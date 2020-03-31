require("mist_4_3_74")
local utils = require("utils")
local inspect = require("inspect")
local rsrConfig = require("RSR_config")

local M = {}

local log = mist.Logger:new("SlotBlocker", "info")

M.clientSet = SET_CLIENT:New()
                        :FilterActive(false)
                        :FilterOnce()

local function disableSlot(groupName)
    --log:info("Disabling $1", groupName)
    trigger.action.setUserFlag(groupName, 1)
end

local function enableSlot(groupName)
    --log:info("Enabling $1", groupName)
    trigger.action.setUserFlag(groupName, 0)
end

local function blockAllSlots()
    log:info("Blocking all slots")
    M.clientSet:ForEach(function(client)
        -- note that we pass unit names here while slot blocker uses group names - make sure they're the same!
		local _disableSlot = true
        if utils.startswith(client.ClientName, "Carrier") then
            log:info("Not blocking carrier slot '$1'", client.ClientName)
			_disableSlot = false
        else
			-- rsrConfig.stagingBases = { "RedStagingPoint", "BlueStagingPoint" } = Gas Platforms
			for _k, stagingBase in ipairs(rsrConfig.stagingBases) do
				if utils.startswith(client.ClientName, stagingBase) then
					_disableSlot = false
					log:info("Not blocking staging base slot '$1'", client.ClientName)
				end
			end
		end

		if _disableSlot then
            disableSlot(client.ClientName)
        end
    end)
end

function M.onMissionStart()
    -- enable simple slot block script
    trigger.action.setUserFlag("SSB", 100)
    blockAllSlots()
end

function M.configureSlotsForBase(baseName, sideName)
    log:info("Configuring slots for $1 as owned by $2", baseName, sideName)
    M.clientSet:ForEach(function(client)
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