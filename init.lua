--- Figure out whether we're running inside DCS or not
--- currently done by setting environment variable manually when running outside or loading dcs_stub.lua

-- stub DCS if we're running outside
if env == nil then
    dofile("dcs_stub.lua")
end

--- Loads file from inside DCS saved games folder if running in DCS or current dir if not
function dofileWrapper(filename)
    env.info("Loading " .. filename)
    if dcsStub == nil then
        dofile(lfs.writedir() .. [[Scripts\RSR\]] .. filename)
    else
    dofile(filename)
    end
    env.info(filename .. " loaded")
end
