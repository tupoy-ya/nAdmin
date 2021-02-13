require'mysqloo'

if not mysqloo then
	nAdmin.Print("gmsv_mysqloo не найден!!!")
	return
end

if not file.Exists("nadmin/dbcfg.txt", "DATA") then
	file.Write("nadmin/dbcfg.txt", util.TableToJSON({["url"] = "", ["login"] = "", ["pass"] = "", ["dbName"] = "", ["port"] = 3306}))
end
local mysqlConnect = util.JSONToTable(file.Read("nAdmin/dbcfg.txt", "DATA"))
nAdminDB, nAdminDBFail = mysqloo.connect(mysqlConnect["url"], mysqlConnect["login"], mysqlConnect["pass"], mysqlConnect["dbName"], math.Round(mysqlConnect["port"]))
