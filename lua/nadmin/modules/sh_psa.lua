if CLIENT then
	surface.CreateFont("nAdmin_PSA", {font = "Roboto", size = 35, antialias = true, extended = true})
	if not file.Exists("cbox_cache", "DATA") then
		file.CreateDir("cbox_cache")
	end
	if not file.Exists("cbox_cache/msg.mp3", "DATA") then
		http.Fetch("http://" .. game.GetIPAddress():sub(1, #game.GetIPAddress() - 6) .. "/media/opoveshalka.mp3", function(a)
			file.Write("cbox_cache/msg.mp3", a)
		end)
	end
	function nAdmin.PSA(txt)
		local lerp = -100
		local realtime = RealTime()
		local a
		local function ParseE(str)
			if a ~= nil then
				return a
			end
			a = ec_markup.AdvancedParse("<color=255, 255, 255>" .. str, {
				nick = false,
				default_color = Color(255, 255, 255),
				default_font = "nAdmin_PSA",
				default_shadow_font = "nAdmin_PSA",
				shadow_intensity = 1
			})
			return a
		end
		hook.Add("DrawOverlay", "nAdmin_PSA", function()
			if (realtime + 10) - RealTime() > 0 then
				lerp = Lerp(FrameTime() * 3, lerp, 0)
			else
				lerp = Lerp(FrameTime() * 3, lerp, -120)
			end
			if ec_markup then
				local txt_ = ParseE(txt)
				local tall = txt_:GetTall()
				surface.SetDrawColor(200, 200, 200)
				surface.DrawRect(0, lerp, ScrW(), tall + 2)
				surface.SetDrawColor(40, 40, 40)
				surface.DrawRect(0, lerp, ScrW(), tall)
				txt_:Draw(ScrW() / 2 - txt_:GetWide() / 2, lerp - 2)
			else
				surface.SetDrawColor(200, 200, 200)
				surface.DrawRect(0, lerp, ScrW(), 35 + 2)
				surface.SetDrawColor(40, 40, 40)
				surface.DrawRect(0, lerp, ScrW(), 35)
				surface.SetFont'nAdmin_PSA'
				local tx = surface.GetTextSize(txt)
				surface.SetTextColor(255, 255, 255)
				surface.SetTextPos(ScrW() / 2 - tx / 2, lerp - 2)
				surface.DrawText(txt)
			end
			if -lerp >= 119 then
				hook.Remove("DrawOverlay", "nAdmin_PSA")
			end
		end)
		sound.PlayFile("data/cbox_cache/msg.mp3", "mono noblock", function(s)
			if IsValid(s) then
				s:Play()
			end
		end)
	end
	net.Receive("nAdmin_PSA", function()
		local txt = net.ReadString()
		nAdmin.PSA(txt)
	end)
end

if SERVER then
	util.AddNetworkString("nAdmin_PSA")
	nAdmin.AddCommand("psa", false, function(ply, args)
		local cock = table.concat(args, " ")
		net.Start("nAdmin_PSA")
			net.WriteString(cock)
		net.Broadcast()
		nAdmin.WarnAll(ply:Name() .. " > " .. cock)
	end)
	nAdmin.SetTAndDesc("psa", "admin", "Оповестить игроков о чём-либо. arg(...) - текст.")
	nAdmin.CmdHidden("psa")
end