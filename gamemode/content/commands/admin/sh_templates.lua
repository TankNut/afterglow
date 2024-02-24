local set = console.AddCommand("rpa_template", function(ply, targets, template)
	local data = Template.Get(template)
	local name = data.Name

	for _, target in pairs(targets) do
		local oldName = target:GetCharacterName()

		Template.Load(ply, data)

		console.Feedback(ply, "NOTICE", "You've spawned %s as a %s.", oldName, name)
		console.Feedback(target, "NOTICE", "%s has spawned you as a %s.", ply, name)
	end
end)

set:SetDescription("Loads a character template onto someone.")
set:AddParameter(console.Player())
set:AddParameter(console.Template())
set:SetAccess(Command.IsAdmin)

local give = console.AddCommand("rpa_template_give", function(ply, targets, template)
	local name = Template.Get(template).Name

	for _, target in pairs(targets) do
		if target:HasTemplate(template) then
			console.Feedback(ply, "ERROR", "%s already has access to the %s template.", target:GetCharacterName(), name)

			continue
		end

		target:GiveTemplate(template)

		console.Feedback(ply, "NOTICE", "You've given %s access to the %s template.", target:GetCharacterName(), name)
		console.Feedback(target, "NOTICE", "%s has given you access to the %s template.", ply, name)
	end
end)

give:SetDescription("Gives a someone permanent access to a character template.")
give:AddParameter(console.Player({
	CheckUserGroup = "superadmin" -- Superadmins have access by default
}))
give:AddParameter(console.Template())
give:SetAccess(Command.IsAdmin)

local take = console.AddCommand("rpa_template_take", function(ply, targets, badge)
	local name = Template.Get(template).Name

	for _, target in pairs(targets) do
		if not target:HasTemplate(template) then
			console.Feedback(ply, "ERROR", "%s doesn't have access to the %s template.", target:GetCharacterName(), name)

			continue
		end

		target:TakeTemplate(badge)

		console.Feedback(ply, "NOTICE", "You've removed %s's %s template access.", target:GetCharacterName(), name)
		console.Feedback(target, "NOTICE", "%s has removed your %s template access.", ply, name)
	end
end)

take:SetDescription("Takes character template access from someone.")
take:AddParameter(console.Player({
	CheckUserGroup = "superadmin" -- Superadmins have access by default
}))
take:AddParameter(console.Template())
take:SetAccess(Command.IsAdmin)
