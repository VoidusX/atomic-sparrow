local module = {}

function module.decode(contents: string): {[string]:any}
    local decodedTable = {}
    local lines = string.split(contents,"\n")
    for i=1, #lines do
        local pair = string.split(lines[i],"=")
        decodedTable[string.lower(pair[1])] = pair[2]
    end

    return decodedTable
end

function module.encode(contents: {[string]:any}): string
    local str = ""
    for key, value in pairs(contents) do
        str = str..str.upper(tostring(key)).."="..tostring(value).."\n"
    end
    return str
end

table.freeze(module)
return module
