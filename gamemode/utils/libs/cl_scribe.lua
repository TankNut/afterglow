module("scribe", package.seeall)

Components = Components or {}

local defaultFont = "afterglow.labelbig"
local defaultColor = color_white

function Register(component, base)
	base = Components[base] or BaseComponent

	local instanceMeta = {
		__index = component
	}

	setmetatable(component, {
		__call = function(self, ...)
			local instance = setmetatable({}, instanceMeta)

			instance:New(...)

			return instance
		end,
		__index = base
	})

	for _, v in pairs(component.Name) do
		Components[v] = component
	end
end

function Parse(str, maxWidth)
	local instance = setmetatable({}, {
		__index = Core
	})

	instance:New(str, maxWidth)

	return instance
end

do -- Core object
	local CORE = {}
	function CORE:New(str, maxWidth)
		self.Pos = {x = 0, y = 0}
		self.Caret = {x = 0, y = 0}
		self.Size = {x = 0, y = 0}

		self.LineHeight = 0
		self.MaxWidth = maxWidth or math.huge

		self.Blocks = {}
		self:Reset()

		self:Parse(str)
	end

	function CORE:Reset()
		self.Stack = {}

		self.Complex = false
		self.Font = defaultFont
		self.Color = defaultColor

		self.CharModifiers = {}
	end

	function CORE:ProcessMatch(stack, str)
		if not str or str == "" or str == "<nop>" then
			return
		end

		local order = stack.Order
		local tags = stack.Tags

		if str[1] == "<" then
			str:gsub("<([/%a]*)=?([^>]*)", function(tag, args)
				local unset = tag[1] == "/"

				if unset then
					tag = tag:sub(2)
				end

				if not Components[tag] then
					return
				end

				tags[tag] = tags[tag] or util.Stack()

				if unset then
					if not tags[tag] or tags[tag]:Size() == 0 then
						return
					end

					local component = tags[tag]:Pop()

					table.insert(self.Blocks, component)
					order[component] = nil
				else
					local component = Components[tag](self, args)

					if not component.Draw then
						tags[tag]:Push(component)
						order[component] = stack.Counter
						stack.Counter = stack.Counter + 1
					end

					table.insert(self.Blocks, component)
				end
			end)
		else
			table.insert(self.Blocks, Components["text"](self, str))
		end
	end

	function CORE:Parse(str)
		table.Empty(self.Blocks)

		local stack = {
			Counter = 1,
			Order = {},
			Tags = {}
		}

		(str .. "<nop>"):gsub("([^<>]*)(<[^>]+.)([^<>]*)", function(...)
			for _, v in pairs({...}) do
				self:ProcessMatch(stack, v)
			end
		end)

		for k in SortedPairsByValue(stack.Order) do
			table.insert(self.Blocks, k)
		end

		self:Recalculate()
	end

	function CORE:Recalculate()
		self.DryRun = true
		self:Draw(0, 0)
		self.DryRun = nil
	end

	function CORE:Newline()
		self.TotalWidth = math.max(self.TotalWidth, self.Caret.x)

		self.Caret.x = 0
		self.Caret.y = self.Caret.y + self.LineHeight

		self.LineHeight = 0
	end

	function CORE:SetFont(font)
		self.Font = font

		surface.SetFont(font)
	end

	function CORE:SetColor(color)
		self.Color = color

		surface.SetTextColor(color.r, color.g, color.b, color.a * self.Alpha)
	end

	-- Stack handling

	function CORE:PushStack(index, val)
		self.Stack[index] = self.Stack[index] or util.Stack()
		self.Stack[index]:Push(val)
	end

	function CORE:PopStack(index)
		if not self.Stack[index] then
			return
		end

		self.Stack[index]:Pop()

		return self.Stack[index]:Top()
	end

	function CORE:PushColor(color)
		self:PushStack("Color", color)
		self:SetColor(color)
	end

	function CORE:PopColor()
		self:SetColor(self:PopStack("Color") or defaultColor)
	end

	function CORE:PushFont(font)
		self:PushStack("Font", font)
		self:SetFont(font)
	end

	function CORE:PopFont()
		self:SetFont(self:PopStack("Font") or defaultFont)
	end

	function CORE:PushComplex()
		self:PushStack("Complex", self.Complex)
		self.Complex = true
	end

	function CORE:PopComplex()
		self.Complex = self:PopStack("Complex") or false
	end

	-- Drawing

	function CORE:Draw(x, y, alpha, xAlign, yAlign)
		xAlign = xAlign or TEXT_ALIGN_LEFT
		yAlign = yAlign or TEXT_ALIGN_TOP

		local w, h = self:GetSize()

		if xAlign == TEXT_ALIGN_CENTER then
			x = x - (w * 0.5)
		elseif xAlign == TEXT_ALIGN_RIGHT then
			x = x - w
		end

		if yAlign == TEXT_ALIGN_CENTER then
			y = y - (h * 0.5)
		elseif yAlign == TEXT_ALIGN_BOTTOM then
			y = y - h
		end

		self.Alpha = alpha or 1

		self.Pos.x = x
		self.Pos.y = y

		self.Caret.x = 0
		self.Caret.y = 0

		self.TotalWidth = 0
		self.LineHeight = 0

		self:SetFont(defaultFont)
		self:SetColor(defaultColor)

		for _, v in pairs(self.Blocks) do
			if v.Draw then
				v:Draw(self)
			else
				if v.Active then
					v:Pop(self)
					v.Active = false
				else
					v:Push(self)
					v.Active = true
				end
			end
		end

		self:Newline()

		self.Size.x = self.TotalWidth
		self.Size.y = self.Caret.y
	end

	function CORE:PrintToConsole()
		self.Buffer = {}
		self.LastColor = color_white

		self.Console = true
		self:Draw(0, 0)
		self.Console = nil

		table.insert(self.Buffer, "\n")
		MsgC(unpack(self.Buffer))
	end

	function CORE:GetSize()
		return self.Size.x, self.Size.y
	end

	function CORE:GetWide()
		return self.Size.x
	end

	function CORE:GetTall()
		return self.Size.y
	end

	Core = CORE
