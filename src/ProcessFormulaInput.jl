# see LICENSE

"""
    replacechar(formula)

Remove and replace characters based. Function assumes default keys `@`, `[`, and `]`
to swap others can be added via keyword argument.

# Arguments
- `formula::String`: the chemical formula, e.g. CO2, H2O
- `addswapkeys::Array{Pair{String,String}}=[Pair("","")]`: additional characters to swap.

# Returns
- `formula::String`
 

""" function replacechar(formula::String;addswapkeys=[Pair("","")])
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
end # function replacechar


"""
    setdefaultdict(formula)

Initializes the default dictionary of type Dict{String,Int}. Each element is set to 0.

""" function setdefaultdict(formula::String)
    defaultdict = Dict{String,Int}()
    elements = findall(r"([A-Z][a-z]*)",formula)
    for e in elements
        defaultdict[formula[e]] = 0
    end
    return defaultdict
end # function getdefaultdict


"""
    getrepresentation(formulaunit;molfactor=1)

Return the formula elemental make-up in terms of multiples of a given element in chemical
formula. Amount due to molecular complexes in chemical formula (e.g., Li3Fe2(PO4)3 ) are handeled with
keyword argument

# Arguments
-`formulaunit::String`: the chemical formula for provided unit, e.g. CO2, H2O
-`molfactor::Integer`: the repeating occurance of molecular complexes, e.g., XX(PO)3

# Returns
-`elementalamount::Dict{String,Integer}`

""" function getrepresentation(formulaunit;molfactor=1)

    elementalamount = setdefaultdict(formulaunit);
    #Assign amount to each element in formula
    elementgroups = findall(r"([A-Z][a-z]*)\s*([-*\.\d]*)",formulaunit);
    for eg in elementgroups
        el,amt = map(String,match(r"([A-Z][a-z]?)(\d*\d?)",formulaunit[eg]).captures)
        iamt = isempty(amt) ? 1 : parse(Int,amt)
        if el ∈ allowedperiodictable
            elementalamount[el] += iamt*molfactor
        else
            error("$(el) in chemical formula $(formulaunit) is not a valid symbol")
        end
    end
    return elementalamount
end # function getrepresentation

"""
    rewriteformula(formula::String)

If formula contains molecular units in the form of AB(CD3)2, rewrite as ABC2D6.

# Arguments
- `formula::String`: A chemical formula such as Li3Fe2(PO4)3 to rewrite

# Returns
- 'modformula::String`: the rewritten chemical formula such as Li3F2P3O12.

""" function rewriteformula(formula::String)
    modformula = formula
    molecularunits = eachmatch(r"\(([^\(\)]+)\)\s*([\.\d]*)",formula)
    for molunit in molecularunits
        molecule,repeat = map(String,molunit.captures)
        irepeat = parse(Int,repeat)
        elementgroups = findall(r"([A-Z][a-z]*)\s*([-*\.\d]*)",molecule);
        molrewrite = ""

        for eg in elementgroups
            element,amount = map(String,match(r"([A-Z][a-z]?)(\d*\d?)",molecule[eg]).captures)
            iamount = isempty(amount) ? 1 : parse(Int,amount)
            iamount *=  irepeat
            molrewrite *= "$(element)$(iamount)"
        end

        elements,amount = map(String,match(r"([A-Z][a-z]?)(\d*\d?)",molecule).captures)
        amount *= repeat
        modformula = replace(modformula,molunit.match => molrewrite)
    end
    return modformula
end #function rewriteformula

"""
    parseformula(formula::String)

Creates a dictionary of elements and stoichiometry for compound formula. If formula is
    written with molecular groupings (e.g., Li3Fe2(PO4)3), then rewrite string.

# Arguments
-`formula::String`: the chemical formula, e.g., Li3Fe2(PO4)3

# Returns
-`Dict{String,Int}`: returns the function call which produces a composition dictionary

""" function parseformula(formula::String)
    modformula = replacechar(formula) :: String

    #Check if formula match of type AB(CD)3
    molecularunits = match(r"\(([^\(\)]+)\)\s*([\.\d]*)",modformula)
    if molecularunits ≠ nothing
        modformula = rewriteformula(modformula)
    end
    return getrepresentation(modformula)
end # function parseformula

parseformula(formula::Symbol) = parseformula(String(formula))
    
