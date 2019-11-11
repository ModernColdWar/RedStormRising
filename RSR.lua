--- Red Storm Rising DCS mission LUA code
-- stub DCS if we're running outside
if env == nil then
    require("dcs_stub")
else
    local module_folder = lfs.writedir() .. [[Scripts\RSR\]]
    package.path = module_folder .. "?.lua;" .. package.path
end

env.info("RSR starting")

if mist == nil then
    require("mist_4_3_74")
end

if ctld == nil then
    -- if not nil, we're in the "old" RSR mission setup
    require("CTLD")
    require("CTLDconfig")
end

log = mist.Logger:new("RSR", "info")

require("RSRconfig")
require("handleMarkEvents")
require("persistence")

if rsr.devMode then
    log:warn("Running in developer mode - should not be used for 'real' servers")
end

env.info("RSR ready")
