module("scribe", package.seeall)

Components = Components or {}

local defaultFont = "DebugFixed"
local defaultColor = color_white

local CORE = {}
local COMPONENT = {}

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

function CORE:New(str, maxWidth)
	self.Pos = {x = 0, y = 0}
	self.Caret = {x = 0, y = 0}
	self.Size = {x = 0, y = 0}

	self.LineHeight = 0
	self.MaxWidth = maxWidth or math.huge

	self.Blocks = {}
	self.Stack = {}

	self.Complex = false
	self.Font = defaultFont
	self.Color = defaultColor

	self.CharModifiers = {}
	self:Parse(str)
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
				tag = tag:utf8sub(2)
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

function CORE:Draw(x, y, alpha)
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

Core = CORE

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

local BaseClass = BaseComponent

COMPONENT = {
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
		self.BufferWidth = self.BufferWidth + 1
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

COMPONENT = {
	Name = {"font", "f"}
}

function COMPONENT:New(ctx, font)
	BaseClass.New(self, ctx)
	self.Font = font
end

function COMPONENT:Push() self.Context:PushFont(self.Font) end
function COMPONENT:Pop() self.Context:PopFont() end

Register(COMPONENT)

COMPONENT = {
	Name = {"color", "c"}
}

function COMPONENT:New(ctx, color)
	BaseClass.New(self, ctx)

	local args = string.Explode("[, ]", color, true)

	self.Color = Color(args[1], args[2], args[3], args[4])
end

function COMPONENT:Push() self.Context:PushColor(self.Color) end
function COMPONENT:Pop() self.Context:PopColor() end

Register(COMPONENT)

COMPONENT = {
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

local PANEL = {}

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
		self.Scribe:Draw(0, 0)
	end
end

vgui.Register("scribe_label", PANEL, "DPanel")