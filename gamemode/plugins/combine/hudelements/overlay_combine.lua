CLASS.Name = "Combine Overlay"

CLASS.Optional = false
CLASS.Default = false

CLASS.DrawOrder = 0

function CLASS:Initialize()
	hook.Add("RenderScreenspaceEffects", self, self.DrawOverlay)
end

function CLASS:DrawOverlay()
	DrawMaterialOverlay("effects/combine_binocoverlay", 0)
end
