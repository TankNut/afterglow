local meta = FindMetaTable("Player")

function meta:GetEquipment(slot)
	if slot then
		local id = self:GetEquipmentCache()[slot]

		return id and Item.Get(id)
	else
		local equipment = {}

		for itemSlot, id in pairs(self:GetEquipmentCache()) do
			equipment[itemSlot] = Item.Get(id)
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

if CLIENT then
	hook.Add("GetHudElements", "Equipment", function(ply)
		for _, item in pairs(ply:GetEquipment()) do
			for _, id in ipairs(item:GetHudElements()) do
				Hud.Add(id)
			end
		end
	end)
else
	function meta:UpdateEquipmentCache()
		local equipment = {}

		for _, item in pairs(self:GetItems()) do
			local slot = item:IsEquipped()

			if slot then
				equipment[slot] = item.ID
			end
		end

		self:SetEquipmentCache(equipment)
	end
end
