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
SETTINGS:SetPlayerMenuOff()

local log = mist.Logger:new("RSR", "info")

local rsrConfig = require("RSR_config")
if rsrConfig.devMode then
    log:warn("Running in developer mode - should not be used for 'real' servers")
    ctld.debug = true
end

local utils = require("utils")
local handleMarkEvents = require("handleMarkEvents")
local persistence = require("persistence")

if utils.runningInDcs() then
    -- set up simple slot block (moved from mission trigger)
    trigger.action.setUserFlag("SSB", 100)
    handleMarkEvents.registerHandlers(rsrConfig.devMode)
    persistence.restore(rsrConfig)
    trigger.action.outText("RSR ready", 10)
end

log:info("RSR ready")
