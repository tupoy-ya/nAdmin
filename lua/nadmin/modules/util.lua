local bans = {} -- util.JSONToTable(file.Read("nadmin/bans.txt", "DATA") or "{}") or {}
local next = next
nAdmin.BanList = bans

util.AddNetworkString("nAdmin_JailHUD")

function nAdmin.BanInSQL(steamid, time, reason, banned_by)
	if not nAdminDB then return false end
	local Q = nAdminDB:query("REPLACE INTO nAdmin_bans (ind, plyban, reason, time, banned_by) VALUES (" .. os.time() .. ", " .. SQLStr(steamid) .. ", " .. SQLStr(reason) .. ", " .. SQLStr(time) .. ", " .. SQLStr(banned_by) .. ")")
	function Q:onError(_, err)
		nAdmin.Print("Запрос выдал ошибку: " .. err)
	end
	function Q:onAborted(q)
		nAdmin.Print("Запрос был отклонён: " .. q)
	end
	Q:start()
end

function nAdmin.TbansFromSQL()
	if not nAdminDB then return false end
	local Q = nAdminDB:query("SELECT * FROM nAdmin_bans")
	function Q:onError(err)
		nAdmin.Print("Запрос выдал ошибку: " .. err)
	end
	Q:start()
	function Q:onSuccess(data)
		if data then
			for k, v in next, data do
				bans[v.plyban] = {time = v.time, reason = v.reason, banned_by = v.banned_by}
			end
			if timer.Exists("nAdmin_bdReload") then
				timer.Remove("nAdmin_bdReload")
			end
			timer.Create("nAdmin_bdReload", 2, 1, function()
				nAdmin.BanList = bans
			end)
		end
	end
end
nAdmin.TbansFromSQL()

local steamidtoacid = function(steamid)
    local acc32 = tonumber(steamid:sub(11))
    return (acc32 * 2) + tonumber(steamid:sub(9,9))
end

