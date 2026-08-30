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
		if cursor then cursor::ActionPageChanged() end
	]];
	RefreshBindings = [[
		local owner = ...;
		self:ClearBindings()
		self::ApplyBindings()
		if owner then
			mouse::OnBindingsChanged()
			if cursor then cursor::OwnerChanged(owner) end
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
			bindings[{owner}] = bindings[{owner}] or newtable();
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
Manager:SetFrameRef('Mouse', db.Interact)
Manager:SetFrameRef('Pager', db.Pager)
Manager:Run([[
	bindings = {};
	owners   = {};
	manager  = self;
	mouse    = self:GetFrameRef('Mouse');
	pager    = self:GetFrameRef('Pager');
]])

---------------------------------------------------------------
-- Targeting module
---------------------------------------------------------------
local PendingBars = {};

function Manager:CacheActionBar(bar)
	if db.Raid then
		return db.Raid:CacheActionBar(bar)
	end
	PendingBars[bar] = true;
end

EventUtil.ContinueOnAddOnLoaded(CPAPI.TargetAddOn, function()
	db:RunSafe(function()
		Manager:SetFrameRef('Cursor', db.Raid)
		Manager:SetFrameRef('Ring', db.TargetRing)
		Manager:Run([[
			cursor = self:GetFrameRef('Cursor');
			ring   = self:GetFrameRef('Ring');
		]])
		for bar in pairs(PendingBars) do
			db.Raid:CacheActionBar(bar)
		end
		PendingBars = nil;
	end)
end)

---------------------------------------------------------------
-- Unit rerouting
---------------------------------------------------------------
-- While the target ring is held open, route clicks to the unit
-- under the radial stick without committing the target.
function Manager:RegisterReroute(button)
	self:Hook(button, 'OnClick', [[
		if not ring then return end;
		if ( down and not ring:IsShown() ) then
			-- Assist spell pressed with no assistable target: block the press
			-- and bring up the ring, so the release casts on the hovered unit.
			if ( button == 'ControllerInput'
				and not ( cursor and cursor:IsShown() )
				and not PlayerCanAssist('target')
				and self:GetAttribute('type') == 'action' ) then
				local spellID = pager::GetSpellID(self:GetAttribute('action'))
				if ( spellID and ring::OpenAssist(spellID) ) then
					assist = self;
					self:SetAttribute('backup-pressAndHold', self:GetAttribute('pressAndHoldAction'))
					self:SetAttribute('pressAndHoldAction', true)
					return false, 'assist';
				end
			end
			return
		end
		if not ring:IsShown() then return end;
		local unit = ring::GetHoveredUnit()
		if unit then
			self:SetAttribute('backup-unit', self:GetAttribute('unit'))
			self:SetAttribute('unit', unit)
			if ( not down and assist == self ) then
				-- The press was blocked, so there is no held action to
				-- release; perform the full action instead.
				self:SetAttribute('backup-typerelease', self:GetAttribute('typerelease'))
				self:SetAttribute('typerelease', 'action')
			end
			return nil, 'reroute';
		end
		if ( not down and assist == self ) then
			return nil, 'assist';
		end
	]], [[
		if ( message == 'reroute' ) then
			self:SetAttribute('unit', self:GetAttribute('backup-unit'))
			self:SetAttribute('backup-unit', nil)
			if ( assist == self ) then
				self:SetAttribute('typerelease', self:GetAttribute('backup-typerelease'))
				self:SetAttribute('backup-typerelease', nil)
			end
		end
		if ( not down and assist == self ) then
			assist = nil;
			self:SetAttribute('pressAndHoldAction', self:GetAttribute('backup-pressAndHold'))
			self:SetAttribute('backup-pressAndHold', nil)
			ring::CloseAssist()
		end
	]])
end

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