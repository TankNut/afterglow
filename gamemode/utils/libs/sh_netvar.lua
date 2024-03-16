local autofill = {
	__index = function(tab, key)
		tab[key] = {}

		return tab[key]
	end
}

Netvar = Netvar or {}

Netvar.Globals = Netvar.Globals or {}
Netvar.Entities = Netvar.Entities or {}

Netvar.GlobalHooks = Netvar.GlobalHooks or setmetatable({}, autofill)
Netvar.EntityHooks = Netvar.EntityHooks or setmetatable({}, autofill)

local writeLog = Log.Category("Netvar")

local function writePayload(payload, key, value)
	if value == nil then
		payload[TYPE_NIL] = payload[TYPE_NIL] or {}
		table.insert(payload[TYPE_NIL], key)
	else
		payload[key] = value
	end

	return payload
end

local function readPayload(payload, callback)
	for key, value in pairs(payload) do
		if key == TYPE_NIL then
			for _, nilKey in pairs(value) do
				callback(nilKey, nil)
			end
		else
			callback(key, value)
		end
	end
end

function Netvar.Get(key, default)
	key = tostring(key)

	if Netvar.Globals[key] != nil then
		return Netvar.Globals[key]
	end

	return default
end

if CLIENT then
	Netstream.Hook("Netvar", function(payload)
		readPayload(payload, function(key, value)
			local old = Netvar.Globals[key]

			Netvar.Globals[key] = value

			writeLog("Global: %s (%s -> %s)", key, old, value)
			hook.Run("GlobalNetvarChanged", key, old, value)
		end)
	end)

	hook.Add("InitPostEntity", "Netvar", function()
		writeLog("Sync Request: Globals")
		Netstream.Send("Netvar")
	end)
end

if SERVER then
	function Netvar.Set(key, value)
		local old = Netvar.Globals[key]

		if old == value and not istable(value) then
			return
		end

		Netvar.Globals[key] = value

		writeLog("Global: %s (%s -> %s)", key, old, value)
		hook.Run("GlobalNetvarChanged", key, old, value)

		Netstream.Broadcast("Netvar", {writePayload({}, key, value)})
	end

	Netstream.Hook("Netvar", function(ply)
		writeLog("Global Sync Request from %s", ply)

		if table.Count(Netvar.Globals) > 0 then
			Netstream.Send("Netvar", ply, Netvar.Globals)
		end
	end)
end

local function getEntry(ent)
	local index = ent:EntIndex()
	local entry = Netvar.Entities[index]

	if not entry then
		entry = {}
		Netvar.Entities[index] = entry

		if SERVER then
			ent:SetNWBool("NetvarActive", true)
		end
	end

	return entry
end

function Netvar.GetEntity(ent, key, default)
	local tab = Netvar.Entities[ent:EntIndex()]

	if not tab or tab[key] == nil then
		return default
	end

	if CLIENT then
		return tab[key]
	else
		return tab[key].Value != nil and tab[key].Value or default
	end
end

if CLIENT then
	Netstream.Hook("NetvarEntity", function(payload)
		for index, data in pairs(payload) do
			local ent = Entity(index)

			readPayload(data, function(key, value)
				local entry = getEntry(ent)
				local old = entry[key]

				entry[key] = value

				writeLog("%s: '%s' (%s -> %s)", ent, key, old, value)
				hook.Run("EntityNetvarChanged", ent, key, old, value)
			end)
		end
	end)

	Netvar.SyncCache = Netvar.SyncCache or {}

	hook.Add("NetworkEntityCreated", "Netvar", function(ent)
		if ent == LocalPlayer() then
			return
		end

		if ent:GetNWBool("NetvarActive", false) then
			Netvar.SyncCache[ent] = true
		end
	end)

	hook.Add("NotifyShouldTransmit", "Netvar", function(ent, should)
		if ent:IsPlayer() or not should or not ent:GetNWBool("NetvarActive", false) then
			return
		end

		if ent == LocalPlayer() then
			return
		end

		Netvar.SyncCache[ent] = true
	end)

	hook.Add("Tick", "Netvar", function()
		local count = table.Count(Netvar.SyncCache)

		if count > 0 then
			writeLog("Sync Request: %s %s", count, count > 1 and "entities" or "entity")

			Netstream.Send("NetvarEntity", table.GetKeys(Netvar.SyncCache))
			table.Empty(Netvar.SyncCache)
		end
	end)
end

