module Alice

include("geometry/utils.jl")
include("geometry/Mesh.jl")

export
    # Delaunay
    Node, Triangle, Circle, DTriangle, Delaunay2D,

    matrix_to_nodes, export_nodes,

    simple_delaunay_condition, robust_delaunay_condition,
    fast_delaunay_condition,
    isinside,

    dtinit,

    simple_delaunay,

    export_triangles, export_circles, export_dt, export_extended_dt,
    export_voronoi_regions,


    # Mesh
    generate_cyl_points

end # module Alice
