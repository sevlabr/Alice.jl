include("utils.jl")
include("geometry/Delaunay.jl")
include("geometry/Mesh.jl")

benchmark_functions = [
    simple_delaunay_voronoi_benchmarks,
    generate_cyl_points_benchmarks,
]

run_benchmark_suites(benchmark_functions)
