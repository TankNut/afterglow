local SKIN = {}

SKIN.PrintName 		= "Afterglow"
SKIN.Author 		= "TankNut"
SKIN.DermaVersion 	= 1

SKIN.Colors = {}

SKIN.Colors.Primary = HSVToColor(0, 1, 0.8)

SKIN.Colors.Border = Color(20, 20, 20)
SKIN.Colors.TextEntry = Color(35, 35, 35)

SKIN.Colors.FillLight = Color(60, 60, 60)
SKIN.Colors.FillMedium = Color(40, 40, 40)
SKIN.Colors.FillDark = Color(30, 30, 30)

SKIN.Text = {}

SKIN.Text.Normal = Color(200, 200, 200)
SKIN.Text.Hover = Color(255, 255, 255)
SKIN.Text.Primary = SKIN.Colors.Primary
SKIN.Text.Disabled = Color(150, 150, 150)
SKIN.Text.Highlight = Color(40, 40, 40)
SKIN.Text.Bad = Color(200, 0, 0)

for k, v in pairs(SKIN.Text) do
	local COMPONENT = {
		Name = {"c" .. k:lower()}
	}

	function COMPONENT:Push() self.Context:PushColor(v) end
	function COMPONENT:Pop() self.Context:PopColor() end

	Scribe.Register(COMPONENT)
end

-- Overrides for hardcoded values

SKIN.Colours = {}

SKIN.Colours.Button = {}
SKIN.Colours.Button.Disabled = SKIN.Text.Disabled
SKIN.Colours.Button.Down = SKIN.Text.Primary
SKIN.Colours.Button.Hover = SKIN.Text.Hover
SKIN.Colours.Button.Normal = SKIN.Text.Normal

SKIN.Colours.Label = {}
SKIN.Colours.Label.Default = SKIN.Text.Normal
SKIN.Colours.Label.Bright = SKIN.Text.Normal
SKIN.Colours.Label.Dark = SKIN.Text.Normal
SKIN.Colours.Label.Highlight = SKIN.Text.Normal

SKIN.Colours.TooltipText = Color(110, 102, 60)

-- Helper functions

local function getAlpha()
	return 250
end

function SKIN:DrawButton(disabled, w, h)
	surface.SetDrawColor(disabled and self.Colors.FillDark or self.Colors.FillLight)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(self.Colors.FillMedium)
	surface.DrawOutlinedRect(0, 0, w, h)
end

function SKIN:SetButtonTextColor(panel)
	local col = self.Text.Normal

	if panel:GetDisabled() then
		col = self.Text.Disabled
	elseif panel.IsDown and panel:IsDown() then
		col = self.Text.Primary
	elseif panel:IsHovered() then
		col = self.Text.Hover
	end

	surface.SetTextColor(col)
end

-- Actual skin hooks

function SKIN:PaintPanel(panel, w, h)
	if not panel.m_bBackground then
		return
	end

	local col = panel.m_bgColor or color_white

	surface.SetDrawColor(col.r, col.g, col.b, col.a)
	surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintFrame(panel, w, h)
	surface.SetDrawColor(ColorAlpha(self.Colors.FillDark, getAlpha()))
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(self.Colors.Border)
	surface.DrawOutlinedRect(0, 0, w, h)

	if panel.bDrawTopbar then
		surface.DrawRect(0, 0, w, 25)
	end
end

function SKIN:PaintButton(panel, w, h)
	if not panel.m_bBackground then
		return
	end

	local bool = panel.GetDisabled and panel:GetDisabled() or false

	if panel.SkinVar then -- TODO: Better way of doing things like this?
		bool = panel[panel.SkinVar]
	end

	if panel.SkinInverted then
		bool = not bool
	end

	self:DrawButton(bool, w, h)
end

function SKIN:PaintTextEntry(panel, w, h)
	if panel.m_bBackground then
		surface.SetDrawColor(self.Colors.TextEntry)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(self.Colors.FillDark)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	-- Hack on a hack, but this produces the most close appearance to what it will actually look if text was actually there
	if panel.GetPlaceholderText and panel.GetPlaceholderColor and panel:GetPlaceholderText() and panel:GetPlaceholderText():Trim() != "" and panel:GetPlaceholderColor() and (not panel:GetText() or panel:GetText() == "") then
		local oldText = panel:GetText()
		local str = panel:GetPlaceholderText()

		if str:StartWith("#") then
			str = str:sub(2)
		end

		str = language.GetPhrase(str)

		panel:SetText(str)
		panel:DrawTextEntryText(self.Text.Disabled, self.Text.Disabled, self.Text.Disabled)
		panel:SetText(oldText)

		return
	end

	panel:DrawTextEntryText(self.Text.Normal, self.Text.Highlight, self.Text.Normal)
end

function SKIN:PaintVScrollBar(panel, w, h)
	surface.SetDrawColor(self.Colors.FillDark)
	surface.DrawRect(0, 0, w, h)
end

function SKIN:PaintScrollBarGrip( panel, w, h )
	self:DrawButton(panel:GetDisabled(), w, h)
end

