CLASS.Name = "Set language"
CLASS.Description = "Say something in the chosen language or set your default."

CLASS.Commands = {}

for _, v in pairs(Language.List) do
	table.insert(CLASS.Commands, v[1])
end

if SERVER then
	function CLASS:Parse(ply, _, lang, text)
		if #text > 0 then
			Chat.Commands.say:Handle(ply, lang, "say", text)

			return
		end

		if not ply:HasLanguage(lang) then
			ply:SendChat("ERROR", "You don't speak this language!")

			return true
		end

		ply:SetActiveLanguage(lang)
		ply:SendChat("NOTICE", string.format("You are now speaking in %s.", Language.GetName(lang)))
	end
end
