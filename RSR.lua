--- Red Storm Rising DCS mission LUA code
-- stub DCS if we're running outside
if env == nil then
    dofile("dcs_stub.lua")
else
    local module_folder = lfs.writedir() .. [[Scripts\RSR\]]
    package.path = module_folder .. "?.lua;" .. package.path
end

env.info("RSR starting")

if mist == nil then
    dofile("mist_4_3_74.lua")
end

if ctld == nil then
    -- if not nil, we're in the "old" RSR mission setup
    dofile("CTLD.lua")
    dofile("CTLDconfig.lua")
end

log = mist.Logger:new("RSR", "info")

dofile("RSRconfig.lua")
dofile("handleMarkEvents.lua")
dofile("persistence.lua")

if rsr.devMode then
    log:warn("Running in developer mode - should not be used for 'real' servers")
end

env.info("RSR ready")
