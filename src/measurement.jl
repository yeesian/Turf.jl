toradians(degree::Float64) = degree * π / 180.0
todegrees(radian::Float64) = radian * 180.0 / π
convertunits(units::Symbol = :kilometers) = 3960.0*(units == :miles) + 6373.0*(units == :kilometers) + 57.2957795*(units == :degrees) + (units == :radians)

function distance(point1::Vector{Float64}, point2::Vector{Float64}, units::Symbol = :kilometers)
    dLat = toradians(point2[2] - point1[2])
    dLon = toradians(point2[1] - point1[1])
    lat1 = toradians(point1[2])
    lat2 = toradians(point2[2])
    a = sin(dLat/2)^2 + sin(dLon/2)^2 * cos(lat1) * cos(lat2)
    2.0 * atan2(sqrt(a), sqrt(1-a)) * convertunits(units)
end
distance(point1::GeoJSON.Point, point2::GeoJSON.Point, units::Symbol = :kilometers) = distance(point1.coordinates, point2.coordinates, units)
distance(point1::GeoJSON.Feature, point2::GeoJSON.Feature, units::Symbol = :kilometers) = distance(point1.geometry, point2.geometry, units)

function ringarea(coords::Vector{Vector{Float64}})
    f(p1::Vector{Float64},p2::Vector{Float64}) = toradians(p2[1]-p1[1]) * (2+sin(toradians(p1[2])) + sin(toradians(p2[2])))
    area_ = 0.0
    if length(coords) > 2
        for i=1:length(coords)-1
            area_ += f(coords[1], coords[i+1])
        end
        area_ *= RADIUS^2 / 2
    end
    area_
end

function polygonarea(coords::Vector{Vector{Vector{Float64}}})
    if length(coords) > 0
        area_ = abs(ringarea(coords[0]))
        for coord in coords[2:end]
            area_ -= abs(ringarea(coords))
        end
        return area_
    else
        return 0.0
    end
end
polygonarea(obj::Void) = 0.0

area(obj::GeoJSON.Point) = 0.0
area(obj::GeoJSON.MultiPoint) = 0.0
area(obj::GeoJSON.LineString) = 0.0
area(obj::GeoJSON.MultiLineString) = 0.0
area(obj::GeoJSON.Polygon) = polygonarea(obj.coordinates)
area(obj::GeoJSON.MultiPolygon) = sum(map(polygonarea, obj.coordinates))
area(obj::GeoJSON.GeometryCollection) = sum(map(area, obj.geometries))
area(obj::GeoJSON.Feature) = area(obj.geometry)
area(obj::GeoJSON.FeatureCollection) = sum(map(area, obj.features))

function nearest(target::GeoJSON.Point, points::GeoJSON.FeatureCollection)
    if length(points.features) > 0
        nearest_feature = points.features[1]
        nearest_dist = distance(target, nearest_feature.geometry)
        for feature in points.features[2:end]
            dist = distance(target, feature.geometry)
            if dist < nearest_dist
                nearest_feature = feature
                nearest_dist = dist
            end
        end
        return deepcopy(nearest_feature)
    end
end

function nearest(target::GeoJSON.Point, points::GeoJSON.GeometryCollection)
    if length(points.geometries) > 0
        nearest = points.geometries[1]
        nearest_dist = distance(target, nearest.geometry)
        for geometry in points.geometries[2:end]
            dist = distance(target, geometry)
            if dist < nearest_dist
                nearest = geometry
                nearest_dist = dist
            end
        end
        nearest = deepcopy(nearest)
    end
end
nearest(target::GeoJSON.Feature, points::GeoJSON.FeatureCollection) = nearest(target.geometry, points)

function bboxpolygon(bbox::Vector{Float64})
    lowleft = Float64[bbox[1], bbox[2]]
    topleft = Float64[bbox[1], bbox[4]]
    topright = Float64[bbox[3], bbox[4]]
    lowright = Float64[bbox[3], bbox[2]]
    GeoJSON.Polygon(Vector{Vector{Float64}}[Vector{Float64}[lowleft, lowright, topright, topleft, lowleft]])
end

