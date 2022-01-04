-- https://github.com/PAC3-Server/notagain/blob/master/lua/notagain/aowl/commands/physics.lua

nAdmin.AddCommand("weldlag", false, function(ply, args)
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
	local lags = {}
	for ent in next, t do
		local found
		for lagger, group in next, lags do
			if ent == lagger or group[ent] then
				found = true
				break
			end
		end
		if not found then
			lags[ent] = constraint.GetAllConstrainedEntities(ent) or {}
		end
	end
	for _, cents in next, lags do
		local count, lagc = 0, t[k] and 1 or 0
		local owner
		for k, v in next, cents do
			count = count + 1
			if t[k] then
				lagc = lagc + 1
			end
			if not owner and IsValid(k:CPPIGetOwner()) then
				owner = k:CPPIGetOwner()
			end
		end
		if (count or 0) > (minresult or 0) then
			if lagc == 1 or count == 1 then return end
			if IsValid(owner) then
				nAdmin.Warn(ply, "Найдены лагающие констрейны: " .. lagc .. '/'.. count .." лагающие пропы (владелец: " .. owner:NameWithoutTags() .. ")")
			else
				nAdmin.Warn(ply, "Найдены лагающие констрейны: " .. lagc .. '/'.. count .." лагающие пропы (владелец: неизвестен)")
			end
		end
	end
end)
nAdmin.SetTAndDesc("weldlag", "moderator", "Найти лагающие констрейны пропов.")

nAdmin.AddCommand("fp", true, function(ply)
	for _, ent in ipairs(ents.GetAll()) do
		local own = ent:CPPIGetOwner()
		if own then
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:EnableMotion(false)
				--phys:Wake()
			end
		end
	end
	nAdmin.WarnAll(ply:NameWithoutTags() .. " зафризил все энтити.")
end)
nAdmin.SetTAndDesc("fp", "builderreal", "Зафризить все энтити.")

nAdmin.AddCommand("fppl", true, function(ply, args)
	local pl = nAdmin.FindByNick(args[1])
	if pl == nil then
		nAdmin.Warn(ply, "Игрока с таким ником нет на сервере.")
		return
	end
	for _, ent in ipairs(ents.GetAll()) do
		local own = ent:CPPIGetOwner()
		if own == pl then
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:EnableMotion(false)
			end
		end
	end
	nAdmin.WarnAll(ply:NameWithoutTags() .. " зафризил энтити " .. pl:NameWithoutTags() .. ".")
end)
nAdmin.SetTAndDesc("fppl", "noclip", "Зафризить энтити какого-то игрока. arg1 - ник игрока.")

nAdmin.AddCommand("fmp", true, function(ply, args)
   local b = 0
   for _, v in ipairs(ents.FindByClass("prop_physics")) do
       if v:CPPIGetOwner() == ply then
           local a = v:GetPhysicsObject()
           if a:IsMotionEnabled() == true then
               if a:IsValid() then
                   a:EnableMotion(false)
                   b = b + 1
               end
           end
       end
   end
   timer.Simple(0, function()
       nAdmin.Warn(ply, "Готово! Зафрижено: " .. b .. " пропов.")
   end)
end)
nAdmin.SetTAndDesc("fmp", "user", "Зафризить свои энтити.")
nAdmin.ConsoleBlock("fmp")
