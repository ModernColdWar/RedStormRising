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