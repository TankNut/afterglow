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

					netstream.Send("ItemAction", {
						ID = self.ID,
						Name = action.Name,
						Value = val
					})
				end)()
			elseif action.Client then
				action.Client(self, ply)
			end
		else
			action.Callback(self, ply, val)
		end

		break
	end
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
