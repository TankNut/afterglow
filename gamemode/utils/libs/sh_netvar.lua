module("netvar", package.seeall)

local autofill = {
	__index = function(tbl, key)
		tbl[key] = {}

		return tbl[key]
	end
}

local writeLog = log.Category("netvar")

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

-- Global vars

Globals = Globals or {}

function Get(key, default)
	key = tostring(key)

	if Globals[key] != nil then
		return Globals[key]
	end

	return default
end

if CLIENT then
	netstream.Hook("NetVar", function(payload)
		readPayload(payload, function(key, value)
			local old = Globals[key]

			Globals[key] = value

			writeLog("Global: %s (%s -> %s)", key, old, value)
			hook.Run("GlobalNetVarChanged", key, old, value)
		end)
	end)

	hook.Add("InitPostEntity", "netvar", function()
		writeLog("Sync Request: Globals")
		netstream.Send("NetVar")
	end)
else
	function Set(key, value)
		key = tostring(key)

		local old = Globals[key]

		Globals[key] = value

		writeLog("Global: %s (%s -> %s)", key, old, value)
		hook.Run("GlobalNetVarChanged", key, old, value)

		netstream.Broadcast("NetVar", {writePayload({}, key, value)})
	end

	netstream.Hook("NetVar", function(ply)
		writeLog("Global Sync Request from %s", ply)

		if table.Count(Globals) > 0 then
			netstream.Send(ply, "NetVar", Globals)
		end
	end)
end

-- Entity vars

Entities = Entities or {}

local function GetEntry(ent)
	local index = ent:EntIndex()
	local entry = Entities[index]

	if not entry then
		entry = {}
		Entities[index] = entry

		if SERVER then
			ent:SetNWBool("NetVarActive", true)
		end
	end

	return entry
end

function GetEntity(ent, key, default)
	local tab = Entities[ent:EntIndex()]

	key = tostring(key)

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
	netstream.Hook("NetVarEntity", function(payload)
		for index, data in pairs(payload) do
			local ent = Entity(index)

			readPayload(data, function(key, value)
				local entry = GetEntry(ent)
				local old = entry[key]

				entry[key] = value

				writeLog("%s: '%s' (%s -> %s)", ent, key, old, value)
				hook.Run("EntityNetVarChanged", ent, key, old, value)
			end)
		end
	end)

	SyncCache = SyncCache or {}

	hook.Add("NetworkEntityCreated", "netvar", function(ent)
		if ent:GetNWBool("NetVarActive", false) then
			SyncCache[ent] = true
		end
	end)

	hook.Add("NotifyShouldTransmit", "netvar", function(ent, should)
		if ent:IsPlayer() or not should or not ent:GetNWBool("NetVarActive", false) then
			return
		end

		SyncCache[ent] = true
	end)

	hook.Add("Tick", "netvar", function()
		local count = table.Count(SyncCache)

		if count > 0 then
			writeLog("Sync Request: %s %s", count, count > 1 and "entities" or "entity")
			netstream.Send("NetVarEntity", table.GetKeys(SyncCache))
			table.Empty(SyncCache)
		end
	end)
else
	function SetEntity(ent, key, value, private)
		local entry = GetEntry(ent)

		key = tostring(key)

		if not entry[key] then
			entry[key] = {
				ChangeNumber = 0,
				Clients = {}
			}
		end

		entry = entry[key]

		local old = entry.Value

		entry.ChangeNumber = entry.ChangeNumber + 1
		entry.Private = private and ent:IsPlayer()
		entry.Value = value

		writeLog("%s: '%s' (%s -> %s)", ent, key, old, value)
		hook.Run("EntityNetVarChanged", ent, key, old, value)

		UpdateEntity(ent, key)
	end

	function SyncEntities(ply, entList)
		writeLog("Sync Request for %s %s from %s", #entList, #entList > 1 and "entities" or "entity", ply)

		local payload = {}
		local userID = ply:UserID()

		for _, ent in pairs(entList) do
			local index = ent:EntIndex()
			local entry = Entities[index]

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
			netstream.Send(ply, "NetVarEntity", payload)
		end
	end

	function UpdateEntity(ent, key)
		local index = ent:EntIndex()
		local entry = Entities[index][key]

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

		netstream.Send(receivers, "NetVarEntity", {[index] = writePayload({}, key, entry.Value)})
	end

	netstream.Hook("NetVarEntity", SyncEntities)
end

hook.Add("EntityRemoved", "netvar", function(ent)
	local index = ent:EntIndex()

	if index > 0 then
		Entities[index] = nil

		if CLIENT then
			SyncCache[ent] = nil
		end
	end
end)

-- Hooking

GlobalHooks = GlobalHooks or setmetatable({}, autofill)
EntityHooks = EntityHooks or setmetatable({}, autofill)

function AddGlobalHook(key, identifier, callback)
	GlobalHooks[key][identifier] = callback
end

function RemoveGlobalHook(key, identifier)
	GlobalHooks[key][identifier] = nil
end

function AddEntityHook(key, identifier, callback)
	EntityHooks[key][identifier] = callback
end

function RemoveEntityHook(key, identifier, callback)
	EntityHooks[key][identifier] = nil
end

function GM:GlobalNetVarChanged(key, old, new)
	for identifier, callback in pairs(GlobalHooks[key]) do
		if isstring(identifier) then
			callback(key, old, new)
		else
			if IsValid(identifier) then
				callback(identifier, key, old, new)
			else
				GlobalHooks[key][identifier] = nil
			end
		end
	end
end

function GM:EntityNetVarChanged(ent, key, old, new)
	local name = "On" .. key .. "Changed"

	if isfunction(ent[name]) then
		ent[name](ent, key, old, new)
	end

	for identifier, callback in pairs(EntityHooks[key]) do
		if isstring(identifier) then
			callback(ent, key, old, new)
		else
			if IsValid(identifier) then
				callback(identifier, key, old, new)
			else
				EntityHooks[key][identifier] = nil
			end
		end
	end
end

-- Meta functions

local entMeta = FindMetaTable("Entity")
local plyMeta = FindMetaTable("Player")

function entMeta:GetNetVar(key, fallback)
	return GetEntity(self, key, fallback)
end

if SERVER then
	function entMeta:SetNetVar(key, val)
		SetEntity(self, key, val)
	end

	function plyMeta:SetPrivateNetVar(key, val)
		SetEntity(self, key, val, true)
	end
end
