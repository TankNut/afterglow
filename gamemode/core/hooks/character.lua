function GM:GetCharacterName(ply) return ply:GetCharacterFlagAttribute("CharacterName") end

function GM:CanChangeCharacterName(ply) return not ply:HasForcedCharacterName() end
function GM:CanChangeCharacterDescription(ply) return true end

function GM:CanSpeakLanguage(ply, lang)
	return ply:GetLanguages()[lang] == true
end

function GM:CanUnderstandLanguage(ply, lang)
	return ply:GetLanguages()[lang] != nil
end

function GM:HasCharacterTemplateAccess(ply, id, template)
	return ply:IsSuperAdmin() or ply:HasTemplate(id)
end

function GM:GetCharacterFlagAttribute(flag, ply, name)
	if flag.AttributeBlacklist[name] then
		error("Attempt to FLAG:GetAttribute blacklisted key " .. name)
	end

	local func = flag["Get" .. name]

	return func and func(flag, ply) or flag[name]
end

if SERVER then
	-- Database fields to use when fetching data for the character list
	-- TODO: Replace with character vars and translate internally
	function GM:GetCharacterListFields(fields)
		table.insert(fields, "name")
	end

	-- Turns the fields from the GetCharacterListFields into the name used in the character list
	function GM:GetCharacterListName(fields)
		return fields.name or "*UNNAMED CHARACTER*"
	end
end
