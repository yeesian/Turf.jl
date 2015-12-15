using GeoJSON, FactCheck, Turf

# Point
pt = GeoJSON.Point(Float64[1,0])
flipped = Turf.flip(pt)
@fact flipped.coordinates --> roughly([0,1])
@fact pt.coordinates --> roughly([1,0]) # not mutated
pt = GeoJSON.Feature(GeoJSON.Point(Float64[1,0]))
flipped = Turf.flip(pt)
@fact flipped.geometry.coordinates --> roughly([0,1])
@fact pt.geometry.coordinates --> roughly([1,0]) # not mutated
line = GeoJSON.LineString(Vector{Float64}[[1,0],[1,0]])
flipped = Turf.flip(line)
@fact flipped.coordinates[1] --> roughly([0,1])
@fact flipped.coordinates[2] --> roughly([0,1])
polygon = GeoJSON.Polygon(Vector{Vector{Float64}}[Vector{Float64}[[1,0],[1,0],[1,12]],
                                                  Vector{Float64}[[.2,.2],[.3,.3],[.1,.2]]])
flipped = Turf.flip(polygon)
@fact flipped.coordinates[1][1] --> roughly([0,1])
@fact flipped.coordinates[1][2] --> roughly([0,1])
@fact flipped.coordinates[1][3] --> roughly([2,1])
@fact flipped.coordinates[2][3] --> roughly([.2,.1])
pt1 = GeoJSON.Feature(GeoJSON.Point(Float64[1,0]))
pt2 = GeoJSON.Feature(GeoJSON.Point(Float64[1,0]))
fc = GeoJSON.FeatureCollection(GeoJSON.Feature[pt1,pt2])
flipped = Turf.flip(fc)
@fact flipped.features[1].geometry.coordinates --> roughly([0,1])
@fact flipped.features[2].geometry.coordinates --> roughly([0,1])

#explode a polygon
polygon = GeoJSON.Polygon(Vector{Vector{Float64}}[Vector{Float64}[[0,0],[10,0],[10,10],[0,10],[0,0]]])
pt1 = GeoJSON.Feature(GeoJSON.Point(Float64[0,0]))
pt2 = GeoJSON.Feature(GeoJSON.Point(Float64[0,10]))
pt3 = GeoJSON.Feature(GeoJSON.Point(Float64[10,10]))
pt4 = GeoJSON.Feature(GeoJSON.Point(Float64[10,0]))
fc = GeoJSON.FeatureCollection(GeoJSON.Feature[pt1,pt2,pt3,pt4])
exploded = Turf.explode(polygon)
@fact typeof(exploded) --> GeoJSON.FeatureCollection
for i=1:length(fc.features)
    @fact typeof(exploded.features[i].geometry) --> GeoJSON.Point
    @fact exploded.features[i].geometry.coordinates --> roughly(fc.features[i].geometry.coordinates)
end
# explode a featurecollection
polygonFC = GeoJSON.FeatureCollection(GeoJSON.Feature[GeoJSON.Feature(polygon)])
exploded = Turf.explode(polygon)
@fact typeof(exploded) --> GeoJSON.FeatureCollection
for i=1:length(fc.features)
    @fact typeof(exploded.features[i].geometry) --> GeoJSON.Point
    @fact exploded.features[i].geometry.coordinates --> roughly(fc.features[i].geometry.coordinates)
end
# explode a single point
point = GeoJSON.Point(Float64[0,0])
fc = GeoJSON.FeatureCollection(GeoJSON.Feature[GeoJSON.Feature(GeoJSON.Point(Float64[0,0]))])
exploded = Turf.explode(point)
@fact typeof(exploded) --> GeoJSON.FeatureCollection
for i=1:length(fc.features)
    @fact typeof(exploded.features[i].geometry) --> GeoJSON.Point
    @fact exploded.features[i].geometry.coordinates --> roughly(fc.features[i].geometry.coordinates)
end
# explode a linestring
line = GeoJSON.LineString(Vector{Float64}[[0,0],[1,1],[0,1],[0,0]])
pt1 = GeoJSON.Feature(GeoJSON.Point(Float64[0,0]))
pt2 = GeoJSON.Feature(GeoJSON.Point(Float64[1,1]))
pt3 = GeoJSON.Feature(GeoJSON.Point(Float64[0,1]))
pt4 = GeoJSON.Feature(GeoJSON.Point(Float64[0,0]))
fc = GeoJSON.FeatureCollection(GeoJSON.Feature[pt1,pt2,pt3,pt4])
exploded = Turf.explode(line)
@fact typeof(exploded) --> GeoJSON.FeatureCollection
for i=1:length(fc.features)
    @fact typeof(exploded.features[i].geometry) --> GeoJSON.Point
    @fact exploded.features[i].geometry.coordinates --> roughly(fc.features[i].geometry.coordinates)
