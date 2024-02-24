local give = console.AddCommand("rpa_badge_give", function(ply, targets, badge)
	local name = Badge.Get(badge).Name

	for _, target in pairs(targets) do
		if target:HasBadge(badge) then
			console.Feedback(ply, "ERROR", "%s already has the %s badge.", target:GetCharacterName(), name)

			continue
		end

		target:GiveBadge(badge)

		console.Feedback(ply, "NOTICE", "You've given %s the %s badge.", target:GetCharacterName(), name)
		console.Feedback(target, "NOTICE", "%s has given you the %s badge.", ply, name)
	end
end)

give:SetDescription("Gives someone a scoreboard badge.")
give:AddParameter(console.Player())
give:AddParameter(console.Badge({CustomOnly = true}))
give:SetAccess(Command.IsSuperAdmin)


local take = console.AddCommand("rpa_badge_take", function(ply, targets, badge)
	local name = Badge.Get(badge).Name

	for _, target in pairs(targets) do
		if not target:HasBadge(badge) then
			console.Feedback(ply, "ERROR", "%s doesn't have the %s badge.", target:GetCharacterName(), name)

			continue
		end

		target:TakeBadge(badge)

		console.Feedback(ply, "NOTICE", "You've removed %s's %s badge.", target:GetCharacterName(), name)
		console.Feedback(target, "NOTICE", "%s has removed your %s badge.", ply, name)
	end
end)

take:SetDescription("Takes a scoreboard badge from someone.")
take:AddParameter(console.Player())
take:AddParameter(console.Badge({CustomOnly = true}))
take:SetAccess(Command.IsSuperAdmin)
