nAdmin = {}
nAdmin.Commands = {}
nAdmin.Modules = {}

if SERVER then
	local meta = FindMetaTable"Player"
	local table_concat = table.concat

	local plCached = {}

	util.AddNetworkString("nadmin_message")
	util.AddNetworkString("nAdmin_Execute")

	net.Receive("nadmin_message", function(_, pl)
		local int = net.ReadUInt(1)
		if int == 1 then
			if plCached[pl] then return end
			local compress = util.Compress(util.TableToJSON(nAdmin.Commands))
			local compress_ = #compress
			net.Start("nadmin_message")
				net.WriteUInt(2, 2)
				net.WriteUInt(compress_, 16)
				net.WriteData(compress, compress_)
			net.Send(pl)
		end
	end)

	hook.Add("PlayerDisconnected", "nAdminnull", function(pl)
		plCached[pl] = nil
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
			if string.match(string.lower(v), e1) then
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
		if a2 then
			local players = player.GetAll()
			for i = 1, #players do
				local v = players[i]
				local nick = v:Name()
				local s = ""
				if a2 ~= nil then
					s = string.match(string.lower(nick), e[2])
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

	function nAdmin.FirstAddCommand()
		concommand.Add("n", function(pl, cmd, args)
			local arg1 = args[1]
			local a = nAdmin.Commands[arg1] or nil
			if a == nil then
				nAdmin.Warn(pl, "Неизвестная команда: " .. (tostring(arg1 or "не введена") or "") .. "!")
				return
			end
			local command = a.func
			for i = 1, #args do
				args[i] = args[i + 1]
			end
			if nAdmin.Commands[cmd] and not nAdmin.Commands[cmd].argsCount then
				table.Merge(nAdmin.Commands[cmd], {argsCount = count})
			end
			if pl.B and arg1:find("noclip") then
				goto skipCheck
			end
			if not nAdmin.GetAccess(arg1, pl) then
				return
			end
			::skipCheck::
			if not IsValid(pl) then
				pl = Entity(0)
			end
			command(pl, cmd, args)
			for _, v in ipairs(player.GetHumans()) do
				if v:IsAdmin() then
					net.Start("nadmin_message")
						net.WriteUInt(3, 2)
						net.WriteString(pl:Name() .. " > CMD: " .. arg1 .. " " .. table_concat(args) .. "")
					net.Send(v)
				end
			end
		end, nAdmin.AutoComplete)
	end

	nAdmin.FirstAddCommand()

	function nAdmin.Message(ply, msg)
		if not IsValid(ply) then
			nAdmin.Print("nAdmin.Message - ошибка.")
			debug.Trace()
			return
		end
		if not msg then
			nAdmin.Print("nAdmin.Message - ошибка.")
			debug.Trace()
			return
		end
		msg = util.TableToJSON(msg)
		local compress = util.Compress(msg)
		local compress_ = #compress
		net.Start("nadmin_message")
			net.WriteUInt(1, 2)
			net.WriteUInt(compress_, 16)
			net.WriteData(compress, compress_)
		net.Send(ply)
	end

	function nAdmin.PrintMessage(msg)
		if not msg then
			nAdmin.Print("nAdmin.Message - ошибка.")
			debug.Trace()
			return
		end
		msg = util.TableToJSON(msg)
		local compress = util.Compress(msg)
		local compress_ = #compress
		net.Start("nadmin_message")
			net.WriteUInt(1, 2)
			net.WriteUInt(compress_, 16)
			net.WriteData(compress, compress_)
		net.Broadcast()
	end

	function nAdmin.Warn(ply, msg)
		nAdmin.Message(ply, {Color(150, 150, 150), msg})
	end

	function nAdmin.WarnAll(msg)
		nAdmin.PrintMessage({Color(150, 150, 150), msg})
	end

	function nAdmin.PrintAndWarn(var)
		nAdmin.Print(var)
		nAdmin.WarnAll(var)
	end

	function nAdmin.ValidCheckCommand(args, count, ply, cmd)
		local has = true
		if not isnumber(count) then
			nAdmin.Print("ValidCheckCommand > count должен быть числом.")
			return
		end
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
		local TF = pl:Team() <= Global_Teams[nAdmin.Commands[cmd].T].num
		if TF == false then
			nAdmin.Warn(pl, "У вас нет прав использовать эту команду.")
		end
		return TF
	end
end

if CLIENT then
	net.Receive("nadmin_message", function()
		local mode = net.ReadUInt(2)
		if mode == 3 then
			local a = net.ReadString()
			nAdmin.LastSystime = SysTime()
			if IsValid(nGUI) then
				hook.Run("nAdmin_SystimeUpdate", nAdmin.LastSystime, a)
			end
			return
		end
		local int = net.ReadUInt(16)
		local data = net.ReadData(int)
		local decompress = util.Decompress(data)
		decompress = util.JSONToTable(decompress or "{}")
		if mode == 1 then
			chat.AddText(unpack(decompress))
		elseif mode == 2 then
			for k, v in next, decompress do
				if nAdmin.Commands[k] then continue end
				nAdmin.Commands[k] = v
			end
		end
	end)
end

if CLIENT or SERVER then
	function PT(...)
		return PrintTable(...)
	end

	function p(...)
		return print(...)
	end

	function nAdmin.Print(...)
		Msg"[nAdmin] "p(...)
	end

	function nAdmin.AddCommand(cmd, autocomplete, func)
		if SERVER then
			if autocomplete == true then
				autocomplete = nAdmin.AutoComplete
			end
			nAdmin.Commands[cmd] = {func = func, ac = autocomplete}
		else
			nAdmin.Commands[cmd] = {func = autocomplete}
		end
	end

	function nAdmin.FindByNick(nick)
		local ent
		nick = nick or ""
		nick = string.lower(nick)
		for _, v in ipairs(player.GetAll()) do
			local name = v:Name()
			name = string.lower(name)
			if string.match(name, nick) then
				ent = v
			end
		end
		return ent
	end

	local str = getmetatable("")
	function isstring(var)
		return getmetatable(var) == str
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
		-- [[ SHARED ]] --
		for k, v in ipairs(file.Find("nadmin/*", "LUA")) do
			if v == "sh_func.lua" then
				continue
			end
			include("nadmin/" .. v)
			AddCSLuaFile("nadmin/" .. v)
			nAdmin.Print("[SHARED] Загружено: " .. v)
		end
		for k, v in ipairs(file.Find("nadmin/client/*", "LUA")) do
			if CLIENT then
				include("nadmin/client/" .. v)
			else
				AddCSLuaFile("nadmin/client/" .. v)
			end
			nAdmin.Print("[CLIENT] Загружено: " .. v)
		end
		if SERVER then
			-- [[ SERVER ]] --
			for k, v in ipairs(file.Find("nadmin/server/*", "LUA")) do
				include("nadmin/server/" .. v)
				nAdmin.Print("[SERVER] Загружено: " .. v)
			end
		end
		-- [[ MODULES ]] --
		for k, v in ipairs(file.Find("nadmin/modules/*", "LUA")) do
			if string.StartWith(v, "sh_") then
				AddCSLuaFile("nadmin/modules/" .. v)
			end
			include("nadmin/modules/" .. v)
			nAdmin.Print("[MODULES] Загружено: " .. v)
			table.insert(nAdmin.Modules, string.sub(v, 1, #v - 4))
		end
	end

	nAdmin.UpdateFiles()
end