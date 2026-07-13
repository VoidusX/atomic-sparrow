local proc = require("@lune/process")
local fs = require("@lune/fs")
local stdio = require("@lune/stdio")
local repos = require("./repos.luau")
local packages = require("./packages.luau")
local serde_kv = require("./serde.kv.luau")

local env = proc.env
local distro = serde_kv.decode(fs.readFile("/etc/os-release"))
local distroType = distro.id
local systemd = require("./managers/systemd.luau")
local manager;

-- figure out the package manager of the system.
if distroType == "arch" then
    print("using pacman")
    manager = require("./managers/pacman.luau")
elseif distroType == "fedora" then
    print("using dnf")
    manager = require("./managers/dnf.luau")
end

local image_name = env.IMAGE_NAME
local image_tag = env.IMAGE_TAG

-- setup the repos on file.
manager.setup(repos)

local success = true;
for _, package in packages do
    local package_target = manager.pull(package) -- uses the proper name of the package of the given manager.
    local result = manager.install(package_target)

    if result == false then
        success = false
        break
    end
end

if success == false then
    stdio.ewrite("PM Fail! A Package could not be installed, Sparrow must terminate.")
    proc.exit(1)
end
-- removes repo traces on the system, that we added from the setup function.
manager.cleanup()

-- now manage the system after installing packages.
local dir = {}
dir.skel="/etc/skel"
dir.greetd = "/etc/greetd"
dir.assets="/imageAssets"
dir.shared="/usr/share"
dir.services="/etc/systemd/system"
dir.sparrow = dir.shared.."/sparrow"
dir.post_scripts = dir.sparrow.."/postscripts"
dir.etc = "/etc/sparrow"

fs.writeDir(dir.sparrow)
fs.copy(dir.assets.."/greetd.toml",dir.greetd.."/greetd.toml",{
    overwrite = true
})
fs.copy(dir.assets.."/greetd.session/session_registry.sh",dir.greetd.."/session.sh",{
    overwrite = true
})
proc.exec("chmod",{"+x",dir.greetd.."/session.sh"})

fs.writeDir(dir.post_scripts)
fs.copy(dir.assets.."/system.post/init.service",dir.services.."/sparrow-init.service")
fs.copy(dir.assets.."/system.post/init.sh",dir.post_scripts.."/init.sh")
proc.exec("chmod",{"+x",dir.post_scripts.."/init.sh"})

fs.writeDir(dir.etc)
fs.copy(dir.assets.."/flatpaks_list.toml",dir.sparrow.."/installation.flatpaks.toml")

systemd.cleanup() -- this cleans up temporary files
systemd.enable({
    "greetd.service",
    "sparrow-init.service",
    "podman.socket"
})
