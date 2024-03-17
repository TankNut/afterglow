Data = Data or {}

function Data.Initialize()
	local config = GAMEMODE.Config.Database

	MySQL:Connect(config.Host, config.Username, config.Password, config.Database, config.Port)
end

Data.LoadTables = coroutine.Bind(function()
	local query

	query = MySQL:Create("rp_player_data")
		query:Create("steamid", "VARCHAR(32) NOT NULL", true)
		query:Create("key", "VARCHAR(255) NOT NULL", true)
		query:Create("value", "TEXT NOT NULL")
	query:Execute()

	query = MySQL:Create("rp_characters")
		query:Create("id", "INT(11) NOT NULL AUTO_INCREMENT", true)
		query:Create("steamid", "VARCHAR(32) NOT NULL")
	query:Execute()

	query = MySQL:Create("rp_character_data")
		query:Create("id", "INT(11) NOT NULL", true)
		query:Create("key", "VARCHAR(255) NOT NULL", true)
		query:Create("value", "TEXT NOT NULL")
	query:Execute()

	MySQL:Suppress()
	MySQL:Query("ALTER TABLE rp_character_data ADD CONSTRAINT fk_rp_characters_id FOREIGN KEY (id) REFERENCES rp_characters(id) ON DELETE CASCADE")

	query = MySQL:Create("rp_items")
		query:Create("id", "INT(11) NOT NULL AUTO_INCREMENT", true)
		query:Create("class", "VARCHAR(255) NOT NULL")
		query:Create("store_type", "INT(11) NOT NULL DEFAULT 0")
		query:Create("store_id", "INT(11) NOT NULL DEFAULT 0")
		query:Create("world_map", "VARCHAR(255) NOT NULL DEFAULT ''")
		query:Create("world_position", "VARCHAR(255) NOT NULL DEFAULT '" .. Pack.Default .. "'")
		query:Create("custom_data", "TEXT NOT NULL")
	query:Execute()

	query = MySQL:Create("rp_map_data")
		query:Create("map", "VARCHAR(255) NOT NULL", true)
		query:Create("key", "VARCHAR(255) NOT NULL", true)
		query:Create("value", "TEXT NOT NULL")
	query:Execute()

	hook.Run("PostInitDatabase")
end)

Data.GetMapData = coroutine.Bind(function(key, fallback)
	local query = MySQL:Select("rp_map_data")
		query:Select("value")
		query:WhereEqual("map", game.GetMap())
		query:WhereEqual("key", key)

	local data = query:Execute()[1]

	if data then
		return Pack.Decode(data.value)
	end

	return fallback
end)

Data.SetMapData = coroutine.Bind(function(key, value)
	local query = MySQL:Upsert("rp_map_data")
		query:Insert("map", game.GetMap())
		query:Insert("key", key)
		query:Insert("value", Pack.Encode(value))
	query:Execute()
end)

Data.DeleteMapData = coroutine.Bind(function(key)
	local query = MySQL:Delete("rp_map_data")
		query:WhereEqual("map", game.GetMap())
		query:WhereEqual("key", key)
	query:Execute()
end)

Data.ClearAllMapData = coroutine.Bind(function()
	local query = MySQL:Delete("rp_map_data")
		query:WhereEqual("map", game.GetMap())
	query:Execute()
end)

hook.Add("Initialize", "Data", function()
	Data.Initialize()
end)

function GM:DatabaseConnected()
	Data.LoadTables()
end

function GM:PostInitDatabase()
end
