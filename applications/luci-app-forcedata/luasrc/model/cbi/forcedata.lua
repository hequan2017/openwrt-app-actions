--[[
LuCI - Lua Configuration Interface
]]--

local taskd = require "luci.model.tasks"
local forcedata_model = require "luci.model.forcedata"
local m, s, o

m = taskd.docker_map("forcedata", "forcedata", "/usr/libexec/istorec/forcedata.sh",
	translate("Forcedata"),
	"此服务为 原力云推出的一款镜像软件，通过简单安装后可快速加入原力云的边缘计算生态，在线共享带宽即可赚钱，每月可获取一定的现金回报！了解更多，请登录「<a href=\"https://www.forcedata.com.cn\" target=\"_blank\" >原力云官网</a>」并查看<a href=\"https://doc.linkease.com/zh/guide/istoreos/software/forcedata.html\" target=\"_blank\">「教程」</a>")

s = m:section(SimpleSection, translate("Service Status"), translate("Forcedata status:"), "")
s:append(Template("forcedata/status"))

s = m:section(TypedSection, "forcedata", translate("Setup"), translate("The following parameters will only take effect during installation or upgrade:"))
s.addremove=false
s.anonymous=true


return m
