local usergroup = console.AddCommand("rpa_setusergroup", function(ply, target, group)
	target:SetRPUserGroup(group)

	console.Feedback(ply, "NOTICE", "You've set %s's usergroup to %s.", target:Nick(), group)
	console.Feedback(target, "NOTICE", "%s has set your usergroup to %s.", ply, group)
end)

usergroup:SetDescription("Sets the user group of another player.")
usergroup:AddParameter(console.Player({
	ForceNick = true,
	CheckImmunity = true,
	NoSelfTarget = true,
	SingleTarget = true
}))
usergroup:AddOptional(console.UserGroup({
	CheckImmunity = true,
	LowerOnly = true
}), "user")
usergroup:SetAccess(Command.IsSuperAdmin)