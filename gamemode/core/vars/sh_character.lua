PlayerVar.Add("CharID", {
	Default = CHARACTER_NONE,
	Callback = function(ply, old, new)
		if CLIENT and ply == LocalPlayer() and new != CHARACTER_NONE then
			Interface.CloseGroup("F2")
		end
	end
})

-- Identity

Character.AddVar("Name", {
	Private = true,
	Default = "*INVALID*",
	Callback = function(ply, old, new)
		hook.Run("CharacterNameChanged", ply, old, new)
	end
})

PlayerVar.Add("VisibleName", {
	Default = ""
})

Character.AddVar("Description", {
	Private = true,
	Default = "",
	Callback = function(ply, old, new)
		hook.Run("CharacterDescriptionChanged", ply, old, new)
	end
})

PlayerVar.Add("ShortDescription", {
	Default = ""
})

-- Appearance

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

Character.AddVar("Flag", {
	Default = "default",
	Callback = function(ply, old, new)
		if SERVER and not CHARACTER_LOADING then
			hook.Run("PlayerSetup", ply)
		end
	end
})

-- Languages

Character.AddVar("ActiveLanguage", {
	Private = true,
	Accessor = "ActiveLanguage"
})

Character.AddVar("Languages", {
	Private = true,
	Accessor = "Languages",
	Default = {}
})
