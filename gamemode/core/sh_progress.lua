module("Progress", package.seeall)

local meta = FindMetaTable("Player")

Active = Active or {}

if CLIENT then
	netstream.Hook("StartProgress", function(payload)
		Active[payload.Player] = {
			StartTime = CurTime(),
			EndTime = payload.Time,
			Scribe = scribe.Parse("<big>" .. payload.Text, 380)
		}
	end)

	netstream.Hook("StopProgress", function(ply)
		Active[ply] = nil
	end)

	hook.Add("PostRenderVGUI", "Progress", function()
		local uiSkin = derma.GetNamedSkin("Afterglow").Colors

		local w = 400
		local h = 40

		local x = (ScrW() / 2) - (w * 0.5)
		local y = (ScrH() / 2) + h

		for ply, data in SortedPairsByMemberValue(Active, "StartTime") do
			if not IsValid(ply) or CurTime() > data.EndTime then
				Active[ply] = nil

				continue
			end

			local fraction = math.ClampedRemap(CurTime(), data.StartTime, data.EndTime, 0, 1)

			surface.SetDrawColor(ColorAlpha(uiSkin.FillDark, 200))
			surface.DrawRect(x, y, w, h)

			surface.SetDrawColor(uiSkin.Primary)
			surface.DrawRect(x + 1, y + 1, fraction * (w - 2), h - 2)

			data.Scribe:Draw(x + (w * 0.5), y + (h * 0.5), 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			y = y + 50
		end
	end)
else
	function Start(ply, time, text, checklist, notify, notifyText)
		if Active[ply] then
			Stop(ply, true)
		end

		checklist = checklist or {}

		local data = {
			EndTime = CurTime() + time,
			Coroutine = coroutine.running(),
			Checklist = checklist,
			Notify = notify,
			Pos = ply:GetPos()
		}

		netstream.Send("StartProgress", ply, {
			Time = data.EndTime,
			Text = text,
			Player = ply
		})

		if notify then
			netstream.Send("StartProgress", notify, {
				Time = data.EndTime,
				Text = notifyText,
				Player = ply
			})
		end

		Active[ply] = data

		if data.Coroutine then
			return coroutine.yield()
		end
	end

	function Stop(ply, silent)
		local data = Active[ply]

		if not data then
			return
		end

		if not silent then
			netstream.Send("StopProgress", ply, ply)

			if data.Notify then
				netstream.Send("StopProgress", data.Notify, ply)
			end
		end

		if data.Coroutine then
			coroutine.Resume(data.Coroutine, false)
		end

		Active[ply] = nil
	end

	function Finish(ply)
		local data = Active[ply]

		if not data then
			return
		end

		if data.Coroutine then
			coroutine.Resume(data.Coroutine, true)
		end

		Active[ply] = nil
	end

	function Think()
		for ply, data in pairs(Active) do
			if not IsValid(ply) or not CheckOwner(ply, data.Pos) then
				Stop(ply)

				continue
			end

			local abort = false

			for _, v in pairs(data.Checklist) do
				if not Validate(ply, v) then
					abort = true
					break
				end
			end

			if abort then
				Stop(ply)

				continue
			end

			if data.EndTime <= CurTime() then
				Finish(ply)
			end
		end
	end

	function CheckOwner(ply, pos)
		if not ply:Alive() or ply:GetPos():DistToSqr(pos) > 4 then
			return false
		end

		return true
	end

	function Validate(ply, check)
		if isentity(check) then
			if not IsValid(check) then
				return false
			end

			return check:IsPlayer() and CheckPlayer(ply, check) or CheckEntity(ply, check)
		elseif check.__Item then
			return CheckItem(ply, check)
		end
	end

	function CheckEntity(ply, ent)
		return true
	end

	function CheckPlayer(ply, target)
		return true
	end

	function CheckItem(ply, item)
		return item:CanInteract(ply)
	end

	function meta:WaitFor(time, text, checklist, notify, notifyText)
		return Start(self, time, text, checklist, notify, notifyText)
	end

	hook.Add("Think", "Progress", Think)
end
