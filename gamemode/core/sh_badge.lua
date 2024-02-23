module("Badge", package.seeall)

local meta = FindMetaTable("Player")

Index = 1
List = List or {}
Lookup = Lookup or {}

function Add(id, name, mat, callback)
	local data = {
		ID = id,
		Name = name,
		Material = Material(mat),
		Callback = callback,
		Automated = tobool(callback)
	}

	List[Index] = data
	Lookup[id] = data

	Index = Index + 1
end

function Get(id)
	return Lookup[id]
end

PlayerVar.Add("CustomBadges", {
	Field = "badges",
	Default = {}
})

function meta:GetBadges()
	local custom = self:GetCustomBadges()
	local badges = {}

	for _, badge in pairs(List) do
		if (badge.Automated and badge.Callback(self)) or custom[badge.ID] then
			table.insert(badges, badge)
		end
	end

	return badges
end

function meta:HasBadge(id)
	local badge = Get(id)

	if badge.Automated then
		return tobool(badge.Callback(self))
	else
		return tobool(self:GetBadges()[id])
	end
end

if SERVER then
	function meta:GiveCustomBadge(id)
		local badge = Get(id)

		if badge.Automated then
			return
		end

		local badges = self:GetCustomBadges()

		badges[id] = true

		self:SetCustomBadges(badges)
	end

	function meta:TakeCustomBadge(id)
		local badge = Get(id)

		if badge.Automated then
			return
		end

		local badges = self:GetCustomBadges()

		badges[id] = nil

		if table.IsEmpty(badges) then
			self:SetCustomBadges(nil)
		else
			self:SetCustomBadges(badges)
		end
	end
end
