---------------------------------------------------------------
-- Radial handler for pie menus
---------------------------------------------------------------
-- This handler configures headers as pie menus, providing API
-- to convert an angle in deg. to a menu index and vice versa.
-- Keystrokes and specific stick inputs are interrupted by the
-- handler and dispatched to the display layer on the header.

local Radial, Dispatcher, RadialMixin, _, db = CPAPI.EventHandler(ConsolePortRadial), CreateFrame('Frame'), {}, ...;
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
-- Dispatcher
---------------------------------------------------------------
-- This frame is necessary to intercept the stick input, and
-- needs to be insecure to propagate input based on stickID.

function Dispatcher:OnGamePadStick(stick, x, y, len)
	local this = self.focusFrame
	if this and this.interrupt[stick] then
		if this.intercept[stick] and not self.disabled then
			this:OnInput(x, y, len, stick)
		end
		return self:SetPropagateKeyboardInput(false)
	end
	return self:SetPropagateKeyboardInput(true)
end

function Dispatcher:SetFocus(frame)
	self.focusFrame = frame;
	self:EnableGamePadStick(true)
end

function Dispatcher:ClearFocus(frame)
	if self.focusFrame ~= frame then return end;
	self.disabled = true
	C_Timer.After(db('radialClearFocusTime'), self.Disable)
end

function Dispatcher:ClearFocusInstantly(frame)
	if self.focusFrame ~= frame then return end;
	self.Disable()
end

function Dispatcher:IsDisabling()
	return self.disabled
end

function Dispatcher.Disable() -- callback
	Dispatcher.disabled = nil;
	Dispatcher.focusFrame = nil;
	Dispatcher:EnableGamePadStick(false);
end

CPAPI.Start(Dispatcher)
Dispatcher:SetPropagateKeyboardInput(true)
Dispatcher:EnableGamePadStick(false)


