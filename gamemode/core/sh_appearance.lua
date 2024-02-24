module("Appearance", package.seeall)

local meta = FindMetaTable("Entity")

Default = {
	Model = Model("models/player/skeleton.mdl"),
	Hands = {}
}

UpdateList = UpdateList or {}


function Apply(ent, data)
	if ent:GetModel() != data.Model then
		ent:SetModel(data.Model)
	end

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


-- Not a PlayerVar because we apply to both entities and players
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

		if table.IsEmpty(data.Hands) then
			local name = player_manager.TranslateToPlayerModelName(data.Model)
			local hands = player_manager.TranslatePlayerHands(name)

			data.Hands.Model = hands.model
			data.Hands.Skin = hands.matchBodySkin and data.Skin or hands.skin
		end

		ply.HandsAppearance = data.Hands
		data.Hands = nil

		ply:SetAppearance(data)
		ply:SetupHands()
	end


	function QueueUpdate(ply)
		UpdateList[ply] = true
	end


	hook.Add("Think", "Appearance", function()
		for ply in pairs(UpdateList) do
			Update(ply)
		end

		table.Empty(UpdateList)
	end)
end


function GM:PostSetAppearance(ent)
	if ent:IsPlayer() then
		ent:RefreshHull()
	end
end


if SERVER then
	function GM:GetAppearance(ply, data)
		ply:GetCharacterFlagTable():GetAppearance(ply, data)
	end


	function GM:PlayerSetHandsModel(ply, ent)
		Appearance.Apply(ent, ply.HandsAppearance)
	end
end
