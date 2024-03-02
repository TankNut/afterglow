CLASS.Name = "Flag up"
CLASS.Description = "Sets you as on-duty if you have a combine flag."

CLASS.Commands = {"flag", "cp", "combine"}

if SERVER then
	function CLASS:Parse(ply, lang, cmd, text)
		if not ply:HasCombineFlag() then
			ply:SendChat("ERROR", "You're not part of the combine!")

			return
		end

		if ply:GetCombineFlagged() then
			ply:SendChat("ERROR", "You're already flagged up!")

			return
		end

		ply:SetCombineFlagged(true)
	end
end
