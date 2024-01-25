local meta = FindMetaTable("Player")

function meta:GetEquipment(slot)
	if slot then
		for _, item in pairs(self:GetInventory().Items) do
			if item:GetProperty("Equipped") == slot then
				return item
			end
		end
	else
		local equipment = {}

		for _, item in pairs(self:GetInventory().Items) do
			local usedSlot = item:GetProperty("Equipped")

			if usedSlot then
				equipment[usedSlot] = item
			end
		end

		return equipment
	end
end
