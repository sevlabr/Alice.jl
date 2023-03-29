#=
A set of relatively simple computational geometry algorithms.
Mainly Delaunay triangulations and helper functions for it
but not only.
=#
using LinearAlgebra: det
using StaticArrays:  @SMatrix # immutable

"Vertex of a `Triangle`."
struct Node
    x::Float64
    y::Float64
end

function Node()
    Node(0, 0)
end


"Get `x` and `y` of a given `Node`."
function nodexy(n::Node)
    [n.x, n.y]
end

"""
    matrix_to_nodes(m::Vector{T} where T <: Real)

Convert ``M \\times 2`` `Matrix` to a `Vector{Node}`.
"""
function matrix_to_nodes(m::Matrix{T} where T <: Real)
    points = []
    for i = axes(m, 1)
        x, y = m[i, :]
        push!(points, Node(x, y))
    end
    return points
end


"3 vertices represent a `Triangle`."
struct Triangle
    nodes::Vector{Node}
end

"Get `Node`s of a given `Triangle`."
function tnodes(t::Triangle)
    t.nodes
end

"""
Return ``3 \\times 2`` `Matrix` each row of which is
`x` and `y` coordinates of a vertex.
"""
function tvertices(t::Triangle)
    xys = zeros(Float64, 3, 2)
    for (idx, node) in enumerate(tnodes(t))
        xy = nodexy(node)
        xys[idx, :] = xy
    end
    return xys
end

"Return ``2S`` where ``S`` is an oriented area of `t`."
function t2area(t::Triangle)
    (x1, x2, x3, y1, y2, y3) = tvertices(t)
    return (x1 - x3) * (y2 - y3) - (x2 - x3) * (y1 - y3)
end

"Return -1 if `Node`s of `t` are given in a clockwise order and 1 otherwise."
function tsign(t::Triangle)
    return sign(t2area(t))
end


"Center and radius."
struct Circle
    center::Node
    radius::Float64
end

"Return circumscribed `Circle` of a given `Triangle`."
function Circle(t::Triangle)
    points = tvertices(t)
    points2 = points * points'
    A = [2 * points2; [1 1 1];; [1; 1; 1]; 0]
    b = [sum(points .* points, dims=2); 1] # [tr(points2); 1]
    x = A \ b
    xc, yc = x[1:end-1]' * points
    radius2 = sum(abs2.(points[1, 1:2] - [xc; yc]))
    return Circle(Node(xc, yc), sqrt(radius2))
end

"Return `Circle` `center` and `radius`."
function ccr(c::Circle)
    [c.center, c.radius]
end


"""
Special representation of a `Triangle` as indices
of `Node`s in a `Delaunay2D` triangulation.
"""
struct DTriangle
    nodes::Tuple{Int64, Int64, Int64}
end

function DTriangle()
    DTriangle((0, 0, 0))
end

function Base.getindex(t::DTriangle, i::Int64)
    t.nodes[i]
end


"""
Representation of a 2D Delaunay triangulation: `Node`s, `Triangle`s and
adjacent to them, and circumscribed `Circle`s for `Triangle`s.
"""
struct Delaunay2D
    nodes::Vector{Node}
    triangles::Dict{DTriangle, Vector{DTriangle}}
    circles::Dict{DTriangle, Circle}
end

"Initialize `Delaunay2D` with given coordinates."
function Delaunay2D(points::Vector{Node})
    Delaunay2D(points, Dict(), Dict())
end


"""
    _simple_delaunay_condition(t::Triangle, x::Float64, y::Float64)

Check if a point is outside of a circumscribed circle or not.

Uses approach with calculating both ``sin`` and ``cos`` of the opposite corners.

!!! note

    `x` and `y` must represent a point which is inside an angle
    with a vertex `(x2, y2)`.

!!! warning

    Points in `Triangle` must be given in a clockwise order!
"""
function _simple_delaunay_condition(t::Triangle, x::Float64, y::Float64)
    (x1, x2, x3, y1, y2, y3) = tvertices(t)

    na = (x  - x1) * (y  - y3) - (x  - x3) * (y  - y1)
    sb = (x2 - x1) * (x2 - x3) + (y2 - y1) * (y2 - y3)
    sa = (x  - x1) * (x  - x3) + (y  - y1) * (y  - y3)
    nb = (x2 - x1) * (y2 - y3) - (x2 - x3) * (y2 - y1)

    return na * sb + sa * nb >= 0
end

