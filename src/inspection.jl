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
    a._display_text[] = node2string(node)
    ms = source.markersize[][idx]
    a._bbox2D[] = Rect2f(proj_pos .- 0.5 .* ms .- Vec2f(5), Vec2f(ms) .+ Vec2f(10))
    a._px_bbox_visible[] = true
    a._bbox_visible[] = false
    a._visible[] = true
    a.range = 1
    a.textsize = 16

    return true
end

function node2string(node::N) where {N<:LightOSM.Node}
    nodestring = """
        ▶ $(nameof(N)) $(node.id)
        Location:
            Lat: $(node.location.lat)
            Lon: $(node.location.lon)
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
    # way = osm.edge_to_highway[[n1, n2]]

    # With plot.index_to_way:
    way = plot.index_to_way[][idx÷2]

    a._display_text[] = edge2string(way)
    a._bbox2D[] = Rect2f(proj_pos .- 0.5 .* lw .- Vec2f(5), Vec2f(lw) .+ Vec2f(10))
    a._px_bbox_visible[] = true
    a._bbox_visible[] = false
    a._visible[] = true
    a.range = 1
    a.textsize = 16

    return true
end

function edge2string(edge::E) where {E<:LightOSM.Way}
    edgestring = """
        ▶ $(nameof(E)) $(edge.id)
        $(haskey(edge.tags, "name") ? "Name: $(edge.tags["name"])" : "" )
        Tags:
        """
    for (key, val) in pairs(sort(edge.tags))
        key == "name" && continue
        edgestring *= "    $(key): $(val)\n"
    end

    return edgestring
end
