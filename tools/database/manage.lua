package.cpath = package.cpath .. [[;C:\dev\luarocks\lib\lua\5.1\?.dll]]

local lfs = require("lfs")
local database = require("database")

local MIGRATIONS_DIR = [[tools\database\migrations]]

local migrations = {}

for file in lfs.dir(MIGRATIONS_DIR) do
    if file:sub(#file - 3, #file) == '.lua' then
        table.insert(migrations, file)
        table.sort(migrations)
    end
end

local action = arg[1]
if action == nil then
    print("No action specified")
    os.exit(1)
end

local db = database.openOrCreate()

local db_version
for v in db:urows("PRAGMA user_version") do
    db_version = v
end

print("Current version of database is " .. db_version)

if action == "current" then
    os.exit(0)
end

if action == "upgrade" then
    for _, file in ipairs(migrations) do
        local version = tonumber(file:sub(0, 3))
        if version > db_version then
            print("Running upgrade " .. file)
            local path = string.format([[%s\%s]], MIGRATIONS_DIR, file)
            dofile(path)
            upgrade(db)
            db:exec("PRAGMA user_version = " .. tostring(version))
        else
            print("Skipping upgrade " .. file)
        end
    end
end

if action == "downgrade" then
    if db_version == 0 then
        print("Cannot downgrade from version 0")
        os.exit(1)
    end
    local file = migrations[db_version]
    print("Running downgrade " .. file)
    local path = string.format([[%s\%s]], MIGRATIONS_DIR, file)
    dofile(path)
    downgrade(db)
    db:exec("PRAGMA user_version = " .. tostring(db_version - 1))
end

for v in db:urows("PRAGMA user_version") do
    db_version = v
end

print("New version of database is " .. db_version)

db:close()
