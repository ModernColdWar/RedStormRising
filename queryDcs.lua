require("MOOSE")
local utils = require("utils")

local M = {}

function M.getAllBaseOwnership()
    local baseOwnership = { airbases = { red = {}, blue = {}, neutral = {} },
                            farps = { red = {}, blue = {}, neutral = {} } }
    for _, base in ipairs(AIRBASE.GetAllAirbases()) do
        local baseName = base:GetName()
        local sideName = utils.getSideName(base:GetCoalition())
        if base:GetAirbaseCategory() == Airbase.Category.AIRDROME then
            table.insert(baseOwnership.airbases[sideName], baseName)
        elseif base:GetAirbaseCategory() == Airbase.Category.HELIPAD then
            table.insert(baseOwnership.farps[sideName], baseName)
        end
    end
    return baseOwnership
end

return M
