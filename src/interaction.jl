export enable_osm_interactions!, disable_osm_interactions!

# reworked to find nested GraphPlot
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

function edge_hover_action(state, idx, event, axis)
    osmplot = axis.scene.plots[2]
    gp = osmplot.plots[1] # alias subplots

    old_width = gp.edge_width[][idx]
    gp.edge_width[][idx] = state ? old_width * 2 : old_width / 2
    gp.edge_width[] = gp.edge_width[] # trigger observable

    gp.edge_color[][idx] = state ? :red : osmplot.osm_edge_colors[][idx]
    gp.edge_color[] = gp.edge_color[] # trigger observable
end

function enable_osm_interactions!(ax)
    ehover = EdgeHoverHandler(edge_hover_action)
    register_interaction!(ax, :ehover, ehover)
end

function disable_osm_interactions!(ax)
    deregister_interaction!(ax, :ehover)
end

# TODO copy current edge ID on click
