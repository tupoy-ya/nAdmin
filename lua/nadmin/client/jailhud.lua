surface.CreateFont("nAdmin_JailHUD", {font = "Roboto", size = 24, antialias = true, extended = true})

net.Receive("nAdmin_JailHUD", function()
	local a = net.ReadFloat()
	local r = RealTime() + a
	local b = 0

	if a == 0 then
		r = "Бесконечно"
		b = r
	end

	hook.Add("HUDPaint", "nAdmin_JailHUD", function()
		if isnumber(r) then
			b = math.Round(r - RealTime())
		end

		surface.SetDrawColor(50, 50, 50, 50)
		surface.DrawRect(ScrW() / 2 - 300, ScrH() / 2 - 150, 600, 50)

		surface.SetFont'nAdmin_JailHUD'

		local w = surface.GetTextSize("Вы посажены в гулаг!")

		surface.SetTextColor(0, 0, 0)
		surface.SetTextPos(ScrW() / 2 - w / 2 + 1, ScrH() / 2 - 150 + 1)
		surface.DrawText("Вы посажены в гулаг!")

		surface.SetTextColor(255, 255, 255)
		surface.SetTextPos(ScrW() / 2 - w / 2, ScrH() / 2 - 150)
		surface.DrawText("Вы посажены в гулаг!")

		local w = surface.GetTextSize("Вам осталось сидеть: " .. b .. " секунд.")

		surface.SetTextColor(0, 0, 0)
		surface.SetTextPos(ScrW() / 2 - w / 2 + 1, ScrH() / 2 - 125 + 1)
		surface.DrawText("Вам осталось сидеть: " .. b .. " секунд.")

		surface.SetTextColor(255, 255, 255)
		surface.SetTextPos(ScrW() / 2 - w / 2, ScrH() / 2 - 125)
		surface.DrawText("Вам осталось сидеть: " .. b .. " секунд.")

		if (isnumber(b) and b < 0) or not LocalPlayer():GetNWBool("nAdmin_InJail") then
			p(isnumber(b), b, LocalPlayer():GetNWBool("nAdmin_InJail"))
			hook.Remove("HUDPaint", "nAdmin_JailHUD")
		end
	end)
end)