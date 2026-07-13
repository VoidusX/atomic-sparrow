local proc = require("@lune/process")
local fs = require("@lune/fs")
local net = require("@lune/net")
local package_mappings = require("../pkgmap/fedora.luau")

local packageManager = {}
local installed_repos = {}

function packageManager.setup(global_repos: {[string]: {[number]:string}})
    local repos = global_repos.arch
    for _, repo in repos do
        local repoCache = string.split(repo,":")
        if repoCache[1] == "copr" then
            local res = proc.exec("dnf5",{"copr","enable",tostring(repoCache[2])})
            assert(res.ok==true,"failed to bind copr repository: "..tostring(repoCache[2]))
            table.insert(installed_repos,"copr:"..tostring(repoCache[2]))
        elseif repoCache[1] == "ext" then
            local url = "https://"..tostring(repoCache[3])
            local repoContents = net.request(url)
            assert(repoContents.ok==true,"request failed, got unexpected result. code: "..tostring(repoContents.statusCode))
            fs.writeFile("/etc/yum.repos.d/"..tostring(repoCache[2])..tostring(".repo"), repoContents.body)
            table.insert(installed_repos,"ext:"..tostring(repoCache[2]))
        end
    end
    fs.writeDir("/tmp/git")
end

function packageManager.cleanup()
    for _, repo in installed_repos do
        local repoCache = string.split(repo,":")
        if repoCache[1] == "copr" then
            local res = proc.exec("dnf5",{"copr","disable",tostring(repoCache[2])})
            assert(res.ok==true,"failed to unbind copr repository: "..tostring(repoCache[2]))
        elseif repoCache[1] == "ext" then
            fs.removeFile("/etc/yum.repos.d/"..tostring(repoCache[2])..tostring(".repo"))
        end
    end
end

function packageManager.pull(package_name: string): {type: string, name: string, [string]: any?}
    local package = package_mappings[package_name]
    if package == nil then
        package = {type = "default", name = package_name}
    end

    return package
end

function packageManager.install(package)
    if package.type == "source" then
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
        local res = proc.exec("dnf5",{"install","-y",tostring(package.name)})
        assert(res.ok==true,"failed to install "..tostring(package.name).." a error occured.")
    end
end

table.freeze(packageManager)
return packageManager
