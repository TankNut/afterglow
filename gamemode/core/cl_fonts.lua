GM.MainFont = "Tahoma"

function surface.FontExists(font)
	local ok = pcall(surface.SetFont, font)

	return ok
end

surface.CreateFont("DefaultBold", {
	font = GM.MainFont,
	size = 13,
	weight = 1000
})

surface.CreateFont("afterglow.labelworld", {
	font = GM.MainFont,
	size = 2048,
	weight = 21
})

for k, v in pairs({massive = 30, giant = 22, big = 18, medium = 16, small = 14, tiny = 12}) do
	surface.CreateFont("afterglow.label" .. k, {
		font = GM.MainFont,
		size = v,
		weight = 500
	})

	surface.CreateFont("afterglow.label" .. k .. "bold", {
		font = GM.MainFont,
		size = v,
		weight = 1600
	})

	surface.CreateFont("afterglow.label" .. k .. "italic", {
		font = GM.MainFont,
		size = v,
		weight = 500,
		italic = true
	})

	local COMPONENT = {
		Name = {k}
	}

	function COMPONENT:Push() self.Context:PushFont("afterglow.label" .. k) end
	function COMPONENT:Pop() self.Context:PopFont() end

	Scribe.Register(COMPONENT)
end

-- Chat component
Scribe.Register({
	Name = {"chat"},
	Components = {
		{"big"},
		{"outline", "1"}
	}
}, "compound")

do -- Bold component
	local COMPONENT = {
		Name = {"bold", "b"}
	}

	function COMPONENT:Push()
		self.Context:PushFont(self.Context.Font .. "bold")
	end

	function COMPONENT:Pop()
		self.Context:PopFont()
	end

	Scribe.Register(COMPONENT)
end

do -- Italic component
	local COMPONENT = {
		Name = {"italic", "i"}
	}

	function COMPONENT:Push()
		self.Context:PushFont(self.Context.Font .. "italic")
	end

	function COMPONENT:Pop()
		self.Context:PopFont()
	end

	Scribe.Register(COMPONENT)
end
