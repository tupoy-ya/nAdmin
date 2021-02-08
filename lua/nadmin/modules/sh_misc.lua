if CLIENT then
	nAdmin.AddCommand("menu", function(...)
		nAdmin.VisibleGUI = not nAdmin.VisibleGUI
		if not IsValid(nGUI) then
			nAdmin.GUI()
		end
	end)
	nAdmin.AddCommand("g", function(...)
		gui.OpenURL("https://www.google.com/#q=" .. table.concat({...}, "+"))
	end)
	nAdmin.AddCommand("y", function(...)
		gui.OpenURL("https://yandex.ru/search/?text=" .. table.concat({...}, "%20"))
	end)
	nAdmin.AddCommand("browser", function()
		gui.OpenURL("https://yandex.ru/")
	end)
	nAdmin.AddCommand("mutecl", function(a)
		local ent = nAdmin.FindByNick(a[1])
		if ent == nil then return end
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
		if ent == nil then return end
		ent:SetMuted(false)
		ent.Muted = nil
		for k, v in ipairs(player.GetAll()) do
			if v.Muted then
				return
			end
		end
		hook.Remove("OnPlayerChat","nAdminMute")
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
	nAdmin.AddCommand("fullupdate", true, function(ply, cmd, args)
		ply:ConCommand("record 1;stop")
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
	nAdmin.AddCommand("menu", true, function(ply, cmd, args)
		ply:SendF("menu", args)
	end)
	nAdmin.AddCommand("giveammo", false, function(ply, cmd, args)
		local check = nAdmin.ValidCheckCommand(args, 1, ply, "mgag")
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
end
