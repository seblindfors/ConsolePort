local env, db, L = CPAPI.GetEnv(...); L = env.L;
---------------------------------------------------------------

local function MakeTitle(text)
	return env.Elements.Title:New(L(text))
end

local function MakeHeader(text, collapsed)
	return env.Elements.Header:New(L(text), collapsed)
end

local function MakeBinding(name, bindingID, readonly)
	return env.Elements.Binding:New(name, bindingID, readonly)
end

local function MakeDivider()
	return env.Elements.Divider:New(8)
end

---------------------------------------------------------------
-- Bindings Panel
---------------------------------------------------------------
local Bindings = env:CreatePanel({
	name = KEY_BINDINGS_MAC;
})

function Bindings:OnLoad()
	CPAPI.Start(self)
end

function Bindings:OnShow()
	print('Hello world')
	self:RenderBindings()
end

function Bindings:RenderBindings()
	local bindings = env.BindingInfo:RefreshDictionary()
	local _, right = self:GetLists()
	local settings = right:GetDataProvider()
	settings:Flush()

	settings:Insert(MakeTitle(KEY_BINDINGS_MAC))
	for header, set in env.table.spairs(bindings) do
		self:Render(settings, header:trim(), set, true)
	end
end

function Bindings:Render(provider, title, data, preferCollapsed)
	local header = provider:Insert(MakeHeader(title, preferCollapsed))
	for _, binding in ipairs(data) do
		header:Insert(MakeBinding(
			binding.name,
			binding.binding,
			binding.readonly
		))
	end
	if next(data) then
		header:Insert(MakeDivider())
	end
end