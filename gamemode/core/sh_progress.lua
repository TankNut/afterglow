Progress = Progress or {}
Progress.Active = Progress.Active or {}

local meta = FindMetaTable("Player")

if CLIENT then
	Netstream.Hook("StartProgress", function(payload)
		Progress.Active[payload.Player] = {
			StartTime = CurTime(),
			EndTime = payload.Time,
			Scribe = Scribe.Parse("<big>" .. payload.Text, 380)
		}
	end)

	Netstream.Hook("StopProgress", function(ply)
		Progress.Active[ply] = nil
	end)

	hook.Add("PostRenderVGUI", "Progress", function()
		local uiSkin = derma.GetNamedSkin("Afterglow").Colors

		local w = 400
		local h = 40

		local x = (ScrW() / 2) - (w * 0.5)
		local y = (ScrH() / 2) + h

		for ply, data in SortedPairsByMemberValue(Progress.Active, "StartTime") do
			if not IsValid(ply) or CurTime() > data.EndTime then
				Progress.Active[ply] = nil

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
end

if SERVER then
	function Progress.Start(ply, time, text, checklist, notify, notifyText)
		if Progress.Active[ply] then
			Progress.Stop(ply, true)
		end

		checklist = checklist or {}

		local data = {
			EndTime = CurTime() + time,
			Coroutine = coroutine.running(),
			Checklist = checklist,
			Notify = notify,
			Pos = ply:GetPos()
		}

		Netstream.Send("StartProgress", ply, {
			Time = data.EndTime,
			Text = text,
			Player = ply
		})

		if notify then
			Netstream.Send("StartProgress", notify, {
				Time = data.EndTime,
				Text = notifyText,
				Player = ply
			})
		end

		Progress.Active[ply] = data

		if data.Coroutine then
			return coroutine.yield()
		end
	end

	function Progress.Stop(ply, silent)
		local data = Progress.Active[ply]

		if not data then
			return
		end

		if not silent then
			Netstream.Send("StopProgress", ply, ply)

			if data.Notify then
				Netstream.Send("StopProgress", data.Notify, ply)
			end
		end

		if data.Coroutine then
			coroutine.Resume(data.Coroutine, false)
		end

		Progress.Active[ply] = nil
	end

	function Progress.Finish(ply)
		local data = Progress.Active[ply]

		if not data then
			return
		end

		if data.Coroutine then
			coroutine.Resume(data.Coroutine, true)
		end

		Progress.Active[ply] = nil
	end

	function Progress.Think()
		for ply, data in pairs(Progress.Active) do
			if not IsValid(ply) or not Progress.CheckOwner(ply, data.Pos) then
				Progress.Stop(ply)

				continue
			end

			local abort = false

			for _, v in pairs(data.Checklist) do
				if not Progress.Validate(ply, v) then
					abort = true
					break
				end
			end

			if abort then
				Progress.Stop(ply)

				continue
			end

			if data.EndTime <= CurTime() then
				Progress.Finish(ply)
			end
		end
	end

	function Progress.CheckOwner(ply, pos)
		if not ply:Alive() or ply:GetPos():DistToSqr(pos) > 4 then
			return false
		end

		return true
	end

	function Progress.Validate(ply, check)
		if isentity(check) then
			if not IsValid(check) then
				return false
			end

			return check:IsPlayer() and Progress.CheckPlayer(ply, check) or Progress.CheckEntity(ply, check)
		elseif check.__Item then
			return Progress.CheckItem(ply, check)
		end
	end

	function Progress.CheckEntity(ply, ent)
		return true
	end

	function Progress.CheckPlayer(ply, target)
		return true
	end

	function Progress.CheckItem(ply, item)
		return item:CanInteract(ply)
	end

	hook.Add("Think", "Progress", Progress.Think)

	function meta:WaitFor(time, text, checklist, notify, notifyText)
		return Progress.Start(self, time, text, checklist, notify, notifyText)
	end
end
