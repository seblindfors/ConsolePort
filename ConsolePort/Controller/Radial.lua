---------------------------------------------------------------
-- Radial handler for pie menus
---------------------------------------------------------------
-- This handler configures headers as pie menus, providing API
-- to convert an angle in deg. to a menu index and vice versa.
-- Keystrokes and specific stick inputs are interrupted by the
-- handler and dispatched to the display layer on the header.

local Radial, Dispatcher, RadialMixin, _, db = CPAPI.DataHandler(ConsolePortRadial), CreateFrame('Frame'), {}, ...;
Mixin(Radial, CPAPI.SecureEnvironmentMixin).Headers = {};
db:Register('Radial', Radial):Execute([[
	----------------------------------------------------------
	HEADERS = newtable() -- maintain references to headers
	STIX    = newtable() -- track config name to stick ID
	BTNS    = newtable() -- track config ID to bind name
	MODS    = newtable() -- track modifiers
	----------------------------------------------------------
]])

---------------------------------------------------------------
-- Consts
---------------------------------------------------------------
local DEFAULT_ANGLE_OFFSET = 90;
local DEFAULT_ITEM_SIZE    = 64;
local DEFAULT_ITEM_PADDING = 32;
local RAW_ORDER     = { 'Left', 'Right', 'Gyro' };
local VIRTUAL_STICK = { Left = 'Movement', Right = 'Camera', Gyro = 'Look' };
local RAW_STICK     = tInvert(VIRTUAL_STICK);

---------------------------------------------------------------
-- Stick input
---------------------------------------------------------------
-- Observed, not documented: each frame delivers raw stick events
-- in order (Left > Right > Gyro), then their virtual twins in the
-- same order, and a twin fires only if its raw stick fired that
-- frame. The game acts on the twins. Propagation flags cannot
-- change in combat; show/hide can.
local Blocker = CreateFrame('Frame');
Dispatcher.tracker, Dispatcher.pending, Dispatcher.seen = {}, {}, {};

function Dispatcher:RaiseBlocker(this, stick)
	self.pending[VIRTUAL_STICK[stick]] = true;
	local waitFor;
	for _, raw in ipairs(RAW_ORDER) do
		if ( raw == stick ) then break end;
		if ( self.seen[raw] and not this.sticks[raw] ) then
			waitFor = VIRTUAL_STICK[raw];
		end
	end
	if waitFor then
		self.armed = waitFor;
	else
		Blocker:Show()
	end
end

function Dispatcher:OnGamePadStick(stick, x, y, len)
	local this, virtual = self.focusFrame, VIRTUAL_STICK[stick];
	if not this then return end;
	if not virtual then
		if ( stick == self.armed ) then
			self.armed = nil;
			Blocker:Show()
		end
		return
	end
	self.seen[stick] = true;
	if not ( this.sticks and this.sticks[stick] ) then return end;
	if ( len > 0 ) then
		self:RaiseBlocker(this, stick)
	end
	self.tracker[stick] = len;
	local canDisable = self:CheckDeadzone(stick, len)
	if self.disabled then
		if canDisable then
			return self:ClearFocusInstantly(this)
		end
	elseif this:IsDominantStick(stick, self.tracker) then
		this:OnInput(x, y, len, stick)
	end
end

function Dispatcher:LowerBlocker()
	wipe(self.pending)
	Blocker:Hide()
end

function Dispatcher:OnFrameEnd()
	wipe(self.seen)
	self.armed = nil;
	if Blocker:IsShown() then
		self:LowerBlocker()
	end
end

Blocker:SetScript('OnGamePadStick', function(_, stick, ...)
	if VIRTUAL_STICK[stick] then
		return Dispatcher:OnGamePadStick(stick, ...)
	end
	Dispatcher.pending[stick] = nil;
	if not next(Dispatcher.pending) then
		Blocker:Hide()
	end
end)

function Dispatcher:CheckDeadzone(stick, len)
	if not self.enableDeadzone then return end;
	if stick and len then
		self.tracker[stick] = len;
	end
	local canDisable = true;
	for _, len in pairs(self.tracker) do
		if len > self.deadzone then
			canDisable = false;
			break;
		end
	end
	return canDisable;
end

