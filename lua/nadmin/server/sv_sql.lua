if game.SinglePlayer() then
	nAdmin.Print("Вы находитесь в одиночной игре. Некоторые модули не будут работать!")
	nAdminDB, nAdminDBFail = getmetatable("---"), getmetatable("---")
	return
end

local a, b = pcall(function() require'mysqloo' end)
if a then
	require'mysqloo'
else
	nAdmin.Print("gmsv_mysqloo не найден!!! Без него не будет работать модуль playtime!!!")
	return
end

if not file.Exists("nadmin/dbcfg.txt", "DATA") then
	file.Write("nadmin/dbcfg.txt", util.TableToJSON({["url"] = "", ["login"] = "", ["pass"] = "", ["dbName"] = "", ["port"] = 3306}))
end
local mysqlConnect = util.JSONToTable(file.Read("nAdmin/dbcfg.txt", "DATA"))
nAdminDB, nAdminDBFail = mysqloo.connect(mysqlConnect["url"], mysqlConnect["login"], mysqlConnect["pass"], mysqlConnect["dbName"], math.Round(mysqlConnect["port"]))

if nAdminDBFail then
	nAdmin.Print("Не удалось подключиться к базе данных: ", nAdminDBFail)
	return
end

function nAdminDB:onConnected()
	nAdmin.Print("База данных успешно подключена.")
end

function nAdminDB:onConnectionFailed( err )
	nAdmin.Print("Ошибка подключения к базе данных!")
	nAdmin.Print("Ошибка:", err)
end
nAdminDB:connect()