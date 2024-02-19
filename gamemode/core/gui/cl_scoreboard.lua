local PANEL = {}

function PANEL:Init()
	self:SetSize(620, ScreenScale(200))
	self:DockPadding(0, 50, 0, 0)

	self:MakePopup()
	self:Center()

	self:SetKeyboardInputEnabled(false)

	self.Players = self:Add("DScrollPanel")
	self.Players:Dock(FILL)

	for index, data in pairs(Team.List) do
		if team.NumPlayers(index) == 0 then
			continue
		end

		local hideTeam = hook.Run("ShouldHideTeam", index)

		if hideTeam and not LocalPlayer():IsAdmin() then
			continue
		end

		local players = table.Filter(team.GetPlayers(index), function(_, ply)
			return not hook.Run("ShouldHidePlayer", ply) or LocalPlayer():IsAdmin()
		end)

		if table.IsEmpty(players) then
			continue
		end

		local label = self.Players:Add("DLabel")

		label:SetFont("afterglow.labelgiant")
		label:SetText(hideTeam and data.Name .. " (Hidden)" or data.Name)

		label:SetContentAlignment(4)

		label:DockMargin(10, 10, 0, 10)
		label:Dock(TOP)

		label:SizeToContents()

		self.Players:AddItem(label)

		local count = label:Add("DLabel")

		count:SetFont("afterglow.labelgiant")
		count:SetText(string.format("%s/%s", #players, player.GetCount()))

		count:SetContentAlignment(6)

		count:DockMargin(0, 0, 10, 0)
		count:Dock(RIGHT)

		count:SizeToContents()

		local alt = true

		for _, ply in pairs(players) do
			local entry = self.Players:Add("RPScoreboardEntry")

			entry:Dock(TOP)
			entry:SetTall(60)
			entry:SetPlayer(ply)
			entry:SetAlt(alt)

			self.Players:AddItem(entry)

			alt = not alt
		end
	end
end

function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "Scoreboard", self, w, h)
end

derma.DefineControl("RPScoreboard", "Scoreboard gui", PANEL, "RPBasePanel")

Interface.Register("Scoreboard", function()
	return vgui.Create("RPScoreboard")
end)

function GM:ShouldHideTeam(index)
	return Team.Get(index).Hidden and not LocalPlayer():IsAdmin()
end

function GM:ShouldHidePlayer(ply)
	return false
end
