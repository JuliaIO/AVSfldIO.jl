# push!(LOAD_PATH,"../src/")

using AVSfldIO
using Documenter

DocMeta.setdocmeta!(AVSfldIO, :DocTestSetup, :(using AVSfldIO); recursive=true)

makedocs(;
    modules = [AVSfldIO],
    authors = "Jeff Fessler <fessler@umich.edu> and contributors",
    repo = "https://github.com/JeffFessler/AVSfldIO.jl/blob/{commit}{path}#{line}",
    sitename = "AVSfldIO.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
#       canonical = "https://JeffFessler.github.io/AVSfldIO.jl/stable",
#       assets = String[],
    ),
    pages = [
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo = "github.com/JeffFessler/AVSfldIO.jl.git",
    devbranch = "main",
    devurl = "dev",
    versions = ["stable" => "v^", "dev" => "dev"],
    push_preview = true,
)
