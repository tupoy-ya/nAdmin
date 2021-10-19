if CLIENT then
	nAdmin.AddCommand("menu", function()
		if not IsValid(nGUI) then
			xpcall(nAdmin.mGUI, function()
				p("Меню недоступно. Перезагружаю файлы!")
				nAdmin.UpdateFiles()
			end)
		else
			if nGUI:IsVisible() then
				gui.EnableScreenClicker(false)
				nGUI:AlphaTo(0, .1, 0, function()
					nGUI:SetVisible(false)
				end)
			else
				nGUI:SetVisible(true)
				gui.EnableScreenClicker(true)
				nGUI:AlphaTo(255, .1, 0)
			end
		end
	end)
	nAdmin.AddCommand("fullupdate", function()
		LocalPlayer():ConCommand("record 1;stop")
	end)
	nAdmin.AddCommand("browser", function()
		gui.OpenURL("https://yandex.ru/")
	end)
	nAdmin.AddCommand("mutecl", function(a)
		local ent = nAdmin.FindByNick(a[1])
		if ent == nil then
			chat.AddText(Color(150, 150, 150), "Игрока с таким ником нет на сервере!")
			return
		end
		ent:SetMuted(true)
		ent.Muted = true
	end)

	hook.Add("OnPlayerChat","nAdminMute",function(ply)
		if ply.Muted then
			return true
		end
	end)

	nAdmin.AddCommand("unmutecl", function(a)
		local ent = nAdmin.FindByNick(a[1])
		if ent == nil then
			chat.AddText(Color(150, 150, 150), "Игрока с таким ником нет на сервере!")
			return
		end
		ent:SetMuted(false)
		ent.Muted = nil
	end)
	nAdmin.AddCommand("help", function()
		if not nAdmin.FULLCMDS then
			net.Start("nAdmin_message")
				net.WriteUInt(1, 2)
			net.SendToServer()
			nAdmin.FULLCMDS = true
			nAdmin.Warn(_, "Пожалуйста, подождите...")
			timer.Simple(3, function()
				nAdmin.Warn(_, "Смотрите консоль.")
				for k, v in SortedPairs(nAdmin.Commands) do
					p("", "n " .. k .. " -", v.desc or "Нет описания", "Доступен с: " .. (v.T or "Игрок"))
				end
			end)
			return
		end
		nAdmin.Warn(_, "Смотрите консоль.")
		for k, v in SortedPairs(nAdmin.Commands) do
			p("", "n " .. k .. " -", v.desc or "Нет описания", "Доступен с: " .. (v.T or "Игрок"))
		end
	end)
	nAdmin.SetTAndDesc("browser", "user", "Открыть браузер.")
	nAdmin.SetTAndDesc("mutecl", "user", "Замутить на клиенте игрока. arg1 - ник игрока.")
	nAdmin.SetTAndDesc("unmutecl", "user", "Размутить на клиенте игрока. arg1 - ник игрока.")
else
	local meta = FindMetaTable("Player")
	nAdmin.AddCommand("giveammo", false, function(ply, args)
		local check = nAdmin.ValidCheckCommand(args, 1, ply, "giveammo")
		if not check then
			return
		end
		if not IsValid(ply:GetActiveWeapon()) then return end
		local a = ply:GetActiveWeapon():GetPrimaryAmmoType()
		local num = tonumber(args[1])
		local c = (num ~= nil and num or 0)
		if a ~= -1 then
			ply:GiveAmmo(math.Clamp(c, 0, 9999), a)
		end
		local b = ply:GetActiveWeapon():GetSecondaryAmmoType()
		if b ~= -1 then
			ply:GiveAmmo(math.Clamp(c, 0, 9999), b)
		end
	end)
	nAdmin.SetTAndDesc("giveammo", "user", "Дать себе патроны. arg1 - количество патрон.")
	nAdmin.CmdHidden("giveammo")
	nAdmin.ConsoleBlock("giveammo")
	local function days( time )
		time = time / 60 / 60
		return time
	end
	nAdmin.AddCommand("uptime", false, function(ply, args)
		timer.Simple(0, function()
			nAdmin.Warn(ply, "Сервер онлайн уже: " .. math.Round(days(SysTime()), 1) .. " часов.")
		end)
	end)
	nAdmin.AddCommand("strip", false, function(ply, args)
		if args and next(args) ~= nil and args[1] ~= nil then
			local ent = nAdmin.FindByNick(args[1])
			if ent == nil then
				chat.AddText(Color(150, 150, 150), "Игрока с таким ником нет на сервере!")
				return
			end
			if not ply:IsAdmin() then
				return
			end
			ent:StripWeapons()
		else
			ply:StripWeapons()
		end
	end)
	nAdmin.SetTAndDesc("strip", "user", "Убрать всё оружие у вас в инвентаре. arg1 - ник. (необязательно)")
	nAdmin.ConsoleBlock("strip")
	nAdmin.AddCommand("leave", false, function(ply, args)
		timer.Simple(.5, function()
			if not args or next(args) == nil then
				ply:Kick("Отключился")
			else
				ply:Kick("Отключился: " .. table.concat(args, " "))
			end
		end)
	end)
	nAdmin.SetTAndDesc("leave", "user", "Выйти с сервера. arg1 - причина. (необязательно)")
	nAdmin.AddCommand("me", false, function(ply, args)
		if ply.Muted then return end
		for _, pl in ipairs(player.GetAll()) do
			pl:ChatPrint("*** " .. ply:Name() .. " " .. table.concat(args, " "))
		end
	end)
	nAdmin.SetTAndDesc("me", "user", "Что-то \"сделать\". arg1 - текст.")
	nAdmin.CmdHidden("me")
	nAdmin.ConsoleBlock("me")
	--[[nAdmin.AddCommand("ulxbanstonadmin", false, function(ply, args)
		local a = file.Read("nadmin/ulxbans.txt", "DATA")
		a = "\"ULXGAYSTVO\" {" .. a .. "}" -- замечательный обход
		a = util.KeyValuesToTable(a)
		for stid, tbl in next, a do
			if tbl.reason == nil then
				tbl.reason = "Нет причины."
			end
			nAdmin.AddBan(stid, tonumber(os.time()) - tonumber(tbl.time), tbl.reason, ply, true, true)
		end
	end)
	nAdmin.SetTAndDesc("ulxbanstonadmin", "superadmin", "Перенести файл банов ULX в nAdmin")
	]]
		--[[
	nAdmin.AddCommand("ulxusergroupsstonadmin", false, function(ply, _, args)
		if not ply:IsSuperAdmin() then return end
		local a = file.Read("nadmin/ulxusergroups.txt", "DATA")
		a = "\"ULXGAYSTVO\" {" .. a .. "}" -- замечательный обход
		a = util.KeyValuesToTable(a)
		for stid, tbl in next, a do
			SetUserGroupID(stid, tbl.group)
		end
		p("есть ошибка? да и похуй")
	end)
	nAdmin.SetTAndDesc("ulxusergroupsstonadmin", "superadmin", "")
	]]--
end
