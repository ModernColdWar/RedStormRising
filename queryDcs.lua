require("MOOSE")
local inspect = require("inspect")
local utils = require("utils")

local M = {}

local log = mist.Logger:new("QueryDCS", "info")

function M.getAllBaseOwnership()
    local baseOwnership = { airbases = { red = {}, blue = {}, neutral = {} },
                            farps = { red = {}, blue = {}, neutral = {} } }
    for _, base in ipairs(AIRBASE.GetAllAirbases()) do
        local baseName = base:GetName()
        local sideName = utils.getSideName(base:GetCoalition())
        if sideName == nil then
            log:info("Got no coalition for $1; setting to neutral", baseName)
            sideName = "neutral"
        end
        if base:GetAirbaseCategory() == Airbase.Category.AIRDROME then
            table.insert(baseOwnership.airbases[sideName], baseName)
        elseif base:GetAirbaseCategory() == Airbase.Category.HELIPAD then
            table.insert(baseOwnership.farps[sideName], baseName)
        end
    end
    log:info("baseOwnership = $1", inspect(baseOwnership, { newline = " ", indent = "" }))
    return baseOwnership
end

return M
