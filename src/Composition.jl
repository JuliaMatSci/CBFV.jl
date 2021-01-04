# see LICENSE

"""

elementalcomposition(formula;frmtarray=true)

Construct a element count fdictionary.

# Arguments
-`formula::String`: chemical formula
-`frmtarray::Bool`: flag indicating type of return value

# Returns
-`amountelement::Dict{String,Float64} or Tuple{Array,Array}`
""" function elementalcomposition(formula::String;frmtarray=true)
    elementmap = parseformula(formula)
    amountelement = Dict{String,Float64}()
    for (key,val) in elementmap
        if abs(val) ≥ 1.0e-4
            amountelement[key] = val
        end
    end
    return frmtarray ? dicttoarray(amountelement) : amountelement
end  # function elementalcomposition


"""
    fractionalcomposition(formula;frmtarray=true)

Construct a composition fraction dictionary.

# Arguments
-`formula::String`: chemical formula
-`frmtarray::Bool`: flag indicating type of return value

# Returns
-`compositionfrac::Dict{String,Float64} or Tuple{Array,Array}`
""" function fractionalcomposition(formula::String;frmtarray=true)

    # this part we need the function call frmtarray=false
    amountelement = elementalcomposition(formula,frmtarray=false)

    natoms = sum(abs.(values(amountelement)))
    compositionfrac = Dict(key => amountelement[key]/natoms for key in keys(amountelement))
    return frmtarray ? dicttoarray(compositionfrac) : compositionfrac
end # function fractionalcomposition

"""
    dicttoarray(dict)

convert a dictionary of Dict{String,T<:Number} to two arrays of keys and values.

# Arguments
-`dict::Dict{String,Number}`: dictionary to convert

# Returns
-`k::Array{Number}`: an array corresponding to the keys
-`v::Array{Number}`: an array corresponding to the values
""" function dicttoarray(dict::Dict{String,T}) where T<:Number
    k = [a for a in keys(dict)]
    v = [c for c in values(dict)]
    return k,v
end  # function dicttoarray 