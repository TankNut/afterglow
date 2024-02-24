PlayerVar.Add("CharID", {
	Default = -1,
	Callback = function(ply, old, new)
		if CLIENT and ply == LocalPlayer() and new > -1 then
			Interface.CloseGroup("F2")
		end
	end
})


do -- Identity
	Character.AddVar("Name", {
		Private = true,
		Default = "*INVALID*",
		Callback = function(ply, old, new)
			hook.Run("CharacterNameChanged", ply, old, new)

			if SERVER and not CHARACTER_LOADING then
				LoadList(ply)
			end
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

			if SERVER then
				local short = string.match(new, "^[^\r\n]*")
				local config = Config.Get("ShortDescriptionLength")

				if #short > 0 and #short > config then
					short = string.sub(short, 1, config) .. "..."
				end

				ply:SetShortDescription(short)
			end
		end
	})


	PlayerVar.Add("ShortDescription", {
		Default = ""
	})
end


do -- Appearance
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


	netvar.AddEntityHook("Appearance", "Appearance", function(ent, _, appearance)
		Appearance.Apply(ent, appearance)

		hook.Run("PostSetAppearance", ent)
	end)
end


Character.AddVar("Flag", {
	Default = "default",
	Callback = function(ply, old, new)
		if SERVER and not CHARACTER_LOADING then
			hook.Run("PlayerSetup", ply)
		end
	end
})


do -- Languages
	Character.AddVar("ActiveLanguage", {
		Private = true,
		Accessor = "ActiveLanguage"
	})


	Character.AddVar("Languages", {
		Private = true,
		Accessor = "Languages",
		Default = {}
	})
end
