include("default_consts.jl")

##########################################################################################
# Node defaults
##########################################################################################

#=
function set_node_defaults(osmplot)
    osm = osmplot.osm[]
    gpk = osmplot.graphplotkwargs

    node_color = @lift(get($gpk, :node_color, :default))
    node_size = @lift(get($gpk, :node_size, :default))
    nlabels = @lift(show_nlabels($gpk, $(osmplot.hide_nlabels), osm))
    nlabels_textsize = @lift(get($gpk, :nlabels_textsize, :default))

    return (; node_color, node_size, nlabels, nlabels_textsize)
end
=#

#=
It would be nicer to just use the function above but NamedTuples are automatically converted
to Attributes, which are not a subtype of AbstractObservable. Hence we cannot lift from 
them. Finding a workaround to this would allow for better reactivity of the plot attributes.
So far everything I've tried was unsuccessful. Maybe at some point I will be smarter or the 
underlying system will have changed.

Anyways, the following workaround has to suffice for now although it only results in 
static plots. The user has to recreate the plots to reflect any changes of graphplotkwargs.
=#

function set_node_defaults(osmplot)
    gpk = osmplot.graphplotkwargs

    node_color = haskey(gpk, :node_color) ? gpk.node_color : :black
    node_size = haskey(gpk, :node_size) ? gpk.node_size : 0
    nlabels = @lift(show_nlabels(gpk, $(osmplot.hide_nlabels), osmplot.osm[]))
    nlabels_textsize = haskey(gpk, :nlabels_textsize) ? gpk.nlabels_textsize : 9

    return (; node_color, node_size, nlabels, nlabels_textsize)
end

function size_nodes(osm) # currently unused but good for testing purposes
    gv = vertices(osm.graph)
    sizes = fill(1, length(gv))

    for i in gv
        n = osm.index_to_node[i]
        w = osm.node_to_highway[n]
        sizes[i] = length(w)
    end

    return sizes
end

function show_nlabels(gpk, hide_nlabels, osm)
    labels = if hide_nlabels
        nothing
    else
        haskey(gpk, :nlabels) ? gpk.nlabels : repr.(keys(osm.nodes))
    end

    return labels
end

##########################################################################################
# Edge defaults
##########################################################################################

function set_edge_defaults(osmplot)
    osm = osmplot.osm[]
    gpk = osmplot.graphplotkwargs
    i2w = osmplot.index_to_way[]
    sorted_edges = osmplot.sorted_edges[]
    n2i = osm.node_to_index
    ways = osm.highways

    edge_color = color_streets(gpk, i2w)
    edge_width = width_streets(gpk, i2w)
    elabels = @lift(show_elabels(gpk, $(osmplot.hide_elabels), sorted_edges, n2i, ways))
    elabels_textsize = haskey(gpk, :elabels_textsize) ? gpk.elabels_textsize : 11
    arrow_attr = (;
        markersize = arrows_streets(gpk, i2w, edge_width),
        color = :white
    )

    return (; edge_color, edge_width, elabels, elabels_textsize, arrow_attr)
end

function color_streets(gpk, i2w)
    if haskey(gpk, :edge_color)
        return gpk.edge_color
    else
        colors = fill(colorant"#444", length(i2w))

        for (index, way) in pairs(i2w)
            waytype = get(way.tags, "highway", nothing)
            if !isnothing(waytype) && haskey(WAYTYPECOLORS, waytype)
                colors[index] = WAYTYPECOLORS[waytype]
            end
        end

        return colors
    end
end

function width_streets(gpk, i2w)
    if haskey(gpk, :edge_width)
        return gpk.edge_width
    else
        widths = fill(BASEWIDTH, length(i2w))

        for (index, way) in pairs(i2w)
            waytype = get(way.tags, "highway", nothing)
            if !isnothing(waytype) && haskey(WAYTYPEWIDTHS, waytype)
                widths[index] *= WAYTYPEWIDTHS[waytype]
            end
        end

        return widths
    end
end

function label_streets(sorted_edges, n2i, ways)
    labels = fill("", length(sorted_edges))

    # replace edge labels but try to avoid repetitions
    for way in values(ways)
        if haskey(way.tags, "name")
            node_indices = begin
                l = length(way.nodes)
                if l == 2 # pick first two nodes of a way 
                    n1 = 1
                    n2 = 2
                elseif iseven(l) # pick middle node and the next one
                    n1 = l ÷ 2
                    n2 = n1 + 1
                else # pick the two nodes next to the middle
                    n1 = floor(Int, l / 2)
                    n2 = ceil(Int, l / 2)
                end
                [n2i[way.nodes[n1]], n2i[way.nodes[n2]]]
            end
            i = only(indexin([node_indices], sorted_edges))
            labels[i] = way.tags["name"]
        end
    end

    return labels
end

function show_elabels(gpk, hide_elabels, sorted_edges, n2i, ways)
    labels = if hide_elabels
        nothing
    else
        haskey(gpk, :elabels) ? gpk.elabels : label_streets(sorted_edges, n2i, ways)
    end
    return labels
end

function arrows_streets(gpk, i2w, edge_width)
    if haskey(gpk, :arrow_attr) && haskey(gpk, :arrow_size)
        return gpk.arrow_attr.arrow_size[]
    else
        markersizes = fill(0, length(i2w))

        for (index, way) in pairs(i2w)
            if get(way.tags, "oneway", false)
                markersizes[index] = edge_width[index]
            end
        end

        return markersizes
    end
end

##########################################################################################
# Building defaults
##########################################################################################

function get_building_polys(buildings)
    building_polys = fill(Point2f[], length(buildings));
    
    for (i, (id, b)) in enumerate(buildings)
        for bp in b.polygons
            building_polys[i] = begin
                Point2f[(node.location.lon, node.location.lat) for node in bp.nodes]
            end
        end
    end
    
    return building_polys
end
