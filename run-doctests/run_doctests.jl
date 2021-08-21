if ENV["GITHUB_EVENT_NAME"] != "pull_request"
    error("""
    `julia-doctest` can only be run on pull requests! Use
    ```
    on: [pull_request]
    ```
    to only trigger your workflow on pull requests.
    """)
end

using Pkg
Pkg.develop(PackageSpec(path=pwd()))
Pkg.instantiate()

try
    using Documenter
catch e
    rethrow(ErrorException("Documenter.jl was not found in the `docs` environment."))
end

MyPkg = Symbol(ENV["INPUT_PACKAGE"])
@info "Package name: $(MyPkg)"
@eval begin
    using $(MyPkg)
    DocMeta.setdocmeta!($(MyPkg), :DocTestSetup, :(using $MyPkg); recursive=true)
    doctest($(MyPkg); fix=true)
end
