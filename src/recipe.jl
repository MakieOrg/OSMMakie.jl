export OSMPlot, osmplot, osmplot!

##########################################################################################
# OSMPlot recipe
##########################################################################################

"""
Define OSMPlot plotting function with some attribute defaults.

*arguments*

osm::LightOSM.OSMGraph

*keyword arguments*

`graphplotkwargs::NamedTuple = (
        # node defaults
        node_color = :black,
        node_size = 0,
        nlabels = nothing,
        nlabels_textsize = 9,
        # edge defaults
        edge_color = nothing,
        edge_size = nothing,
        elabels = nothing,
        elabels_textsize = 11,
    )` : All kwargs are passed on to the graphplot recipe, therefore all kwargs that work
    with graphplot will also work here. Extending the defaults or changing single kwargs 
    can be done by merging them `graphplotkwargs = (; OSMMakie.GRAPHPLOTKWARGS..., kwargs...)`.
    An empty NamedTuple fully disables the built-in defaults.
`hide_elabels::Boolean = false` : Show or hide edge labels.
`hide_nlabels::Boolean = true` : Show or hide node labels.
`buildings::Union{Dict{Integer, LightOSM.Building}, Nothing} = nothing` : Buildings polygons
    are plotted if this is not nothing.
`inspect_nodes::Boolean = false` : Enables/disables inspection of OpenStreetMap nodes.
`inspect_edges::Boolean = true` : Enables/disables inspection of OpenStreetMap ways.
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
        osmplot.graphplotkwargs...,
        node_defaults...,
        edge_defaults...
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
