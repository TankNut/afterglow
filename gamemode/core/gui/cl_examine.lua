local PANEL = {}

function PANEL:Init()
	self:SetSize(800, 500)
	self:DockPadding(10, 10, 10, 10)

	self:SetAllowEscape(true)
	self:SetDrawTopBar(true)
	self:SetDraggable(true)

	self.Preview = self:Add("RPPlayerView")
	self.Preview:DockMargin(0, 0, 20, 0)
	self.Preview:Dock(LEFT)
	self.Preview:SetWide(200)
	self.Preview:SetLookAtTarget(Vector(0, 0, 54))

	self.CharacterName = self:Add("DLabel")
	self.CharacterName:DockMargin(0, 0, 0, 5)
	self.CharacterName:Dock(TOP)
	self.CharacterName:SetTall(22)
	self.CharacterName:SetFont("afterglow.labelgiant")

	self.Scroll = self:Add("DScrollPanel")
	self.Scroll:DockMargin(0, 0, 0, 0)
	self.Scroll:Dock(FILL)
	self.Scroll:InvalidateParent(true)

	self.Description = self.Scroll:Add("ScribeLabel")
	self.Description:SetWide(self.Scroll:GetWide() - 15)

	self.Scroll:AddItem(self.Description)

	self:MakePopup()
	self:Center()
end

function PANEL:Setup(ply, description)
	local name = ply:GetVisibleName()

	if LocalPlayer():IsAdmin() then
		name = string.format("%s - %s (%s)", name, ply:Nick(), ply:SteamID())
	end

	self:SetTitle(name)

	self.Preview:SetPlayer(ply)
	self.CharacterName:SetText(ply:GetVisibleName())

	self.Description:SetText(string.format("<iset=2><small><cnormal>%s", description))
	self.Description:SizeToContentsY()
end

derma.DefineControl("RPExamine", "A character examine window", PANEL, "RPBasePanel")

Interface.Register("Examine", function(ply, description)
	local panel = vgui.Create("RPExamine")

	panel:Setup(ply, description)

	return panel
end)

FindMetaTable("Player").Examine = coroutine.Bind(function(self)
	local description = Request.Send("Examine", self) or self.ExamineCache

	self.ExamineCache = description

	Interface.Open("Examine", self, description)
end)
