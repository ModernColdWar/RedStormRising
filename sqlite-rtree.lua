--[[
-- new installation for Lua having installed Visual Studio 2019 community
set PREFIX=C:\dev\lua (or whatever)
install.bat /L /NOADMIN /P %PREFIX% /CONFIG %PREFIX%\luarocks
Download luarocks-3.3.1-win32 via https://github.com/luarocks/luarocks/wiki/installation-instructions-for-windows
add to PATH: C:\dev\lua and C:\dev\lua\systree\bin
Grab sqlite3 amalgamated source from https://www.sqlite.org/download.html and put somewhere
Create sqlite3.lib via https://docs.microsoft.com/en-us/cpp/build/walkthrough-creating-and-using-a-static-library-cpp?view=vs-2019
  `cl /c /EHsc -DSQLITE_ENABLE_RTREE=1 sqlite3.c`  # The rtree stuff actually seems slower than doing it naively
  `lib sqlite3.obj`
luarocks install luasql-sqlite3 SQLITE_INCDIR=C:\dev\sqlite3 SQLITE_DIR=C:\dev\sqlite3
]]
package.cpath = package.cpath .. ";C:\\dev\\lua\\systree\\lib\\lua\\5.1\\?.dll;"

local driver = require("luasql.sqlite3")
local env = assert(driver.sqlite3())

local con = assert(env:connect(":memory:"))

local numAirbases = 50

local numUnits = 5000

local baseRadius = 5000
local mapSize = 100000

local numLoops = 1

assert(con:execute [[
CREATE VIRTUAL TABLE map USING rtree(
  id,
  minX, maxX,
  minY, maxY,
  +name TEXT,
  +coalition INTEGER
)
]])

for _ = 1, numLoops do
    local airbases = {}
    for i = 1, numAirbases do
        local x = math.random() * (mapSize - baseRadius * 2) + baseRadius
        local y = math.random() * (mapSize - baseRadius * 2) + baseRadius
        local baseName = string.format("Airbase_%02d", i)
        airbases[baseName] = { x = x, y = y }
    end

    local units = {}
    local coalition = 1
    for i = 1, numUnits do
        local x = math.random() * mapSize
        local y = math.random() * mapSize
        local unitName = string.format("Unit_%04d", i)
        units[unitName] = { x = x, y = y, coalition = coalition }
        if coalition == 1 then
            coalition = 2
        else
            coalition = 1
        end
    end

    local sqliteT0 = os.clock()
    assert(con:execute("DELETE FROM map"))
    for unitName, unitData in pairs(units) do
        local stmt = string.format([[
          INSERT INTO map(minX, maxX, minY, maxY, name, coalition)
          VALUES(%f, %f, %f, %f, '%s', %d)
    ]], unitData.x, unitData.x, unitData.y, unitData.y, unitName, unitData.coalition)
        assert(con:execute(stmt))
    end

    for airbaseName, position in pairs(airbases) do
        local unitsInProximity = {}
        local baseX, baseY = position.x, position.y
        local minX, maxX = baseX - baseRadius, baseX + baseRadius
        local minY, maxY = baseY - baseRadius, baseY + baseRadius
        local query = string.format([[
          select name from map
          where minX > %f and minX < %f
          and minY > %f and minY < %f
        ]], minX, maxX, minY, maxY)
        local cur = assert(con:execute(query))
        local row = cur:fetch()
        while row do
            table.insert(unitsInProximity, row)
            row = cur:fetch()
        end
        --print(string.format("%s: %s", airbaseName, inspect(unitsInProximity)))
        cur:close()
    end
    local sqliteT1 = os.clock()

    local naiveT0 = os.clock()
    for airbaseName, position in pairs(airbases) do
        local unitsInProximity = {}
        local baseX, baseY = position.x, position.y
        local minX, maxX = baseX - baseRadius, baseX + baseRadius
        local minY, maxY = baseY - baseRadius, baseY + baseRadius
        for unitName, unitData in pairs(units) do
            local unitX, unitY = unitData.x, unitData.y
            local close = unitX > minX and unitX < maxX and unitY > minY and unitY < maxY
            if close then
                table.insert(unitsInProximity, unitName)
            end
        end
        --print(string.format("%s: %s", airbaseName, inspect(unitsInProximity)))
    end
    local naiveT1 = os.clock()

    print(string.format("Checking %d units against %d airbases:", numUnits, numAirbases))
    print(string.format("  SQLite Rtree: %.4f", sqliteT1 - sqliteT0))
    print(string.format("  Naive       : %.4f", naiveT1 - naiveT0))
end

con:close()
env:close()
