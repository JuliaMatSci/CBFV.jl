# Examples

The example below uses the default `oliynyk` feature element database:

```@example
using DataFrames
using CBFV
d = DataFrame(:formula=>["Tc1V1","Cu1Dy1","Cd3N2"],:target=>[248.539,66.8444,91.5034])
generatefeatures(d)
```

now trying with the `jarvis` database:

```@example
using DataFrames #hide
using CBFV #hide
d = DataFrame(:formula=>["Tc1V1","Cu1Dy1","Cd3N2"],:target=>[248.539,66.8444,91.5034]) #hide
generatefeatures(d,elementdata="jarvis")
```