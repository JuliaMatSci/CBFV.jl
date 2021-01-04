# see LICENSE

"""
""" function assignfeatures(processeddata::AbstractArray,
                            elementinfo::Dict{String,Array},
                            formulae::Array{String,1},
                            extendfeatures::Bool,
                            combinefeatures::Bool)
    iterformulae = ProgressBar(1:length(formulae))
    skippedformula = Array{String,1}()

    for i in iterformulae
        formula = formulae[i]
        elements = processeddata[i,1]
        amount = processeddata[i,2]
        properties = processeddata[i,3]
        target = processeddata[i,end] 

        compositionmat = zeros(length(elements),length(properties))

        for (i,e) in enumerate(formula)
            if e ∈ elementinfo[:missing]
                push!(skippedformula,e)
            else
                index = findall(x-> x == e, elementinfo[:symbols])
                row = elementinfo[:index][index]
                compositionmat[i,:] = properties[row]
            end
        end

        

        set_description(iterformulae,"Assigning features")
    end

end  # function assignfeatures

"""
""" function constructfeaturedataframe(features,target,formula,skipped)
    
end  # function constructfeaturedataframe
"""

""" function generatefeatures(dataname::String;
                             elementdata::String="oliynyk",
                             dropduplicate=true,
                             extendfeatures=false,
                             combinefeatures=false)

   
    # Element feature databases
    elementdatabase = getelementpropertydatabase(elementdata):: DataFrame
    elementinfo,elementdata = processelementdatabase(elementdatabase,combine=combinefeatures)
   
    # Digest and process input data
    data = readdatabasefile(dataname)::DataFrame
    checkdataframe(data)
    formulae = data[!,:formula]
    processeddata = processinput(data,elementdata)

    # Featurization
    # features,targets,formulae,skipped = assignfeatures(processeddata,
    #                                                   elementinfo,
    #                                                   formulae,
    #                                                   extendfeatures,
    #                                                   combinefeatures)
    #X,y,formulae,skipped = constructfeaturedataframe(features,targets)
    #return X,y,formula,skipped
end  # function generatefeaturesdata 

"""

""" function generatefeatures(data::DataFrame)
    return nothing
end  # function generatefeaturesdata

generatefeatures(data::Union{String,DataFrame},elementdata::FileName) = generatefeatures(data,elementdata.fullpath)
