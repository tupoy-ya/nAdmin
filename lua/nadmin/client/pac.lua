net.Receive("igPac", function()
	local int = net.ReadUInt(2)
	if int == 1 then
		pac.IgnoreEntity(net.ReadEntity())
	elseif int == 2 then
		pac.UnIgnoreEntity(net.ReadEntity())
	end
end)