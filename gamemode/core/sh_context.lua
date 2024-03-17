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
		local options = LocalPlayer():GetContextOptions()

		Context.Menu = DermaMenu()
		Context.Menu:SetSkin("Afterglow")

		Context.BuildMenu(options)

		gui.EnableScreenClicker(true)

		Context.Menu:Open()
	end

	function Context.BuildMenu(options)
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
			table.SortByMember(sectionOptions, "Order")

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
									Value = val
								})
							end
						end)()
					else
						Netstream.Send("ContextOption", {
							ID = data.ID,
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

function meta:GetContextOptions()
	local options = {}

	Context.Current = options

	hook.Run("GetContextOptions", self)

	Context.Current = nil

	return options
end

function GM:GetContextOptions(ply, ent)
	Context.Add("test", {
		Name = "Test Option",
		Client = function()
			print("Test!")
		end
	})
end
