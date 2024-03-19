Hull = Hull or {}
Hull.Tables = Hull.Tables or {}
Hull.Models = Hull.Models or {}

Hull.Default = {
	Hull = {Vector(-16, -16, 0), Vector(16, 16, 72)},
	DuckHull = {Vector(-16, -16, 0), Vector(16, 16, 36)},
	View = {Vector(0, 0, 64), Vector(0, 0, 28)}
}

local meta = FindMetaTable("Player")

PlayerVar.Add("Scale", {
	Accessor = "PlayerScale",
	Default = 1,
	Callback = function(ply, old, new)
		ply:UpdateHull()
	end
})

function Hull.Standard(size, height)
	return {
		Vector(-size, -size, 0),
		Vector(size, size, height)
	}
end

function Hull.Define(name, data)
	local tab = Hull.Tables[name]

	if not tab then
		tab = {}
		Hull.Tables[name] = tab
	end

	table.Merge(tab, data)
end

function Hull.Add(name, models)
	if not istable(models) then
		models = {models}
	end

	for _, v in pairs(models) do
		Hull.Models[v:lower()] = Hull.Tables[name]
	end
end

if SERVER then
	hook.Add("PostLoadCharacter", "Hull", function(ply)
		ply:SetPlayerScale(1)
	end)

	hook.Add("PostSetAppearance", "Hull", function(ent)
		if ent:IsPlayer() then
			ent:UpdateHull()
		end
	end)
end

function meta:UpdateHull()
	local data = Hull.Models[self:GetModel():lower()] or Hull.Default
	local scale = self:GetPlayerScale()

	self:SetModelScale(scale, 0.0001)

	timer.Simple(0, function()
		self:SetHull(data.Hull[1] * scale, data.Hull[2] * scale)
		self:SetHullDuck(data.DuckHull[1] * scale, data.DuckHull[2] * scale)

		self:SetViewOffset(data.View[1] * scale)
		self:SetViewOffsetDucked(data.View[2] * scale)
	end)
end