end

do -- Base component
	local COMPONENT = {}

	function COMPONENT:New(ctx)
		self.Context = ctx
		self.Handlers = {}
	end

	function COMPONENT:AddHandler(handler)
		local index = #self.Context[handler] + 1

		self.Handlers[handler] = index
		self.Context[handler][index] = self
	end

	function COMPONENT:RemoveHandler(handler)
		self.Context[handler][self.Handlers[handler]] = nil
		self.Handlers[handler] = nil
	end

	function COMPONENT:AddCharHandler() self:AddHandler("CharModifiers") end
	function COMPONENT:RemoveCharHandler() self:RemoveHandler("CharModifiers") end

	function COMPONENT:Push() end
	function COMPONENT:Pop() end

	function COMPONENT:PreCharModify(part, data) end
	function COMPONENT:PostCharModify(part, data) end

	function COMPONENT:DrawText(text, x, y, effect)
		if self.Context.Console and not effect then
			local buffer = self.Context.Buffer
			local color = self.Context.Color

			if color != self.Context.LastColor then
				self.Context.LastColor = color

				table.insert(buffer, color)
				table.insert(buffer, text)
			else
				buffer[#buffer] = buffer[#buffer] .. text
			end
		else
			surface.SetTextPos(x, y)
			surface.DrawText(text)
		end
	end

	BaseComponent = COMPONENT
end

local BaseClass = BaseComponent

do -- Text component
	local COMPONENT = {
		Name = {"text"}
	}

	function COMPONENT:New(ctx, str)
		BaseClass.New(self, ctx)
		self.Text = str:Unescape()
	end

	function COMPONENT:Draw()
		local ctx = self.Context
		local caret = ctx.Caret
		local storeBuffer = {}

		self.Buffer = {}
		self.BufferWidth = 0

		for _, code in utf8.codes(self.Text) do
			local char = utf8.char(code)

			if code == 10 then
				self:FlushBuffer(true)
				continue
			end

			local w = surface.GetFontSize(ctx.Font, char)

			if caret.x + self.BufferWidth + w > ctx.MaxWidth then
				local last = string.LastSpace(self.Buffer) -- Does actually work if you pass it a table of characters!

				if last then
					for i = last + 1, #self.Buffer do
						storeBuffer[#storeBuffer + 1] = self.Buffer[i]
						self.Buffer[i] = nil
					end

					self:FlushBuffer(true)

					table.Empty(self.Buffer)

					for k, v in pairs(storeBuffer) do
						self.Buffer[k] = v
						storeBuffer[k] = nil
					end

					self.BufferWidth = surface.GetFontSize(ctx.Font, table.concat(self.Buffer))
				else
					self:FlushBuffer(true)
				end
			end

			self.Buffer[#self.Buffer + 1] = char
			self.BufferWidth = self.BufferWidth + w
		end

		self:FlushBuffer()
	end

	function COMPONENT:FlushBuffer(newline)
		local ctx = self.Context

		if self.BufferWidth == 0 then
			if newline then
				if ctx.LineHeight == 0 then
					local _, h = surface.GetFontSize(ctx.Font, "a")

					ctx.LineHeight = h
				end

				ctx:Newline()
			end

			return
		end

		local caret = ctx.Caret
		local pos = ctx.Pos

		if ctx.Complex then
			for _, v in ipairs(self.Buffer) do
				local w, h = surface.GetFontSize(ctx.Font, v)
				local data = {
					Text = v,
					x = pos.x + caret.x,
					y = pos.y + caret.y,
					w = w,
					h = h
				}

				local skip = false

				for _, handler in pairs(ctx.CharModifiers) do
					if handler:PreCharModify(self, data) then
						skip = true
					end
				end

				if not skip and not ctx.DryRun then
					self:DrawText(data.Text, data.x, data.y)
				end

				for _, handler in pairs(ctx.CharModifiers) do
					handler:PostCharModify(self, data)
				end

				ctx.LineHeight = math.max(ctx.LineHeight, data.h)
				caret.x = caret.x + data.w
			end
		else
			local text = table.concat(self.Buffer)
			local w, h = surface.GetFontSize(ctx.Font, text)
			local data = {
				Text = text,
				x = pos.x + caret.x,
				y = pos.y + caret.y,
				w = w,
				h = h
			}

			local skip = false

			for _, handler in pairs(ctx.CharModifiers) do
				if handler:PreCharModify(self, data) then
					skip = true
				end
			end

			if not skip and not ctx.DryRun then
				self:DrawText(data.Text, data.x, data.y)
			end

			for _, handler in pairs(ctx.CharModifiers) do
				handler:PostCharModify(self, data)
			end

			ctx.LineHeight = math.max(ctx.LineHeight, data.h)
			caret.x = caret.x + data.w
		end

		table.Empty(self.Buffer)
		self.BufferWidth = 0

		if newline then
			ctx:Newline()
		end
	end

	Register(COMPONENT)
end

do -- Font component
	local COMPONENT = {
		Name = {"font", "f"}
	}

	function COMPONENT:New(ctx, font)
		BaseClass.New(self, ctx)
		self.Font = font
	end

	function COMPONENT:Push() self.Context:PushFont(self.Font) end
	function COMPONENT:Pop() self.Context:PopFont() end

	Register(COMPONENT)
end

do -- Color component
	local COMPONENT = {
		Name = {"color", "c"}
	}

	function COMPONENT:New(ctx, color)
		BaseClass.New(self, ctx)

		local args = string.Explode("[%p%s]", color, true)

		self.Color = Color(args[1], args[2], args[3], args[4])
	end

	function COMPONENT:Push() self.Context:PushColor(self.Color) end
	function COMPONENT:Pop() self.Context:PopColor() end

	Register(COMPONENT)
end

do -- Alpha component
	local COMPONENT = {
		Name = {"alpha", "a"}
	}

	function COMPONENT:New(ctx, alpha)
		self.Color = ColorAlpha(ctx.Color, tonumber(alpha))
	end

	function COMPONENT:Push() self.Context:PushColor(self.Color) end
	function COMPONENT:Pop() self.Context:PopColor() end

	Register(COMPONENT)
end

do -- Inset component
	local COMPONENT = {
		Name = {"iset", "inset"}
	}

	function COMPONENT:New(ctx, inset)
		BaseClass.New(self, ctx)
		self.Inset = tonumber(inset)
	end

	function COMPONENT:Push() self:AddCharHandler() end
	function COMPONENT:Pop() self:RemoveCharHandler() end

	function COMPONENT:PreCharModify(part, data)
		if self.Context.Caret.x == 0 then
			data.x = data.x + self.Inset
			data.w = data.w + self.Inset
		end
	end

	Register(COMPONENT)
end

do -- Reset component
	local COMPONENT = {
		Name = {"reset"}
	}

	function COMPONENT:Push()
		self.Context:Reset()

		self.Context:SetFont(self.Context.Font)
		self.Context:SetColor(self.Context.Color)
	end

	Register(COMPONENT)
end

do -- Rainbow component
	local COMPONENT = {
		Name = {"rgb", "rainbow"}
	}

	function COMPONENT:New(ctx, args)
		BaseClass.New(self, ctx)
		args = string.Explode("[%p%s]", args, true)

		self.Complex = tobool(args[1])

		if self.Complex then
			self.Frequency = tonumber(args[2])
			self.Speed = tonumber(args[3]) or 0
		else
			self.Speed = tonumber(args[2]) or 0
		end
	end

	function COMPONENT:Push()
		self.SavedColor = self.Context.Color
		self.Counter = 0

		if self.Complex then
			self.Context:PushComplex()
		end

		self:AddCharHandler()
	end

	function COMPONENT:Pop()
		self:RemoveCharHandler()

		if self.Complex then
			self.Context:PopComplex()
		end

		self.Context:SetColor(self.SavedColor)
	end

	function COMPONENT:PreCharModify(part, data)
		-- Something else has overwritten us
		if self.Context.Color != self.SavedColor then
			return
		end

		self.Color = self.Context.Color

		if self.Complex then
			local frequency = self.Frequency or 360 / #part.Text

			self.Context:SetColor(HSVToColor(self.Counter * frequency + (CurTime() * self.Speed) % 360, 1, 1))
		else
			self.Context:SetColor(HSVToColor(CurTime() * self.Speed % 360, 1, 1))
		end
	end

	function COMPONENT:PostCharModify(part, data)
		self.Counter = self.Counter + 1

		if self.Color then
			self.Context:SetColor(self.Color)
			self.Color = nil
		end
	end

	Register(COMPONENT)
end

do -- Outline component
	local black = Color(0, 0, 0)
	local COMPONENT = {
		Name = {"ol", "outline"}
	}

	function COMPONENT:New(ctx, args)
		BaseClass.New(self, ctx)

		self.Width = tonumber(args) or 1
	end

	function COMPONENT:Push()
		self:AddCharHandler()
	end

	function COMPONENT:Pop()
		self:RemoveCharHandler()
	end

	function COMPONENT:PreCharModify(part, data)
		local color = self.Context.Color

		data.w = data.w + self.Width * 2
		data.h = data.h + self.Width * 2

		data.x = data.x + self.Width
		data.y = data.y + self.Width

		self.Context:SetColor(black)

		local steps = math.max((self.Width * 2) / 3, 1)

		for _x = -self.Width, self.Width, steps do
			for _y = -self.Width, self.Width, steps do
				self:DrawText(data.Text, data.x + _x, data.y + _y, true)
			end
		end

		self.Context:SetColor(color)
	end

	Register(COMPONENT)
end

do -- Compound component
	local COMPONENT = {
		Name = {"compound"},
		Components = {}
	}

	function COMPONENT:New(ctx, args)
		BaseClass.New(self, ctx)

		self._Components = {}

		for k, v in pairs(self.Components) do
			self._Components[k] = Components[v[1]](ctx, v[2])
		end
	end

	function COMPONENT:Push()
		for _, component in SortedPairs(self._Components) do
			component:Push()
		end
	end

	function COMPONENT:Pop()
		for _, component in SortedPairs(self._Components, true) do
			component:Pop()
		end
	end

	Register(COMPONENT)
end

local PANEL = {}

function PANEL:SetAlignment(x, y)
	self.AlignmentX = x
	self.AlignmentY = y
end

function PANEL:SetText(text)
	self.Text = text
	self:Rebuild()
end

function PANEL:GetText()
	return self.Text or ""
end

function PANEL:Rebuild()
	local text = self:GetText()

	if text and #text > 0 then
		self.Scribe = scribe.Parse(text, self:GetWide())
	end
end

function PANEL:PerformLayout()
	self:Rebuild()
end

function PANEL:GetContentSize()
	if self.Scribe then
		return self.Scribe:GetSize()
	else
		return 0, 0
	end
end

function PANEL:Paint(w, h)
	if self.Scribe then
		local x = 0
		local y = 0

		if self.AlignmentX == TEXT_ALIGN_CENTER then
			x = w * 0.5
		elseif self.AlignmentX == TEXT_ALIGN_RIGHT then
			x = w
		end

		if self.AlignmentY == TEXT_ALIGN_CENTER then
			y = h * 0.5
		elseif self.AlignmentY == TEXT_ALIGN_BOTTOM then
			y = h
		end

		self.Scribe:Draw(x, y, self:GetAlpha(), self.AlignmentX, self.AlignmentY)
	end
end

vgui.Register("scribe_label", PANEL, "DPanel")
