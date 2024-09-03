Hud = Hud or {}

if SERVER then
	AddCSLuaFile("class/base_hudelement.lua")
end

function Hud.AddFile(path, name)
	if CLIENT then
		name = name or path:GetFileFromFilename():sub(1, -5)

		_G.CLASS = {}

		IncludeFile(path, "client")
		Hud.RegisterElement(name, CLASS)

		_G.CLASS = nil
	else
		AddCSLuaFile(path)
	end
end

function Hud.AddFolder(basePath)
	local recursive

	recursive = function(path)
		local files, folders = file.Find(path .. "/*", "LUA")

		for _, v in pairs(files) do
			if v:GetExtensionFromFilename() != "lua" then
				continue
			end

			Hud.AddFile(path .. "/" .. v)
		end

		for _, v in pairs(folders) do
			recursive(path .. "/" .. v)
		end
	end

	recursive(engine.ActiveGamemode() .. "/gamemode/" .. basePath)
end

if SERVER then
	hook.Add("PostPlayerSpawn", "Hud", function(ply)
		Netstream.Send("HudRebuild", ply)
	end)

	hook.Add("UnloadCharacter", "Hud", function(ply, id, loadingNew)
		if not loadingNew then
			Netstream.Send("HudClear", ply)
		end
	end)

	return
end

Hud.List = Hud.List or {}
Hud.Class = Hud.Class or {}

Hud.ActiveElements = Hud.ActiveElements or {}
Hud.ActiveLookup = Hud.ActiveLookup or {}

_G.CLASS = Hud.Class
IncludeFile("class/base_hudelement.lua", "client")
_G.CLASS = nil

Hud.Skin = derma.GetNamedSkin("Afterglow")

function Hud.RegisterElement(name, data)
	name = name:lower()
	data.ID = name

	local base = data.Base

	Hud.List[name] = setmetatable(data, {
		__index = function(_, index)
			return base and Hud.Get(base)[index] or Hud.Class[index]
		end
	})
end

function Hud.Get(id)
	return Hud.List[id]
end

function Hud.GetActive(id)
	return Hud.ActiveLookup[id]
end

function Hud.FireEvent(event, ...)
	for _, element in pairs(Hud.ActiveElements) do
		element:OnEvent(event, ...)
	end
end

function Hud.Add(id)
	if not Hud.Get(id) or not Hud.Rebuilding then
		return
	end

	Hud.Rebuilding[id] = true
end

function Hud.Clear()
	for _, element in pairs(Hud.ActiveElements) do
		element:OnRemove()
	end

	table.Empty(Hud.ActiveElements)
	table.Empty(Hud.ActiveLookup)
end

function Hud.Rebuild()
	Hud.Rebuilding = {}

	local ply = LocalPlayer()

	hook.Run("GetHudElements", ply)

	local elements = Hud.Rebuilding

	Hud.Rebuilding = nil

	for id in pairs(elements) do
		if not Hud.ActiveLookup[id] then
			local data = Hud.Get(id)
			local element = setmetatable({
				Player = LocalPlayer()
			}, {__index = data})

			table.insert(Hud.ActiveElements, element)
			Hud.ActiveLookup[id] = element

			element:Initialize()
		end
	end

	for id, element in pairs(Hud.ActiveLookup) do
		if not elements[id] then
			element:OnRemove()

			for index, v in pairs(Hud.ActiveElements) do
				if v == element then
					table.remove(Hud.ActiveElements, index)

					break
				end
			end

			Hud.ActiveLookup[id] = nil
		end
	end

	table.SortByMember(Hud.ActiveElements, "DrawOrder")
end

Netstream.Hook("HudRebuild", function() Hud.Rebuild() end)
Netstream.Hook("HudClear", function() Hud.Clear() end)

local disabled = table.Lookup({
	"CHudHealth", "CHudBattery",
	"CHudChat", "CHudHistoryResource",
	"CHUDAutoAim", "CHudDamageIndicator"
})

hook.Add("HUDShouldDraw", "Hud", function(name)
	if disabled[name] then
		return false
	end

	if name == "CHudCrosshair" and not IsValid(LocalPlayer():GetActiveWeapon()) then
		return false
	end
end)

hook.Add("HUDPaint", "Hud", function()
	local w, h = ScrW(), ScrH()

	for _, element in ipairs(Hud.ActiveElements) do
		element:Paint(w, h)
	end
end)

hook.Add("HUDPaintBackground", "Hud", function()
	local w, h = ScrW(), ScrH()

	for _, element in ipairs(Hud.ActiveElements) do
		element:PaintBackground(w, h)
	end
end)

hook.Add("OnReloaded", "Hud", function()
	Hud.Clear()
	Hud.Rebuild()
end)
