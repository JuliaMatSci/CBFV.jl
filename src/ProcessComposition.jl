# see LICENSE

"""
    replaceformula(formula)

remove and replace characters based. Function assumes default keys `@`, `[`, and `]`
to swap others can be added via keyword argument.

# Arguments
- `formula::String`: the chemical formula, e.g. CO2, H2O
- `addswapkeys::Array{Pair{String,String}}=[Pair("","")]`: additional characters to swap.

# Returns
- `formula::String`


""" function replaceformula(formula::String;addswapkeys=[Pair("","")])
        swapkeys = [Pair("@",""),Pair("[","("),Pair("]",")")];
        if addswapkeys != [Pair("","")]
            for addkey in addswapkeys
                push!(swapkeys,addkey)
            end
        end
        modformula = formula
        for key in swapkeys
            modformula = replace(modformula,key)
        end
        return modformula        
end

