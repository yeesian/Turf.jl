cross(o::Vector{Float64}, a::Vector{Float64}, b::Vector{Float64}) = (a[1]-o[1])*(b[2]-o[2]) - (a[2]-o[2])*(b[1]-o[1])

function convex(points::Vector{Vector{Float64}})
    lower = Vector{Float64}[]
    upper = Vector{Float64}[]
    lt(a,b) = a[1] == b[1] ? a[2] < b[2] : a[1] < b[1]
    sort!(points, lt=lt)
    for i=1:length(points)
        while length(lower) >= 2 && cross(lower[end-2], lower[end-1], points[i]) <= 0
            pop!(lower)
        end
        push!(lower, points[i])
    end
    for i=length(points):-1:1
        while length(upper) >= 2 && cross(upper[end-2], upper[end-1], points[i]) <= 0
            pop!(upper)
        end
        push!(upper, points[i])
    end
    pop!(upper)
    pop!(lower)
    coords = [lower, upper]
    push!(coords, coords[1])
    GeoJSON.Feature(GeoJSON.Polygon(Vector{Vector{Float64}}[coords]))
end