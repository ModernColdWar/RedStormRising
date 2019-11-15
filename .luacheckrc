stds.dcs_stub = {
    read_globals = {
        "dcsStub",
        "AI", "Airbase", "Group", "StaticObject", "Unit",
        "coalition", "country", "env", "lfs", "radio", "timer", "trigger", "world"
    }
}

stds.moose = {
    read_globals = {
        "AIRBASE", "SET_GROUP", "SETTINGS", "UTILS", "ZONE_AIRBASE"
    }
}

std = "lua51+dcs_stub+moose"

read_globals = { "mist" }
globals = { "ctld" }

max_line_length = 160

-- ignore libraries about which we can do little/nothing
exclude_files = {
    "CTLD.lua",
    "CTLD_config.lua",
    "JSON.lua",
    "tests/luaunit.lua",
    "mist_4_3_74.lua",
    "Moose.lua" }

-- ignore luaunit conventions which cause warnings
files["tests/test_*.lua"] = { ignore = { "111", "112", "212" } }
