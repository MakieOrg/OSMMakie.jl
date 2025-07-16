export OSMPlot, osmplot, osmplot!

##########################################################################################
# OSMPlot recipe
##########################################################################################

"""
Define OSMPlot plotting function with some attribute defaults.

## Arguments

`osm::LightOSM.OSMGraph`

## Keyword arguments

`graphplotkwargs::NamedTuple = (; )` : All kwargs are passed on to `GraphMakie.graphplot!`. 
    All kwargs that work with graphplot will also work here (see [GraphMakie docs](https://juliaplots.org/GraphMakie.jl/stable/#The-graphplot-Recipe) for reference).
    Extending the defaults can be done by providing `graphplotkwargs = (; kwargs...)`.
`hide_elabels::Bool = false` : Show or hide edge labels.
`hide_nlabels::Bool = true` : Show or hide node labels.
`buildings::Union{Dict{Integer, LightOSM.Building}, Nothing} = nothing` : Buildings polygons
    are plotted if this is not nothing.
`buildingskwargs::NamedTuple = (; )` : All kwargs are passed on to `Makie.poly` and will
    overwrite the default plotting behaviour
`inspect_nodes::Bool = false` : Enables/disables inspection of OpenStreetMap nodes.
`inspect_edges::Bool = true` : Enables/disables inspection of OpenStreetMap ways.
"""
@recipe(OSMPlot, osm) do scene
    Attributes(
        # general    
        graphplotkwargs = NamedTuple(),
        hide_elabels = true,
        hide_nlabels = true,
        buildings = nothing,
        buildingskwargs = NamedTuple(),
        
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
            (osm.ways[way] for way in
             (osm.edge_to_way[edge] for edge in
              ([osm.index_to_node[s], osm.index_to_node[d]] for (s, d) in osmplot.sorted_edges[])))
        )
    )

    # Node positions
    # OSMGraph.node_coordinates is in lat/lon format. Reversing it provides lon/lat 
    # which then creates standard north-oriented maps.
    node_pos = Point2.(reverse.(osm.node_coordinates))

    # OSMMakie defaults (see defaults.jl for details)
    edge_defaults = set_edge_defaults(osmplot)
    node_defaults = set_node_defaults(osmplot, edge_defaults.edge_width, edge_defaults.edge_color)

    # If user provided buildings, plot them as polys below ways layer
    if !isnothing(osmplot.buildings[])
        building_polys = @lift(get_building_polys($(osmplot.buildings)))
        bp = poly!(osmplot, building_polys; 
            color = BUILDINGSCOLORS,
            strokecolor = colorant"#444", strokewidth = 0.5,
            osmplot.buildingskwargs...)
        bp.inspectable[] = false # Disable building inspection for now
    end

    # Create the ways layer as a graphplot
    # User-provided graphplotkwargs will overwrite defaults
    waypoints = get_waypoints(osm)
    gp = graphplot!(osmplot, osm.graph;
        layout = _ -> node_pos,
        waypoints,
        osmplot.graphplotkwargs...,
        node_defaults...,
        edge_defaults...
    )
    
    # Setup inspection on mouse hover
    # Tracks inspect_edges for ways
    gp.plots[1].plots[1].inspectable = lift(identity, osmplot.inspect_edges)
    # Always disabled for one-way arrows
    gp.plots[2].inspectable[] = false
    # Tracks inspect_nodes for nodes
    gp.plots[3].inspectable = lift(identity, osmplot.inspect_nodes)

    return osmplot
end
