local proc = require("@lune/process")
local fs = require("@lune/fs")
local package_mappings = require("../pkgmap/arch.luau")

local packageManager = {}
local installed_repos = {}

function packageManager.setup(global_repos: {[string]: {[number]:string}})
    local repos = global_repos.arch
    local reposFile = fs.readFile("/etc/pacman.conf")
    for _, repo in repos do
        if repo == "@chaotic" then
            local res = proc.exec("/tmp/scripts/chaotic-setup")
            assert(res.ok==true,"failed to establish chaotic aur keys, tag @chaotic used.")
            local chaotic_tag = [[

            [chaotic-aur]
            Include = /etc/pacman.d/chaotic-mirrorlist
            ]]
            fs.writeFile("/etc/pacman.conf", reposFile..chaotic_tag)
            table.insert(installed_repos,"chaotic-aur")
            reposFile = fs.readFile("/etc/pacman.conf")
            continue
        end
        --TODO: convert mirror target urls into proper pacman repo targets.
    end
    local res = proc.exec("/tmp/scripts/builduser-setup", {"mk"})
    assert(res.ok==true,"failed to establish a build user for AUR packages.")
    fs.writeDir("/tmp/git")
end

function packageManager.cleanup()
    for _, repo in installed_repos do
        local res = proc.exec("sed", {"-i", "\"'/\["..repo.."\]/,/^$/d'\"","/etc/pacman.conf"})
        assert(res.ok==true,"failed to cleanup repository \""..tostring(repo).."\" from pacman.conf!")
    end
    local res = proc.exec("/tmp/scripts/builduser-setup", {"rm"})
    assert(res.ok==true,"failed to remove the build user.")
end

function packageManager.pull(package_name: string): {type: string, name: string, [string]: any?}
    local package = package_mappings[package_name]
    if package == nil then
        package = {type = "default", name = package_name}
    end

    return package
end

function packageManager.install(package)
    if package.type == "aur" then
        print(package.name.." is a AUR package, please check the MAKEPKG file if possible!")

        local pull = proc.exec("git",{"clone",tostring(package.url),"/tmp/git/"..tostring(package.name)})
        assert(pull.ok==true,"git clone failure, problem occured.")
        local control = proc.exec("chown",{"-R","oci-build",":","oci-build"},{
            cwd = "/tmp/git/"..tostring(package.name)
        })
        assert(control.ok==true,"failed to attach builder to cloned repository.")
        local res = proc.exec("runuser",{"-u","oci-build","--","makepkg","-si","--noconfirm"},{
            cwd = "/tmp/git/"..tostring(package.name)
        })
        assert(res.ok==true,"failed to install "..tostring(package.name).." a error occured.")
    elseif package.type == "source" then
        assert(package.builder~=nil,"builder context required.")
        assert(package.builder.program~=nil,"builder program required.")
        assert(package.builder.args~=nil,"builder arguments required.")

        print(package.name.." is being pulled from source! check the origin url here: "..tostring(package.url))

        local pull = proc.exec("git",{"clone",tostring(package.url),"/tmp/git/"..tostring(package.name)})
        assert(pull.ok==true,"git clone failure, problem occured.")
        local res = proc.exec(package.builder.program,package.builder.args,{
            cwd = "/tmp/git/"..tostring(package.name)
        })
        assert(res.ok==true,"failed to install "..tostring(package.name).." a error occured.")
    elseif package.type == "default" then
        local res = proc.exec("pacman",{"-S","--noconfirm",tostring(package.name)})
        assert(res.ok==true,"failed to install "..tostring(package.name).." a error occured.")
    end
end

table.freeze(packageManager)
return packageManager
