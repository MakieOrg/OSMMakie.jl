##########################################################################################
# Node defaults
##########################################################################################

function set_node_defaults(osmplot, edge_width)
    osmplot.osm_nlabels[] = get(osmplot.graphplotkwargs, :nlabels,
        repr.(keys(osmplot.osm[].nodes))) # save labels to enable hide_nlabels functionality
    node_color = :black
    node_size = edge_width
    nlabels = osmplot.hide_nlabels[] ? nothing : osm_nlabels
    nlabels_textsize = 9

    return (; node_color, node_size, nlabels, nlabels_textsize)
end

##########################################################################################
# Edge defaults
##########################################################################################

function set_edge_defaults(osmplot)
    # some handy aliases
    i2n = osmplot.osm[].index_to_node
    n2i = osmplot.osm[].node_to_index
    e2h = osmplot.osm[].edge_to_highway
    ways = osmplot.osm[].highways

    # sorted list of edges with node indices as identifier
    # need to use edges(::AbstractGraph) to preserve edge order
    sorted_edges = collect([e.src, e.dst] for e in edges(osmplot.osm[].graph))

    osmplot.osm_elabels[] = get(osmplot.graphplotkwargs, :elabels,
        label_streets(sorted_edges, n2i, ways)) # save labels to enable hide_elabels functionality
    edge_color = color_streets(sorted_edges, i2n, e2h, ways)
    edge_width = width_streets(sorted_edges, i2n, e2h, ways)
    elabels = osmplot.hide_elabels[] ? nothing : osmplot.osm_elabels[]
    elabels_textsize = 11
    arrow_size = arrows_streets(sorted_edges, i2n, e2h, ways)

    return (; edge_color, edge_width, elabels, elabels_textsize, arrow_size)
end

function color_streets(sorted_edges, i2n, e2h, ways)
    # preallocate list with length = edges
    color_list = fill(:black, length(sorted_edges))

    for i in eachindex(sorted_edges)
        edge_nodes = [i2n[sorted_edges[i][1]], i2n[sorted_edges[i][2]]]
        way = e2h[edge_nodes]
        if ways[way].tags["maxspeed"] <= 30
            color_list[i] = :grey
        end
    end

    return color_list
end

function width_streets(sorted_edges, i2n, e2h, ways)
    widths = fill(0, length(sorted_edges))

    for i in eachindex(sorted_edges)
        edge_nodes = [i2n[sorted_edges[i][1]], i2n[sorted_edges[i][2]]]
        way = e2h[edge_nodes]
        widths[i] = ways[way].tags["lanes"]
    end

    return widths
end

function label_streets(sorted_edges, n2i, ways)
    # preallocate list of empty strings with length = edges
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
            i = indexin([node_indices], sorted_edges)[1]
            labels[i] = way.tags["name"]
        end
    end

    return labels
end

function arrows_streets(sorted_edges, i2n, e2h, ways)
    markersizes = fill(0, length(sorted_edges))

    for i in eachindex(sorted_edges)
        edge_nodes = [i2n[sorted_edges[i][1]], i2n[sorted_edges[i][2]]]
        way = e2h[edge_nodes]
        if ways[way].tags["oneway"]
            markersizes[i] = floor(Int, (ways[way].tags["lanes"] + 3) * 1.3)
        end
    end

    return markersizes
end
