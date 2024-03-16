Config = Config or {}

function Config.Get(key)
	return GM and GM.Config[key] or GAMEMODE.Config[key]
end
