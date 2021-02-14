local limits = nAdmin.Limits
local p = p
local tostring = tostring

if not limits then return end
hook.Add("PlayerCheckLimit", "limits", function(pl, limit, cur, dMax)
	local a = limits[pl:GetUserGroup()]
	if a and a[limit] then
		if cur >= a[limit] then
			return false
		end
	end
end)

hook.Add("InitPostEntity", "nAdmin_loadlogs", function()
	hook.Remove("InitPostEntity", "nAdmin_loadlogs")
	local alllogs = {
		"Prop",
		"Ragdoll",
		"SENT",
		"Effect",
		"Vehicle"
	}

	for i = 1, #alllogs do
		local _log = alllogs[i]
		hook.Add("PlayerSpawned" .. _log, "nAdminLog", function(a, b)
			p(a:Name() .. " заспавнил: " .. tostring(b))
		end)
	end

	hook.Add("CanTool", "nAdminLog", function(a, _, b)
		p(a:Name() .. " использовал инструмент: " .. tostring(b))
	end)
end)