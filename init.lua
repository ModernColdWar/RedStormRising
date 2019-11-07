--- Figure out whether we're running inside DCS or not
--- currently done by setting environment variable manually when running outside or loading dcs_stub.lua

-- stub DCS if we're running outside
if env == nil then
    dofile("dcs_stub.lua")
end

--- Loads file from inside DCS saved games folder if running in DCS or current dir if not
function dofileWrapper(filename)
    filename = getFilePath(filename)
    env.info("Loading " .. filename)
    dofile(filename)
    env.info(filename .. " loaded")
end

function getFilePath(filename)
    if dcsStub == nil then
        return lfs.writedir() .. [[Scripts\RSR\]] .. filename
    else
        return filename
    end
end
