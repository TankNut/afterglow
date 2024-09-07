local function updateDescription(self)
	local desc = LocalPlayer():GetVisibleDescription():Escape()

	self.Description:SetText(string.format("<iset=2><small><cnormal>%s", desc))
	self.Description:SizeToContentsY()
end

local function func(self)
	self.Preview = self:Add("RPLiveView")
	self.Preview:DockMargin(0, 0, 5, 0)
	self.Preview:Dock(LEFT)
	self.Preview:SetWide(200)
	self.Preview:SetEntity(LocalPlayer())

	local bottom = self:Add("DPanel")

	bottom:DockMargin(0, 5, 0, 0)
	bottom:Dock(BOTTOM)
	bottom:SetTall(22)
	bottom:SetPaintBackground(false)

	self.CharacterName = self:Add("DLabel")
	self.CharacterName:DockMargin(0, 0, 0, 5)
	self.CharacterName:Dock(TOP)
	self.CharacterName:SetTall(22)
	self.CharacterName:SetFont("afterglow.labelgiant")
	self.CharacterName:SetText(LocalPlayer():GetVisibleName())

	self.Scroll = self:Add("DScrollPanel")
	self.Scroll:DockMargin(0, 0, 0, 0)
	self.Scroll:Dock(FILL)
	self.Scroll:InvalidateParent(true)

	self.Description = self.Scroll:Add("ScribeLabel")
	self.Description:SetWide(self.Scroll:GetWide() - 15)

	self.Scroll:AddItem(self.Description)

	updateDescription(self)

	self.ChangeDescription = bottom:Add("DButton")
	self.ChangeDescription:DockMargin(5, 0, 0, 0)
	self.ChangeDescription:Dock(RIGHT)
	self.ChangeDescription:SetText("Change Description")
	self.ChangeDescription:SetDisabled(not hook.Run("CanChangeCharacterDescription", LocalPlayer()))
	self.ChangeDescription:SizeToContents()

	self.ChangeDescription.DoClick = function()
		coroutine.wrap(function()
			local new = Interface.Open("Input", "string", "Change Description", {
				Min = Config.Get("MinDescriptionLength"),
				Max = Config.Get("MaxDescriptionLength"),
				AllowedCharacters = Config.Get("DescriptionCharacters"),
				Multiline = true,
				Default = LocalPlayer():GetVisibleDescription()
			})

			Netstream.Send("SetCharacterDescription", new)
		end)()
	end

	self.ChangeName = bottom:Add("DButton")
	self.ChangeName:DockMargin(5, 0, 0, 0)
	self.ChangeName:Dock(RIGHT)
	self.ChangeName:SetText("Change Name")
	self.ChangeName:SetDisabled(not hook.Run("CanChangeCharacterName", LocalPlayer()))
	self.ChangeName:SizeToContents()

	self.ChangeName.DoClick = function()
		coroutine.wrap(function()
			local new = Interface.Open("Input", "string", "Change Description", {
				Min = Config.Get("MinNameLength"),
				Max = Config.Get("MaxNameLength"),
				AllowedCharacters = Config.Get("NameCharacters"),
				Default = LocalPlayer():GetVisibleName()
			})

			Netstream.Send("SetCharacterName", new)
		end)()
	end

	hook.Add("OnVisibleNameChanged", self.CharacterName, function(ply, _, new)
		if ply == LocalPlayer() then
			self.CharacterName:SetText(new)
		end
	end)

	hook.Add("OnVisibleDescriptionChanged", self.Description, function(ply)
		updateDescription(self)
	end)
end

hook.Add("PopulatePlayerMenu", "Description", function(pnl)
	pnl:AddMenu(1, "Description", func)
end)