function nAdmin.AddBan(ply_, minutes, reas, o, banid_, nospam) -- это уёбищный код, но так как я ленивая залупа я не хочу это переписывать
	if not nAdminDB then return false end
	local ply_Kick = nAdmin.FindByNick(ply_)
	local reason_warn = ""
	if ply_Kick == o then
		nAdmin.Warn(o, "Вы не можете забанить самого себя!")
		return
	end
	if banid_ then
		goto zcont
	end
	if ply_Kick == nil then
		nAdmin.Warn(o, "Игрока с таким именем нет на сервере!")
		return
	end
	if ply_Kick:Team() <= o:Team() then
		nAdmin.Warn(o, "Вы не можете забанить игрока выше/равного по привилегии!")
		return
	end
	::zcont::
	if banid_ == true then
		if not nAdmin.ValidSteamID(ply_) then
			nAdmin.Warn(o, "Неправильно введён SteamID!")
			return
		end
		local this = steamidtoacid(ply_)
		ply_ = util.SteamIDTo64(ply_)
		if ply_ == o:SteamID64() then
			nAdmin.Warn(o, "Вы не можете забанить самого себя!")
			return
		end
		local a
		local b
		if o:SteamID() == "STEAM_0:0:0" then
			goto conskip
		end
		a = Global_Teams[nGSteamIDs[o:AccountID()]].num
		b = nGSteamIDs[this]
		if b == nil then
			b = Global_Teams["user"].num
			goto hui
		end
		b = (Global_Teams[nGSteamIDs[this]] and Global_Teams[nGSteamIDs[this]].num) or table.Count(Global_Teams)
		::hui::
		if a > b then
			nAdmin.Warn(o, "Вы не можете забанить данный SteamID, т.к. у него выше/равная привилегия.")
			return
		end
		::conskip::
		ply_Kick = ply_
	end
	local banM = os.time() + (tonumber(minutes) * 60)
	if tonumber(minutes) == 0 then
		banM = 0
	end
	local who_banned = o:NameWithoutTags()
	local time = (banM ~= 0 and (banM - os.time())) or 0
	local str = ""
	if time == 0 then
		str = "Бесконечно"
	else
		str = string.NiceTime(time)
	end
	if ply_Kick ~= false and not banid_ and ply_Kick:IsPlayer() then
		local stid = ply_Kick:SteamID64():lower()
		bans[stid] = {time = banM, reason = reas, banned_by = who_banned}
		nAdmin.BanInSQL(stid, banM, reas, who_banned)
		if not nospam then
			local msg = ply_Kick:NameWithoutTags() .. " был заблокирован с причиной: " .. bans[stid].reason .. "; на: " .. str .. "; забанил: " .. who_banned
			nAdmin.WarnAll(msg)
			if discord then
				discord.SendMessage("632473866794434567", {embeds = {[1] = {author = {name = ply_Kick:NameWithoutTags() .. " (" .. ply_Kick:SteamID() .. ")", url = "http://steamcommunity.com/profiles/".. ply_Kick:SteamID64() .."/",}, title = "Опа! А вот и бан.", color = 10038562, description = "Был забанен по причине: " .. bans[stid].reason .. ", на: " .. str .. ", заблокировал: " .. who_banned}}})
			end
		end
		ply_Kick:Kick("Вы забанены. Причина: " .. bans[stid].reason .. "; время: " .. str)
		goto skipb
	end
	bans[ply_Kick] = {time = banM, reason = reas, banned_by = who_banned}
	nAdmin.BanInSQL(ply_Kick, banM, reas, who_banned)
	if not nospam then
		nAdmin.WarnAll(util.SteamIDFrom64(ply_Kick) .. " был заблокирован с причиной: " .. bans[ply_Kick].reason .. "; на: " .. str .. "; забанил: " .. who_banned)
		if discord then
			discord.SendMessage("632473866794434567", {embeds = {[1] = {author = {name = util.SteamIDFrom64(ply_Kick), url = "http://steamcommunity.com/profiles/".. ply_Kick .."/",}, title = "Опа! А вот и бан.", color = 10038562, description = "Был забанен по причине: " .. bans[ply_Kick].reason .. ", на: " .. str .. ", заблокировал: " .. who_banned}}})
		end
	end
	game.KickID(util.SteamIDFrom64(ply_Kick), "Вы забанены. Причина: " .. bans[ply_Kick].reason .. "; время: " .. str)
	::skipb::
	nAdmin.unbanUpdate()
end

hook.Add("CheckPassword", "ban_System", function(id)
	if bans[id] then
		local reas = bans[id].reason or ""
		if reas:Trim() == "" then
			reas = "Нет причины"
		end
		nAdmin.Print(util.SteamIDFrom64(id) .. " попытался зайти на сервер, но у него блокировка по причине: " .. reas)
		if bans[id].time ~= 0 then
			return false,
			"Вы заблокированы на [RU] Уютный Сандбокс. Причина: " .. reas .. "; время до разбана: " .. string.NiceTime(bans[id].time - os.time())
		else
			return false,
			"Вы заблокированы на [RU] Уютный Сандбокс. Причина: " .. reas .. "; время до разбана: Никогда"
		end
	end
end)

hook.Add("PlayerAuthed", "ban_System", function(ply)
	local t = bans[ply:OwnerSteamID64()]
	if t then
		local steamid = ply:SteamID()
		ply:Kick("Заблокирован")
		if t.time == 0 then
			nAdmin.AddBan(steamid, 0, t.reason or "Нет причины", Entity(0), true, true)
		else
			if t.time - os.time() > 0 then
				nAdmin.AddBan(steamid, t.time - os.time(), t.reason or "Нет причины", Entity(0), true, true)
			end
		end
	end
end)

