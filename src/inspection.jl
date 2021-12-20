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

# TODO
