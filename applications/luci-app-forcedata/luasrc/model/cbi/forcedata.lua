--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local forcedata_model = require "luci.model.forcedata"
local m, s, o

m = taskd.docker_map("forcedata", "forcedata","/usr/libexec/istorec/forcedata.sh",
	translate("Forcedata"),
	"通过简单安装后可快速加入原力联盟的边缘计算生态，在线共享带宽即可赚钱，每月可获取一定的现金回报！了解更多，请登录「<a href=\"http://www.forcedata.cn\" target=\"_blank\" >原力联盟官网</a>」并查看<a href=\"https://docs.qq.com/doc/DZXNFWWtKbHN4UHFD\" target=\"_blank\">「教程」</a>")

s = m:section(SimpleSection, translate("Service Status"), translate("Forcedata status:"), "")
s:append(Template("forcedata/status"))

s = m:section(TypedSection, "forcedata", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true

--local default_id = forcedata_model.default_id()
--o = s:option(Value, "id", translate("id").."<b>*</b>")
--o.rmempty = false
--o.description = default_id
--o.datatype = "string"
--o.default = default_id
--o.readonly = true
--o.value = default_id

local default_uid = forcedata_model.default_uid()
o = s:option(Value, "uid", translate("UID").."<b>*</b>")
o.rmempty = false
o.datatype = "string"
o:value(default_uid, default_uid)
o.default = default_uid


return m
