local slashes = {
    ["!"] = "!",
    ["."] = ".",
    ["/"] = "/",
}

function nAdmin.OnPlayerChat(pl, txt)
	if slashes[txt[1]] then
		local expl = string.Explode(" ", string.Right(txt, #txt - 1))
		local expl_f = expl[1]
		if nAdmin.Commands[expl_f] == nil then
			return
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
