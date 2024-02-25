module("Animtable", package.seeall)

Tables = Tables or {}
Models = Models or {}
Offsets = Offsets or {}

function Define(name, normal, combat)
	local tab = Tables[name]

	if not tab then
		tab = {}
		Tables[name] = tab
	end

	table.Merge(tab, normal)

	if combat then
		local sub = tab["__COMBAT"] or {}

		if not sub then
			sub = {}
			tab["__COMBAT"] = sub
		end

		table.Merge(sub, combat)
	end
end

function Add(name, models, offset)
	if not istable(models) then
		models = {models}
	end

	for _, model in pairs(models) do
		Models[model:lower()] = Tables[name]
	end

	if offset then
		AddOffset(models, offset)
	end
end

function AddOffset(models, offset)
	if not istable(models) then
		models = {models}
	end

	for _, model in pairs(models) do
		Offsets[model:lower()] = offset
	end
end

function Get(model)
	return Models[model:lower()]
end

function GetOffset(model)
	return Offsets[model:lower()] or Vector()
end
