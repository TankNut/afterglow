local PANEL = {}

function PANEL:Init()
	self:SetSize(620, ScreenScale(200))
	self:DockPadding(0, 50, 0, 0)

	self:MakePopup()
	self:Center()

	self:SetKeyboardInputEnabled(false)

	self.Players = self:Add("DScrollPanel")
	self.Players:Dock(FILL)
end

function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "Scoreboard", self, w, h)
end

derma.DefineControl("RPScoreboard", "Scoreboard gui", PANEL, "RPBasePanel")

Interface.Register("Scoreboard", function()
	return vgui.Create("RPScoreboard")
end)
