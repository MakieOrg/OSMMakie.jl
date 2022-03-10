module OSMMakie

using LightOSM
using GraphMakie
using Graphs
using Makie
using Makie.Colors
import GeometryBasics

include("recipe.jl")
include("defaults/defaults.jl")
include("inspection.jl")

end # module
