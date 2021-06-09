if CLIENT or SERVER then
	local meta = FindMetaTable("Player")

	function meta:GetTotalTime()
		return self:GetNWInt("TotalTime", 0) + self:GetSessionTime()
	end

	function meta:GetSessionTime()
		return CurTime() - self:GetNWInt("StartTimeSession", 0)
	end

	function meta:GetStartTimeSession()
		return self:GetNWInt("StartTimeSession", 0)
	end

	function meta:SetTotalTime(n)
		ply:SetNWInt("TotalTime", tonumber(n) or ply:GetTotalTime() or 0)
	end
end

if SERVER then
	if nAdminDBFail then return end
	local meta = FindMetaTable'Player'

	function meta:SetPTime(TIME, setnwint)
		if not IsValid(self) then return end
		local ACID = self:AccountID()
		local Q = nAdminDB:query("REPLACE INTO nAdmin_time (infoid, time) VALUES (" .. SQLStr(ACID) .. ", " .. SQLStr(TIME) .. ")")
		function Q:onError(err)
			nAdmin.Print("Запрос выдал ошибку: " .. err)
		end
		self:GetPTime(function(time)
			if setnwint then
				Q:start()
				return
			end
			if TIME > time then
				Q:start()
			else
				nAdmin.Print(self:Name() .. " > что время хуевое какого хуя " .. tostring(TIME) .. " < " .. tostring(time))
				self:SetPTime(time, true)
			end
		end)
		if setnwint then
			self:SetNWInt("TotalTime", TIME)
		end
	end

	function meta:GetPTime(func)
		if not IsValid(self) then return end
		local ACID = self:AccountID()
		local Q = nAdminDB:query("SELECT time FROM nAdmin_time WHERE infoid = " .. SQLStr(ACID) .. " LIMIT 1")
		function Q:onError(err)
			nAdmin.Print("Запрос выдал ошибку: " .. err)
		end
		Q:start()
		function Q:onSuccess(data)
			if data and data[1] then
				func(data[1].time)
			else
				func(0)
			end
		end
	end

	function meta:RemovePTime()
		if not IsValid(self) then return end
		local ACID = self:AccountID()
		local Q = nAdminDB:query("DELETE FROM nAdmin_time WHERE infoid = " .. SQLStr(ACID))
		function Q:onError(err)
			nAdmin.Print("Запрос выдал ошибку: " .. err)
		end
		Q:start()
	end

    hook.Add("PlayerInitialSpawn", "nAdmin_PTime", function(ply)
        ply:SetNWInt("StartTimeSession", CurTime())
		ply:GetPTime(function(a)
			ply:SetNWInt("TotalTime", a)
		end)
    end)

    hook.Add("PlayerDisconnected", "nAdmin_PTime", function(ply)
        ply:SetPTime(ply:GetTotalTime(), false)
    end)

	local function savePTime()
		for _, ply in ipairs(player.GetAll()) do
			ply:SetPTime(math.Round(ply:GetTotalTime()), false)
		end
	end

	savePTime()

	timer.Create("savePTime", 300, 0, savePTime)

	nAdmin.AddCommand("restoretime", false, function(ply)
		timer.Simple(1, function()
			--local query = sql.QueryRow("SELECT totaltime FROM utime WHERE player = " .. ply:UniqueID() .. ";")
			local ACID = ply:AccountID()
			local Q = nAdminDB:query("SELECT * FROM `ulxtime` WHERE `player` = " .. ply:UniqueID())
			function Q:onError(err)
				nAdmin.Print("Запрос выдал ошибку: " .. err)
			end
			function Q:onSuccess(data)
				if data and data[1] then
					ply:GetPTime(function(a)
						if a > data[1].totaltime then
							ply:ChatPrint("В базе данных число меньше чем на сервере. Отмена восстановлению часов.")
							return
						end
						ply:SetPTime(data[1].totaltime + (10 * 60 * 60), true)
						ply:ChatPrint("Восстановлено!")
						timer.Simple(3, function()
							local a = nAdminDB:query("DELETE FROM `ulxtime` WHERE `player` = " .. ply:UniqueID() .. ";")
							a:start()
						end)
					end)
				else
					ply:ChatPrint("Ваше время не найдено.")
				end
			end
			Q:start()
		end)
	end)
end