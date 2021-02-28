# see LICENSE

"""
        generate_available_databases()

# Returns
-`dictfiles::Dict{String,String}`: database name and filename+extension
""" function generate_available_databases()
        path = joinpath(rootdir,"databases");
        println(path)
        listfiles = split.(readdir(path),".")
        dictfiles = Dict(String(l[1])=>joinpath(path,l[1]*"."*l[2]) for l in listfiles) 
        pop!(dictfiles,"README")
        return dictfiles
end  # function generatedatabases

show_available_databases() = show(keys(generate_available_databases()))
