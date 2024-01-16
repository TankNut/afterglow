function util.HasPhysicsObject(mdl)
	local info = util.GetModelInfo(mdl)

	return info.KeyValues and util.KeyValuesToTable(info.KeyValues).solid
end

function util.GetModelSkins(mdl)
	local info = util.GetModelInfo(mdl)

	return info and info.SkinCount or 1
end
