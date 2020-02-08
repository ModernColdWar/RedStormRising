local M = {}

local function getDistSq(x1, y1, x2, y2)
    local dX = x1 - x2
    local dY = y1 - y2
    return dX * dX + dY * dY
end

function M.isPointInZone(point, zonePoint, zoneRadius)
    return getDistSq(point.x, point.y, zonePoint.x, zonePoint.y) < zoneRadius * zoneRadius
end

function M.findNearest(point, points)
    local pX = point.x
    local pY = point.y
    local minIdx, minDist
    for idx, p in pairs(points) do
        local dist = getDistSq(pX, pY, p.x, p.y)
        if minDist == nil or dist < minDist then
            minIdx = idx
            minDist = dist
        end
    end
    return minIdx, minDist and math.sqrt(minDist) or nil
end

return M
