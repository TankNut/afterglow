module("Appearance", package.seeall)

local meta = FindMetaTable("Player")

Default = {
	Model = Model("models/player/skeleton.mdl"),
	Hands = {
		Model = Model("models/weapons/c_arms_hev.mdl")
	}
}

function Apply(ent, data)
	ent:SetModel(data.Model)

	if ispanel(ent) then
		ent = ent.Entity
	end

	ent:SetSkin(data.Skin or 0)

	local bodygroups = data.Bodygroups or {}

	for _, v in pairs(ent:GetBodyGroups()) do
		if v.num <= 1 then
			continue
		end

		ent:SetBodygroup(v.id, bodygroups[v.name] or 0)
	end
end

function meta:GetAppearance()
	return self:GetNetVar("Appearance", table.Copy(Default))
end

if SERVER then
	function Update(ply)
		local data = table.Copy(Default)

		if ply:HasCharacter() then
			hook.Run("GetAppearance", ply, data)
		end

		ply.HandsAppearance = data.Hands
		data.Hands = nil

		ply:SetNetVar("Appearance", data)
		ply:SetupHands()

		hook.Run("PostSetAppearance", ply, data)
	end

	function meta:UpdateAppearance()
		Update(self)
	end
end
