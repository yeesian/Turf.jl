# Turf.jl

[![Build Status](https://travis-ci.org/yeesian/Turf.jl.svg)](https://travis-ci.org/yeesian/Turf.jl.svg)
[![Coverage Status](https://coveralls.io/repos/yeesian/Turf.jl/badge.svg)](https://coveralls.io/r/yeesian/Turf.jl)

> Turf is a modular geospatial engine written in JavaScript. It includes traditional spatial operations, helper functions for creating GeoJSON data, and data classification and statistics tools.

This library is a port of Turf.js to the Julia programming language for geospatial analysis.

## Installation

`Turf.jl` is not a listed package (yet). Heres what you're going to need to do to install it:

```julia
# You'll need GeoJSON, so install it if you haven't already
Pkg.add("GeoJSON")
# Now download Turf direct from this repository
Pkg.clone("https://github.com/yeesian/Turf.jl.git")
# This will install it to your Julia package directory.
# Running Pkg.update() will always give you the freshest version of Turf
Pkg.test("Turf")
# Doublecheck that it works
```

##Data in Turf

Turf uses [GeoJSON](http://geojson.org/) for all geographic data, and expects the data to be standard [WGS84](http://en.wikipedia.org/wiki/World_Geodetic_System) longitude, latitude coordinates. Check out [geojson.io](http://geojson.io/#id=gist:anonymous/844f013aae8354eb889c&map=12/38.8955/-77.0135) for a tool to easily create this data.

## Basic Usage
Most Turf functions work with GeoJSON features, provided by the [GeoJSON.jl](https://github.com/JuliaGeo/GeoJSON.jl) package. These are are pieces of data that represent a collection of properties (ie: population, elevation, zipcode, etc.) along with a geometry.

We provide a few examples of its usage below: