local PANEL = {}
DEFINE_BASECLASS("RPBasePanel")

function PANEL:Init()
	self:SetWide(200)
	self:DockPadding(10, 10, 10, 10)

	if LocalPlayer():HasCharacter() then
		self:SetToggleKey("gm_showteam")
		self:SetAllowEscape(true)
	end

	self:SetDrawTopBar(true)
	self:SetTitle("Template Selection")

	self:Populate()

	self:MakePopup()
	self:Center()
end

function PANEL:Populate()
	self.Buttons = {}

	local ply = LocalPlayer()

	for _, data in SortedPairsByMemberValue(ply:GetAvailableTemplates(), "Name") do
		local button = self:Add("DButton")

		button:DockMargin(0, 0, 0, 5)
		button:Dock(TOP)
		button:SetText(data.Name)

		button.DoClick = function(pnl)
			Netstream.Send("LoadTemplate", data.ID)
		end

		table.insert(self.Buttons, button)
	end

	self.BackButton = self:Add("DButton")
	self.BackButton:DockMargin(0, 20, 0, 0)
	self.BackButton:Dock(TOP)
	self.BackButton:SetText("Back")

	self.BackButton.DoClick = function(pnl)
		Interface.OpenGroup("CharacterSelect", "F2")
	end

	self:InvalidateLayout(true)
	self:SizeToChildren(false, true)
end

derma.DefineControl("RPTemplateSelect", "Template character selection gui", PANEL, "RPBasePanel")

Interface.Register("TemplateSelect", function()
	return vgui.Create("RPTemplateSelect")
end)
