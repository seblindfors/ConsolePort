local env, db, _, L = CPAPI.GetEnv(...);
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
-- Help Panel
---------------------------------------------------------------
local Help = env:CreatePanel({
	name = HELP_LABEL;
})

function Help:OnLoad()
	CPAPI.Start(self)
end

function Help:OnShow()
	print('Hello world')
	self:RenderHelp()
end

function Help:RenderHelp()
	--[[local bindings = env.BindingInfo:RefreshDictionary()
	local _, right = self:GetLists()
	local settings = right:GetDataProvider()
	settings:Flush()

	settings:Insert(MakeTitle(KEY_BINDINGS_MAC))
	for header, set in env.table.spairs(bindings) do
		self:Render(settings, header:trim(), set, true)
	end]]
end

function Help:Render(provider, title, data, preferCollapsed)
	--[[local header = provider:Insert(MakeHeader(title, preferCollapsed))
	for _, binding in ipairs(data) do
		header:Insert(MakeBinding(
			binding.name,
			binding.binding,
			binding.readonly
		))
	end
	if next(data) then
		header:Insert(MakeDivider())
	end]]
end