function SKIN:PaintButtonDown(panel, w, h)
	if not panel.m_bBackground then
		return
	end

	self:DrawButton(panel:GetDisabled(), w, h)
	self:SetButtonTextColor(panel)

	surface.SetFont("marlett")

	local tw, th = surface.GetTextSize("6")

	surface.SetTextPos(math.ceil(w * 0.5 - tw * 0.5), math.ceil(h * 0.5 - th * 0.5))
	surface.DrawText("6")
end

function SKIN:PaintButtonUp(panel, w, h)
	if not panel.m_bBackground then
		return
	end

	self:DrawButton(panel:GetDisabled(), w, h)
	self:SetButtonTextColor(panel)

	surface.SetFont("marlett")

	local tw, th = surface.GetTextSize("5")

	surface.SetTextPos(math.ceil(w * 0.5 - tw * 0.5), math.ceil(h * 0.5 - th * 0.5))
	surface.DrawText("5")
end

function SKIN:PaintButtonLeft(panel, w, h)
	if not panel.m_bBackground then
		return
	end

	self:DrawButton(panel:GetDisabled(), w, h)
	self:SetButtonTextColor(panel)

	surface.SetFont("marlett")

	local tw, th = surface.GetTextSize("3")

	surface.SetTextPos(math.ceil(w * 0.5 - tw * 0.5), math.ceil(h * 0.5 - th * 0.5))
	surface.DrawText("3")
end

function SKIN:PaintButtonRight(panel, w, h)
	if not panel.m_bBackground then
		return
	end

	self:DrawButton(panel:GetDisabled(), w, h)
	self:SetButtonTextColor(panel)

	surface.SetFont("marlett")

	local tw, th = surface.GetTextSize("4")

	surface.SetTextPos(math.floor(w * 0.5 - tw * 0.5), math.ceil(h * 0.5 - th * 0.5))
	surface.DrawText("4")
end

function SKIN:PaintProgressBar(panel, w, h)
	surface.SetDrawColor(self.Colors.FillDark)
	surface.DrawRect(0, 0, w, h)

	local width = w - 2

	surface.SetDrawColor(self.Colors.Primary)
	surface.DrawRect(1, 1, width * math.Clamp(panel:GetProgress(), 0, 1), h - 2)

	draw.SimpleText(panel:GetText(), "afterglow.labelsmall", w * 0.5, h * 0.5, self.Text.Normal, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintHighlight(x, y, w, h)
	surface.SetDrawColor(ColorAlpha(self.Colors.Primary, 25))
	surface.DrawRect(x, y, w, h)

	surface.SetDrawColor(ColorAlpha(self.Colors.Primary, 100))
	surface.DrawOutlinedRect(x, y, w, h)
end

function SKIN:PaintItemHover(x, y, w, h)
	self:PaintHighlight(x, y, w, h)
end

function SKIN:PaintMenu(panel, w, h)
	surface.SetDrawColor(self.Colors.FillMedium)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(self.Colors.FillDark)
	surface.DrawOutlinedRect(0, 0, w, h, 1)
end

function SKIN:PaintMenuOption(panel, w, h)
	if panel.m_bBackground and not panel:IsEnabled() then
		surface.SetDrawColor(self.Colors.FillDark)
		surface.DrawRect(0, 0, w, h)
	end

	if panel.m_bBackground and (panel.Hovered or panel.Highlight) then
		self:PaintHighlight(1, 1, w - 2, h - 2)
	end
end

function SKIN:PaintScoreboard(panel, w, h)
	surface.SetDrawColor(ColorAlpha(self.Colors.FillDark, getAlpha()))
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(self.Colors.Border)
	surface.DrawRect(0, 0, w, 50)
	surface.DrawOutlinedRect(0, 0, w, h)

	draw.DrawText(Config.Get("ServerName"), "afterglow.labelmassive", 10, 10, self.Text.Normal)
end

function SKIN:PaintScoreboardEntry(panel, w, h)
	if panel:GetAlt() then
		surface.SetDrawColor(ColorAlpha(self.Colors.Border, 130))
		surface.DrawRect(0, 0, w, h)
	end

	if panel:GetHidden() then
		surface.SetDrawColor(ColorAlpha(self.Colors.Primary, 10))
		surface.DrawRect(0, 0, w, h)
	end

	local ply = panel:GetPlayer()

	draw.SimpleText(ply:GetVisibleName(), "afterglow.labelsmall", h + 19, math.Round(h * 0.33), self.Text.Normal, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText(ply:GetShortDescription(), "afterglow.labelsmall", h + 19, math.Round(h * 0.66), self.Text.Disabled, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

	draw.DrawText(ply:Ping(), "afterglow.labelsmall", w - 20, 5, self.Text.Normal, TEXT_ALIGN_RIGHT)

	if LocalPlayer():IsAdmin() then
		draw.DrawText(ply:Nick(), "afterglow.labelsmall", w - 20, 40, self.Text.Normal, TEXT_ALIGN_RIGHT)
	end

	surface.SetDrawColor(color_white)

	for k, v in pairs(panel.Badges) do
		surface.SetMaterial(v.Material)
		surface.DrawTexturedRect(w - 14 - (k * 18), 22, 16, 16)
	end
end

derma.DefineSkin("Afterglow", "Default Afterglow UI skin", SKIN)
