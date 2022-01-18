##########################################################################################
# Consts for edge defaults
##########################################################################################

WAYTYPECOLORS = Dict{String, Colorant}(
    # roads
    # TODO: roads should have thin outlines in darker colour
    #       currently impossible with linesegments, Makie feature request is open
    "motorway" => colorant"#E892A2",
    "trunk" => colorant"#FCC0AC",
    "primary" => colorant"#FCD6A4",
    "secondary" => colorant"#F7FABF",
    "tertiary" => colorant"#444",
    "unclassified" => colorant"#444",
    "residential" => colorant"#444",
    # link roads
    # TODO: link roads should have thin outlines in darker colour
    #       currently impossible with linesegments, Makie feature request is open
    "motorway_link" => colorant"#E892A2",
    "trunk_link" => colorant"#FCC0AC",
    "primary_link" => colorant"#FCD6A4",
    "secondary_link" => colorant"#F7FABF",
    "tertiary_link" => colorant"#444",
    # special road types
    "living_street" => colorant"#EDEDED",
    "service" => colorant"#444",
    "pedestrian" => colorant"#DDDDE9",
    "track" => colorant"#AC8327",
    "bus_guideway" => colorant"#6666FF",
    "escape" => colorant"#444",
    "raceway" => colorant"#FFC0CA",
    "road" => colorant"#DDDDDD",
    "busway" => colorant"#444",
    # path
    "footway" => colorant"#F49C8B",
    "bridleway" => colorant"#008000",
    "steps" => colorant"#FC7F6F",
    "corridor" => colorant"#444",
    "path" => colorant"#F49C8B",
    # cycleway
    "cycleway" => colorant"#1619FC",
)

WAYTYPEWIDTHS = Dict{String, Float64}(
    # roads
    "motorway" => 2.0,
    "trunk" => 2.0,
    "primary" => 2.0,
    "secondary" => 2.0,
    "tertiary" => 2.0,
    "unclassified" => 1.0,
    "residential" => 1.0,
    # link roads
    "motorway_link" => 1.0,
    "trunk_link" => 1.0,
    "primary_link" => 1.0,
    "secondary_link" => 1.0,
    "tertiary_link" => 1.0,
    # special road types
    "living_street" => 1.0,
    "service" => 0.75,
    "pedestrian" => 1.0,
    "track" => 0.3,
    "bus_guideway" => 0.5,
    "escape" => 1.0,
    "raceway" => 1.0,
    "road" => 1.0,
    "busway" => 1.0,
    # path
    "footway" => 0.3,
    "bridleway" => 0.3,
    "steps" => 0.5,
    "corridor" => 0.3,
    "path" => 0.3,
    # cycleway
    "cycleway" => 0.3,
)

WAYTYPESTYLES = Dict{String, Symbol}(
    # roads
    "motorway" => :solid,
    "trunk" => :solid,
    "primary" => :solid,
    "secondary" => :solid,
    "tertiary" => :solid,
    "unclassified" => :solid,
    "residential" => :solid,
    # link roads
    "motorway_link" => :solid,
    "trunk_link" => :solid,
    "primary_link" => :solid,
    "secondary_link" => :solid,
    "tertiary_link" => :solid,
    # special road types
    "living_street" => :solid,
    "service" => :solid,
    "pedestrian" => :solid,
    "track" => :dashdot,
    "bus_guideway" => :dashed,
    "escape" => :solid,
    "raceway" => :solid,
    "road" => :solid,
    "busway" => :solid,
    # path
    "footway" => :dot,
    "bridleway" => :dash,
    "steps" => :dot,
    "corridor" => :solid,
    "path" => :dot,
    # cycleway
    "cycleway" => :dot,
)
