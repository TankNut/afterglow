module("CharacterFlags", package.seeall)

local meta = FindMetaTable("Player")

List = List or {}

Character.RegisterVar("Flag", {
	Default = "default",
	Callback = function(ply, old, new)
		if SERVER and not CHARACTER_LOADING then
			ply:UpdateAttributes()
		end
	end
})

function Register(name, data)
	List[name] = data
end

function LoadFromFile(path, name)
	name = name or path:GetFileFromFilename():sub(1, -5)

	_G.FLAG = {}

	IncludeFile(path)

	Register(name, FLAG)

	_G.FLAG = nil
end

function LoadFlags()
	local recursive

	recursive = function(path)
		local files, folders = file.Find(path .. "/*", "LUA")

		for _, v in pairs(files) do
			if v:GetExtensionFromFilename() != "lua" then
				continue
			end

			LoadFromFile(path .. "/" .. v)
		end

		for _, v in pairs(folders) do
			recursive(path .. "/" .. v)
		end
	end

	recursive(engine.ActiveGamemode() .. "/gamemode/content/characterflags")
end

function meta:GetCharacterFlagTable()
	return List[self:GetCharacterFlag()] or List.default
end

function meta:GetCharacterFlagAttribute(name)
	local flag = List[self:GetCharacterFlag()] or List.default
	local func = flag["Get" .. name]

	return func and func(flag, ply) or flag[name]
end