function Dispatcher:SetFocus(frame)
	self.focusFrame = frame;
	self:EnableGamePadStick(true)
	SetGamePadCursorControl(false)
	self:SetScript('OnUpdate', self.OnFrameEnd)
	if self:ClearTimer() then
		self.disabled = nil;
	end
end

function Dispatcher:ClearFocus(frame)
	if self.focusFrame ~= frame then return end;
	self.disabled = true;
	self:SetTimer()
	if self.enableDeadzone and self:CheckDeadzone() then
		self:ClearFocusInstantly(frame)
	end
end

function Dispatcher:ClearTimer()
	if self.focusTimer then
		self.focusTimer:Cancel()
		self.focusTimer = nil;
		return true;
	end
end

function Dispatcher:SetTimer()
	self:ClearTimer()
	if not self.enableTimeout then return end;
	self.focusTimer = C_Timer.NewTimer(self.timeout, self.Disable)
end

function Dispatcher:ClearFocusInstantly(frame)
	if self.focusFrame ~= frame then return end;
	self:ClearTimer()
	self.Disable()
end

function Dispatcher:IsDisabling()
	return self.disabled;
end

function Dispatcher.Disable() -- callback
	wipe(Dispatcher.tracker)
	Dispatcher.disabled = nil;
	Dispatcher.focusFrame = nil;
	Dispatcher.focusTimer = nil;
	Dispatcher:LowerBlocker()
	Dispatcher:SetScript('OnUpdate', nil)
	Dispatcher:EnableGamePadStick(false)
end

CPAPI.Start(Dispatcher)
Dispatcher:SetFrameStrata('BACKGROUND')
Dispatcher:SetPropagateKeyboardInput(true)
Dispatcher:EnableGamePadStick(false)
Blocker:SetFrameStrata('TOOLTIP')
Blocker:SetPropagateKeyboardInput(false)
Blocker:EnableGamePadStick(true)
Blocker:Hide()

---------------------------------------------------------------
-- RadialMixin, for headers registered as radials
---------------------------------------------------------------
RadialMixin.Env = {
	GetIndex = [[
		local stickID, size = ...;
		size = size or UpdateSize and self::UpdateSize() or self:GetAttribute('size');
		if stickID then
			return radial::GetIndexForStickPosition(stickID, size);
		end
		local index, i = nil, 1;
		repeat
			local stick = self:GetAttribute('stick'..i)
			if not stick then break end;
			index, i = radial::GetIndexForStickPosition(stick, size), i + 1;
		until index
		return index;
	]];
	IsButtonHeld = [[
		local id = ...;
		return radial::IsButtonHeld(id)
	]];
	GetButtonsHeld = [[
		return radial::GetButtonsHeld()
	]];
	GetModifiersHeld = [[
		return radial::GetModifiersHeld()
	]];
	GetActiveModifiers = [[
		return radial::GetActiveModifiers()
	]];
	GetRadius = [[
		return math.sqrt(self:GetWidth() * self:GetHeight()) / 2;
	]];
	GetStickPosition = [[
		local id = ...;
		return radial::GetStickPosition(stickID or self:GetAttribute('stick'))
	]];
	SetDynamicRadius = [[
		local numItems, itemSize, padding = ...;
		local size = self:GetAttribute('preferSize')
		self:SetWidth(size)
		self:SetHeight(size)
		return self::GetRadius(), self::GetItemSize(numItems, itemSize, padding);
	]];
	GetItemSize = ([[
		local numItems, itemSize, padding = ...;
		itemSize, padding = itemSize or %d, padding or %d;
		local available = (math.pi * self:GetAttribute('preferSize')) / math.max(numItems or 1, 1) - padding;
		return math.max(math.min(available, itemSize), itemSize * 0.35);
	]]):format(DEFAULT_ITEM_SIZE, DEFAULT_ITEM_PADDING);
	SpaceEvenly = [[
		local children = { self:GetChildren() };
		local radius = math.sqrt(self:GetWidth() * self:GetHeight()) / 2
		local count = #children
		self:SetAttribute('size', count)
		for i, child in ipairs(children) do
			child:ClearAllPoints()
			child:SetPoint('CENTER', radial::GetPointForIndex(i, count, radius))
		end
	]];
	SetBinding = [[
		local btn, mod = ...
		self:SetBindingClick(true, ((mod or '')..btn):upper(), self, btn)
		self:CallMethod('OnBindingSet', btn, mod)
	]];
	SetBindingsForTriggers = [[
		local btns = { self::GetButtonsHeld() };
		local mods = { self::GetActiveModifiers() };

		for _, btn in pairs(btns) do
			self::SetBinding(btn)
			for _, mod in pairs(mods) do
				self::SetBinding(btn, mod)
			end
		end
		return #btns > 0;
	]];
	SetBindingsForButton = [[
		local btns = { ... };
		local mods = { self::GetActiveModifiers() };

		for _, btn in pairs(btns) do
			self::SetBinding(btn)
			for _, mod in pairs(mods) do
				self::SetBinding(btn, mod)
			end
		end
		return #btns > 0;
	]];
	GetBindingsForButton = [[
		local btn  = ...;
		local mods = { self::GetActiveModifiers() };
		for i=1, #mods do
			mods[i] = mods[i]..btn;
		end
		return btn, unpack(mods);
	]];
}

