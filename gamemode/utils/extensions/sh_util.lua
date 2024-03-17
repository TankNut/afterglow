function util.HasPhysicsObject(mdl)
	local info = util.GetModelInfo(mdl)

	return info.KeyValues and util.KeyValuesToTable(info.KeyValues).solid
end

function util.GetModelSkins(mdl)
	local info = util.GetModelInfo(mdl)

	return info and info.SkinCount or 1
end

util.IsFemaleModel = Memoize(function(mdl)
	return tobool(hook.Run("IsFemaleModel", mdl))
end)

local femaleModels = table.Lookup({
	"models/player/alyx.mdl",
	"models/player/mossman.mdl",
	"models/player/mossman_arctic.mdl",
	"models/player/p2_chell.mdl",
	"models/player/police_fem.mdl"
})

function GM:IsFemaleModel(mdl)
	if femaleModels[mdl] then
		return true
	end

	if string.find(mdl, "female") then return true end

	return false
end
