local p, limitss, tostring, meta = p, nAdmin.Limits, tostring, FindMetaTable'Player'

hook.Add("PlayerCheckLimit", "limits", function(pl, limit, cur, dMax)
	local a = limitss[pl:GetUserGroup()]
	if a and a[limit] then
		local getcount = cur
		if pl.IsEquipped and pl:IsEquipped("+limit") then
			getcount = getcount * 0.75
		end
		if getcount > a[limit] then
			return false
		end
	end
end)


local alllogs = {
	"Prop",
	"Ragdoll",
	"SENT",
	"Effect",
	"Vehicle",
	"NPC"
}

for i = 1, #alllogs do
	local _log = alllogs[i]
	hook.Add("PlayerSpawned" .. _log, "nAdminLog", function(a, b, c)
		Msg(a:NameWithoutTags() .. " заспавнил: " .. tostring(b) .. "\n")
	end)
end

hook.Add("CanTool", "nAdminLog", function(a, _, b)
	Msg(a:NameWithoutTags() .. " использовал инструмент: " .. tostring(b) .. "\n")
end)
