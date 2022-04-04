# see LICENSE


"""
        removeunsupported!(datainput,elementproperties)

Handle cases where compound can't be processed because it isn't an allowed element symbol
or because the elements of the formula don't have properties in the data base.

# Arguments
- `datainput::DataFrame`  : data frame representation of input data set.
- `elementproperties::Abstract` : Array of elements with properties for featurization.

# Modifies
- `datainput` : removes unsupported items.

""" function removeunsupported!(datainput::DataFrame,elementsproperties::AbstractArray)

    elements = convert(Vector{String},elementsproperties[:,1])
    formulas = copy(datainput[!,:formula])
    splitformulas = splitcap.(formulas)

    for i=1:length(formulas)
        for el in splitformulas[i]
            if stripamt(el) ∉ allowedperiodictable ||  stripamt(el) ∉ elements
                # modify so that only those rows not equal are kept.
                filter!(row-> row.formula != formulas[i],datainput)
            end
        end
    end
end  # function removeunsupported!

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

""" function processelementdatabase(data::DataFrame)

    elementsymbols = convert(Vector{String},data[!,:element])
    elementindex = collect(1:nrow(data))
    elementmissing = collect(setdiff(
                             Set(allowedperiodictable),Set(elementsymbols)
                             )) :: Array{String,1}
    
    # This goes into featurization functions
    # columnnames = names(data)
    
    # newcolumnnames = ["avg_" .* columnnames;
    #                  "var_" .* columnnames;
    #                  "range_" .* columnnames]
    # if combine
    #    newcolumnnames = cat(columnnames,newcolumnnames,dims=1)
    # end

    elementinfo = Dict(:symbols=>elementsymbols,
                             :index=>elementindex,
                             :missing=>elementmissing)

    # TODO: Replace missing with mean or zero, how was this done in python ver.
    # also why am I doing this instead of just working with DataFrame?
    arrayrepresentation = Tables.matrix(data)

    return elementinfo, arrayrepresentation
end # function readdata


"""
Returns DataFrame of an elemental database file in [databases/](databases/)
""" function readdatabasefile(pathtofile::String)
       # Use CSV and dataframes
       data = CSV.File(pathtofile) |> DataFrame
       return data
end  # function readdatabasefile

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


"""
    processinput(datainput,elementdatabase)

Take a DataFrame datatype and return an Array datatype with additional data.

# Arguments
-`datainput::DataFrame`: data containing columns :formula and :target.
-`elementfeatures::Array{Number,2}`: element feature set based on database 

# Returns
-`processdata::Array{Array{Any},2}`: Array format of data with additional content.
""" function processinput(datainput::DataFrame,elementdatabase::DataFrame)

    elementinfo,elementsproperties = processelementdatabase(elementdatabase)

    checkdataframe(datainput);
    
    removeunsupported!(datainput,elementsproperties)
    
    n,_ = size(datainput);
   
    #Line belows follow python approach.
    #processdata=Array{Array{Any},2}(undef,n,m+2)
    
    processdata = Vector{Dict{Symbol,Any}}(undef,n)

    #CHECK: Is this a performant iterator
    table = Tables.namedtupleiterator(datainput[!,[:formula,:target]]);
    
    i = 1
    itertable = ProgressBar(table)
    for row in itertable
        formula,target = row[1],row[2]
        elements,amount = elementalcomposition(formula)
        #_,fractions = fractionalcomposition(formula)
        
        extractedproperties = extractproperties(elementsproperties,elements)

        #The line above follows the python approach but doesn't seem ideal.
        #processdata[i,1:end] = [elements,amount,extractedproperties,[target]]

        processdata[i] = Dict(:elements => elements, 
                              :amount => amount, 
                              :eleprops => extractedproperties,
                              :target => target)
        i += 1
        set_description(itertable,"Preparing Input Data")
    end
    return elementinfo, processdata
end  # function processinput

processinput(datainput::DataFrame,elementdatabasename::String="oliynyk") = begin
    eledb = getelementpropertydatabase(elementdatabasename)
    processinput(datainput,eledb)
end