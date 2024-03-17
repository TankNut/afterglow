CharacterFlag = CharacterFlag or {}
CharacterFlag.List = CharacterFlag.List or {}

local meta = FindMetaTable("Player")

Character.AddVar("Flag", {
	Default = "default",
	Callback = function(ply, old, new)
		if SERVER and not CHARACTER_LOADING then
			hook.Run("PlayerSetup", ply)
		end
	end
})

function CharacterFlag.Add(name, data)
	if name != "default" then
		setmetatable(data, {__index = CharacterFlag.List.default})
	else
		CharacterFlag.Default = data
	end

	data.ID = name

	CharacterFlag.List[name] = data
end

function CharacterFlag.AddFile(path, name)
	name = name or path:GetFileFromFilename():sub(1, -5)

	_G.FLAG = {}

	IncludeFile(path)
	CharacterFlag.Add(name, FLAG)

	_G.FLAG = nil
end

function CharacterFlag.AddFolder(basePath)
	basePath = engine.ActiveGamemode() .. "/gamemode/" .. basePath

	CharacterFlag.AddFile(basePath .. "/default.lua")

	local recursive

	recursive = function(path)
		local files, folders = file.Find(path .. "/*", "LUA")

		for _, v in pairs(files) do
			if v == "default.lua" or v:GetExtensionFromFilename() != "lua" then
				continue
			end

			CharacterFlag.AddFile(path .. "/" .. v)
		end

		for _, v in pairs(folders) do
			recursive(path .. "/" .. v)
		end
	end

	recursive(basePath)
end

function CharacterFlag.Get(name)
	return CharacterFlag.List[name]
end

function CharacterFlag.GetOrDefault(name)
	return CharacterFlag.List[name] or CharacterFlag.default
end

function meta:GetCharacterFlagTable()
	return CharacterFlag.GetOrDefault(self:GetCharacterFlag())
end

function meta:GetCharacterFlagAttribute(name)
	return self:GetCharacterFlagTable():GetAttribute(self, name)
end

function GM:GetCharacterFlagAttribute(flag, ply, name)
	if flag.AttributeBlacklist[name] then
		error("Attempt to FLAG:GetAttribute blacklisted key " .. name)
	end

	local func = flag["Get" .. name]

	return func and func(flag, ply) or flag[name]
end

