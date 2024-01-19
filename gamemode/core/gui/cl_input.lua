local PANEL = {}

function PANEL:Init()
	self:DockPadding(10, 10, 10, 10)
	self:SetAllowEscape(true)
	self:SetDrawTopBar(true)

	self.Bottom = self:Add("DPanel")
	self.Bottom:DockMargin(0, 10, 0, 0)
	self.Bottom:Dock(BOTTOM)
	self.Bottom:SetTall(22)
	self.Bottom:SetPaintBackground(false)

	self.Submit = self.Bottom:Add("DButton")
	self.Submit:Dock(RIGHT)
	self.Submit:SetText("Submit")
	self.Submit.DoClick = function()
		self:DoSubmit()
	end
end

function PANEL:Setup(subtype, title, data)
	self.Rules = {validate.Required()}

	self:SetTitle(title)
	self.SubType = subtype

	if subtype == "string" then
		table.insert(self.Rules, validate.String())

		if data.AllowedCharacters then
			table.insert(self.Rules, validate.AllowedCharacters(data.AllowedCharacters))
		end

		local width = data.Multiline and 500 or 300
		local height = data.Multiline and 280 or 80

		self:SetSize(width, height)

		self.TextInput = self:Add("DTextEntry")
		self.TextInput:Dock(FILL)
		self.TextInput:SetFont(data.Multiline and "afterglow.labelsmall" or "afterglow.labelbig")
		self.TextInput:SetText(data.Default or "")
		self.TextInput:SetMultiline(tobool(data.Multiline))
		self.TextInput:SetUpdateOnType(true)
		self.TextInput:SetCaretPos(#self.TextInput:GetText())

		if data.Min then
			table.insert(self.Rules, validate.Min(data.Min))
		end

		if data.Max then
			table.insert(self.Rules, validate.Max(data.Max))

			self.MaxLabel = self.Bottom:Add("DLabel")
			self.MaxLabel:DockMargin(2, 0, 0, 0)
			self.MaxLabel:Dock(FILL)
			self.MaxLabel:SetFont("afterglow.labelbig")
			self.MaxLabel:SetText(#self:GetOutput() .. "/" .. data.Max)
		end

		self.TextInput.OnChange = function()
			if data.Max then
				local val = self:GetOutput()
				local color = #val > data.Max and self:GetSkin().Text.Bad or self:GetSkin().Text.Normal

				self.MaxLabel:SetTextColor(color)
				self.MaxLabel:SetText(#val .. "/" .. data.Max)
			end

			self:Validate()
		end

		if not data.Multiline then
			self.TextInput.OnEnter = function()
				self:DoSubmit()
			end
		end

		self.TextInput:RequestFocus()
	end

	self:Validate()
	self.Coroutine = coroutine.running()
end

function PANEL:GetOutput()
	if self.SubType == "string" then
		return self.TextInput:GetText():Trim()
	end
end

function PANEL:Validate()
	local ok, err = validate.Value(self:GetOutput(), self.Rules)

	if ok then
		self.Submit:SetDisabled(false)
		self.Submit:SetTooltip()
	else
		self.Submit:SetDisabled(true)
		self.Submit:SetTooltip(err)
	end

	return ok, err
end

function PANEL:DoSubmit()
	local ok, val = self:Validate()

	if not ok then
		return
	end

	self:Remove()

	coroutine.Resume(self.Coroutine, val)
end

vgui.Register("afterglow_input", PANEL, "afterglow_basepanel")

Interface.Register("Input", function(subtype, title, data)
	local panel = vgui.Create("afterglow_input")

	panel:Setup(subtype, title, data)
	panel:MakePopup()
	panel:Center()

	return coroutine.yield()
end)
