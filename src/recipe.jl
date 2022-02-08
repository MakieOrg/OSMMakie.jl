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
        # general    
        graphplotkwargs = NamedTuple(),
        hide_elabels = true,
        hide_nlabels = true,
        buildings = nothing,
        
        # inspection
        inspect_nodes = false,
        inspect_edges = true,

        # internal
        sorted_edges = [],
        index_to_way = Dict(),
        osm_elabels = nothing,
        osm_nlabels = nothing,
    )
end

function Makie.plot!(osmplot::OSMPlot{<:Tuple{<:OSMGraph}})
    osm = osmplot.osm[]

    # Need to make a PR to have an `index_to_way` dict in OSMGraph. For now we create
    # a sorted list of edges (source and destination node ids) as well as a dict that maps
    # edge index to its related way. We need to use edges(::AbstractGraph) to preserve edge order.
    osmplot.sorted_edges = collect([e.src, e.dst] for e in edges(osm.graph))
    osmplot.index_to_way = Dict(
        zip(1:Graphs.ne(osm.graph),
            (osm.highways[way] for way in
             (osm.edge_to_highway[edge] for edge in
              ([osm.index_to_node[s], osm.index_to_node[d]] for (s, d) in osmplot.sorted_edges[])))
        )
    )

    # Node positions
    # OSMGraph.node_coordinates is in lat/lon format. Reversing it provides lon/lat 
    # which then creates standard north-oriented maps.
    node_pos = Point2.(reverse.(osm.node_coordinates))

    # OSMMakie defaults (see defaults.jl for details)
    node_defaults = set_node_defaults(osmplot)
    edge_defaults = set_edge_defaults(osmplot)

    # Create the graphplot
    # User-provided graphplotkwargs will overwrite defaults
    gp = graphplot!(osmplot, osm.graph;
        layout = _ -> node_pos,
        node_defaults...,
        edge_defaults...,
        osmplot.graphplotkwargs...
    )
    
    # Setup with inspectability
    gp.plots[1].inspectable = osmplot.inspect_nodes
    gp.plots[2].inspectable[] = false # Always disable inspection for one-way arrows
    gp.plots[3].inspectable = osmplot.inspect_edges

    # If user provided buildings, plot them as polys
    if !isnothing(osmplot.buildings[])
        bp = @lift(plot_buildings!(osmplot, $(osmplot.buildings)))
    end

    return osmplot
end
