local _, env = ...;
local Manager, db = Mixin(ConsolePortBarManager, CPAPI.AdvancedSecureMixin), env.db;
---------------------------------------------------------------
env.Manager = Manager;
---------------------------------------------------------------
Manager.Env = {
	_onhide = [[]];
	_onshow = [[
		mouse::OnBindingsChanged()
		cursor::ActionPageChanged()
	]];
	RefreshBindings = [[
		local owner = ...;
		self:CallMethod('OnRefreshBindings')
		if owner then
			mouse::OnBindingsChanged()
			cursor::OwnerChanged(owner)
		end
	]];
	ApplyBindings = [[
		-- Bindings are now applied dynamically via BuildApplyBody / UpdateOverrides
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

function Manager:OnBindingIconChanged()
	-- Don't expect this to happen very often, but there are
	-- obviously better ways to handle this than a full refresh.
	self:OnNewBindings(db.Gamepad:GetBindings(true))
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
	self.keyBindings = {}
	self:Run([[
		bindings = wipe(bindings);
		self:ClearBindings()
	]])
end

function Manager:BuildApplyBody()
	for refName, keys in pairs(self.keyBindings) do
		for key, _ in pairs(keys) do
			SetBindingClick(key, refName)
		end
	end
end

function Manager:OnRefreshBindings()
	self:Run([[self:ClearBindings()]])
	self:BuildApplyBody()
end

function Manager:UpdateOverrides()
	self:Run([[self:ClearBindings()]])
	self:BuildApplyBody()
	self:Run([[mouse:RunAttribute('OnBindingsChanged')]])
end

function Manager:RegisterOverride(owner, ref, ...)
	-- Track in Lua table for binding setup
	if not self.keyBindings[ref] then
		self.keyBindings[ref] = {}
	end
	for i = 1, select('#', ...) do
		local key = select(i, ...)
		self.keyBindings[ref][key] = true
		self:Parse([[
			bindings[{owner}] = bindings[{owner}] or newtable();
			bindings[{owner}][{key}] = {ref};
		]], {
			owner = env:GetSignature(owner);
			key  = key;
			ref  = ref;
		})
	end
end

function Manager:UnregisterOverride(owner, key)
	-- Remove from Lua tracking table
	for refName, keys in pairs(self.keyBindings) do
		keys[key] = nil
	end
	self:Parse([[
		if bindings[{owner}] then
			bindings[{owner}][{key}] = nil;
		end
	]], { owner = env:GetSignature(owner), key = key })
end

function Manager:UnregisterOverrides(owner)
	self.keyBindings = {}
	self:Parse([[
		bindings[{owner}] = nil;
	]], { owner = env:GetSignature(owner) })
end

---------------------------------------------------------------
-- Initialize manager
---------------------------------------------------------------
Manager:SetFrameRef('Cursor', db.Raid)
Manager:SetFrameRef('Mouse', db.Interact)
Manager:SetFrameRef('Pager', db.Pager)
Manager.keyBindings = {}
Manager:HookScript('OnShow', function(self)
	self:BuildApplyBody()
end)
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
db:RegisterSafeCallback('OnBindingIconChanged', Manager.OnBindingIconChanged, Manager)
env:RegisterSafeCallback('OnDataLoaded', Manager.OnDataLoaded, Manager)
env:RegisterSafeCallback('OnLayoutChanged', Manager.OnPropsChanged, Manager)