end

pt1 = GeoJSON.Feature(GeoJSON.Point(Float64[50,51]))
pt2 = GeoJSON.Feature(GeoJSON.Point(Float64[100,101]))
multipoint = Turf.combine(GeoJSON.FeatureCollection(GeoJSON.Feature[pt1,pt2]))
@fact typeof(multipoint) --> GeoJSON.MultiPoint
@fact multipoint.coordinates[1] --> roughly([50,51])
@fact multipoint.coordinates[2] --> roughly([100,101])

line1 = GeoJSON.Feature(GeoJSON.LineString(Vector{Float64}[[102,-10],[130,4]]))
line2 = GeoJSON.Feature(GeoJSON.LineString(Vector{Float64}[[40,-20],[150,18]]))
multiline = Turf.combine(GeoJSON.FeatureCollection(GeoJSON.Feature[line1,line2]))
@fact typeof(multiline) --> GeoJSON.MultiLineString
@fact multipoint.coordinates[1][1] --> roughly([102,-10])
@fact multipoint.coordinates[1][2] --> roughly([130,4])
@fact multipoint.coordinates[2][1] --> roughly([40,-20])
@fact multipoint.coordinates[2][2] --> roughly([150,18])

poly1 = GeoJSON.Feature(GeoJSON.Polygon(Vector{Vector{Float64}}[Vector{Float64}[[20,0],[101,0],[101,1],[100,1],[100,0]]]))
poly2 = GeoJSON.Feature(GeoJSON.Polygon(Vector{Vector{Float64}}[Vector{Float64}[[30,0],[102,0],[103,1]]]))
multipoly = Turf.combine(GeoJSON.FeatureCollection(GeoJSON.Feature[poly1,poly2]))
@fact typeof(multipoly) --> GeoJSON.MultiPolygon
@fact multipoint.coordinates[1][1][1] --> roughly([20,0])
@fact multipoint.coordinates[1][1][2] --> roughly([101,0])
@fact multipoint.coordinates[1][1][3] --> roughly([101,1])
@fact multipoint.coordinates[1][1][4] --> roughly([100,1])
@fact multipoint.coordinates[1][1][5] --> roughly([100,0])
@fact multipoint.coordinates[2][1][1] --> roughly([30,0])
@fact multipoint.coordinates[2][1][2] --> roughly([102,0])
@fact multipoint.coordinates[2][1][3] --> roughly([103,1])

@fact Turf.isclockwise(Vector{Float64}[[0,0],[1,1],[1,0],[0,0]]) --> true
@fact Turf.isclockwise(Vector{Float64}[[0,0],[1,0],[1,1],[0,0]]) --> false

hourglass = GeoJSON.parse("""{
        "type": "Polygon",
        "coordinates": [
          [
            [
              -12.034835815429688,
              8.901183448260598
            ],
            [
              -12.060413360595701,
              8.899826693726117
            ],
            [
              -12.036380767822266,
              8.873199368734273
            ],
            [
              -12.059383392333983,
              8.871418491385919
            ],
            [
              -12.034835815429688,
              8.901183448260598
            ]
          ]
        ]
      }""")
hourglasskinks = Turf.kinks(hourglass)
@fact typeof(hourglasskinks) --> GeoJSON.FeatureCollection
@fact length(hourglasskinks.features) --> 2
@fact typeof(hourglasskinks.features[1]) --> GeoJSON.Point

triple = GeoJSON.parse("""{
        "type": "Polygon",
        "coordinates": [
          [
            [
              -44.384765625,
              1.0106897682409128
            ],
            [
              -53.4375,
              0.4833927027896987
            ],
            [
              -43.154296875,
              -6.402648405963884
            ],
            [
              -53.173828125,
              -6.708253968671543
            ],
            [
              -43.857421875,
              -13.752724664396975
            ],
            [
              -54.09667968749999,
              -14.944784875088372
            ],
            [
              -53.3935546875,
              -11.867350911459308
            ],
            [
              -44.384765625,
              1.0106897682409128
            ]
          ]
        ]
      }""")
triplekinks = Turf.kinks(triple)
@fact length(triplekinks.features) --> 6

feature = GeoJSON.parse("""{
    "type": "Feature",
    "geometry": {
      "type": "Polygon",
      "coordinates": [
        [
          [
            -12.034835815429688,
            8.901183448260598
          ],
          [
            -12.060413360595701,
            8.899826693726117
          ],
          [
            -12.036380767822266,
            8.873199368734273
          ],
          [
            -12.059383392333983,
            8.871418491385919
          ],
          [
            -12.034835815429688,
            8.901183448260598
          ]
        ]
      ]
    },
    "properties": null
  }""")

featurekinks = Turf.kinks(feature)
@fact length(featurekinks.features) --> 2
