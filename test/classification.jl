using GeoJSON, Turf, FactCheck

points = GeoJSON.parsefile(joinpath(dirname(@__FILE__),"geojson/pts.geojson"))
quantiled = Turf.quantile(points, "elevation", [10,30,40,60,80,90,99])
@fact length(quantiled) --> 7 # what should be the expected values?

infield = "elevation"
outfield = "heightIndex"
translations = Vector[[0,20,1], [20,40,2], [40,60,3], [60,Inf,4]]
reclassed = Turf.reclass(points, infield, outfield, translations)
@fact typeof(reclassed.features[1].geometry) --> GeoJSON.Point
# what's the expected output here?
