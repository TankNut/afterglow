module("Hull", package.seeall)

Tables = Tables or {}
Models = Models or {}

Default = {
	Hull = {Vector(-16, -16, 0), Vector(16, 16, 72)},
	DuckHull = {Vector(-16, -16, 0), Vector(16, 16, 36)},
	View = {Vector(0, 0, 64), Vector(0, 0, 28)}
}

function Standard(size, height)
	return {
		Vector(-size, -size, 0),
		Vector(size, size, height)
	}
end

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

if SERVER then
	hook.Add("PostLoadCharacter", "Hull", function(ply)
		ply:SetPlayerScale(1)
	end)
end
