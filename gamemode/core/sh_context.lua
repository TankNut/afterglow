module("Context", package.seeall)

local meta = FindMetaTable("Player")

function Add(name, data)
	if not Current then
		return
	end

	Current[name] = {
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
	function OpenMenu()
		Current = {}

		LocalPlayer():GetContextOptions()

		local options = Current

		Current = nil

		Menu = DermaMenu()
		Menu:SetSkin("Afterglow")

		BuildMenu(options)

		gui.EnableScreenClicker(true)

		Menu:Open()
	end

	function BuildMenu(options)
		local sections = {}

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
				Menu:AddSpacer()
			end

			for _, data in pairs(sectionOptions) do
				local callback = function(value)
					gui.EnableScreenClicker(false)

					if data.Client then
						coroutine.wrap(function()
							local val = data.Client(value)

							if val != nil then
								netstream.Send("ContextOption", {
									ID = data.ID,
									Value = val
								})
							end
						end)()
					else
						netstream.Send("ContextOption", {
							ID = data.ID,
							Value = value
						})
					end
				end

				if data.SubMenu then
					local subMenu = Menu:AddSubMenu(data.Name)

					data.SubMenu(subMenu, callback)
				else
					Menu:AddOption(data.Name, callback)
				end
			end
		end
	end

	function CloseMenu()
		if IsValid(Menu) then
			Menu:Remove()
		end

		Menu = nil

		gui.EnableScreenClicker(false)
	end
end

if CLIENT then
	hook.Add("OnContextMenuOpen", "Context", function()
		if hook.Run("ShouldOpenContextMenu", LocalPlayer()) then
			OpenMenu()

			return true
		end
	end)

	hook.Add("OnContextMenuClose", "Context", function()
		CloseMenu()
	end)
end

function meta:GetContextOptions()
	Add("test", {
		Name = "Test Option",
		Client = function()
			print("Test!")
		end
	})
end
