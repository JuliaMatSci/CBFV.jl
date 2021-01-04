using CBFV
using Test

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
    end

    @testset "ProcessData.jl functions" begin
        @test typeof(CBFV.getelementpropertydatabase()) == DataFrame
    end
    
end
