require("mist_4_3_74")
local logisticsManager = require("logisticsManager")
local pickupZoneManager = require("pickupZoneManager")
local slotBlocker = require("slotBlocker")
local state = require("state")
local utils = require("utils")

local M = {}
M.mapMarkers = {}

local log = mist.Logger:new("Utils", "info")

local allLateActivatedGroundGroups = SET_GROUP:New()
                                              :FilterCategories("ground")
                                              :FilterActive(false)
                                              :FilterOnce()

local function getRadius(rsrConfig, base)
    if base:GetAirbaseCategory() == Airbase.Category.AIRDROME then
        return rsrConfig.baseDefenceActivationRadiusAirbase
    elseif base:GetAirbaseCategory() == Airbase.Category.HELIPAD then
        return rsrConfig.baseDefenceActivationRadiusFarp
    end
    return 0
end

local function isReplacementGroup(group)
    return string.find(group:GetName():lower(), "replacement")
end

local function activateBaseDefences(baseName, sideName, rsrConfig)
    local base = AIRBASE:FindByName(baseName)
    local side = utils.getSide(sideName)
    local radius = getRadius(rsrConfig, base)
    log:info("Activating base defences for $1 base $2 within $3m", sideName, baseName, radius)
    local activationZone = ZONE_AIRBASE:New(baseName, radius)
    allLateActivatedGroundGroups:ForEachGroup(function(group)
        -- we can't use any of the GROUP:InZone methods as these are late activated units
        if group:GetCoalition() == side and activationZone:IsVec3InZone(group:GetVec3()) and not isReplacementGroup(group) then
            log:info("Activating $1 $2 base defence group $3", baseName, sideName, group:GetName())
            group:Activate()
            state.pushSpawnQueue(group:GetName())
            utils.setGroupControllerOptions(group:GetDCSObject())
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

function M.resupply(baseName, sideName, rsrConfig)
    log:info("Configuring $1 resupplied by $2", baseName, sideName)
    if checkNeutral(baseName, sideName) then
        return
    end
    activateBaseDefences(baseName, sideName, rsrConfig)
    logisticsManager.spawnLogisticsBuildingForBase(baseName, sideName)
end

function M.onMissionStart(baseName, sideName, rsrConfig, firstTimeSetup)
    log:info("Configuring $1 as $2 at mission start", baseName, sideName)
    M.configureForSide(baseName, sideName)
    if checkNeutral(baseName, sideName) then
        return
    end
    if firstTimeSetup then
        log:info("First time setup - resupplying")
        M.resupply(baseName, sideName, rsrConfig)
    else
        log:info("Not first time setup - not doing any base resupply; only logistics")
        logisticsManager.spawnLogisticsBuildingForBase(baseName, sideName)
    end
end

return M