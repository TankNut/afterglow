local restart = console.AddCommand("rpa_restart", function(ply, delay)
	if delay == 0 then
		RunConsoleCommand("changelevel", game.GetMap())
	else
		Chat.Send("ADMINYELL", string.format("%s is restarting the server in %s", console.PlayerName(ply), string.NiceTime(delay)))

		timer.Simple(delay, function()
			RunConsoleCommand("changelevel", game.GetMap())
		end)
	end
end)

restart:SetDescription("Restarts the current map.")
restart:AddOptional(console.Time({}, "Delay"), 5, "5 seconds")
restart:SetAccess(Command.IsAdmin)
