local meta = FindMetaTable("Player")
if not meta then
	return
end

local G_Teams = {
	["superadmin"] = {num = 1, n = "Создатель", clr = Color(200, 0, 0)},
	["admin"] = {num = 2, n = "Админ", clr = Color(255, 144, 0)},
	["moderator"] = {num = 3, n = "Модератор", clr = Color(100, 100, 214)},
	["osobenniy2"] = {num = 4, n = "Хедбэнгер", clr = Color(229, 0, 237)},
	["osobenniy"] = {num = 5, n = "Кальянщик", clr = Color(142, 0, 165)},
	["builderreal"] = {num = 6, n = "Строитель", clr = Color(255, 255, 255)},
	["e2_coder"] = {num = 7, n = "E2-кодер", clr = Color(255, 0, 0)},
	["noclip"] = {num = 8, n = "Гоблин", clr = Color(250, 250, 0)},
	["user"] = {num = 9, n = "Игрок", clr = Color(0, 255, 37)}
}

nAdmin.Limits = {
	["superadmin"] = {
		["props"] = math.huge,
		["sents"] = math.huge,
		["npcs"] = math.huge,
		["vehicles"] = math.huge,
		["ragdolls"] = math.huge,
		["effects"] = math.huge,
	},
	["Spy"] = {
		["props"] = 999,
		["sents"] = 999,
		["npcs"] = 10,
		["vehicles"] = 999,
		["ragdolls"] = 999,
		["effects"] = 999,
	},
	["vutka"] = {
		["props"] = 999,
		["sents"] = 999,
		["npcs"] = 10,
		["vehicles"] = 999,
		["ragdolls"] = 999,
		["effects"] = 999,
	},
	["admin"] = {
		["props"] = 999,
		["sents"] = 70,
		["npcs"] = 10,
		["vehicles"] = 25,
		["ragdolls"] = 25,
		["effects"] = 15,
	},
	["moderator"] = {
		["props"] = 700,
		["sents"] = 50,
		["npcs"] = 0,
		["vehicles"] = 15,
		["ragdolls"] = 10,
		["effects"] = 25,
	},
	["oleg"] = {
		["props"] = 500,
		["sents"] = 50,
		["npcs"] = 0,
		["vehicles"] = 15,
		["ragdolls"] = 10,
		["effects"] = 10,
	},
	["osobenniy2"] = {
		["props"] = 500,
		["sents"] = 45,
		["npcs"] = 0,
		["vehicles"] = 10,
		["ragdolls"] = 8,
		["effects"] = 8,
	},
	["osobenniy"] = {
		["props"] = 350,
		["sents"] = 30,
		["npcs"] = 0,
		["vehicles"] = 7,
		["ragdolls"] = 6,
		["effects"] = 6,
	},
	["builderreal"] = {
		["props"] = 950,
		["sents"] = 80,
		["npcs"] = 0,
		["vehicles"] = 30,
		["ragdolls"] = 10,
		["effects"] = 30,
	},
	["e2_coder"] = {
		["props"] = 350,
		["sents"] = 30,
		["npcs"] = 0,
		["vehicles"] = 6,
		["ragdolls"] = 5,
		["effects"] = 6,
	},
	["noclip"] = {
		["props"] = 300,
		["sents"] = 20,
		["npcs"] = 0,
		["vehicles"] = 5,
		["ragdolls"] = 4,
		["effects"] = 4,
	},
	["user"] = {
		["props"] = 250,
		["sents"] = 15,
		["npcs"] = 0,
		["vehicles"] = 4,
		["ragdolls"] = 3,
		["effects"] = 4,
	}
}

Global_Teams = G_Teams

for k, v in next, G_Teams do
	team.SetUp(v.num, v.n, v.clr)
end

function meta:GetUserGroup()
	return self:GetNWString("usergroup")
end

function meta:IsUserGroup(group)
	return self:GetNWString("usergroup") == group
end

function meta:IsAdmin()
	if not (IsValid(self)) then return false end
	if (self:IsSuperAdmin()) then return true end
	if (self:Team() <= 2) then return true end
	return false
end

function meta:IsSuperAdmin()
	return self:IsUserGroup("superadmin")
end

if SERVER then
	hook.Add("PlayerSpawn", "collidefix", function(ply)
		timer.Simple(0, function()
			if IsValid(ply) then
				ply:SetNoCollideWithTeammates(false)
			end
		end)
	end)

	for _, ply in next, player.GetAll() do
		ply:SetNoCollideWithTeammates(false)
	end

	hook.Add("PhysgunPickup", "nAdminPhysgunPickupPlayer", function(pl, ent)
		if ent:IsPlayer() then
			if pl:Team() < ent:Team() and pl:Team() <= 3 then
				ent:SetMoveType(MOVETYPE_NONE)
				ent.Freezed = true
				ent:GodEnable()
				ent:Freeze(true)
				return true
			end
		end
	end)

	hook.Add("PhysgunDrop", "nAdminPhysgunDropPlayer", function(pl, ent)
		if ent:IsPlayer() then
			if pl:Team() < ent:Team() and pl:Team() <= 3 then
				if pl:KeyPressed(IN_ATTACK2) then return end
				ent:SetMoveType(MOVETYPE_WALK)
				ent.Freezed = false
				ent:Freeze(false)
				ent:GodDisable()
			end
		end
	end)
end