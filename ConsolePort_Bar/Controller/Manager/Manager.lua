local _, env = ...;
local Manager, db = Mixin(ConsolePortBarManager, CPAPI.AdvancedSecureMixin), env.db;
---------------------------------------------------------------
env.Manager = Manager;
---------------------------------------------------------------
Manager.Env = {
	_onhide = [[
		self:ClearBindings()
	]];
	_onshow = [[
		self::ApplyBindings()
		mouse::OnBindingsChanged()
		cursor::ActionPageChanged()
	]];
	RefreshBindings = [[
		local owner = ...;
		self:ClearBindings()
		self::ApplyBindings()
		if owner then
			mouse::OnBindingsChanged()
			cursor::OwnerChanged(owner)
		end
	]];
	ApplyBindings = [[
		for owner, set in pairs(bindings) do
			if self:GetAttribute(owner) then
				for key, button in pairs(set) do
					self:SetBindingClick(false, key, button, 'ControllerInput')
				end
			end
		end
	]];
};

---------------------------------------------------------------
-- Secure callbacks
---------------------------------------------------------------

function Manager:OnDataLoaded()
	self:CreateEnvironment()
	self:OnPropsChanged()
	self:OnNewBindings(db.Gamepad:GetBindings(true))
end

function Manager:OnPropsChanged(refreshBindings)
	local layout = env.Layout;
	RegisterStateDriver(self, env.Attributes.Visible, layout.visibility or 'show')
	for id, props in pairs(layout.children or {}) do
		local widget = env:Acquire(props.type, id)
		if widget then
			securecallfunction(widget.SetProps, widget, props)
		end
	end
	if refreshBindings then
		self:OnNewBindings(self.bindingSnapshot)
	end
end

function Manager:OnNewBindings(bindings)
	self.bindingSnapshot = bindings;
	self:ClearOverrides()
	env:TriggerEvent('OnNewBindings', bindings)
	self:UpdateOverrides()
end

function Manager:GetBindings(buttonID)
	if buttonID then
		return self.bindingSnapshot and self.bindingSnapshot[buttonID];
	end
	return self.bindingSnapshot;
end

---------------------------------------------------------------
-- Secure environment
---------------------------------------------------------------

function Manager:ClearOverrides()
	self:Run([[
		bindings = wipe(bindings);
		self:ClearBindings()
	]])
end

function Manager:UpdateOverrides() self:Run([[
	self:ClearBindings()
	self::ApplyBindings()
	mouse::OnBindingsChanged()
]]) end

function Manager:RegisterOverride(owner, ref, ...)
	for i = 1, select('#', ...) do
		self:Parse([[
			bindings[{owner}]        = bindings[{owner}] or newtable();
			bindings[{owner}][{key}] = {ref};
		]], {
			owner = env:GetSignature(owner);
			key  = select(i, ...);
			ref  = ref;
		})
	end
end

function Manager:UnregisterOverride(owner, key) self:Parse([[
	if bindings[{owner}] then
		bindings[{owner}][{key}] = nil;
	end
]], { owner = env:GetSignature(owner), key = key }) end

function Manager:UnregisterOverrides(owner) self:Parse([[
	bindings[{owner}] = nil;
]], { owner = env:GetSignature(owner) }) end

---------------------------------------------------------------
-- Initialize manager
---------------------------------------------------------------
Manager:SetFrameRef('Cursor', db.Raid)
Manager:SetFrameRef('Mouse', db.Interact)
Manager:SetFrameRef('Pager', db.Pager)
Manager:Run([[
	bindings = {};
	owners   = {};
	manager  = self;
	mouse    = self:GetFrameRef('Mouse');
	cursor   = self:GetFrameRef('Cursor');
]])

---------------------------------------------------------------
-- Frontend
---------------------------------------------------------------

function Manager:FadeIn(alpha, time)
	db.Alpha.FadeIn(self, time or .25, alpha or 0, 1)
end

function Manager:FadeOut(alpha, time)
	db.Alpha.FadeOut(self, time or 1, alpha or 1, 0)
end

function Manager:OnHintsFocus()
	self:FadeOut(self:GetAlpha(), .1)
end

function Manager:OnHintsClear()
	self:FadeIn(self:GetAlpha())
end

---------------------------------------------------------------
-- Callbacks
---------------------------------------------------------------
db:RegisterCallback('OnHintsFocus', Manager.OnHintsFocus, Manager)
db:RegisterCallback('OnHintsClear', Manager.OnHintsClear, Manager)
db:RegisterSafeCallback('OnNewBindings', Manager.OnNewBindings, Manager)
env:RegisterSafeCallback('OnDataLoaded', Manager.OnDataLoaded, Manager)
env:RegisterSafeCallback('OnLayoutChanged', Manager.OnPropsChanged, Manager)