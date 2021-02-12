hook.Add("EntityTakeDamage", "nAdmin_buildmode", function(target, dmg)
	local attacker = dmg:GetAttacker()
	if attacker.B or target.B then
		dmg:SetDamage(0)
	end
end)

nAdmin.AddCommand("build", false, function(ply, cmd, args)
	if ply.NoB then return end
	local inB = ply:GetNWBool("inBuild")
	if inB then return end
	if ply:InVehicle() then return end
	nAdmin.Warn(ply, "Входим в режим строительства...")
	ply.NoB = true
	timer.Simple(3, function()
		if not IsValid(ply) then return end
		nAdmin.WarnAll(ply:Name() .. " вошёл в режим строительства.")
		ply:SetNWBool("inBuild", true)
		ply.B = true
		ply:GodEnable()
		ply.NoB = false
	end)
end)
nAdmin.SetTAndDesc("build", "user", "Включить режим строительства.")

nAdmin.AddCommand("pvp", false, function(ply, cmd, args)
	if ply.NoB then return end
	local inB = ply:GetNWBool("inBuild")
	if not inB then return end
	if ply:InVehicle() then return end
	nAdmin.Warn(ply, "Входим в режим ПВП...")
	ply.NoB = true
	timer.Simple(3, function()
		if not IsValid(ply) then return end
		nAdmin.WarnAll(ply:Name() .. " вошёл в ПВП-режим.")
		ply:SetNWBool("inBuild", false)
		ply.B = false
		ply:GodDisable()
		ply.NoB = false
		ply:Spawn()
	end)
end)
nAdmin.SetTAndDesc("pvp", "user", "Включить ПВП-режим.")
