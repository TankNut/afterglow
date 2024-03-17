Badge = Badge or {}

Badge.Index = 1
Badge.List = Badge.List or {}
Badge.Lookup = Badge.Lookup or {}

local meta = FindMetaTable("Player")

PlayerVar.Add("CustomBadges", {
	Field = "badges",
	Default = {}
})

function Badge.Add(id, name, mat, callback)
	local data = {
		ID = id,
		Name = name,
		Material = Material(mat),
		Callback = callback,
		Automated = tobool(callback)
	}

	Badge.List[Badge.Index] = data
	Badge.Lookup[id] = data

	Badge.Index = Badge.Index + 1
end

function Badge.Get(id)
	return Badge.Lookup[id]
end

function meta:GetBadges()
	local custom = self:GetCustomBadges()
	local badges = {}

	for _, badge in pairs(Badge.List) do
		if (badge.Automated and badge.Callback(self)) or custom[badge.ID] then
			table.insert(badges, badge)
		end
	end

	return badges
end

function meta:HasBadge(id)
	local badge = Badge.Get(id)

	if badge.Automated then
		return tobool(badge.Callback(self))
	else
		return tobool(self:GetBadges()[id])
	end
end

if SERVER then
	function meta:GiveBadge(id)
		local badge = Badge.Get(id)

		if badge.Automated then
			return
		end

		local badges = self:GetCustomBadges()

		badges[id] = true

		self:SetCustomBadges(badges)
	end

	function meta:TakeBadge(id)
		local badge = Badge.Get(id)

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
