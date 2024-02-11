local PANEL = {}

function PANEL:Init()
	self:SetSkin("Afterglow")

	self:SetSize(600, 300)
	self:MakePopup()

	self.Scroll = self:Add("RPChatScroll")
	self.Scroll:SetPos(10, 40)
	self.Scroll:SetSize(580, 220)

	self.Tabs = cookie.GetNumber("afterglow_chat_tabs", -1)
	self.Buttons = {}

	local last
	local tabs = {
		{"LOOC", 	TAB_LOOC},
		{"OOC",		TAB_OOC},
		{"IC",		TAB_IC},
		{"Admin",	TAB_ADMIN},
		{"PM",		TAB_PM},
		{"Radio",	TAB_RADIO}
	}

	for _, v in pairs(tabs) do
		local button = self:Add("DButton")

		button:SetFont("afterglow.labelsmall")
		button:SetText(v[1])
		button:SetSize(60, 20)
		button:SetPos(10, 10)

		button.SkinVar = "Active"
		button.SkinInverted = true

		if last then
			button:MoveRightOf(last, 5)
		end

		button.Active = self:CanSeeTab(v[2])
		button.Tab = v[2]

		button.DoClick = function(pnl)
			pnl.Active = not pnl.Active

			self:SaveTabConfig()
		end

		last = button

		table.insert(self.Buttons, button)
	end

	self.Input = self:Add("RPChatInput")
	self.Input:SetSize(self:GetWide() - 20, 20)
	self.Input:SetPos(10, self:GetTall() - self.Input:GetTall() - 10)

	self.Close = self:Add("DButton")
	self.Close:SetFont("marlett")
	self.Close:SetText("r")
	self.Close:SetSize(20, 20)
	self.Close:SetPos(self:GetWide() - self.Close:GetWide() - 10, 10)

	self.Close.DoClick = function(pnl)
		Chat.Hide()
	end
end

function PANEL:SaveTabConfig()
	local val = 0

	for _, v in pairs(self.Buttons) do
		if v.Active then
			val = val + v.Tab
		end
	end

	self.Tabs = val

	cookie.Set("afterglow_chat_tabs", val)
end

function PANEL:CanSeeTab(tab)
	if not tab then
		return true
	end

	return self.Tabs == -1 or tobool(bit.band(self.Tabs, tab))
end

function PANEL:AddMessage(message, consoleMessage, tabs)
	self.Scroll:AddMessage(message, tabs)
end

-- We explicitly don't call back to normal show/hide since we don't want to hide everything
-- most notably we want to keep the canvas around so we can draw chat without too much extra work

function PANEL:Show()
	self.IsOpen = true

	self:SetKeyboardInputEnabled(true)
	self:SetMouseInputEnabled(true)

	self.Scroll:Show()

	self.Input:Show()
	self.Input:RequestFocus()
	self.Input.HistoryIndex = 0

	for _, v in pairs(self.Buttons) do
		v:Show()
	end

	self.Close:Show()
end

function PANEL:Hide()
	self.IsOpen = false

	self:SetKeyboardInputEnabled(false)
	self:SetMouseInputEnabled(false)

	self.Scroll:Hide()

	self.Input:Hide()
	self.Input:SetText("")

	for _, v in pairs(self.Buttons) do
		v:Hide()
	end

	self.Close:Hide()
end

function PANEL:ExportBuffer()
	return {
		self.Scroll.Buffer,
		self.Scroll.BufferSize,
		self.IsOpen,
		self.Scroll.VBar:GetScroll()
	}
end

function PANEL:ImportBuffer(buffer)
	self.Scroll.Buffer = buffer[1]
	self.Scroll.BufferSize = buffer[2]

	self.Scroll:InvalidateLayout()

	if buffer[3] then
		self:Show()
		self.Scroll.VBar:SetScroll(buffer[4])
	end
end

function PANEL:Paint(w, h)
	if self.IsOpen then
		derma.SkinHook("Paint", "Frame", self, w, h)
	end
end

derma.DefineControl("RPChat", "Main chat window", PANEL, "EditablePanel")

Interface.Register("Chat", function()
	local panel = vgui.Create("RPChat")

	panel:SetPos(20, ScrH() - panel:GetTall() - 200)
	panel:Hide()

	return panel
end)
