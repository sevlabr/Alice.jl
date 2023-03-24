using Documenter, Alice

DocMeta.setdocmeta!(Alice, :DocTestSetup, :(using Alice); recursive=true)

makedocs(
    sitename="Alice.jl",
    modules=[Alice],
    strict=:doctest,
)