topright(obj::Vector{Vector{Float64}}) = reduce(max, obj)
topright(obj::Vector{Vector{Vector{Float64}}}) = topright(map(topright, obj)::Vector{Vector{Float64}})
topright(obj::GeoJSON.Point) = obj.coordinates
topright(obj::GeoJSON.MultiPoint) = topright(obj.coordinates)
topright(obj::GeoJSON.LineString) = topright(obj.coordinates)
topright(obj::GeoJSON.MultiLineString) = topright(obj.coordinates)
topright(obj::GeoJSON.Polygon) = topright(obj.coordinates)
topright(obj::GeoJSON.MultiPolygon) = topright(map(topright, obj.coordinates))
topright(obj::GeoJSON.GeometryCollection) = topright(map(topright, obj.geometries))
topright(obj::GeoJSON.Feature) = topright(obj.geometry)
topright(obj::GeoJSON.FeatureCollection) = topright(map(topright, obj.features))

lowleft(obj::Vector{Vector{Float64}}) = reduce(min, obj)
lowleft(obj::Vector{Vector{Vector{Float64}}}) = lowleft(map(lowleft, obj)::Vector{Vector{Float64}})
lowleft(obj::GeoJSON.Point) = obj.coordinates
lowleft(obj::GeoJSON.MultiPoint) = lowleft(obj.coordinates)
lowleft(obj::GeoJSON.LineString) = lowleft(obj.coordinates)
lowleft(obj::GeoJSON.MultiLineString) = lowleft(obj.coordinates)
lowleft(obj::GeoJSON.Polygon) = lowleft(obj.coordinates)
lowleft(obj::GeoJSON.MultiPolygon) = lowleft(map(lowleft, obj.coordinates))
lowleft(obj::GeoJSON.GeometryCollection) = lowleft(map(lowleft, obj.geometries))
lowleft(obj::GeoJSON.Feature) = lowleft(obj.geometry)
lowleft(obj::GeoJSON.FeatureCollection) = lowleft(map(lowleft, obj.features))

extent(obj::GeoJSON.Point) = obj.coordinates
extent(obj::GeoJSON.MultiPoint) = [topright(obj); lowleft(obj)]
extent(obj::GeoJSON.LineString) = [topright(obj); lowleft(obj)]
extent(obj::GeoJSON.MultiLineString) = [topright(obj); lowleft(obj)]
extent(obj::GeoJSON.Polygon) = [topright(obj); lowleft(obj)]
extent(obj::GeoJSON.MultiPolygon) = [topright(obj); lowleft(obj)]
extent(obj::GeoJSON.Feature) = [topright(obj); lowleft(obj)]
extent(obj::GeoJSON.FeatureCollection) = [topright(obj); lowleft(obj)]

envelope(obj::GeoJSON.AbstractGeoJSON) = bboxpolygon(extent(obj))

function midpoint(p1::Vector{Float64}, p2::Vector{Float64})
    x1, y1, x2, y2 = p1[1], p1[2], p2[1], p2[2]
    Float64[(x1+x2)/2, (y1+y2)/2]
end
midpoint(p1::GeoJSON.Point, p2::GeoJSON.Point) = GeoJSON.Point(midpoint(p1.coordinates, p2.coordinates))
midpoint(p1::GeoJSON.Feature, p2::GeoJSON.Feature) = GeoJSON.Feature(midpoint(p1.geometry, p2.geometry))

function square(bbox::Vector{Float64})
    lowleft = Float64[bbox[1],bbox[2]]
    topleft = Float64[bbox[1],bbox[4]]
    topright = Float64[bbox[3],bbox[4]]
    lowright = Float64[bbox[3],bbox[2]]
    hdist = distance(lowleft, lowright)
    vdist = distance(lowleft, topleft)
    if hdist >= vdist
        mid = midpoint(lowleft, topleft)
        return Float64[ bbox[1],
                        mid[2] - (bbox[3] - bbox[1])/2,
                        bbox[3],
                        mid[1] + (bbox[3] - bbox[1])/2 ]
    else
        mid = midpoint(lowleft, lowright)
        return Float64[ mid[1] - (bbox[4] - bbox[2])/2,
                        bbox[2],
                        mid[1] + (bbox[4] - bbox[2])/2,
                        bbox[4] ]
    end
end

function size(bbox::Vector{Float64}, factor::Real)
    curr_xdist = bbox[3] - bbox[1]
    curr_ydist = bbox[4] - bbox[2]
    new_xdist = factor * curr_xdist
    new_ydist = factor * curr_ydist
    dx = new_xdist - curr_xdist
    dy = new_ydist - curr_ydist

    Float64[bbox[1] - dx/2, # low_x
            bbox[2] - dy/2, # low_y
            bbox[3] + dx/2, # high_x
            bbox[4] + dy/2] # high_y
end

