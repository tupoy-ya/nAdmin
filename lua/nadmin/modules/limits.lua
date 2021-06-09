local p, limitss, tostring, meta = p, nAdmin.Limits, tostring, FindMetaTable'Player'

hook.Add("PlayerCheckLimit", "limits", function(pl, limit, cur, dMax)
	local a = limitss[pl:GetUserGroup()]
	if a and a[limit] then
		if cur > a[limit] then
			return false
		end
	end
end)

--hook.Add("InitPostEntity", "nAdmin_loadlogs", function()
	local alllogs = {
		"Prop",
		"Ragdoll",
		"SENT",
		"Effect",
		"Vehicle"
	}

	for i = 1, #alllogs do
		local _log = alllogs[i]
		hook.Add("PlayerSpawned" .. _log, "nAdminLog", function(a, b, c)
			local limit = limitss[a:GetUserGroup()]
			local _log_lower = _log:lower() .. "s"
			if limit and limit[_log_lower] then
				if a:GetCount(_log_lower) > limit[_log_lower] then
					a:LimitHit(_log_lower)
					--a:ChatPrint("Проп был удалён. Вы превысили лимит данного типа энтити. (" .. limit[_log_lower] .. ")")
					--timer.Simple(0, function()
						if isstring(b) then
							SafeRemoveEntity(c)
						else
							SafeRemoveEntity(b)
						end
					--end)
				end
			end
			--p(1)
			Msg(a:Name() .. " заспавнил: " .. tostring(b) .. "\n")
		end)
	end

	hook.Add("CanTool", "nAdminLog", function(a, _, b)
		Msg(a:Name() .. " использовал инструмент: " .. tostring(b) .. "\n")
	end)

	hook.Remove("InitPostEntity", "nAdmin_loadlogs")
--end)