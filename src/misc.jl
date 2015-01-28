flip(obj::Vector{Float64}) = reverse(obj)
flip(obj::Vector{Vector{Float64}}) = map(flip, obj)
flip(obj::Vector{Vector{Vector{Float64}}}) = map(flip, obj)

flip(obj::GeoJSON.Point) = GeoJSON.Point(flip(obj.coordinates))
flip(obj::GeoJSON.MultiPoint) = GeoJSON.MultiPoint(flip(obj.coordinates))
flip(obj::GeoJSON.LineString) = GeoJSON.LineString(flip(obj.coordinates))
flip(obj::GeoJSON.MultiLineString) = GeoJSON.MultiLineString(map(flip,obj.coordinates))
flip(obj::GeoJSON.Polygon) = GeoJSON.Polygon(map(flip,obj.coordinates))
flip(obj::GeoJSON.MultiPolygon) = GeoJSON.MultiPolygon(map(flip,obj.coordinates))
flip(obj::GeoJSON.GeometryCollection) = GeoJSON.GeometryCollection(map(flip, obj.geometries)) # be careful of type here
flip(obj::GeoJSON.Feature) = GeoJSON.Feature(flip(obj.geometry))
flip(obj::GeoJSON.FeatureCollection) = GeoJSON.FeatureCollection(map(flip, obj.features))

explode(obj::Vector{Float64}) = GeoJSON.Feature[GeoJSON.Feature(GeoJSON.Point(obj))]
explode(obj::Vector{Vector{Float64}}) = vcat(map(explode, obj)...)
explode(obj::Vector{Vector{Vector{Float64}}}) = vcat(map(explode, obj)...)

explode(obj::GeoJSON.Point) = GeoJSON.FeatureCollection(explode(obj.coordinates))
explode(obj::GeoJSON.MultiPoint) = GeoJSON.FeatureCollection(explode(obj.coordinates))
explode(obj::GeoJSON.LineString) = GeoJSON.FeatureCollection(explode(obj.coordinates))
explode(obj::GeoJSON.MultiLineString) = GeoJSON.FeatureCollection(explode(obj.coordinates))
explode(obj::GeoJSON.Polygon) = GeoJSON.FeatureCollection(explode(obj.coordinates))
explode(obj::GeoJSON.MultiPolygon) = GeoJSON.FeatureCollection(vcat(map(explode, obj.coordinates)...))
explode(obj::GeoJSON.Feature) = explode(obj.geometry)

function explode(obj::GeoJSON.GeometryCollection)
    fc = GeoJSON.Feature[]
    for geom in obj.geometries
        fc = vcat(fc, explode(geom.coordinates)) # inefficient?
    end
    GeoJSON.FeatureCollection(fc)
end

function explode(obj::GeoJSON.FeatureCollection)
    fc = GeoJSON.Feature[]
    for feature in obj.features
        fc = vcat(fc, explode(feature.geometry))
    end
    GeoJSON.FeatureCollection(fc)
end

combine(obj::Vector{GeoJSON.Point}) = GeoJSON.MultiPoint(map(GeoJSON.coordinates, obj))
combine(obj::Vector{GeoJSON.LineString}) = GeoJSON.MultiLineString(map(GeoJSON.coordinates, obj))
combine(obj::Vector{GeoJSON.Polygon}) = GeoJSON.MultiPolygon(map(GeoJSON.coordinates, obj))
combine(obj::GeoJSON.GeometryCollection) = combine(obj.geometries)
combine(obj::GeoJSON.Feature) = combine(obj.geometry::GeoJSON.GeometryCollection)
combine(obj::GeoJSON.FeatureCollection) = combine(typeof(obj.features[1].geometry)[feature.geometry for feature in obj.features])

function isclockwise(ring::Vector{Vector{Float64}}) # not sure if this works
    sum = 0.0
    for i=2:length(ring)
        prev = ring[i-1]; cur = ring[i]
        sum += (cur[1] - prev[1]) * (cur[2] + prev[2])
    end
    sum > 0
end

function intersection(line1startx::Float64, line1starty::Float64, line1endx::Float64, line1endy::Float64,
                      line2startx::Float64, line2starty::Float64, line2endx::Float64, line2endy::Float64)
    online1 = false
    online2 = false
    
    denom = ((line2endy - line2starty)*(line1endx - line1startx)) - ((line2endx - line2startx)*(line1endy - line1starty))

    a = line1starty - line2starty
    b = line1startx - line2startx
    num1 = ((line2endx - line2startx) * a) - ((line2endy - line2starty) * b)
    num2 = ((line1endx - line1startx) * a) - ((line1endy - line1starty) * b)
    a = num1 / denom
    b = num2 / denom

    # if we cast these lines infinitely in both directions, they intersect here:
    x = line1startx + (a * (line1endx - line1startx))
    y = line1starty + (a * (line1endy - line1starty))

    # they intersect if:
    online1 = a > 0 && a < 1 # if line1 is a segment and line2 is infinite
    online2 = b > 0 && b < 1 # if line2 is a segment and line1 is infinite

    # if line1 and line2 are segments, they intersect if both of the above are true
    if online1 && online2
        return Float64[x, y]
    else
        return Float64[]
    end
end

function kinks(obj::GeoJSON.Polygon)
    results = GeoJSON.FeatureCollection()
    for ring1 in obj.coordinates
        for ring2 in obj.coordinates
            for i=1:length(ring1)-1
                for k=1:length(ring2)-1
                    intersect = intersection(ring1[i][1], ring1[i][2], ring1[i+1][1], ring1[i+1][2],
                                             ring2[k][1], ring2[k][2], ring2[k+1][1], ring2[k+1][2])
                    if length(intersect) == 2
                        push!(results.features, GeoJSON.Feature(GeoJSON.Point(intersect)))
                    end
                end
            end
        end
    end
    results
end
kinks(obj::GeoJSON.Feature) = kinks(obj.geometry)
