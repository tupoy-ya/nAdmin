surface.CreateFont("nAdmin_desc", {font = "Roboto", size = 18, antialias = true, extended = true})
surface.CreateFont("logs", {font = "Roboto Bold", size = 12, antialias = true, extended = true})
if IsValid(nGUI) then
	nGUI:Remove()
	gui.EnableScreenClicker(false)
end
nAdmin.FullCMDS = false
function nAdmin.mGUI()
	local a = {}
	local cYes = {}
	nGUI = vgui.Create'DFrame'
	nGUI:SetSize(500, 300)
	nGUI:Center()
	nGUI:SetTitle("")
	nGUI:SetVisible(true)
	nGUI:MakePopup()
	nGUI:SetKeyboardInputEnabled(false) -- гениально блять
	gui.EnableScreenClicker(true)
	nGUI.Paint = function(self, w, h)
		draw.RoundedBox(5, 0, 0, w, h, Color(200, 200, 200))
		draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(40, 40, 40))
	end
	nGUI.OnClose = function()
		nAdmin.VisibleGUI = false
		gui.EnableScreenClicker(false)
	end
	nGUI:SetDeleteOnClose(false)

	local title = vgui.Create('DLabel', nGUI)
	title:SetSize(100, 25)
	title:SetPos(5, 4)
	title:SetText("[nAdmin]")
	title:SetTextColor(Color(230, 230, 230))
	title:SetFont("nAdmin_desc")

	local clist = vgui.Create('DListView', nGUI)
	clist:Dock(LEFT)
	clist:DockMargin(0, 20, 0, 0)
	clist:SetSize(150, 0)
	clist:SetMultiSelect(false)
	clist:AddColumn("Команды")
	local search = vgui.Create('DTextEntry', nGUI)
	search:SetPos(5, 28)
	search:SetSize(150, 20)
	net.Start("nadmin_message")
		net.WriteUInt(1, 1)
	net.SendToServer()
	local changed = ""
	nGUI.Think = function()
		local cCount = 0
		local l = 0
		local txt = search:GetText()
		if changed ~= txt then
			clist:Clear()
			changed = txt
			a = {}
			cYes = {}
		end
		if txt == "" then
			for k in next, nAdmin.Commands do
				cCount = cCount + 1
				a[cCount] = k
			end
			table.sort(a)
		else
			for k in next, nAdmin.Commands do
				local wf = nAdmin.Commands[k].desc
				if wf == nil then
					wf = ""
				end
				if string.match(k, txt) or string.match(wf, txt) then
					cCount = cCount + 1
					a[cCount] = k
				end
			end
			table.sort(a)
		end
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

	clist.OnRowSelected = function(self, rowi, row)
		for k, v in ipairs(entries) do
			if IsValid(v) then
				v:Remove()
			end
		end
		if IsValid(butn) then
			butn:Remove()
		end
		entries = {}
		if nAdmin.Commands[row:GetValue(1)] == nil then
			nAdmin.Print("Ошибка при обновлении списка команд. Обновляю таблицу...")
			net.Start("nadmin_message")
				net.WriteUInt(1, 1)
			net.SendToServer()
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
									m:AddOption(v:Name(), function()
										val_enter:SetText(v:Name())
									end)
								end
								m:SetMaxHeight(500)
								m:Open()
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
		if table.IsEmpty(entries) then
			argsInf:SetText("")
		else
			argsInf:SetText("Ввод аргументов:")
		end
		argsInf:SetPos(162, 25 + ps:GetTall())
	end
	for i = 1, 2 do
		local dc = vgui.Create('DLabel', ps)
		dc:SetSize(320, 50)
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
				dc:SetPos(5 + 1, -20 + b * .5 + 1)
			else
				dc:SetPos(5, -20 + b * .5)
			end
			ps:SetSize(330, 10 + b)
		end
	end
	local runCommand = vgui.Create('DTextEntry', nGUI)
	runCommand:Dock(BOTTOM)
	runCommand.Think = function()
		if table.IsEmpty(entries) then
			runCommand:SetText("n " .. cm)
			return
		end
		local msg = "n " .. cm
		for k, v in ipairs(entries) do
			msg = msg .. " \"" .. v:GetText() .. "\""
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
			but:SetDisabled(true)
		end
		but:SetPos(315, ps:GetTall() + 45)
	end
	local logs = vgui.Create("RichText", nGUI)
	logs:SetSize(200, 200)
	logs:SetPos(315, ps:GetTall() + 75)
	logs.Think = function()
		logs:SetSize(200, 200 - ps:GetTall())
		logs:SetPos(315, ps:GetTall() + 75)
	end
	logs.PerformLayout = function()
		logs:SetFontInternal("logs")
	end
	but.DoClick = function()
		local a = SysTime()
		local gTN = tonumber(gT)
		local ch = gTN ~= nil and gTN or 1
		if ply:Team() > ch then
			logs:InsertColorChange(215, 0, 0, 255)
			logs:AppendText("Нет доступа!\n")
			return
		end
		local msg = runCommand:GetText()
		msg = msg:gsub("\n", ""):gsub(";", ":"):gsub("\"", "\"")
		LocalPlayer():ConCommand(msg)
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
		if b:find(LocalPlayer():Name()) then
			b = b .. "; " .. math.Round((SysTime() - a or SysTime()), 5)
		end
		logs:InsertColorChange(200, 200, 200, 255)
		logs:AppendText("[" .. os.date("%H:%M:%S") .. "] " .. b .. "\n")
	end)
	nAdmin.FullCMDS = true
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