local PANEL = {}

function PANEL:Init()
	self:SetFont("afterglow.labelbig")
	self:SetUpdateOnType(true)

	self.m_bLoseFocusOnClickAway = false

	self.History = {}
	self.HistoryIndex = 0
end

function PANEL:OnKeyCodeTyped(code)
	self:OnKeyCode(code)

	if code == KEY_ESCAPE then
		Chat.Hide()
		RunConsoleCommand("cancelselect")
	elseif code == KEY_ENTER then
		self:OnEnter()
	elseif code == KEY_UP or code == KEY_DOWN then
		self:CycleChatHistory(code)
	end
end

function PANEL:CycleChatHistory(code)
	if code == KEY_UP and self.HistoryIndex == 1 then
		return
	elseif code == KEY_DOWN and self.HistoryIndex == 0 then
		return
	elseif code == KEY_UP and self.HistoryIndex == 0 then
		self.Backup = self:GetText()
	end

	local change = (code == KEY_DOWN) and 1 or -1
	local index = (self.HistoryIndex + change) % (#self.History + 1)

	if index == 0 then
		self:SetText(self.Backup)
		self.Backup = nil
	else
		self:SetText(self.History[index])
	end

	self:SetCaretPos(#self:GetText())
	self.HistoryIndex = index
end

function PANEL:OnEnter()
	local str = self:GetText()

	if #str == 0 then
		Chat.Hide()
		return
	end

	if #self.History > 100 then
		table.remove(self.History, 1)
	end

	table.insert(self.History, str)

	Chat.Parse(LocalPlayer(), str)
	Chat.Hide()
end

function PANEL:AllowInput(char)
	if #self:GetValue() > Config.Get("ChatLimit") then
		surface.PlaySound("weapons/pistol/pistol_empty.wav")

		return true
	elseif char == input.LookupBinding("toggleconsole") then
		return true
	end
end

derma.DefineControl("RPChatInput", "Chat input panel", PANEL, "DTextEntry")
