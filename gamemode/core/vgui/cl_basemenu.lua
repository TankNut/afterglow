local PANEL = {}
DEFINE_BASECLASS("afterglow_basepanel")

function PANEL:Init()
	self.Topbar = self:Add("DPanel")
	self.Topbar:DockPadding(5, 10, 5, 10)
	self.Topbar:Dock(TOP)
	self.Topbar:SetTall(50)
	self.Topbar:SetBackgroundColor(self:GetSkin().Colors.Border)

	self.MenuButtons = {}

	self.Content = self:Add("DPanel")
	self.Content:DockPadding(5, 5, 5, 5)
	self.Content:Dock(FILL)
	self.Content:SetPaintBackground(false)
end

function PANEL:Think()
	BaseClass.Think(self)

	self:MoveToBack()
end

function PANEL:Populate()
	self.Topbar:InvalidateParent(true)

	local space = self.Topbar:GetWide() - 10
	local count = table.Count(self.MenuButtons)

	space = space - (count * 10)

	local width = math.floor(space / count)

	for k, v in SortedPairs(self.MenuButtons) do
		local button = self.Topbar:Add("DButton")

		button:DockMargin(5, 0, 5, 0)
		button:Dock(LEFT)
		button:SetText(v.Name)
		button:SetWidth(width)

		if v.Func then
			button.Active = true
			button.DoClick = function()
				for _, child in pairs(self.Content:GetChildren()) do
					child:Dock(NODOCK)
				end

				self.Content:Clear()

				v.Func(self.Content)

				for _, child in pairs(self.Topbar:GetChildren()) do
					if child == button then
						child:SetDisabled(true)
					elseif child.Active then
						child:SetDisabled(false)
					end
				end
			end
		else
			button:SetDisabled(true)
		end

		v.Panel = button
	end

	if self.Default then
		self.MenuButtons[self.Default].Panel:DoClick()
	else
		for _, v in SortedPairs(self.MenuButtons) do
			v.Panel:DoClick()

			break
		end
	end
end

function PANEL:AddMenu(order, name, func, default)
	self.MenuButtons[order] = {
		Name = name,
		Func = func
	}

	if default then
		self.Default = order
	end
end

vgui.Register("afterglow_basemenu", PANEL, "afterglow_basepanel")
