##########################################################################################
# Node inspection on mouse hover
##########################################################################################

function Makie.show_data(inspector::DataInspector, plot::OSMPlot, idx, source::Scatter)
    osm = plot.osm[]
    scene = Makie.parent_scene(plot)
    pos = source[1][][idx]
    proj_pos = Makie.shift_project(scene, plot, to_ndim(Point3f, pos, 0))
    Makie.update_tooltip_alignment!(inspector, proj_pos)
    node = osm.nodes[osm.index_to_node[idx]]
    update!(inspector.plot,
        text = node2string(node),
        visible = true,
        fontsize = 13
    )
    return true
end

function node2string(node::N) where {N<:LightOSM.Node}
    nodestring = """
        ▶ $(nameof(N)) $(node.id)
        Location:
            Lon: $(node.location.lon)
            Lat: $(node.location.lat)
            Alt: $(node.location.alt)
        Tags:
        """
    for (key, val) in pairs(node.tags)
        nodestring *= "    $(key): $(val)\n"
    end

    return nodestring
end

# TODO copy current node ID on click

##########################################################################################
# Edge inspection on mouse hover
##########################################################################################

function Makie.show_data(inspector::DataInspector, plot::OSMPlot, idx, source::Lines)
    scene = Makie.parent_scene(plot)
    pos = Makie.position_on_plot(source, idx, apply_transform = false)
    proj_pos = Makie.shift_project(scene, Makie.apply_transform_and_model(plot, pos))
    Makie.update_tooltip_alignment!(inspector, proj_pos)

    # Without plot.index_to_way:
    # i1, i2 = plot.sorted_edges[][idx÷2]
    # n1, n2 = osm.index_to_node[i1], osm.index_to_node[i2]
    # way = osm.edge_to_way[[n1, n2]]
    # With plot.index_to_way:
    index = Int64(idx÷2)
    if haskey(plot.index_to_way[], index)
        way = plot.index_to_way[][index]
        update!(
            inspector.plot; text = edge2string(way), visible=true, fontsize=13
        )
    end
    return true
end

function edge2string(edge::E) where {E<:LightOSM.Way}
    edgestring = """
        ▶ $(nameof(E)) $(edge.id)
        Name: $(get(edge.tags, "name", "unnamed"))
        Tags:
        """
    for (key, val) in pairs(sort(edge.tags))
        key == "name" && continue
        edgestring *= "    $(key): $(val)\n"
    end

    return edgestring
end
