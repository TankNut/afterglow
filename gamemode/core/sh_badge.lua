module("Badge", package.seeall)

Index = 1
List = List or {}
Lookup = Lookup or {}

function Add(id, name, mat, callback)
	local data = {
		ID = id,
		Name = Name,
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

PlayerVar.Register("Badges", {
	Field = "badges",
	Default = {}
})

local meta = FindMetaTable("Player")

function meta:GetAllBadges()
	local custom = self:GetBadges()
	local badges = {}

	for _, v in pairs(List) do
		if (v.Automated and v.Callback(self)) or custom[v.ID] then
			table.insert(badges, v)
		end
	end

	return badges
end

if SERVER then
	function meta:GiveBadge(id)
		local badge = Get(id)

		if badge.Automated then
			return
		end

		local badges = self:GetBadges()

		badges[id] = true

		self:SetBadges(badges)
	end

	function meta:TakeBadge(id)
		local badge = Get(id)

		if badge.Automated then
			return
		end

		local badges = self:GetBadges()

		badges[id] = nil

		if table.IsEmpty(badges) then
			self:SetBadges(nil)
		else
			self:SetBadges(badges)
		end
	end
end
