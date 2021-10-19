util.AddNetworkString("igPac")

nAdmin.AddCommand("fixpac", false, function(ply, args)
	if pace then
		ply.pac_requested_outfits = false
		pace.RequestOutfits(ply)
	end
end)
nAdmin.SetTAndDesc("fixpac", "user", "Фикс PAC3. (делает реквест одежки)")
nAdmin.ConsoleBlock("fixpac")

nAdmin.AddCommand("wear", false, function(ply, args)
	if not args[1] then return end
	ply:ConCommand("pac_wear_parts \"" .. args[1] or '' .."\"")
end)
nAdmin.SetTAndDesc("wear", "user", "Надеть одежку из PAC3. arg1 - название пака.")
nAdmin.ConsoleBlock("wear")

nAdmin.AddCommand("ignorepac", false, function(ply, args)
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	net.Start("igPac")
		net.WriteUInt(1, 2)
		net.WriteEntity(pl)
	net.Send(ply)
end)
nAdmin.SetTAndDesc("ignorepac", "user", "Игнорировать PAC3 игрока. arg1 - ник игрока.")

nAdmin.AddCommand("unignorepac", false, function(ply, args)
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	net.Start("igPac")
		net.WriteUInt(2, 2)
		net.WriteEntity(pl)
	net.Send(ply)
end)
nAdmin.ConsoleBlock("unignorepac")
nAdmin.SetTAndDesc("unignorepac", "user", "Разигнорировать PAC3 игрока. arg1 - ник игрока.")