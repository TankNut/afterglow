local PANEL = {}
DEFINE_BASECLASS("EditablePanel")

AccessorFunc(PANEL, "bAllowEscape", "AllowEscape")
AccessorFunc(PANEL, "sToggleKey", "ToggleKey")
AccessorFunc(PANEL, "bDrawTopbar", "DrawTopbar")
AccessorFunc(PANEL, "bDraggable", "Draggable")

function PANEL:Init()
	self:SetSkin("Afterglow")

	self.bDrawTopbar = false

	self:DockPadding(1, 1, 1, 1)
	self.Armed = false
end

function PANEL:SetDrawTopBar(bool)
	if bool == self.bDrawTopbar then
		return
	end

	local padding = self:GetDockPadding()

	if bool then
		self:SetTall(self:GetTall() + 24)
		self:DockPadding(padding, padding + 24, padding, padding)

		if self.bAllowEscape then
			self.ButtonClose = self:Add("DButton")
			self.ButtonClose:SetSize(24, 24)
			self.ButtonClose:SetFont("marlett")
			self.ButtonClose:SetText("r")
			self.ButtonClose:PerformLayout()
			self.ButtonClose.Paint = function() end
			self.ButtonClose.DoClick = function(pnl)
				pnl:GetParent():Remove()
			end
		end

		self.Title = self:Add("DLabel")
	else
		self:SetTall(self:GetTall() - 24)
		self:DockPadding(padding, padding, padding, padding)

		if IsValid(self.ButtonClose) then
			self.ButtonClose:Remove()
		end

		if IsValid(self.Title) then
			self.Title:Remove()
		end
	end

	self.bDrawTopbar = bool

	self:PerformLayout()
end

function PANEL:Think()
	if self.bAllowEscape and gui.IsGameUIVisible() and (not IsValid(vgui.GetKeyboardFocus()) or vgui.FocusedHasParent(self)) then
		self:Remove()
		gui.HideGameUI()
	end

	if self.Dragging then
		local mousex = math.Clamp(gui.MouseX(), 1, ScrW() - 1)
		local mousey = math.Clamp(gui.MouseY(), 1, ScrH() - 1)

		local x = math.Clamp(mousex - self.Dragging[1], 0, ScrW() - self:GetWide())
		local y = math.Clamp(mousey - self.Dragging[2], 0, ScrH() - self:GetTall())

		self:SetPos(x, y)
	end
end

function PANEL:SetTitle(title)
	if IsValid(self.Title) then
		self.Title:SetText(title)
	end
end

function PANEL:SetSize(w, h)
	if self.bDrawTopbar then
		h = h + 24
	end

	BaseClass.SetSize(self, w, h)
end

function PANEL:OnKeyCodePressed(key)
	if self.sToggleKey and input.LookupKeyBinding(key) == self.sToggleKey then
		self:Remove()
	end
end

function PANEL:OnMousePressed()
	local x, y = self:ScreenToLocal(gui.MousePos())

	if self.bDraggable and math.InRange(x, 0, self:GetWide()) and math.InRange(y, 0, 24) then
		self.Dragging = {x, y}
		self:MouseCapture(true)
	end
end

function PANEL:OnMouseReleased()
	self.Dragging = nil
	self:MouseCapture(false)
end

function PANEL:PerformLayout()
	if IsValid(self.ButtonClose) then
		self.ButtonClose:SetPos(self:GetWide() - 24, 0)
	end

	if IsValid(self.Title) then
		self.Title:SetPos(6, 0)
		self.Title:SetSize(self:GetWide() - 24, 25)
	end
end

function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "Frame", self, w, h)
end

vgui.Register("afterglow_basepanel", PANEL, "EditablePanel")
