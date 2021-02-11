local meta = FindMetaTable("Player")
local _Global_Teams = Global_Teams

local SteamIDs = {}

if not file.Exists("nadmin", "DATA") then
	file.CreateDir("nadmin")
end

function meta:SetUserGroup(group)
	self:SetNWString("usergroup", group)
	timer.Simple(0, function()
		self:SetTeam(_Global_Teams[group].num)
	end)
	if not SteamIDs[self:SteamID()] then
		for k, v in next, SteamIDs do
			if k == self:SteamID() then
				SteamIDs[k].group = group
				file.Write("nadmin/users.txt", util.TableToJSON(SteamIDs))
				break
			end
		end
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