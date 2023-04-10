using Alice
using BenchmarkTools
using Random: Xoshiro

function simple_delaunay_voronoi_benchmarks(
    title=" simple_delaunay and export_voronoi_regions benchmarks "
)
    rng = Xoshiro(42)
    bench_suite = BenchmarkGroup()

    bench_suite["simple_delaunay"] = BenchmarkGroup([
        "simple Delaunay", "10 - 3000 points"
    ])

    points = [3 3; -5 -2; 3 -5; 1 -4; 2 -2; -5 4; 1 -5; -2 -3; -4 -3; 3 1]
    pts10 = matrix_to_nodes(points)
    bench_suite["simple_delaunay"]["10"] = @benchmarkable simple_delaunay($pts10)

    pts_100_3000 = []
    for size in [100, 500, 1_000, 2_000, 3_000]
        ps = rand(rng, 2, size) .* size .* 100
        @assert length(unique(ps)) == 2 * size
        pts = matrix_to_nodes(transpose(ps))
        push!(pts_100_3000, (size, pts))
        bench_suite["simple_delaunay"][string(size)] = @benchmarkable simple_delaunay($pts)
    end

    bench_suite["export_voronoi_regions"] = BenchmarkGroup([
        "export Voronoi", "10 - 3000 points"
    ])

    dt = simple_delaunay(pts10)
    bench_suite["export_voronoi_regions"]["10"] = @benchmarkable export_voronoi_regions($dt)

    for (size, pts) in pts_100_3000
        dt = simple_delaunay(pts)
        bench_suite["export_voronoi_regions"][string(size)] = @benchmarkable export_voronoi_regions($dt)
    end

    tune!(bench_suite)
    return run(bench_suite, verbose=true), title
end
