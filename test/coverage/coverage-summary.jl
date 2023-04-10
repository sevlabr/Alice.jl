using Coverage

cd(joinpath(@__DIR__, "..", "..")) do
    processed = process_folder()
    # (Doesn't work. Maybe because of private repo. Check later when repo is public.)
    # Codecov.submit_local(processed)
    covered_lines, total_lines = get_summary(processed)
    percentage = covered_lines / total_lines * 100
    println("($(percentage)%) covered")
end
