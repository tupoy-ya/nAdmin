nAdmin = {}
nAdmin.Commands = {}
nAdmin.Modules = {}
nAdmin.Slashes = {
    ["!"] = "!",
    ["."] = ".",
    ["/"] = "/",
}
nAdmin.UseNickWithoutTags = true

local table_concat = table.concat
local util = util
local net = net
local net_Start = net.Start
local net_WriteUInt = net.WriteUInt
local net_WriteData = net.WriteData
local net_ReadString = net.ReadString
local net_ReadData = net.ReadData
local net_ReadUInt = net.ReadUInt
local net_Send = net.Send
local net_SendToServer = net.SendToServer
local net_Broadcast = net.Broadcast
local util = util
local util_Compress = util.Compress
local util_Decompress = util.Decompress
local util_TableToJSON = util.TableToJSON
local util_JSONToTable = util.JSONToTable
local ipairs = ipairs

if SERVER then
	local meta = FindMetaTable"Player"

	local plCached = {}

	util.AddNetworkString("nadmin_message")
	util.AddNetworkString("nAdmin_CommandExec")
	util.AddNetworkString("nadmin_singleplayer")

	local function sendCMDTable(pl)
		local compress = util_Compress(util_TableToJSON(nAdmin.Commands))
		local compress_ = #compress
		net_Start("nadmin_message")
			net_WriteUInt(2, 2)
			net_WriteUInt(compress_, 16)
			net_WriteData(compress, compress_)
		net_Send(pl)
	end

	for k, v in ipairs(player.GetAll()) do
		sendCMDTable(v)
	end

	net.Receive("nadmin_message", function(_, pl)
		local int = net_ReadUInt(1)
		if int == 1 then
			if plCached[pl] then return end
			sendCMDTable(pl)
		end
	end)

	hook.Add("PlayerInitialSpawn", "nAdmin_TCommands", function(ply)
		timer.Simple(5, function()
			sendCMDTable(ply)
		end)
	end)

	function nAdmin.CommandExec(pl, args)
		local arg1 = args[1]
		local a = nAdmin.Commands[arg1]
		if a == nil then
			nAdmin.Warn(pl, "Неизвестная команда: " .. (tostring(arg1 or "не введена") or "") .. "!")
			return
		end
		for i = 1, #args do
			args[i] = args[i + 1]
		end
		if not nAdmin.GetAccess(arg1, pl) then
			return
		end
		if args[1] == "^" then
			args[1] = pl:Name()
		end
		a.func(pl, args)
		local pls, admins = player.GetAll(), {}
		for i = 1, #pls do
			local v = pls[i]
			if v:IsAdmin() then
				table.insert(admins, v)
			end
		end
		net_Start("nadmin_message")
			net_WriteUInt(3, 2)
			net.WriteString((IsValid(pl) and pl:NameWithoutTags() or "Консоль") .. " > CMD: " .. arg1 .. " " .. table_concat(args) .. "")
		net_Send(admins)
	end

	net.Receive("nAdmin_CommandExec", function(_, pl)
		local args =  util_JSONToTable(net_ReadString())
		nAdmin.CommandExec(pl, args)
	end)

	hook.Add("PlayerDisconnected", "nAdmin_null", function(pl)
		plCached[pl] = nil
	end)

	hook.Add("Think", "nAdminInitWorld", function()
		local metaENT = FindMetaTable"Entity"
		function metaENT:Team()
			if self == Entity(0) or not IsValid(self) then
				return 0
			end
		end
		function metaENT:SteamID()
			if self == Entity(0) or not IsValid(self) then
				return "STEAM_0:0:0"
			end
		end
		function metaENT:Name()
			if self == Entity(0) or not IsValid(self) then
				return "Консоль"
			end
		end
		function metaENT:NameWithoutTags()
			if self == Entity(0) or not IsValid(self) then
				return "Консоль"
			end
		end
		hook.Remove("Think", "nAdminInitWorld")
	end)

	function nAdmin.msg(msg, ply)
		if not ply then
			local a = ""
			for k, v in next, msg do
				if isstring(v) then
					a = a .. v
				end
			end
			nAdmin.Print(a)
		end
		msg = util_TableToJSON(msg)
		local compress = util_Compress(msg)
		local compress_ = #compress
		net_Start("nadmin_message")
			net_WriteUInt(1, 2)
			net_WriteUInt(compress_, 16)
			net_WriteData(compress, compress_)
		if not ply then
			net_Broadcast()
		else
			net_Send(ply)
		end
	end

	function nAdmin.PrintMessage(msg)
		nAdmin.msg(msg)
	end

	function nAdmin.WarnAll(msg)
		nAdmin.PrintMessage({Color(180, 180, 180), msg})
	end

	function nAdmin.ValidCheckCommand(args, count, ply, cmd)
		local has = true
		for i = 1, count do
			if not args[i] then
				local argg = ""
				if ply then
					nAdmin.Warn(ply, "Не назначен " .. i .. " аргумент. (" ..  nAdmin.Commands[cmd].desc .. ")")
				else
					nAdmin.Print("Не назначен " .. i .. " аргумент. (" .. nAdmin.Commands[cmd].desc .. ")")
				end
				has = false
				break
			end
		end
		if not has then
			return false
		end
		return has
	end

	local wrld, singleplayer = Entity(0), game.SinglePlayer()
	concommand.Add("n", function(pl, _, args)
		if not IsValid(pl) and (nAdmin.Commands[args[1]] and not nAdmin.Commands[args[1]].ConsoleBlock) then
			nAdmin.CommandExec(wrld, args)
			return
		end
		if (singleplayer or (IsValid(pl) and pl:IsListenServerHost())) and nAdmin.Commands[args[1]] and nAdmin.Commands[args[1]].SV then
			nAdmin.CommandExec(pl, args)
		elseif (singleplayer or (IsValid(pl) and pl:IsListenServerHost())) and not nAdmin.Commands[args[1]] then
			net.Start'nadmin_singleplayer'
				net.WriteString(table.concat(args, "\\\\"))
			net.Send(pl)
		end
	end)
