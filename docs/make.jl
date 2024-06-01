# push!(LOAD_PATH,"../src/")

org, reps = :JuliaIO, :AVSfldIO
eval(:(using $reps))
import Documenter
#import Literate

base = "$org/$reps.jl"

repo = eval(:($reps))
Documenter.DocMeta.setdocmeta!(repo, :DocTestSetup, :(using $reps); recursive=true)


format = Documenter.HTML(;
    prettyurls = isci,
    edit_link = "main",
    canonical = "https://$org.github.io/$repo.jl/stable/",
    assets = ["assets/custom.css"],
)

Documenter.makedocs(;
    modules = [repo],
    authors = "Jeff Fessler and contributors",
    sitename = "$repo.jl",
    format,
    pages = [
        "Home" => "index.md",
        "Methods" => "methods.md",
    ],
)

if isci
    Documenter.deploydocs(;
        repo = "github.com/$base",
        devbranch = "main",
        devurl = "dev",
        versions = ["stable" => "v^", "dev" => "dev"],
        forcepush = true,
#       push_preview = true,
        # see https://$org.github.io/$repo.jl/previews/PR##
    )
end
