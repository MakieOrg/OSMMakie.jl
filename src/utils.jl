export map_aspect

##########################################################################################
# Map projection
##########################################################################################

"Approximate the map aspect ratio via minimum and maximum latitude of the projected area."
function map_aspect(minlat, maxlat)
    mean_lat = (minlat + maxlat) / 2
    aspect = 1 / cosd(mean_lat)
    return aspect
end