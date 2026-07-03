return {
    noctalia = {type = "default", name = "noctalia-git"},
    litterbox = {type = "source", name = "litterbox", url = "https://github.com/Gerharddc/litterbox", builder = {
        program = "cargo",
        args = {"install","--path",".","--root","/usr"}
    }},
    ["helium-browser"] = {type = "default", name = "helium-browser-bin"}
}
