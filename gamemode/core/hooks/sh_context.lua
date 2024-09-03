function GM:IsValidContextEntity(ply, ent)
	return IsValid(ent) and ent:WithinRange(ply, Config.Get("ContextRange"))
end

function GM:GetContextOptions(ply)
end

function GM:GetEntityContextOptions(ply, ent, interact)
	if ent:IsPlayer() then
		Context.Add("examine", {
			Name = "Examine",
			Client = function()
				ent:Examine()
			end
		})
	end
end

local classes = table.Lookup({
	"weapon_physgun",
	"gmod_tool"
})

function GM:ShouldOpenContextMenu(ply)
	local weapon = ply:GetActiveWeapon()

	if IsValid(weapon) and classes[weapon:GetClass()] then
		return false
	end

	return true
end
