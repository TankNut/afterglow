local PANEL = {}

function PANEL:Init()
	self:SetWide(200)
	self:DockPadding(10, 10, 10, 10)

	if LocalPlayer():HasCharacter() then
		self:SetToggleKey("gm_showteam")
		self:SetAllowEscape(true)
	end

	self:SetDrawTopBar(true)
	self:SetTitle("Character Selection")

	self:Populate()

	self:MakePopup()
	self:Center()
end

function PANEL:Populate()
	self.Buttons = {}

	local ply = LocalPlayer()

	for id, name in SortedPairs(ply:GetCharacterList()) do
		local button = self:Add("DButton")

		button:DockMargin(0, 0, 0, 5)
		button:Dock(TOP)
		button:SetText(name)

		button.DoClick = function(pnl)
			if self.DeleteMode then
				Netstream.Send("DeleteCharacter", id)
			else
				Netstream.Send("SelectCharacter", id)

				button:SetDisabled(true)
			end
		end

		if id == ply:GetCharID() then
			button:SetDisabled(true)
		end

		button.ID = id

		table.insert(self.Buttons, button)
	end

	local numCharacters = #self.Buttons
	local max = Config.Get("MaxCharacters")

	if numCharacters < max then
		local button = self:Add("DButton")

		button:DockMargin(0, 0, 0, 5)
		button:Dock(TOP)
		button:SetText("Empty slot")
		button:SetDisabled(true)
	end

	self.CreateNew = self:Add("DButton")
	self.CreateNew:DockMargin(0, 20, 0, 0)
	self.CreateNew:Dock(TOP)
	self.CreateNew:SetText("Create character")

	self.CreateNew.DoClick = function(pnl)
		Interface.OpenGroup("CharacterCreate", "F2")
	end

	if numCharacters >= max then
		self.CreateNew:SetDisabled(true)
	end

	self.TempCharacters = self:Add("DButton")
	self.TempCharacters:DockMargin(0, 5, 0, 0)
	self.TempCharacters:Dock(TOP)
	self.TempCharacters:SetText("Template characters")

	self.TempCharacters.DoClick = function(pnl)
		Interface.OpenGroup("TemplateSelect", "F2")
	end

	self.TempCharacters:SetDisabled(table.IsEmpty(ply:GetAvailableTemplates()))

	self.Delete = self:Add("DButton")
	self.Delete:DockMargin(0, 5, 0, 0)
	self.Delete:Dock(TOP)
	self.Delete:SetText("Delete")

	self.Delete.DoClick = function(pnl)
		self.DeleteMode = not self.DeleteMode

		local override = self:GetSkin().Text.Primary

		pnl:SetTextColor(self.DeleteMode and override or nil)

		if self.DeleteMode then
			for _, v in pairs(self.Buttons) do
				v:SetDisabled(false)
			end
		else
			local id = ply:GetCharID()

			for _, v in pairs(self.Buttons) do
				v:SetDisabled(v.ID == id)
			end
		end
	end

	self:InvalidateLayout(true)
	self:SizeToChildren(false, true)
end

derma.DefineControl("RPCharacterSelect", "Character selection gui", PANEL, "RPBasePanel")

Interface.Register("CharacterSelect", function()
	return vgui.Create("RPCharacterSelect")
end)