end

if CLIENT then
	net.Receive("nadmin_message", function()
		local mode = net_ReadUInt(2)
		if mode == 3 then
			local a = net_ReadString()
			nAdmin.LastSystime = SysTime()
			if IsValid(nGUI) then
				hook.Run("nAdmin_SystimeUpdate", nAdmin.LastSystime, a)
			end
			return
		end
		local int = net_ReadUInt(16)
		local data = net_ReadData(int)
		local decompress = util_Decompress(data)
		decompress = util_JSONToTable(decompress or "{}")
		if mode == 1 then
			chat.AddText(unpack(decompress))
		elseif mode == 2 then
			for k, v in next, decompress do
				if nAdmin.Commands[k] then continue end
				nAdmin.Commands[k] = v
			end
			nAdmin.FULLCMDS = true
		end
	end)

	net.Receive("nadmin_singleplayer", function()
		local args = string.Explode("\\\\", net.ReadString())
		local cmd = args[1]
		if nAdmin.Commands[cmd] ~= nil and nAdmin.Commands[cmd].CL == true then
			for i = 1, #args do
				args[i] = args[i + 1]
			end
			nAdmin.Commands[cmd].func(args)
			return
		end
	end)

	function nAdmin.AutoComplete(cmd, args)
		--todo
	end

	function nAdmin.NetCmdExec(pl, args)
		local cmd = args[1]
		if nAdmin.Commands[cmd] ~= nil and nAdmin.Commands[cmd].CL == true then
			for i = 1, #args do
				args[i] = args[i + 1]
			end
			nAdmin.Commands[cmd].func(args)
			return
		end
		local a = util_TableToJSON(args)
		net_Start("nAdmin_CommandExec")
			net.WriteString(a)
		net_SendToServer()
	end

	function nAdmin.Run(cmd, ...)
		return concommand.Run(LocalPlayer(), "n", {cmd, unpack({...})})
	end

	concommand.Add("n", function(pl, _, args)
		nAdmin.NetCmdExec(pl, args)
	end, nAdmin.AutoComplete)
end

function nAdmin.GetAccess(cmd, pl)
	if SERVER then
		if nAdmin.Commands[cmd].T == nil then
			return true
		end
		if pl:SteamID() == "STEAM_0:0:0" then
			return true
		end
		local TF = pl:Team() <= Global_Teams[nAdmin.Commands[cmd].T].num
		if TF == false then
			nAdmin.Warn(pl, "У вас нет прав использовать эту команду.")
		end
		return TF
	else
		if nAdmin.Commands[cmd] == nil or (nAdmin.Commands[cmd] and nAdmin.Commands[cmd].T == nil) then
			return true
		end
		return LocalPlayer():Team() <= Global_Teams[nAdmin.Commands[cmd].T].num
	end
end

function PT(...)
	return PrintTable(...)
end

function p(...)
	return print(...)
end

function nAdmin.Print(...)
	Msg"[nAdmin] "p(...)
end

function nAdmin.Message(ply, msg)
	if SERVER then
		if ply:SteamID() == "STEAM_0:0:0" then
			nAdmin.Print(msg[2])
			return
		end
		nAdmin.msg(msg, ply)
	else
		chat.AddText(unpack(msg))
	end
end

function nAdmin.Warn(ply, msg)
	nAdmin.Message(ply, {Color(180, 180, 180), msg})
end

function nAdmin.AddCommand(cmd, autocomplete, func)
	if SERVER then
		if autocomplete == true then
			autocomplete = nAdmin.AutoComplete
		end
		nAdmin.Commands[cmd] = {func = func, ac = autocomplete, SV = true}
	else
		nAdmin.Commands[cmd] = {func = autocomplete, CL = true}
	end
