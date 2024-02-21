local PANEL = {}

AccessorFunc(PANEL, "Player", "Player")
AccessorFunc(PANEL, "Alt", "Alt")
AccessorFunc(PANEL, "Hidden", "Hidden")

function PANEL:Init()
	self.Icon = self:Add("RPPlayerView")

	self.BadgeButton = self:Add("DButton")
	self.BadgeButton:Dock(RIGHT)
	self.BadgeButton:SetText("")
	self.BadgeButton.Paint = function() end

	self.ExamineButton = self:Add("DButton")
	self.ExamineButton:Dock(FILL)
	self.ExamineButton:SetText("")
	self.ExamineButton.Paint = function() end
end

function PANEL:PerformLayout(w, h)
	self.Icon:SetPos(1, 1)
	self.Icon:SetSize(h - 2, h - 2)

	local buttonWidth = 0
	local ply = self.Player

	if IsValid(ply) then
		local nameWidth = surface.GetFontSize("afterglow.labelsmall", ply:Nick())

		buttonWidth = math.max(buttonWidth, nameWidth + 40)
		buttonWidth = math.max(buttonWidth, (#self.Badges * 18) + 28)
	end

	self.BadgeButton:SetWide(buttonWidth)
end

function PANEL:SetPlayer(ply)
	self.Player = ply
	self.Icon:SetPlayer(ply)
	self.Hidden = hook.Run("ShouldHidePlayer", ply)
	self.Badges = ply:GetBadges()

	self:InvalidateLayout()
end

function PANEL:Paint(w, h)
	derma.SkinHook("Paint", "ScoreboardEntry", self, w, h)
end

derma.DefineControl("RPScoreboardEntry", "A single scoreboard entry", PANEL, "DPanel")
