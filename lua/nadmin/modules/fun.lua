nAdmin.AddCommand("ragdoll", true, function(ply, _, args)
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	if pl.rag then
		nAdmin.Warn(ply, "Игрок уже пешка навального.")
		return
	end
	if pl:InVehicle() then
		pl:ExitVehicle()
	end
	local plvel = pl:GetVelocity()
	local ragdoll = ents.Create("prop_ragdoll")
	pl.ragOldPos = pl:GetPos()
	ragdoll:SetPos(pl:GetPos())
	ragdoll:SetModel(pl:GetModel())
	ragdoll:SetAngles(pl:GetAngles())
	ragdoll:Spawn()
	ragdoll:Activate()
	for i = 1, ragdoll:GetPhysicsObjectCount() - 1 do
		local a = ragdoll:GetPhysicsObjectNum(i)
		a:SetVelocity(plvel)
	end
	pl:Spectate(OBS_MODE_CHASE)
	pl:SpectateEntity(ragdoll)
	pl:StripWeapons()
	pl.nospawn = true
	pl.rag = ragdoll
end)

nAdmin.AddCommand("unragdoll", true, function(ply, _, args)
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	if pl.rag then
		pl.rag:Remove()
		pl.rag = nil
	end
	pl:UnSpectate()
	pl:Spawn()
	if pl.ragOldPos then
		pl:SetPos(pl.ragOldPos)
		pl.ragOldPos = nil
	end
	pl.nospawn = false
end)

hook.Add("PlayerSpawnObject", "nAdmin_ragdoll", function(ply)
	if ply.nospawn then
		return false
	end
end)

hook.Add("PlayerSpawn", "nAdmin_ragdoll", function(ply)
	timer.Simple(.1, function()
		if ply and ply.rag then
			ply:Spectate(OBS_MODE_CHASE)
			ply:SpectateEntity(ply.rag)
			ply:StripWeapons()
		end
	end)
end)

hook.Add("PlayerDisconnected", "nAdmin_ragdoll", function(ply)
	if ply.rag then
		ply.rag:Remove()
	end
end)

nAdmin.SetTAndDesc("ragdoll", "vutka", "Делает игрока пешкой навального. arg1 - ник игрока.")
nAdmin.SetTAndDesc("unragdoll", "vutka", "Не делает игрока пешкой навального. arg1 - ник игрока.")

nAdmin.AddCommand("slay", true, function(ply, _, args)
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	if not pl:Alive() then
		nAdmin.Warn(ply, "Игрок мёртв.")
		return
	end
	pl:Kill()
	nAdmin.WarnAll(ply:Name() .. " убил " .. pl:Name())
end)
nAdmin.SetTAndDesc("slay", "vutka", "Убивает игрока. arg1 - ник игрока.")