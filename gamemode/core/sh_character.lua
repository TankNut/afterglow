CHARACTER_NONE = 0

Character = Character or {}
Character.Vars = Character.Vars or {}

local meta = FindMetaTable("Player")

function Character.AddVar(key, data)
	Character.Vars[key] = data

	data.Key = "C_" .. key:FirstToUpper()
	data.Accessor = data.Accessor or ("Character" .. key:FirstToUpper())
	data.Field = data.Field or key:lower()

	if data.ServerOnly then
		if CLIENT then
			return
		end

		meta["Get" .. data.Accessor] = function(ply)
			if not ply.CharacterData then
				return data.Default
			end

			local val = ply.CharacterData[data.Key]

			if val == nil then
				val = data.Default
			end

			return data.Get and data.Get(ply, val) or val
		end

		meta["Set" .. data.Accessor] = function(ply, value, noSave)
			ply.CharacterData = ply.CharacterData or {}

			local old = ply.CharacterData[data.Key]

			-- Since defaults are pre-defined, we can replace nil with it
			local callValue = value != nil and value or data.Default

			ply.CharacterData[data.Key] = value

			if data.Callback then
				data.Callback(ply, old, callValue)
			end

			if not noSave then
				-- Write nil here to keep the database clean
				Character.SaveVar(ply:GetCharID(), data.Field, value)
			end

			hook.Run("On" .. data.Accessor .. "Changed", ply, old, callValue)
		end
	else
		meta["Get" .. data.Accessor] = function(ply)
			local val = ply:GetNetvar(data.Key, data.Default)

			return data.Get and data.Get(ply, val) or val
		end

		if SERVER then
			local func = data.Private and "SetPrivateNetvar" or "SetNetvar"

			meta["Set" .. data.Accessor] = function(ply, value, noSave)
				local old = ply:GetNetvar(data.Key, data.Default)

				-- Since defaults are pre-defined, we can replace nil with it
				local callValue = value != nil and value or data.Default

				ply[func](ply, data.Key, value)

				if data.Callback then
					data.Callback(ply, old, callValue)
				end

				if not noSave then
					-- Write nil here to keep the database clean
					Character.SaveVar(ply:GetCharID(), data.Field, value)
				end

				hook.Run("On" .. data.Accessor .. "Changed", ply, old, callValue)
			end
		end

		if CLIENT then
			Netvar.AddEntityHook(data.Key, "CharacterVar", function(ply, old, value)
				local callValue = value != nil and value or data.Default

				if data.Callback then
					data.Callback(ply, old, callValue)
				end

				hook.Run("On" .. data.Accessor .. "Changed", ply, old, callValue)
			end)
		end
	end
end

function Character.Find(id)
	for _, v in player.Iterator() do
		if v:GetCharID() == id then
			return v
		end
	end
end

function Character.VarToField(var)
	var = Character.Vars[var]

	if var then
		return var.Field
	end
end

function Character.GetRules()
	local rules = hook.Run("GetBaseCharacterRules")

	hook.Run("ModifyCharacterRules", rules)

	return rules
end

function meta:HasCharacter()
	return self:GetCharID() != CHARACTER_NONE
end

function meta:IsTemplateCharacter()
	return self:GetCharID() < CHARACTER_NONE
end

PlayerVar.Add("CharID", {
	Default = CHARACTER_NONE,
	Callback = function(ply, old, new)
		if CLIENT and ply == LocalPlayer() and new != CHARACTER_NONE then
			Interface.CloseGroup("F2")
		end
	end
})

PlayerVar.Add("CharacterList", {
	Private = true,
	Default = {},
	Callback = function(ply, old, new)
		if CLIENT and (not ply:HasCharacter() or IsValid(Interface.Get("CharacterSelect")[1])) then
			Interface.OpenGroup("CharacterSelect", "F2")
		end
	end
})
