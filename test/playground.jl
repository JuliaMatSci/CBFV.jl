include("../src/CBFV.jl")

d = DataFrame(:formula=>["TiO2","SiO2","SiC"],:target=>[1000.0,1200.0,2400.0])
processinput(d)