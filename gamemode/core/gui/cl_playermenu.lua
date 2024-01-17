local PANEL = {}

function PANEL:Init()
	self:SetSize(800, 500)

	self:SetToggleKey("gm_showspare1")
	self:SetAllowEscape(true)

	self.Default = 2

	self:MakePopup()
	self:Center()
end

vgui.Register("afterglow_playermenu", PANEL, "afterglow_basemenu")

Interface.Register("PlayerMenu", function()
	local instance = vgui.Create("afterglow_playermenu")

	hook.Run("PopulatePlayerMenu", instance)

	instance:Populate()

	return instance
end)
