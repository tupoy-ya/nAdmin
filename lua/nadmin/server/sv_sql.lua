if file.Exists("bin/gmsv_mysqloo_*.dll", "LUA") then
	require('mysqloo')
end

http_Fetch_old = http_Fetch_old or http.Fetch

function http.Fetch(url, onSuccess, onFailure, headers)
	if url == "https://raw.githubusercontent.com/FredyH/MySQLOO/master/minorversion.txt" then
		return
	end
	return http_Fetch_old(url, onSuccess, onFailure, headers)
end

if not mysqloo then
	nAdmin.Print("Модуль MYSQLoo не найден. Некоторые функции не будут работать.")
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

nAdminDB:connect()

function nAdminDB:onConnected(database)
	nAdmin.Print("База данных успешно подключена.")
end

function nAdminDB:onConnectionFailed( err )
	nAdmin.Print("Ошибка подключения к базе данных!")
	nAdmin.Print("Ошибка:", err)
end
