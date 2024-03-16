local set = Console.AddCommand("rpa_template", function(ply, targets, template)
	local data = Template.Get(template)
	local name = data.Name

	for _, target in pairs(targets) do
		local oldName = target:GetVisibleName()

		Template.Load(ply, data)

		Console.Feedback(ply, "NOTICE", "You've spawned %s as a %s.", oldName, name)
		Console.Feedback(target, "NOTICE", "%s has spawned you as a %s.", ply, name)
	end
end)

set:SetDescription("Loads a character template onto someone.")
set:AddParameter(Console.Player())
set:AddParameter(Console.Template())
set:SetAccess(Command.IsAdmin)

local give = Console.AddCommand("rpa_template_give", function(ply, targets, template)
	local name = Template.Get(template).Name

	for _, target in pairs(targets) do
		if target:HasTemplate(template) then
			Console.Feedback(ply, "ERROR", "%s already has access to the %s template.", target:GetVisibleName(), name)

			continue
		end

		target:GiveTemplate(template)

		Console.Feedback(ply, "NOTICE", "You've given %s access to the %s template.", target:GetVisibleName(), name)
		Console.Feedback(target, "NOTICE", "%s has given you access to the %s template.", ply, name)
	end
end)

give:SetDescription("Gives a someone permanent access to a character template.")
give:AddParameter(Console.Player({
	CheckUserGroup = "superadmin" -- Superadmins have access by default
}))
give:AddParameter(Console.Template())
give:SetAccess(Command.IsAdmin)

local take = Console.AddCommand("rpa_template_take", function(ply, targets, template)
	local name = Template.Get(template).Name

	for _, target in pairs(targets) do
		if not target:HasTemplate(template) then
			Console.Feedback(ply, "ERROR", "%s doesn't have access to the %s template.", target:GetVisibleName(), name)

			continue
		end

		target:TakeTemplate(template)

		Console.Feedback(ply, "NOTICE", "You've removed %s's %s template access.", target:GetVisibleName(), name)
		Console.Feedback(target, "NOTICE", "%s has removed your %s template access.", ply, name)
	end
end)

take:SetDescription("Takes character template access from someone.")
take:AddParameter(Console.Player({
	CheckUserGroup = "superadmin" -- Superadmins have access by default
}))
take:AddParameter(Console.Template())
take:SetAccess(Command.IsAdmin)
