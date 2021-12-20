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

    nn = nearest_node(osm, collect(pos))[1][1][1]
    a._display_text[] = node2string(osm.nodes[nn])
    ms = source.markersize[][osm.node_to_index[nn]]
    a._bbox2D[] = Rect2f(proj_pos .- 0.5 .* ms .- Vec2f(5), Vec2f(ms) .+ Vec2f(10))
    a._px_bbox_visible[] = true
    a._bbox_visible[] = false
    a._visible[] = true

    return true
end

function node2string(node::N) where {N<:LightOSM.Node}
    nodestring = "▶ $(nameof(N)) $(node.id)\n"

    nodestring *= "$(node.location)"

    for (key, val) in pairs(node.tags)
        nodestring *= "$(key): $(val)\n"
    end

    return nodestring
end

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

    # TODO nearest_node may pick wrong nodes because it takes the two nearest to cursor pos
    # -> should somehow directly search for edge which goes through cursor pos
    nn = nearest_node(osm, collect(pos), 2)[1][1]
    way = osm.edge_to_highway[nn]
    a._display_text[] = edge2string(osm.highways[way])
    a._bbox2D[] = Rect2f(proj_pos .- 0.5 .* lw .- Vec2f(5), Vec2f(lw) .+ Vec2f(10))
    a._px_bbox_visible[] = true
    a._bbox_visible[] = false
    a._visible[] = true

    return true
end

function edge2string(edge::E) where {E<:LightOSM.Way}
    edgestring = "▶ $(nameof(E)) $(edge.id)\n"

    edgestring *= "$(edge.nodes)\n"

    for (key, val) in pairs(edge.tags)
        edgestring *= "$(key): $(val)\n"
    end

    return edgestring
end
