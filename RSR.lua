--- Red Storm Rising DCS mission LUA code
-- stub DCS if we're running outside
if env == nil then
    require("tests.dcs_stub")
else
    local module_folder = lfs.writedir() .. [[Scripts\RSR\]]
    package.path = module_folder .. "?.lua;" .. package.path
end

env.info("RSR starting")

require("mist_4_3_74")
require("CTLD")
require("CSAR")
require("Moose")

local log = mist.Logger:new("RSR", "info")

local rsrConfig = require("RSR_config")
if rsrConfig.devMode then
    log:warn("Running in developer mode - should not be used for 'real' servers")
    ctld.debug = true
    ctld.buildTimeFOB = 5
    ctld.crateWaitTime = 1
end

local persistence = require("persistence")
local slotBlocker = require("slotBlocker")
local baseCapturedHandler = require("baseCapturedHandler")
local hitEventHandler = require("hitEventHandler")
local missionInfo = require("missionInfo")
local awacs = require("awacs")
require("weaponManager")

slotBlocker.onMissionStart()
baseCapturedHandler.register()
hitEventHandler.register(rsrConfig.hitMessageDelay)
persistence.onMissionStart(rsrConfig)
missionInfo.onMissionStart(rsrConfig)
awacs.onMissionStart(rsrConfig.awacsBases)

_SETTINGS:SetPlayerMenuOff()
trigger.action.outText("RSR ready", 10)
log:info("RSR ready")