function nAdmin.unban(id)
	local Q = nAdminDB:query("DELETE FROM nAdmin_bans WHERE plyban = " .. SQLStr(id))
	function Q:onError(err)
		nAdmin.Print("Запрос выдал ошибку: " .. err)
	end
	Q:start()      
	bans[id] = nil
	nAdmin.Print(id .. " > был удалён из списка банов.")
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
	--nAdmin.UpdateBans()
	nAdmin.Print("В базе данных насчитывается около: " .. table.Count(bans) .. " банов.")
end)

local curtime = CurTime()

if nAdminDB then
	nAdmin.AddCommand("ban", true, function(ply, args)
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
		if tonumber(min_) == 0 then
			m2 = min_
			goto skip
		end
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
		::skip::
		local txt = ""
		for k, v in next, args do
			if k >= 3 then
				txt = txt .. " " .. v
			end
		end
		nAdmin.AddBan(args[1], m2, txt, ply)
	end)
	nAdmin.SetTAndDesc("ban", "moderator", "Банит игрока. arg1 - ник, arg2 - время [7m, 7h, 7d, 7w], arg3 - причина.")

	nAdmin.AddCommand("banid", true, function(ply, args)
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
		if tonumber(min_) == 0 then
			m2 = min_
			goto skip
		end
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
		::skip::
		local txt = ""
		for k, v in next, args do
			if k >= 3 then
				txt = txt .. " " .. v
			end
		end
		nAdmin.AddBan(args[1], m2, txt, ply, true)
	end)
	nAdmin.SetTAndDesc("banid", "moderator", "Банит игрока по SteamID. arg1 - SteamID, arg2 - время [7m, 7h, 7d, 7w], arg3 - причина.")

	nAdmin.AddCommand("unban", true, function(ply, args)
		local check = nAdmin.ValidCheckCommand(args, 1, ply, "unban")
		if not check then
			return
		end
		local stid = util.SteamIDTo64(args[1]:Trim())
		nAdmin.unban(stid)
		nAdmin.WarnAll(ply:NameWithoutTags().. " разблокировал: " .. args[1]:Trim():upper())
		if discord then
			discord.SendMessage("632473866794434567", {embeds = {[1] = {author = {name = util.SteamIDFrom64(stid), url = "http://steamcommunity.com/profiles/".. stid .."/",}, title = "Аккаунт был разбанен.", color = 2123412, description = "Разблокировал: " .. ply:NameWithoutTags() .. "; время: " .. os.date("%H:%M:%S - %d/%m/%Y" , os.time())}}})
		end
	end)
	nAdmin.SetTAndDesc("unban", "moderator", "Разбанивает игрока. arg1 - SteamID игрока.")

	nAdmin.AddCommand("bancount", true, function(ply, args)
		nAdmin.Warn(ply, "В базе данных насчитывается около: " .. table.Count(bans) .. " банов.")
	end)
	nAdmin.SetTAndDesc("bancount", "admin", "Количество игроков в бане.")
end

nAdmin.AddCommand("kick", true, function(ply, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "kick")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	local txt = ""
	for k, v in next, args do
		if k >= 2 then
			txt = txt .. " " .. v
		end
	end
	if txt:Trim() ~= "" then
		pl:Kick("Вас кикнул " .. ply:NameWithoutTags() .. "; с причиной: " .. txt)
		return
	end
	pl:Kick("Вы были кикнуты: " .. ply:NameWithoutTags() .. ".")
end)
nAdmin.SetTAndDesc("kick", "moderator", "Кикает игрока. arg1 - ник игрока, arg2 - причина.")

local vec = Vector(-15999, -15999, -15999)

