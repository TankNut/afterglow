Appearance = Appearance or {}

Appearance.Default = {
	Model = Model("models/player/skeleton.mdl"),
	Hands = {}
}

Appearance.UpdateList = Appearance.UpdateList or {}

local meta = FindMetaTable("Entity")

function Appearance.Apply(ent, data)
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

function Appearance.Copy(from, to)
	if CLIENT then
		Appearance.Apply(to, from:GetAppearance())
	else
		to:SetAppearance(from:GetAppearance())
	end
end

if SERVER then
	function Appearance.Update(ply)
		local data = table.Copy(Appearance.Default)

		if ply:HasCharacter() then
			hook.Run("GetCharacterAppearance", ply, data)
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

	function Appearance.QueueUpdate(ply)
		Appearance.UpdateList[ply] = true
	end

	hook.Add("Think", "Appearance", function()
		for ply in pairs(Appearance.UpdateList) do
			Appearance.Update(ply)
		end

		table.Empty(Appearance.UpdateList)
	end)
end

Netvar.AddEntityHook("Appearance", "Appearance", function(ent, _, appearance)
	Appearance.Apply(ent, appearance)

	hook.Run("PostSetAppearance", ent)
end)

-- Not a PlayerVar because we apply to both entities and players
function meta:GetAppearance()
	return self:GetNetvar("Appearance", {})
end

if SERVER then
	function meta:SetAppearance(data)
		self:SetNetvar("Appearance", data)
	end

	function meta:UpdateAppearance()
		Appearance.QueueUpdate(self)
	end
end
