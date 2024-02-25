function ITEM:FireEvent(event, ...)
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

function ITEM:HandleEvent(event, ...)
	-- Don't want these to propagate
	if event == "ItemAdded" or event == "ItemRemoved" then
		return true
	end
end
