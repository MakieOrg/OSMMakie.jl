##########################################################################################
# Node inspection on mouse hover
##########################################################################################

function Makie.show_data(inspector::DataInspector,
    plot::GraphPlot{<:Tuple{<:AbstractGraph}}, idx, ::Scatter)
    a = inspector.plot.attributes
    scene = Makie.parent_scene(plot)

    proj_pos = Makie.shift_project(scene, plot, to_ndim(Point3f0, plot[1][][idx], 0))
    Makie.update_tooltip_alignment!(inspector, proj_pos)
    ms = plot.markersize[]

    cursor_pos = collect(plot[1][][idx].data[1], plot[1][][idx].data[2])
    a._display_text[] = node2string(plot.parent.osm[], Float64.(cursor_pos))
    a._bbox2D[] = Rect2f(proj_pos .- 0.5 .* ms .- Vec2f(5), Vec2f(ms) .+ Vec2f(10))
    a._px_bbox_visible[] = true
    a._bbox_visible[] = false
    a._visible[] = true

    return true
end

function node2string(osm::LightOSM.OSMGraph, cursor_pos::Vector{Float64})
    nn = nearest_node(osm, cursor_pos)[1][1][1]
    return node2string(osm.nodes[nn])
end

function node2string(node::N) where {N<:LightOSM.Node}
    nodestring = "▶ $(nameof(N))\n"

    nodestring *= "id: $(node.id)\n"

    nodestring *= "GeoLocation: $(node.nodes)\n"

    for (key, val) in Pairs(node.tags)
        nodestring *= "$(key): $(val)\n"
    end

    return nodestring
end

##########################################################################################
# Edge inspection on mouse hover
##########################################################################################

# TODO
