function GM:GetCharacterName(ply) return ply:GetCharacterFlagAttribute("CharacterName") end

-- Returns false if our name is being overwritten by *anything*
function GM:CanChangeCharacterName(ply) return not tobool(hook.Run("GetCharacterName", LocalPlayer())) end
function GM:CanChangeCharacterDescription(ply) return true end


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