end

local function found(nick)
	local player_GetAll = player.GetAll()
	local pgacount = #player_GetAll
	for i = 1, pgacount do
		local v = player_GetAll[i]
		if v:NameWithoutTags() == nick then
			return true
		end
	end
end

function nAdmin.FindByNick(nick)
	if tonumber(nick) ~= nil
		and IsValid(Entity(nick))
		and tonumber(nick) <= 128
		and not found(nick) then
		return Entity(nick)
	end
	if nAdmin.ValidSteamID(nick) then
		local this = player.GetBySteamID(nick)
		return this ~= false and this or nil
	end
	nick = string.lowerRus(nick)
	local ent
	local player_GetAll = player.GetAll()
	local pgacount = #player_GetAll
	for i = 1, pgacount do
		local v = player_GetAll[i]
		if v:Name() == nick then
			ent = v
			break
		end
	end
	if not ent then
		for i = 1, pgacount do
			local v = player_GetAll[i]
			if v:NameWithoutTags() == nick then
				ent = v
				break
			end
		end
	end
	if not ent then
		for i = 1, pgacount do
			local v = player_GetAll[i]
			local name = string.lowerRus(v:NameWithoutTags())
			if name == "^" or name == "*" then
				ent = v
				break
			end
			local findplayer = string.find(name, nick, 1, true)
			if findplayer == 1 then
				ent = v
				break
			end
		end
	end
	if not ent then
		for i = 1, pgacount do
			local v = player_GetAll[i]
			local name = string.lowerRus(v:NameWithoutTags())
			local findplayer = string.find(name, nick)
			if findplayer then
				ent = v
				break
			end
		end
	end
	return IsValid(ent) and ent:IsPlayer() and ent or nil
end

function nAdmin.SetTAndDesc(cmd, T, desc)
	local tCmds = nAdmin.Commands[cmd]
	if tCmds == nil then
		nAdmin.Print(cmd .. " < команда не найдена! > nAdmin.SetTAndDesc")
		return
	end
	table.Merge(nAdmin.Commands[cmd], {T = T, desc = desc})
end

function nAdmin.ConsoleBlock(cmd)
	local tCmds = nAdmin.Commands[cmd]
	if tCmds == nil then
		nAdmin.Print(cmd .. " < команда не найдена! > nAdmin.ConsoleBlock")
		return
	end
	table.Merge(nAdmin.Commands[cmd], {consoleblock = true})
end

function nAdmin.CmdHidden(cmd)
	local tCmds = nAdmin.Commands[cmd]
	if tCmds == nil then
		nAdmin.Print(cmd .. " < команда не найдена! > nAdmin.CmdHidden")
		return
	end
	table.Merge(nAdmin.Commands[cmd], {hidden = true})
end

function nAdmin.CmdIsHidden(cmd)
	if nAdmin.Commands[cmd] and nAdmin.Commands[cmd].hidden then return true end
	return false
end

function nAdmin.ValidSteamID(sid)
	if sid == nil then return end
	return sid:upper():Trim():match("^STEAM_0:%d:%d+$")
end

function nAdmin.UpdateFiles()
	nAdmin.Print("Загрузка файлов...")
	local os_time = SysTime()
	-- [[ SQL ]] --
	if SERVER then
		include("nadmin/server/sv_sql.lua")
	end
	-- [[ SHARED ]] --
	for k, v in ipairs(file.Find("nadmin/*", "LUA")) do
		if v == "sh_func.lua" then
			continue
		end
		include("nadmin/" .. v)
		AddCSLuaFile("nadmin/" .. v)
	end
	for k, v in ipairs(file.Find("nadmin/client/*", "LUA")) do
		if CLIENT then
			include("nadmin/client/" .. v)
		else
			AddCSLuaFile("nadmin/client/" .. v)
		end
	end
	if SERVER then
		-- [[ SERVER ]] --
		for k, v in ipairs(file.Find("nadmin/server/*", "LUA")) do
			include("nadmin/server/" .. v)
		end
	end
	-- [[ MODULES ]] --
	for k, v in ipairs(file.Find("nadmin/modules/*", "LUA")) do
		if string.StartWith(v, "sh_") then
			AddCSLuaFile("nadmin/modules/" .. v)
		end
		include("nadmin/modules/" .. v)
		table.insert(nAdmin.Modules, string.sub(v, 1, #v - 4))
	end
	nAdmin.Print("Файлы были загружены за: " .. SysTime() - os_time .. ".")
end

nAdmin.UpdateFiles()

if not nAdmin.UseNickWithoutTags then
	local meta = FindMetaTable'Player'
	meta.NameWithoutTags = meta.GetName
end