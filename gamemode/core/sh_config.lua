module("Config", package.seeall)

function Get(key)
	return GAMEMODE.Config[key]
end
