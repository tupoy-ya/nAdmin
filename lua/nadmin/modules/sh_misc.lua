if CLIENT then
	nAdmin.AddCommand("menu", function()
		if not IsValid(nGUI) then
			xpcall(nAdmin.mGUI, function()
				p("Меню недоступно. Перезагружаю файлы!")
				nAdmin.UpdateFiles()
			end)
		elseif IsValid(nGUI) then
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
	nAdmin.AddCommand("g", function(...)
		gui.OpenURL("https://www.google.com/search?&q=" .. table.concat({...}, "+"))
	end)
	nAdmin.AddCommand("y", function(...)
		gui.OpenURL("https://yandex.ru/search/?text=" .. table.concat({...}, "%20"))
	end)
	nAdmin.AddCommand("browser", function()
		gui.OpenURL("https://yandex.ru/")
	end)
	nAdmin.AddCommand("git", function(...)
		gui.OpenURL("https://github.com/search?q=" .. table.concat({...}, "+"))
	end)
	nAdmin.AddCommand("mutecl", function(a)
		local ent = nAdmin.FindByNick(a[1])
		if ent == nil then
			chat.AddText(Color(150, 150, 150), "Игрока с таким ником нет на сервере!")
			return
		end
		ent:SetMuted(true)
		ent.Muted = true
		hook.Add("OnPlayerChat","nAdminMute",function(ply)
			if ply.Muted then
				return true
			end
		end)
	end)
	nAdmin.AddCommand("unmutecl", function(a)
		local ent = nAdmin.FindByNick(a[1])
		if ent == nil then
			chat.AddText(Color(150, 150, 150), "Игрока с таким ником нет на сервере!")
			return
		end
		ent:SetMuted(false)
		ent.Muted = nil
		for k, v in ipairs(player.GetAll()) do
			if v.Muted then
				return
			end
		end
		hook.Remove("OnPlayerChat","nAdminMute")
	end)
	nAdmin.AddCommand("help", function()
		if not nAdmin.FullCMDS then
			nAdmin.Print("Пожалуйста, подождите...")
			net.Start("nadmin_message")
				net.WriteUInt(1, 1)
			net.SendToServer()
			timer.Simple(1.5, function()
				for k, v in SortedPairs(nAdmin.Commands) do
					p("", "n " .. k .. " -", v.desc or "Нет описания", v.T or "Игрок")
				end
			end)
		else
			for k, v in SortedPairs(nAdmin.Commands) do
				p("", "n " .. k .. " -", v.desc or "Нет описания", "Доступен с: " .. (v.T or "Игрок"))
			end
		end
	end)
	net.Receive("nAdmin_MFunctions", function()
		local str = net.ReadString()
		local a = net.ReadUInt(16)
		local t = net.ReadData(a)
		t = util.Decompress(t)
		t = util.JSONToTable(t or "{}")
		nAdmin.Commands[str].func(unpack(t or {}))
	end)
	nAdmin.SetTAndDesc("g", "user", "Поиск чего-нибудь в Google. arg1 - что-то искать.")
	nAdmin.SetTAndDesc("git", "user", "Поиск чего-нибудь в GitHub. arg1 - что-то искать.")
	nAdmin.SetTAndDesc("browser", "user", "Открыть браузер.")
	nAdmin.SetTAndDesc("mutecl", "user", "Замутить на клиенте игрока. arg1 - ник игрока.")
	nAdmin.SetTAndDesc("unmutecl", "user", "Размутить на клиенте игрока. arg1 - ник игрока.")
	nAdmin.SetTAndDesc("y", "user", "Поиск чего-нибудь в Яндексе. arg1 - что-то искать.")
end

if SERVER then
	local meta = FindMetaTable("Player")
	util.AddNetworkString("nAdmin_MFunctions")
	function meta:SendF(func, ...)
		if next({...}) ~= nil then
			local comp = util.Compress(util.TableToJSON(...))
			local c = #comp
			net.Start("nAdmin_MFunctions")
				net.WriteString(func)
				net.WriteUInt(c, 16)
				net.WriteData(comp, c)
			net.Send(self)
		else
			net.Start("nAdmin_MFunctions")
				net.WriteString(func)
			net.Send(self)
		end
	end
	nAdmin.AddCommand("menu", true, function(ply, cmd, args)
		ply:SendF("menu")
	end)
	nAdmin.AddCommand("fullupdate", true, function(ply, cmd, args)
		ply:SendF("fullupdate", args)
	end)
	nAdmin.AddCommand("g", true, function(ply, cmd, args)
		ply:SendF("g", args)
	end)
	nAdmin.AddCommand("browser", true, function(ply, cmd, args)
		ply:SendF("browser")
	end)
	nAdmin.AddCommand("mutecl", true, function(ply, cmd, args)
		ply:SendF("mutecl", {args[1]})
	end)
	nAdmin.AddCommand("unmutecl", true, function(ply, cmd, args)
		ply:SendF("unmutecl", {args[1]})
	end)
	nAdmin.AddCommand("y", true, function(ply, cmd, args)
		ply:SendF("y", args)
	end)
	nAdmin.AddCommand("git", true, function(ply, cmd, args)
		ply:SendF("git", args)
	end)
	nAdmin.AddCommand("giveammo", false, function(ply, cmd, args)
		local check = nAdmin.ValidCheckCommand(args, 1, ply, "giveammo")
		if not check then
			return
		end
		if not IsValid(ply:GetActiveWeapon()) then return end
		local a = ply:GetActiveWeapon():GetPrimaryAmmoType()
		local c = (args[1] or 0)
		if a ~= -1 then
			ply:GiveAmmo(math.Clamp(c, 0, 9999), a)
		end
		local b = ply:GetActiveWeapon():GetSecondaryAmmoType()
		if b ~= -1 then
			ply:GiveAmmo(math.Clamp(c, 0, 9999), b)
		end
	end)
	nAdmin.SetTAndDesc("giveammo", "user", "Дать себе патроны. arg1 - количество патрон.")
	local function days( time )
		time = time / 60 / 60
		return time
	end
	nAdmin.AddCommand("uptime", false, function(ply, _, args)
		timer.Simple(0, function()
			nAdmin.Warn(ply, "Сервер онлайн уже: " .. math.Round(days(SysTime())) .. " часов.")
		end)
	end)
	nAdmin.AddCommand("leave", false, function(ply, _, args)
		timer.Simple(.5, function()
			if not args then
				ply:Kick("Отключился")
			else
				ply:Kick("Отключился: " .. table.concat(args, " "))
			end
		end)
	end)
	nAdmin.SetTAndDesc("leave", "user", "Выйти с сервера. arg1 - причина. (необязательно)")
	nAdmin.AddCommand("help", false, function(ply, _, args)
		ply:SendF("help")
	end)
	--[[
	nAdmin.AddCommand("ulxbanstonadmin", false, function(ply, _, args)
		if not ply:IsSuperAdmin() then return end
		local a = file.Read("nadmin/ulxbans.txt", "DATA")
		a = "\"ULXGAYSTVO\" {" .. a .. "}" -- замечательный обход
		a = util.KeyValuesToTable(a)
		for stid, tbl in next, a do
			if tbl.reason == nil then
				tbl.reason = "Нет причины."
			end
			nAdmin.AddBan(stid, tonumber(os.time()) - tonumber(tbl.time), tbl.reason, ply, true)
		end
	end)
	nAdmin.SetTAndDesc("ulxbanstonadmin", "superadmin", "")
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
	]]
end
