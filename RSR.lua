--- Red Storm Rising DCS mission LUA code
-- stub DCS if we're running outside
if env == nil then
    require("dcs_stub")
else
    local module_folder = lfs.writedir() .. [[Scripts\RSR\]]
    package.path = module_folder .. "?.lua;" .. package.path
end

env.info("RSR starting")

require("mist_4_3_74")
require("CTLD")

log = mist.Logger:new("RSR", "info")

require("RSRconfig")
require("handleMarkEvents")
require("persistence")

if rsr.devMode then
    log:warn("Running in developer mode - should not be used for 'real' servers")
end

-- set up simple slot block (moved from mission trigger)
trigger.action.setUserFlag("SSB",100)

env.info("RSR ready")