nAdmin.AddCommand("jail", true, function(ply, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "jail")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil and ply ~= Entity(0) then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	local arg2 = tonumber(args[2]) or 0
	local tostr = tostring(pl)
	if arg2 ~= 0 then
		nAdmin.WarnAll(ply:NameWithoutTags() .. " засунул в гулаг " .. pl:NameWithoutTags() .. " на " .. arg2 .. " секунд.")
		timer.Create(tostr .. "_nAdminJail", arg2, 1, function()
			pl:SetNWBool("nAdmin_InJail", false)
		end)
		goto skip
	end
	nAdmin.WarnAll(ply:NameWithoutTags() .. " засунул в гулаг " .. pl:NameWithoutTags() .. ".")
	::skip::
	pl:SetNWBool("nAdmin_InJail", true)
	pl:SetPos(vec)
	local plName = pl:NameWithoutTags()
	local as = tostring(pl)
	timer.Create(as .. "nAdmin_ToJail", 0, 0, function()
		if not pl:IsValid() then
			timer.Remove(as .. "nAdmin_ToJail")
			timer.Remove(tostr .. "_nAdminJail")
			nAdmin.WarnAll(plName .. " вышел из игры во время нахождения в гулаге!")
			return
		end
		if pl:GetNWBool("nAdmin_InJail") == true then
			pl:SetPos(vec)
		else
			pl:Spawn()
			pl.Freezed = false
			timer.Remove(as .. "nAdmin_ToJail")
		end
	end)
	timer.Simple(.35, function()
		net.Start("nAdmin_JailHUD")
			net.WriteFloat(arg2)
		net.Send(pl)
	end)
	if pl:InVehicle() then
		pl:ExitVehicle()
	end
end)
nAdmin.SetTAndDesc("jail", "builderreal", "Садит человека в гулаг. arg1 - ник игрока, arg2 - количество секунд.")

nAdmin.AddCommand("unjail", true, function(ply, args)
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
	if not pl:GetNWBool("nAdmin_InJail") then
		return
	end
	local tpl = tostring(pl)
	if timer.Exists(tpl .. "_nAdminJail") then
		timer.Remove(tpl .. "_nAdminJail")
	end
	pl.Freezed = false
	pl:SetNWBool("nAdmin_InJail", false)
	pl:Spawn()
	nAdmin.WarnAll(ply:NameWithoutTags() .. " выпустил из гулага " .. pl:NameWithoutTags() .. ".")
end)
nAdmin.SetTAndDesc("unjail", "builderreal", "Освобождает человека с гулага. arg1 - ник игрока.")

hook.Add("CanTool", "restrictJail", function(ply)
	if ply:GetNWBool("nAdmin_InJail") or ply.Freezed then
		return false
	end
end)

local alllogs = {
	"Prop",
	"Ragdoll",
	"SENT",
	"Effect",
	"Vehicle"
}

for i = 1, #alllogs do
	local _log = alllogs[i]
	hook.Add("PlayerSpawn" .. _log, "restrictJail", function(ply)
		if ply:GetNWBool("nAdmin_InJail") or ply.Freezed then
			return false
		end
	end)
end

hook.Add("CanPlayerSuicide", "restrictJail", function(ply)
	if ply:GetNWBool("nAdmin_InJail") or ply.Freezed then
		return false
	end
end)

