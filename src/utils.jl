export map_aspect

##########################################################################################
# Waypoints
##########################################################################################

function get_waypoints(osm)
    paths = (way.nodes for (id, way) in osm.ways)
    waypoints = []
    for path in paths
        points = collect(node_coordinate(osm, node) for node in path)
        push!(waypoints, points)
    end

    return waypoints
end

##########################################################################################
# Conversions
##########################################################################################

node_coordinate(osm, node) = Point2(reverse(osm.node_coordinates[osm.node_to_index[node]]))

##########################################################################################
# Map projection
##########################################################################################

"Approximate the map aspect ratio via minimum and maximum latitude of the projected area."
function map_aspect(minlat, maxlat)
    mean_lat = (minlat + maxlat) / 2
    aspect = 1 / cosd(mean_lat)
    return aspect
end