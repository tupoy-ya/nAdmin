local meta = FindMetaTable("Player")

local SteamIDs = {}

if not file.Exists("nadmin", "DATA") then
	file.CreateDir("nadmin")
end

function meta:SetUserGroup(group)
	self:SetNWString("usergroup", group)
	for k, v in next, SteamIDs do
		if k == self:SteamID() then
			SteamIDs[k].group = group
			file.Write("nadmin/users.txt", util.TableToJSON(SteamIDs))
			break
		end
	end
end

local function LoadUsers()
	local txt = file.Read("nadmin/users.txt", "DATA")
	if ( !txt ) then
		MsgN( "Failed to load nadmin/users.txt!" )
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

hook.Add("PlayerAuthed", "PlayerAuthSpawn", function(ply)
	local steamid = ply:SteamID()
	if (game.SinglePlayer() or ply:IsListenServerHost()) then
		ply:SetUserGroup("superadmin")
		ply:SetTeam(Global_Teams["superadmin"].num)
		return
	end
	if (SteamIDs[steamid] == nil) then
		ply:SetUserGroup("user")
		ply:SetTeam(Global_Teams["user"].num)
		return
	end
	ply:SetUserGroup(SteamIDs[steamid].group)
	ply:SetTeam(Global_Teams[SteamIDs[steamid].group].num)
end)