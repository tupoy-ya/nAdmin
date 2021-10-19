if CLIENT then
    net.Receive("nAdmin_countdown", function()
		local int = net.ReadUInt(1)
		if int == 0 then
			LocalPlayer():EmitSound("buttons/blip1.wav", 100, 100)
			local t = net.ReadFloat()
			local count = RealTime() + t
			local m = 0
			local stop = RealTime()
			local i = 0
			local l = 0
			local l2 = 0
			hook.Add("HUDPaint", "countdown", function()
				surface.SetFont'DermaLarge'
				local time = count - RealTime()
				local pr = (count - RealTime()) / t
				pr = math.Clamp(pr, 0, 1)
				local txt = ("%.2d:%05.2f"):format(math.floor(time / 60), math.Round(time, 2) % 60)
				if math.floor(time / 60) < 0 then
					txt = "00:00.00"
					m = math.cos(CurTime() * 6)
					m = math.abs(m)
					m = math.Round(m)
					if m == 1 and stop < RealTime() then
						stop = RealTime() + .5
						i = i + 1
						l2 = RealTime()
						LocalPlayer():EmitSound("buttons/blip1.wav", 100, 100)
					end
					if i >= 6 then
						m = 0
						stop = math.huge
						l = math.Clamp(-((l2 + 6) - RealTime()), 0, 1)
						if l > .99 then
							hook.Remove("HUDPaint", "countdown")
						end
					end
				end
				local w = surface.GetTextSize(txt)
				for i = -1, 0 do
					surface.SetTextColor(255 + i * 255, 255 + i * 255, 255 + i * 255, 255 - m * 255 - l * 255)
					surface.SetTextPos(ScrW() / 2 - w / 2 - i, ScrH() / 2 - 230 - i)
					surface.DrawText(txt)
				end

				draw.RoundedBox(0, ScrW() / 2 - 500 / 2, ScrH() / 2 - 200 - 1, 500, 30 + 4, Color(0, 0, 0, 230 - m * 230 - l * 255))
				for i = 1, 2 do
					draw.RoundedBox(0, ScrW() / 2 - 500 / 2 + 2.5, ScrH() / 2 - 212 + i * 14, pr * 496, 28 / 2, Color(0, 100 + i * 50, 0, 255 - m * 255 - l * 255))
				end
			end)
		elseif int == 1 then
			hook.Remove("HUDPaint", "countdown")
		end
    end)
else
    util.AddNetworkString("nAdmin_countdown")
	function nAdmin.Countdown(count_, func)
        local count = tonumber(count_)
        if count == nil then
            return
        end
		count = math.Clamp(count, 0, 1800)
        net.Start("nAdmin_countdown")
			net.WriteUInt(0, 1)
            net.WriteFloat(count)
        net.Broadcast()
		timer.Create("nAdmin_countdown", count, 1, function()
			if func then
				func()
			end
			nAdmin.Print("Отсчёт завершён!")
		end)
	end
	function nAdmin.StopCountdown()
        net.Start("nAdmin_countdown")
			net.WriteUInt(1, 1)
        net.Broadcast()
		timer.Remove("nAdmin_countdown")
		nAdmin.WarnAll("Отсчёт был остановлен.")
	end
    nAdmin.AddCommand("countdown", false, function(ply, args)
		local check = nAdmin.ValidCheckCommand(args, 1, ply, "countdown")
		if not check then
			return
        end
        nAdmin.Countdown(args[1])
    end)
    nAdmin.SetTAndDesc("countdown", "admin", "Включить обратный отсчёт. arg1 - время (в секундах).")
    nAdmin.AddCommand("stopcountdown", false, function(ply, args)
		if not timer.Exists("nAdmin_countdown") then
			nAdmin.Warn(ply, "На данный момент нет никакого отсчёта времени.")
			return
		end
        nAdmin.StopCountdown()
    end)
    nAdmin.SetTAndDesc("stopcountdown", "moderator", "Остановить обратный отсчёт.")
end