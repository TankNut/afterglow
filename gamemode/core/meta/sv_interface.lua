local meta = FindMetaTable("Player")


function meta:OpenInterface(name, ...)
	netstream.Send("OpenInterface", self, {Name = name, Args = {...}})
end


function meta:OpenGroupedInterface(name, group, ...)
	netstream.Send("OpenInterface", self, {Name = name, Group = group, Args = {...}})
end
