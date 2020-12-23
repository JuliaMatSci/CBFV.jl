using CBFV
using Test

@testset "CBFV.jl" begin

    @testset "ProcessComposition.jl functions" begin
        @test CBFV.replaceformula("Y3N@C80") == "Y3NC80"
        @test CBFV.replaceformula("Li3Fe2[PO4]3") == "Li3Fe2(PO4)3"
        @test CBFV.replaceformula("SiO_2",addswapkeys=[Pair("_","")]) == "SiO2"
    end
    # Write your tests here.
end
