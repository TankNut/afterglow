function GM:DatabaseConnected()
	database.LoadTables()
end

function GM:PostInitDatabase()
	items.LoadWorldItems()
end
