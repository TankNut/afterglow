module("Database", package.seeall)

function Initialize()
	local config = GAMEMODE.Config.Database

	mysql:Connect(config.Host, config.Username, config.Password, config.Database, config.Port)
end

LoadTables = coroutine.Bind(function()
	local query

	query = mysql:Create("rp_player_data")
		query:Create("steamid", "VARCHAR(32) NOT NULL", true)
		query:Create("key", "VARCHAR(255) NOT NULL", true)
		query:Create("value", "TEXT NOT NULL")
	query:Execute()

	query = mysql:Create("rp_characters")
		query:Create("id", "INT(11) NOT NULL AUTO_INCREMENT", true)
		query:Create("steamid", "VARCHAR(32) NOT NULL")
	query:Execute()

	query = mysql:Create("rp_character_data")
		query:Create("id", "INT(11) NOT NULL", true)
		query:Create("key", "VARCHAR(255) NOT NULL", true)
		query:Create("value", "TEXT NOT NULL")
	query:Execute()

	mysql:Suppress()
	mysql:Query("ALTER TABLE rp_character_data ADD CONSTRAINT fk_rp_characters_id FOREIGN KEY (id) REFERENCES rp_characters(id) ON DELETE CASCADE")

	query = mysql:Create("rp_items")
		query:Create("id", "INT(11) NOT NULL AUTO_INCREMENT", true)
		query:Create("class", "VARCHAR(255) NOT NULL")
		query:Create("storetype", "INT(11) NOT NULL DEFAULT 0")
		query:Create("storeid", "INT(11) NOT NULL DEFAULT 0")
		query:Create("worldmap", "VARCHAR(255) NOT NULL DEFAULT ''")
		query:Create("worldpos", "VARCHAR(255) NOT NULL DEFAULT '" .. pack.Default .. "'")
		query:Create("customdata", "TEXT NOT NULL")
	query:Execute()

	hook.Run("PostInitDatabase")
end)
