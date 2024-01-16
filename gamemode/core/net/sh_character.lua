if SERVER then
	netstream.Hook("SelectCharacter", function(ply, id)
		if ply:GetCharacterList()[id] then
			Character.LoadExternal(ply, id)
		end
	end)
end
