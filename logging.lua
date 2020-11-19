-- Logger inspired by MIST's logger for use inside and outside DCS
-- Here to replace the need to import MIST when we're just doing logging

local inspect = require("inspect")
local M = {}

M.Logger = {}

M.inspect_options = { newline = " ", indent = "" }

if env == nil then
    M._info = function(text)
        print("INFO    " .. text)
    end
    M._warning = function(text)
        print("WARNING " .. text)
    end
    M._error = function(text)
        print("ERROR   " .. text)
    end
else
    M._info = env.info
    M._warning = env.warning
    M._error = env.error
end

local function toStr(o)
    if type(o) == 'string' then
        return o
    end
    if type(o) == 'table' then
        return inspect(o, M.inspect_options)
    end
    return tostring(o)
end

local function formatText(text, ...)
    text = toStr(text)
    for i, v in ipairs(arg) do
        v = toStr(v)
        text = text:gsub('$' .. i, v)
    end
	
	local fName = nil
    local cLine = nil
	local dInfo = debug.getinfo(3)
	fName = dInfo.name
	cLine = dInfo.currentline
	-- local fsrc = dinfo.short_src
	--local fLine = dInfo.linedefined
	if fName and cLine then
		return fName .. '|' .. cLine .. ': ' .. text
	elseif cLine then
		return cLine .. ': ' .. text
	else
		return ' ' .. text
	end

    return text
end

function M.Logger:new(tag)
    local l = {}
    l.tag = tag
    setmetatable(l, self)
    self.__index = self
    return l
end

function M.Logger:info(text, ...)
    M._info(self.tag .. '|' .. formatText(text, unpack(arg)))
end

function M.Logger:warn(text, ...)
    M._warning(self.tag .. '|' .. formatText(text, unpack(arg)))
end

function M.Logger:error(text, ...)
    M._error(self.tag .. '|' .. formatText(text, unpack(arg)))
end

return M