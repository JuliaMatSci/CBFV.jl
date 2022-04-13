using CBFV
using Test
using CSV, DataFrames

@testset "CBFV.jl" begin

    @testset "Types.jl constructors" begin
        begin
         afile = CBFV.FileName("test/file.txt")
         @test afile.fullpath == "test/file.txt"
        end 
    end # Types.jl tesset

    @testset "ProcessFormulaInput.jl functions" begin
        @test CBFV.replacechar("Y3N@C80") == "Y3NC80"
        @test CBFV.replacechar("Li3Fe2[PO4]3") == "Li3Fe2(PO4)3"
        @test CBFV.replacechar("SiO_2",addswapkeys=[Pair("_","")]) == "SiO2"
        @test CBFV.setdefaultdict("SiO2") == Dict("Si"=>0,"O"=>0)
        @test CBFV.getrepresentation("PO4",molfactor=3) == Dict("P"=>3,"O"=>12)
        @test CBFV.getrepresentation("SiO2") == Dict("Si"=>1,"O"=>2)
        @test CBFV.rewriteformula("Li3Fe2(PO4)3") == "Li3Fe2P3.0O12.0"
        @test CBFV.rewriteformula("Si(OH)4(CO2)3") == "SiO4.0H4.0C3.0O6.0"
        begin
            correct = Dict("Li"=>3,"Fe"=>2,"P"=>3,"O"=>12);
            output = CBFV.parseformula("Li3Fe2[PO4]3")
            @test output == correct
        end
        begin
            correct = Dict("Y"=>3,"N"=>1,"C"=>80);
            output = CBFV.parseformula("Y3N@C80")
            @test output == correct
        end
        begin
            correct = Dict("H"=>4,"O"=>2);
            output = CBFV.parseformula("(H2O)(H2O)")
            @test output == correct
        end
            correct = Dict("H"=>2,"O"=>1);
            output = CBFV.parseformula("(H2O)0.5(H2O)0.5")
            @test output == correct
    end # ProcessFormulaInput.jl testset
    

    @testset "Composition.jl functions" begin
        begin
            correct = Dict("Li"=>3,"Fe"=>2,"P"=>3,"O"=>12);
            output = CBFV.elementalcomposition("Li3Fe2[PO4]3",frmtarray=false)
            @test output == correct
        end
        begin 
            correct = Dict("Y"=>3/84,"N"=>1/84,"C"=>80/84)
            output = CBFV.fractionalcomposition("Y3N@C80",frmtarray=false) 
            @test output == correct
        end
        begin
            correct = (["Y","C","N"],[3/84 , 80/84 , 1/84])
            output = CBFV.fractionalcomposition("Y3N@C80")
            @test correct == output
        end

    end # Composition.jl testset

    @testset "Databases.jl functions" begin
            @test typeof(CBFV.generate_available_databases()) == Dict{String,String} 
            # @test CBFV.show_available_databases() == nothing
    end # Databases.jl testset

    @testset "ProcessData.jl functions" begin
        @test typeof(CBFV.getelementpropertydatabase()) == DataFrame
        begin
            eletest = DataFrame(:element => ["Pr","Ni","Ru"],
                                 :C0 => [58.7, 257.5, 562.1],
                                 :C1 => [25.6, 171.8, 183.8],
                                 :C2 => [0.0, 0.0, 0.0],
                                 :C3 => [0.0, 0.0, 0.0])
            
            
            # NOTE: Ficticious materials
            inputtest = DataFrame(:formula=>["PrNi2","PrNi","PrRuNi3"],:target=>[1000.0,1200.0,2400.0])
            colnames,processdata = CBFV.processinputdata(inputtest,eletest)
            @test typeof(colnames) == Vector{String}

            
            @test processdata[1][:elements] == ["Pr","Ni"]
            @test processdata[1][:amount] == [1.0,2.0]
            @test processdata[2][:eleprops] == [58.7 25.6 0.0 0.0; 257.5 171.8 0.0 0.0]
            @test processdata[2][:target] == 1200.0
            @test processdata[3][:elements] == ["Pr","Ni","Ru"]
            @test processdata[3][:amount] == [1.0,3.0,1.0]

            inputtest = DataFrame(:formula=>["PrX2","PrNi","PrRuQ3"],:target=>[1000.0,1200.0,2400.0])
            eleinfo,processdata = CBFV.processinputdata(inputtest,eletest)

            @test length(processdata) == 1
            @test processdata[1][:elements] == ["Pr","Ni"]
            @test processdata[1][:amount] == [1.0,1.0]

            @test !isnothing(CBFV.processinputdata(inputtest))
        end
    end # ProcessData.jl testset

    @testset "Featurization.jl functions" begin
        d = DataFrame(:formula=>["Tc1V1","Cu1Dy1","Cd3N2"],
                      :property=>[1.0,0.5,1.0],
                      :target=>[248.539,66.8444,91.5034])
        featdb = CBFV.generatefeatures(d,returndataframe=true)

        tmpfile = tempname()
        CSV.write(tmpfile,d)
        @test featdb == CBFV.generatefeatures(tmpfile,returndataframe=true)
     
        testdb = CSV.File("pycbfv_test_data.csv") |> DataFrame
        @test length(names(featdb[!,Not([:target,:formula])])) == length(names(testdb))
        @testset "Column $n" for n in names(testdb)
            @test testdb[!,n] ≈ featdb[!,n]
        end

    end # Featurization.jl testset
end
