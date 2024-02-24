function CLASS:GetItems(class, allowChildren)
	if not class then
		return table.Collapse(self.Items)
	end

	local tab = {}

	for _, item in pairs(self.Items) do
		if (allowChildren and item:IsBasedOn(class)) or item:GetClass() == class then
			table.insert(tab, item)
		end
	end

	return tab
end

function CLASS:GetFirstItem(class, allowChildren)
	for _, item in pairs(self.Items) do
		if (allowChildren and item:IsBasedOn(class)) or item:GetClass() == class then
			return item
		end
	end
end

function CLASS:GetAmount(class)
	local count = 0

	for _, item in pairs(self.Items) do
		if item:GetClass() == class then
			count = count + item:GetAmount()
		end
	end

	return count
end

function CLASS:HasItem(class, amount)
	amount = tonumber(amount) or 1

	return self:GetAmount(class) >= amount
end
