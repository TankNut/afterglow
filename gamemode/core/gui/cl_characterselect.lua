local PANEL = {}
DEFINE_BASECLASS("afterglow_basepanel")

function PANEL:Init()
	self:SetWide(200)
	self:DockPadding(10, 10, 10, 10)

	if LocalPlayer():HasCharacter() then
		self:SetToggleKey("gm_showteam")
		self:SetAllowEscape(true)
	end

	self:SetDrawTopBar(true)
	self:SetTitle("Character Selection")

	--self:Populate()

	self:MakePopup()
	self:Center()
end

function PANEL:Populate()
	self.Buttons = {}

	for k, v in SortedPairs(LocalPlayer():GetCharList()) do
		local button = self:Add("DButton")

		button:DockMargin(0, 0, 0, 5)
		button:Dock(TOP)
		button:SetText(v)

		button.DoClick = function(pnl)
			if self.DeleteMode then
				netstream.Send("DeleteCharacter", k)
			else
				netstream.Send("SelectCharacter", k)

				self:Remove()
			end
		end

		button.ID = k

		table.insert(self.Buttons, button)
	end

	local num = #self.Buttons
	local max = GAMEMODE:GetConfig("max_characters")
	local perm, temp = LocalPlayer():GetCharacterTypeList()

	if num < max then
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
		coroutine.Call(function()
			GAMEMODE:OpenGUI("CharClass", "Character type selection", perm)
			GAMEMODE:OpenGUI("CharCreate", coroutine.yield())
		end)
	end

	if #perm < 1 or num >= max then
		self.CreateNew:SetDisabled(true)
	end

	self.TempCharacters = self:Add("DButton")
	self.TempCharacters:DockMargin(0, 5, 0, 0)
	self.TempCharacters:Dock(TOP)
	self.TempCharacters:SetText("Temporary characters")

	self.TempCharacters.DoClick = function(pnl)
		coroutine.Call(function()
			GAMEMODE:OpenGUI("CharClass", "Temporary character selection", temp)

			netstream.Send("CreateTempCharacter", coroutine.yield())
		end)
	end

	if #temp < 1 then
		self.TempCharacters:SetDisabled(true)
	end

	self.Delete = self:Add("DButton")
	self.Delete:DockMargin(0, 5, 0, 0)
	self.Delete:Dock(TOP)
	self.Delete:SetText("Delete")

	self.Delete.DoClick = function(pnl)
		self.DeleteMode = not self.DeleteMode

		local override = self:GetSkin().Text.Primary

		pnl:SetTextColor(self.DeleteMode and override or nil)
	end

	self:InvalidateLayout(true)
	self:SizeToChildren(false, true)
end

vgui.Register("afterglow_characterselect", PANEL, "afterglow_basepanel")

Interface.Register("CharacterSelect", function()
	return vgui.Create("afterglow_characterselect")
end)
