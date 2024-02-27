function GM:GetCharacterFlagAttribute(flag, ply, name)
	if flag.AttributeBlacklist[name] then
		error("Attempt to FLAG:GetAttribute blacklisted key " .. name)
	end

	local func = flag["Get" .. name]

	return func and func(flag, ply) or flag[name]
end
