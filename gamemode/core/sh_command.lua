module("Command", package.seeall)

function Load()
	local basePath = engine.ActiveGamemode() .. "/gamemode/content/commands"
	local recursive

	recursive = function(path)
		local files, folders = file.Find(path .. "/*", "LUA")

		for _, v in pairs(files) do
			IncludeFile(path .. "/" .. v)
		end

		for _, v in pairs(folders) do
			recursive(path .. "/" .. v)
		end
	end

	recursive(basePath)
end

function IsAdmin(ply)
	return ply:IsAdmin(), "You need to be an admin to do this."
end

function IsSuperAdmin(ply)
	return ply:IsSuperAdmin(), "You need to be a superadmin to do this."
end

function IsDeveloper(ply)
	return ply:IsDeveloper(), "You need to be a developer to do this."
end

function IsUserGroup(...)
	local usergroups = {...}

	return function(ply)
		for _, group in pairs(usergroups) do
			if ply:CheckUserGroup(group) then
				return true
			end
		end

		return false
	end
end

function FindPlayer(ply, str, options)
	if not str or #str < 1 then
		return false, "No target found."
	end

	str = str:lower()

	local targets = {}

	if str == "^" then -- Target self
		if not IsValid(ply) then
			return false, "Console does not support self-targeting."
		end

		if options.NoSelfTarget then
			return false, "You cannot target yourself."
		end

		targets = {ply}
	elseif str == "-" then -- Lookat
		if not IsValid(ply) then
			return false, "Console does not support look-targeting."
		end

		local ent = ply:GetEyeTrace().Entity

		if IsValid(ent) and ent:IsPlayer() then
			targets = {ent}
		end
	elseif str[1] == "$" then -- Radius
		if not IsValid(ply) then
			return false, "Console does not support radius targeting."
		end

		local radius, targetSelf = str:match("^%$([%d]+)(%+?)$")

		radius = tonumber(radius)
		targetSelf = targetSelf == "+"

		local eye = ply:EyePos()

		if not radius then
			return false, "Invalid radius."
		end

		radius = radius * radius

		for _, target in player.Iterator() do
			if (target != ply or targetSelf) and target:EyePos():DistToSqr(eye) <= radius then
				table.insert(targets, target)
			end
		end
	elseif str[1] == "#" then -- Team
		local name = str:sub(2)
		local data = Team.Find(name)

		if not data then
			return false, "Invalid team."
		end

		targets = team.GetPlayers(data.Index)
	elseif str == "@@" then
		targets = player.GetAll()
	else -- Match by name
		local multi = str[1] == "@"

		if multi then
			str = str:sub(2)
		end

		for _, target in player.Iterator() do
			if target:HasCharacter() and string.find(target:GetCharacterName():lower(), str, 1, not multi) then
				table.insert(targets, target)

				continue
			end

			if (not IsValid(ply) or ply:IsAdmin()) and string.find(target:Nick():lower(), str, 1, not multi) then
				table.insert(targets, target)

				continue
			end
		end
	end

	-- Don't allow us to target people that have our usergroup (e.g. admins cannot target admins/superadmins)
	if options.CheckImmunity and IsValid(ply) then
		local usergroup = ply:GetUserGroup()

		targets = table.Filter(targets, function(_, target)
			return not target:CheckUserGroup(usergroup)
		end)
	end

	-- Filter out anyone that matches this usergroup (e.g. no admins)
	if options.CheckUserGroup then
		targets = table.Filter(targets, function(_, target)
			return not target:CheckUserGroup(options.CheckUserGroup)
		end)
	end

	-- Remove ourselves from the target list
	if options.NoSelfTarget and IsValid(ply) then
		targets = table.Filter(targets, function(_, target)
			return target != ply
		end)
	end

	if table.IsEmpty(targets) then
		return false, "No target found."
	elseif (not multi or options.SingleTarget) and #targets > 1 then
		return false, "Multiple target matches."
	end

	if options.SingleTarget then
		return true, targets[1]
	end

	return true, targets
end
