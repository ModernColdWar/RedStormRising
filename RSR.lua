--- Red Storm Rising DCS mission LUA code

if env == nil then
    dofile("bootstrap.lua")
else
    dofile(lfs.writedir() .. [[Scripts\RSR\bootstrap.lua]])
end

env.info("RSR starting")

if mist == nil then
    dofileWrapper("mist_4_3_74.lua")
end

if ctld == nil then
    dofileWrapper("CTLD.lua")
    dofileWrapper("CTLDconfig.lua")
end

log = mist.Logger:new("RSR", "info")
JSON = loadfile(getFilePath("JSON.lua"))()

dofileWrapper("RSRconfig.lua")
dofileWrapper("persistence.lua")
dofileWrapper("markEvents.lua")
dofileWrapper("ctldCallbacks.lua")
dofileWrapper("init.lua")

env.info("RSR ready")
