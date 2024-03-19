GM.Config.ServerName = "Afterglow"

GM.Config.Content = {
	"3149717683", -- Gmod expanded assets
	"2891252709" -- Half Life 2 Props Extended
}

-- All languages
GM.Config.Languages = {
	{"eng", "English"},
	{"rus", "Russian"}
}

-- Default languages characters are given during creation
GM.Config.DefaultLanguages = {
	{"eng", true}
}

-- Characters
GM.Config.MaxCharacters = 10

GM.Config.MinNameLength = 3
GM.Config.MaxNameLength = 30

GM.Config.MinDescriptionLength = 0
GM.Config.MaxDescriptionLength = 2048

GM.Config.ShortDescriptionLength = 64

GM.Config.NameCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ áàâäçéèêëíìîïóòôöúùûüÿÁÀÂÄßÇÉÈÊËÍÌÎÏÓÒÔÖÚÙÛÜŸ.-0123456789'"
GM.Config.DescriptionCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ áàâäçéèêëíìîïóòôöúùûüÿÁÀÂÄßÇÉÈÊËÍÌÎÏÓÒÔÖÚÙÛÜŸ.-0123456789',\n!?@#$%^&*(){}[]_=|\\\"><`~"

GM.Config.CharacterModels = {
	Model("models/player/group01/male_01.mdl"),
	Model("models/player/group01/male_02.mdl"),
	Model("models/player/group01/male_03.mdl"),
	Model("models/player/group01/male_04.mdl"),
	Model("models/player/group01/male_05.mdl"),
	Model("models/player/group01/male_06.mdl"),
	Model("models/player/group01/male_07.mdl"),
	Model("models/player/group01/male_08.mdl"),
	Model("models/player/group01/male_09.mdl"),
	Model("models/player/group01/female_01.mdl"),
	Model("models/player/group01/female_02.mdl"),
	Model("models/player/group01/female_03.mdl"),
	Model("models/player/group01/female_04.mdl"),
	Model("models/player/group01/female_05.mdl"),
	Model("models/player/group01/female_06.mdl")
}

GM.Config.DamageScale = {
	[HITGROUP_HEAD] = 1.5,
	[HITGROUP_LEFTLEG] = 0.75,
	[HITGROUP_RIGHTLEG] = 0.75
}

-- Anything at or above this damage threshold will penetrate armor no questions asked
GM.Config.PenetrationCap = 75

GM.Config.ChatLimit = 500

GM.Config.ContextRange = 1024
GM.Config.InteractRange = 82

GM.Config.BotTemplate = "citizen"
