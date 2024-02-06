local restart = console.AddCommand("rpa_restart", function(ply)
	RunConsoleCommand("changelevel", game.GetMap())
end)

restart:SetDescription("Restarts the current map.")
restart:SetAccess(Command.IsAdmin)

local restartIn = console.AddCommand("rpa_restart_delayed", function(ply, delay)
	timer.Simple(delay, function()
		RunConsoleCommand("changelevel", game.GetMap())
	end)
end)

restartIn:SetDescription("Restarts the current map after a delay.")
restartIn:AddOptional(console.Time({}, "Delay"), 5, "5 seconds")
restartIn:SetAccess(Command.IsAdmin)
