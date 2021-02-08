hook.Add("EntityTakeDamage", "nAdmin_buildmode", function(target, dmg)
	local attacker = dmg:GetAttacker()
	if attacker.B then
		return true
	end
end)

nAdmin.AddCommand("build", false, function(ply, cmd, args)
	local inB = ply:GetNWBool("inBuild")
	if inB then return end
	if ply:InVehicle() then return end
	nAdmin.Warn(ply, "Входим в режим строительства...")
	timer.Simple(3, function()
		if not IsValid(ply) then return end
		nAdmin.WarnAll(ply:Name() .. " вошёл в режим строительства.")
		ply:SetNWBool("inBuild", true)
		ply.B = true
		ply:GodEnable()
	end)
end)
nAdmin.SetTAndDesc("build", "user", "Включить режим строительства.")

nAdmin.AddCommand("pvp", false, function(ply, cmd, args)
	local inB = ply:GetNWBool("inBuild")
	if not inB then return end
	if ply:InVehicle() then return end
	nAdmin.Warn(ply, "Входим в режим ПВП...")
	timer.Simple(3, function()
		if not IsValid(ply) then return end
		nAdmin.WarnAll(ply:Name() .. " вошёл в ПВП-режим.")
		ply:SetNWBool("inBuild", false)
		ply.B = false
		ply:GodDisable()
	end)
end)
nAdmin.SetTAndDesc("pvp", "user", "Включить ПВП-режим.")
