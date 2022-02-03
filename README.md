# OSMMakie

A [Makie](https://github.com/JuliaPlots/Makie.jl) recipe for plotting [OpenStreetMap](https://www.openstreetmap.org/) data.
It makes heavy use of the [GraphMakie](https://github.com/JuliaPlots/GraphMakie.jl) package and extends it to work with the specific features of an `OSMGraph`.

Please note that this recipe provides some opinionated (but hopefully sane) defaults for how the OpenStreetMap data should be plotted.
However, users have full control over every aspect of the plot and can style them to their likings.

## Usage example

```julia
using LightOSM
using OSMMakie
using GLMakie

# download OpenStreetMap data
download_osm_network(:bbox; # rectangular area
    minlat = 51.5015, # bottom left corner
    minlon = -0.0921,
    maxlat = 51.5154, # top right corner
    maxlon = -0.0662,
    network_type = :drive, # download motorways
    save_to_file_location = "london_drive.json"
);

# load as OSMGraph
osm = graph_from_file("london_drive.json";
    graph_type = :light, # SimpleDiGraph
    weight_type = :distance
)

# plot it
fig, ax, plot = osmplot(osm)
ax.aspect = DataAspect()
display(fig)
```

Output:

![London map](https://github.com/fbanning/OSMMakie-assets/blob/master/London.png)

To enable edge inspection:

```julia
DataInspector(fig)
```

Output:

![London map with inspection enabled](https://github.com/fbanning/OSMMakie-assets/blob/master/London_inspection.png)

Markersize of nodes is set to zero by default, preventing inspection.
A `node_size` has to be provided to enable node inspection.

```julia
fig, ax, plot = osmplot(osm; graphplotkwargs=(; node_size = 1))
ax.aspect = DataAspect()
DataInspector(fig)
```

## Contributions

All contributions are welcome!
- If you need some inspiration what to work on, have a look at the [TODO lists](https://github.com/fbanning/OSMMakie.jl/projects).
- If you have a vague idea about a feature and it's not already on the list, get in touch via the discussion section.
- If you already know what you want to add/fix, please feel free to open a new issue.

This recipe is currently written for use with [LightOSM](https://github.com/DeloitteDigitalAPAC/LightOSM.jl) `OSMGraph`s but can be extended to work with other OSM backends as well.
PRs regarding this are also very much encouraged!

## License

Please refer to the [LICENSE](LICENSE) file included in this repository.
