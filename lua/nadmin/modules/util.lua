local bans = bans or util.JSONToTable(file.Read("nadmin/bans.txt", "DATA"))
local next = next
nAdmin.BanList = bans

local singleplayer = game.SinglePlayer()
if singleplayer then
	nAdmin.Print("Модуль util отключен, но был загружен. Причина: сервер запущен в одиночной игре.")
	return
end

function nAdmin.UpdateBans()
	if not file.Exists("nadmin/bans.txt", "DATA") then
		nAdmin.Print("Файл \"nadmin/bans.txt\" не существует. Создаю...")
		file.Write("nadmin/bans.txt", "{}")
	end
	local function write_bans()
		file.Write("nadmin/bans.txt", util.TableToJSON(bans))
		coroutine.yield()
	end
	local a = SysTime()
	local co = coroutine.create(write_bans)
	coroutine.resume(co)
end

function nAdmin.AddBan(ply_, minutes, reason, o, banid_)
	local ply_Kick = nAdmin.FindByNick(ply_)
	local reason_warn = ""
	if banid_ then
		goto zcont
	end
	if ply_Kick == nil then
		nAdmin.Warn(o, "Игрока с таким именем нет на сервере!")
		return
	end
	if ply_Kick == o or o:SteamID() == ply_ then
		nAdmin.Warn(o, "Вы не можете забанить самого себя!")
		return
	end
	if ply_Kick:Team() <= o:Team() then
		nAdmin.Warn(o, "Вы не можете забанить игрока выше/равного по привилегии!")
		return
	end
	::zcont::
	if banid_ == true then
		if not string.StartWith(ply_, "STEAM_0") then
			nAdmin.Warn(o, "Неправильно введён аргумент!")
			return
		end
		local a = Global_Teams[nGSteamIDs[o:SteamID()].group].num or 0
		local b = nGSteamIDs[ply_]
		if b == nil then
			b = Global_Teams["user"].num
			goto hui
		end
		b = Global_Teams[nGSteamIDs[ply_]].num
		::hui::
		if a > b then
			nAdmin.Warn(o, "Вы не можете забанить данный SteamID, т.к. у него выше/равная привилегия.")
			return
		end
		ply = ply_
	end
	bans[ply] = {time = tonumber(os.time()) + (minutes * 60), reason = reason}
	if ply_Kick ~= false and not banid_ then
		ply_Kick:Kick("Вы забанены. Причина: " .. bans[ply].reason .. "; время: " .. string.NiceTime(bans[ply].time - tonumber(os.time())))
	end
	nAdmin.UpdateBans()
	nAdmin.unbanUpdate()
	nAdmin.WarnAll(tostring(ply) .. " был заблокирован с причиной: " .. bans[ply].reason .. "; на: " .. string.NiceTime(bans[ply].time - tonumber(os.time())) .. "; админом: " .. o:Name())
end

hook.Add("CheckPassword", "ban_System", function(id)
	if bans[id] then
		return false,
		"Вы забанены на [RU] Уютный Сандбокс. Причина: " .. bans[id].reason .. "; время до разбана: " .. bans[id].time - tonumber(os.time())
	end
end)

function nAdmin.unban(id)
	bans[id] = nil
	nAdmin.UpdateBans()
end

function nAdmin.unbanUpdate()
	if not timer.Exists("nAdmin_unbanUpdate") then
		timer.Create("nAdmin_unbanUpdate", 3600, 0, nAdmin.unbanUpdate)
	end
	for id, data in next, bans do
		if data.time ~= 0 then
			if data.time - os.time() < 3600 then
				if timer.Exists("nAdmin_banRemove_" .. id) then
					timer.Remove("nAdmin_banRemove_" .. id)
				end
				timer.Create("nAdmin_banRemove_" .. id, data.time - os.time(), 1, function()
					nAdmin.unban(id)
				end)
			end
		end
	end
end

hook.Add("InitPostEntity", "nAdmin_unbanUpdate", function()
	hook.Remove("InitPostEntity", "nAdmin_unbanUpdate")
	nAdmin.unbanUpdate()
	nAdmin.UpdateBans()
	nAdmin.Print("В базе данных насчитывается около: " .. table.Count(bans) .. " банов.")
end)

local curtime = CurTime()

