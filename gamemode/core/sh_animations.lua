Animations = Animations or {}

Animations.Tables = Animations.Tables or {}
Animations.Models = Animations.Models or {}
Animations.Offsets = Animations.Offsets or {}

function Animations.Define(name, normal, combat)
	local tab = Animations.Tables[name]

	if not tab then
		tab = {}
		Animations.Tables[name] = tab
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

function Animations.Add(name, models, offset)
	if not istable(models) then
		models = {models}
	end

	for _, model in pairs(models) do
		Animations.Models[model:lower()] = Animations.Tables[name]
	end

	if offset then
		Animations.AddOffset(models, offset)
	end
end

function Animations.AddOffset(models, offset)
	if not istable(models) then
		models = {models}
	end

	for _, model in pairs(models) do
		Animations.Offsets[model:lower()] = offset
	end
end

function Animations.Get(model)
	return Animations.Models[model:lower()]
end

function Animations.GetOffset(model)
	return Animations.Offsets[model:lower()] or Vector()
end
