local PANEL = {}

function PANEL:Init()
	self:SetSize(800, 500)

	self:SetToggleKey("gm_showspare1")
	self:SetAllowEscape(true)

	self.Default = 2

	self:MakePopup()
	self:Center()
end

derma.DefineControl("RPPlayerMenu", "Main F3 menu", PANEL, "RPBaseMenu")

Interface.Register("PlayerMenu", function()
	local instance = vgui.Create("RPPlayerMenu")

	hook.Run("PopulatePlayerMenu", instance)

	instance:Populate()

	return instance
end)
