local env, db = CPAPI.GetEnv(...)
---------------------------------------------------------------
local Secure = Mixin(env.Frame, CPAPI.AdvancedSecureMixin)
---------------------------------------------------------------
Secure:SetAttribute(CPAPI.ActionPressAndHold, true)
Secure:Execute(([[
	DATA = newtable()
	META = newtable()
	SWAP = newtable()
	TYPE = '%s';
]]):format(CPAPI.ActionTypeRelease))

---------------------------------------------------------------
-- Ring environment
---------------------------------------------------------------
Secure:CreateEnvironment({
	-----------------------------------------------------------
	-- Draw current ring
	-----------------------------------------------------------
	DrawSelectedRing = ([[
		local set = ...;
		RING, INFO = DATA[set], META[set];
		if not RING then
			return
		end

		local numActive = #RING;
		local radius    = self::SetDynamicRadius(numActive)
		local invertY   = self:GetAttribute('axisInversion')

		self:SetAttribute(%q, self::GetButtonsHeld())
		self:SetAttribute('state', set)
		control:ChildUpdate('state', set)

		for i, action in ipairs(RING) do
			local x, y = radial::GetPointForIndex(i, numActive, radius)
			local widget = self:GetFrameRef(self::GetButtonRef(set, i))

			widget:::SetRotation(-math.atan2(x, y))
			widget:Show()
			widget:ClearAllPoints()
			widget:SetPoint('CENTER', '$parent', 'CENTER', x, invertY * y)
		end
		for i=numActive+1, self:GetAttribute('numButtons') do
			self:GetFrameRef(tostring(i)):Hide()
		end
		self:SetAttribute('size', numActive)
	]]):format(env.Attributes.TriggerButton);
	CommitAction = [[
		local index = ...;
		if not RING or not index then
			return self:::ClearInstantly()
		end

		self:::OnSelection(true)
		self:::OnSelectionAttributeAdded('index', index)

		local slot = RING[index];
		if slot.ring then
			self::SwitchRing(slot.ring)
			self:::OnSelection(false)
			return true;
		end

		for attribute, value in pairs(slot) do
			local convertedAttribute = self::ConvertAttribute(attribute)
			self:SetAttribute(convertedAttribute, value)
			self:::OnSelectionAttributeAdded(convertedAttribute, value)
		end
		self:::OnSelection(false)
	]];
	-- Attribute conversion wrapper:
	-- If the attribute is 'type', it should be mapped to the press type currently
	-- used by the ring. Otherwise, it should be passed through as is.
	-- E.g. 'type' -> 'typerelease', 'action' -> 'action'
	ConvertAttribute = [[
		local attribute = ...;
		return (attribute == 'type') and TYPE or attribute;
	]];
	GetButtonRef = [[
		local set, idx = ...;
		return set..':'..idx;
	]];
	GetRingSetFromButton = ([[
		local button = ...;
		return self::GetContextAttribute('state', true)
			or DATA[button] and button
			or tostring(%s);
	]]):format(CPAPI.DefaultRingSetID);
	-----------------------------------------------------------
	-- Context switching
	-----------------------------------------------------------
	SwitchRing = ([[
		self::ClearContext()

		local button = ...;
		local set = self::GetRingSetFromButton(button)

		local trigger = %q;
		local pressAndHold = %q;

		self:SetAttribute(trigger, nil)
		self::SetRemoveBinding(true)
		self::SetAcceptBinding(true)

		self::SetContextAttribute('state', set)
		self::SetContextAttribute(pressAndHold, false)
		self:::OnSelectionAttributeAdded('ring', set)

		self::DrawSelectedRing(set)
		self:::OnStickyIndexChanged()
		self:::OnPostShow()
	]]):format(env.Attributes.TriggerButton, env.Attributes.PressAndHold);
	GetContextAttribute = [[
		local attribute, preventDefault = ...;
		if ( SWAP[attribute] ~= nil ) then
			return SWAP[attribute];
		end
		if not preventDefault then
			return self:GetAttribute(attribute);
		end
	]];
	SetContextAttribute = [[
		local attribute, value = ...;
		SWAP[attribute] = value;
	]];
	ClearContext = [[
		wipe(SWAP)
	]];
	-----------------------------------------------------------
	-- Control bindings
	-----------------------------------------------------------
	IsControlBindingInConflict = ([[
		local binding = ...;
		local trigger = self:GetAttribute(%q)
		return trigger and binding and trigger:match(binding)
	]]):format(env.Attributes.TriggerButton);
	SetRemoveBinding = ([[
		local enabled = ...;
		local button = self:GetAttribute(%q)
		local bindings = { self::GetBindingsForButton(button) };
		local isInConflict = self::IsControlBindingInConflict(button)
		self:SetAttribute(%q, isInConflict)

		if enabled and not isInConflict then
			local removeWidget = self:GetFrameRef('Remove')
			for _, binding in ipairs(bindings) do
				self:SetBindingClick(true, binding, removeWidget)
			end
		else
			for _, binding in ipairs(bindings) do
				self:ClearBinding(binding)
			end
		end
	]]):format(env.Attributes.RemoveButton, env.Attributes.RemoveBlocked);
	SetAcceptBinding = ([[
		local enabled = ...;
		local button = self:GetAttribute('acceptButton')
		local bindings = { self::GetBindingsForButton(button) };
		local isInConflict = self::IsControlBindingInConflict(button)
		self:SetAttribute('acceptButtonBlocked', isInConflict)

		if enabled and not isInConflict then
			for _, binding in ipairs(bindings) do
				self:SetBindingClick(true, binding, self)
			end
		else
			for _, binding in ipairs(bindings) do
				self:ClearBinding(binding)
			end
		end
	]]):format(env.Attributes.AcceptButton, env.Attributes.AcceptBlocked);
	-----------------------------------------------------------
	-- Sticky index
	-----------------------------------------------------------
	ClearStickyIndex = [[
		self::SaveStickyIndex(nil)
		self:::OnStickyIndexChanged()
	]];
	GetStickyIndex = ([[
		local key = %q;
		local index = INFO[key];
		if index and index > #RING then
			index = #RING;
			self::SaveStickyIndex(index)
		end
		return index;
	]]):format(env.Attributes.Sticky);
	SaveStickyIndex = ([[
		local index = ...;
		local key = %q;
		local set = self:GetAttribute('state')
		INFO[key] = index;
		self:::SafeSetMetadata(set, key, index)
	]]):format(env.Attributes.Sticky);
	InjectStickyIndex = [[
		local index = ...;
		if index then
			self::SaveStickyIndex(index)
		else
			index = self::GetStickyIndex()
		end
		return index;
	]];
	-----------------------------------------------------------
	-- Actions
	-----------------------------------------------------------
	Enable = [[
		local button, stickySelect, pressAndHold = ...;
		local set = self::GetRingSetFromButton(button)

		self:::CheckCursorInfo(set)
		self::DrawSelectedRing(set)
		self::SetRemoveBinding(true)
		self:Show()

		if not pressAndHold then
			self::SetAcceptBinding(true)
		end
	]];
	Disable = [[
		self::ClearContext()
		self:ClearBindings()
		self:Hide()
	]];
	Commit = [[
		local stickySelect, pressAndHold = ...;
		local index = self::GetIndex()
		if stickySelect then
			index = self::InjectStickyIndex(index)
		end
		if not self::CommitAction(index) then
			self::Disable()
		end
	]];
	-----------------------------------------------------------
	-- Behavior
	-----------------------------------------------------------
	Hold = [[
		local button, down, stickySelect, pressAndHold = ...;
		if down then
			self::Enable(button, stickySelect, pressAndHold)
		else
			self::Commit(stickySelect, pressAndHold)
		end
	]];
	Toggle = [[
		local button, down, stickySelect, pressAndHold = ...;
		if down then return end;
		if self:IsShown() then
			self::Commit(stickySelect, pressAndHold)
		else
			self::Enable(button, stickySelect, pressAndHold)
		end
	]];
	-----------------------------------------------------------
	Main = ([[
		local button, down = ...;
		local stickySelect = self::GetContextAttribute(%q)
		local pressAndHold = self::GetContextAttribute(%q)
		self:SetAttribute(TYPE, nil)

		if pressAndHold then
			self::Hold(button, down, stickySelect, pressAndHold)
		else
			self::Toggle(button, down, stickySelect, pressAndHold)
		end
	]]):format(env.Attributes.StickySelect, env.Attributes.PressAndHold);
});

