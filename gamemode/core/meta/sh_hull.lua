local meta = FindMetaTable("Player")


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
