using Documenter
using GroupTools

makedocs(
    modules=[GroupTools],
    doctest=true,
    sitename="GroupTools.jl",
    format=Documenter.HTML(prettyurls=!("local" in ARGS)),
    authors="Kyungmin Lee",
    checkdocs=:all,
    pages = [
      "Home" => "index.md",
    ]
  )

deploydocs(repo="github.com/kyungminlee/GroupTools.jl.git", devbranch = "dev")
