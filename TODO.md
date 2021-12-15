# TODO

## basics

- [x] isolate in `OSMMakie` module
- [x] add package info to [Project.toml](Project.toml)
- [x] init git
- [x] wrap into makie recipe
- [x] add LICENSE
- [ ] initial commit + tag for v0.0.1
- [ ] publish on github
- [ ] finish README
    - add screenshot for London example
- [ ] add automated docs
- [ ] add automated releases

## edges

- [x] switch `edge_width` to represent number of lanes
- [x] generally hide arrows but show them for oneways
- [ ] color edges according to way type

## labels

- [ ] scale `elabels_textsize` according to zoom level and/or edge length
- [ ] observe state of `hide_elabels` and `hide_nlabels` and dynamically change plot
- [ ] fix `elabels` for duplicate ways (i.e. reduce label overlap)
- [ ] look into further performance improvements when there are a lot of `elabels`

## extensions

- [ ] add buildings layer via `Makie.poly`
- [ ] add railways layer via `Makie.linesegments`
- [ ] add cycling lanes layer via `Makie.linesegments`
- [ ] add proper test suite