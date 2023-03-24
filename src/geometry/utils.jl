using LinearAlgebra: det

"Vertex of a `Triangle`."
struct Node
    x::Float64
    y::Float64
end

"Get `x` and `y` of a given `Node`."
function nodexy(n::Node)
    [n.x, n.y]
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


"`Triangle` and 3 adjacent `Triangle`s."
struct MeshNode
    focus::Triangle
    triangles::Vector{Triangle}
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

    a = det([x1 y1 1; x2 y2 1; x3 y3 1])
    sa = sign(a)
    b = det([x1^2 + y1^2 y1  1; x2^2 + y2^2 y2  1; x3^2 + y3^2 y3  1])
    c = det([x1^2 + y1^2 x1  1; x2^2 + y2^2 x2  1; x3^2 + y3^2 x3  1])
    d = det([x1^2 + y1^2 x1 y1; x2^2 + y2^2 x2 y2; x3^2 + y3^2 x3 y3])

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
