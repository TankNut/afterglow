function GM:GetCharacterFlagAttribute(flag, ply, name)
	if flag.AttributeBlacklist[name] then
		error("Attempt to FLAG:GetAttribute blacklisted key " .. name)
	end

	local func = flag["Get" .. name]

	return func and func(flag, ply) or flag[name]
end


if SERVER then
	function GM:PreCreateCharacter(ply, fields)
	end

	function GM:PostLoadCharacter(ply, id)
		ply:Spawn()
	end

	function GM:UnloadCharacter(ply, id, loadingNew)
	end

	-- Database fields to use when fetching data for the character list
	-- TODO: Replace with character vars and translate internally
	function GM:GetCharacterListFields(fields)
		table.insert(fields, "name")
	end

	-- Turns the fields from GetCharacterListFields into the name used in the character list
	function GM:GetCharacterListName(fields)
		return fields.name or "*UNNAMED CHARACTER*"
	end
end
