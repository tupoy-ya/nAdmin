nAdmin.FULLCMDS = false

surface.CreateFont("nAdmin_desc", {font = "Roboto", size = 18, antialias = true, extended = true})
surface.CreateFont("nAdmin_desc2", {font = "Roboto", size = 18, antialias = true, extended = true})
surface.CreateFont("logs", {font = "Roboto Bold", size = 12, antialias = true, extended = true})

if IsValid(nGUI) then
	nGUI:Remove()
	gui.EnableScreenClicker(false)
end

function nAdmin.mGUI()
	if not nAdmin.FULLCMDS then
		net.Start("nAdmin_message")
			net.WriteUInt(1, 2)
		net.SendToServer()
		nAdmin.FULLCMDS = true
	end

	local a = {}
	local cYes = {}
	local usergroup = LocalPlayer():GetUserGroup()
	local clr = Color(200, 200, 200)
	local clr2 = Color(40, 40, 40)
	nGUI = vgui.Create'DFrame'
	nGUI:SetSize(500, 300)
	nGUI:Center()
	nGUI:SetTitle("")
	nGUI:SetVisible(true)
	nGUI:MakePopup()
	nGUI:SetKeyboardInputEnabled(false)
	gui.EnableScreenClicker(true)
	nGUI:ShowCloseButton(false)
    nGUI.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50))
        draw.RoundedBox(0, 2, 2, w - 4, h - 4, Color(40, 40, 40))
        draw.RoundedBox(0, 0, 22, w, 2, Color(50, 50, 50))
        draw.RoundedBox(0, 2, 2, w - 4, 10, Color(120, 120, 120))
        draw.RoundedBox(0, 2, 2 + 10, w - 4, 10, Color(140, 140, 140))
		draw.SimpleText("[nAdmin]", "nAdmin_desc2", 5 + 1, 3 + 1, color_black)
		draw.SimpleText("[nAdmin]", "nAdmin_desc2", 5, 3, color_white)
    end
    local close = nGUI:Add("DButton")
    close:SetSize(28, 24)
    close:SetPos(nGUI:GetWide() - 28, 0)
    close:SetText''
    close.Paint = function(self, w, h)
        draw.NoTexture()
        surface.SetDrawColor(color_black)
        surface.DrawTexturedRectRotated(w / 2, 12, 16, 2, 45)
        draw.NoTexture()
        surface.SetDrawColor(color_black)
        surface.DrawTexturedRectRotated(w / 2, 12, 16, 2, -45)
    end
    close.DoClick = function()
		nGUI:AlphaTo(0, .1, 0, function()
			nGUI:Close()
		end)
    end
	nGUI.OnClose = function()
		gui.EnableScreenClicker(false)
	end
	nGUI:SetDeleteOnClose(false)

	local clist = vgui.Create('DListView', nGUI)
	clist:Dock(LEFT)
	clist:DockMargin(0, 0, 0, 20)
	clist:SetPos(0, -30)
	clist:SetSize(150, 0)
	clist:SetMultiSelect(false)
	clist:AddColumn("Команды")
	local search = vgui.Create('DTextEntry', nGUI)
	search:SetPos(5, 275)
	search:SetSize(150, 20)
	search:SetPlaceholderText'поиск'
	local changed = ""
	nGUI.Think = function()
		local cCount = 0
		local l = 0
		local txt = search:GetText()
		if changed ~= txt or usergroup ~= LocalPlayer():GetUserGroup() then
			usergroup = LocalPlayer():GetUserGroup()
			clist:Clear()
			changed = txt
			a = {}
			cYes = {}
		end
		for k, d in next, nAdmin.Commands do
			if LocalPlayer():Team() > Global_Teams[d.T or "user"].num then continue end
			if txt == nil then
				cCount = cCount + 1
				a[cCount] = k
			else
				local wf = nAdmin.Commands[k].desc
				if wf == nil then
					wf = ""
				end
				if string.find(k, txt, 1, true) or string.find(wf, txt, 1, true) then
					cCount = cCount + 1
					a[cCount] = k
				end
			end
		end
		table.sort(a)
	end
	clist.Think = function()
		for i = 1, #a do
			if cYes[a[i]] then continue end
			cYes[a[i]] = true
			clist:AddLine(a[i])
			clist:SortByColumn(1)
		end
	end
	local ps = vgui.Create('DPanel', nGUI)
	ps:SetBackgroundColor(Color(20, 20, 20))
	ps:SetSize(330, 50)
	ps:SetPos(clist:GetWide() + 10 + 1, 40)
	local des = ""
	local cm = ""
	local entries = {}
	local gT = ""
	local butn

	local onrowselectedplayer
	clist.OnRowSelected = function(self, rowi, row)
		onrowselectedplayer = nil
		for k, v in ipairs(entries) do
			if IsValid(v) then
				v:Remove()
			end
		end
		if IsValid(butn) then
			butn:Remove()
		end
		if nAdmin.Commands[row:GetValue(1)] == nil then
			nAdmin.Print("Ошибка при обновлении списка команд!")
			return
		end
		local t = nAdmin.Commands[row:GetValue(1)].T or ""
		cm = row:GetValue(1)
		if Global_Teams[t] and Global_Teams[t].n then
			gT = Global_Teams[t].num
			des = (nAdmin.Commands[row:GetValue(1)].desc or "") .. (t ~= nil and " \nДоступно с: " .. Global_Teams[t].n or "")
		else
			des = ""
		end
		local cfind = 0
		entries = {}
		timer.Simple(0, function()
			local e = string.Explode(" ", des)
			for k, v in next, e do
				if v:find("arg") then
					cfind = cfind + 1
					local val_enter = vgui.Create('DTextEntry', nGUI)
					val_enter:SetSize(130, 25)
					table.insert(entries, val_enter)
					local name = e[k + 2]
					local fint = name:find","
					local m = name:sub(1, ((fint or 0) - 1) or #name)
					local s = string.Trim(m, ".")
					if cm == "vote" then
						goto skip
					end
					if s:find("ник") then
						timer.Simple(0, function()
							local bu = vgui.Create('DButton', nGUI)
							local aye, bye = val_enter:GetPos()
							bu:SetPos(aye + val_enter:GetWide(), bye + val_enter:GetTall() - 15)
							bu:SetSize(15, 15)
							bu:SetText("")
							butn = bu
							bu.DoClick = function()
								local m = DermaMenu()
								for k, v in ipairs(player.GetAll()) do
									if nAdmin.UseNickWithoutTags then
										m:AddOption(v:NameWithoutTags() .. " (" .. v:GetName() .. ")", function()
											onrowselectedplayer = v:EntIndex()
											val_enter:SetText(v:NameWithoutTags())
										end)
									else
										m:AddOption(v:NameWithoutTags(), function()
											onrowselectedplayer = v:EntIndex()
											val_enter:SetText(v:NameWithoutTags())
										end)
									end
								end
								m:SetMaxHeight(500)
								m:Open()
								local plcount = player.GetCount()
								m.Think = function(self)
									if plcount ~= player.GetCount() then
										CloseDermaMenus()
									end
								end
							end
							bu.Think = function(self)
								if not IsValid(val_enter) then
									self:Remove()
								end
							end
						end)
					end
					val_enter:SetPlaceholderText(s)
					::skip::
					if ps and val_enter then
						val_enter:SetPos(162, 35 + ps:GetTall() + cfind * 27)
					end
				end
			end
		end)
	end
	local argsInf = vgui.Create('DLabel', nGUI)
	argsInf:SetSize(150, 50)
	argsInf:SetText("Ввод аргументов:")
	argsInf:SetTextColor(color_white)
	argsInf:SetFont("nAdmin_desc")
	argsInf.Think = function()
		if #entries == 0 then
			argsInf:SetText("")
		else
			argsInf:SetText("Ввод аргументов:")
		end
		argsInf:SetPos(162, 25 + ps:GetTall())
	end
	for i = 1, 2 do
		local dc = vgui.Create('DLabel', ps)
		dc:SetSize(320, 70)
		dc:SetText("")
		if i == 1 then
			dc:SetTextColor(Color(60, 60, 60))
		else
			dc:SetTextColor(color_white)
		end
		dc:SetFont("nAdmin_desc")
		dc:SetWrap(true)
		dc.Think = function()
			local a = des
			if des == "" then
				des = (cm ~= "" and cm or "no value") .. ": Нет описания."
			end
			dc:SetText(des)
			local a, b = dc:GetTextSize()
			if i == 1 then
				dc:SetPos(5 + 1, -30 + b * .45 + 1)
			else
				dc:SetPos(5, -30 + b * .45)
			end
			ps:SetSize(330, 10 + b)
		end
	end
	local runCommand = vgui.Create('DTextEntry', nGUI)
	runCommand:Dock(BOTTOM)
	runCommand.Think = function()
		if #entries == 0 then
			runCommand:SetText("n \"" .. cm .. "\"")
			return
		end
		local msg = "n \"" .. cm .. "\""
		for k, v in ipairs(entries) do
			msg = msg .. (v:GetText() ~= "" and " \"" .. v:GetText() .. "\"" or "")
		end
		runCommand:SetText(msg)
	end
	local but = vgui.Create('DButton', nGUI)
	but:SetText("Запустить выбранную команду")
	but:SetSize(175, 25)
	but.Think = function()
		local args = 0
		local allargs = 0
		for k, v in ipairs(entries) do
			allargs = allargs + 1
			if v:GetText() ~= "" then
				args = args + 1
			end
		end
		if allargs == args or not des:find("arg") then
			but:SetDisabled(false)
		else
			if not des:find'необязательно' then
				but:SetDisabled(true)
			end
		end
		but:SetPos(315, ps:GetTall() + 45)
	end
	local logs = vgui.Create("RichText", nGUI)
	logs:SetVerticalScrollbarEnabled(false)
	logs:SetSize(180, 200)
	logs:SetPos(315, ps:GetTall() + 75)
	logs.Think = function()
		logs:SetSize(180, 200 - ps:GetTall())
		logs:SetPos(315, ps:GetTall() + 75)
	end
	logs.PerformLayout = function()
		logs:SetFontInternal("logs")
	end
	but.DoClick = function()
		local a = SysTime()
		local gTN = tonumber(gT)
		local ch = gTN ~= nil and gTN or 1
		if LocalPlayer():Team() > ch then
			logs:InsertColorChange(215, 0, 0, 255)
			logs:AppendText("Нет доступа!\n")
			return
		end
		local msg = runCommand:GetText()
		msg = msg:gsub("\n", ""):gsub(";", ":"):gsub("\"", "/"):gsub("//", "/"):gsub(" /", "")
        msg = msg:sub(1, #msg - 1)
		local stringexpl = string.Explode("/", msg)
        local b = {}
        stringexpl[1] = stringexpl[1]:sub(2, #stringexpl[1])
		if stringexpl[1] ~= nil then
			for i = 1, #stringexpl do
				table.insert(b, stringexpl[i])
			end
        end
		if b[1] == "" then return end
		if onrowselectedplayer ~= nil and b[2] then
			b[2] = onrowselectedplayer
		end
        nAdmin.NetCmdExec(_, b)
		--LocalPlayer():ConCommand(msg)
	end
	local copy = vgui.Create('DButton', nGUI)
	copy:SetText("Скопировать")
	copy:SetSize(100, 20)
	copy:SetZPos(9999)
	copy.Think = function()
		local x, y = runCommand:GetPos()
		copy:SetPos(x + runCommand:GetWide() - 100, y)
	end
	copy.DoClick = function()
		SetClipboardText(runCommand:GetText())
	end
	hook.Add("nAdmin_SystimeUpdate", "", function(a, b)
		if a then
			b = b .. "; " .. math.Round((SysTime() - a or SysTime()), 6)
		end
		logs:InsertColorChange(200, 200, 200, 255)
		logs:AppendText("[" .. os.date("%H:%M:%S") .. "] " .. b .. "\n")
	end)
end

local function getKeyboardFocus(pnl)
	if not IsValid(nGUI) then return end
	pnl:SetKeyboardInputEnabled(true)
	nGUI:SetKeyboardInputEnabled(true)
	pnl:RequestFocus()
end
hook.Add("OnTextEntryGetFocus", "nAdmin_GUIfocus", getKeyboardFocus)

local function loseKeyboardFocus(pnl)
	if not IsValid(nGUI) then return end
	pnl:SetKeyboardInputEnabled(false)
	nGUI:SetKeyboardInputEnabled(false)
end
hook.Add("OnTextEntryLoseFocus", "nAdmin_GUIloss", loseKeyboardFocus)