---------------------------------------------------------------
-- Trigger script
---------------------------------------------------------------
Secure:Wrap('PreClick', [[ self::Main(button, down) ]])

---------------------------------------------------------------
-- Removal
---------------------------------------------------------------
Secure:SetFrameRef('Remove', Secure.Remove)
Secure:Hook(Secure.Remove, 'OnClick', [[
	local index = control::GetIndex()
	local set = control:GetAttribute('state')
	if set and index then
		control:::SafeRemoveAction(set, index)
		control::DrawSelectedRing(set)
		control:::OnPostShow()
		return control:::OnStickyIndexChanged()
	end
	return control::ClearStickyIndex()
]])

---------------------------------------------------------------
-- Widget handling
---------------------------------------------------------------
function Secure:QueueRefresh()
	if env.IsDataReady then
		db:RunSafe(self.RefreshAll, self)
	end
end

function Secure:RefreshAll()
	self:ClearAllActions()
	local numButtons = 0;
	for setID, set in env:EnumerateAvailableSets() do
		self:AddSecureMetadata(setID, set[env.Attributes.MetadataIndex])
		for i, action in ipairs(set) do
			self:AddSecureAction(setID, i, action)
		end
		numButtons = #set > numButtons and #set or numButtons;
	end
	self:SetAttribute('numButtons', numButtons)
