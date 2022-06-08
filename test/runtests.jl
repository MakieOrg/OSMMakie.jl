using Test
using OSMMakie
using OSMMakie.LightOSM
using GLMakie
using StatsBase

##

@testset "Basic" begin
    # download OpenStreetMap data and load as OSMGraph
    osm = graph_from_download(:bbox; # rectangular area
        minlat = 51.5015, # bottom left corner
        minlon = -0.0921,
        maxlat = 51.5154, # top right corner
        maxlon = -0.0662,
        network_type = :drive, # download motorways
        graph_type = :light, # SimpleDiGraph
        weight_type = :distance
    )
    fig, ax, p = osmplot(osm)
    DataInspector(fig)

    # download OpenStreetMap buildings and load as buildings dict
    buildings = buildings_from_download(:bbox;
        minlat = 51.5015, # bottom left corner
        minlon = -0.0921,
        maxlat = 51.5154, # top right corner
        maxlon = -0.0662,
        metadata = true,
        download_format = :osm,
    );

    # plot London with buildings
    fig = Figure()
    ax = fig[1,1] = Axis(fig; 
        limits = ((-0.0921, -0.0662), (51.5015, 51.5154)),
        autolimitaspect = 1 + abs(mean([51.5015, 51.5154])) / 90
    )
    p = osmplot!(osm; buildings)
end
