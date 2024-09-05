CLASS.Name = "Doors"

CLASS.Optional = true
CLASS.Default = true

CLASS.MinRange = 100 * 100
CLASS.MaxRange = 256 * 256

function CLASS:Initialize()
	hook.Add("PostDrawTranslucentRenderables", self, self.DrawDoors)

	self.TraceResult = {}
	self.Trace = {
		filter = {},
		whitelist = true,
		output = self.TraceResult,
		ignoreworld = true
	}
end

function CLASS:GetTextPos(door, reversed)
	local center = door:WorldSpaceCenter()

	self.Trace.endpos = center
	self.Trace.filter[1] = door

	local size = door:OBBMins() - door:OBBMaxs()

	size.x = math.abs(size.x)
	size.y = math.abs(size.y)
	size.z = math.abs(size.z)

	local offset
	local width = 0

	if size.z < size.x and size.z < size.y then
		offset = door:GetUp() * size.z
		width = size.y
	elseif size.x < size.y then
		offset = door:GetForward() * size.x
		width = size.y
	elseif size.y < size.x then
		offset = door:GetRight() * size.y
		width = size.x
	end

	if reverse then
		self.Trace.start = center - offset
	else
		self.Trace.start = center + offset
	end

	util.TraceLine(self.Trace)

	if self.TraceResult.HitWorld then
		if not reversed then
			return self:GetTextPos(door, true)
		else
			return false
		end
	end

	local ang = self.TraceResult.HitNormal:Angle()
	local ang2 = self.TraceResult.HitNormal:Angle()

	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), 90)

	ang2:RotateAroundAxis(ang2:Forward(), 90)
	ang2:RotateAroundAxis(ang2:Right(), -90)

	local len = (center - self.TraceResult.HitPos):Length() + 1

	local pos = center - (len * self.TraceResult.HitNormal)
	local pos2 = center + (len * self.TraceResult.HitNormal)

	return pos, ang, pos2, ang2, math.abs(width)
end

local black = Color(0, 0, 0)

function CLASS:DrawDoors(depth, skybox, skybox3D)
	if skybox or skybox3D or not render.IsDrawingMainView() then
		return
	end

	local eye = EyePos()
	local primaryColor = Hud.Skin.Text.Primary
	local secondaryColor = Hud.Skin.Text.Normal

	surface.SetFont("afterglow.labelworld")

	for door in Door.Iterator() do
		if not IsValid(door) or door:IsDormant() then
			continue
		end

		local title = door:GetDoorValue("Title")
		local subtitle = door:GetDoorValue("Subtitle")

		if title == "" and subtitle == "" then
			continue
		end

		local alpha = math.ClampedRemap(eye:DistToSqr(door:WorldSpaceCenter()), self.MaxRange, self.MinRange, 0, 255)

		if alpha > 0 then
			local pos, ang, pos2, ang2, width = self:GetTextPos(door, reversed)

			if title != "" then
				local w, h = surface.GetTextSize(title)
				local scale = math.min(math.abs((width * 0.6) / w), 0.04)
				local color = ColorAlpha(secondaryColor, alpha)

				cam.Start3D2D(pos, ang, scale)
					draw.SimpleTextOutlined(title, "afterglow.labelworld", 0, -h, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, black)
				cam.End3D2D()

				cam.Start3D2D(pos2, ang2, scale)
					draw.SimpleTextOutlined(title, "afterglow.labelworld", 0, -h, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, black)
				cam.End3D2D()
			end

			if subtitle != "" then
				local w = surface.GetTextSize(subtitle)
				local scale = math.min(math.abs((width * 0.6) / w), 0.02)
				local color = ColorAlpha(primaryColor, alpha)

				cam.Start3D2D(pos, ang, scale)
					draw.SimpleTextOutlined(subtitle, "afterglow.labelworld", 0, 0, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, black)
				cam.End3D2D()

				cam.Start3D2D(pos2, ang2, scale)
					draw.SimpleTextOutlined(subtitle, "afterglow.labelworld", 0, 0, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, black)
				cam.End3D2D()
			end
		end
	end
end
