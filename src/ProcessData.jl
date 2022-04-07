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

!!! Warn
    At the moment we just remove formula's with unsupported elements if they
    weren't in the elemental database. This is  not how the original CBFV 
    handled this, instead they treated the entries as NaN and then assigned the 
    median value of the feature during the featurization process.
""" function removeunsupported!(datainput::DataFrame)

    formulas = copy(datainput[!,:formula])
    rows = range(1,nrow(datainput))
    splitformulas = keys.(getrepresentation.(formulas))

    for i=1:length(formulas)
        for el in splitformulas[i]
            if stripamt(el) ∉ allowedperiodictable
                # modify so that only those rows not equal are kept.
                elementwarn(el,formulas[i],row=rows[i])
                filter!(row-> row.formula != formulas[i],datainput)
            end
        end
    end
end  # function removeunsupported!

"""
    extractproperties(elements,properties,formulaelements)

returns an array of properties for elements that are in a formula.

# Arguments
-`elements::Vector{String}` : supported elements from elemental database.
-`properties::AbstractArray` : array formatted database element properties
-`formulaelements::Array{String,1}` : elements form a formula in array format.

# Returns
-`extractdedproperties::Array{Any,2}` : parsed/selected element properties from elementproperties.

""" function extractproperties(elements::Vector{String},
                              properties::AbstractArray,
                              formulaelements::Array{String,1},
                              formula::String)
    _,m = size(properties)
    l = length(formulaelements)
    extractedproperties = Array{Number,2}(undef,l,m)
    
    for (i,e) in enumerate(formulaelements)
        if stripamt(e) ∉ elements
            elementmissinginfo(e,formula)
            extractedproperties[i,:] = fill(NaN,m)
        else
            coordinate = findfirst(x -> x == e,elements)
            extractedproperties[i,:] = properties[coordinate,:]
        end
    end

    return extractedproperties
end  # function extractproperties

"""
Returns DataFrame of an elemental database file in [databases/](databases/)
""" function readdatabasefile(pathtofile::String)
       # Use CSV and dataframes
       data = CSV.File(pathtofile) |> DataFrame;
       return data
end  # function readdatabasefile

"""
    getelementpropertydatabase(databasename)

Reads a elemental database file given its name.

# Arguments
-`databasename::String="oliynyk"` - name of internally available database file. See [databases](CBFV/databases)

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
    return database :: DataFrame
end  # function elementpropertydatabase

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
    
    columnnames = names(data[!,Not(:element)])

    elementsymbols = convert(Vector{String},data[!,:element])
    elementindex = collect(1:nrow(data))
    elementmissing = collect(setdiff(
                             Set(allowedperiodictable),Set(elementsymbols)
                             )) :: Array{String,1}
    
    elementinfo = Dict(:symbols=>elementsymbols,
                             :index=>elementindex,
                             :missing=>elementmissing)

    arrayrepresentation = Tables.matrix(data[!,Not(:element)])

    return elementinfo, columnnames, arrayrepresentation
end # function processelementdatabase

processelementdatabase(databasename::String) = begin
    data = getelementpropertydatabase(databasename)
    processelementdatabase(data)
end

processelementdatabase(databasepath::FileName) = begin
    data = readdatabasefile(databasepath.fullpath)
    processelementdatabase(data)
end


"""
    processinputdata(datainput,elementdatabase;combine=false)

Take a DataFrame datatype and return an Array datatype with additional data.

# Arguments
-`datainput::DataFrame`: data containing columns ``:formula`` and `:target`.
-`elementfeatures::Array{Number,2}`: element feature set based on database 

# Returns
-`processeddata::Array{Array{Any},2}`: Array format of data with additional content.

""" function processinputdata(datainput::DataFrame,elementdatabase::DataFrame)

    elementinfo,elpropnames,elementsproperties = processelementdatabase(elementdatabase)

    checkdataframe(datainput);

    removeunsupported!(datainput)
    
    n,_ = size(datainput);
   
    processeddata = Vector{Dict{Symbol,Any}}(undef,n)

    #CHECK: Is this a performant iterator
    table = Tables.namedtupleiterator(datainput[!,[:formula,:target]]);
    
    i = 1
    itertable = ProgressBar(table)
    for row in itertable
        formula,target = row[1],row[2]
        elements,amount = elementalcomposition(formula)
        
        extractedproperties = extractproperties(elementinfo[:symbols],
                                                elementsproperties,
                                                elements,formula)

        processeddata[i] = Dict(:elements => elements, 
                              :amount => amount, 
                              :eleprops => extractedproperties,
                              :target => target)

        i += 1
        set_description(itertable,"Preparing input data...")
    end
    return elpropnames, processeddata
end  # function processinputdata

processinputdata(datainput::DataFrame,elementdatabasename::String) = begin
    eledb = getelementpropertydatabase(elementdatabasename)
    processinputdata(datainput,eledb)
end

processinputdata(datainput::DataFrame) = begin
    eledb = getelementpropertydatabase("oliynyk")
    processinputdata(datainput,eledb)
end    