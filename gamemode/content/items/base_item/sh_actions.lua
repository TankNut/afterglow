function ITEM:CanInteract(ply)
	if self.StoreType == ITEM_PLAYER then
		return self:GetInventory() == ply:GetInventory()
	end
end

function ITEM:CanDrop(ply)
	return true
end

function ITEM:CanDestroy(ply)
	return true
end

if CLIENT then
	function ITEM:OpenActionMenu(parent, exclude)
		local panel = DermaMenu(false, parent)

		for _, action in pairs(self:GetActions(LocalPlayer())) do
			if exclude[action.Name] then
				continue
			end

			if action.Choices then
				local sub = panel:AddSubMenu(action.Name)

				for _, choice in pairs(action.Choices) do
					sub:AddOption(choice[1], function()
						self:FireAction(LocalPlayer(), action.Name, choice[2])
					end)
				end
			else
				panel:AddOption(action.Name, function()
					self:FireAction(LocalPlayer(), action.Name)
				end)
			end
		end

		panel:Open()

		return panel
	end
end

function ITEM:FireAction(ply, name, val)
	for _, action in pairs(self:GetActions(ply)) do
		if action.Name != name then
			continue
		end

		if CLIENT then
			if action.Callback then
				coroutine.wrap(function()
					if action.Client then
						val = action.Client(self, ply)
					end

					Netstream.Send("ItemAction", {
						ID = self.ID,
						Name = action.Name,
						Value = val
					})
				end)()
			elseif action.Client then
				coroutine.wrap(action.Client)(self, ply)
			end
		else
			coroutine.wrap(action.Callback)(self, ply, val)
		end

		break
	end
end

if SERVER then
	Netstream.Hook("ItemAction", function(ply, payload)
		local item = Item.Get(payload.ID)

		if not item or not item:CanInteract(ply) then
			return
		end

		item:FireAction(ply, payload.Name, payload.Value)
	end)
end

function ITEM:GetActions(ply)
	local tab = {}

	table.insert(tab, {
		Name = "Examine",
		Client = function()
			Interface.Open("ItemPopup", self)
		end
	})

	if self:IsEquipped() then
		if self:CanUnequip() then
			table.insert(tab, {
				Name = "Unequip",
				Callback = CLIENT and true or self.TryUnequip
			})
		end
	elseif self:IsEquipment() and self:CanEquip() then
		local options = {}
		local equipment = ply:GetEquipment()

		for _, v in ipairs(self:GetProperty("Equipment")) do
			if equipment[v] and equipment[v] == self then
				continue
			end

			table.insert(options, {equipment[v] and string.format("As %s (Replace %s)", v, equipment[v]:GetName()) or "As " .. v, v})
		end

		if #options > 0 then
			table.insert(tab, {
				Name = "Equip...",
				Choices = options,
				Callback = CLIENT and true or self.TryEquip
			})
		end
	end

	if self:CanDrop(ply) then
		table.insert(tab, {
			Name = "Drop",
			Callback = function()
				if not self:IsEquipped() or ply:WaitFor(2, "Unequipping...", {self}) then
					self:SetWorldPos(hook.Run("GetItemDropLocation", ply))
				end
			end
		})
	end

	if self:CanDestroy(ply) then
		table.insert(tab, {
			Name = "Destroy",
			Callback = function()
				self:Destroy()
			end
		})
	end

	return tab
end
