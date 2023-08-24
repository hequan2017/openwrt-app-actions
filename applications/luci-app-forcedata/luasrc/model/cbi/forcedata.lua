--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local forcedata_model = require "luci.model.forcedata"
local m, s, o

m = taskd.docker_map("forcedata", "forcedata", "/usr/libexec/istorec/forcedata.sh",
        translate("forcedata"),
        translate("forcedata  介绍"))

s = m:section(SimpleSection, translate("Service Status"), translate("forcedata status:"))
s:append(Template("forcedata/status"))

s = m:section(TypedSection, "forcedata", translate("Setup"))

s.addremove=false
s.anonymous=true

return m