---------------------------------------------------------------
-- RadialMixin, for headers registered as radials
---------------------------------------------------------------
RadialMixin.Env = {
	GetIndex = [[
		local stickID, size = ...
		return radial:RunAttribute(
			'GetIndexForStickPosition',
			stickID or self:GetAttribute('stick'),
			size or UpdateSize and self:Run(UpdateSize) or
			self:GetAttribute('size')
		);
	]];
	GetButtonsHeld = [[
		return radial:RunAttribute('GetButtonsHeld')
	]];
	GetModifiersHeld = [[
		return radial:RunAttribute('GetModifiersHeld')
	]];
	SpaceEvenly = [[
		local children = newtable(self:GetChildren())
		local radius = math.sqrt(self:GetWidth() * self:GetHeight()) / 2
		local count = #children
		self:SetAttribute('size', count)
		for i, child in ipairs(children) do
			child:ClearAllPoints()
			child:SetPoint('CENTER', radial:RunAttribute('GetPointForIndex', i, count, radius))
		end
	]];
	SetBinding = [[
		local btn, mod = ...
		self:SetBindingClick(true, ((mod or '')..btn):upper(), self, btn)
		self:CallMethod('OnBindingSet', btn, mod)
	]];
	SetBindingsForTriggers = [[
		local mods = newtable(self:Run(GetModifiersHeld))
		local btns = newtable(self:Run(GetButtonsHeld))
		table.sort(mods)
		mods[#mods+1] = table.concat(mods)

		for _, btn in ipairs(btns) do
			self:Run(SetBinding, btn)
			for _, mod in ipairs(mods) do
				self:Run(SetBinding, btn, mod)
			end
		end
		return #btns > 0;
	]];
}

function RadialMixin:SetInterrupt(sticks)
	-- sets the sticks that should be interrupted
	self.interrupt = sticks and tInvert(sticks) or {}
end

function RadialMixin:SetIntercept(sticks)
	-- sets the stick(s) that should be processed,
	-- 1st argument is used implicitly in secure env
	self.intercept = sticks and tInvert(sticks) or {}
	self:SetAttribute('stick', sticks and sticks[1])
end

function RadialMixin:SetDynamicSizeFunction(body)
	self:SetAttribute('UpdateSize', body .. [[
		self:SetAttribute('size', size)
		return size;
	]])
	self:Execute('UpdateSize = self:GetAttribute("UpdateSize")')
end

function RadialMixin:GetPointForIndex(index, size, radius)
	return 'CENTER', Radial:GetPointForIndex(index, size or self:GetAttribute('size'), radius or (self:GetWidth() / 2))
end

function RadialMixin:GetIndexForPos(x, y, len, size)
	return Radial:GetIndexForStickPosition(x, y, len, size or self:GetAttribute('size'))
end

function RadialMixin:GetValidThreshold()
	return Radial.VALID_VEC_LEN or .5;
end

function RadialMixin:OnLoad(data)
	self:CreateEnvironment()
	self:SetInterrupt(data.sticks)
	self:SetIntercept(data.target)
	self:SetDynamicSizeFunction(data.sizer)
	if data.clicks then
		self:RegisterForClicks(data.clicks)
	end
	return self
end

function RadialMixin:OnShow()
	Dispatcher:SetFocus(self)
end

function RadialMixin:ClearInstantly()
	Dispatcher:ClearFocusInstantly(self)
end

function RadialMixin:OnHide()
	if not Dispatcher:IsDisabling() then
		Dispatcher:ClearFocus(self)
	end
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
		local angle = self:Run(GetAngleForIndex, index, size)
		return self:Run(GetPointForAngle, angle, radius)
	]];
	-- @param  angle  : number[0, 360], the angle
	-- @param  radius : number, multiplier for size
	-- @return x      : number, the X-position from origin
	-- @return y      : number, the Y-position from origin
	GetPointForAngle = [[
		local angle, radius = ...
		return COS_DELTA * (radius * cos(angle)), (radius * sin(angle))
	]];
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
		local x, y, len = self:Run(GetStickPosition, stickID)
		if not len or len < VALID_VEC_LEN then return end

		local angle = math.deg(math.atan2(x, y)) + ANGLE_IDX_ONE
		angle = ((angle % 360) + 360) % 360;

		local offset, index = math.huge
		for i=1, size do
			local comp = self:Run(GetAngleForIndex, i, size)
			local distance = self:Run(GetAngleDistance, angle, comp)
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
		local result = newtable()
		for id, held in ipairs(buttons) do
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
		local result = newtable()
		for id, held in ipairs(buttons) do
			if held and BTNS[id] then
				result[#result+1] = MODS[ BTNS[id] ]
			end
		end
		return unpack(result)
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

	db('table/mixin')(header, RadialMixin)
	if OnInput then header.OnInput = OnInput; end
	if OnBindingSet then header.OnBindingSet = OnBindingSet; end;

	header:SetScale(db('radialScale'))
	db:RegisterSafeCallback('Settings/radialScale', header.SetScale, header)

	return header:OnLoad(...)
end

function Radial:OnDataLoaded()
	for attr, val in pairs({
		ANGLE_IDX_ONE = 90;
		VALID_VEC_LEN = 1 - db('Settings/radialActionDeadzone'); -- vector length for valid action
		COS_DELTA     = -db('Settings/radialCosineDelta');       -- delta for the cosine value
	}) do
		self:Execute(('%s = %f;'):format(attr, val))
		self[attr] = val
	end
	return self
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
		if not id:match('STICK') then
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
	return self
end

function Radial:GetStickStruct(type)
	return ({
		Movement = {'Left', 'Movement'};
		Camera   = {'Right', 'Camera'};
	})[type]
end


---------------------------------------------------------------
-- Unrestricted data access
---------------------------------------------------------------
function Radial:GetAngleDistance(a1, a2)
	return (180 - math.abs(math.abs(a1 - a2) - 180));
end

function Radial:GetAngleForIndex(index, size)
	local step = 360 / size
	return ((self.ANGLE_IDX_ONE + ((index - 1) * step)) % 360)
end

function Radial:GetPointForIndex(index, size, radius)
	local angle = self:GetAngleForIndex(index, size)
	return self.COS_DELTA * (radius * cos(angle)), (radius * sin(angle))
end

function Radial:GetIndexForStickPosition(x, y, len, size)
	if not len or len < self.VALID_VEC_LEN then return end
	local angle = math.deg(math.atan2(x, y)) + self.ANGLE_IDX_ONE
	angle = ((angle % 360) + 360) % 360;

	local offset, index = math.huge
	for i=1, size do
		local distance = self:GetAngleDistance(angle, self:GetAngleForIndex(i, size))
		if distance < offset then
			offset, index = distance, i
		end
	end
	return index
end


---------------------------------------------------------------
-- Set environment on handler and feed stick data
---------------------------------------------------------------
RadialMixin.CreateEnvironment = Radial.CreateEnvironment;
---------------------------------------------------------------
db:RegisterSafeCallback('Gamepad/Active', Radial.OnActiveDeviceChanged, Radial)
db:RegisterSafeCallback('Settings/radialActionDeadzone', Radial.OnDataLoaded, Radial)
db:RegisterSafeCallback('Settings/radialCosineDelta', Radial.OnDataLoaded, Radial)