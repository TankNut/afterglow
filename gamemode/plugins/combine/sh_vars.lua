Character.AddVar("CID", {
	Accessor = "CID",
	Default = "00000",
	Callback = function(ply, old, new)
		if SERVER and not CHARACTER_LOADING and ply:HasForcedCharacterName() then
			ply:UpdateName()
		end
	end
})
