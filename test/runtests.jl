using Test
using OSMMakie
using OSMMakie.LightOSM
using CairoMakie
using StatsBase
using Downloads

## Get data

# download OpenStreetMap data and load as OSMGraph
london_drive = download("https://raw.githubusercontent.com/fbanning/OSMMakie-assets/master/london_drive.json", "./london_drive.json")
osm = graph_from_file(london_drive;
    graph_type = :light, # SimpleDiGraph
    weight_type = :distance
)

# download OpenStreetMap buildings and load as buildings dict
london_buildings = download("https://raw.githubusercontent.com/fbanning/OSMMakie-assets/master/london_buildings.osm", "./london_buildings.osm")
buildings = buildings_from_file(london_buildings);

## Tests

@testset "Basic" begin
    @test begin # OSMPlot recipe
        osmplot(osm)
        true
    end

    @test begin # DataInspector
        fig, ax, p = osmplot(osm)
        DataInspector(fig)
        true
    end

    # wrong recipe usage, for whatever reasons this is different between CI and local
    if get(ENV, "CI", nothing) == "true"
        @test_throws ArgumentError osmplot(; osm)
    else
        @test_throws MethodError osmplot(; osm)
    end

    @test begin # recipe with buildings and limits/autolimitaspect keywords
        fig = Figure()
        ax = fig[1,1] = Axis(fig; 
            limits = ((-0.0921, -0.0662), (51.5015, 51.5154)),
            autolimitaspect = 1 + abs(mean([51.5015, 51.5154])) / 90
        )
        p = osmplot!(osm; buildings)
        true
    end
end
