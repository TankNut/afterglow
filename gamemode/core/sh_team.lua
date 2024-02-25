module("Team", package.seeall)

local meta = FindMetaTable("Player")

List = {}

function Add(name, color, hidden)
	return table.insert(List, {
		Name = name,
		Color = color,
		Hidden = tobool(hidden)
	})
end

function Get(index)
	return List[index]
end

function Find(name)
	name = name:lower()

	for _, data in pairs(List) do
		if string.find(data.Name:lower(), name) then
			return data
		end
	end
end

if SERVER then
	function meta:UpdateTeam()
		self:SetTeam(hook.Run("GetPlayerTeam", self))
	end
end
