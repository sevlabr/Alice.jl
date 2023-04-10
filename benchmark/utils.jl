"Helper function to run benchmarks and show results."
function run_benchmark_suites(bfs::Vector{F} where F <: Function)
    for bf in bfs
        println("\nRunning benchmark...\n")
        results, title = bf()
        println("\n", "-"^20, title, "-"^20, "\n")

        for (bg, cases) in results
            if bg == "title"
                continue
            end
            println("\n", "-"^10, bg, "-"^10, "\n")
            for (name, trial) in cases
                println("\n", "-"^5, name, "-"^5, "\n")
                display(trial)
                println()
            end
        end

        println("\nFinished benchmark.\n")
    end
end
