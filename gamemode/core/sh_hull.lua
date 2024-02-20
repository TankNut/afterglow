module("Hull", package.seeall)

local meta = FindMetaTable("Player")

Tables = Tables or {}
Models = Models or {}

Default = {
	Hull = {Vector(-16, -16, 0), Vector(16, 16, 72)},
	DuckHull = {Vector(-16, -16, 0), Vector(16, 16, 36)},
	View = {Vector(0, 0, 64), Vector(0, 0, 28)}
}

function Define(name, data)
	local tab = Tables[name]

	if not tab then
		tab = {}
		Tables[name] = tab
	end

	table.Merge(tab, data)
end

function Add(name, models)
	if not istable(models) then
		models = {models}
	end

	for _, v in pairs(models) do
		Models[v:lower()] = Tables[name]
	end
end

Define("antlion", {
	Hull = {Vector(-18, -18, 0), Vector(18, 18, 36)},
	DuckHull = {Vector(-18, -18, 0), Vector(18, 18, 36)},
	View = {Vector(0, 0, 32), Vector(0, 0, 32)}
})

Add("antlion", {"models/antlion.mdl", "models/antlion_worker.mdl"})

PlayerVar.Register("Scale", {
	Accessor = "PlayerScale",
	Default = 1,
	Callback = function(ply, old, new)
		ply:RefreshHull()
	end
})

function meta:RefreshHull()
	local data = Models[self:GetModel():lower()] or Default
	local scale = self:GetPlayerScale()

	self:SetModelScale(scale, 0.0001)

	timer.Simple(0, function()
		self:SetHull(data.Hull[1] * scale, data.Hull[2] * scale)
		self:SetHullDuck(data.DuckHull[1] * scale, data.DuckHull[2] * scale)

		self:SetViewOffset(data.View[1] * scale)
		self:SetViewOffsetDucked(data.View[2] * scale)
	end)
end

if SERVER then
	hook.Add("PostLoadCharacter", "Hull", function(ply)
		ply:SetPlayerScale(1)
	end)
end
