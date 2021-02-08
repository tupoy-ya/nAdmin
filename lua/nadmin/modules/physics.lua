nAdmin.AddCommand("weldlag", false, function(ply, cmd, args)
	if not nAdmin.GetAccess("weldlag", ply) then
		return
	end
	local t = {}
	for _, v in ipairs(ents.GetAll()) do
		local count = v:GetPhysicsObjectCount()
		if count == 0 or count > 1 then continue end
		local p = v:GetPhysicsObject()
		if not p:IsValid() then continue end
		if p:IsAsleep() then continue end
		if p:IsMotionEnabled() then
			t[v] = true
		end
	end
	local lags={}
	for ent in next, t do
		local found
		for lagger, group in next, lags do
			if ent==lagger or group[ent] then
				found=true
				break
			end
		end
		if not found then
			lags[ent]=constraint.GetAllConstrainedEntities(ent) or {}
		end
	end
	for _, cents in next, lags do
		p(cents)
		local count, lagc = 0, t[k] and 1 or 0
		local owner
		for k,v in next, cents do
			count = count + 1
			if t[k] then
				lagc = lagc + 1
			end
			if not owner and IsValid(k:CPPIGetOwner()) then
				owner = k:CPPIGetOwner()
			end
		end
		if (count or 0) > (minresult or 0) then
			nAdmin.Warn(ply, "Найдены лагающие констрейны: " .. lagc .. '/'.. count .." лагающие пропы (владелец: " .. tostring(owner) .. ")")
		end
	end
end)
nAdmin.SetTAndDesc("weldlag", "admin", "Найти лагающие констрейны пропов.")