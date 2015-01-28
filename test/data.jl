using GeoJSON, Turf, FactCheck

point1 = GeoJSON.Feature(GeoJSON.Point(Float64[1, 2]), @compat Dict{String,Any}("team" => "Red Sox"))
point2 = GeoJSON.Feature(GeoJSON.Point(Float64[2, 1]), @compat Dict{String,Any}("team" => "Yankees"))
point3 = GeoJSON.Feature(GeoJSON.Point(Float64[3, 1]), @compat Dict{String,Any}("team" => "Nationals"))
point4 = GeoJSON.Feature(GeoJSON.Point(Float64[2, 2]), @compat Dict{String,Any}("team" => "Yankees"))
point5 = GeoJSON.Feature(GeoJSON.Point(Float64[2, 3]), @compat Dict{String,Any}("team" => "Red Sox"))
point6 = GeoJSON.Feature(GeoJSON.Point(Float64[4, 2]), @compat Dict{String,Any}("team" => "Yankees"))
pointFC = GeoJSON.FeatureCollection(GeoJSON.Feature[point1, point2, point3, point4, point5, point6])

# test "remove"
newFC = Turf.remove(pointFC, "team", "Yankees")
@fact length(newFC.features) => 3
for feature in newFC.features
    @fact (feature.properties["team"] == "Yankees") => false
end

# test `filter`
newFC = Turf.remove(pointFC, "team", "Nationals")
@fact length(newFC.features) => 1
@fact newFC.features[1].properties["team"] => "Nationals"

