# see LICENSE

function checkdataframe(dataframe::DataFrame)
    if !hasproperty(dataframe,:formula) && !hasproperty(dataframe,:target)
        error("Dataframe is missing columns :formula or :target")
    end
    return nothing
end

function checkcombineallowed(dataframe::DataFrame)
    extrprops = dataframe[!,Not([:formula,:target])]
    if !isempty(extrprops)
        return true
    else
        @warn "Combining of features requested but none exist, skipping!"
        return false
    end
end

function elementmissinginfo(element::String,formula::String)
    @info("The elemental database didn't contain the $(element) in for \n
    input formula $(formula), so values is being set to NaN.")
end # elementmissing

function elementwarn(element,formula;row=nothing)
    if row !== nothing
        @warn("$(element) in chemical formula $(formula) on row $(row) is not a valid symbol 
        or is an unsupported element, this formula/entry is being skipped.")
    else
        @warn("$(element) in chemical formula $(formula) is not a valid symbol 
        or is an unsupported element, this formula/entry is being skipped.")
    end
    return nothing
end  # function elementwarn

function databaseerror(name::String)
    error("The database or file name $(string) could not be found or loaded")
    return nothing
end  # function databaseerror