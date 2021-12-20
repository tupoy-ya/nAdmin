hook.Add("EntityTakeDamage", "nAdmin_buildmode", function(target, dmg)
	local attacker = dmg:GetAttacker()
	if (attacker.B or target.B) and target:GetClass() ~= "fishing_mod_seagull" then
		return true
	end
end)

nAdmin.AddCommand("build", false, function(ply, args)
	if ply.NoB then return end
	if ply.InGunGame then return end
	local inB = ply:GetNWBool("inBuild")
	if inB then return end
	nAdmin.Warn(ply, "Входим в режим строительства...")
	ply.NoB = true
	timer.Simple(3, function()
		if not IsValid(ply) then return end
		nAdmin.WarnAll(ply:NameWithoutTags() .. " вошёл в режим строительства.")
		ply:SetNWBool("inBuild", true)
		ply.B = true
		ply:GodEnable()
		ply.NoB = false
	end)
end)
nAdmin.SetTAndDesc("build", "user", "Включить режим строительства.")
nAdmin.ConsoleBlock("build")

nAdmin.AddCommand("pvp", false, function(ply, args)
	if ply.NoB then return end
	local inB = ply:GetNWBool("inBuild")
	if not inB then return end
	nAdmin.Warn(ply, "Входим в режим ПВП...")
	ply.NoB = true
	timer.Simple(3, function()
		if not IsValid(ply) then return end
		if ply:InVehicle() then
			ply:ExitVehicle()
		end
		nAdmin.WarnAll(ply:NameWithoutTags() .. " вошёл в ПВП-режим.")
		ply:SetNWBool("inBuild", false)
		ply.B = false
		ply:GodDisable()
		ply.NoB = false
		ply:Spawn()
	end)
end)
nAdmin.SetTAndDesc("pvp", "user", "Включить ПВП-режим.")
nAdmin.ConsoleBlock("pvp")

hook.Add("PlayerNoClip", "nAdmin_buildmode", function(ply)
	if ply.B then
		return true
	end
end)

hook.Add("PlayerSpawn", "nAdmin_buildmode", function(ply)
	if ply:GetNWBool("inBuild") then
		ply:GodEnable()
	end
end)

nAdmin.AddCommand("noclip", true, function(ply, args)
	if ply.Freezed or ply.InVirus or ply.InGunGame then return end
	local movetype = ply:GetMoveType()
	if movetype == MOVETYPE_WALK then
		ply:SetMoveType(MOVETYPE_NOCLIP)
	elseif movetype == MOVETYPE_NOCLIP then
		ply:SetMoveType(MOVETYPE_WALK)
	else
		nAdmin.Warn(ply, "Сейчас нельзя пользоваться Noclip'ом!")
	end
end)
nAdmin.SetTAndDesc("noclip", "noclip", "Включает/выключает Noclip. /noclip или n noclip.")
nAdmin.ConsoleBlock("noclip")