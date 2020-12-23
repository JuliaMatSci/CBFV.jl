using CBFV
using Documenter

makedocs(;
    modules=[CBFV],
    authors="Stefan Bringuier <stefanbringuier@gmail.com> and contributors",
    repo="https://github.com/stefanbringuier/CBFV.jl/blob/{commit}{path}#L{line}",
    sitename="CBFV.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://stefanbringuier.github.io/CBFV.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/stefanbringuier/CBFV.jl",
)
