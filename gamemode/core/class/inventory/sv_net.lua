function CLASS:GetReceivers(lookup)
	local receivers = self.Receivers

	if self.StoreType == ITEM_PLAYER then
		receivers[self:GetParent()] = true
	elseif self.StoreType == ITEM_ITEM then
		table.Merge(receivers, self:GetParent():GetInventory():GetReceivers(true))
	end

	return lookup and receivers or table.GetKeys(receivers)
end

-- Get the receivers we don't have compared to other
function CLASS:DiffReceivers(other)
	local receivers = self:GetReceivers(true)
	local tab = {}

	for _, v in pairs(other:GetReceivers()) do
		if not receivers[v] then
			tab[v] = true
		end
	end

	return table.GetKeys(tab)
end

function CLASS:SendFullUpdate(targets)
	local payload = {}

	for _, v in pairs(self.Items) do
		table.insert(payload, {
			Name = v.ClassName,
			ID = v.ID,
			Data = v.CustomData
		})
	end

	Netstream.Send("InventoryCreated", targets, {
		ID = self.ID,
		StoreType = self.StoreType,
		StoreID = self.StoreID,
		Items = payload
	})
end

function CLASS:AddReceiver(ply)
	if table.HasValue(self:GetReceivers(), ply) then
		return
	end

	self.Receivers[ply] = true

	self:SendFullUpdate(ply)
end

function CLASS:RemoveReceiver(ply)
	if not self.Receivers[ply] then
		return
	end

	self.Receivers[ply] = nil

	Netstream.Send("InventoryRemoved", ply, self.ID)
end
