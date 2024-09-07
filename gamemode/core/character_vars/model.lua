Character.AddVar("Model", {
	ServerOnly = true,
	Default = "models/player/skeleton.mdl",
	Callback = function(ply)
		if SERVER and not CHARACTER_LOADING then
			ply:UpdateAppearance()
		end
	end
})

Character.AddVar("Skin", {
	ServerOnly = true,
	Default = 0,
	Callback = function(ply)
		if SERVER and not CHARACTER_LOADING then
			ply:UpdateAppearance()
		end
	end
})