function center(obj::GeoJSON.AbstractGeoJSON)
    ext = extent(obj)
    GeoJSON.Point(Float64[(ext[1] + ext[3])/2, (ext[2] + ext[4])/2])
end

centroid(obj::Vector{Vector{Float64}}) = reduce(+, obj) / length(obj)
function centroid(obj::Vector{Vector{Vector{Float64}}})
    points = vcat(obj...) # not memory efficient
    reduce(+, points) / length(points)
end
centroid(obj::GeoJSON.Point) = obj
centroid(obj::GeoJSON.MultiPoint) = GeoJSON.Point(centroid(obj.coordinates))
centroid(obj::GeoJSON.LineString) = GeoJSON.Point(centroid(obj.coordinates))
centroid(obj::GeoJSON.MultiLineString) = GeoJSON.Point(centroid(obj.coordinates))
centroid(obj::GeoJSON.Polygon) = GeoJSON.Point(centroid(obj.coordinates)) # what about the holes?
centroid(obj::GeoJSON.MultiPolygon) = GeoJSON.Point(centroid(vcat(obj.coordinates...))) # what about the holes?
centroid(obj::GeoJSON.GeometryCollection) = map(centroid, obj.geometries) # different from Turf.js
centroid(obj::GeoJSON.Feature) = centroid(obj.geometry)
centroid(obj::GeoJSON.FeatureCollection) = map(centroid, obj.features) # different from Turf.js

function bearing(p1::Vector{Float64}, p2::Vector{Float64})
    lon1 = toradians(p1[1])
    lon2 = toradians(p2[1])
    lat1 = toradians(p1[2])
    lat2 = toradians(p2[2])
    a = sin(lon2 - lon1) * cos(lat2)
    b = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1)
    todegrees(atan2(a, b))
end
bearing(p1::GeoJSON.Point, p2::GeoJSON.Point) = bearing(p1.coordinates, p2.coordinates)
bearing(p1::GeoJSON.Feature, p2::GeoJSON.Feature) = bearing(p1.geometry, p2.geometry)

function destination(point::Vector{Float64}, distance::Float64, bearing::Float64, units::Symbol = :kilometers)
    lon1 = toradians(point[1])
    lat1 = toradians(point[2])
    bearing_rad = toradians(bearing)
    dist = distance / convertunits(units)
    lat2 = asin(sin(lat1)*cos(dist) + cos(lat1)*sin(dist)*cos(bearing_rad))
    lon2 = lon1 + atan2(sin(bearing_rad)*sin(dist)*cos(lat1), cos(dist) - sin(lat1)*sin(lat2))
    GeoJSON.Point(Float64[todegrees(lon2), todegrees(lat2)])
end
destination(point::GeoJSON.Point, distance::Float64, bearing::Float64, units::Symbol = :kilometers) = destination(point.coordinates, distance, bearing, units)
destination(point::GeoJSON.Feature, distance::Float64, bearing::Float64, units::Symbol = :kilometers) = destination(point.geometry, distance, bearing, units)

function linedistance(line::Vector{Vector{Float64}}, units::Symbol = :kilometers)
    dist = 0.0
    for i=1:length(line)-1
        dist += distance(line[i], line[i+1], units)
    end
    dist
end
linedistance(line::GeoJSON.LineString, units::Symbol = :kilometers) = linedistance(line.coordinates, units)
function linedistance(multiline::GeoJSON.MultiLineString, units::Symbol = :kilometers)
    dist = 0.0
    for line in multiline.coordinates
        dist += linedistance(line, units)
    end
    dist
end
linedistance(line::GeoJSON.Feature, units::Symbol = :kilometers) = linedistance(line.geometry, units)

function along(line::Vector{Vector{Float64}}, dist::Real, units::Symbol = :kilometers)
    travelled = 0.0
    n_points = length(line)
    for i=1:n_points
        if travelled <= dist && i == n_points
            break
        elseif travelled == dist
            return GeoJSON.Point(line[i])
        elseif travelled > dist
            overshot = dist - travelled
            direction = bearing(line[i], line[i-1]) - 180.0
            return destination(line[i], overshot, direction, units)
        else # travelled == dist
            travelled += distance(line[i], line[i+1], units)
        end
    end
    GeoJSON.Point(line[end])
end
along(line::GeoJSON.LineString, dist::Real, units::Symbol = :kilometers) = along(line.coordinates, dist, units)
along(line::GeoJSON.Feature, dist::Real, units::Symbol = :kilometers) = along(line.geometry, dist, units)
