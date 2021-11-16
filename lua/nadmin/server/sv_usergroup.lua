local meta = FindMetaTable("Player")

local SteamIDs = {}
_G.nGSteamIDs = {}

local function LoadUsers()
	if not nAdminDB then return end
	local Q = nAdminDB:query("SELECT * FROM nAdmin_users")
	function Q:onError(err)
		nAdmin.Print("Запрос выдал ошибку: " .. err)
	end
	Q:start()
	function Q:onSuccess(data)
		if data then
			for k, v in next, data do
				SteamIDs[v.accountid] = v.usergroup
			end
			for k, ply in next, player.GetAll() do
				local steamid = ply:AccountID()
				if SteamIDs[steamid] == nil then
					ply:SetUserGroup("user")
					goto skip
				end
				if SteamIDs[steamid] ~= nil then
					ply:SetUserGroup(SteamIDs[steamid])
				end
				::skip::
			end
		end
	end
	nGSteamIDs = SteamIDs
end
LoadUsers()

if not file.Exists("nadmin", "DATA") then
	file.CreateDir("nadmin")
end

function meta:SetUserGroup(group)
	self:SetNWString("usergroup", group)
	self:SetTeam(Global_Teams[group].num)
	local stid = self:AccountID()
	if (group ~= "user" and SteamIDs[stid] == nil) or (SteamIDs[stid] and SteamIDs[stid] ~= group) then
		SteamIDs[stid] = group
		nGSteamIDs = SteamIDs
		local ACID = self:AccountID()
		local Q = nAdminDB:query("REPLACE INTO nAdmin_users (accountid, usergroup) VALUES (" .. SQLStr(ACID) .. ", " .. SQLStr(group) .. ")")
		function Q:onError(err)
			nAdmin.Print("Запрос выдал ошибку: " .. err)
		end
		Q:start()
	end
end

local steamidtoacid = function(steamid)
    local acc32 = tonumber(steamid:sub(11))
    return (acc32 * 2) + tonumber(steamid:sub(9,9))
end

function SetUserGroupID(stid, group)
	if nAdmin.ValidSteamID(stid) then
		stid = steamidtoacid(stid)
	else
		return
	end
	SteamIDs[stid] = group
	nGSteamIDs = SteamIDs
	local ye = player.GetByAccountID(stid)
	if IsValid(ye) then
		ye:SetUserGroup(group)
	end
	if not nAdminDB then
		return
	end
	local Q = nAdminDB:query("REPLACE INTO nAdmin_users (accountid, usergroup) VALUES (" .. SQLStr(stid) .. ", " .. SQLStr(group) .. ")")
	function Q:onError(err)
		nAdmin.Print("Запрос выдал ошибку: " .. err)
	end
	Q:start()
end

hook.Add("PlayerInitialSpawn", "PlayerAuthSpawn", function(ply)
	timer.Simple(0, function()
		if not IsValid(ply) then return end
		local steamid = ply:AccountID()
		if (game.SinglePlayer() or ply:IsListenServerHost()) then
			ply:SetUserGroup("superadmin")
			return
		end
		if (SteamIDs[steamid] == nil) then
			ply:SetUserGroup("user")
			return
		end
		ply:SetUserGroup(SteamIDs[steamid])
	end)
end)

SetUserGroupID("STEAM_0:0:0", "superadmin")