---------------------------------------------------------------
local RadialCalc = {};
---------------------------------------------------------------
function RadialCalc:GetPointForIndex(index, size, radius)
	return 'CENTER', self:GetCoordsForIndex(index, size, radius)
end

function RadialCalc:GetCoordsForIndex(index, size, radius)
	return Radial:GetPointForIndex(index, size or self:GetAttribute('size'), radius or (self:GetWidth() / 2))
end

function RadialCalc:GetBoundingRadiansForIndex(index, size)
	return Radial:GetBoundingRadiansForIndex(index, size or self:GetAttribute('size'))
end

function RadialCalc:GetIndexForPos(x, y, len, size)
	return Radial:GetIndexForStickPosition(x, y, len, size or self:GetAttribute('size'))
end

function RadialCalc:GetValidThreshold()
	return Radial.VALID_VEC_LEN or .5;
end

function RadialCalc:IsValidThreshold(len)
	return len >= self:GetValidThreshold()
end

function RadialCalc:SetRadialSize(size)
	if self.fixedSize then return end;
	local radius = self.radius or 1;
	local newSize = size * radius;
	self:SetAttribute('preferSize', newSize)
	return self:SetSize(newSize, newSize)
end

function RadialCalc:SetFixedSize(size)
	self.fixedSize = size;
	if not size then return end;
	self:SetAttribute('preferSize', size)
	return self:SetSize(size, size)
end

function RadialCalc:SetDynamicRadius(numItems, itemSize, padding)
	if self:IsProtected() then
		assert(not InCombatLockdown(), 'Cannot set dynamic radius from insecure code in combat.')
		self:Execute(([[
			self:RunAttribute('SetDynamicRadius', %d, %d, %d)
		]]):format(numItems, itemSize or DEFAULT_ITEM_SIZE, padding or DEFAULT_ITEM_PADDING))
		return self:GetRadius(), self:GetItemSizeForCount(numItems, itemSize, padding);
	end

	local preferSize = self:GetAttribute('preferSize')
	assert(preferSize, 'Prefer size not set.')
	self:SetSize(preferSize, preferSize)
	return self:GetRadius(), self:GetItemSizeForCount(numItems, itemSize, padding);
end

function RadialCalc:GetItemSizeForCount(numItems, itemSize, padding)
	itemSize, padding = itemSize or DEFAULT_ITEM_SIZE, padding or DEFAULT_ITEM_PADDING;
	local available = (math.pi * self:GetAttribute('preferSize')) / math.max(numItems or 1, 1) - padding;
	return math.max(math.min(available, itemSize), itemSize * 0.35);
end

function RadialCalc:GetRadius()
	return math.sqrt(self:GetWidth() * self:GetHeight()) / 2;
end

function RadialCalc:GetNormalizedAngle(x, y)
	return Radial:GetNormalizedAngle(x, y)
end

---------------------------------------------------------------
Mixin(RadialMixin, RadialCalc); Radial.CalcMixin = RadialCalc;
---------------------------------------------------------------

