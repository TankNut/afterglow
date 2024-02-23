local usergroup = console.AddCommand("rpa_usergroup_set", function(ply, target, group)
	target:SetRPUserGroup(group)

	console.Feedback(ply, "NOTICE", "You've set %s's usergroup to %s.", target:Nick(), group)
	console.Feedback(target, "NOTICE", "%s has set your usergroup to %s.", ply, group)
end)

usergroup:SetDescription("Sets the user group of another player.")
usergroup:AddParameter(console.Player({
	CheckImmunity = true,
	NoSelfTarget = true,
	SingleTarget = true
}))
usergroup:AddOptional(console.UserGroup({
	CheckImmunity = true,
	NoSelfSelect = true
}), "user")
usergroup:SetAccess(Command.IsSuperAdmin)
