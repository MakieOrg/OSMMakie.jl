module OSMMakie

using LightOSM
using GraphMakie
using Graphs
using Makie
using Makie.Colors
using Makie.GeometryBasics

include("recipe.jl")
include("defaults/defaults.jl")
include("inspection.jl")
include("utils.jl")

end # module
