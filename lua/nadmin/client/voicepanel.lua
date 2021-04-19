hook.Add("StartCommand", "vBox", function()
	if IsValid(g_VoicePanelList) then g_VoicePanelList:Remove() end
	surface.CreateFont("voiceBox", {font = "Roboto", size = 24, antialias = true, extended = true})

	local GM = GAMEMODE
	local PANEL = {}
	local PlayerVoicePanels = {}

	function PANEL:Init()
		self.Avatar = vgui.Create("AvatarImage", self)
		self.Avatar:Dock(LEFT )
		self.Avatar:SetSize(32, 32)

		self.Color = color_transparent
		self.Lerp = 0

		self:SetSize(250, 40)
		self:DockPadding(4, 4, 4, 4)
		self:Dock(BOTTOM)
	end

	function PANEL:Setup(ply)
		self.ply = ply
		self:DockMargin(2, 2, 2, 2)
		self.Avatar:SetPlayer(ply)
		self:InvalidateLayout()
	end

	function PANEL:Paint( w, h )
		if ( !IsValid( self.ply ) ) then return end

		self.Lerp = Lerp(FrameTime() * 4, self.Lerp, self.ply:VoiceVolume() * 255)
		for i = 1, 4 do
			surface.SetDrawColor(0, self.Lerp * 2 - i * 48, 0, 200 - i * 48)
			surface.DrawRect(self.Lerp * 2 + i - 1, 0, 2, h)
		end

		surface.SetDrawColor(0, 0, 0, 240)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(0, math.Clamp(self.Lerp * 2, 0, 200), 0, 100)
		surface.DrawRect(0, 0, self.Lerp * 2, h)

		surface.SetDrawColor(0, 0, 0, 240)
		local a, b = self.Avatar:GetPos()
		surface.DrawRect(a - 1, b - 1, self.Avatar:GetWide() + 2, self.Avatar:GetTall() + 2)

		surface.SetFont'voiceBox'

		local nick = self.ply:Name()

		if utf8.len(self.ply:Name()) > 18 then
			nick = utf8.sub(nick, 1, 18) .. "..."
		end

		surface.SetTextColor(0, 0, 0)
		surface.SetTextPos(a + 36 + 1, b + 3 + 1)
		surface.DrawText(nick)

		surface.SetTextColor(255, 255, 255)
		surface.SetTextPos(a + 36, b + 3)
		surface.DrawText(nick)
	end

	function PANEL:Think()
		if ( self.fadeAnim ) then
			self.fadeAnim:Run()
		end
		local a = LocalPlayer():GetActiveWeapon()
		if IsValid(a) and a:GetClass():find'camera' then
			self:SetAlpha(0)
		elseif not self.fadeAnim then
			self:SetAlpha(255)
		end
	end

	function PANEL:FadeOut( anim, delta, data )
		if ( anim.Finished ) then
			if ( IsValid( PlayerVoicePanels[ self.ply ] ) ) then
				PlayerVoicePanels[ self.ply ]:Remove()
				PlayerVoicePanels[ self.ply ] = nil
				return
			end
		return end
		self:SetAlpha( 255 - ( 255 * delta ) )
	end

	derma.DefineControl( "VoiceNotify", "", PANEL, "DPanel" )

	function GM:PlayerStartVoice( ply )
		if ( !IsValid( g_VoicePanelList ) ) then return end
		GAMEMODE:PlayerEndVoice( ply )
		if ( IsValid( PlayerVoicePanels[ ply ] ) ) then
			if ( PlayerVoicePanels[ ply ].fadeAnim ) then
				PlayerVoicePanels[ ply ].fadeAnim:Stop()
				PlayerVoicePanels[ ply ].fadeAnim = nil
			end
			PlayerVoicePanels[ ply ]:SetAlpha( 255 )
			return
		end
		if ( !IsValid( ply ) ) then return end
		local pnl = g_VoicePanelList:Add( "VoiceNotify" )
		pnl:Setup( ply )
		PlayerVoicePanels[ ply ] = pnl
	end

	local function VoiceClean()
		for k, v in pairs( PlayerVoicePanels ) do
			if ( !IsValid( k ) ) then
				GAMEMODE:PlayerEndVoice( k )
			end
		end
	end
	timer.Create( "VoiceClean", 10, 0, VoiceClean )

	function GM:PlayerEndVoice( ply )
		if ( IsValid( PlayerVoicePanels[ ply ] ) ) then
			if ( PlayerVoicePanels[ ply ].fadeAnim ) then return end
			PlayerVoicePanels[ ply ].fadeAnim = Derma_Anim( "FadeOut", PlayerVoicePanels[ ply ], PlayerVoicePanels[ ply ].FadeOut )
			PlayerVoicePanels[ ply ].fadeAnim:Start( 1 )
		end
	end

	local function CreateVoiceVGUI()

		g_VoicePanelList = vgui.Create( "DPanel" )

		g_VoicePanelList:ParentToHUD()
		g_VoicePanelList:SetPos( ScrW() - 300, 100 )
		g_VoicePanelList:SetSize( 250, ScrH() - 200 )
		g_VoicePanelList:SetPaintBackground( false )

	end

	CreateVoiceVGUI()
	hook.Remove("StartCommand", "vBox")
end)