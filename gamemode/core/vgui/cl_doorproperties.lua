local PANEL = {}

function PANEL:Setup(door)
	self.Door = door
	self:Rebuild()
end

function PANEL:Rebuild()
	self:Clear()

	local door = self.Door

	if not IsValid(door) or not door:IsDoor() then
		return
	end

	for key, data in SortedPairsByMemberValue(Door.Vars, "Order") do
		self:AddVar(key, data)
	end
end

function PANEL:AddVar(key, data)
	local edit = data.Edit
	local door = self.Door

	if not edit then
		return
	end

	if data.NoProp and door:IsPropDoor() then
		return
	end

	edit = table.Copy(edit)

	data.PreEdit(door, edit)

	local row = self:CreateRow(edit.category or "General", edit.title)

	row:Setup(edit.type, edit)

	row.DataUpdate = function()
		if not IsValid(door) then
			self:Remove()

			return
		end

		row:SetValue(door:GetDoorValue(key))
	end

	row.DataChanged = function(_, val)
		if not IsValid(door) then
			self:Remove()

			return
		end

		Netstream.Send("SetDoorProperty", {
			Door = door,
			Key = key,
			Value = val
		})
	end
end

derma.DefineControl("RPDoorProperties", "Custom scroll panel for chat drawing", PANEL, "DProperties")