nAdmin.AddCommand("spectate", true, function(ply, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "spectate")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	local function upd_Spectate(cock)
		if cock and cock == pl then
			if not IsValid(ply) then
				del_AllSpectateHooks()
			end
			ply:SetObserverMode(OBS_MODE_IN_EYE)
			ply:SpectateEntity(pl)
		end
	end
	ply:SetObserverMode(OBS_MODE_IN_EYE)
	ply:SpectateEntity(pl)
	nAdmin.Print(ply:NameWithoutTags() .. " следит за " .. pl:NameWithoutTags())
	local index = ply:EntIndex()
	local function del_AllSpectateHooks()
		ply:SetObserverMode(0)
		ply:UnSpectate()
		hook.Remove("KeyPress", index .. "_nAdmin_UnSpectate")
		hook.Remove("PlayerDisconnected", index .. "_nAdmin_UnSpectate")
		hook.Remove("PlayerSpawn", index .. "_nAdmin_UnSpectate")
	end
	hook.Add("KeyPress", index.. "_nAdmin_UnSpectate", function(pl_, k)
		if pl_ ~= ply then return end
		if k ~= 8 and k ~= 16 and k ~= 512 and k ~= 1024 then return end
		del_AllSpectateHooks()
		nAdmin.Print(ply:NameWithoutTags() .. " больше не следит за " .. pl:NameWithoutTags())
	end)
	hook.Add("PlayerDisconnected", index.. "_nAdmin_UnSpectate", function(pl_)
		if pl_ ~= pl then return end
		del_AllSpectateHooks()
		nAdmin.Print(ply:NameWithoutTags() .. " больше не следит за " .. pl:NameWithoutTags())
	end)
	hook.Add("PlayerSpawn", index .. "_nAdmin_UnSpectate", upd_Spectate)
end)
nAdmin.SetTAndDesc("spectate", "osobenniy2", "Включает режим наблюдения за игроком. arg1 - ник игрока.")
nAdmin.CmdHidden("spectate")
nAdmin.ConsoleBlock("spectate")

nAdmin.AddCommand("gag", false, function(ply, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "gag")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	pl.Gagged = true
	nAdmin.WarnAll(ply:NameWithoutTags() .. " разрешил говорить в ГЧ " .. pl:NameWithoutTags().. ".")
end)
nAdmin.SetTAndDesc("gag", "moderator", "Запретить игроку говорить. arg1 - ник.")

nAdmin.AddCommand("ungag", false, function(ply, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "ungag")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	pl.Gagged = false
	nAdmin.WarnAll(ply:NameWithoutTags() .. " запретил говорить в ГЧ " .. pl:NameWithoutTags() .. ".")
end)
nAdmin.SetTAndDesc("ungag", "moderator", "Разрешить игроку говорить. arg1 - ник.")

local function GagUngag(_, a)
	if a.Gagged then
		return false
	end
end
hook.Add("PlayerCanHearPlayersVoice", "nAdmin_gag", GagUngag)

nAdmin.AddCommand("goto", false, function(ply, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "goto")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	if ply == pl then
		nAdmin.Warn(ply, "Вы не можете телепортироваться к самому себе.")
		return
	end
	ply.OldPositionTP = ply:GetPos()
	ply:SetPos(pl:EyePos() + Vector(pl:EyeAngles():Right()[1], 0, 0) * 150)
end)
nAdmin.SetTAndDesc("goto", "noclip", "Телепортироваться к игроку. arg1 - ник.")

nAdmin.AddCommand("return", false, function(ply, args)
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		pl = ply
	end
	if not pl.OldPositionTP then
		nAdmin.Warn(ply, "Игрок никуда не телепортировался.")
		return
	end
	pl:SetPos(pl.OldPositionTP)
	pl.OldPositionTP = nil
end)
nAdmin.SetTAndDesc("return", "builderreal", "Телепортироваться к игроку. arg1 - ник (необязательно).")

nAdmin.AddCommand("bring", false, function(ply, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "bring")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	if ply == pl then
		nAdmin.Warn(ply, "Вы не можете телепортироваться к самому себе.")
		return
	end
	pl.OldPositionTP = pl:GetPos()
	pl:SetPos(ply:EyePos() + Vector(ply:EyeAngles():Right()[1], 0, 0) * 150)
end)
nAdmin.SetTAndDesc("bring", "builderreal", "Телепортировать игрока к себе. arg1 - ник.")

nAdmin.AddCommand("mute", false, function(ply, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "mute")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	if pl.Muted then
		nAdmin.Warn(ply, "Игрок в муте.")
		return
	end
	pl.Muted = true
	nAdmin.WarnAll(ply:NameWithoutTags() .. " запретил писать в чат " .. pl:NameWithoutTags().. ".")
end)
nAdmin.SetTAndDesc("mute", "osobenniy2", "Запретить игроку писать в чат. arg1 - ник.")

