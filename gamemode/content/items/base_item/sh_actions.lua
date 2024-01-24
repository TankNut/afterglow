function ITEM:CanInteract(ply)
	if self.StoreType == ITEM_PLAYER then
		return self:GetInventory() == ply:GetInventory()
	end
end

function ITEM:CanDrop(ply)
	return true
end

function ITEM:GetActions(ply)
	local tab = {}

	table.insert(tab, {
		Name = "Examine",
		Client = function()
			Interface.Open("ItemPopup", self)
		end
	})

	if self:CanDrop(ply) then
		table.insert(tab, {
			Name = "Drop",
			Callback = function()
				self:SetWorldPos(hook.Run("GetItemDropLocation", ply))
			end
		})
	end

	return tab
end
