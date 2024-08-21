function GM:CanSpeakLanguage(ply, lang)
	return ply:GetLanguages()[lang] == true
end

function GM:CanUnderstandLanguage(ply, lang)
	return ply:GetLanguages()[lang] != nil
end
