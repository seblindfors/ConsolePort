local env, db = CPAPI.GetEnv(...)
---------------------------------------------------------------
local Secure = Mixin(env.Frame, CPAPI.AdvancedSecureMixin)
---------------------------------------------------------------
Secure:SetAttribute(CPAPI.ActionPressAndHold, true)
Secure:Execute(([[
	DATA = newtable()
	TYPE = '%s';
]]):format(CPAPI.ActionTypeRelease))

---------------------------------------------------------------
-- Ring environment
---------------------------------------------------------------
Secure:CreateEnvironment({
	-----------------------------------------------------------
	-- Draw current ring
	-----------------------------------------------------------
	DrawSelectedRing = [[
		local set = ...;
		RING = DATA[set];
		if not RING then
			return
		end

		local numActive = #RING;
		local radius = self::SetDynamicRadius(numActive)
		local invertY = self:GetAttribute('axisInversion')

		self:SetAttribute('trigger', self::GetButtonsHeld())
		self:SetAttribute('state', set)
		control:ChildUpdate('state', set)

		for i, action in ipairs(RING) do
			local x, y = radial::GetPointForIndex(i, numActive, radius)
			local widget = self:GetFrameRef(self::GetButtonRef(set, i))

			widget:CallMethod('SetRotation', -math.atan2(x, y))
			widget:Show()
			widget:ClearAllPoints()
			widget:SetPoint('CENTER', '$parent', 'CENTER', x, invertY * y)
		end
		for i=numActive+1, self:GetAttribute('numButtons') do
			self:GetFrameRef(tostring(i)):Hide()
		end
		self:SetAttribute('size', numActive)
	]];
	CopySelectedIndex = [[
		local index = ...;
		if not RING or not index then
			return self:CallMethod('ClearInstantly')
		end

		self:CallMethod('OnSelection', true)
		for attribute, value in pairs(RING[index]) do
			local convertedAttribute = (attribute == 'type') and TYPE or attribute;
			self:SetAttribute(convertedAttribute, value)
			self:CallMethod('OnSelectionAttributeAdded', convertedAttribute, value)
		end
		self:CallMethod('OnSelection', false)
	]];
	GetButtonRef = [[
		local set, idx = ...;
		return set..':'..idx;
	]];
	GetRingSetFromButton = ([[
		local button = ...;
		if DATA[button] then
			return button;
		end
		return tostring(%s);
	]]):format(CPAPI.DefaultRingSetID);
	-----------------------------------------------------------
	-- Set pre-defined remove binding
	-----------------------------------------------------------
	SetRemoveBinding = [[
		local enabled = ...;
		if enabled then
			local binding, trigger = self:GetAttribute('removeButton'), self:GetAttribute('trigger')
			if trigger and binding and trigger:match(binding) then
				self:SetAttribute('removeButtonBlocked', true)
				return self:ClearBindings()
			end

			self:SetAttribute('removeButtonBlocked', false)
			local mods = {self::GetModifiersHeld()}
			table.sort(mods)
			mods[#mods+1] = table.concat(mods)

			local removeWidget = self:GetFrameRef('Remove')
			for _, mod in ipairs(mods) do
				self:SetBindingClick(true, mod..binding, removeWidget)
			end
			self:SetBindingClick(true, binding, removeWidget)
		else
			self:ClearBindings()
		end
	]];
	-----------------------------------------------------------
	ClearStickyIndex = [[
		if self:GetAttribute('stickyIndex') then
			self:SetAttribute('stickyIndex', nil)
			self:SetAttribute('backup', nil)
			self:SetAttribute(TYPE, nil)
			self:CallMethod('OnStickyIndexChanged')
		end
	]];
});

---------------------------------------------------------------
-- Trigger script
---------------------------------------------------------------
Secure:Wrap('PreClick', [[
	local stickySelect = self:GetAttribute('stickySelect')

	if stickySelect then
		if down then
			self:SetAttribute('backup', self:GetAttribute(TYPE))
			self:SetAttribute(TYPE, nil)
		else
			self:SetAttribute(TYPE, self:GetAttribute('backup'))
			self:SetAttribute('backup', nil)
		end
	else
		self:SetAttribute(TYPE, nil)
	end

	if down then
		local set = self::GetRingSetFromButton(button)
		self:CallMethod('CheckCursorInfo', set)
		self::DrawSelectedRing(set)
		self::SetRemoveBinding(true)
		self:Show()
		if stickySelect then
			if ( set ~= self:GetAttribute('stickyState') ) then
				self:SetAttribute('stickyIndex', nil)
				self:SetAttribute('stickyState', set)
			end
		end
	else
		local index = self::GetIndex()
		self::CopySelectedIndex(index)
		self:ClearBindings()
		self:Hide()
		if stickySelect then
			self:SetAttribute('stickyIndex', index or self:GetAttribute('stickyIndex'))
		end
	end
]])

---------------------------------------------------------------
-- Removal
---------------------------------------------------------------
Secure:SetFrameRef('Remove', Secure.Remove)
Secure:WrapScript(Secure.Remove, 'OnClick', [[
	local index = control:Run(GetIndex)
	local set = control:GetAttribute('state')
	if set and index then
		control:CallMethod('SafeRemoveAction', set, index)
		control:Run(DrawSelectedRing, set)
		control:CallMethod('OnPostShow')
		return control:CallMethod('OnStickySelectChanged')
	end
	return control:Run(ClearStickyIndex)
]])

---------------------------------------------------------------
-- Widget handling
---------------------------------------------------------------
function Secure:QueueRefresh()
	if self.isDataReady then
		db:RunSafe(self.RefreshAll, self)
	end
end

function Secure:RefreshAll()
	self:ClearAllActions()
	local numButtons = 0;
	for setID, set in pairs(env:ValidateData(self.Data)) do
		for i, action in ipairs(set) do
			self:AddSecureAction(setID, i, action)
		end
		numButtons = #set > numButtons and #set or numButtons;
	end
	self:SetAttribute('numButtons', numButtons)
end

function Secure:ClearAllActions()
	self:Execute('wipe(DATA)')
	for button in self:EnumerateActive() do
		button:ClearStates()
	end
	self:ReleaseAll()
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
	local kind, action = env:GetKindAndAction(info)
	if not kind or not action then
		return -- TODO: not good, we end up with missing indices.
	end
	button:SetState(set, kind, action)

	local args, body = { ring = tostring(set), slot = idx }, [[
		local ring = DATA[{ring}];
		if not ring then
			DATA[{ring}] = newtable();
			ring = DATA[{ring}];
		end

		local slot = ring[{slot}];
		if not slot then
			ring[{slot}] = newtable();
			slot = ring[{slot}];
		end
	]];
	for key, value in pairs(info) do
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

function Secure:OnRemoveButtonChanged()
	self:SetAttribute('removeButton', db('radialRemoveButton'))
end

function Secure:OnPrimaryStickChanged()
	local sticks = db.Radial:GetStickStruct(db('radialPrimaryStick'))
	self:SetInterrupt(sticks)
	self:SetIntercept({sticks[1]})
end

function Secure:OnStickySelectChanged()
	self:SetAttribute(CPAPI.ActionTypeRelease, nil)
	self:SetAttribute('stickySelect', db('radialStickySelect'))
	self:SetAttribute('backup', nil)
	self:SetAttribute('stickyIndex', nil)
	self:SetAttribute('stickyState', nil)
end

db:RegisterSafeCallback('Settings/radialCosineDelta',  Secure.OnAxisInversionChanged, Secure)
db:RegisterSafeCallback('Settings/radialRemoveButton', Secure.OnRemoveButtonChanged,  Secure)
db:RegisterSafeCallback('Settings/radialPrimaryStick', Secure.OnPrimaryStickChanged,  Secure)
db:RegisterSafeCallback('Settings/radialStickySelect', Secure.OnStickySelectChanged,  Secure)

---------------------------------------------------------------
-- Load the secure environment
---------------------------------------------------------------
env:AddLoader(function(self, container)
	self:SetAttribute('size', 0)
	self:CreateObjectPool(env.ActionButton:NewPool({
		name   = self:GetName()..'Button';
		header = self;
		mixin  = env.DisplayButton;
		config = {
			showGrid = true;
			hideElements = {
				macro = true;
			};
		};
	}))

	local sticks = db.Radial:GetStickStruct(db('radialPrimaryStick'))
	db.Radial:Register(self, 'UtilityRing', {
		sticks = sticks;
		target = {sticks[1]};
		sizer  = [[
			local size = self:GetAttribute('size');
		]];
	});

	-- Set up a proxy so all new rings are automatically
	-- created in the secure environment.
	CPAPI.Proxy(container, function(data, key)
		self:Parse([[
			DATA[{ring}] = newtable();
		]], {ring = tostring(key)})
		return rawset(data, key, {})[key];
	end)

	self:OnRemoveButtonChanged()
	self:OnAxisInversionChanged()
	self:OnStickySelectChanged()
end)