module("Interface", package.seeall)

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
			Open(payload.Name, payload.Group, unpack(payload.Args))
		end
	end)
else
	local meta = FindMetaTable("Player")

	function meta:OpenInterface(name, ...)
		netstream.Send(ply, "OpenInterface", {Name = name, Args = {...}})
	end

	function meta:OpenGroupedInterface(name, group, ...)
		netstream.Send(ply, "OpenInterface", {Name = name, Group = group, Args = {...}})
	end
end