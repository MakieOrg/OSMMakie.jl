include("default_consts.jl")

##########################################################################################
# Node defaults
##########################################################################################

function set_node_defaults(osmplot)
    gpk = osmplot.graphplotkwargs

    node_color = @lift(get($gpk, :node_color, :black))
    node_size = @lift(get($gpk, :node_size, 0))
    nlabels = @lift(show_nlabels($(osmplot.hide_nlabels), osmplot.osm, $gpk))
    nlabels_textsize = @lift(get($gpk, :nlabels_textsize, 9))

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

function show_nlabels(hide_nlabels, osm, gpk)
    if hide_nlabels[]
        nlabels = nothing
    else
        nlabels = get(gpk, :nlabels, repr.(keys(osm[].nodes)))
    end
    return nlabels
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

    edge_color = @lift(get($gpk, :edge_color, color_streets(i2w)))
    edge_width = @lift(get($gpk, :edge_width, width_streets(i2w)))
    elabels = @lift(show_elabels($(osmplot.hide_elabels), sorted_edges, n2i, ways, $gpk))
    elabels_textsize = @lift(get($gpk, :elabels_textsize, 11))
    arrow_size = arrows_streets(i2w)

    return (; edge_color, edge_width, elabels, elabels_textsize, arrow_size)
end

function color_streets(i2w)
    colors = fill(colorant"#444", length(i2w))

    for (index, way) in pairs(i2w)
        waytype = get(way.tags, "highway", nothing)
        if !isnothing(waytype) && haskey(WAYTYPECOLORS, waytype)
            colors[index] = WAYTYPECOLORS[waytype]
        end
    end

    return colors
end

function width_streets(i2w)
    widths = fill(BASEWIDTH, length(i2w))

    for (index, way) in pairs(i2w)
        waytype = get(way.tags, "highway", nothing)
        if !isnothing(waytype) && haskey(WAYTYPEWIDTHS, waytype)
            widths[index] *= WAYTYPEWIDTHS[waytype]
        end
    end

    return widths
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

function show_elabels(hide_elabels, sorted_edges, n2i, ways, gpk)
    elabels = if hide_elabels[]
        nothing
    else
        get(gpk, :elabels, label_streets(sorted_edges, n2i, ways))
    end
    return elabels
end

function arrows_streets(i2w)
    markersizes = fill(0, length(i2w))

    for (index, way) in pairs(i2w)
        if get(way.tags, "oneway", false)
            markersizes[index] = BASEWIDTH ÷ 2
        end
    end

    return markersizes
end

##########################################################################################
# Building defaults
##########################################################################################

function plot_buildings!(osmplot, buildings)
    building_polys = fill(Point2f[], length(buildings));
    
    for (i, (id, b)) in enumerate(buildings)
        for bp in b.polygons
            building_polys[i] = begin
                Point2f[(node.location.lon, node.location.lat) for node in bp.nodes]
            end
        end
    end
    
    bp = poly!(osmplot, building_polys; color = BUILDINGSCOLORS)
    
    return bp
end
