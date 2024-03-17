Interface = Interface or {}

local meta = FindMetaTable("Player")

if CLIENT then
	Interface.Types = Interface.Types or {}
	Interface.Instances = Interface.Instances or {}
	Interface.Groups = Interface.Groups or {}

	function Interface.Register(name, func)
		Interface.Types[name] = func
		Interface.Instances[name] = Interface.Instances[name] or {}
	end

	function Interface.Get(name)
		return table.Filter(Interface.Instances[name], function(_, v) return IsValid(v) end)
	end

	function Interface.GetGroup(group)
		return Interface.Groups[group]
	end

	function Interface.Open(name, ...)
		local ui = Interface.Types[name]
		local panel = ui(...)

		if IsValid(panel) then
			table.insert(Interface.Instances[name], panel)
		end

		return panel
	end

	function Interface.Close(name)
		for _, v in pairs(Interface.Get(name)) do
			v:Remove()
		end

		table.Empty(Interface.Instances[name])
	end

	function Interface.CloseGroup(group)
		if IsValid(Interface.Groups[group]) then
			Interface.Groups[group]:Remove()
		end
	end

	function Interface.OpenGroup(name, group, ...)
		local existing = Interface.Groups[group]

		if IsValid(existing) then
			existing:Remove()
			Interface.Groups[group] = nil
		end

		local panel = Interface.Open(name, ...)

		if IsValid(panel) then
			Interface.Groups[group] = panel
		end

		return panel
	end

	Netstream.Hook("OpenInterface", function(payload)
		if payload.Group then
			Interface.OpenGroup(payload.Name, payload.Group, unpack(payload.Args))
		else
			Interface.Open(payload.Name, unpack(payload.Args))
		end
	end)
end

if SERVER then
	function meta:OpenInterface(name, ...)
		Netstream.Send("OpenInterface", self, {Name = name, Args = {...}})
	end

	function meta:OpenGroupedInterface(name, group, ...)
		Netstream.Send("OpenInterface", self, {Name = name, Group = group, Args = {...}})
	end
end

if CLIENT then
	function GM:ScoreboardShow()
		Interface.OpenGroup("Scoreboard", "Scoreboard")
	end

	function GM:ScoreboardHide()
		Interface.CloseGroup("Scoreboard")
		Interface.Close("BadgeList")
	end
end

if SERVER then
	function GM:ShowTeam(ply)
		ply:OpenGroupedInterface("CharacterSelect", "F2")
	end

	function GM:ShowSpare1(ply)
		ply:OpenGroupedInterface("PlayerMenu", "F3")
	end
end
