# see LICENSE


struct FeatureVectors
    avg::Vector{Float64}
    range::Vector{Float64}
    max::Vector{Float64}
    min::Vector{Float64}
    mode::Vector{Float64}
    dev::Vector{Float64}
end

"""
generatefeatures Datatype for multiple dispatch
""" struct FileName
    fullpath::String
end