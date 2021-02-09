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
		ply:SetNWInt("TotalTime", tonumber(n))
	end
end

if SERVER then
    hook.Add("PlayerInitialSpawn", "PTime", function(ply)
        ply:SetNWInt("StartTimeSession", CurTime())
        ply:SetNWInt("TotalTime", tonumber(ply:GetPData("TimeOnServer", 0)))
    end)

    hook.Add("PlayerDisconnected", "PTime", function(ply)
        ply:SetPData("TimeOnServer", ply:GetTotalTime())
    end)

	local function savePTime()
		for _, ply in ipairs(player.GetAll()) do
			ply:SetPData("TimeOnServer", ply:GetTotalTime())
		end
	end

	timer.Create("savePTime", 180, 0, savePTime)
end