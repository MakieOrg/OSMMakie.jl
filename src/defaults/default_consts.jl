##########################################################################################
# Consts for edge defaults
##########################################################################################

BASEWIDTH = 1

# Currently the colours are a mix of the OSM standard style and the German OSM style.
# They are modified to work with a white background because we don't have any buildings and
# areas on the map. This specifically affects all roads which are white or light grey in 
# OSM standard style, e.g. "residential" and "tertiary". #444 was chosen in these cases.
WAYTYPECOLORS = Dict{String, Colorant}(
    # roads
    # TODO: roads should have thin outlines in darker colour
    #       currently impossible with linesegments, Makie feature request is open
    "motorway" => colorant"#EB7D54",
    "trunk" => colorant"#E27272",
    "primary" => colorant"#E892A2",
    "secondary" => colorant"#FCD6A4",
    "tertiary" => colorant"#F7FABF",
    "unclassified" => colorant"#444",
    "residential" => colorant"#444",
    # link roads
    # TODO: link roads should have thin outlines in darker colour
    #       currently impossible with linesegments, Makie feature request is open
    "motorway_link" => colorant"#EB7D54",
    "trunk_link" => colorant"#E27272",
    "primary_link" => colorant"#E892A2",
    "secondary_link" => colorant"#FCD6A4",
    "tertiary_link" => colorant"#F7FABF",
    # special road types
    "living_street" => colorant"#444",
    "service" => colorant"#444",
    "pedestrian" => colorant"#939894",
    "track" => colorant"#AC8327",
    "bus_guideway" => colorant"#6666FF",
    "escape" => colorant"#444",
    "raceway" => colorant"#FFC0CA",
    "road" => colorant"#444",
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
    "motorway" => 6.0,
    "trunk" => 6.0,
    "primary" => 6.0,
    "secondary" => 6.0,
    "tertiary" => 6.0,
    "unclassified" => 3.0,
    "residential" => 3.0,
    # link roads
    "motorway_link" => 3.0,
    "trunk_link" => 3.0,
    "primary_link" => 3.0,
    "secondary_link" => 3.0,
    "tertiary_link" => 3.0,
    # special road types
    "living_street" => 3.0,
    "service" => 3.0,
    "pedestrian" => 3.0,
    "track" => 1.0,
    "bus_guideway" => 2.0,
    "escape" => 3.0,
    "raceway" => 3.0,
    "road" => 3.0,
    "busway" => 3.0,
    # path
    "footway" => 1.0,
    "bridleway" => 1.0,
    "steps" => 2.0,
    "corridor" => 1.0,
    "path" => 1.0,
    # cycleway
    "cycleway" => 1.0,
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

BUILDINGSCOLORS = colorant"#bbb"
