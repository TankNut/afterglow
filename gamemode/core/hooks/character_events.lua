function GM:CharacterNameChanged(ply, old, new)
	if SERVER and not CHARACTER_LOADING then
		ply:UpdateName()
		Character.LoadList(ply)
	end
end

function GM:CharacterDescriptionChanged(ply, old, new)
	if SERVER then
		local short = string.match(new, "^[^\r\n]*")
		local config = Config.Get("ShortDescriptionLength")

		if #short > 0 and #short > config then
			short = string.sub(short, 1, config) .. "..."
		end

		ply:SetShortDescription(short)
	end
end

if SERVER then
	function GM:PreCreateCharacter(ply, fields)
	end

	function GM:PostLoadCharacter(ply, id)
		ply:Spawn()
	end
end
