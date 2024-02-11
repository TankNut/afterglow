local PANEL = {}

function PANEL:Init()
	self.Buffer = {}
	self.BufferSize = 0

	self.VBar = self:Add("DVScrollBar")
	self.VBar:Dock(RIGHT)

	self.VBar.AddScroll = function(pnl, delta)
		local old = pnl:GetScroll()

		pnl:SetScroll(old + delta * 18)

		return old != pnl:GetScroll()
	end

	self:SetMouseInputEnabled(true)

	self:SetPaintBackgroundEnabled(false)
	self:SetPaintBorderEnabled(false)
	self:SetPaintBackground(false)
end

function PANEL:OnMouseWheeled(delta)
	return self.VBar:OnMouseWheeled(delta)
end

function PANEL:PerformLayout()
	if self.IsOpen then
		self.VBar:SetUp(self:GetTall(), self.BufferSize + 1)
	end
end

function PANEL:AddMessage(message, consoleMessage, tabs)
	local data = {
		Scribe = scribe.Parse("<chat>" .. message, self:GetWide() - self.VBar:GetWide()),
		ReceiveTime = CurTime(),
		Tabs = tabs
	}

	if consoleMessage then
		scribe.Parse("<chat>" .. consoleMessage):PrintToConsole()
	else
		data.Scribe:PrintToConsole()
	end

	table.insert(self.Buffer, data)

	local doScroll = self.VBar:GetOffset() - self:GetTall() + self.BufferSize == -1

	self.BufferSize = self.BufferSize + data.Scribe:GetTall()

	while self.BufferSize > 2^15 - 1 do
		local line = table.remove(self.Buffer, 1)

		self.BufferSize = self.BufferSize - line.Scribe:GetTall()
	end

	if self.IsOpen then
		self.VBar:SetUp(self:GetTall(), self.BufferSize + 1)

		if doScroll then
			self.VBar:SetScroll(math.huge)
		end
	end
end

function PANEL:Hide()
	self.IsOpen = false
	self.VBar:Hide()
end

function PANEL:Show()
	self.IsOpen = true
	self.VBar:Show()

	self.VBar:SetUp(self:GetTall(), self.BufferSize + 1)
	self.VBar:SetScroll(math.huge)
end

function PANEL:Paint(w, h)
	local open = self:GetParent().IsOpen

	if open then
		local color = Color(0, 0, 0, 70)

		surface.SetDrawColor(color)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	local offset = (self.IsOpen and self.VBar:IsVisible()) and self.VBar:GetOffset() - self:GetTall() + 1 + self.BufferSize or 0
	local y = h - 3 -- Start point

	for i = #self.Buffer, 1, -1 do
		local data = self.Buffer[i]
		local lifetime = CurTime() - data.ReceiveTime
		local alpha = 255

		if not open then
			if lifetime >= 15 then
				break -- All other messages are assumed to be older, no need to iterate them
			else
				alpha = (15 - lifetime) * 0.2
			end
		end

		if self:GetParent():CanSeeTab(data.Tabs) then
			-- Bottom of the text
			if y + offset <= 0 then
				break
			end

			y = y - data.Scribe:GetTall()

			-- Top of the text
			if y + offset >= h then
				continue
			end

			data.Scribe:Draw(5, y + offset, alpha, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
	end
end

derma.DefineControl("RPChatScroll", "Custom scroll panel for chat drawing", PANEL, "DPanel")
