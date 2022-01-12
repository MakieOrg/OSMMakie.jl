module OSMMakie

using LightOSM
using GraphMakie
using Graphs
using Makie
using InteractiveUtils: clipboard

include("recipe.jl")
include("defaults.jl")
include("inspection.jl")
include("interaction.jl")

end # module
