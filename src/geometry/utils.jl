"Vertex of a `Triangle`."
struct Node
    x::Float64
    y::Float64
end

"3 vertices represent a `Triangle`."
struct Triangle
    nodes::Vector{Node}
end

"`Triangle` and 3 adjacent `Triangle`s."
struct MeshNode
    focus::Triangle
    triangles::Vector{Triangle}
end

"Get `x` and `y` of a given `Node`."
function nodexy(n::Node)
    [n.x, n.y]
end

"Get `Node`s of a given `Triangle`."
function tnodes(t::Triangle)
    t.nodes
end

"Return 3x2 matrix each row of which is `x` and `y` coordinates of a vertex."
function tvertices(t::Triangle)
    xys = zeros(Float64, 3, 2)
    for (idx, node) in enumerate(tnodes(t))
        xy = nodexy(node)
        xys[idx, :] = xy
    end
    return xys
end

"""
    _check_delaunay_condition(t::Triangle, x::Float64, y::Float64)

Check if a point is outside of a circumscribed circle or not.

Uses approach with calculating both sin and cos.
!!! note

    `x` and `y` must represent a point which is inside an angle
    with a vertex `(x2, y2)`.

!!! warning

    Points in `Triangle` must be given in a clockwise order!
"""
function _check_delaunay_condition(t::Triangle, x::Float64, y::Float64)
    (x1, x2, x3, y1, y2, y3) = tvertices(t)

    na = (x  - x1) * (y  - y3) - (x  - x3) * (y  - y1)
    sb = (x2 - x1) * (x2 - x3) + (y2 - y1) * (y2 - y3)
    sa = (x  - x1) * (x  - x3) + (y  - y1) * (y  - y3)
    nb = (x2 - x1) * (y2 - y3) - (x2 - x3) * (y2 - y1)

    return na * sb + sa * nb >= 0
end

"""
    check_delaunay_condition(t::Triangle, x::Float64, y::Float64)

Return `true` if a point is outside of a circumscribed circle and `false` otherwise.

Uses faster approach which sometimes reduses to calculating only cos.

!!! note

    `x` and `y` must represent a point which is inside an angle
    with a vertex `(x2, y2)`. Also it is preferable that this point is
    outside of a `Triangle` `t`.

!!! warning

    Points in `Triangle` must be given in a clockwise order!

# Examples
```jldoctest
julia> t = Triangle([Node(0, 0), Node(5, 5 * sqrt(3)), Node(10, 0)])
julia> check_delaunay_condition(t, 5.0, -1.0)
false

julia> check_delaunay_condition(t, 5.0, -10.0)
true
```
"""
function check_delaunay_condition(t::Triangle, x::Float64, y::Float64)
    (x1, x2, x3, y1, y2, y3) = tvertices(t)

    sa = (x  - x1) * (x  - x3) + (y  - y1) * (y  - y3)
    sb = (x2 - x1) * (x2 - x3) + (y2 - y1) * (y2 - y3)

    if sa < 0 && sb < 0
        return false
    elseif sa >= 0 && sb >= 0
        return true
    else
        return _check_delaunay_condition(t, x, y)
    end
end

#=
Make tests with it later:
tequilateral = Triangle([Node(0, 0), Node(5, 5 * sqrt(3)), Node(10, 0)])
x1, y1 = 3.0,  1.0   # f
x2, y2 = 3.0, -1.0   # f
x3, y3 = 2.0, -4.0   # t
x4, y4 = 8.0, -2.0   # f
x5, y5 = 9.0,  0.0   # f
x6, y6 = 9.0, -100.0 # t
x7, y7 = 3.5, -5.0   # t
tright = Triangle([Node(4, 0), Node(0, 0), Node(0, 3)])
x1, y1 = 3.0, 2.0 # f
x2, y2 = 4.0, 2.0 # f
x3, y3 = 4.0, 3.0 # t - lies exactly on the circle
x4, y4 = 4.0, 4.0 # t
x5, y5 = 1.0, 3.0 # f
x6, y6 = 1.0, 4.0 # t
# outside (x2, y2) angle but still works
x7, y7 = 2.0, -0.5 # f
x8, y8 = 0.5, 0.5 # f
x9, y9 = -0.1, 1.5 # f
x10, y10 = 2.0, -2.0 # t
x11, y11 = -1.0, 2.0 # t
x12, y12 = -1.0, -1.0 # t
x13, y13 = -1.0, 0.0 # t
x14, y14 = 0.0, -1.0 # t
=#

"""
    lies_inside(A::Node, B::Node, C::Node, D::Node)

Check if `D` is inside `∠ABC`.

!!! note

    Works if `∠ABC` is less than 180°.

!!! warning
    
    If `∠ABC` is 90° this code gives `NaN`s and does not work.
    And in general this code is unsafe because 0 division can occur.
"""
function lies_inside(A::Node, B::Node, C::Node, D::Node)
    ax, ay = nodexy(A)
    bx, by = nodexy(B)
    cx, cy = nodexy(C)
    dx, dy = nodexy(D)

    axcx, bxax, dxax = ax - cx, bx - ax, dx - ax
    cyay, byay, dyay = cy - ay, by - ay, dy - ay

    j = (dyay - byay * dxax / bxax) / (byay * axcx / bxax + cyay)
    i = (dxax + axcx * j) / bxax

    println(i, " ", j)

    if i > 0 && j > 0
        return true
    end
    return false
end

#=
Make tests with it later:
## sharp
a1, b1, c1 = Node(0, 0), Node(3, 1), Node(3, 0)
d1 = Node(4, 1) # t
d2 = Node(2, 1) # f
# rearrange b and c
a2, b2, c2 = Node(0, 0), Node(3, 0), Node(3, 1)
d3 = Node(4, 1) # t
d4 = Node(2, 1) # f
## blunt (more 180 deg)
a3, b3, c3 = Node(0, 0), Node(-3, -1), Node(1, 0)
d5 = Node(0, 1) # t -> f
d6 = Node(0, -1) # f -> t
## right
a4, b4, c4 = Node(0, 0), Node(0, 1), Node(1, 0)
d7 = Node(1, 1) # t (works only if c -> b, b -> c, so c should be above)
d8 = Node(2, -1) # f
d9 = Node(-1, -1) # f
d10 = Node(-1, 1) # f
## blunt (less 180 deg)
a5, b5, c5 = Node(0, 0), Node(-1, 1), Node(1, 0)
d11 = Node(-1, 2) # t
d12 = Node(2, 1) # t
d13 = Node(-2, 1) # f
d14 = Node(-2, 0) # f
d15 = Node(-1, -1) # f
=#
