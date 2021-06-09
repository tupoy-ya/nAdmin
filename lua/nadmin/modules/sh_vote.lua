if SERVER then
	util.AddNetworkString("nAdmin_votekick")
	local current_status = false
	local next_Kick = CurTime()
	local results = {}
	net.Receive("nAdmin_votekick", function(_, ply)
		if current_status == false then return end
		local int = net.ReadUInt(3)
		if int == 1 then
			if results[ply] then
				return
			end
			local fl = net.ReadFloat()
			results[ply] = fl
			net.Start("nAdmin_votekick")
				net.WriteUInt(3, 3)
				net.WriteEntity(ply)
				net.WriteFloat(fl)
			net.Broadcast()
		end
	end)
	nAdmin.AddCommand("votekick", false, function(ply, args)
		if current_status then
			nAdmin.Warn(ply, "В данный момент уже идет какое-то голосование!")
			return
		end
		local check = nAdmin.ValidCheckCommand(args, 2, ply, "votekick")
		if not check then
			return
		end
		local pl = nAdmin.FindByNick(args[1])
		if pl == nil then
			nAdmin.Warn(ply, "Игрока с таким именем нет на сервере!")
			return
		end
		if next_Kick > CurTime() then
			nAdmin.Warn(ply, "Подождите ещё: " .. math.Round(next_Kick - CurTime()) .. " секунд!")
			return
		end
		results = {}
		next_Kick = CurTime() + 60
		local answers = {[1] = "Да.", [2] = "Нет."}
		table.sort(answers, function(a, b) return #a < #b end)
		local a = util.Compress(util.TableToJSON(answers))
		local ass = {}
		for k, v in next, args do
			if k > 1 then
				table.insert(ass, v)
			end
		end
		local ass2 = table.concat(ass, " ")
		net.Start("nAdmin_votekick")
			net.WriteUInt(1, 3)
			net.WriteString("Выгнать " .. pl:Name() .. "? (Причина: " .. ass2 .. "; создал: " .. ply:Name() .. ")")
			net.WriteUInt(#a, 16)
			net.WriteData(a)
		net.Broadcast()
		current_status = true
		timer.Create("nAdmin_Vote", 20, 1, function()
			net.Start("nAdmin_votekick")
				net.WriteUInt(2, 3)
			net.Broadcast()
			current_status = false
			local c = table.Count(results)
			if c == 0 then return end
			local final = {}
			for i = 1, #answers do
				final[i] = 0
			end
			for _, vote in next, results do
				final[vote] = (final[vote] or 0) + 1
			end
			local first = table.GetWinningKey(final)
			nAdmin.WarnAll("В голосовании победил ответ: " .. answers[first])
			if not IsValid(pl) then
				nAdmin.WarnAll("Игрок, которого пытались выгнать, вышел с сервера.")
			end
			if first == 1 then
				pl:Kick("Вас выгнали всеобщим голосованием. Причина: " .. ass2 .. "; голосование создал: " .. ply:Name())
			end
		end)
	end)
	nAdmin.SetTAndDesc("votekick", "user", "Запускает голование на кик игрока. arg1 - ник, arg2 - причина.")

	nAdmin.AddCommand("vote", false, function(ply, args)
		if current_status then
			nAdmin.Warn(ply, "В данный момент уже идет какое-то голосование!")
			return
		end
		local check = nAdmin.ValidCheckCommand(args, 2, ply, "vote")
		if not check then
			return
		end
		if next_Kick > CurTime() then
			nAdmin.Warn(ply, "Подождите ещё: " .. math.Round(next_Kick - CurTime()) .. " секунд!")
			return
		end
		local count = table.Count(args)
		if count >= 7 then
			nAdmin.Warn(ply, "Нельзя сделать больше 7 ответов")
			return
		end
		if count < 3 then
			return
		end
		results = {}
		next_Kick = CurTime() + 5
		local dop = {}
		local answers = {}
		local args_copy = table.Copy(args)
		for i = 1, #args do
			answers[i] = args_copy[i + 1]
		end
		table.sort(answers, function(a, b) return #a < #b end)
		local a = util.Compress(util.TableToJSON(answers))
		net.Start("nAdmin_votekick")
			net.WriteUInt(1, 3)
			net.WriteString(args[1])
			net.WriteUInt(#a, 16)
			net.WriteData(a)
		net.Broadcast()
		current_status = true
		timer.Create("nAdmin_Vote", 20, 1, function()
			net.Start("nAdmin_votekick")
				net.WriteUInt(2, 3)
			net.Broadcast()
			current_status = false
			local c = table.Count(results)
			if c == 0 then return end
			local final = {}
			for i = 1, #answers do
				final[i] = 0
			end
			for _, vote in next, results do
				final[vote] = (final[vote] or 0) + 1
			end
			local first = table.GetWinningKey(final)
			nAdmin.WarnAll("В голосовании победил ответ: " .. answers[first])
		end)
	end)
	nAdmin.SetTAndDesc("vote", "osobenniy2", "Запускает голование на кик игрока. arg1 - что обсуждаем, arg2, arg3, arg4. (необязательно).")

	local nextCleanMap = 0
	nAdmin.AddCommand("votecleanmap", false, function(ply, args)
		if current_status then
			nAdmin.Warn(ply, "В данный момент уже идет какое-то голосование!")
			return
		end
		local pl = nAdmin.FindByNick(args[1])
		if pl == nil then
			nAdmin.Warn(ply, "Игрока с таким именем нет на сервере!")
			return
		end
		if nextCleanMap > CurTime() then
			nAdmin.Warn(ply, "Подождите ещё: " .. math.Round(nextCleanMap - CurTime()) .. " секунд!")
			return
		end
		results = {}
		nextCleanMap = CurTime() + 1800
		local answers = {[1] = "Да.", [2] = "Нет."}
		table.sort(answers, function(a, b) return #a < #b end)
		local a = util.Compress(util.TableToJSON(answers))
		local ass = {}
		for k, v in next, args do
			if k > 1 then
				table.insert(ass, v)
			end
		end
		local ass2 = table.concat(ass, " ")
		net.Start("nAdmin_votekick")
			net.WriteUInt(1, 3)
			net.WriteString(ply:Name() .. " желает очистить карту.")
			net.WriteUInt(#a, 16)
			net.WriteData(a)
		net.Broadcast()
		current_status = true
		timer.Create("nAdmin_Vote", 20, 1, function()
			net.Start("nAdmin_votekick")
				net.WriteUInt(2, 3)
			net.Broadcast()
			current_status = false
			local c = table.Count(results)
			if c == 0 then return end
			local final = {}
			for i = 1, #answers do
				final[i] = 0
			end
			for _, vote in next, results do
				final[vote] = (final[vote] or 0) + 1
			end
			local first = table.GetWinningKey(final)
			nAdmin.WarnAll("В голосовании победил ответ: " .. answers[first])
			if first == 1 then
				PrintMessage(3, "Через 5 минут произойдет очистка пропов!")
				nAdmin.Countdown(300, function()
					RunConsoleCommand("gmod_admin_cleanup")
				end)
			end
		end)
	end)
	nAdmin.SetTAndDesc("votecleanmap", "e2_coder", "Запускает голование на очистку карты.")

	nAdmin.AddCommand("stopvote", false, function(ply, args)
		if not current_status then
			nAdmin.Warn(ply, "В данный момент нет никакого голосования!")
			return
		end
		if timer.Exists("nAdmin_Vote") then
			timer.Remove("nAdmin_Vote")
		end
		net.Start("nAdmin_votekick")
			net.WriteUInt(2, 3)
		net.Broadcast()
		current_status = false
		nAdmin.WarnAll(ply:Name() .. " отменил голосование.")
	end)
	nAdmin.SetTAndDesc("stopvote", "osobenniy2", "Отменить голосование.")
end

if CLIENT then
	surface.CreateFont("nAdmin_votekick_Font", {font = "Roboto", size = 24, antialias = true, extended = true})
	local results = {}
	local function create_vote(reason, TB)
		results = {}
		local count, alpha, max_, lerp, alphaon = #TB, 255, 0, -50, false

		hook.Add("DrawOverlay", "VoteShow", function()
			lerp = Lerp(FrameTime() * 6, lerp, 30)
			surface.SetFont("nAdmin_votekick_Font")

			local w, h = surface.GetTextSize(reason)
			for i = 1, count do
				local v = TB[i]
				local as = surface.GetTextSize(i .. ". " .. v .. " (" .. (results[i] or 0) .. ")")
				if as > w then
					w = as
				end
			end

			if alphaon then
				alpha = Lerp(FrameTime() * 4, alpha, 100)
			end

			surface.SetDrawColor(200, 200, 200, alpha)
			surface.DrawRect(ScrW() / 2 - w / 2 - 2 - 10, ScrH() - lerp - count * 24, w + 24, 29 + count * 24)

			surface.SetDrawColor(50, 50, 50, 255)
			surface.DrawRect(ScrW() / 2 - w / 2 - 10, ScrH() - lerp + 2 - count * 24, w + 20, 25 + count * 24)

			surface.SetTextColor(255, 255, 255, alpha)
			surface.SetTextPos(ScrW() / 2 - w / 2, ScrH() - lerp + 2 - count * 24) 
			surface.DrawText(reason)
			for i = 1, count do
				surface.SetTextColor(255, 255, 255, alpha)
				surface.SetTextPos(ScrW() / 2 - w / 2, ScrH() - lerp - count * 24 + i * 24) 
				surface.DrawText(i .. ". " .. TB[i] .. " (" .. (results[i] or 0) .. ")")
			end
		end)

		hook.Add("PlayerBindPress", "plBindVote", function(ply, bind, pressed)
			if string.find(bind, "slot*") then
				local num = tonumber(string.sub(bind, #bind, #bind))
				if TB[num] then
					net.Start("nAdmin_votekick")
						net.WriteUInt(1, 3)
						net.WriteFloat(num)
					net.SendToServer()
					hook.Remove("PlayerBindPress", "plBindVote")
					alphaon = true
					--hook.Remove("DrawOverlay", "VoteShow")
					return true
				end
			end
		end)
	end

	local cT = {}
	net.Receive("nAdmin_votekick", function()
		local int =  net.ReadUInt(3)
		if int == 1 then -- [[ START VOTE ]] --
			local str = net.ReadString()
			local int = net.ReadUInt(16)
			local t = net.ReadData(int)
			t = util.JSONToTable(util.Decompress(t))
			cT = t
			create_vote(str, t)
			surface.PlaySound("buttons/button3.wav")
		end
		if int == 2 then -- [[ STOP VOTE ]] --
			hook.Remove("PlayerBindPress", "plBindVote")
			hook.Remove("DrawOverlay", "VoteShow")
			results = {}
		end
		if int == 3 then -- [[ + VOTE ]] --
			local ent = net.ReadEntity()
			local fl = net.ReadFloat()
			if not IsValid(ent) then return end
			results[fl] = (results[fl] or 0) + 1
			notification.AddLegacy(((ent:IsPlayer() and ent:Name()) or "???") .. " проголосовал за: " .. ((cT and cT[fl]) or "???"), NOTIFY_GENERIC, 3)
			surface.PlaySound("buttons/button9.wav")
		end
	end)
end