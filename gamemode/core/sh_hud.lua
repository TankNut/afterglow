module("Hud", package.seeall)

if SERVER then
	IncludeFile("class/base_hudelement.lua", "client")
end

function AddFile(path, name)
	if CLIENT then
		name = name or path:GetFileFromFilename():sub(1, -5)

		_G.CLASS = {}

		IncludeFile(path, "client")
		RegisterElement(name, CLASS)

		_G.CLASS = nil
	else
		IncludeFile(path, "client")
	end
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

if SERVER then
	hook.Add("PostPlayerSpawn", "Hud", function(ply)
		netstream.Send("HudRebuild", ply)
	end)

	hook.Add("UnloadCharacter", "Hud", function(ply, id, loadingNew)
		if not loadingNew then
			netstream.Send("HudClear", ply)
		end
	end)

	return
end

List = List or {}
Class = Class or {}

ActiveElements = ActiveElements or {}
ActiveLookup = ActiveLookup or {}

_G.CLASS = Class
IncludeFile("class/base_hudelement.lua", "client")
_G.CLASS = nil

Skin = derma.GetNamedSkin("Afterglow")

function RegisterElement(name, data)
	name = name:lower()
	data.ID = name

	local base = data.Base

	List[name] = setmetatable(data, {
		__index = function(_, index)
			return base and Get(base)[index] or Class[index]
		end
	})
end

function Get(id)
	return List[id]
end

function GetActive(id)
	return ActiveLookup[id]
end

function FireEvent(event, ...)
	for _, element in pairs(ActiveElements) do
		element:OnEvent(event, ...)
	end
end

function Add(id, ...)
	if GetActive(id) then
		Remove(id)
	end

	local data = Get(id)
	local element = setmetatable({}, {__index = data})

	table.insert(ActiveElements, element)
	ActiveLookup[id] = element

	element:Initialize(LocalPlayer(), ...)

	table.SortByMember(ActiveElements, "DrawOrder")

	return element
end

function Remove(id)
	local element = GetActive(id)

	if not element then
		return
	end

	element:OnRemove()

	for index, v in pairs(ActiveElements) do
		if v == element then
			table.remove(ActiveElements, index)
			break;
		end
	end

	ActiveLookup[id] = nil
end

function Clear()
	for _, element in pairs(ActiveElements) do
		element:OnRemove()
	end

	table.Empty(ActiveElements)
	table.Empty(ActiveLookup)
end

function Rebuild()
	Clear()

	for id, element in pairs(List) do
		if element.Default then
			Add(id)
		end
	end

	hook.Run("OnHudRebuild")
end

netstream.Hook("HudRebuild", function() Rebuild() end)
netstream.Hook("HudClear", function() Clear() end)

local disabled = table.Lookup({
	"CHudHealth", "CHudBattery",
	"CHudChat", "CHudHistoryResource",
	"CHUDAutoAim", "CHudDamageIndicator"
})

hook.Add("HUDShouldDraw", "Hud", function(name)
	if disabled[name] then
		return false
	end
end)

hook.Add("HUDPaint", "Hud", function()
	local ply = LocalPlayer()
	local w, h = ScrW(), ScrH()

	for _, element in ipairs(ActiveElements) do
		element:Paint(ply, w, h)
	end
end)

hook.Add("HUDPaintBackground", "Hud", function()
	local ply = LocalPlayer()
	local w, h = ScrW(), ScrH()

	for _, element in ipairs(ActiveElements) do
		element:PaintBackground(ply, w, h)
	end
end)
