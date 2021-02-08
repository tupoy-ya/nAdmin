local slashes = {
    ["!"] = "!",
    ["."] = ".",
    ["/"] = "/",
}

function nAdmin.PlayerSay(pl, txt)
	if slashes[txt[1]] then
		local expl = string.Explode(" ", string.Right(txt, #txt - 1))
		local expl_f = expl[1]
		if nAdmin.Commands[expl_f] == nil then
			return
		end
		concommand.Run(pl, "n", expl)
	end
end

hook.Add("PlayerSay", "nadmin_ChatCommands", function(pl, txt)
	timer.Simple(.1, function()
		nAdmin.PlayerSay(pl, txt)
	end)
end)