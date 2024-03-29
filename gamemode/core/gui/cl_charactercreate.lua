local PANEL = {}

function PANEL:Init()
	self:SetSize(700, 400)
	self:DockPadding(5, 5, 5, 5)

	if LocalPlayer():HasCharacter() then
		self:SetToggleKey("gm_showteam")
		self:SetAllowEscape(true)
	end

	self:SetDrawTopBar(true)
	self:SetTitle("Character Creation")

	self.Left = self:Add("DPanel")
	self.Left:DockMargin(0, 0, 5, 0)
	self.Left:Dock(LEFT)
	self.Left:SetWide(480)
	self.Left:SetPaintBackground(false)

	self.Right = self:Add("DPanel")
	self.Right:Dock(FILL)
	self.Right:SetPaintBackground(false)

	self.Cancel = self.Right:Add("DButton")
	self.Cancel:DockMargin(0, 5, 0, 0)
	self.Cancel:Dock(BOTTOM)
	self.Cancel:SetText("Cancel")

	self.Cancel.DoClick = function(pnl)
		Interface.OpenGroup("CharacterSelect", "F2")
	end

	self.Confirm = self.Right:Add("DButton")
	self.Confirm:DockMargin(0, 5, 0, 0)
	self.Confirm:Dock(BOTTOM)
	self.Confirm:SetText("Confirm")

	self.Confirm:SetEnabled(false)

	self.Confirm.DoClick = function(pnl)
		self:Submit()
	end

	self.ModelPanel = self.Right:Add("RPModelPanel")
	self.ModelPanel:Dock(FILL)
	self.ModelPanel:SetFOV(20)
	self.ModelPanel:SetAnimated(true)
	self.ModelPanel:SetAllowManipulation(true)

	self.ModelPanel:SetModel("models/player/skeleton.mdl")

	self.Fields = {
		Name = "",
		Description = ""
	}

	self:BuildFields()

	self:MakePopup()
	self:Center()
end

function PANEL:BuildFields()
	local name = self.Left:Add("RPCharCreateEntry")
	name:SetTitle("Name")
	name:SetTall(22)

	self.NameEntry = name.Canvas:Add("DTextEntry")
	self.NameEntry:Dock(FILL)
	self.NameEntry:SetUpdateOnType(true)

	self.NameEntry.OnValueChange = function(_, val)
		self:SetCharacterName(val)
	end

	local description = self.Left:Add("RPCharCreateEntry")
	description:SetTitle("Description")
	description:SetTall(150)

	self.DescEntry = description.Canvas:Add("DTextEntry")
	self.DescEntry:Dock(FILL)
	self.DescEntry:SetMultiline(true)
	self.DescEntry:SetUpdateOnType(true)

	local model = self.Left:Add("RPCharCreateEntry")
	model:SetTitle("Model")
	model:SetTall(56)

	self.ModelScroll = model.Canvas:Add("DHorizontalScroller")
	self.ModelScroll:Dock(FILL)

	local models = Config.Get("CharacterModels")

	for _, v in pairs(models) do
		local icon = self.ModelScroll:Add("SpawnIcon")

		icon:SetSize(56, 56)
		icon:SetModel(v)
		icon:SetTooltip(false)

		icon.DoClick = function()
			self:SetModel(v)
		end

		self.ModelScroll:AddPanel(icon)
	end

	local modelSkin = self.Left:Add("RPCharCreateEntry")
	modelSkin:SetTitle("Skin")
	modelSkin:SetTall(56)

	self.SkinScroll = modelSkin.Canvas:Add("DHorizontalScroller")
	self.SkinScroll:Dock(FILL)

	self:SetModel(models[1])
end

function PANEL:SetCharacterName(name)
	self.Fields.Name = name
	self:Validate()
end

function PANEL:SetModel(mdl)
	self.Fields.Model = mdl
	self.Fields.Skin = 0

	self.ModelPanel:SetModel(mdl)
	self.ModelPanel:SetSkin(1)

	local color = CharacterFlag.Default.PlayerColor

	if color then
		self.ModelPanel.Entity.GetPlayerColor = function(ent)
			return color
		end
	end

	self:RebuildSkins()
	self:Validate()
end

function PANEL:SetSkin(index)
	self.Fields.Skin = index
	self.ModelPanel:SetSkin(index)
	self:Validate()
end

function PANEL:RebuildSkins()
	self.SkinScroll:Clear()

	local mdl = self.Fields.Model

	for i = 0, util.GetModelSkins(mdl) - 1 do
		local icon = self.SkinScroll:Add("SpawnIcon")

		icon:SetSize(56, 56)
		icon:SetModel(mdl, i)
		icon:SetTooltip(false)

		icon.DoClick = function()
			self:SetSkin(i)
		end

		self.SkinScroll:AddPanel(icon)
	end
end

function PANEL:Validate()
	local ok, key, err = Validate.Multi(self.Fields, Character.GetRules())

	self.Confirm:SetEnabled(ok)

	if ok then
		self.Confirm:SetTooltip(false)
	else
		self.Confirm:SetTooltip(string.format("%s: %s", key, err))
	end
end

function PANEL:Submit()
	local ok, payload = Validate.Multi(self.Fields, Character.GetRules())

	if ok then
		Netstream.Send("CreateCharacter", payload)

		self.Confirm:SetEnabled(false)
	end
end

derma.DefineControl("RPCharacterCreate", "Character Creation Panel", PANEL, "RPBasePanel")

Interface.Register("CharacterCreate", function()
	return vgui.Create("RPCharacterCreate")
end)
