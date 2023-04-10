#=
Mesh generation utilities.
=#
using Random: Xoshiro


"""
    generate_cyl_points(boundary::T, inside::T, cyl::T) where T <: Int64

Generate points for unstructured grid around cylinder.

Parameters specify the number of points to create.
Cylinder has radius 0.8 and bounding frame is `x ∈ [-5, 10]`, `y ∈ [-5, 5]`.
"""
function generate_cyl_points(boundary::T, inside::T, cyl::T; verbose=true) where T <: Int64
    n = boundary + inside + cyl
    points = zeros(Float64, 2, n)

    # bounding frame
    nb = div(boundary, 10)
    # front
    points[1, 1:2*nb] = repeat([-5], 2*nb)
    points[2, 1:2*nb] = LinRange(5, -5, 2*nb)
    # bottom
    points[1, 2*nb+1:5*nb] = LinRange(-5, 10, 3*nb)
    points[2, 2*nb+1:5*nb] = repeat([-5], 3*nb)
    # back
    points[1, 5*nb+1:7*nb] = repeat([10], 2*nb)
    points[2, 5*nb+1:7*nb] = LinRange(-5, 5, 2*nb)
    # top
    points[1, 7*nb+1:boundary] = LinRange(10, -5, 3*nb)
    points[2, 7*nb+1:boundary] = repeat([5], 3*nb)

    # cylinder boundary
    for i in 1:cyl
        points[1, boundary + i] = 0.8 * cos(2π * (i - 1) / cyl)
        points[2, boundary + i] = 0.8 * sin(2π * (i - 1) / cyl)
    end

    # generate points inside the domain
    pin = rand(Xoshiro(42), 2, inside) .- 0.5
    pin[1, :] .*= 15
    pin[1, :] .+= 2.5
    pin[2, :] .*= 10

    # filter points that are outside the frame or inside the cylinder
    pdel = Set{Int64}()
    for i = axes(pin, 2)
        x, y = pin[:, i]
        if x^2 + y^2 <= 0.8^2
            push!(pdel, i)
            continue
        end
        isinside = -5 < x < 10 && -5 < y < 5
        if !isinside
            push!(pdel, i)
        end
    end
    pleave = setdiff(Set(1:size(pin, 2)), pdel)
    pin = pin[:, collect(pleave)]
    ldel = length(pdel)
    if verbose
        println("Deleted ", ldel, " points.")
    end

    # insert `inside` points into the `points`
    idx = n - inside + 1
    points[:, idx:end-ldel] = pin
    points = points[:, 1:end-ldel]

    return points
end
