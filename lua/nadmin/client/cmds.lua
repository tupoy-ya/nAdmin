local retry = ""
local retrycount = 0

function nAdmin.OnPlayerChat(pl, txt)
	if nAdmin.Slashes and nAdmin.Slashes[txt[1]] then
		local expl = string.Explode(" ", string.Right(txt, #txt - 1))
		local expl_f = expl[1]
		if nAdmin.Commands[expl_f] == nil then
			return
		end
		for index, str in pairs(expl) do
			if str:Trim() == "" then
				table.remove(expl, index)
			end
		end
		if nAdmin.Commands[expl_f].CL then
			nAdmin.NetCmdExec(pl, expl)
		end
	end
end

hook.Add("OnPlayerChat", "nAdmin_ChatCommands", function(pl, txt)
	if pl ~= LocalPlayer() then return end
	txt = txt:lower()
	timer.Simple(0, function()
		nAdmin.OnPlayerChat(pl, txt)
	end)
end)
