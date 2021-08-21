#####
##### Activate the right project (usually `docs`)
#####

using Pkg
project_path = get(ENV, "INPUT_PROJECT", "")
if isempty(project_path)
    project_path = mktempdir()
end
Pkg.activate(project_path)

#####
##### `dev` the package code into our project
#####

package_path = get(ENV, "INPUT_PACKAGE_PATH", "")
if isempty(package_path)
    package_path = pwd()
end

Pkg.develop(PackageSpec(path=package_path))
Pkg.instantiate()

#####
##### parse the package name out of its Project.toml
#####

try
    using TOML # stdlib on Julia v1.6+
catch
    @info "Adding TOML..."
    Pkg.add("TOML")
    using TOML
end

name_str = TOML.parsefile(joinpath(package_path, "Project.toml"))["name"]
name_sym = Symbol(name_str)
@info "Package name: $(name_sym)"

#####
##### Load Documenter
#####

try
    using Documenter
catch
    @warn("Documenter.jl was not found in the `$(project_path)` environment. Adding latest release...")
    Pkg.add("Documenter")
    using Documenter
end

#####
##### Run the doctests with `fix=true`
#####

@eval begin
    using $(name_sym)
    DocMeta.setdocmeta!($(name_sym), :DocTestSetup, :(using $name_sym); recursive=true)
    doctest($(name_sym); fix=true)
end

#####
##### Reset the docs Project + Manifest so that they don't show up in the diff
#####

run(`git checkout HEAD -- $(joinpath(package_path, "Project.toml"))`)
run(`git checkout HEAD -- $(joinpath(package_path, "Manifest.toml"))`)
