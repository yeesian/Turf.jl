using GeoJSON, FactCheck, Turf

point1 = GeoJSON.Feature(GeoJSON.Point(Float64[-75.343, 39.984]))
point2 = GeoJSON.Feature(GeoJSON.Point(Float64[-75.534, 39.123]))

@fact Turf.distance(point1, point2, :miles) --> roughly(60.37218405837491)
@fact Turf.distance(point1, point2, :kilometers) --> roughly(97.15957803131901)
@fact Turf.distance(point1, point2, :radians) --> roughly(0.015245501024842149)
@fact Turf.distance(point1, point2, :degrees) --> roughly(0.8735028650863799)
@fact Turf.distance(point1, point2) --> distance(point1, point2, :kilometers) # default

polygon = GeoJSON.Polygon(Vector{Vector{Float64}}[Vector{Float64}[[0,0],[10,0],[10,10],[0,10],[0,0]]])
@fact Turf.area(polygon) --> roughly(1232921098571.292)
point = GeoJSON.Point(Float64[0, 0])
@fact Turf.area(point) --> roughly(0)
line = GeoJSON.LineString(Vector{Float64}[[0,0],[1,2]])
@fact Turf.area(line) --> roughly(0)
polygonFC = GeoJSON.FeatureCollection(GeoJSON.Feature[GeoJSON.Feature(polygon, Dict{AbstractString,Any}())])
@fact Turf.area(polygonFC) --> roughly(1232921098571.292)
polygonFC = GeoJSON.FeatureCollection(GeoJSON.Feature[GeoJSON.Feature(polygon, Dict{AbstractString,Any}()),
                                                      GeoJSON.Feature(polygon, Dict{AbstractString,Any}())])
@fact Turf.area(polygonFC) --> roughly(1232921098571.292 * 2)
feature = GeoJSON.Feature(polygon, Dict{AbstractString,Any}())
@fact Turf.area(feature) --> roughly(1232921098571.292)

pt = GeoJSON.parsefile(joinpath(dirname(@__FILE__),"geojson/pt.geojson"))
@fact typeof(pt) --> GeoJSON.Feature
pts = GeoJSON.parsefile(joinpath(dirname(@__FILE__),"geojson/pts.geojson"))
@fact typeof(pts) --> GeoJSON.FeatureCollection
closest = Turf.nearest(pt, pts)
@fact typeof(closest) --> GeoJSON.Feature
@fact typeof(closest.geometry) --> GeoJSON.Point
@fact closest.geometry.coordinates --> roughly([-75.33, 39.44])

polygon = Turf.bboxpolygon([0.0,0.0,10.0,10.0])
@fact typeof(polygon) --> GeoJSON.Polygon
@fact length(polygon.coordinates) --> 5
@fact polygon.coordinates[1] --> roughly(polygon.coordinates[end])

fc = GeoJSON.parsefile(joinpath(dirname(@__FILE__),"geojson/fc.geojson"))
@fact typeof(fc) --> GeoJSON.FeatureCollection
bbox = Turf.envelope(fc)
@fact typeof(bbox) --> GeoJSON.Polygon

pt = GeoJSON.parsefile(joinpath(dirname(@__FILE__),"geojson/Point.geojson"))
line = GeoJSON.parsefile(joinpath(dirname(@__FILE__),"geojson/LineString.geojson"))
poly = GeoJSON.parsefile(joinpath(dirname(@__FILE__),"geojson/Polygon.geojson"))
multiline = GeoJSON.parsefile(joinpath(dirname(@__FILE__),"geojson/MultiLineString.geojson"))
multipoly = GeoJSON.parsefile(joinpath(dirname(@__FILE__),"geojson/MultiPolygon.geojson"))
@fact Turf.extent(fc) --> roughly([20, -10, 130, 4])
@fact Turf.extent(pt) --> roughly([102, 0.5, 102, 0.5])
@fact Turf.extent(line) --> roughly([102, -10, 130, 4])
@fact Turf.extent(poly) --> roughly([100, 0, 101, 1])
@fact Turf.extent(multiline) --> roughly([100, 0, 103, 3])
@fact Turf.extent(multipoly) --> roughly([100, 0, 103, 3])