if SERVER then
	function Netvar.SetEntity(ent, key, value, private)
		local entry = getEntry(ent)

		if not entry[key] then
			entry[key] = {
				ChangeNumber = 0,
				Clients = {}
			}
		end

		local data = entry[key]
		local old = data.Value

		data.ChangeNumber = data.ChangeNumber + 1
		data.Private = tobool(private and ent:IsPlayer())
		data.Value = value

		writeLog("%s:%s '%s' (%s -> %s)", ent, private and " PRIVATE" or "", key, old, value)
		hook.Run("EntityNetvarChanged", ent, key, old, value)

		Netvar.UpdateEntity(ent, key)
	end

	function Netvar.SyncEntities(ply, entList)
		writeLog("Sync Request for %s %s from %s", #entList > 1 and #entList or entList[1], #entList > 1 and "entities" or "", ply)

		local payload = {}
		local userID = ply:UserID()

		for _, ent in pairs(entList) do
			local index = ent:EntIndex()
			local entry = Netvar.Entities[index]

			if not entry then
				continue
			end

			-- Player should always be aware of it's own data, no reason to try and sync them
			if ply == ent then
				return
			end

			local entPayload = {}

			for key, data in pairs(entry) do
				-- Only sync fields we're behind on
				if data.Clients[userID] == data.ChangeNumber then
					continue
				end

				writePayload(entPayload, key, data.Value)
				data.Clients[userID] = data.ChangeNumber
			end

			if table.Count(entPayload) > 0 then
				payload[index] = entPayload
			end
		end

		if table.Count(payload) > 0 then
			Netstream.Send("NetvarEntity", ply, payload)
		end
	end

	function Netvar.UpdateEntity(ent, key)
		local index = ent:EntIndex()

		local entry = Netvar.Entities[index][key]
		local receivers = RecipientFilter()

		if entry.Private then
			receivers:AddPlayer(ent)
		elseif ent:IsPlayer() then
			receivers:AddAllPlayers()
		else
			receivers:AddPVS(ent:GetPos())
		end

		for _, v in pairs(receivers:GetPlayers()) do
			entry.Clients[v:UserID()] = entry.ChangeNumber
		end

		Netstream.Send("NetvarEntity", receivers, {[index] = writePayload({}, key, entry.Value)})
	end

	Netstream.Hook("NetvarEntity", Netvar.SyncEntities)
end

hook.Add("EntityRemoved", "Netvar", function(ent, fullUpdate)
	if fullUpdate then
		return
	end

	local index = ent:EntIndex()

	if index > 0 and Netvar.Entities[index] then
		writeLog("%s removed", ent)

		Netvar.Entities[index] = nil

		if CLIENT then
			Netvar.SyncCache[ent] = nil
		end
	end
end)

function Netvar.AddGlobalHook(key, identifier, callback)
	Netvar.GlobalHooks[key][identifier] = callback
end

function Netvar.RemoveGlobalHook(key, identifier)
	Netvar.GlobalHooks[key][identifier] = nil
end

function Netvar.AddEntityHook(key, identifier, callback)
	Netvar.EntityHooks[key][identifier] = callback
end

function Netvar.RemoveEntityHook(key, identifier, callback)
	Netvar.EntityHooks[key][identifier] = nil
end

function GM:GlobalNetvarChanged(key, old, value)
	for identifier, callback in pairs(Netvar.GlobalHooks[key]) do
		if isstring(identifier) then
			callback(old, value)
		else
			if IsValid(identifier) then
				callback(old, value)
			else
				Netvar.GlobalHooks[key][identifier] = nil
			end
		end
	end
end

function GM:EntityNetvarChanged(ent, key, old, value)
	local name = "On" .. key .. "Changed"

	if isfunction(ent[name]) then
		ent[name](ent, key, old, value)
	end

	for identifier, callback in pairs(Netvar.EntityHooks[key]) do
		if isstring(identifier) then
			callback(ent, old, value)
		else
			if IsValid(identifier) and ent == identifier then
				callback(ent, old, value)
			else
				Netvar.EntityHooks[key][identifier] = nil
			end
		end
	end
end

local entMeta = FindMetaTable("Entity")
local plyMeta = FindMetaTable("Player")

function entMeta:GetNetvar(key, fallback)
	return Netvar.GetEntity(self, key, fallback)
end

if SERVER then
	function entMeta:SetNetvar(key, val)
		Netvar.SetEntity(self, key, val)
	end

	function plyMeta:SetPrivateNetvar(key, val)
		Netvar.SetEntity(self, key, val, true)
	end
end
