module Alice

include("geometry/utils.jl")

export
    Node, Triangle, Circle, DTriangle, Delaunay2D,

    matrix_to_nodes,

    simple_delaunay_condition, robust_delaunay_condition,
    fast_delaunay_condition,
    isinside,

    dtinit,

    simple_delaunay

end # module Alice
