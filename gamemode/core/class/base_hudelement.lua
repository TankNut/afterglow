CLASS.Name = "Unnamed HUD Element"

CLASS.Optional = false -- Allows disabling (eventually) 
CLASS.Default = false -- Added on Hud.Rebuild

CLASS.DrawOrder = 0

function CLASS:IsValid()
	return Hud.ActiveLookup[self.ID] == self
end

function CLASS:Initialize(ply, ...)
end

function CLASS:OnEvent(event, ...)
end

function CLASS:OnRemove()
end

function CLASS:Paint(ply, w, h)
end

function CLASS:PaintBackground(ply, w, h)
end

-- Helpers

function CLASS:DrawAlignedRect(x, y, w, h, xAlign, yAlign)
	if xAlign == TEXT_ALIGN_CENTER then
		x = x - w * 0.5
	elseif xAlign == TEXT_ALIGN_RIGHT then
		x = x - w
	end

	if yAlign == TEXT_ALIGN_CENTER then
		y = y - h * 0.5
	elseif yAlign == TEXT_ALIGN_BOTTOM then
		y = y - h
	end

	surface.DrawRect(x, y, w, h)
end
