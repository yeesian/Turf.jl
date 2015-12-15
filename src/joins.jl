# Only supports 2D geometries for now

# pt is [x,y] and ring is [[x,y], [x,y],..]
function inring(pt::Vector{Float64}, ring::Vector{Vector{Float64}})
    intersect(i::Vector{Float64},j::Vector{Float64}) =
        (i[2] >= pt[2]) != (j[2] >= pt[2]) && (pt[1] <= (j[1] - i[1]) * (pt[2] - i[2]) / (j[2] - i[2]) + i[1])
    isinside = intersect(ring[1], ring[end])
    for k=2:length(ring)
        isinside = intersect(ring[k], ring[k-1]) ? !isinside : isinside
    end
    isinside
end

# pt is [x,y] and polygon is [ring, [ring, ring, ...]]
function inpolygon(pt::Vector{Float64}, polygon::Vector{Vector{Vector{Float64}}})
    if !inring(pt, polygon[1]) # check if it is in the outer ring first
        return false
    end
    for poly in polygon[2:end] # check for the point in any of the holes
        if inring(pt,poly)
            return false
        end
    end
    true
end

# GeoJSON.Point

inside(point::GeoJSON.Point, polygon::GeoJSON.Polygon) = inpolygon(point.coordinates, polygon.coordinates)

function inside(point::GeoJSON.Point, polygon::GeoJSON.MultiPolygon)
    for poly in polygon.coordinates
        if inpolygon(point.coordinates, poly)
            return true
        end
    end
    false
end

inside(point::GeoJSON.Point, polygon::GeoJSON.Feature) = inside(point, polygon.geometry)

function inside(point::GeoJSON.Point, collection::GeoJSON.GeometryCollection)
    for geom in collection.geometries
        if inside(point, geom)
            return true
        end
    end
    false
end

function inside(point::GeoJSON.Point, collection::GeoJSON.FeatureCollection)
    for feature in collection.features
        if inside(point, feature)
            return true
        end
    end
    false
end

# GeoJSON.MultiPoint
function inside(point::GeoJSON.MultiPoint, polygon::GeoJSON.Polygon)
    poly = polygon.coordinates
    for pt in point.coordinates
        if !inpolygon(pt, poly)
            return false
        end
    end
    true
end

function inside(point::GeoJSON.MultiPoint, polygon::GeoJSON.MultiPolygon)
    for pt in point.coordinates
        for poly in polygon.coordinates
            if !inpolygon(pt, poly)
                return false
            end
        end
    end
    true
end

inside(point::GeoJSON.MultiPoint, polygon::GeoJSON.Feature) = inside(point, polygon.geometry)

function inside(point::GeoJSON.MultiPoint, collection::GeoJSON.GeometryCollection)
    for geom in collection.geometries
        if inside(point, geom)
            return true
        end
    end
    false
end

function inside(point::GeoJSON.MultiPoint, collection::GeoJSON.FeatureCollection)
    for feature in collection.features
        if inside(point, feature)
            return true
        end
    end
    false
end

# GeoJSON.Feature
inside(point::GeoJSON.Feature, polygon::GeoJSON.Polygon) = inside(point.geometry, polygon)
inside(point::GeoJSON.Feature, polygon::GeoJSON.MultiPolygon) = inside(point.geometry, polygon)
inside(point::GeoJSON.Feature, polygon::GeoJSON.Feature) = inside(point.geometry, polygon)
inside(point::GeoJSON.Feature, collection::GeoJSON.GeometryCollection) = inside(point.geometry, collection)
inside(point::GeoJSON.Feature, collection::GeoJSON.FeatureCollection) = inside(point.geometry, collection)

for geojson_type in (GeoJSON.Point, GeoJSON.MultiPoint, GeoJSON.Feature)
    @eval begin
        within(point::$geojson_type, polygon::GeoJSON.Polygon) = inside(point, polygon) ? point : nothing
        within(point::$geojson_type, polygon::GeoJSON.MultiPolygon) = inside(point, polygon) ? point : nothing
        within(point::$geojson_type, polygon::GeoJSON.Feature) = inside(point, polygon) ? point : nothing
        within(point::$geojson_type, collection::GeoJSON.GeometryCollection) = inside(point, collection) ? point : nothing
        within(point::$geojson_type, collection::GeoJSON.FeatureCollection) = inside(point, collection) ? point : nothing
    end
end

# GeoJSON.GeometryCollection
within(collection::GeoJSON.GeometryCollection, polygon::GeoJSON.Polygon) = GeoJSON.GeometryCollection(Base.filter((geom,)->inside(geom,polygon), collection.geometries))
within(collection::GeoJSON.GeometryCollection, polygon::GeoJSON.MultiPolygon) = GeoJSON.GeometryCollection(Base.filter((geom,)->inside(geom,polygon), collection.geometries))
within(collection::GeoJSON.GeometryCollection, polygon::GeoJSON.Feature) = GeoJSON.GeometryCollection(Base.filter((geom,)->inside(geom,polygon), collection.geometries))
within(collection::GeoJSON.GeometryCollection, polygon::GeoJSON.GeometryCollection) = GeoJSON.GeometryCollection(Base.filter((geom,)->inside(geom,polygon), collection.geometries))
within(collection::GeoJSON.GeometryCollection, polygon::GeoJSON.FeatureCollection) = GeoJSON.GeometryCollection(Base.filter((geom,)->inside(geom,polygon), collection.geometries))

# GeoJSON.FeatureCollection
within(collection::GeoJSON.FeatureCollection, polygon::GeoJSON.Polygon) = GeoJSON.FeatureCollection(Base.filter((feature,)->inside(feature,polygon), collection.features))
within(collection::GeoJSON.FeatureCollection, polygon::GeoJSON.MultiPolygon) = GeoJSON.FeatureCollection(Base.filter((feature,)->inside(feature,polygon), collection.features))
within(collection::GeoJSON.FeatureCollection, polygon::GeoJSON.Feature) = GeoJSON.FeatureCollection(Base.filter((feature,)->inside(feature,polygon), collection.features))
within(collection::GeoJSON.FeatureCollection, polygon::GeoJSON.GeometryCollection) = GeoJSON.FeatureCollection(Base.filter((feature,)->inside(feature,polygon), collection.features))
within(collection::GeoJSON.FeatureCollection, polygon::GeoJSON.FeatureCollection) = GeoJSON.FeatureCollection(Base.filter((feature,)->inside(feature,polygon), collection.features))

# end

# function tag()
function tag(points::GeoJSON.FeatureCollection, polygons::GeoJSON.FeatureCollection, field::AbstractString, outfield::AbstractString)
    tagpoints = deepcopy(points)
    for pt in tagpoints.features
        if pt.properties == nothing
            pt.properties = Dict{AbstractString,Any}()
        end
        for poly in polygons.features
            if !haskey(pt.properties, outfield)
                if inside(pt, poly)
                    pt.properties[outfield] = poly.properties[field]
                end
            end
        end
    end
    tagpoints
end
