# see LICENSE

"""
        generate_available_databases()

# Returns
-`dictfiles::Dict{String,String}`: database name and filename+extension

# TODO
- This will eventually get replaced by using and `Artifcats.toml` that will
provide the interface for getting the database.
        
""" function generate_available_databases()
        path = joinpath(rootdir,"databases");
        listfiles = split.(readdir(path),".")
        dictfiles = Dict(String(l[1])=>joinpath(path,l[1]*"."*l[2]) for l in listfiles) 
        pop!(dictfiles,"README")
        return dictfiles
end  # function generatedatabases

show_available_databases() = show(keys(generate_available_databases()))

"""
    readdatabasefile(pathtofile)

Returns DataFrame of an elemental database file in [databases/](databases/)

# Arguments
- `pathtofile::String`: path to the CSV formatted file to read

# Returns
- `data::DataFrame`: the dataframe representation of the csv file.
"""
function readdatabasefile(pathtofile::AbstractString;
                          stringtype::Type{T}=String) where T<:Union{String,InlineString}
    # Use CSV and dataframes
    data = CSV.File(pathtofile,stringtype=stringtype) |> DataFrame
    return data
end  # function readdatabasefile
