# CBFV.jl : A simple composition-based feature vectorization Julia utility
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://stefanbringuier.github.io/CBFV.jl/stable) [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://stefanbringuier.github.io/CBFV.jl/dev) [![Build Status](https://github.com/stefanbringuier/CBFV.jl/workflows/CI/badge.svg)](https://github.com/stefanbringuier/CBFV.jl/actions) [![Build Status](https://travis-ci.com/stefanbringuier/CBFV.jl.svg?branch=master)](https://travis-ci.com/stefanbringuier/CBFV.jl) [![Coverage](https://codecov.io/gh/stefanbringuier/CBFV.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/stefanbringuier/CBFV.jl)

This is just rewrite of the simple python tool to create a composition-based feature vector representation for machine learning data but as a Julia package. The ideas and methodology are discussed in the recent article:


>Wang, Anthony Yu-Tung; Murdock, Ryan J.; Kauwe, Steven K.; Oliynyk, Anton O.; Gurlo, Aleksander; Brgoch, Jakoah; Persson, Kristin A.; Sparks, Taylor D., [Machine Learning for Materials Scientists: An Introductory Guide toward Best Practices](https://doi.org/10.1021/acs.chemmater.0c01907), *Chemistry of Materials* **2020**, *32 (12)*: 4954–4965. DOI: [10.1021/acs.chemmater.0c01907](https://doi.org/10.1021/acs.chemmater.0c01907).

and the original python source code can be found here:

> (https://github.com/anthony-wang/BestPractices/tree/master/notebooks/CBFV)

## Citation
Pleae cite the following when if you use this package in your work:

```bibtex
@misc{Bringuier2021CBFV.jl,
    author = {Bringuier, Stefan},
    year = {2021},
    title = {CBFV.jl - A simple composition based feature vectorization Julia utility},
    url = {https://github.com/stefanbringuier/CBFV.jl},
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