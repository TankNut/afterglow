function CLASS:FireEvent(event, ...)
	local current = self

	while current do
		if not current.__Item and not current.__Inventory then
			return
		end

		local ret = {current:HandleEvent(event, ...)}

		if table.Count(ret) > 0 then
			return unpack(ret)
		else
			current = current:GetParent()
		end
	end
end

function CLASS:HandleEvent(event, ...)
	if CLIENT then
		for _, v in pairs(self.Panels) do
			if IsValid(v) then
				v:HandleEvent(event, ...)
			end
		end
	end
end
