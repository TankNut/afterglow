local give = console.AddCommand("rpa_givelanguage", function(ply, delay)
	timer.Simple(delay, function()
		RunConsoleCommand("changelevel", game.GetMap())
	end)
end)

give:SetDescription("Restarts the current map after a delay.")
give:AddOptional(console.Time({}, "Delay"), 5, "5 seconds")
give:SetAccess(Command.IsAdmin)
