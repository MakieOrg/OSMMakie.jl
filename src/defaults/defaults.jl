include("default_consts.jl")

##########################################################################################
# Node defaults
##########################################################################################

function set_node_defaults(osmplot)
    osm = osmplot.osm[]

    osmplot.osm_nlabels[] = get(osmplot.graphplotkwargs, :nlabels,
        repr.(keys(osm.nodes))) # save labels to enable hide_nlabels functionality
    node_color = :black
    node_size = 0
    nlabels = show_nlabels(osmplot.hide_nlabels[], osmplot.osm_nlabels[])
    nlabels_textsize = 9

    return (; node_color, node_size, nlabels, nlabels_textsize)
end

function node_sizes(osm) # currently unused but good for testing purposes
    gv = vertices(osm.graph)
    sizes = fill(1, length(gv))

    for i in gv
        n = osm.index_to_node[i]
        w = osm.node_to_highway[n]
        sizes[i] = length(w)
    end

    return sizes
end

function show_nlabels(hide_nlabels, osm_nlabels)
    return hide_nlabels ? nothing : osm_nlabels
end

##########################################################################################
# Edge defaults
##########################################################################################

function set_edge_defaults(osmplot)
    osm = osmplot.osm[]

    osmplot.osm_elabels[] = get(osmplot.graphplotkwargs, :elabels,
        label_streets(osmplot.sorted_edges[], osm.node_to_index,
            osm.highways)) # save labels to enable hide_elabels functionality
    edge_color = color_streets(osmplot.index_to_way[])
    edge_width = width_streets(osmplot.index_to_way[])
    elabels = show_elabels(osmplot.hide_elabels[], osmplot.osm_elabels[])
    elabels_textsize = 11
    arrow_size = arrows_streets(osmplot.index_to_way[])
    arrow_attr=(; color = colorant"#fff")

    return (; edge_color, edge_width, elabels, elabels_textsize, arrow_size, arrow_attr)
end

function color_streets(i2w)
    colors = fill(colorant"#444", length(i2w))

    for (index, way) in pairs(i2w)
        waytype = get(way.tags, "highway", nothing)
        if waytype !== nothing && haskey(WAYTYPECOLORS, waytype)
            colors[index] = WAYTYPECOLORS[waytype]
        end
    end

    return colors
end

function width_streets(i2w)
    widths = fill(BASEWIDTH, length(i2w))

    for (index, way) in pairs(i2w)
        waytype = get(way.tags, "highway", nothing)
        if waytype !== nothing && haskey(WAYTYPEWIDTHS, waytype)
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

function show_elabels(hide_elabels, osm_elabels)
    return hide_elabels ? nothing : osm_elabels
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
