# see LICENSE

function checkdataframe(dataframe::DataFrame)
    if !hasproperty(dataframe,:formula) && !hasproperty(dataframe,:target)
        error("Dataframe is missing columns :formula or :target")
    end
    return nothing
end

function elementwarn(element,formula)
    @warn("$(element) in chemical formula $(formula) is not a valid symbol, \n 
    this formula is being skipped.")
    return nothing
end  # function elementwarn

function databaseerror(name::String)
    error("The database or file name $(string) could not be found or loaded")
    return nothing
end  # function databaseerror