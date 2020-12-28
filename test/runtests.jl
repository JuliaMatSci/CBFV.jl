using CBFV
using Test

@testset "CBFV.jl" begin

    @testset "ProcessComposition.jl functions" begin
        @test CBFV.replacechar("Y3N@C80") == "Y3NC80"
        @test CBFV.replacechar("Li3Fe2[PO4]3") == "Li3Fe2(PO4)3"
        @test CBFV.replacechar("SiO_2",addswapkeys=[Pair("_","")]) == "SiO2"
        @test CBFV.setdefaultdict("SiO2") == Dict("Si"=>0,"O"=>0)
        @test CBFV.getrepresentation("PO4",molfactor=3) == Dict("P"=>3,"O"=>12)
        @test CBFV.getrepresentation("SiO2") == Dict("Si"=>1,"O"=>2)
        @test CBFV.rewriteformula("Li3Fe2(PO4)3") == "Li3Fe2P3O12"
        @test CBFV.rewriteformula("Si(OH)4(CO2)3") == "SiO4H4C3O6"
        begin
            correct = Dict("Li"=>3,"Fe"=>2,"P"=>3,"O"=>12);
            output = CBFV.parseformula("Li3Fe2[PO4]3")
            @test output == correct
        end
    end
    # Write your tests here.
end
