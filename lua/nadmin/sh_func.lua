nAdmin = {}
nAdmin.Commands = {}
nAdmin.Modules = {}

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

	function nAdmin.CommandExec(pl, cmd, args)
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
		for _, v in ipairs(player.GetHumans()) do
			if v:IsAdmin() then
				net_Start("nadmin_message")
					net_WriteUInt(3, 2)
					net.WriteString(pl:Name() .. " > CMD: " .. arg1 .. " " .. table_concat(args) .. "")
				net_Send(v)
			end
		end
	end

	net.Receive("nAdmin_CommandExec", function(_, pl)
		local command = net_ReadString()
		local args = net_ReadString()
		args = util_JSONToTable(args)
		nAdmin.CommandExec(pl, command, args)
	end)

	hook.Add("PlayerDisconnected", "nAdminnull", function(pl)
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

	function nAdmin.GetAccess(cmd, pl)
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
	end

	local wrld = Entity(0)
	concommand.Add("n", function(pl, _, args)
		if not IsValid(pl) then
			nAdmin.CommandExec(wrld, args[1], args)
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

	function nAdmin.AutoComplete(cmd, args) -- я вообще не ебу как ее переделать
		args = string.Trim(args)
		args = string.lower(args)
		local e = args:Split(" ")
		local tbl = {}
		local cmdFull = ""
		local a2 = e[2]
		local s_ = {}
		for k in next, nAdmin.Commands do
			table.insert(s_, k)
		end
		table.sort(s_)
		local e1 = e[1]
		for i = 1, #s_ do
			local v = s_[i]
			if string.find(string.lower(v), e1, 1, true) then
				v = cmd .. " " .. v
				cmdFull = v
				if string.sub(v, 3, #v) == e1 then
					goto skipp
				end
				if not a2 or v == e1 then
					table.insert(tbl, v)
				end
			end
		end
		::skipp::
		if a2 and nAdmin.Commands[e1] ~= nil then
			local players = player.GetAll()
			for i = 1, #players do
				local v = players[i]
				local nick = v:Name()
				local s = ""
				if a2 ~= nil then
					s = string.find(string.lower(nick), e[2], 1, true)
				else
					s = true
				end
				if s then
					nick = "\"" .. nick .. "\""
					nick = cmdFull .. " " .. nick
					table.insert(tbl, nick)
				end
			end
		end
		return tbl
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
		--a = util_Compress(a)
		net_Start("nAdmin_CommandExec")
			net.WriteString(cmd or "")
			net.WriteString(a)
		net_SendToServer()
	end

	concommand.Add("n", function(pl, _, args)
		nAdmin.NetCmdExec(pl, args)
	end, nAdmin.AutoComplete)
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
		nAdmin.Commands[cmd] = {func = func, ac = autocomplete}
	else
		nAdmin.Commands[cmd] = {func = autocomplete, CL = true}
	end
end

function nAdmin.FindByNick(nick)
	local ent
	nick = nick or ""
	nick = string.lower(nick)
	nick = nick:Trim()
	local player_GetAll = player.GetAll()
	for _, v in ipairs(player_GetAll) do
		if v:Name():Trim() == nick then
			ent = v
			goto skip
		end
	end
	for _, v in ipairs(player_GetAll) do
		local name = v:Name():Trim()
		name = string.lower(name)
		if name == "^" or name == "*" then
			ent = v
			break
		end
		local findplayer = string.find(name, nick, 1, true)
		if findplayer == 1 or findplayer then
			ent = v
			break
		end
	end
	::skip::
	return ent
end

function nAdmin.SetTAndDesc(cmd, T, desc)
	local tCmds = nAdmin.Commands[cmd]
	if tCmds == nil then
		debug.Trace()
	end
	if tCmds.T or tCmds.desc then
		return
	end
	table.Merge(nAdmin.Commands[cmd], {T = T, desc = desc})
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