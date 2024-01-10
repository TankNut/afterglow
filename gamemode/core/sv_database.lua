function GM:DatabaseInitialize()
	local config = self.Config.Database

	mysql:Connect(config.Host, config.Username, config.Password, config.Database, config.Port)
end

function GM:LoadDatabaseTables()
	local query

	query = mysql:Create("rp_player_data")
		query:Create("steamid", "VARCHAR(32) NOT NULL", true)
		query:Create("key", "VARCHAR(255) NOT NULL", true)
		query:Create("value", "TEXT NOT NULL")
	query:Execute()
end

function GM:DatabaseConnected()
	hook.Run("LoadDatabaseTables")
end
