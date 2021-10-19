hook.Add("PlayerSay", "nadmin_ChatCommands", function(pl, txt)
	if nAdmin.Slashes[txt[1]] then
		local expl = string.Explode(" ", string.Right(txt, #txt - 1))
        local expl_f = expl[1]
        timer.Simple(0, function()
			for index, str in pairs(expl) do
				if str:Trim() == "" then
					table.remove(expl, index)
				end
			end
            if nAdmin.Commands[expl_f] ~= nil then
                nAdmin.CommandExec(pl, expl)
            end
        end)
        if nAdmin.CmdIsHidden(expl_f) then
            return ""
        end
	end
end)
