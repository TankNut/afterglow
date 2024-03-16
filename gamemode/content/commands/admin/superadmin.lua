local usergroup = Console.AddCommand("rpa_usergroup_set", function(ply, target, group)
	target:SetRPUserGroup(group)

	Console.Feedback(ply, "NOTICE", "You've set %s's usergroup to %s.", target:Nick(), group)
	Console.Feedback(target, "NOTICE", "%s has set your usergroup to %s.", ply, group)
end)

usergroup:SetDescription("Sets someone's usergroup.")
usergroup:AddParameter(Console.Player({
	CheckImmunity = true,
	NoSelfTarget = true,
	SingleTarget = true
}))
usergroup:AddOptional(Console.UserGroup({
	CheckImmunity = true,
	NoSelfSelect = true
}), "user")
usergroup:SetAccess(Command.IsSuperAdmin)
