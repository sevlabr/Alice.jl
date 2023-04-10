using Alice
using BenchmarkTools

function generate_cyl_points_benchmarks(
    title=" generate_cyl_points benchmarks "
)
    bench_suite = BenchmarkGroup()

    bench_suite["generate_cyl_points"] = BenchmarkGroup([
        "points generator for cylinder problem", "10 - 1_000_000 points"
    ])

    for size in [10^x for x in 2:6]
        bench_suite["generate_cyl_points"][string(size)] = @benchmarkable generate_cyl_points(100, $size, 100, verbose=false)
    end

    tune!(bench_suite)
    return run(bench_suite, verbose=true), title
end
