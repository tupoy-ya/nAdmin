hook.Add("PlayerSay", "nadmin_ChatCommands", function(pl, txt)
	if nAdmin.Slashes[txt[1]] then
		local expl = string.Explode(" ", string.Right(txt, #txt - 1))
        local expl_f = expl[1]
        timer.Simple(0, function()
            if nAdmin.Commands[expl_f] ~= nil then
                if pl.retry ~= expl_f then
                    pl.retry = expl_f
                    pl.retrycount = 0
                else
                    pl.retrycount = (pl.retrycount or 0) + 1
                end
                if (pl.retrycount or 0) > 8 then
                    nAdmin.Warn(pl, "Может ты просто забиндишь команду, а не будешь срать в чат? (n " .. expl_f .. ")")
                end
                nAdmin.CommandExec(pl, _, expl)
            end
        end)
        if nAdmin.CmdIsHidden(expl_f) then
            return ""
        end
	end
end)
