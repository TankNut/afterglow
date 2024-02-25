module("Template", package.seeall)

local meta = FindMetaTable("Player")

Class = Class or {}
List = List or {}


_G.TEMPLATE = Class
IncludeFile("class/base_template.lua")
_G.TEMPLATE = nil


function Add(name, data)
	name = name:lower()
	data.ID = name

	-- Rewrite fields and callbacks so they're in the proper load format
	if data.Vars then
		local vars = {}

		for key, val in pairs(data.Vars) do
			local var = Character.Vars[key]

			if var then
				vars[var.Field] = val
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

	List[name] = setmetatable(data, {
		__index = Class
	})
end


function AddFile(path, name)
	name = name or path:GetFileFromFilename():sub(1, -5)

	_G.TEMPLATE = {}

	IncludeFile(path)
	Add(name, TEMPLATE)

	_G.TEMPLATE = nil
end


function AddFolder(basePath)
	local recursive

	recursive = function(path)
		local files, folders = file.Find(path .. "/*", "LUA")

		for _, v in pairs(files) do
			if v:GetExtensionFromFilename() != "lua" then
				continue
			end

			AddFile(path .. "/" .. v)
		end

		for _, v in pairs(folders) do
			recursive(path .. "/" .. v)
		end
	end

	recursive(engine.ActiveGamemode() .. "/gamemode/" .. basePath)
end


function Get(id)
	return List[id]
end


function meta:HasTemplate(template)
	return self:GetTemplates()[template]
end


function meta:GetAvailableTemplates()
	local tab = {}

	for id, data in pairs(List) do
		if hook.Run("HasTemplateAccess", self, id) then
			table.insert(tab, data)
		end
	end

	return tab
end


if SERVER then
	-- Don't have to bind here since Character.Load doesn't do any async calls on
	-- template character loads
	function Load(ply, template)
		local fields = {}

		for field, val in pairs(template.Vars) do
			fields[field] = val
		end

		for field, func in pairs(template.Callbacks) do
			local val = template[func](template, ply)

			if val != nil then
				fields[field] = val
			end
		end

		Character.Load(ply, 0, fields)

		local inventory = ply:GetInventory()

		for _, class in pairs(template.Items) do
			local data

			if istable(class) then
				class, data = class[1], class[2]
			end

			local item = Item.CreateTemp(class, data)

			item:SetInventory(inventory)
		end

		template:OnCreate(ply)
	end


	netstream.Hook("LoadTemplate", function(ply, id)
		if not hook.Run("HasTemplateAccess", ply, id) then
			return
		end

		Load(ply, Get(id))
	end)


	function meta:GiveTemplate(template)
		local templates = self:GetTemplates()

		templates[template] = true

		self:SetTemplates(templates)
	end


	function meta:TakeTemplate(template)
		local templates = self:GetTemplates()

		templates[template] = nil

		self:SetTemplates(templates)
	end
end


function GM:HasTemplateAccess(ply, template)
	return ply:IsSuperAdmin() or ply:HasTemplate(template)
end
