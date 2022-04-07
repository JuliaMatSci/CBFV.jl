# see LICENSE

"""     combinefeatures!(features,extras)
        combinefeatures!(features,featnames,extras)


Combines existing features in data with the prepared features. Returns additional
vector of column names for a database.

# Arguments
- `features::AbstractArray` - Generated features of data
- `extras::DataFrame` - The data frame representation of the orignial data.
- `featnames::Vector` - The column names of the generated features.

# Returns (Optional)
- `combfeatnames::Vector{String}` - Combined names of feature columns.

"""
function combinefeatures!(features::AbstractArray,extras::DataFrame)
    if checkcombineallowed(extras)
        extrasarry = Tables.matrix(extras)
        features = hcat(features,extrasarry)
    end
end  # function combinefeatures

combinefeatures!(features::AbstractArray,featnames::Vector,extras::DataFrame) = begin
    
    if checkcombineallowed(extras)
        extrasarry = Tables.matrix(extras)
        features = hcat(features,extrasarry)
        combfeatnames = vcat(featnames,names(extras))
    else
        combfeatnames = featnames
    end
    return combfeatnames
end

"""
""" function assignfeatures(processeddata::Vector{Dict{Symbol,Any}},
                            formulae::Array{String,1},
                            sumfeatures::Bool=false)

    iterformulae = ProgressBar(1:length(formulae))
    skippedformula = Array{String,1}()

    features = Vector{Matrix{Number}}(undef,length(formulae))

    for i in iterformulae
        formula = formulae[i]
        amount = processeddata[i][:amount]
        properties = processeddata[i][:eleprops]

        # Each formula has a n-element by m-feature matrix representation.
        # Construct all the feature vectors
        frange = [e[2]-e[1] for e in extrema(properties,dims=1)]
        fmax = maximum(properties,dims=1)
        fmin = minimum(properties,dims=1)
        _,fraccomp = fractionalcomposition(formula)
        favg = sum(fraccomp .* properties, dims=1)
        fdev = sum(fraccomp .* abs.(properties .- favg),dims=1)
        prominant = isapprox.(fraccomp,maximum(fraccomp))
        fmode = minimum(properties[prominant,:],dims=1)
    
        fweight = sumfeatures ? sum(amount.*properties,dims=1) : amount.*properties
    
        if sumfeatures
            features[i] = hcat(fweight, favg, fdev, frange, fmax, fmin, fmode);
        else
            features[i] = hcat(favg, fdev, frange, fmax, fmin, fmode);
        end

        set_description(iterformulae,"Assigning features...")
    end

    featuresarry = reduce(vcat,features)

    return featuresarry, skippedformula

end  # function assignfeatures

"""
""" function constructfeaturedataframe(features,target,formula,skipped)
     # newcolumnnames = ["avg_" .* columnnames;
    #                  "var_" .* columnnames;
    #                  "range_" .* columnnames]
    # if combine
    #    newcolumnnames = cat(columnnames,newcolumnnames,dims=1)
    # end
end  # function constructfeaturedataframe
"""

""" function generatefeatures(data::DataFrame;
                             elementdata::String="oliynyk",
                             dropduplicate=true,
                             combine=false,
                             sumfeatures=false,
                             returndataframe=true)

   
    # Element feature databases
    #elementdatabase = getelementpropertydatabase(elementdata):: DataFrame
    #elementinfo,elementdata = processelementdatabase(elementdatabase,combine=combinefeatures)
    
    # Process input data
    checkdataframe(data)
    formulae = data[!,:formula]
    featcolnames,processeddata = processinputdata(data,elementdata)
   
    targets = [row[:target] for row in processeddata]
   
    # Featurization
    features,skippedformula = assignfeatures(processeddata,
                                             formulae,
                                             sumfeatures)
    extrafeatures = data[!,Not([:formula,:target])]

    #TODO: need to fill features that are NaN with median values.

    if returndataframe
        if sumfeatures
            colprefixes = ["sum_","avg_","dev_","range_","max_","min_","mode_"]
        else 
            colprefixes = ["avg_","dev_","range_","max_","min_","mode_"]
        end

        modcolnames = []
        for p in colprefixes
            push!(modcolnames,fill(p,length(featcolnames)).*featcolnames)
        end
        featnames = reduce(vcat,modcolnames)

        dictfeatnames = Dict{String,Vector}("formula"=>formulae)

        # Stopping-Point 5 Apr 2022
        # Need tof igure out why the dictionary of feature names is failing.
        if combine 
            combinedfeatnames = combinefeatures!(features,featnames,extrafeatures) 
            for (i,n) in enumerate(combinedfeatnames)
                dictfeatnames[n] = features[i,:]
            end
        else
            for (i,n) in enumerate(featnames)
                dictfeatnames[n] = features[:,i]
            end
        end
      
        dictfeatnames["target"] = targets
        generatedataframe = DataFrame(dictfeatnames)
        return generatedataframe
    else
        if combine combinefeatures!(features,extrafeatures) end
        return formulae, features, targets
    end
    
end  # function generatefeaturesdata 

generatefeatures(dataname::String;kwargs...) = begin
    # Digest data file before processing
    data = readdatabasefile(dataname)::DataFrame
    generatefeatures(data,kwargs...)
end

generatefeatures(data::Union{String,DataFrame},elementdata::FileName;kwargs...) = begin
    generatefeatures(data,elementdata=elementdata.fullpath,kwargs...)
end
