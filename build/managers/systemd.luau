local proc = require("@lune/process")
local systemManager = {}

function systemManager.cleanup()
    local res = proc.exec("systemd-tmpfiles",{"--clean"})
    if res.ok ~= true then
        error("systemd.cleanup() has errored! Action was non-zero result.",0)
    end
    return true
end

function systemManager.enable(services: {[number]: string})
    for _, service in services do
        if string.find(service,".service") ~= nil or string.find(service,".socket") ~= nil then
            local res = proc.exec("systemctl",{"enable",tostring(service)})
            if res.ok ~= true then
                error("service \""..tostring(service).."\" does not exist!",0)
            end
        elseif string.find(service,".service") == nil and string.find(service,".socket") == nil then
            error("Invalid syntax. Expected a socket or service, got: "..tostring(service),0)
        end
    end
end

table.freeze(systemManager)
return systemManager
