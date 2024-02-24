module("Interface", package.seeall)

local meta = FindMetaTable("Player")

if CLIENT then
	Types = Types or {}
	Instances = Instances or {}
	Groups = Groups or {}

	function Register(name, func)
		Types[name] = func
		Instances[name] = Instances[name] or {}
	end

	function Get(name)
		return table.Filter(Instances[name], function(_, v) return IsValid(v) end)
	end

	function GetGroup(group)
		return Groups[group]
	end

	function Open(name, ...)
		local ui = Types[name]
		local panel = ui(...)

		if IsValid(panel) then
			table.insert(Instances[name], panel)
		end

		return panel
	end

	function Close(name)
		for _, v in pairs(Get(name)) do
			v:Remove()
		end

		table.Empty(Instances[name])
	end

	function CloseGroup(group)
		if IsValid(Groups[group]) then
			Groups[group]:Remove()
		end
	end

	function OpenGroup(name, group, ...)
		local existing = Groups[group]

		if IsValid(existing) then
			existing:Remove()
			Groups[group] = nil
		end

		local panel = Open(name, ...)

		if IsValid(panel) then
			Groups[group] = panel
		end

		return panel
	end

	netstream.Hook("OpenInterface", function(payload)
		if payload.Group then
			OpenGroup(payload.Name, payload.Group, unpack(payload.Args))
		else
			Open(payload.Name, unpack(payload.Args))
		end
	end)
else
	function meta:OpenInterface(name, ...)
		netstream.Send("OpenInterface", self, {Name = name, Args = {...}})
	end

	function meta:OpenGroupedInterface(name, group, ...)
		netstream.Send("OpenInterface", self, {Name = name, Group = group, Args = {...}})
	end
end

if CLIENT then
	function GM:ScoreboardShow()
		OpenGroup("Scoreboard", "Scoreboard")
	end

	function GM:ScoreboardHide()
		CloseGroup("Scoreboard")
		Close("BadgeList")
	end
else
	function GM:ShowTeam(ply)
		ply:OpenGroupedInterface("CharacterSelect", "F2")
	end

	function GM:ShowSpare1(ply)
		ply:OpenGroupedInterface("PlayerMenu", "F3")
	end
end
