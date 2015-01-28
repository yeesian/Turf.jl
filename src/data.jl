function remove(collection::GeoJSON.FeatureCollection, key::String, value::String)
    fc = GeoJSON.FeatureCollection()
    for feature in collection.features
        if haskey(feature.properties, key) && feature.properties[key] != value
            push!(fc.features, deepcopy(feature))
        end
    end
    fc
end

function remove(collection::GeoJSON.FeatureCollection, key::String, value::Integer)
    fc = GeoJSON.FeatureCollection()
    for feature in collection.features
        if haskey(feature.properties, key) && feature.properties[key] != value
            push!(fc.features, deepcopy(feature))
        end
    end
    fc
end

function filter(collection::GeoJSON.FeatureCollection, property::String, value::String)
    fc = GeoJSON.FeatureCollection()
    for feature in collection.features
        if haskey(feature.properties, key) && feature.properties[key] == value
            push!(fc.features, deepcopy(feature))
        end
    end
    fc
end

function filter(collection::GeoJSON.FeatureCollection, key::String, value::Integer)
    fc = GeoJSON.FeatureCollection()
    for feature in collection.features
        if haskey(feature.properties, key) && feature.properties[key] == value
            push!(fc.features, deepcopy(feature))
        end
    end
    fc
end