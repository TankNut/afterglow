Character.AddVar("CombineName", {
	Accessor = "CombineName",
	Private = true,
	Callback = function(ply, old, new)
		if SERVER and not CHARACTER_LOADING then
			ply:UpdateName()
		end
	end
})

if SERVER then
	hook.Add("GetCharacterName", "Plugin.Combine", function(ply)
		if ply:GetCombineFlagged() then
			return ply:GetCombineName()
		end
	end)

	hook.Add("SetCharacterName", "Plugin.Combine", function(ply, new)
		if ply:GetCombineFlagged() then
			ply:SetCombineName(new)

			return true
		end
	end)
end

Character.AddVar("CombineDescription", {
	Accessor = "CombineDescription",
	Private = true,
	Callback = function(ply, old, new)
		if SERVER and not CHARACTER_LOADING then
			ply:UpdateDescription()
		end
	end
})

hook.Add("GetCharacterDescription", "Plugin.Combine", function(ply)
	if ply:GetCombineFlagged() then
		return ply:GetCombineDescription()
	end
end)

if SERVER then
	hook.Add("SetCharacterDescription", "Plugin.Combine", function(ply, new)
		if ply:GetCombineFlagged() then
			ply:SetCombineDescription(new)

			return true
		end
	end)
end
