PlayerVar.Add("EditMode", {
	Default = false,
	Get = function(ply, val)
		return val and ply:IsAdmin()
	end
})

hook.Add("GetContextOptions", "Edit", function(ply)
	if ply:IsAdmin() then
		Context.Add("toggle_edit", {
			Name = "Toggle Edit Mode",
			Section = 2,
			Order = 10,
			Callback = function()
				ply:SetEditMode(not ply:GetEditMode())
			end
		})
	end
end)

hook.Add("GetEntityContextOptions", "Edit", function(ply, ent, interact)
	if ply:GetEditMode() then
		hook.Run("GetEditModeOptions", ply, ent, interact)
	end
end)
