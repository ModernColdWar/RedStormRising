local logging = require("logging")
local missionUtils = require("missionUtils")
local rsrConfig = require("RSR_config")
local utils = require("utils")

local M = {}

-- These values must match what's in Hooks\RSRSlotBlocker.lua
M.slotEnabled = 1
M.slotDisabled = 99 -- see Hooks\RSRSlotBlocker.lua for the reason for this value

local log = logging.Logger:new("SlotBlocker", "info")

M.clientGroupNames = {}

missionUtils.iterGroups(env.mission, function(group)
    if missionUtils.isClientGroup(group) then
        local groupName = env.getValueDictByKey(group.name)
        table.insert(M.clientGroupNames, groupName)
    end
end)

local function disableSlot(groupName)
    log:info("Disabling group '$1'", groupName)
    trigger.action.setUserFlag(groupName, M.slotDisabled)
end

local function enableSlot(groupName)
    log:info("Enabling group '$1'", groupName)
    trigger.action.setUserFlag(groupName, M.slotEnabled)
end

local function blockAllSlots()
    log:info("Blocking all slots")
    for _, groupName in pairs(M.clientGroupNames) do
        local _disableSlot = true
        if utils.startswith(groupName, "Carrier") then
            log:info("Not blocking carrier group '$1'", groupName)
            _disableSlot = false
        else
            for _k, stagingBase in ipairs(rsrConfig.stagingBases) do
                if utils.startswith(groupName, stagingBase) then
                    _disableSlot = false
                    log:info("Not blocking staging base group '$1'", groupName)
                end
            end
        end

        if _disableSlot then
            disableSlot(groupName)
        end
    end
end

function M.onMissionStart()
    -- enable simple slot block script
    trigger.action.setUserFlag("SSB", 100)
    blockAllSlots()
end

function M.configureSlotsForBase(baseName, sideName)
    log:info("Configuring slots for $1 as owned by $2", baseName, sideName)
    for _, groupName in pairs(M.clientGroupNames) do
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
    end
end

return M