env.info("RSR STARTUP: bases.LUA INIT")
require("mist_4_3_74")
local logisticsManager = require("logisticsManager")
local pickupZoneManager = require("pickupZoneManager")
local slotBlocker = require("slotBlocker")
local updateSpawnQueue = require("updateSpawnQueue")
local utils = require("utils")
local rsrConfig = require("RSR_config")

local M = {}
M.mapMarkers = {}

local log = mist.Logger:new("bases", "info")

local allLateActivatedGroundGroups = SET_GROUP:New()
                                              :FilterCategories("ground")
                                              :FilterActive(false)
                                              :FilterOnce()

local function getRadius(rsrConfig, base)
    if base:GetAirbaseCategory() == Airbase.Category.AIRDROME then
        return rsrConfig.baseDefenceActivationRadiusAirbase
    elseif base:GetAirbaseCategory() == Airbase.Category.HELIPAD then
        return rsrConfig.baseDefenceActivationRadiusFARP
    end
    return 0
end

local function isReplacementGroup(group)
    return string.find(group:GetName():lower(), "replacement")
end

local function activateBaseDefences(baseName, sideName, rsrConfig, missionInit, campaignStartSetup)
	log:info("Activating base defences. missionInit = $1, Add to spawnQueue = $2 (campaignStartSetup)",missionInit,campaignStartSetup)
    local base = AIRBASE:FindByName(baseName)
    local side = utils.getSide(sideName)
    local radius = getRadius(rsrConfig, base)
    log:info("Activating base defences for $1 base $2 within $3m", sideName, baseName, radius)
    local activationZone = ZONE_AIRBASE:New(baseName, radius)
    allLateActivatedGroundGroups:ForEachGroup(function(group)
        -- we can't use any of the GROUP:InZone methods as these are late activated units
        if group:GetCoalition() == side and activationZone:IsVec3InZone(group:GetVec3()) and not isReplacementGroup(group) then
            local _groupName = group:GetName() --MOOSE
			
			log:info("Activating $1 $2 base defence group $3", baseName, sideName, _groupName)
            group:Activate()
			--[[
				campaignStartSetup == true, missionInit = true:
					add base defences to spawn queue (persistent unit list) at campaign start as not yet added
				campaignStartSetup == true, missionInit = false:	
					add base defences to spawn queue (persistent unit list) as mission progresses after campaign setup
				campaignStartSetup == false, missionInit = true:
					do NOT add base defences to spawn queue (persistent unit list) as already present in rsrState.json
				campaignStartSetup == false, missionInit = false:
					add base defences to spawn queue (persistent unit list) as mission progresses
			--]]
			if campaignStartSetup or not missionInit then
				updateSpawnQueue.pushSpawnQueue(_groupName)
			end
			
			if ctld.isJTACUnitType(_groupName) then
				local _code = ctld.getLaserCode(Group.getByName(_groupName):getCoalition())
				log:info("Configuring group $1 to auto-lase on $2", _groupName, _code)
				ctld.JTACAutoLase(_groupName, _code)
			end

			if string.match(_groupName, "1L13 EWR") then
				log:info("Configuring group $1 as EWR", _groupName)
				ctld.addEWRTask(group)
			end
			
			
            utils.setGroupControllerOptions(group)
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
    if checkNeutral(baseName, sideName) then
        return
    end
    slotBlocker.configureSlotsForBase(baseName, sideName)
    pickupZoneManager.configurePickupZonesForBase(baseName, sideName)
end

function M.resupply(baseName, sideName, rsrConfig, spawnLC, missionInit, campaignStartSetup)
	log:info("RESUPPLY: baseName: $1, sideName: $2, missionInit: $3, campaignStartSetup: $4", baseName, sideName, mist.utils.basicSerialize(missionInit), mist.utils.basicSerialize(campaignStartSetup))
    log:info("Configuring $1 resupplied by $2", baseName, sideName)
    if checkNeutral(baseName, sideName) then
        return
    end
    activateBaseDefences(baseName, sideName, rsrConfig, missionInit, campaignStartSetup)
	if spawnLC then 
		log:info("PRE-logisticsManager: baseName $1 sideName $2", baseName, sideName)
		--(baseName, sideName, logisticsCentreName, isMissionInit, constructingPlayerName)
		logisticsManager.spawnLogisticsBuildingForBase(baseName, sideName,"none", missionInit,"none")
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
        logisticsManager.spawnLogisticsBuildingForBase(baseName, sideName,"none",true,"none")
    end
end
env.info("RSR STARTUP: bases.LUA LOADED")
return M