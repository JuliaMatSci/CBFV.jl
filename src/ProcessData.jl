# see LICENSE

"""

""" function removeunsupported(datainput::DataFrame,elementsproperties::AbstractArray)
    
end  # function removeunsupported

"""
    extractproperties(elementproperties,formulaelements)

returns an array of properties for elements that are in a formula.

# Arguments
-`elementproperties::AbstractArray` : array formatted database element properties
-`formulaelements::Array{String,1}` : elements form a formula in array format.

# Returns
-`properties::Array{Any,2}` : parsed/selected element properties from elementproperties.

""" function extractproperties(elementproperties::AbstractArray,formulaelements::Array{String,1})
    _,m = size(elementproperties)
    l = length(formulaelements)
    properties = Array{Any,2}(undef,l,m)
    
    for (i,e) in enumerate(formulaelements)
        coordinate = findfirst(x -> x == e,elementproperties)
        properties[i,:] = elementproperties[coordinate.I[1],:]
    end

    return properties
end  # function extractproperties

"""
#TODOS!
    * Need to remove non-supported formulas (add skip)

    processinput(datainput)

Take a DataFrame datatype and return an Array datatype with additional data.

# Arguments
-`datainput::DataFrame`: data containing columns :formula and :target.
-`elementfeatures::Array{Number,2}`: element feature set based on database 

# Returns
-`processdata::Array{Array{Any},2}`: Array format of data with additional content.
""" function processinput(datainput::DataFrame,elementsproperties::AbstractArray)

    checkdataframe(datainput);
    
    # Need to remove unsupported formula
    #moddatainput = removenonsupported()
    
    n,m = size(datainput);
    #Seems like this should be a dictionary of Array{Dict,1} if Array{Any,2}?
    processdata = Array{Array{Any},2}(undef,n,m+2)

    # Performant iterator?
    table = Tables.namedtupleiterator(datainput[!,[:formula,:target]]);
    
    i = 1
    itertable = ProgressBar(table)
    for row in itertable
        formula,target = row[1],row[2]
        elements,amount = elementalcomposition(formula)
        _,fractions = fractionalcomposition(formula)
        
        extractedproperties = extractproperties(elementsproperties,elements)

        # Catch if element was not in property database
        if elements == extractedproperties[:,1]
        end
        processdata[i,1:end] = [elements,amount,extractedproperties,[target]]
        i += 1
        set_description(itertable,"Processing Input Data")
    end
    return processdata
end  # function processinput

"""
Returns DataFrame
""" function readdatabasefile(pathtofile::String)
       # Use CSV and dataframes
       data = CSV.File(pathtofile) |> DataFrame
       return data
end  # function readdatabasefile

"""
    processelementdatabase(data;combine=false)

takes the element feature dataframe and process it to return a
dictionary with values of type Array{String,N} and a Array representation
of the entire database.

# Arguments
-`data::DataFrame`: element feature dataframe from database file
-`combine::Bool`: determines if old column names are combined with new ones

# Returns
-`elementproperties::Dict{Symbol,Array{String,N}}`: dictionary with keys :symbols,
:index, and :missing which return Array{String,N} values for the dataframe
-`arrayrepresentation::Array{Any,2}`: representation of the dataframe

""" function processelementdatabase(data::DataFrame;combine=false)

    elementsymbols = data[!,:element] :: Array{String,1}
    elementindex = collect(1:nrow(data))
    elementmissing = collect(setdiff(
                             Set(allowedperiodictable),Set(elementsymbols)
                             )) :: Array{String,1}
    columnnames = names(data) :: Array{String,1}
    
    
    newcolumnnames = ["avg_" .* columnnames;
                      "var_" .* columnnames;
                      "range_" .* columnnames]
    if combine
        newcolumnnames = cat(columnnames,newcolumnnames,dims=1)
    end

    elementproperties = Dict(:symbols=>elementsymbols,
                             :index=>elementindex,
                             :missing=>elementmissing)
    # Replace missing with mean or zero, how was this done in python ver.
    arrayrepresentation = convert(Array,data)

    return elementproperties, arrayrepresentation
end # function readdata

"""
    getelementpropertydatabase(databasename)

# Returns
-`database::DataFrame`

""" function getelementpropertydatabase(databasename::String="oliynyk")
    #Check if databasename in database folder using function call
    databases = generate_available_databases()::Dict{String,String}
    if databasename ∈ keys(databases)
        database = readdatabasefile(databases[databasename])
    else
        databaseerror(databasename)
    end
    return database
end  # function elementpropertydatabase