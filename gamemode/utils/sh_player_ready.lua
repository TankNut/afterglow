local meta = FindMetaTable("Player")

function GM:OnPlayerReady(ply)
end

function meta:IsClientReady()
	return net.Ready[self]
end

if CLIENT then
	hook.Add("InitPostEntity", "PlayerReady", function()
		net.Start("PlayerReady")
		net.SendToServer()

		hook.Run("OnPlayerReady", LocalPlayer())
	end)
end

if SERVER then
	util.AddNetworkString("PlayerReady")

	net.Ready = net.Ready or {}

	net.Receive("PlayerReady", function(_, ply)
		if net.Ready[ply] then
			return
		end

		net.Ready[ply] = true

		hook.Run("OnPlayerReady", ply)
	end)
end
