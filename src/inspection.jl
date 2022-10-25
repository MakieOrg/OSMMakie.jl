##########################################################################################
# Node inspection on mouse hover
##########################################################################################

function Makie.show_data(inspector::DataInspector,
    plot::OSMPlot{<:Tuple{<:OSMGraph}}, idx, source::Scatter)
    osm = plot.osm[]
    a = inspector.plot.attributes
    scene = Makie.parent_scene(plot)

    pos = source[1][][idx]
    proj_pos = Makie.shift_project(scene, plot, to_ndim(Point3f, pos, 0))
    Makie.update_tooltip_alignment!(inspector, proj_pos)

    node = osm.nodes[osm.index_to_node[idx]]
    a.text[] = node2string(node)
    ms = source.markersize[][idx]
    a.visible[] = true
    a.range = 1
    a.textsize = 13

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

function Makie.show_data(inspector::DataInspector,
    plot::OSMPlot{<:Tuple{<:OSMGraph}}, idx, source::LineSegments)
    osm = plot.osm[]
    a = inspector.plot.attributes
    scene = Makie.parent_scene(plot)

    p0, p1 = source[1][][idx-1:idx]
    origin, dir = Makie.view_ray(scene)
    pos = Makie.closest_point_on_line(p0, p1, origin, dir)
    lw = source.linewidth[] isa Vector ? source.linewidth[][idx] : source.linewidth[]

    proj_pos = Makie.shift_project(scene, plot, to_ndim(Point3f, pos, 0))
    Makie.update_tooltip_alignment!(inspector, proj_pos)

    # Without plot.index_to_way:
    # i1, i2 = plot.sorted_edges[][idx÷2]
    # n1, n2 = osm.index_to_node[i1], osm.index_to_node[i2]
    # way = osm.edge_to_way[[n1, n2]]

    # With plot.index_to_way:
    way = plot.index_to_way[][idx÷2]

    a.text[] = edge2string(way)
    a.visible[] = true
    a.range = 1
    a.textsize = 13

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
