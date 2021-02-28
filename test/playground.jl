include("../src/CBFV.jl")

d = DataFrame(:formula=>["TiO2","SiO2","SiC"],:target=>[1000.0,1200.0,2400.0])
e1,e2 = CBFV.readdatabasefile("databases/jarvis.csv") |> CBFV.processelementdatabase
pd = CBFV.processinput(d,e2) |> DataFrame # ✓
pde = CBFV.processelementdatabase(pd,combine=true)

d = DataFrame(:formula=>["TiX2","SiO2","SiC"],:target=>[1000.0,1200.0,2400.0])
CBFV.processinput(d,e2)
