Template = Template or {}

Template.Class = Template.Class or {}
Template.List = Template.List or {}

_G.TEMPLATE = Template.Class
IncludeFile("class/base_template.lua")
_G.TEMPLATE = nil

local meta = FindMetaTable("Player")

PlayerVar.Add("Templates", {
	Field = "character_templates",
	Default = {},
	Private = true
})

function Template.Add(name, data)
	name = name:lower()
	data.ID = name

	Template.List[name] = Template.Process(data)
end

function Template.AddFile(path, name)
	name = name or path:GetFileFromFilename():sub(1, -5)

	_G.TEMPLATE = {}

	IncludeFile(path)
	Template.Add(name, TEMPLATE)

	_G.TEMPLATE = nil
end

function Template.AddFolder(basePath)
	local recursive

	recursive = function(path)
		local files, folders = file.Find(path .. "/*", "LUA")

		for _, v in pairs(files) do
			if v:GetExtensionFromFilename() != "lua" then
				continue
			end

			Template.AddFile(path .. "/" .. v)
		end

		for _, v in pairs(folders) do
			recursive(path .. "/" .. v)
		end
	end

	recursive(engine.ActiveGamemode() .. "/gamemode/" .. basePath)
end

function Template.Process(data)
	-- Rewrite fields and callbacks so they're in the proper load format
	if data.Vars then
		local vars = {}

		for key, val in pairs(data.Vars) do
			local field = Character.VarToField(key)

			if field then
				vars[field] = val
			end
		end

		data.Vars = vars
	end

	if data.Callbacks then
		local callbacks = {}

		for _, key in pairs(data.Callbacks) do
			if not data["Get" .. key] then
				error("Template callback doesn't have matching Get" .. key .. " function")
			end

			local var = Character.Vars[key]

			if var then
				callbacks[var.Field] = "Get" .. key
			end
		end

		data.Callbacks = callbacks
	end

	local base = data.Base

	return setmetatable(data, {
		__index = function(_, index)
			return base and Template.Get(base)[index] or Template.Class[index]
		end
	})
end

function Template.Get(id)
	return Template.List[id]
end

function meta:CanAccessTemplate(id)
	return hook.Run("CanAccessTemplate", self, id)
end

function meta:GetAvailableTemplates()
	local tab = {}

	for id, data in pairs(Template.List) do
		if self:CanAccessTemplate(id) then
			table.insert(tab, data)
		end
	end

	return tab
end

if SERVER then
	-- Don't have to bind here since ply:LoadCharacter doesn't do any async calls on template character loads
	function meta:LoadTemplate(template)
		if isstring(template) then
			template = Template.Get(template)
		end

		local fields = {}

		for field, val in pairs(template.Vars) do
			fields[field] = val
		end

		hook.Run("PreCreateCharacter", self, fields)

		local data = {}

		template:OnCreate(self, data, fields)

		for field, func in pairs(template.Callbacks) do
			local val = template[func](template, self, data)

			if val != nil then
				fields[field] = val
			end
		end

		self:LoadCharacter(Character.TempID, fields)

		Character.TempID = Character.TempID - 1

		local inventory = self:GetInventory()

		for _, class in pairs(template:GetItems(self, data)) do
			local itemData

			if istable(class) then
				class, itemData = class[1], class[2]
			end

			local item = Item.CreateTemp(class, itemData)

			item:SetInventory(inventory)
		end

		template:OnLoad(self, data)
	end

	Netstream.Hook("LoadTemplate", function(ply, id)
		local template = Template.Get(id)

		if not template or not ply:CanAccessTemplate(id) then
			return
		end

		ply:LoadTemplate(template)
	end)

	function meta:GiveTemplate(id)
		local templates = self:GetTemplates()

		templates[id] = true

		self:SetTemplates(templates)
	end

	function meta:TakeTemplate(id)
		local templates = self:GetTemplates()

		templates[id] = nil

		self:SetTemplates(templates)
	end
end
