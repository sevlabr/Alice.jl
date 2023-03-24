module Alice

include("geometry/utils.jl")

export
    Node, Triangle,

    simple_delaunay_condition, robust_delaunay_condition,
    isinside

end # module Alice
