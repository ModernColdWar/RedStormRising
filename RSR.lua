--- Red Storm Rising DCS mission LUA code

if env == nil then
    dofile("bootstrap.lua")
else
    dofile(lfs.writedir() .. [[Scripts\RSR\init.lua]])
end

env.info("RSR starting")

dofileWrapper("mist_4_3_74.lua")
dofileWrapper("CTLD.lua")

ctld.slingLoad = true

log = mist.Logger:new("RSR", "info")
JSON = loadfile(getFilePath("JSON.lua"))()

dofileWrapper("rsrState.lua")
dofileWrapper("persistence.lua")
dofileWrapper("markEvents.lua")

env.info("RSR ready")
