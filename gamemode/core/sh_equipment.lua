local meta = FindMetaTable("Player")

function meta:GetEquipment(slot)
	if slot then
		for _, item in pairs(self:GetItems()) do
			if item:GetProperty("Equipped") == slot then
				return item
			end
		end
	else
		local equipment = {}

		for _, item in pairs(self:GetItems()) do
			local usedSlot = item:GetProperty("Equipped")

			if usedSlot then
				equipment[usedSlot] = item
			end
		end

		return equipment
	end
end

function meta:EquipmentHook(name)
	for _, item in pairs(self:GetEquipment()) do
		local val

		if item["Get" .. name] then
			val = {item["Get" .. name](item)}
		else
			val = {item:GetProperty(name)}
		end

		if not table.IsEmpty(val) then
			return unpack(val)
		end
	end
end
