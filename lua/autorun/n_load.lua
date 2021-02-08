AddCSLuaFile("nadmin/sh_func.lua")
include("nadmin/sh_func.lua")

if CLIENT then
	for k, v in ipairs(file.Find("nadmin/client/*", "LUA")) do
		include("nadmin/client/" .. v)
	end
end