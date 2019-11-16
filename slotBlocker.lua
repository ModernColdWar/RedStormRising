require("mist_4_3_74")

local M = {}

local log = mist.Logger:new("SlotBlocker", "info")

local clientSet = nil

-- do this lazily so we can run tests outside DCS
function M.initClientSet()
    clientSet = SET_CLIENT:New()
                          :FilterActive(false)
                          :FilterOnce()
end

function M.getBaseAndSideNames(groupName)
    local baseName, sideName = string.match(groupName, "^(%S+)%s+(%S+)")
    return baseName, sideName:lower()
end

local function startswith(string, prefix)
    if string:sub(1, #prefix) == prefix then
        return true
    end
    return false
end

local function split(string, sep)
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    string:gsub(pattern, function(c)
        fields[#fields + 1] = c
    end)
    return fields
end

-- Matches a base name against a groupPrefix
-- is fairly generous in that you only need the distinguishing prefix on the group
-- with each word being treated independently
function M.matchesBaseName(baseName, groupPrefix)
    if groupPrefix == nil then
        return false
    end
    if startswith(baseName, groupPrefix) then
        return true
    end

    local baseNameParts = split(baseName, "-")
    local groupPrefixParts = split(groupPrefix, "-")

    if #baseNameParts < #groupPrefixParts then
        return false
    end
    for i = 1, #groupPrefixParts do
        local baseNamePart = baseNameParts[i]
        local groupPrefixPart = groupPrefixParts[i]
        if startswith(baseNamePart, groupPrefixPart) == false then
            return false
        end
    end
    return true
end

local function disableSlot(groupName)
    log:info("Disabling $1", groupName)
    trigger.action.setUserFlag(groupName, 1)
end

local function enableSlot(groupName)
    log:info("Enabling $1", groupName)
    trigger.action.setUserFlag(groupName, 0)
end

function M.blockAllSlots()
    log:info("Blocking all slots")
    clientSet:ForEach(function(client)
        disableSlot(client.ClientName)
    end)
end

function M.configureSlotsForBase(baseName, sideName)
    log:info("Configuring slots for $1 as owned by $2", baseName, sideName)

end

return M