function RadialMixin:SetSticks(sticks)
	-- Sticks drive the radial in dominance order, which is
	-- mirrored to the secure env as numbered attributes.
	local order, consumed = {}, {};
	for _, stick in ipairs(sticks) do
		local raw = RAW_STICK[stick] or stick;
		if not consumed[raw] then
			consumed[raw] = true;
			order[#order + 1] = raw;
		end
	end
	for i = 1, math.max(#(self.stickOrder or {}), #order) do
		self:SetAttribute('stick'..i, order[i])
	end
	self:SetAttribute('stick', order[1])
	self.sticks, self.stickOrder = consumed, order;
end

function RadialMixin:IsDominantStick(stick, tracker)
	for _, name in ipairs(self.stickOrder) do
		if ( name == stick ) then
			return true;
		end
		if ( (tracker[name] or 0) >= self:GetValidThreshold() ) then
			return false;
		end
	end
end

function RadialMixin:SetDynamicSizeFunction(body)
	self:SetAttribute('UpdateSize', body .. [[
		self:SetAttribute('size', size)
		return size;
	]])
	self:Execute('UpdateSize = self:GetAttribute("UpdateSize")')
end

function RadialMixin:OnLoad(data)
	self:CreateEnvironment()
	self:SetSticks(data.sticks)
	self:SetDynamicSizeFunction(data.sizer)
	if data.clicks then
		self:RegisterForClicks(data.clicks)
	end
	return self
end

function RadialMixin:OnShow()
	Dispatcher:SetFocus(self)
	db:TriggerEvent('OnRadialShown', true, self)
end

function RadialMixin:ClearInstantly()
	Dispatcher:ClearFocusInstantly(self)
end

function RadialMixin:OnHide()
	if not Dispatcher:IsDisabling() then
		Dispatcher:ClearFocus(self)
	end
	db:TriggerEvent('OnRadialShown', false, self)
end

function RadialMixin:OnInput(x, y, len, stick)
	-- replace with callback
end

function RadialMixin:OnBindingSet(btn, mod)
	-- replace with callback
end


---------------------------------------------------------------
-- Restricted pie slicer
---------------------------------------------------------------
Radial:CreateEnvironment({
	-- @param  a1    : number [0-360], first angle
	-- @param  a2    : number [0-360], second angle
	-- @return diff  : number, difference between angles
	GetAngleDistance = [[
		local a1, a2 = ...
		return (180 - math.abs(math.abs(a1 - a2) - 180));
	]];
	-- @param  index : number [1,n], the index
	-- @param  size  : number [n>0], how many indices
	-- @return angle : number [0-360], angle
	GetAngleForIndex = [[
		local index, size = ...
		local step = 360 / size
		return ((ANGLE_IDX_ONE + ((index - 1) * step)) % 360)
	]];
	-- @param  angle : number [0,360], the angle
	-- @param  size  : number [n>0], how many indices
	-- @return index : number [1,n], the slot on the pie
	GetIndexForAngle = [[
		local angle, size = ...
		local step = 360 / size
		if (angle % step) > 0 then return end
		local index = (((angle % 360) / step) - (ANGLE_IDX_ONE / step) + 1)
		return (index < 0 and index + size) or (index > 0 and index) or (size)
	]];
	-- @param  index  : number [1,n], the index
	-- @param  size   : number [n>0], how many indices
	-- @param  radius : number, multiplier for size (usually half of frame)
	-- @return x      : number, the X-position from CENTER
	-- @return y      : number, the Y-position from CENTER
	GetPointForIndex = [[
		local index, size, radius = ...
		local angle = self::GetAngleForIndex(index, size)
		return self::GetPointForAngle(angle, radius)
	]];
	-- @param  angle  : number[0, 360], the angle
	-- @param  radius : number, multiplier for size
	-- @return x      : number, the X-position from origin
	-- @return y      : number, the Y-position from origin
	GetPointForAngle = [[
		local angle, radius = ...
		return COS_DELTA * (radius * cos(angle)), (radius * sin(angle))
	]];
	-- @param  items    : number, how many items
	-- @param  id  : numberID or name
	-- @return x   : number [-1,1], X-position
	-- @return y   : number [-1,1], Y-position
	-- @return len : number [0,1], length of vector
	GetStickPosition = [[
		local id = ...
		local gstate = GetGamePadState()
		local sticks = gstate and gstate.sticks
		if not sticks then return end
		local pos = sticks[ tonumber(id) or STIX[id] ]
		if not pos then return end
		return pos.x, pos.y, pos.len
	]];
	-- @param  stickID : numberID or name
	-- @param  size    : number, how many indices
	-- @return index   : number, the slot on the pie
	GetIndexForStickPosition = [[
		local stickID, size = ...
		local x, y, len = self::GetStickPosition(stickID)
		if not len or len < VALID_VEC_LEN then return end

		local angle = math.deg(math.atan2(x, y)) + ANGLE_IDX_ONE
		angle = ((angle % 360) + 360) % 360;

		local offset, index = math.huge
		for i=1, size do
			local comp = self::GetAngleForIndex(i, size)
			local distance = self::GetAngleDistance(angle, comp)
			if distance < offset then
				offset, index = distance, i
			end
		end
		return index
	]];
	-- @return buttons : list of buttons held
	GetButtonsHeld = [[
		local gstate = GetGamePadState()
		local buttons = gstate and gstate.buttons
		if not buttons then return end
		local result = {};
		for id, held in pairs(buttons) do
			if held and BTNS[id] and not MODS[ BTNS[id] ] then
				result[#result+1] = BTNS[id]
			end
		end
		return unpack(result)
	]];
	-- @return modifiers : list of modifiers held (with suffix)
	GetModifiersHeld = [[
		local gstate = GetGamePadState()
		local buttons = gstate and gstate.buttons
		if not buttons then return end
		local result = {};
		for id, held in pairs(buttons) do
			if held and BTNS[id] then
				result[#result+1] = MODS[ BTNS[id] ]
			end
		end
		return unpack(result)
	]];
	-- @return modifiers : list of active modifiers (sorted, with suffix)
	GetActiveModifiers = [[
		local mods = { self::GetModifiersHeld() };
		if #mods > 1 then
			table.sort(mods)
			mods[#mods+1] = table.concat(mods)
		end
		return unpack(mods)
	]];
	-- @param id    : numberID or name
	-- @return bool : whether a given button is held
	IsButtonHeld = [[
		local id = ...;
		local gstate = GetGamePadState()
		local buttons = gstate and gstate.buttons
		if not buttons then return end
		return buttons[ tonumber(id) or BTNS[id] ]
	]];
})


---------------------------------------------------------------
-- Radial handler API
---------------------------------------------------------------
function Radial:Register(header, name, ...)
	header:SetFrameRef('radial', self)
	header:Execute('radial = self:GetFrameRef("radial")')

	self.Headers[header] = true;
	self:SetFrameRef(name, header)
	self:Execute(('HEADERS["%s"] = self:GetFrameRef("%s")'):format(name, name))

	-- upvalue in case predefined methods should be mixed in post load
	local OnInput, OnBindingSet = header.OnInput, header.OnBindingSet;

	db.table.mixin(header, RadialMixin)
	if OnInput then header.OnInput = OnInput; end
	if OnBindingSet then header.OnBindingSet = OnBindingSet; end;

	header:SetScale(db('radialScale'))
	header:SetRadialSize(db('radialPreferredSize'))
	db:RegisterSafeCallback('Settings/radialScale', header.SetScale, header)
	db:RegisterSafeCallback('Settings/radialPreferredSize', header.SetRadialSize, header)

	return header:OnLoad(...)
end

function Radial:OnDataLoaded()
	for attr, val in pairs({
		ANGLE_IDX_ONE = DEFAULT_ANGLE_OFFSET;
		VALID_VEC_LEN = 1 - db('radialActionDeadzone'); -- vector length for valid action
		COS_DELTA     = -db('radialCosineDelta');       -- delta for the cosine value
	}) do
		self:Execute(('%s = %f;'):format(attr, val))
		self[attr] = val
	end

	for setting, value in pairs({
		enableDeadzone = db('radialClearFocusMode') ~= 2;
		enableTimeout  = db('radialClearFocusMode') ~= 3;
		deadzone       = db('radialClearFocusDeadzone');
		timeout        = db('radialClearFocusTime');
	}) do Dispatcher[setting] = value; end

	return CPAPI.KeepMeForLater;
end

function Radial:OnActiveDeviceChanged()
	self:Execute('wipe(STIX)')
	for id, name in db:For('Gamepad/Index/Stick/ID') do
		self:Execute(('STIX["%s"] = %d'):format(name, id))
	end
	local modifiers = db('Gamepad/Index/Modifier/Active')
	local modkeys = tInvert(modifiers)
	self:Execute('wipe(BTNS)')
	for id, set in db:For('Gamepad/Index/Button/Binding') do
		if not id:match('^PAD.STICK%w+') then -- TODO: are cardinal stick buttons OK now?
			self:Execute(([[
				BTNS[%d] = "%s";
				BTNS["%s"] = %d;
			]]):format(set.ID+1, id, id, set.ID+1))
		end
	end
	self:Execute('wipe(MODS)')
	for modifier, key in pairs(modifiers) do
		if key ~= true then
			self:Execute(('MODS["%s"] = "%s"'):format(key, modifier));
		end
	end
end

function Radial:GetStickStruct(type)
	if ( not type or type == DEFAULT ) then
		type = db('radialPrimaryStick');
	end
	return ({
		Movement = {'Left', 'Movement'};
		Camera   = {'Right', 'Camera'};
		Gyro     = {'Gyro', 'Look'};
	})[type]
end

---------------------------------------------------------------
-- Unrestricted data access
---------------------------------------------------------------
function Radial:GetAngleDistance(a1, a2)
	return (180 - math.abs(math.abs(a1 - a2) - 180));
end

function Radial:GetAngleForIndex(index, size)
	if not size or size < 1 then return self.ANGLE_IDX_ONE end;
	local step = 360 / size;
	return ((self.ANGLE_IDX_ONE + ((index - 1) * step)) % 360)
end

function Radial:GetBoundingRadiansForIndex(index, size)
	if not size or size < 1 then return 0, 360, self.ANGLE_IDX_ONE end;
	local centerAngle = self:GetAngleForIndex(index, size)
	local halfstep = -(self.COS_DELTA) * 360 / size / 2;
	local startAngle = centerAngle - halfstep;
	local endAngle = centerAngle + halfstep;
	startAngle = -(math.rad(startAngle));
	endAngle = -(math.rad(endAngle) + math.pi);
	centerAngle = centerAngle - self.ANGLE_IDX_ONE;
	centerAngle =  self.COS_DELTA * -math.atan2(cos(centerAngle), self.COS_DELTA * sin(centerAngle));

	return startAngle, endAngle, centerAngle;
end

function Radial:GetPointForIndex(index, size, radius)
	local angle = self:GetAngleForIndex(index, size)
	return self.COS_DELTA * (radius * cos(angle)), (radius * sin(angle))
end

function Radial:GetNormalizedAngle(x, y)
	local angle = math.deg(math.atan2(x, y)) + self.ANGLE_IDX_ONE
	return ((angle % 360) + 360) % 360;
end

function Radial:GetIndexForStickPosition(x, y, len, size)
	local angle = self:GetNormalizedAngle(x, y)

	local offset, index = math.huge
	for i=1, size do
		local distance = self:GetAngleDistance(angle, self:GetAngleForIndex(i, size))
		if distance < offset then
			offset, index = distance, i
		end
	end
	return len and len >= self.VALID_VEC_LEN and index or nil, index;
end

function Radial:ToggleFocusFrame(frame, enabled)
	if enabled then
		Dispatcher:SetFocus(frame)
	else
		Dispatcher:ClearFocus(frame)
	end
end

---------------------------------------------------------------
-- Set environment on handler and feed stick data
---------------------------------------------------------------
RadialMixin.CreateEnvironment = Radial.CreateEnvironment;
---------------------------------------------------------------
db:RegisterSafeCallback('Gamepad/Active', Radial.OnActiveDeviceChanged, Radial)
db:RegisterSafeCallbacks(Radial.OnDataLoaded, Radial,
	'Settings/radialActionDeadzone',
	'Settings/radialCosineDelta',
	'Settings/radialClearFocusMode',
	'Settings/radialClearFocusTime',
	'Settings/radialClearFocusDeadzone'
);