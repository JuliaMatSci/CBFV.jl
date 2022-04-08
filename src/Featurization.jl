# see LICENSE

"""     combinefeatures!(features,extras)
        combinefeatures!(features,featnames,extras)


Combines existing features in data with the prepared features. Returns additional
vector of column names for a database.

# Arguments
- `features::AbstractArray`: Generated features of data
- `extras::DataFrame`: The data frame representation of the orignial data.
- `featnames::Vector`: The column names of the generated features.

# Returns (Optional)
- `combfeatnames::Vector{String}`: Combined names of feature columns.

"""
function combinefeatures!(features::AbstractArray, extras::DataFrame)
    if checkcombineallowed(extras)
        extrasarry = Tables.matrix(extras)
        features = hcat(features, extrasarry)
    end
end  # function combinefeatures

combinefeatures!(features::AbstractArray, featnames::Vector, extras::DataFrame) = begin

    if checkcombineallowed(extras)
        extrasarry = Tables.matrix(extras)
        features = hcat(features, extrasarry)
        combfeatnames = vcat(featnames, names(extras))
    else
        combfeatnames = featnames
    end
    return combfeatnames
end

"""
    assignfeatures(processeddata,formulae,sumfeatures)


This is the primary function that assigns the features based on the CBFV approach. For more
details its best to see the original python CBFV and references in README file.


"""
function assignfeatures(processeddata::Vector{Dict{Symbol,Any}},
    formulae::Array{String,1},
    sumfeatures::Bool=false)

    iterformulae = ProgressBar(1:length(formulae))
    skippedformula = Array{String,1}()

    features = Vector{Matrix{Number}}(undef, length(formulae))

    for i in iterformulae
        formula = formulae[i]
        amount = processeddata[i][:amount]
        properties = processeddata[i][:eleprops]

        # Each formula has a n-element by m-feature matrix representation.
        # Construct all the feature vectors
        frange = [e[2] - e[1] for e in extrema(properties, dims=1)]
        fmax = maximum(properties, dims=1)
        fmin = minimum(properties, dims=1)
        _, fraccomp = fractionalcomposition(formula)
        favg = sum(fraccomp .* properties, dims=1)
        fdev = sum(fraccomp .* abs.(properties .- favg), dims=1)
        prominant = isapprox.(fraccomp, maximum(fraccomp))
        fmode = minimum(properties[prominant, :], dims=1)

        fweight = sumfeatures ? sum(amount .* properties, dims=1) : amount .* properties

        if sumfeatures
            features[i] = hcat(fweight, favg, fdev, frange, fmax, fmin, fmode)
        else
            features[i] = hcat(favg, fdev, frange, fmax, fmin, fmode)
        end

        set_description(iterformulae, "Assigning features...")
    end

    featuresarry = reduce(vcat, features)

    return featuresarry, skippedformula

end  # function assignfeatures

"""
    constructfeaturedataframe(featcolnames,features,extrafeatures,sumfeatures)

Return a `DataFrame` data type given the features  with column names and if extra features
are to be added. In addition if the summation statistics should be used as a feature. The
column name prefixes are fixed based on the CBFV approach which is to use the formula statistical
moments from the element features in the formula.

# Arguments

# Returns


"""
function constructfeaturedataframe(featcolnames::Vector{String},
    features::Array{Number,2},
    extrafeatures::Tuple{Bool,DataFrame},
    sumfeatures::Bool)
    if sumfeatures
        colprefixes = ["sum_", "avg_", "dev_", "range_", "max_", "min_", "mode_"]
    else
        colprefixes = ["avg_", "dev_", "range_", "max_", "min_", "mode_"]
    end

    modcolnames = []
    for p in colprefixes
        push!(modcolnames, fill(p, length(featcolnames)) .* featcolnames)
    end
    featnames = reduce(vcat, modcolnames)

    dictfeatnames = Dict{String,Vector}()

    if extrafeatures[1]
        combinedfeatnames = combinefeatures!(features, featnames, extrafeatures[2])
        for (i, n) in enumerate(combinedfeatnames)
            dictfeatnames[n] = features[i, :]
        end
    else
        for (i, n) in enumerate(featnames)
            dictfeatnames[n] = features[:, i]
        end
    end
    return DataFrame(dictfeatnames)
end  # function constructfeaturedataframe

"""
    generatefeatures(data; elementdata,dropduplicate,combine,sumfeatures,returndataframe)
    generatefeatures(data, elementdata; kwargs...)
    generatefeatures(dataname; kwargs...)

This is the primary function for generating the CBFV features for a dataset of formulas with or without
existing features. This function will process the input data and grab the provided element database. The
assigning of features is then executed based on the CBFV approach. If the `returndataframe=true` then a
`DataFrame` data type is returned by this function with the added columns `:target` and `:formula`. 
    
!!! note
    I am not using `OrderedDict` so the column names will be arranged based on the native `Dict` 
    ordering. 

# Arguments
- `data::DataFrame`: This is the data set that you want to be featurized for example.
- `elementdata::Union{String,FileName}`: The name of the internal database or the file path and
name to an external database.
- `dropduplicate::Bool=true`: Option to drop duplicate entries.
- `combine::Bool=false`: Option to combine existing features in `data` with the generated feature set.
- `sumfeatures::Bool=false`: Option to include the `sum_` feature columns.
- `returndataframe::Bool=true`: Option to return a `DataFrame`. Will include `:target` and `:formula` columns.

# Returns
- `generatedataframe::DataFrame`
- `formulae::Vector{String}, features::Array{Number,2}, targets::Vector{Number}`

The following featurization schemes are included within CBFV.jl:

- `oliynyk` (default)
- `magpie`
- `mat2vec`
- `jarvis`
- `onehot`
- `random_200`

```@example
using DataFrames
using CBFV
d = DataFrame(:formula=>["Tc1V1","Cu1Dy1","Cd3N2"],:target=>[248.539,66.8444,91.5034])
generatefeatures(d)
```




# TODOs
- Add dropduplicate Optional
- Decide what to do with `skippedformulas`
- Process elementa data features with `NaN`
"""
function generatefeatures(data::DataFrame;
    elementdata::String="oliynyk",
    dropduplicate=true,
    combine=false,
    sumfeatures=false,
    returndataframe=true)

    # Process input data
    checkdataframe(data)
    formulae = data[!, :formula]
    featcolnames, processeddata = processinputdata(data, elementdata)

    targets = [row[:target] for row in processeddata]

    # Featurization
    features, skippedformulas = assignfeatures(processeddata,
        formulae,
        sumfeatures)
    extrafeatures = data[!, Not([:formula, :target])]

    #TODO: need to fill features that are NaN with median values.

    if returndataframe
        generatedataframe = constructfeaturedataframe(featcolnames, features, (combine, extrafeatures), sumfeatures)
        generatedataframe[!, :formula] = formulae
        generatedataframe[!, :target] = targets
        return generatedataframe
    else
        if combine
            combinefeatures!(features, extrafeatures)
        end
        return formulae, features, targets
    end

end  # function generatefeaturesdata 

generatefeatures(dataname::String; kwargs...) = begin
    # Digest data file before processing
    data = readdatabasefile(dataname)::DataFrame
    generatefeatures(data, kwargs...)
end

generatefeatures(data::Union{String,DataFrame}, elementdata::FileName; kwargs...) = begin
    generatefeatures(data, elementdata=elementdata.fullpath, kwargs...)
end
