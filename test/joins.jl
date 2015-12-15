using FactCheck, GeoJSON, Turf, Compat

# small tests
polygon = Vector[Vector{Float64}[[-1.,-1.],[1.,-1.],[1.,1.],[-1.,1.]]]
point = [0.9,0.9]
@fact inside(Point(point), Polygon(polygon)) --> true
point = [1.0,1.1]
@fact inside(Point(point), Polygon(polygon)) --> false

polygon = Vector[Vector{Float64}[[-1.,-1.],[1.,-1.],[1.,1.],[-1.,1.]],
                 Vector{Float64}[[-0.5,-0.5],[0.5,-0.5],[0.5,0.5],[-0.5,0.5]]]

point = [-0.9,-0.9]
@fact inside(Point(point), Polygon(polygon)) --> true
point = [-1.0,-1.1]
@fact inside(Point(point), Polygon(polygon)) --> false
point = [0.0,0.1]
@fact inside(Point(point), Polygon(polygon)) --> false

# test simple polygon
polygon = GeoJSON.Polygon(Vector{Vector{Float64}}[Vector{Float64}[[0,0],[0,100],[100,0],[0,0]]])
point_in = GeoJSON.Point(Float64[50, 50])
point_out = GeoJSON.Point(Float64[140, 150])
@fact Turf.inside(point_in, polygon) --> true
@fact Turf.inside(point_out, polygon) --> false

# test concave polygon
polygon = GeoJSON.Polygon(Vector{Vector{Float64}}[Vector{Float64}[[0,0],[50,50],[0,100],[100,100],[100,0],[0,0]]])
point_in = GeoJSON.Point(Float64[75, 75])
point_out = GeoJSON.Point(Float64[25, 50])
@fact Turf.inside(point_in, polygon) --> true
@fact Turf.inside(point_out, polygon) --> false

# test polygon with hole
feature = GeoJSON.parsefile(joinpath(dirname(@__FILE__),"geojson/poly-with-hole.geojson"))
polygon = feature.geometry
in_hole = GeoJSON.Point(Float64[-86.69208526611328, 36.20373274711739])
point_in = GeoJSON.Point(Float64[-86.72229766845702, 36.20258997094334])
point_out = GeoJSON.Point(Float64[-86.75079345703125, 36.18527313913089])
@fact Turf.inside(in_hole, polygon) --> false
@fact Turf.inside(point_in, polygon) --> true
@fact Turf.inside(point_out, polygon) --> false

# test multipolygon with hole
feature = GeoJSON.parsefile(joinpath(dirname(@__FILE__),"geojson/multipoly-with-hole.geojson"))
polygon = feature.geometry
in_hole = GeoJSON.Point(Float64[-86.69208526611328, 36.20373274711739])
point_in1 = GeoJSON.Point(Float64[-86.72229766845702, 36.20258997094334])
point_in2 = GeoJSON.Point(Float64[-86.75079345703125, 36.18527313913089])
point_out = GeoJSON.Point(Float64[-86.75302505493164, 36.23015046460186])
@fact Turf.inside(in_hole, polygon) --> false
@fact Turf.inside(point_in1, polygon) --> true
@fact Turf.inside(point_in2, polygon) --> true
@fact Turf.inside(point_out, polygon) --> false

# test with a single point
polygon = GeoJSON.Polygon(Vector{Vector{Float64}}[Vector{Float64}[[0,0],[0,100],[100,0],[0,0]]])
point_in = GeoJSON.Point(Float64[50, 50])
polygonFC = GeoJSON.FeatureCollection(GeoJSON.Feature[GeoJSON.Feature(polygon)])
pointFC = GeoJSON.FeatureCollection(GeoJSON.Feature[GeoJSON.Feature(point_in)])
counted = Turf.within(pointFC, polygonFC)
@fact typeof(counted) --> GeoJSON.FeatureCollection
@fact length(counted.features) --> 1

# test with multiple points and multiple polygons
polygon1 = GeoJSON.Polygon(Vector{Vector{Float64}}[Vector{Float64}[[0,0],[10,0],[10,10],[0,10]]])
polygon2 = GeoJSON.Polygon(Vector{Vector{Float64}}[Vector{Float64}[[10,0],[20,10],[20,20],[20,0]]])
polygonFC = GeoJSON.FeatureCollection(GeoJSON.Feature[GeoJSON.Feature(polygon1),GeoJSON.Feature(polygon2)])
point1 = GeoJSON.Feature(GeoJSON.Point(Float64[1, 1]), @compat Dict{AbstractString,Any}("population" => 500))
point2 = GeoJSON.Feature(GeoJSON.Point(Float64[1, 3]), @compat Dict{AbstractString,Any}("population" => 400))
point3 = GeoJSON.Feature(GeoJSON.Point(Float64[14, 2]), @compat Dict{AbstractString,Any}("population" => 600))
point4 = GeoJSON.Feature(GeoJSON.Point(Float64[13, 1]), @compat Dict{AbstractString,Any}("population" => 500))
point5 = GeoJSON.Feature(GeoJSON.Point(Float64[19, 7]), @compat Dict{AbstractString,Any}("population" => 200))
point6 = GeoJSON.Feature(GeoJSON.Point(Float64[100, 7]), @compat Dict{AbstractString,Any}("population" => 200))
pointFC = GeoJSON.FeatureCollection(GeoJSON.Feature[point1, point2, point3, point4, point5, point6])
counted = Turf.within(pointFC, polygonFC)
@fact typeof(counted) --> GeoJSON.FeatureCollection
@fact length(counted.features) --> 5

# test tag (which is dependent on filter)
pointFC = GeoJSON.parsefile(joinpath(dirname(@__FILE__),"geojson/tagPoints.geojson"))
polygonFC = GeoJSON.parsefile(joinpath(dirname(@__FILE__),"geojson/tagPolygons.geojson"))
taggedFC = Turf.tag(pointFC, polygonFC, "polyID", "containingPolyID")
@fact length(taggedFC.features) --> length(pointFC.features)
countFC = Turf.filter(taggedFC, "containingPolyID", 4)
@fact length(countFC.features) --> 6
