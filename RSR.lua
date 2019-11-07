--- Red Storm Rising DCS mission LUA code

--- Figure out whether we're running inside DCS or not
-- currently done by setting environment variable manually when running outside or loading dcs_stub.lua
local function runningInDcs()
    return os.getenv("STUB_DCS") == nil and dcsStub == nil
end

if not runningInDcs() then
    dofile("dcs_stub.lua")
end

env.info("RSR starting")

--- Loads file from inside DCS saved games folder if running in DCS or current dir if not
local function dofileWrapper(filename)
    env.info("Loading " .. filename)
    if runningInDcs() then
        dofile(lfs.writedir() .. [[Scripts\RSR\]] .. filename)
    else
        dofile(filename)
    end
    env.info(filename .. " loaded")
end

dofileWrapper("mist_4_3_74.lua")
dofileWrapper("CTLD.lua")

ctld.slingLoad = true

log = mist.Logger:new("RSR", "info")

dofileWrapper("markEvents.lua")

env.info("RSR ready")
