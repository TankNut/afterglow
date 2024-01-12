function util.HasPhysicsObject(mdl)
	local info = util.GetModelInfo(mdl)

	return info.KeyValues and util.KeyValuesToTable(info.KeyValues).solid
end
