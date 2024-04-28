local _, env = ...;
local Manager, db = Mixin(ConsolePortBarManager, CPAPI.AdvancedSecureMixin), env.db;
---------------------------------------------------------------
env.Manager = Manager;
---------------------------------------------------------------
Manager.Env = {
	['_onhide'] = [[
		self:ClearBindings()
	]];
	['_onshow'] = [[
		self::ApplyBindings()
		mouse::OnBindingsChanged()
	]];
	ApplyBindings = [[
		for key, button in pairs(bindings) do
			self:SetBindingClick(false, key, button, 'ControllerInput')
			self:CallMethod('OnOverrideSet', key)
		end
	]];
};

---------------------------------------------------------------
-- Secure callbacks
---------------------------------------------------------------

function Manager:OnDataLoaded()
    self:CreateEnvironment()
    self:OnConfigChanged()
end

function Manager:OnConfigChanged()
    local layout = env.Layout;
    RegisterStateDriver(self, 'visibility', layout.visibility or 'show')
    for id, config in pairs(layout.bars or {}) do
        local bar = env:Acquire(config.type, id)
        if bar then
            bar:SetConfig(config)
        end
    end
end

function Manager:OnNewBindings(bindings)
    self:UnregisterOverrides()
    env:TriggerEvent('OnNewBindings', bindings)
    self:UpdateOverrides()
end

---------------------------------------------------------------
-- Secure environment
---------------------------------------------------------------

function Manager:UnregisterOverrides()
    self:Run([[
        bindings = wipe(bindings);
        self:ClearBindings()
    ]])
end

function Manager:UpdateOverrides() self:Run([[
    self:ClearBindings()
    self::ApplyBindings()
    -- TODO: notify control:ChildUpdate(...)
    mouse::OnBindingsChanged()
]]) end

function Manager:RegisterOverride(owner, key, button) self:Parse([[
    owners[{key}]   = {owner};
    bindings[{key}] = {button};
]], { owner = env:GetSignature(owner), key = key, button = button }) end

function Manager:UnregisterOverride(owner, key) self:Parse([[
    if owners[{key}] == {owner} then
        owners[{key}]   = nil;
        bindings[{key}] = nil;
    end
]], { owner = env:GetSignature(owner), key = key }) end

function Manager:OnOverrideSet(key)
	db.Input:HandleConflict(self, false, key)
end

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