module("Appearance", package.seeall)

local meta = FindMetaTable("Entity")
local plyMeta = FindMetaTable("Player")

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

	ent:SetSubMaterial()

	local materials = data.Materials or {}

	for k, v in pairs(materials) do
		ent:SetSubMaterial(k - 1, v)
	end
end

function Copy(from, to)
	if CLIENT then
		Apply(to, from:GetAppearance())
	else
		to:SetAppearance(from:GetAppearance())
	end
end

function meta:GetAppearance()
	return self:GetNetVar("Appearance", {})
end

if SERVER then
	function meta:SetAppearance(data)
		self:SetNetVar("Appearance", data)
	end

	function Update(ply)
		local data = table.Copy(Default)

		if ply:HasCharacter() then
			hook.Run("GetAppearance", ply, data)
		end

		ply.HandsAppearance = data.Hands
		data.Hands = nil

		ply:SetAppearance(data)
		ply:SetupHands()

		hook.Run("PostSetAppearance", ply, data)
	end

	function plyMeta:UpdateAppearance()
		Update(self)
	end
end