end

function Secure:ClearAllActions()
	self:Execute('wipe(DATA); wipe(META)')
	for button in self:EnumerateActive() do
		button:ClearStates()
	end
	self:ReleaseAll()
end

function Secure:AddSecureMetadata(set, data)
	local args, body = { ring = tostring(set) }, [[
		local meta = META[{ring}];
		if not meta then
			META[{ring}] = newtable();
			meta = META[{ring}];
		end
	]];
	for key, value in pairs(data) do
		body = ('%s\n meta.%s = {%s}'):format(body, key, key)
		args[key] = value;
	end
	return self:Parse(body, args)
end

function Secure:AddSecureAction(set, idx, info)
	local button, newObj = self:TryAcquireRegistered(idx)
	if newObj then
		button:SetFrameLevel(idx + 2)
		button:SetID(idx)
		button:OnLoad()
		button:DisableDragNDrop(true)
		button:SetSize(64, 64)
		self:SetFrameRef(tostring(idx), button)
	end

	self:SetFrameRef(set..':'..idx, button)
	local kind, action, extraInfo = env:GetKindAndAction(info)
	if not kind or not action then
		return -- TODO: not good, we end up with missing indices.
	end
	button:SetState(set, kind, action)

	local args, body = { container = tostring(set), slot = idx }, [[
		local ring = DATA[{container}];
		if not ring then
			DATA[{container}] = newtable();
			ring = DATA[{container}];
		end

		local slot = ring[{slot}];
		if not slot then
			ring[{slot}] = newtable();
			slot = ring[{slot}];
		end
	]];

	local parseInfo = extraInfo and CreateFromMixins(info, extraInfo) or info;
	for key, value in pairs(parseInfo) do
		body = ('%s\n slot.%s = {%s}'):format(body, key, key)
		args[key] = value;
	end
	return self:Parse(body, args)
end

db:RegisterSafeCallback('OnRingCleared', Secure.RefreshAll, Secure)
db:RegisterSafeCallback('OnRingRemoved', Secure.RefreshAll, Secure)

---------------------------------------------------------------
-- Data handling
---------------------------------------------------------------
function Secure:OnAxisInversionChanged()
	self.axisInversion = db('radialCosineDelta')
	self:SetAttribute('axisInversion', self.axisInversion)
end

function Secure:OnPrimaryStickChanged()
	local sticks = db.Radial:GetStickStruct(db('radialPrimaryStick'))
	self:SetInterrupt(sticks)
	self:SetIntercept({sticks[1]})
end

function Secure:OnAcceptButtonChanged()
	self:SetAttribute(env.Attributes.AcceptButton, db('ringAcceptButton'))
end

function Secure:OnRemoveButtonChanged()
	self:SetAttribute(env.Attributes.RemoveButton, db('ringRemoveButton'))
end

function Secure:OnPressAndHoldChanged()
	self.pressAndHold = db('ringPressAndHold')
	self:SetAttribute(env.Attributes.PressAndHold, self.pressAndHold)
end

function Secure:OnStickySelectChanged()
	self.stickySelect = db('ringStickySelect')
	self:SetAttribute(env.Attributes.StickySelect, self.stickySelect)
end

db:RegisterSafeCallback('Settings/radialCosineDelta',  Secure.OnAxisInversionChanged, Secure)
db:RegisterSafeCallback('Settings/radialPrimaryStick', Secure.OnPrimaryStickChanged,  Secure)
db:RegisterSafeCallback('Settings/ringRemoveButton',   Secure.OnRemoveButtonChanged,  Secure)
db:RegisterSafeCallback('Settings/ringAcceptButton',   Secure.OnAcceptButtonChanged,  Secure)
db:RegisterSafeCallback('Settings/ringPressAndHold',   Secure.OnPressAndHoldChanged,  Secure)
db:RegisterSafeCallback('Settings/ringStickySelect',   Secure.OnStickySelectChanged,  Secure)

function Secure:IsSticky() return self.stickySelect end;
function Secure:IsPressAndHold() return self.pressAndHold end;

---------------------------------------------------------------
-- Load the secure environment
---------------------------------------------------------------
env:AddLoader(function(self)
	self:SetAttribute('size', 0)
	self:CreateObjectPool(env.ActionButton:NewPool({
		name   = self:GetName()..'Button';
		header = self;
		mixin  = env.DisplayButton;
		config = env.LABConfig;
	}))

	local sticks = db.Radial:GetStickStruct(db('radialPrimaryStick'))
	db.Radial:Register(self, 'UtilityRing', {
		sticks = sticks;
		target = {sticks[1]};
		sizer  = [[
			local size = self:GetAttribute('size');
		]];
	});

	self:OnAcceptButtonChanged()
	self:OnRemoveButtonChanged()
	self:OnAxisInversionChanged()
	self:OnStickySelectChanged()
	self:OnPressAndHoldChanged()
end)