nAdmin.AddCommand("unmute", false, function(ply, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "unmute")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	if not pl.Muted then
		nAdmin.Warn(ply, "Игрок не в муте!")
		return
	end
	pl.Muted = false
	nAdmin.WarnAll(ply:NameWithoutTags() .. " разрешил писать в чат " .. pl:NameWithoutTags().. ".")
end)
nAdmin.SetTAndDesc("unmute", "osobenniy2", "Разрешить игроку писать в чат. arg1 - ник.")

local function plSay(pl, txt)
	if pl.Muted then return "" end
end
hook.Add("PlayerSay", "nAdmin_mute", plSay)

nAdmin.AddCommand("mgag", false, function(ply, args)
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
	nAdmin.WarnAll(ply:NameWithoutTags() .. " " .. (pl.Gagged and "запретил" or "разрешил") .. " писать в чат и говорить в ГЧ " .. pl:NameWithoutTags().. ".")
end)
nAdmin.SetTAndDesc("mgag", "moderator", "Запретить/разрешить игроку писать в чат и говорить в ГЧ. arg1 - ник.")

nAdmin.AddCommand("banip", true, function(ply, args)
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
	nAdmin.Print(ply:NameWithoutTags() .. " забанил: " .. args[1]:Trim())
end)
nAdmin.SetTAndDesc("banip", "admin", "Банит IP адрес. arg1 - IP, arg2 - время.")

nAdmin.AddCommand("unbanip", true, function(ply, args)
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
	nAdmin.Print(ply:NameWithoutTags() .. " разбанивает: " .. args[1]:Trim())
end)
nAdmin.SetTAndDesc("unbanip", "admin", "Разбанивает IP адрес. arg1 - IP.")

nAdmin.AddCommand("freeze", true, function(ply, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "freeze")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	pl:Freeze(true)
	pl.Freezed = true
	pl:GodEnable()
	nAdmin.WarnAll(ply:NameWithoutTags() .. " зафризил " .. pl:NameWithoutTags())
end)
nAdmin.SetTAndDesc("freeze", "e2_coder", "Зафризить/разфризить игрока. arg1 - ник игрока.")

nAdmin.AddCommand("unfreeze", true, function(ply, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "unfreeze")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	pl:Freeze(false)
	pl:GodDisable()
	pl.Freezed = false
	nAdmin.WarnAll(ply:NameWithoutTags() .. " разфризил " .. pl:NameWithoutTags())
end)
nAdmin.SetTAndDesc("unfreeze", "e2_coder", "Разфризить игрока. arg1 - ник игрока.")

nAdmin.AddCommand("ip", true, function(ply, args)
	local check = nAdmin.ValidCheckCommand(args, 1, ply, "ip")
	if not check then
		return
	end
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	local ip = pl:IPAddress()
	if ip == "loopback" then
		ip = "0.0.0.0:27015"
	end
	ip = ip:sub(1, ip:find(":") - 1)
	nAdmin.Warn(ply, "IP адрес " .. pl:NameWithoutTags() .. ": " .. ip)
end)
nAdmin.SetTAndDesc("ip", "admin", "Узнать IP игрока. arg1 - ник игрока.")

nAdmin.AddCommand("bancheck", false, function(ply, args)
    local stid = args[1]:Trim()
    if nAdmin.ValidSteamID(stid) then
        stid = util.SteamIDTo64(stid)
    end
    local ban = nAdmin.BanList[stid]
    if ban then
        nAdmin.Warn(ply, "Забанил: " .. (ban.banned_by or "???") .. "; причина: " .. (ban.reason or "???") .. "; время: " .. (ban.time ~= 0 and string.NiceTime(ban.time - os.time())) or "Бесконечно")
    else
        nAdmin.Warn(ply, "SteamID не найден в банах!")
    end
end)
nAdmin.SetTAndDesc("bancheck", "admin", "Проверить бан игрока. arg1 - SteamID")
