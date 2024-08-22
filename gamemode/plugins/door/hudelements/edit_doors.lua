CLASS.Name = "Doors"

CLASS.Optional = true

CLASS.BoxSize = Vector(0.1, 0.1, 0.1)

CLASS.GroupColor = Color(0, 120, 0)
CLASS.BuyColor = Color(255, 255, 100)

function CLASS:ShouldAddElement(ply)
	return ply:IsAdmin()
end

function CLASS:Initialize()
	hook.Add("PostDrawTranslucentRenderables", self, self.DrawDoors)
end

function CLASS:DrawGroups(groups, color)
	for group, positions in pairs(groups) do
		if #positions <= 1 then
			continue
		end

		local pos = Vector()

		for _, vec in pairs(positions) do
			pos:Add(vec)
		end

		pos:Div(#positions)

		render.DepthRange(0, 0)
			for _, vec in pairs(positions) do
				render.DrawLine(vec, pos, color, true)
			end

			render.DrawBox(pos, Angle(), Vector(-1, -1, -1) * 5, Vector(1, 1, 1) * 5, ColorAlpha(color, 100), true)
		render.DepthRange(0, 1)
	end
end

function CLASS:DrawDoors(depth, skybox, skybox3D)
	if skybox or skybox3D or not render.IsDrawingMainView() then
		return
	end

	if not LocalPlayer():GetEditMode() then
		return
	end

	render.SetColorMaterial()

	local groups = {}
	local buyGroups = {}

	for door, class in Door.Iterator() do
		if not IsValid(door) then
			continue
		end

		local group = door:GetDoorValue("Group")

		if group != "" then
			groups[group] = groups[group] or {}

			table.insert(groups[group], door:WorldSpaceCenter())
		end

		local buyGroup = door:GetDoorValue("BuyGroup")

		if buyGroup != "" then
			buyGroups[buyGroup] = buyGroups[buyGroup] or {}

			table.insert(buyGroups[buyGroup], door:WorldSpaceCenter())
		end

		if door:IsDormant() then
			continue
		end

		local color = Door.GetAccessType(door).Color

		render.DrawBox(door:GetPos(), door:GetAngles(),
			door:OBBMins() - self.BoxSize,
			door:OBBMaxs() + self.BoxSize,
			ColorAlpha(color, 50))
	end

	self:DrawGroups(groups, self.GroupColor)
	self:DrawGroups(buyGroups, self.BuyColor)
end
