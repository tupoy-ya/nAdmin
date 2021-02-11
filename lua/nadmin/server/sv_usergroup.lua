local meta = FindMetaTable("Player")
local _Global_Teams = Global_Teams

local SteamIDs = {}
_G.nGSteamIDs = {}

if not file.Exists("nadmin", "DATA") then
	file.CreateDir("nadmin")
end

function meta:SetUserGroup(group)
	self:SetNWString("usergroup", group)
	timer.Simple(0, function()
		self:SetTeam(_Global_Teams[group].num)
	end)
	if group ~= "user" and SteamIDs[self:SteamID()] == nil then
		SteamIDs[self:SteamID()] = {}
		SteamIDs[self:SteamID()].group = self:GetNWString("usergroup")
		file.Write("nadmin/users.txt", util.TableToJSON(SteamIDs))
	end
end

local function LoadUsers()
	local txt = file.Read("nadmin/users.txt", "DATA")
	if ( !txt ) then
		MsgN( "nadmin/users.txt не обнаружен! Создаём..." )
		file.Write("nadmin/users.txt")
		return
	end
	if txt == "" then
		txt = "{}"
	end
	for steamid, v in next, util.JSONToTable(txt) do
		SteamIDs[steamid] = {}
		SteamIDs[steamid].group = v.group
	end
	nGSteamIDs = SteamIDs
end

LoadUsers()

hook.Add("PlayerInitialSpawn", "PlayerAuthSpawn", function(ply)
	local steamid = ply:SteamID()
	if (game.SinglePlayer() or ply:IsListenServerHost()) then
		ply:SetUserGroup("superadmin")
		return
	end
	if (SteamIDs[steamid] == nil) then
		ply:SetUserGroup("user")
		return
	end
	ply:SetUserGroup(SteamIDs[steamid].group)
end)