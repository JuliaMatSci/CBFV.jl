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

Another example:

```@example
using DataFrames
using CBFV
data = DataFrame("name"=>["Rb2Te","CdCl2","LaN"],"bandgap_eV"=>[1.88,3.51,1.12])
rename!(data,Dict("name"=>"formula","bandgap_eV"=>"target"))
features = generatefeatures(data)
```

Here is an example with an existing feature combined with the generated features:

```@example
using DataFrames
using CBFV
data = DataFrame(:formula=>["B2O3","Be1I2","Be1F3Li1"],
                 :temperature=>[1400.00,1200.0,1100.00],
                 :heat_capacity=>[89.115,134.306,192.464])
rename!(data,Dict(:heat_capacity=>:target))
features = generatefeatures(data,combine=true)
```