"""
    simple_delaunay_condition(t::Triangle, x::Float64, y::Float64)

Return `true` if a point is outside of a circumscribed circle and `false` otherwise.

Uses faster approach which sometimes reduses to calculating only
``cos`` of the opposite corners.

!!! note

    `x` and `y` must represent a point which is inside an angle
    with a vertex `(x2, y2)`. Also it is preferable that this point is
    outside of a `Triangle` `t`.

!!! warning

    Points in `Triangle` must be given in a clockwise order!

# Examples

```jldoctest
julia> t = Triangle([Node(0, 0), Node(5, 5 * sqrt(3)), Node(10, 0)]);

julia> simple_delaunay_condition(t, 5.0, -1.0)
false

julia> simple_delaunay_condition(t, 5.0, -10.0)
true
```
"""
function simple_delaunay_condition(t::Triangle, x::Float64, y::Float64)
    (x1, x2, x3, y1, y2, y3) = tvertices(t)

    sa = (x  - x1) * (x  - x3) + (y  - y1) * (y  - y3)
    sb = (x2 - x1) * (x2 - x3) + (y2 - y1) * (y2 - y3)

    if sa < 0 && sb < 0
        return false
    elseif sa >= 0 && sb >= 0
        return true
    else
        return _simple_delaunay_condition(t, x, y)
    end
end

"""
    lies_inside(A::Node, B::Node, C::Node, D::Node)

Check if `D` is inside ``∠ABC``.

!!! note

    Works if ``∠ABC`` is less than ``180°``.

!!! warning
    
    If ``∠ABC`` is ``90°`` this function gives `NaN`s and does not work.
    And in general this function is unsafe in case of 0 division
    (in such a case the result is always `false`).
"""
function isinside(A::Node, B::Node, C::Node, D::Node)
    ax, ay = nodexy(A)
    bx, by = nodexy(B)
    cx, cy = nodexy(C)
    dx, dy = nodexy(D)

    axcx, bxax, dxax = ax - cx, bx - ax, dx - ax
    cyay, byay, dyay = cy - ay, by - ay, dy - ay

    j = (dyay - byay * dxax / bxax) / (byay * axcx / bxax + cyay)
    i = (dxax + axcx * j) / bxax

    if i > 0 && j > 0
        return true
    end
    return false
end

"""
    robust_delaunay_condition(t::Triangle, x::Float64, y::Float64)

Return `false` if `(x, y)` is in circumscribed circle around `t` and false otherwise.

Works slower than "simple" version but correctly in all cases
(inside/outside the angle, inside/outside the triangle).
Order of `Node`s in `t` does not matter.
"""
function robust_delaunay_condition(t::Triangle, x::Float64, y::Float64)
    (x1, x2, x3, y1, y2, y3) = tvertices(t)

    a = det(@SMatrix [x1 y1 1; x2 y2 1; x3 y3 1])
    sa = sign(a)
    b = det(@SMatrix [x1^2 + y1^2 y1  1; x2^2 + y2^2 y2  1; x3^2 + y3^2 y3  1])
    c = det(@SMatrix [x1^2 + y1^2 x1  1; x2^2 + y2^2 x2  1; x3^2 + y3^2 x3  1])
    d = det(@SMatrix [x1^2 + y1^2 x1 y1; x2^2 + y2^2 x2 y2; x3^2 + y3^2 x3 y3])

    cond = (a * (x^2 + y^2) - b * x + c * y - d) * sa
    return cond >= 0
end

"Return `true` if a point `(x, y)` is inside a given `t` or `false` otherwise."
function isinside(t::Triangle, x::Float64, y::Float64)
    (x1, x2, x3, y1, y2, y3) = tvertices(t)
    
    t1s = tsign(Triangle([Node(x, y), Node(x1, y1), Node(x2, y2)]))
    t2s = tsign(Triangle([Node(x, y), Node(x2, y2), Node(x3, y3)]))
    t3s = tsign(Triangle([Node(x, y), Node(x3, y3), Node(x1, y1)]))

    has_neg = (t1s < 0) || (t2s < 0) || (t3s < 0)
    has_pos = (t1s > 0) || (t2s > 0) || (t3s > 0)

    return !(has_neg && has_pos)
end

"""
    simple_delaunay(points::Vector{Node})

Generate `Delaunay2D` triangulation on given `Node`s.

Uses simple Bowyer-Watson algorithm. Main references:
- [analogous python code](https://github.com/jmespadero/pyDelaunay2D)
- [Computational Geometry: Algorithms and Applications](https://link.springer.com/book/10.1007/978-3-540-77974-2)
"""
function simple_delaunay(points::Vector{Node})
    # create bounding rectangle frame
    center = centroid(points)
    bbox = boundbox(points)
    frame = boundframe(center, bbox)

    triangulation = dtinit(frame)

    # Bowyer-Watson algorithm
    for p in points
        triangulation = add_point_bw!(p, triangulation)
    end

    return triangulation
end

"Get coordinates of a centroid of a set of points."
function centroid(points::Vector{Node})
    xsum = .0
    ysum = .0
    n = length(points)
    for p in points
        x, y = nodexy(p)
        xsum += x
        ysum += y
    end
    return Node(xsum / n, ysum / n)
end

"""
Return left bottom and right upper points of a rectangle
that encloses a provided set of points.
"""
function boundbox(points::Vector{Node})
    xmin, xmax, ymin, ymax = .0, .0, .0, .0
    for p in points
        x, y = nodexy(p)
        xmin, xmax = min(x, xmin), max(x, xmax)
        ymin, ymax = min(y, ymin), max(y, ymax)
    end
    return [Node(xmin, ymin), Node(xmax, ymax)]
end

