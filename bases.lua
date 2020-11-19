env.info("RSR STARTUP: bases.LUA INIT")
local logging = require("logging")
local logisticsManager = require("logisticsManager")
local pickupZoneManager = require("pickupZoneManager")
local slotBlocker = require("slotBlocker")
local updateSpawnQueue = require("updateSpawnQueue")
local utils = require("utils")

local M = {}
M.mapMarkers = {}

local log = logging.Logger:new("bases")

local function getRadius(rsrConfig, base)
    if base:GetAirbaseCategory() == Airbase.Category.AIRDROME then
        return rsrConfig.baseDefenceActivationRadiusAirbase
    elseif base:GetAirbaseCategory() == Airbase.Category.HELIPAD then
        return rsrConfig.baseDefenceActivationRadiusFARP
    end
    return 0
end

local function activateBaseDefences(baseName, sideName, rsrConfig, missionInit, campaignStartSetup)
    log:info("Activating base defences. missionInit: $1, Add to spawnQueue (campaignStartSetup): $2 ", missionInit, campaignStartSetup)
    local base = AIRBASE:FindByName(baseName)
    local radius = getRadius(rsrConfig, base)
    log:info("Activating base defences for $1 base $2 within $3m", sideName, baseName, radius)
    local activationZone = ZONE_AIRBASE:New(baseName, radius)
    local allBaseDefencesGroups = SET_GROUP:New()
                                           :FilterCategories("ground")
                                           :FilterActive(false)
                                           :FilterCoalitions(sideName)
                                           :FilterOnce()

    allBaseDefencesGroups:ForEachGroup(function(group)
        -- check we have a unit in the group to avoid nil when we call group:GetVec3()
        if group:GetUnit(1) then
            -- we can't use any of the GROUP:InZone methods as these are late activated units
            if activationZone:IsVec3InZone(group:GetVec3()) then
                local groupName = group:GetName() --MOOSE
                -- assumes group name prefix includes base name for base defences
                local _baseOriginForGroup = string.match(groupName, ("^%w+"))
                local _groupMatchesBase = utils.matchesBaseName(baseName, _baseOriginForGroup)

                -- log:info("groupName: $1 _baseOriginForGroup: $2, _groupMatchesBase: $3, baseName: $4", groupName, _baseOriginForGroup, _groupMatchesBase, baseName)
                if _groupMatchesBase then
                    log:info("Activating $1 $2 base defence group $3", baseName, sideName, groupName)
                    group:Activate()

                    --[[
                        campaignStartSetup == true, missionInit = true:
                            add base defences to spawn queue (persistent unit list) at campaign start and mission start as not yet added
                        campaignStartSetup == true, missionInit = false:
                            add base defences to spawn queue (persistent unit list) as mission progresses after campaign setup
                        campaignStartSetup == false, missionInit = true:
                            do NOT add base defences to spawn queue (persistent unit list) at mission start as already present in rsrState.json
                        campaignStartSetup == false, missionInit = false:
                            add base defences to spawn queue (persistent unit list) as mission progresses
                    --]]
					
					-- disabled addition of base defences to persistence data until RESUPPLY SYSTEM developed
					-- adds late activated groups to spawn queue = persistence data
					--[[
                    if campaignStartSetup or not missionInit then
                        updateSpawnQueue.pushSpawnQueue(groupName) 
                    end
					--]]
					
                    utils.setGroupControllerOptions(group:GetDCSObject())

                    if ctld.isJTACUnitType(group:GetTypeName()) then
                        timer.scheduleFunction(function(_groupName)
                            -- do this 2 seconds later so that group has time to be activated
                            local _code = ctld.getLaserCode(Group.getByName(_groupName):getCoalition())
                            log:info("Configuring base defences group $1 to auto-lase on $2", _groupName, _code)
                            ctld.JTACAutoLase(_groupName, _code)
                        end, groupName, timer.getTime() + 2)
                    end

                    if string.match(groupName, "1L13 EWR") then
                        log:info("Configuring group $1 as EWR", groupName)
                        ctld.addEWRTask(group)
                    end
                else
                    --mr: add to validateMissionFile.lua type check for mission editors?
                    log:warn("Group ($1) found within $2m of airbase/FARP ($3) not activated due to base origin ($4) mismatch!", groupName, radius, baseName, _baseOriginForGroup)
                end
            end
        else
            log:warn("Could not find first unit in group $1", group:GetName())
        end
    end)
end

local function checkNeutral(baseName, sideName)
    if sideName == "neutral" then
        log:info("Nothing to do for neutral base $1", baseName)
        return true
    end
    return false
end

local function setMapMarker(baseName, sideName)
    local base = AIRBASE:FindByName(baseName)
    local markText = baseName .. " (" .. string.upper(sideName) .. ")"
    local existingMarkId = M.mapMarkers[baseName]
    if existingMarkId ~= nil then
        trigger.action.removeMark(existingMarkId)
    end
    M.mapMarkers[baseName] = COORDINATE:NewFromVec2(base:GetVec2()):MarkToAll(markText, true)
end

function M.configureForSide(baseName, sideName)
    log:info("Configuring base $1 for $2", baseName, sideName)
    setMapMarker(baseName, sideName)

    --[[
        commented-out as any neutral ownership of a FARP or neutral airbase (due to logistics centre destruction)
        should result in slots blocked and pickup zone blocked
        capturable airbases will always either be red/blue so abort will never occur
        remnant abort from when baseCaptureEH was sole determinant whereas now baseOwnershipCheck pre-determines capture logic
    --]]
    --[[
    if checkNeutral(baseName, sideName) then
        log:info("Aborting slot blocking and pickup zone blocking for $1", baseName)
        return
    end
    --]]
    slotBlocker.configureSlotsForBase(baseName, sideName)
    pickupZoneManager.configurePickupZonesForBase(baseName, sideName)
end

function M.resupply(baseName, sideName, rsrConfig, spawnLC, missionInit, campaignStartSetup)
    log:info("RESUPPLY: baseName: $1, sideName: $2, missionInit: $3, campaignStartSetup: $4", baseName, sideName, missionInit, campaignStartSetup)
    log:info("Configuring $1 resupplied by $2", baseName, sideName)
    if checkNeutral(baseName, sideName) then
        return
    end
    activateBaseDefences(baseName, sideName, rsrConfig, missionInit, campaignStartSetup)
    if spawnLC then
        log:info("PRE-logisticsManager: baseName $1 sideName $2", baseName, sideName)
        --(baseName, sideName, logisticsCentreName, isMissionInit, constructingPlayerName)
        logisticsManager.spawnLogisticsBuildingForBase(baseName, sideName, "none", missionInit, "none")
    end
end

function M.onMissionStart(baseName, sideName, rsrConfig, missionInitSetup, campaignStartSetup)
    log:info("Configuring $1 as $2 at mission start", baseName, sideName)
    M.configureForSide(baseName, sideName)
    if checkNeutral(baseName, sideName) then
        log:info("Checking if $1 (owner: $2) is neutral at mission start", baseName, sideName)
        return -- do not setup base if neutral
    end
    if missionInitSetup then
        log:info("First time setup - resupplying")
        M.resupply(baseName, sideName, rsrConfig, true, true, campaignStartSetup)
    else
        log:info("Not first time setup - not doing any base resupply; only logistics")
        logisticsManager.spawnLogisticsBuildingForBase(baseName, sideName, "none", true, "none")
    end
end
env.info("RSR STARTUP: bases.LUA LOADED")
return M