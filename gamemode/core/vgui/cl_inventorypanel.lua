local PANEL = {}

function PANEL:Init()
	self:SetPaintBackground(false)

	self.SearchEntry = self:Add("DTextEntry")
	self.SearchEntry:Dock(TOP)
	self.SearchEntry:DockMargin(0, 0, 0, 5)
	self.SearchEntry:SetTall(22)
	self.SearchEntry:SetPlaceholderText("Search...")
	self.SearchEntry:SetUpdateOnType(true)
	self.SearchEntry:SetZPos(0)

	self.SearchEntry.OnValueChange = function(_, val)
		self:OnSearchChanged(val)
	end

	self.SortBar = self:Add("DPanel")
	self.SortBar:Dock(TOP)
	self.SortBar:SetTall(22)
	self.SortBar:SetPaintBackground(false)
	self.SortBar:SetZPos(1)

	self:AddSortButtons()

	self.Scroll = self:Add("DScrollPanel")
	self.Scroll:Dock(FILL)

	self.ItemList = self.Scroll:Add("RPInventoryList")
	self.ItemList:Dock(FILL)
	self.ItemList:SetInventoryPanel(self)

	self.Weight = self:Add("RPProgressBar")
	self.Weight:DockMargin(0, 5, 0, 0)
	self.Weight:Dock(BOTTOM)
	self.Weight:SetTall(20)
end

function PANEL:AddSortButtons()
	self.SortName = self.SortBar:Add("DButton")
	self.SortName:Dock(LEFT)

	self.SortName.DoClick = function()
		self:SetSorting("Name")
	end

	self.SortCategory = self.SortBar:Add("DButton")
	self.SortCategory:Dock(FILL)

	self.SortCategory.DoClick = function()
		self:SetSorting("Category")
	end

	self.SortWeight = self.SortBar:Add("DButton")
	self.SortWeight:Dock(RIGHT)

	self.SortWeight.DoClick = function()
		self:SetSorting("Weight", true)
	end

	self:UpdateSortButtons()
end

function PANEL:UpdateSortButtons()
	self.SortName:SetText(self.ActiveSort == "Name" and "[Type]" or "Type")
	self.SortCategory:SetText(self.ActiveSort == "Category" and "[Category]" or "Category")
	self.SortWeight:SetText(self.ActiveSort == "Weight" and "[Weight]" or "Weight")
end

function PANEL:Populate()
	for _, v in pairs(self:GetInventory().Items) do
		self:AddItem(v)
	end

	self:UpdateWeight()
end

function PANEL:PerformLayout()
	self.SortName:SetWide(self.Scroll:GetWide() * 0.6 - 15)
	self.SortWeight:SetWide(self.Scroll:GetWide() * 0.2 - 15)
end

function PANEL:GetInventory()
	return Inventory.Get(self.InventoryID)
end

function PANEL:OnRemove()
	self:GetInventory():RemovePanel(self)
end

function PANEL:Setup(inventory)
	inventory:AddPanel(self)

	self.InventoryID = inventory.ID
	self:Populate()
	self:Sort()
end

function PANEL:AddItem(item)
	local panel = self.ItemList:Add("RPItemPanel")

	panel:Setup(item)
end

function PANEL:RemoveItem(item)
	for _, v in pairs(self.ItemList:GetChildren()) do
		if v.Item == item then
			v:Remove()
		end
	end
end

function PANEL:HandleEvent(event, ...)
	if event == "ItemAdded" then
		self:AddItem(...)
		self:UpdateWeight()
	elseif event == "ItemRemoved" then
		self:RemoveItem(...)
		self:UpdateWeight()
	elseif event == "WeightChanged" then
		self:UpdateWeight()
	end

	self:Sort()
end

function PANEL:UpdateWeight()
	local weight = self:GetInventory():GetWeight()
	local maxWeight = self:GetInventory():GetMaxWeight()

	if maxWeight == 0 then
		self.Weight:SetProgress(weight / 100)
		self.Weight:SetText(string.format("%.1f kg", weight))
	else
		self.Weight:SetProgress(weight / maxWeight)
		self.Weight:SetText(string.format("%.1f / %.1f kg", weight, maxWeight))
	end
end

-- Filtering

function PANEL:OnSearchChanged(val)
	val = val:lower():Trim()

	if val == self.FilterValue then
		return
	end

	self.FilterValue = val:Trim():lower()
	self:Filter()
end

function PANEL:Filter()
	local terms = string.Explode(" ", self.FilterValue)

	for _, v in pairs(self.ItemList:GetChildren()) do
		local match = false

		local name = v.Item:GetName():lower()
		local tags = table.Map(v.Item:GetTags(), function(val, key) return val:lower() end)

		for _, term in pairs(terms) do
			if name:find(term) then
				match = true
				break
			end

			for _, tag in ipairs(tags) do
				if tag:find(term) then
					match = true
					break
				end
			end
		end

		v:SetVisible(match)
	end

	self.ItemList:InvalidateLayout(true)
	self.Scroll:InvalidateLayout(true)
	self.Scroll:GetCanvas():SizeToChildren(false, true)
end

-- Sorting

local function sortEquipped(a, b)
	a = a.Item:GetProperty("Equipped") and 1 or 0
	b = b.Item:GetProperty("Equipped") and 1 or 0

	if a == b then
		return
	end

	return a < b
end

local function sortByMember(a, b, member, flip)
	a = a.Item["Get" .. member](a.Item)
	b = b.Item["Get" .. member](b.Item)

	if a == b then
		return
	end

	if flip then
		return a > b
	else
		return a < b
	end
end

function PANEL:SetSorting(name, flip)
	if self.ActiveSort == name then
		self.FlippedSort = not self.FlippedSort
	else
		self.FlippedSort = flip or false
	end

	self.ActiveSort = name
	self:UpdateSortButtons()
	self:Sort()
end

function PANEL:Sort()
	local panels = self.ItemList:GetChildren()

	table.sort(panels, function(a, b)
		local sort = sortEquipped(a, b)

		if sort != nil then
			return sort
		end

		if self.ActiveSort then
			sort = sortByMember(a, b, self.ActiveSort, self.FlippedSort)

			if sort != nil then
				return sort
			end
		end

		return a.Item.ID < b.Item.ID
	end)

	for k, v in pairs(panels) do
		v:SetZPos(k - 1)
	end
end

RPInventoryPanel = derma.DefineControl("RPInventoryPanel", "A panel that contains the standard inventory display", PANEL, "DPanel")
