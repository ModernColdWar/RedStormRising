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
require("Moose")

local log = mist.Logger:new("RSR", "info")

local rsrConfig = require("RSR_config")
if rsrConfig.devMode then
    log:warn("Running in developer mode - should not be used for 'real' servers")
    ctld.debug = true
end

local handleMarkEvents = require("handleMarkEvents")
local persistence = require("persistence")
local slotBlocker = require("slotBlocker")
local baseCapturedHandler = require("baseCapturedHandler")
local hitEventHandler = require("hitEventHandler")

slotBlocker.onMissionStart()
handleMarkEvents.registerHandlers(rsrConfig.devMode)
baseCapturedHandler.register()
hitEventHandler.register()
persistence.onMissionStart(rsrConfig)

_SETTINGS:SetPlayerMenuOff()
trigger.action.outText("RSR ready", 10)
log:info("RSR ready")