nAdmin.AddCommand("ban", true, function(ply, cmd, args)
	local check = nAdmin.ValidCheckCommand(args, 3, ply, "ban")
	if not check then
		return
	end
	if curtime > CurTime() then
		nAdmin.Warn(ply, "Подождите ещё " .. math.Round(curtime - CurTime()) .. " секунд.")
		return
	end
	curtime = CurTime() + 10
	local min_ = args[2]
	local m2 = tonumber(string.sub(min_, 1, #min_ - 1))
	if string.EndsWith(min_, "m") then
		m2 = m2
	elseif string.EndsWith(min_, "h") then
		m2 = m2 * 60
	elseif string.EndsWith(min_, "d") then
		m2 = m2 * 60 * 24
	elseif string.EndsWith(min_, "w") then
		m2 = m2 * 60 * 24 * 7
	else
		nAdmin.Warn(ply, "Введите корректное значение 2 аргумента. (Пример: 7m, 7h, 7d, 7w)")
		return
	end
	nAdmin.AddBan(args[1], m2, args[3], ply)
end)
nAdmin.SetTAndDesc("ban", "moderator", "Банит игрока. arg1 - ник, arg2 - время [7m, 7h, 7d, 7w], arg3 - причина.")

nAdmin.AddCommand("banid", true, function(ply, cmd, args)
	local check = nAdmin.ValidCheckCommand(args, 3, ply, "banid")
	if not check then
		return
	end
	if curtime > CurTime() then
		nAdmin.Warn(ply, "Подождите ещё " .. math.Round(curtime - CurTime()) .. " секунд.")
		return
	end
	curtime = CurTime() + 10
	local min_ = args[2]
	local m2 = tonumber(string.sub(min_, 1, #min_ - 1))
	if string.EndsWith(min_, "m") then
		m2 = m2
	elseif string.EndsWith(min_, "h") then
		m2 = m2 * 60
	elseif string.EndsWith(min_, "d") then
		m2 = m2 * 60 * 24
	elseif string.EndsWith(min_, "w") then
		m2 = m2 * 60 * 24 * 7
	else
		nAdmin.Warn(ply, "Введите корректное значение 2 аргумента. (Пример: 7m, 7h, 7d, 7w)")
		return
	end
	nAdmin.AddBan(args[1], m2, args[3]:Trim(), ply, true)
end)
nAdmin.SetTAndDesc("banid", "admin", "Банит игрока по SteamID. arg1 - SteamID, arg2 - время [7m, 7h, 7d, 7w], arg3 - причина.")

nAdmin.AddCommand("unban", true, function(ply, cmd, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "unban")
	if not check then
		return
	end
	nAdmin.unban(args[1]:Trim())
	nAdmin.WarnAll(ply:Name().. " разблокировал: " .. tostring(args[1]))
end)
nAdmin.SetTAndDesc("unban", "moderator", "Разбанивает игрока. arg1 - SteamID игрока.")

nAdmin.AddCommand("bancount", true, function(ply, cmd, args)
	nAdmin.Warn(ply, "В базе данных насчитывается около: " .. table.Count(bans) .. " банов.")
end)
nAdmin.SetTAndDesc("bancount", "admin", "Количество игроков в бане.")

nAdmin.AddCommand("kick", true, function(ply, cmd, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "kick")
	if not check then
		return
	end
	if curtime > CurTime() then
		nAdmin.Warn(ply, "Подождите ещё " .. math.Round(curtime - CurTime()) .. " секунд.")
		return
	end
	curtime = CurTime() + 10
	local pl = nAdmin.FindByNick(args[1])
	local reason = args[2]
	if reason then
		nAdmin.WarnAll(ply:Name() .. " кикнул: " .. pl:Name() .. ", с причиной: " .. reason)
		pl:Kick("Вас кикнул " .. ply:Name() .. "; с причиной: " .. reason)
		return
	end
	nAdmin.WarnAll(ply:Name() .. " кикнул: " .. pl:Name())
	pl:Kick("Вы были кикнуты админом: " .. ply:Name() .. ".")
end)
nAdmin.SetTAndDesc("kick", "moderator", "Кикает игрока. arg1 - ник игрока.")

local vec = Vector(-15999, -15999, -15999)

nAdmin.AddCommand("jail", true, function(ply, cmd, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "jail")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	local function pl_Null()
		pl.InJail = false
	end
	pl_Null()
	local arg2 = tonumber(args[2]) or 0
	if arg2 ~= 0 then
		nAdmin.PrintAndWarn(ply:Name() .. " засунул в гулаг " .. pl:Name() .. " на " .. arg2 .. " секунд.")
		timer.Create(tostring(pl) .. "_nAdminJail", arg2, 1, function()
			pl_Null()
		end)
		goto skip
	end
	nAdmin.PrintAndWarn(ply:Name() .. " засунул в гулаг " .. pl:Name() .. ".")
	::skip::
	pl.InJail = true
	pl:SetPos(vec)
	timer.Create(tostring(pl) .. "nAdmin_ToJail", .2, 0, function()
		if pl.InJail == true then
			pl:SetPos(vec)
		else
			pl:Spawn()
			timer.Remove(tostring(pl) .. "nAdmin_ToJail")
		end
	end)
end)
nAdmin.SetTAndDesc("jail", "builderreal", "Садит человека в клетку. arg1 - ник игрока, arg2 - количество секунд.")

nAdmin.AddCommand("unjail", true, function(ply, cmd, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "unjail")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	local arg2 = tonumber(args[2]) or 0
	if not pl.InJail then
		return
	end
	if timer.Exists(tostring(pl) .. "_nAdminJail") then
		timer.Remove(tostring(pl) .. "_nAdminJail")
	end
	pl.InJail = false
	pl:Spawn()
	nAdmin.PrintAndWarn(ply:Name() .. " выпустил из гулага " .. pl:Name() .. ".")
end)
nAdmin.SetTAndDesc("unjail", "builderreal", "Освобождает человека с гулага. arg1 - ник игрока.")

hook.Add("PlayerSpawnObject", "restrictJail", function(ply)
	if ply.InJail then
		return false
	end
end)

nAdmin.AddCommand("noclip", true, function(ply, cmd, args)
	local pl = ply
	if pl:GetMoveType() == MOVETYPE_WALK then
		pl:SetMoveType( MOVETYPE_NOCLIP )
	elseif pl:GetMoveType() == MOVETYPE_NOCLIP then
		pl:SetMoveType( MOVETYPE_WALK )
	else
		nAdmin.Warn(ply, "Сейчас нельзя пользоваться Noclip'ом!")
	end
end)
nAdmin.SetTAndDesc("noclip", "builderreal", "Включает/выключает Noclip.")

nAdmin.AddCommand("spectate", true, function(ply, cmd, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "spectate")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	local function upd_Spectate()
		ply:SetObserverMode(OBS_MODE_IN_EYE)
		ply:SpectateEntity(pl)
	end
	upd_Spectate()
	nAdmin.Print(ply:Name() .. " следит за " .. pl:Name())
	local function del_AllSpectateHooks()
		ply:SetObserverMode(0)
		ply:UnSpectate()
		hook.Remove("KeyPress", ply:EntIndex().. "_nAdmin_UnSpectate")
		hook.Remove("PlayerDisconnected", ply:EntIndex().. "_nAdmin_UnSpectate")
		hook.Remove("PlayerSpawn", ply:EntIndex() .. "_nAdmin_UnSpectate")
	end
	hook.Add("KeyPress", ply:EntIndex().. "_nAdmin_UnSpectate", function(pl_, k)
		if pl_ ~= ply then return end
		if k ~= 8 and k ~= 16 and k ~= 512 and k ~= 1024 then return end
		del_AllSpectateHooks()
		nAdmin.Print(ply:Name() .. " больше не следит за " .. pl:Name())
	end)
	hook.Add("PlayerDisconnected", ply:EntIndex().. "_nAdmin_UnSpectate", function(pl_)
		if pl_ ~= pl or pl_ ~= ply then return end
		del_AllSpectateHooks()
		nAdmin.Print(ply:Name() .. " больше не следит за " .. pl:Name())
	end)
	hook.Add("PlayerSpawn", ply:EntIndex() .. "_nAdmin_UnSpectate", upd_Spectate)
end)
nAdmin.SetTAndDesc("spectate", "moderator", "Включает режим наблюдения за игроком. arg1 - имя игрока.")

nAdmin.AddCommand("gag", false, function(ply, cmd, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "gag")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	if not pl.Gagged then
		pl.Gagged = true
	else
		pl.Gagged = false
	end
	nAdmin.PrintAndWarn(ply:Name() .. " " .. (pl.Gagged and "запретил" or "разрешил") .. " говорить в ГЧ " .. pl:Name().. ".")
end)
nAdmin.SetTAndDesc("gag", "moderator", "Запретить/разрешить игроку говорить. arg1 - ник.")

local function GagUngag(_, a)
	if a.Gagged then
		return false
	end
end
hook.Add("PlayerCanHearPlayersVoice", "nAdmin_gag", GagUngag)

nAdmin.AddCommand("goto", false, function(ply, cmd, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "goto")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	ply:SetPos(pl:EyePos() + Vector(pl:EyeAngles():Right()[1], 0, 0) * 150)
	nAdmin.PrintAndWarn(ply:Name() .. " телепортировался к " .. pl:Name().. ".")
end)
nAdmin.SetTAndDesc("goto", "e2_coder", "Телепортироваться к игроку. arg1 - ник.")

nAdmin.AddCommand("bring", false, function(ply, cmd, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "bring")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	pl:SetPos(ply:EyePos() + Vector(ply:EyeAngles():Right()[1], 0, 0) * 150)
	nAdmin.PrintAndWarn(ply:Name() .. " телепортировал к себе " .. pl:Name().. ".")
end)
nAdmin.SetTAndDesc("bring", "osobenniy2", "Телепортировать игрока к себе. arg1 - ник.")

nAdmin.AddCommand("mute", false, function(ply, cmd, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "mute")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	if not pl.Muted then
		pl.Muted = true
	else
		pl.Muted = false
	end
	nAdmin.PrintAndWarn(ply:Name() .. " " .. (pl.Gagged and "запретил" or "разрешил") .. " писать в чат " .. pl:Name().. ".")
end)
nAdmin.SetTAndDesc("mute", "osobenniy2", "Запретить/разрешить игроку писать в чат. arg1 - ник.")

local function plSay(pl, txt)
	if pl.Muted then return "" end
end
hook.Add("PlayerSay", "nAdmin_mute", plSay)

nAdmin.AddCommand("mgag", false, function(ply, cmd, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "mgag")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	if not pl.Muted then
		pl.Muted = true
	else
		pl.Muted = false
	end

	if not pl.Gagged then
		pl.Gagged = true
	else
		pl.Gagged = false
	end

	if pl.Gagged ~= pl.Muted then
		pl.Gagged = true
		pl.Muted = true
		nAdmin.Print("Значения Gag и Mute различаются. Мучу и запрещаю игроку писать в чат!")
	end
	nAdmin.PrintAndWarn(ply:Name() .. " " .. (pl.Gagged and "запретил" or "разрешил") .. "  писать в чат и говорить в ГЧ " .. pl:Name().. ".")
end)
nAdmin.SetTAndDesc("mgag", "admin", "Запретить/разрешить игроку писать в чат и говорить в ГЧ. arg1 - ник.")

nAdmin.AddCommand("banip", true, function(ply, cmd, args)
	local check = nAdmin.ValidCheckCommand(args, 2, ply, "banip")
	if not check then
		return
	end
	if curtime > CurTime() then
		nAdmin.Warn(ply, "Подождите ещё " .. math.Round(curtime - CurTime()) .. " секунд.")
		return
	end
	curtime = CurTime() + 10
	local min_ = args[2]
	local m2 = tonumber(string.sub(min_, 1, #min_ - 1))
	if string.EndsWith(min_, "m") then
		m2 = m2
	elseif string.EndsWith(min_, "h") then
		m2 = m2 * 60
	elseif string.EndsWith(min_, "d") then
		m2 = m2 * 60 * 24
	elseif string.EndsWith(min_, "w") then
		m2 = m2 * 60 * 24 * 7
	else
		nAdmin.Warn(ply, "Введите корректное значение 2 аргумента. (Пример: 7m, 7h, 7d, 7w)")
		return
	end
	RunConsoleCommand("addip", m2, args[1]:Trim())
	RunConsoleCommand("writeip")
	nAdmin.Print(ply:Name() .. " забанил: " .. args[1]:Trim())
end)
nAdmin.SetTAndDesc("banip", "admin", "Банит IP адрес. arg1 - время, arg2 - IP.")

nAdmin.AddCommand("unbanip", true, function(ply, cmd, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "unbanip")
	if not check then
		return
	end
	if curtime > CurTime() then
		nAdmin.Warn(ply, "Подождите ещё " .. math.Round(curtime - CurTime()) .. " секунд.")
		return
	end
	curtime = CurTime() + 10
	RunConsoleCommand("removeip", args[1]:Trim())
	RunConsoleCommand("writeip")
	nAdmin.Print(ply:Name() .. " разбанивает: " .. args[1]:Trim())
end)
nAdmin.SetTAndDesc("unbanip", "admin", "Разбанивает IP адрес. arg1 - IP.")
