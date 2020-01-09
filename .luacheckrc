stds.dcs_stub = {
    read_globals = {
        "dcsStub",
        "AI", "Airbase", "Controller", "Group", "Object", "Spot", "StaticObject", "Unit",
        "coalition", "coord", "country", "env", "land", "lfs", "missionCommands", "radio", "timer", "trigger", "world"
    }
}

stds.moose = {
    read_globals = {
        "BASE", "AIRBASE", "COMMANDCENTER", "COORDINATE", "DATABASE", "DESIGNATE", "DETECTION_AREAS", "EVENTHANDLER",
        "EVENTS", "GROUP", "MENU_GROUP", "MENU_GROUP_COMMAND", "MESSAGE", "SCHEDULER", "SET_CLIENT", "SET_GROUP",
        "SETTINGS", "SPAWN", "UNIT", "UTILS", "ZONE", "ZONE_AIRBASE", "_SETTINGS"
    }
}

std = "lua51+dcs_stub+moose"

read_globals = { "mist" }
globals = { "csar", "ctld" }

max_line_length = 160

-- ignore libraries about which we can do little/nothing
exclude_files = {
    "JSON.lua",
    "tests/luaunit.lua",
    "mist_4_3_74.lua",
    "Moose.lua" }

-- ignore luaunit conventions which cause warnings
files["tests/test_*.lua"] = { ignore = { "111", "112", "212" } }
