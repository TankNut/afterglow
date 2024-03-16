local give = Console.AddCommand("rpa_badge_give", function(ply, targets, badge)
	local name = Badge.Get(badge).Name

	for _, target in pairs(targets) do
		if target:HasBadge(badge) then
			Console.Feedback(ply, "ERROR", "%s already has the %s badge.", target:GetVisibleName(), name)

			continue
		end

		target:GiveBadge(badge)

		Console.Feedback(ply, "NOTICE", "You've given %s the %s badge.", target:GetVisibleName(), name)
		Console.Feedback(target, "NOTICE", "%s has given you the %s badge.", ply, name)
	end
end)

give:SetDescription("Gives someone a scoreboard badge.")
give:AddParameter(Console.Player())
give:AddParameter(Console.Badge({CustomOnly = true}))
give:SetAccess(Command.IsSuperAdmin)

local take = Console.AddCommand("rpa_badge_take", function(ply, targets, badge)
	local name = Badge.Get(badge).Name

	for _, target in pairs(targets) do
		if not target:HasBadge(badge) then
			Console.Feedback(ply, "ERROR", "%s doesn't have the %s badge.", target:GetVisibleName(), name)

			continue
		end

		target:TakeBadge(badge)

		Console.Feedback(ply, "NOTICE", "You've removed %s's %s badge.", target:GetVisibleName(), name)
		Console.Feedback(target, "NOTICE", "%s has removed your %s badge.", ply, name)
	end
end)

take:SetDescription("Takes a scoreboard badge from someone.")
take:AddParameter(Console.Player())
take:AddParameter(Console.Badge({CustomOnly = true}))
take:SetAccess(Command.IsSuperAdmin)
