using Documenter, RemoteSemaphores

makedocs(;
    modules=[RemoteSemaphores],
    format=:html,
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/invenia/RemoteSemaphores.jl/blob/{commit}{path}#L{line}",
    sitename="RemoteSemaphores.jl",
    authors="Invenia Technical Computing Corporation",
    assets=[
        "assets/invenia.css",
        "assets/logo.png",
    ],
)

deploydocs(;
    repo="github.com/invenia/RemoteSemaphores.jl",
    target="build",
    julia="0.6",
    deps=nothing,
    make=nothing,
)
