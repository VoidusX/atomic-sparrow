return {
    noctalia = {type = "aur", name = "noctalia-git", url = "https://aur.archlinux.org/noctalia-git"},
    ["noctalia-greeter"] = {type = "aur", name = "noctalia-greeter-git", url = "https://aur.archlinux.org/noctalia-greeter-git"},
    litterbox = {type = "source", name = "litterbox", url = "https://github.com/Gerharddc/litterbox", builder = {
        program = "cargo",
        args = {"install","--path",".","--root","/usr"}
    }},
    ["helium-browser"] = {type = "default", name = "helium-browser-bin"}
}
