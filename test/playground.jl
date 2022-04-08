include("../src/CBFV.jl")
using DataFrames

d = DataFrame(:formula=>["Tc1V1","Cu1Dy1","Cd3N2"],:target=>[248.539,66.8444,91.5034])
dfele = CBFV.readdatabasefile("databases/jarvis.csv")
e1,e2 = CBFV.processelementdatabase(dfele)
en,pd = CBFV.processinputdata(d,dfele)  # ✓

feat = CBFV.generatefeatures(d,returndataframe=true)

d = DataFrame(:formula=>["TiX2","SiO2","SiC"],:target=>[1000.0,1200.0,2400.0])
ei,en,pd = CBFV.processinputdata(d,dfele)


    # features,targets,formulae,skipped = assignfeatures(processeddata,
    #                                                   elementinfo,
    #                                                   formulae,
    #                                                   extendfeatures,
    #                                                   combinefeatures)de