export OSMPlot, osmplot, osmplot!

##########################################################################################
# OSMPlot recipe
##########################################################################################

"""
Define OSMPlot plotting function with some attribute defaults.

*arguments*

osm::OSMGraph # OSMGraph object from LightOSM package

*keyword arguments*

graphplotkwargs = NamedTuple # kwargs to be passed on to graphplot recipe
hide_elabels = false # show edge labels
hide_nlabels = true # hide node labels
osm_elabels = nothing # used internally for hide_elabels
osm_nlabels = nothing # used internally for hide_nlabels
"""
@recipe(OSMPlot, osm) do scene
    Attributes(
        graphplotkwargs = NamedTuple(),
        hide_elabels = false,
        hide_nlabels = true,
        osm_elabels = nothing,
        osm_nlabels = nothing,
    )
end

function Makie.plot!(osmplot::OSMPlot{<:Tuple{<:OSMGraph}})
    # Node positions
    node_pos = Point2.(reverse.(osmplot.osm[].node_coordinates))

    # OSMMakie defaults
    node_defaults = set_node_defaults(osmplot)
    edge_defaults = set_edge_defaults(osmplot)

    # Create the graphplot
    graphplot!(osmplot, osmplot.osm[].graph;
        layout = _ -> node_pos,
        node_defaults...,
        edge_defaults...,
        osmplot.graphplotkwargs...
    )

    return osmplot
end
