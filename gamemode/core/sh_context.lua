Context = Context or {}

local meta = FindMetaTable("Player")

function Context.Add(name, data)
	if not Context.Current then
		return
	end

	Context.Current[name] = {
		ID = name,
		Name = data.Name or "Unnamed Option",
		Section = data.Section or 0,
		Order = data.Order or 0,
		SubMenu = data.SubMenu,
		Client = data.Client,
		Callback = data.Callback
	}
end

if CLIENT then
	function Context.OpenMenu()
		local options, ent = LocalPlayer():GetContextOptions()

		if table.Count(options) < 1 then
			return
		end

		Context.Menu = DermaMenu()
		Context.Menu:SetSkin("Afterglow")

		Context.BuildMenu(options, ent)

		gui.EnableScreenClicker(true)

		Context.Menu:Open()
	end

	function Context.BuildMenu(options, ent)
		local sections = {}
		local menu = Context.Menu

		for _, data in pairs(options) do
			if not sections[data.Section] then
				sections[data.Section] = {}
			end

			table.insert(sections[data.Section], data)
		end

		local first = true

		for _, sectionOptions in pairs(sections) do
			table.SortByMember(sectionOptions, "Order", true)

			if first then
				first = false
			else
				menu:AddSpacer()
			end

			for _, data in pairs(sectionOptions) do
				local callback = function(value)
					gui.EnableScreenClicker(false)

					if data.Client then
						coroutine.wrap(function()
							local val = data.Client(value)

							if val != nil then
								Netstream.Send("ContextOption", {
									ID = data.ID,
									Entity = ent,
									Value = val
								})
							end
						end)()
					else
						Netstream.Send("ContextOption", {
							ID = data.ID,
							Entity = ent,
							Value = value
						})
					end
				end

				if data.SubMenu then
					local subMenu = menu:AddSubMenu(data.Name)

					data.SubMenu(subMenu, callback)
				else
					menu:AddOption(data.Name, callback)
				end
			end
		end
	end

	function Context.CloseMenu()
		if IsValid(Context.Menu) then
			Context.Menu:Remove()
		end

		Context.Menu = nil

		gui.EnableScreenClicker(false)
	end
else
	Netstream.Hook("ContextOption", function(ply, payload)
		local options = ply:GetContextOptions(payload.Entity)

		for key, option in pairs(options) do
			if key == payload.ID then
				option.Callback(payload.Value)
			end
		end
	end)
end

if CLIENT then
	hook.Add("OnContextMenuOpen", "Context", function()
		if hook.Run("ShouldOpenContextMenu", LocalPlayer()) then
			Context.OpenMenu()

			return true
		end
	end)

	hook.Add("OnContextMenuClose", "Context", function()
		Context.CloseMenu()
	end)
end

if CLIENT then
	function meta:GetContextEntity()
		local range = Config.Get("ContextRange")

		local origin = self:EyePos()
		local tab = table.Filter(ents.FindInSphere(origin, range), function(_, ent)
			return not ent:IsDormant() and ent:GetCollisionGroup() == COLLISION_GROUP_IN_VEHICLE
		end)

		table.sort(tab, function(a, b)
			return a:WorldSpaceCenter():DistToSqr(origin) > b:WorldSpaceCenter():DistToSqr(origin)
		end)

		local dir = self:EyeAngles():Forward() * range

		for _, ent in pairs(tab) do
			local hit = util.IntersectRayWithOBB(origin, dir, ent:GetPos(), ent:GetAngles(), ent:OBBMins(), ent:OBBMaxs())

			if hit then
				return ent
			end
		end

		local ent = self:GetEyeTrace().Entity

		if hook.Run("IsValidContextEntity", self, ent) then
			return ent
		end
	end
end

function meta:GetContextOptions(ent)
	if CLIENT then
		ent = self:GetContextEntity()
	end

	local options = {}

	Context.Current = options

	hook.Run("GetContextOptions", self)

	if IsValid(ent) then
		hook.Run("GetEntityContextOptions", self, ent, ent:WithinRange(self, Config.Get("InteractRange")))
	end

	Context.Current = nil

	return options, ent
end
