if file.Exists("bin/gmsv_mysqloo_*.dll", "LUA") then
	pcall(require,'mysqloo')
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

function nAdminDB:onConnected()
	nAdmin.Print("База данных успешно подключена.")
end

function nAdminDB:onConnectionFailed( err )
	nAdmin.Print("Ошибка подключения к базе данных!")
	nAdmin.Print("Ошибка:", err)
end
nAdminDB:connect()