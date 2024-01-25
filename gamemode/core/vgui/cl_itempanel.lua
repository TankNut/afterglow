DEFINE_BASECLASS("DLabel")
local PANEL = {}

function PANEL:Init()
	self:SetTall(20)
	self:SetText("Inventory Item")
	self:SetMouseInputEnabled(true)

	self.ScrollPanel = self:GetParent():GetParent():GetParent() -- Ew
end

function PANEL:Setup(item)
	self.Item = item
	self.Scribe = scribe.Parse(item:GetFormattedItemName())
end

function PANEL:OnDepressed()
	self.GrabX, self.GrabY = self:ScreenToLocal(gui.MousePos())
end

function PANEL:DoDoubleClick()
	self.Item:FireAction(LocalPlayer(), "Examine")
end

function PANEL:DoRightClick()
	local panel = DermaMenu(false, self)

	for _, action in pairs(self.Item:GetActions(LocalPlayer())) do
		if action.Choices then
			local sub = panel:AddSubMenu(action.Name)

			for _, choice in pairs(action.Choices) do
				sub:AddOption(choice[1], function()
					self.Item:FireAction(LocalPlayer(), action.Name, choice[2])
				end)
			end
		else
			panel:AddOption(action.Name, function()
				self.Item:FireAction(LocalPlayer(), action.Name)
			end)
		end
	end

	panel:Open()
end

function PANEL:PaintAt(x, y, w, h)
	x = x + (self:GetWide() * 0.5) - 8 - self.GrabX
	y = y + (self:GetTall() * 0.5) - 8 - self.GrabY

	return BaseClass.PaintAt(self, x, y, w, h)
end

function PANEL:Paint(w, h)
	local color = self.VisiblePos % 2 == 0 and Color(40, 40, 40, 200) or Color(30, 30, 30, 200)

	if self.Selected and not dragndrop.IsDragging() then
		color = Color(255, 0, 0, 20)
	end

	surface.SetDrawColor(color)
	surface.DrawRect(0, 0, w, h)

	if self:IsHovered() and not dragndrop.IsDragging() then
		surface.SetDrawColor(255, 255, 255, 5)
		surface.DrawRect(0, 0, w, h)
	end

	local y = (h * 0.5) - 1
	local item = self.Item

	self.Scribe:Draw(5, y, 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	local x = self.Scribe:GetWide()
	local amount = item:GetProperty("Amount")

	if amount > 1 then
		x = x + draw.SimpleText(" x" .. amount, "afterglow.labelbig", x, y, self:GetSkin().Text.Disabled, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	if item:GetProperty("Equipped") then
		draw.SimpleText("Equipped", "afterglow.labelsmall", x + 10, y + 1, self:GetSkin().Text.Primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local offset = self.ScrollPanel.VBar.Enabled and 0 or self.ScrollPanel.VBar:GetWide() * 0.6

	draw.SimpleText(item:GetProperty("Category"), "afterglow.labelbig", w * 0.6 - offset, y, self:GetSkin().Text.Disabled, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText(item:GetWeight() .. " kg", "afterglow.labelbig", w - 5, y, self:GetSkin().Text.Disabled, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

	return true
end

vgui.Register("afterglow_itempanel", PANEL, "DLabel")
