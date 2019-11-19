require("mist_4_3_74")
local utils = require("utils")

local M = {}

local log = mist.Logger:new("SlotBlocker", "info")

local clientSet = nil

-- do this lazily so we can run tests outside DCS
function M.initClientSet()
    clientSet = SET_CLIENT:New()
                          :FilterActive(false)
                          :FilterOnce()
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
    clientSet:ForEach(function(client)
        local groupName = client.ClientName -- not actually true - this is the unit name (they must be the same!)
        local groupBaseName, groupSideName = utils.getBaseAndSideNamesFromGroupName(groupName)
        if groupBaseName ~= nil and groupSideName ~= nil then
            if utils.matchesBaseName(baseName, groupBaseName) then
                if groupSideName == sideName then
                    enableSlot(groupName)
                else
                    disableSlot(groupName)
                end
            end
        end
    end)
end

return M