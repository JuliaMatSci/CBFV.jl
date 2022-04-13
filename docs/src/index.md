# CBFV.jl : A simple composition-based feature vectorization utility in Julia
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliamatsci.github.io/CBFV.jl/stable) [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliamatsci.github.io/CBFV.jl/dev) [![Build Status](https://github.com/juliamatsci/CBFV.jl/workflows/CI/badge.svg)](https://github.com/JuliaMatSci/CBFV.jl/actions) [![Build Status](https://travis-ci.com/JuliaMatSci/CBFV.jl.svg?branch=master)](https://travis-ci.com/JuliaMatSci/CBFV.jl) [![Coverage](https://codecov.io/gh/JuliaMatSci/CBFV.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaMatSci/CBFV.jl)

This is a Julia rewrite of the [python tool](https://github.com/kaaiian/CBFV) to create a composition-based feature vector representation for machine learning with materials science data. The ideas and methodology are discussed in the recent article:


>Wang, Anthony Yu-Tung; Murdock, Ryan J.; Kauwe, Steven K.; Oliynyk, Anton O.; Gurlo, Aleksander; Brgoch, Jakoah; Persson, Kristin A.; Sparks, Taylor D., [Machine Learning for Materials Scientists: An Introductory Guide toward Best Practices](https://doi.org/10.1021/acs.chemmater.0c01907), *Chemistry of Materials* **2020**, *32 (12)*: 4954–4965. DOI: [10.1021/acs.chemmater.0c01907](https://doi.org/10.1021/acs.chemmater.0c01907).

and the original python source code(s) can be found here:

- [https://github.com/anthony-wang/BestPractices/tree/master/notebooks/CBFV](https://github.com/anthony-wang/BestPractices/tree/master/notebooks/CBFV)
- [https://github.com/kaaiian/CBFV](https://github.com/kaaiian/CBFV)

## Example Use

The input data set should have a least two columns with the header/names `formula` and `target`.

```@example
using DataFrames
using CBFV
data = DataFrame("name"=>["Rb2Te","CdCl2","LaN"],"bandgap_eV"=>[1.88,3.51,1.12])
rename!(data,Dict("name"=>"formula","bandgap_eV"=>"target"))
features = generatefeatures(data)
```

The thing to note is you most likely will still want to post-process the generated feature data using some transformation to scale the data. The [StatsBase.jl](https://juliastats.org/StatsBase.jl/stable/transformations/) package provides some basic fetures for this, although the input needs to be `AbstractMatrix{<:Real}` rather than a `DataFrame`. This can be achieved using `generatefeatures(data,returndataframe=false)`

## Supported Featurization Schemes

As with the orignal CBFV python package the following element databases are available:

- `oliynyk` (default): Database from A. Oliynyk.
- `magpie`: [Materials Agnostic Platform for Informatics and Exploration](https://bitbucket.org/wolverton/magpie/src/master/)
- `mat2vec`:  [Word embeddings capture latent knowledge from materials science](https://github.com/materialsintelligence/mat2vec)
- `jarvis`: [Joint Automated Repository for Various Integrated Simulations provided by U.S. National Institutes of Standards and Technologies.](https://jarvis.nist.gov/)
- `onehot`: Simple one hot encoding scheme, i.e., diagonal elemental matrix.
- `random_200`: 200 random elemental properties (I'm assuming).

However, `CBFV.jl` will allow you to provide your own element database to featurize with. Also, the current implementation reads the saved `.csv` file in [`databases`](@ref), however, this is prone to potential issues (ex. out of date files). To alleviate this I will change the implementation to utilize `Pkg.Artificats` with a `Artificats.toml` file that enables grabbing the datafiles needed from a server if they don't exist locally already.

### Julia Dependencies
This is a relatively small package so there aren't a lot of dependencies. The required packages are:

- CSV
- DataFrames
- ProgressBars

## Citations
Pleae cite the following when and if you use this package in your work:

```bibtex
@misc{CBFV.jl,
    author = {Bringuier, Stefan},
    year = {2021},
    title = {CBFV.jl - A simple composition based feature vectorization Julia utility},
    url = {https://github.com/JuliaMatSci/CBFV.jl},
}
```
In addition, please also consider citing the original python implementation and tutorial paper.

```bibtex
@misc{CBFV,
    author = {Kauwe, Steven and Wang, Anthony Yu-Tung and Falkowski, Andrew},
    title = {CBFV: Composition-based feature vectors},
    url = {https://github.com/kaaiian/CBFV}
}
```

```bibtex
@article{Wang2020bestpractices,
    author = {Wang, Anthony Yu-Tung and Murdock, Ryan J. and Kauwe, Steven K. and Oliynyk, Anton O. and Gurlo, Aleksander and Brgoch, Jakoah and Persson, Kristin A. and Sparks, Taylor D.},
    year = {2020},
    title = {Machine Learning for Materials Scientists: An Introductory Guide toward Best Practices},
    url = {https://doi.org/10.1021/acs.chemmater.0c01907},
    pages = {4954--4965},
    volume = {32},
    number = {12},
    issn = {0897-4756},
    journal = {Chemistry of Materials},
    doi = {10.1021/acs.chemmater.0c01907}
}
```