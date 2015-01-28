module Turf
    import GeoJSON

    export 
        inside,
        within,
        tag,
        remove,
        filter,
        distance,
        area,
        nearest,
        bboxpolygon,
        envelope,
        extent,
        square,
        # size,
        center,
        centroid,
        midpoint,
        bearing,
        destination,
        linedistance,
        along,
        quantile,
        reclass,
        convex,
        flip,
        explode,
        combine,
        isclockwise,
        kinks

    include("joins.jl")
    include("data.jl")
    include("measurement.jl")
    # include("interpolation.jl")
    include("classification.jl")
    # include("aggregation.jl")
    # include("transformation.jl")
    include("misc.jl")
    # include("wgs84constants.jl")
end