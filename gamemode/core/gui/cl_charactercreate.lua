local PANEL = {}

function PANEL:Init()
	self:SetSize(700, 400)
	self:DockPadding(10, 10, 10, 10)

	if LocalPlayer():HasCharacter() then
		self:SetToggleKey("gm_showteam")
		self:SetAllowEscape(true)
	end

	self:SetDrawTopBar(true)
	self:SetTitle("Character Creation")

	self.Left = self:Add("DPanel")
	self.Left:DockMargin(0, 0, 10, 0)
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
	self.Confirm:DockMargin(0, 10, 0, 0)
	self.Confirm:Dock(BOTTOM)
	self.Confirm:SetText("Confirm")

	self.Confirm:SetDisabled(true)

	self.Confirm.DoClick = function(pnl)
		self:Submit()
	end

	self.ModelPanel = self.Right:Add("afterglow_modelpanel")
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
	local name = self.Left:Add("afterglow_charactercreate_entry")
	name:SetTitle("Name")
	name:SetTall(22)

	self.NameEntry = name.Canvas:Add("DTextEntry")
	self.NameEntry:Dock(FILL)
	self.NameEntry:SetUpdateOnType(true)

	self.NameEntry.OnValueChange = function(_, val)
		self:SetCharacterName(val)
	end

	local description = self.Left:Add("afterglow_charactercreate_entry")
	description:SetTitle("Description")
	description:SetTall(150)

	self.DescEntry = description.Canvas:Add("DTextEntry")
	self.DescEntry:Dock(FILL)
	self.DescEntry:SetMultiline(true)
	self.DescEntry:SetUpdateOnType(true)

	local model = self.Left:Add("afterglow_charactercreate_entry")
	model:SetTitle("Model")
	model:SetTall(56)

	self.ModelScroll = model.Canvas:Add("DHorizontalScroller")
	self.ModelScroll:Dock(FILL)

	local models = Config.Get("CharacterModels")

	for _, v in pairs(models) do
		local icon = self.ModelScroll:Add("SpawnIcon")

		icon:SetSize(56, 56)
		icon:SetModel(v)
		icon:SetTooltip()

		icon.DoClick = function()
			self:SetModel(v)
		end

		self.ModelScroll:AddPanel(icon)
	end

	local modelSkin = self.Left:Add("afterglow_charactercreate_entry")
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
		icon:SetTooltip()

		icon.DoClick = function()
			self:SetSkin(i)
		end

		self.SkinScroll:AddPanel(icon)
	end
end

local map = {
	RPName = "Name",
	CharacterModel = "Model",
	CharacterSkin = "Skin"
}

function PANEL:Validate()
	local ok, key, err = validate.Multi(self.Fields, Character.GetRules())

	self.Confirm:SetDisabled(not ok)

	if ok then
		self.Confirm:SetTooltip()
	else
		self.Confirm:SetTooltip(string.format("%s: %s", map[key], err))
	end
end

function PANEL:Submit()
	local ok, payload = validate.Multi(self.Fields, Character.GetRules())

	if ok then
		netstream.Send("CreateCharacter", payload)
	end
end

vgui.Register("afterglow_charactercreate", PANEL, "afterglow_basepanel")

Interface.Register("CharacterCreate", function()
	return vgui.Create("afterglow_charactercreate")
end)
