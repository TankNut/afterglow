CLASS.Name = "Doors"

CLASS.Optional = true

CLASS.BoxSize = Vector(0.1, 0.1, 0.1)

function CLASS:ShouldAddElement(ply)
	return ply:IsAdmin()
end

function CLASS:Initialize()
	hook.Add("PostDrawTranslucentRenderables", self, self.DrawDoors)
end

function CLASS:DrawDoors(depth, skybox, skybox3D)
	if skybox or skybox3D or not render.IsDrawingMainView() then
		return
	end

	if not LocalPlayer():GetEditMode() then
		return
	end

	render.SetColorMaterial()

	for door, class in Door.Iterator() do
		if not IsValid(door) or door:IsDormant() then
			continue
		end

		render.DrawBox(door:GetPos(), door:GetAngles(),
			door:OBBMins() - self.BoxSize,
			door:OBBMaxs() + self.BoxSize,
			ColorAlpha(Color(255, 0, 0), 50))
	end
end