"Create square frame for Delaunay triangulation."
function boundframe(center::Node, bbox::Vector{Node})
    xc, yc = nodexy(center)
    xmin, ymin = nodexy(bbox[1])
    xmax, ymax = nodexy(bbox[2])
    xd = xmax - xmin
    yd = ymax - ymin
    frame = [Node(xc - 3 * xd, yc - 3 * yd),
             Node(xc + 3 * xd, yc - 3 * yd),
             Node(xc + 3 * xd, yc + 3 * yd),
             Node(xc - 3 * xd, yc + 3 * yd)]
    return frame
end

"Initialize `Delaunay2D` with given coordinates of a bounding frame."
function dtinit(frame::Vector{Node})
    dt = Delaunay2D(frame)

    # Create two CCW triangles for the frame.
    t1 = DTriangle((1, 2, 4))
    t2 = DTriangle((3, 4, 2))
    dt.triangles[t1] = [t2, DTriangle(), DTriangle()]
    dt.triangles[t2] = [t1, DTriangle(), DTriangle()]

    # Compute circumcenters and circumradius for each triangle.
    for t in keys(dt.triangles)
        ai, bi, ci = t.nodes
        a, b, c = dt.nodes[ai], dt.nodes[bi], dt.nodes[ci]
        dt.circles[t] = Circle(Triangle([a, b, c]))
    end

    return dt
end

"""
    fast_delaunay_condition(c::Circle, x::Float64, y::Float64)

Given a `Circle` return `false` if `(x, y)` is inside and `true` otherwise.
"""
function fast_delaunay_condition(c::Circle, x::Float64, y::Float64)
    center, radius = ccr(c)
    xc, yc = nodexy(center)
    return (xc - x)^2  + (yc - y)^2 >= abs2(radius)
end

"Add a `Node` to provided `Delaunay2D` and refine it using Bowyer-Watson."
function add_point_bw!(p::Node, dt::Delaunay2D)
    x, y = nodexy(p)
    push!(dt.nodes, p)
    idx = length(dt.nodes)

    # Search the `DTriangle`s whose circumcircle contains `Node` `p`.
    bad_triangles = []
    for t in keys(dt.triangles)
        circle = dt.circles[t]
        if !fast_delaunay_condition(circle, x, y)
            push!(bad_triangles, t)
        end
    end

    # Find the CCW boundary (star shape) of the bad triangles,
    # expressed as the *opposite* triangle to current `Node` and
    # a list of `Node`s (point pair) that form this triangle and
    # are adjacent to the current `Node`.
    boundary = []
    t = bad_triangles[1]
    node = 1
    # Get the opposite triangle of this `Node`.
    while true
        # Check if the opposite edge of current `Node`
        # of triangle `t` is on the boundary,
        # i.e. if opposite triangle of this `Node`
        # is external to the list.
        tri_op = dt.triangles[t][node]
        if tri_op ∉ bad_triangles
            # Insert edge and external triangle into boundary list.
            push!(boundary, (t[mod(node, 3) + 1], t[mod(node - 2, 3) + 1], tri_op))

            # Move to the next CCW `Node` in this triangle.
            node = mod(node, 3) + 1

            # Check if boundary is a closed loop.
            if boundary[1][1] == boundary[end][2]
                break
            end
        
        else
            # Move to next CCW `Node` in the opposite triangle.
            node = mod(findfirst(==(t), dt.triangles[tri_op]), 3) + 1
            t = tri_op
        end
    end

    # Remove triangles that are too close to the point p from our solution.
    for t in bad_triangles
        pop!(dt.triangles, t)
        pop!(dt.circles,   t)
    end

    # Retriangulate the hole left by bad_triangles.
    new_triangles = []
    for (e1, e2, tri_op) in boundary
        # Create a new triangle using point p and points of the edge.
        t = DTriangle((idx, e1, e2))

        # Store circumcenter and circumradius of the triangle.
        a, b, c = dt.nodes[idx], dt.nodes[e1], dt.nodes[e2]
        dt.circles[t] = Circle(Triangle([a, b, c]))

        # Set the opposite triangle of the edge as neighbour of `t`.
        dt.triangles[t] = [tri_op, DTriangle(), DTriangle()]

        # Try to set `t` as neighbour of the opposite triangle.
        if tri_op != DTriangle((0, 0, 0))
            # Search the neighbour of `tri_op` that uses the edge `(e2, e1)`.
            for (i, neigh) in enumerate(dt.triangles[tri_op])
                nnodes = neigh.nodes
                if neigh != DTriangle((0, 0, 0)) && e2 in nnodes && e1 in nnodes
                    # Change link to that of our new triangle.
                    dt.triangles[tri_op][i] = t
                end
            end
        end

        # Add triangle to a temporal list.
        push!(new_triangles, t)
    end

    # Link new triangles with one another.
    n = length(new_triangles)
    for (i, t) in enumerate(new_triangles)
        dt.triangles[t][2] = new_triangles[mod(i,     n) + 1]
        dt.triangles[t][3] = new_triangles[mod(i - 2, n) + 1]
    end

    return dt
end
