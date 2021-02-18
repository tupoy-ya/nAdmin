if CLIENT or SERVER then
	local meta = FindMetaTable("Player")

	local G_Teams = {
		["superadmin"] = {num = 1, n = "Создатель", clr = Color(200, 0, 0)},
		["admin"] = {num = 2, n = "Админ", clr = Color(255, 144, 0)},
		["Spy"] = {num = 3, n = "Админ", clr = Color(0, 255, 37)},
		["vutka"] = {num = 4, n = "Админ", clr = Color(0, 255, 37)},
		["moderator"] = {num = 5, n = "Модератор", clr = Color(100, 100, 214)},
		["oleg"] = {num = 6, n = "Игрок", clr = Color(0, 255, 37)},
		["osobenniy2"] = {num = 7, n = "Хедбэнгер", clr = Color(229, 0, 237)},
		["osobenniy"] = {num = 8, n = "Кальянщик", clr = Color(142, 0, 165)},
		["builderreal"] = {num = 9, n = "Строитель", clr = Color(255, 255, 255)},
		["e2_coder"] = {num = 10, n = "E2-кодер", clr = Color(255, 0, 0)},
		["noclip"] = {num = 11, n = "Гоблин", clr = Color(250, 250, 0)},
		["user"] = {num = 12, n = "Игрок", clr = Color(0, 255, 37)}
	}

	nAdmin.Limits = {
		["superadmin"] = {
			["props"] = 999,
			["sents"] = 999,
			["npcs"] = 999,
			["vehicles"] = 999,
			["ragdolls"] = 999,
			["effects"] = 999,
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
			["props"] = 650,
			["sents"] = 50,
			["npcs"] = 0,
			["vehicles"] = 15,
			["ragdolls"] = 10,
			["effects"] = 10,
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
			["props"] = 450,
			["sents"] = 40,
			["npcs"] = 0,
			["vehicles"] = 10,
			["ragdolls"] = 6,
			["effects"] = 8,
		},
		["osobenniy"] = {
			["props"] = 350,
			["sents"] = 30,
			["npcs"] = 0,
			["vehicles"] = 6,
			["ragdolls"] = 5,
			["effects"] = 6,
		},
		["builderreal"] = {
			["props"] = 850,
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
		if (self:IsSuperAdmin()) then return true end
		if (self:Team() <= 4) then return true end
		return false
	end

	function meta:IsSuperAdmin()
		return self:IsUserGroup("superadmin")
	end
end

if SERVER then
	hook.Add("PhysgunPickup", "nAdminPhysgunPickupPlayer", function(pl, ent)
		if ent:IsPlayer() then
			if pl:Team() < ent:Team() and pl:Team() <= 5 then
				ent:SetMoveType(MOVETYPE_NONE)
				return true
			end
		end
	end)
	hook.Add("PhysgunDrop", "nAdminPhysgunDropPlayer", function(pl, ent)
		if ent:IsPlayer() then
			if pl:Team() < ent:Team() and pl:Team() <= 5 then
				if pl:KeyPressed(IN_ATTACK2) then return end
				ent:SetMoveType(MOVETYPE_WALK)
			end
		end
	end)
end