@fact Turf.square(Float64[0,0,5,10]) --> roughly([-2.5,0,7.5,10])
@fact Turf.square(Float64[0,0,10,5]) --> roughly([0,-2.5,10,7.5])

@fact Turf.size(Float64[0,0,10,10], 2) --> roughly([-5,-5,15,15])
@fact Turf.size(Float64[0,0,4,4], 1) --> roughly([0,0,4,4])
@fact Turf.size(Float64[0,0,4,4], 2) --> roughly([-2,-2,6,6])
@fact Turf.size(Float64[0,0,4,4], 0.5) --> roughly([1,1,3,3])
@fact Turf.size(Float64[-10,-10,0,0], 2) --> roughly([-15,-15,5,5])
@fact Turf.size(Float64[0,0,10,10], 1.5) --> roughly([-2.5,-2.5,12.5,12.5])
@fact Turf.size(Float64[0,0,10,10], 0.5) --> roughly([2.5,2.5,7.5,7.5])

feature = Turf.center(fc)
@fact typeof(feature) --> GeoJSON.Feature
@fact typeof(feature.geometry) --> GeoJSON.Point
@fact feature.geometry.coordinates --> roughly([75, -3])

pt1 = GeoJSON.Point(Float64[0, 0])
pt2 = GeoJSON.Point(Float64[10, 0])
midpt = Turf.midpoint(pt1, pt2)
@fact typeof(midpt) --> GeoJSON.Point
@fact midpt.coordinates --> roughly([0, 5])
pt1 = GeoJSON.Feature(GeoJSON.Point(Float64[1, 1]))
pt2 = GeoJSON.Feature(GeoJSON.Point(Float64[11, 11]))
@fact typeof(midpt) --> GeoJSON.Feature
@fact midpt.geometry.coordinates --> roughly([6, 6])

pt1 = GeoJSON.Feature(GeoJSON.Point(Float64[-75.4, 39.4]))
pt2 = GeoJSON.Feature(GeoJSON.Point(Float64[-75.534, 39.123]))
bearing = Turf.bearing(pt1, pt2) # what's the expected value?

pt1 = GeoJSON.Feature(GeoJSON.Point(Float64[-75.0, 39.0]))
dist = 100.0
bearing = 180.0
pt2 = Turf.destination(pt1, dist, bearing) # what's the expected value?

route1 = GeoJSON.parsefile(joinpath(dirname(@__FILE__),"geojson/route1.geojson"))
route2 = GeoJSON.parsefile(joinpath(dirname(@__FILE__),"geojson/route2.geojson"))
Turf.linedistance(route1, :miles)
# t.equal(Math.round(lineDistance(route1, 'miles')), 202);
#     t.true((lineDistance(route2, 'kilometers') - 742) < 1 &&
#             (lineDistance(route2, 'kilometers') - 742) > (-1) );

line = GeoJSON.parsefile(joinpath(dirname(@__FILE__),"geojson/dc-line.geojson"))
pt1 = GeoJSON.Feature(Turf.along(line, 1, :miles))
pt2 = GeoJSON.Feature(Turf.along(line, 1.2, :miles))
pt3 = GeoJSON.Feature(Turf.along(line, 1.4, :miles))
pt4 = GeoJSON.Feature(Turf.along(line, 1.6, :miles))
pt5 = GeoJSON.Feature(Turf.along(line, 1.8, :miles))
pt6 = GeoJSON.Feature(Turf.along(line, 2, :miles))
pt7 = GeoJSON.Feature(Turf.along(line, 100, :miles))
pt8 = GeoJSON.Feature(Turf.along(line, 0, :miles))
fc = GeoJSON.FeatureCollection(GeoJSON.Feature[pt1, pt2, pt3, pt4, pt5, pt6, pt7, pt8])
for feature in fc.features
    @fact typeof(feature.geometry) --> GeoJSON.Point
end
@fact length(fc.features) --> 8
@fact fc.features[end].geometry.coordinates --> roughly(pt8.geometry.coordinates)
