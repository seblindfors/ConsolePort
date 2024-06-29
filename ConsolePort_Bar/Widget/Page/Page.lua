local _, env, db = ...; db = env.db;
---------------------------------------------------------------
local PAGE, SLOT = 'Page', 'Slot';
---------------------------------------------------------------

local GetBindingKey, GetBindingText = GetBindingKey, GetBindingText;

---------------------------------------------------------------
local Slot = CreateFromMixins(env.SlotButton)
---------------------------------------------------------------

function Slot:OnLoad()
	env.SlotButton.OnLoad(self)
	self.HotKey:SetWidth(self:GetWidth())
	self:SetAttribute(CPAPI.SkipHotkeyRender, true)
end

function Slot:OnRelease()
	self:ClearStates()
	env.Manager:UnregisterOverrides(self)
end

function Slot:SetProps(id, states)
	self.id     = id;
	self.states = states;
end

function Slot:OnNewBindings()
	for state in pairs(self.states) do
		local page = tonumber(state) or 1;
		local actionID = ( ( page - 1 ) * NUM_ACTIONBAR_BUTTONS ) + self.id;
		self:SetState(state, self:SetActionBinding(state, actionID))
	end
end

function Slot:ShouldOverrideActionBarBinding(_, actionID)
	return true;
end

function Slot:GetOverrideBinding(_, actionID)
	local binding = db('Actionbar/Action/'..actionID)
	-- TODO: this isn't perfect, as the custom flyout only works for one binding.
	self:SetAttribute(CPAPI.UseCustomFlyout, db.Gamepad:GetBindingKey(binding))
	return GetBindingKey(binding, true);
end

function Slot:GetHotkey()
	local actionID = self:GetAttribute('action')
	if not actionID then return end;
	local text = GetBindingText(GetBindingKey(db('Actionbar/Action/'..actionID), true), 1)
	return text;
end

---------------------------------------------------------------
CPActionPage = CreateFromMixins(CPActionBar, ResizeLayoutMixin, GridLayoutFrameMixin, env.MovableWidgetMixin);
---------------------------------------------------------------

function CPActionPage:OnLoad()
	CPActionBar.OnLoad(self)
	self.buttons = {};
	self.states  = {};

	env:RegisterCallback('OnNewBindings', self.OnNewBindings, self)
	env:RegisterCallback('OnConfigChanged', self.OnConfigChanged, self)
	env:RegisterCallback('OnMasqueLoaded', self.OnMasqueLoaded, self)

	self:RegisterPageResponse([[
		local page = ...;
		local state = self:GetAttribute('state');
		if ( state ~= 'dynamic' ) then
			if ( state == 'override' ) then
				if HasVehicleActionBar and HasVehicleActionBar() then
					page = GetVehicleBarIndex()
				elseif HasOverrideActionBar and HasOverrideActionBar() then
					page = GetOverrideBarIndex()
				end
			elseif ( tonumber(state) ) then
				page = tonumber(state)
			end
		end
		self:ChildUpdate('actionpage', page)
	]])

	if env.MSQ then
		self:OnMasqueLoaded(env.MSQ)
	end
end

function CPActionPage:UpdateSlots()
	self:OnRelease()
	wipe(self.buttons)

	local props = self.props;
	for i = 1, props.slots do
		local id = props.offset + (i-1);
		local slot = env:Acquire(SLOT, env.MakeID('%s_Slot%s', self:GetName(), i), i, self)
		slot:Show()
		slot:ClearAllPoints()
		slot:SetProps(id, self.states)
		slot.layoutIndex = i;
		self.buttons[i] = slot;
		if self.msqGroup then
			slot:AddToMasque(self.msqGroup)
		end
	end

	local isHorizontal, reverse = props.orientation == 'HORIZONTAL', props.reverse;

	self.stride                 = props.stride;
	self.isHorizontal           = isHorizontal;
	self.childXPadding          = props.paddingX;
	self.childYPadding          = props.paddingY;
	self.layoutFramesGoingUp    = reverse;
	self.layoutFramesGoingRight = not reverse;

	self:Layout()
end

function CPActionPage:ShouldUpdateLayout()
	-- :Layout() is manually invoked when updating slots instead of OnShow,
	-- so we don't insecurely update the layout in combat. Since we may update
	-- the layout while hidden, return true to force a layout update.
	return true;
end

function CPActionPage:OnRelease()
	self:UnregisterVisibilityDriver()
	env:Map(SLOT, nil, function(slot)
		if ( slot:GetParent() == self ) then
			env:Release(slot)
		end
	end)
end

function CPActionPage:SetProps(props)
	self:SetDynamicProps(props)
	self:OnDriverChanged()
	self:UpdateSlots()
	self:OnConfigChanged(env.Button:GetConfig())
	CPActionBar.OnDriverChanged(self)
	CPActionBar.OnHierarchyChanged(self)
end

function CPActionPage:OnPropsUpdated()
	self:SetProps(self.props)
	self:OnNewBindings()
end

function CPActionPage:OnDriverChanged()
	local driver = env.ConvertDriver(self.props.page);
	wipe(self.states)
	for response, condition in env.MapDriver(driver) do
		self.states[response] = condition or false;
	end
	self:RegisterModifierDriver(driver, [[
		self:SetAttribute('state', newstate)
		control:ChildUpdate('state', newstate)
	]])
end

function CPActionPage:OnNewBindings()
	for _, slot in ipairs(self.buttons) do
		slot:OnNewBindings()
	end
	self:RunAttribute(env.Attributes.OnPage, self:GetAttribute('actionpage'))
	self:RunDriver('modifier')
	self:OnConfigChanged(env.Button:GetConfig())
end

function CPActionPage:OnConfigChanged(generic)
	local config = CopyTable(generic)
	config.hideElements.hotkey = not self.props.hotkeys;
	for _, slot in ipairs(self.buttons) do
		slot:UpdateConfig(config)
	end
end

function CPActionPage:OnMasqueLoaded(msq)
	local groupID = ('%s: %s'):format(YELLOW_FONT_COLOR:WrapTextInColorCode(PAGE), self.id)
	self.msqGroup = msq:Group('ConsolePort', groupID)
	for _, button in pairs(self.buttons) do
		button:AddToMasque(self.msqGroup)
	end
end

---------------------------------------------------------------
-- Action page factory
---------------------------------------------------------------
env:AddFactory(PAGE, function(id)
	local frame = CreateFrame('Frame', env.MakeID('ConsolePortPage%s', id), env.Manager, 'CPActionPage')
	frame.id = id;
	frame:OnLoad()
	return frame;
end, env.Interface.Page)

env:AddFactory(SLOT, function(id, slotID, parent)
	local slot = Mixin(env.LAB:CreateButton(slotID, id, parent), Slot)
	slot:OnLoad()
	return slot;
end)