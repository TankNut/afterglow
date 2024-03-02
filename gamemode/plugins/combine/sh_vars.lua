Character.AddVar("CID", {
	Accessor = "CID",
	Default = "00000",
	Callback = function(ply, old, new)
		if SERVER and not CHARACTER_LOADING and ply:HasForcedCharacterName() then
			ply:UpdateName()
		end
	end
})

Character.AddVar("CombineFlag", {
	Accessor = "CombineFlag",
	Default = "",
	Callback = function(ply, old, new)
		if SERVER and not CHARACTER_LOADING and ply:GetCombineFlagged() then
			if new == "" then
				ply:SetCombineFlagged(false)
			else
				hook.Run("PlayerSetup", ply)
			end
		end
	end
})

Character.AddVar("CombineFlagged", {
	Accessor = "CombineFlagged",
	Default = false,
	Callback = function(ply, old, new)
		if SERVER and not CHARACTER_LOADING then
			hook.Run("PlayerSetup", ply)
			hook.Run(new and "OnCombineFlag" or "OnCombineUnflag", ply)
		end
	end
})

Character.AddVar("CombineSquad", {
	Accessor = "CombineSquad",
	Default = "UNASSIGNED",
	Callback = function(ply, old, new)
		if SERVER and not CHARACTER_LOADING and ply:HasForcedCharacterName() then
			ply:UpdateName()
		end
	end
})

Character.AddVar("CombineSquadID", {
	Accessor = "CombineSquadID",
	Default = "00",
	Callback = function(ply, old, new)
		if SERVER and not CHARACTER_LOADING and ply:HasForcedCharacterName() then
			ply:UpdateName()
		end
	end
})
