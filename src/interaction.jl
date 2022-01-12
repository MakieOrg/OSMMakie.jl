export enable_osm_interactions!, disable_osm_interactions!

# reworked to find nested GraphPlot
# TODO: rework into a while loop to iteratively search for GraphPlot in parent
# TODO: ask on GraphMakie repo if a PR would be accepted
function GraphMakie.registration_setup!(parent, inter::GraphMakie.GraphInteraction)
    # in case of multiple graph plots in one axis this won't work
    gplots = filter(p -> p isa GraphPlot, parent.scene.plots[2].plots)
    if length(gplots) !== 1
        @warn "There are multiple GraphPlots, register interaction to first!"
    end
    gplot = gplots[1]
    GraphMakie.set_nodeplot!(inter, get_node_plot(gplot))
    GraphMakie.set_edgeplot!(inter, get_edge_plot(gplot))
end

##########################################################################################
# Enabling/Disabling interactions
##########################################################################################

function enable_osm_interactions!(ax)
    register_interaction!(ax, :nhover, NodeHoverHandler(node_hover_action))
    register_interaction!(ax, :nclick, NodeClickHandler(node_click_action))

    register_interaction!(ax, :ehover, EdgeHoverHandler(edge_hover_action))
    register_interaction!(ax, :eclick, EdgeClickHandler(edge_click_action))
end

function disable_osm_interactions!(ax)
    deregister_interaction!(ax, :nhover)
    deregister_interaction!(ax, :nclick)

    deregister_interaction!(ax, :ehover)
    deregister_interaction!(ax, :eclick)
end

##########################################################################################
# Node interactions
##########################################################################################

"Double node size on mouse hover."
function node_hover_action(state, idx, event, axis)
    osmplot = axis.scene.plots[2]
    gp = osmplot.plots[1] # alias subplots

    old_size = gp.node_size[][idx]
    gp.node_size[][idx] = state ? old_size * 2 : old_size / 2
    gp.node_size[] = gp.node_size[]
end

"Copy id of corresponding `OSMGraph.Node` into clipboard on mouse click."
function node_click_action(idx, event, axis)
    osm = axis.scene.plots[2].osm[]
    id = osm.index_to_node[idx]
    clipboard(id)
end

##########################################################################################
# Edge interactions
##########################################################################################

"Triple edge width on mouse hover."
function edge_hover_action(state, idx, event, axis)
    osmplot = axis.scene.plots[2]
    gp = osmplot.plots[1] # alias subplots

    old_width = gp.edge_width[][idx]
    gp.edge_width[][idx] = state ? old_width * 3 : old_width / 3
    gp.edge_width[] = gp.edge_width[]
end

"Copy id of corresponding `OSMGraph.Way` into clipboard on mouse click."
function edge_click_action(idx, event, axis)
    osmplot = axis.scene.plots[2]
    way = osmplot.index_to_way[][idx]
    clipboard(way.id)
end
