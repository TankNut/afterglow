Language = Language or {}
Language.List = table.Copy(Config.Get("Languages"))
Language.Lookup = {}

for _, v in pairs(Language.List) do
	Language.Lookup[v[1]] = v
end

IncludeFile("sh_vars.lua")
IncludeFile("sh_hooks.lua")
IncludeFile("sh_meta.lua")

function Language.Get(command)
	return Language.Lookup[command]
end

function Language.GetName(command)
	return Language.Get(command)[2]
end

function Language.GetUnknown(command)
	local lang = Language.Get(command)

	return lang[3] or lang[2]
end

function Language.GetOverride(command, index)
	local override = Language.Get(command)[4]

	if override and override[index] then
		override = override[index]

		return isstring(override) and override or table.Random(override)
	end
end

function Language.FromConfig(data)
	local langs = {}

	for _, lang in pairs(data) do
		langs[lang[1]] = lang[2]
	end

	return langs
end
