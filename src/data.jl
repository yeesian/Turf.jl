function remove(collection::GeoJSON.FeatureCollection, key::AbstractString, value::AbstractString)
    fc = GeoJSON.FeatureCollection()
    for feature in collection.features
        if haskey(feature.properties, key) && feature.properties[key] != value
            push!(fc.features, deepcopy(feature))
        end
    end
    fc
end

function remove(collection::GeoJSON.FeatureCollection, key::AbstractString, value::Integer)
    fc = GeoJSON.FeatureCollection()
    for feature in collection.features
        if haskey(feature.properties, key) && feature.properties[key] != value
            push!(fc.features, deepcopy(feature))
        end
    end
    fc
end

function filter(collection::GeoJSON.FeatureCollection, property::AbstractString, value::AbstractString)
    fc = GeoJSON.FeatureCollection()
    for feature in collection.features
        if haskey(feature.properties, key) && feature.properties[key] == value
            push!(fc.features, deepcopy(feature))
        end
    end
    fc
end

function filter(collection::GeoJSON.FeatureCollection, key::AbstractString, value::Integer)
    fc = GeoJSON.FeatureCollection()
    for feature in collection.features
        if haskey(feature.properties, key) && feature.properties[key] == value
            push!(fc.features, deepcopy(feature))
        end
    end
    fc
end
