Animtable = Animtable or {}

Animtable.Tables = Animtable.Tables or {}
Animtable.Models = Animtable.Models or {}
Animtable.Offsets = Animtable.Offsets or {}

function Animtable.Define(name, normal, combat)
	local tab = Animtable.Tables[name]

	if not tab then
		tab = {}
		Animtable.Tables[name] = tab
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

function Animtable.Add(name, models, offset)
	if not istable(models) then
		models = {models}
	end

	for _, model in pairs(models) do
		Animtable.Models[model:lower()] = Animtable.Tables[name]
	end

	if offset then
		Animtable.AddOffset(models, offset)
	end
end

function Animtable.AddOffset(models, offset)
	if not istable(models) then
		models = {models}
	end

	for _, model in pairs(models) do
		Animtable.Offsets[model:lower()] = offset
	end
end

function Animtable.Get(model)
	return Animtable.Models[model:lower()]
end

function Animtable.GetOffset(model)
	return Animtable.Offsets[model:lower()] or Vector()
end
