
function quantile(fc::GeoJSON.FeatureCollection, field::String, percentiles::Vector{Float64})
    vals = [feature.properties[field] for feature in fc.features]
    Float64[Base.quantile(vals, percentile * 0.01) for percentile in percentiles]
end
quantile(fc::GeoJSON.FeatureCollection, field::String, percentiles::Vector{Int}) = quantile(fc,field,float(percentiles))

# jenks from https://github.com/tmcw/simple-statistics/blob/b930ead8b61ee6ea862e68c5b6dc5d84c3c3cc8f/src/simple_statistics.js

function jenks(fc, field, num)
end

function reclass(fc::GeoJSON.FeatureCollection, infield::String, outfield::String, translations::Vector)
    reclassed = GeoJSON.FeatureCollection()
    for feature in fc.features
        reclassed_feature = deepcopy(feature)
        found = false
        for translation in translations
            if feature.properties[infield] >= translation[1] && feature.properties[infield] <= translation[2]
                reclassed_feature.properties[outfield] = translation[2]
            end
        end
        push!(reclassed.features, reclassed_feature)
    end
    reclassed
end