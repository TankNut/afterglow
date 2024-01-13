function GM:DatabaseConnected()
	Database.LoadTables()
end

function GM:PostInitDatabase()
	Item.LoadWorldItems()
end
