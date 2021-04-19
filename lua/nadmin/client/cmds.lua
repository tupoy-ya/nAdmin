local slashes = {
    ["!"] = "!",
    ["."] = ".",
    ["/"] = "/",
}


local retry = ""
local retrycount = 0

function nAdmin.OnPlayerChat(pl, txt)
	if slashes[txt[1]] then
		local expl = string.Explode(" ", string.Right(txt, #txt - 1))
		local expl_f = expl[1]
		if not nAdmin.FULLCMDS then
			if not nAdmin.Commands[expl_f] then
				net.Start("nAdmin_message")
					net.WriteUInt(1, 2)
				net.SendToServer()
				--nAdmin.FULLCMDS = true
				nAdmin.Warn(_, "Пожалуйста, введите команду ещё раз.")
			end
		end
		if nAdmin.Commands[expl_f] == nil then
			return
		end
		if retry ~= expl_f then
			retry = expl_f
			retrycount = 0
		else
			retrycount = retrycount + 1
		end
		if retrycount > 8 then
			nAdmin.Warn(_, "Может ты просто забиндишь команду, а не будешь срать в чат? (n " .. expl_f .. ")")
		end
		nAdmin.NetCmdExec(pl, expl)
	end
end

hook.Add("OnPlayerChat", "nadmin_ChatCommands", function(pl, txt)
	if pl ~= LocalPlayer() then return end
	txt = txt:lower()
	timer.Simple(0, function()
		nAdmin.OnPlayerChat(pl, txt)
	end)
end)
