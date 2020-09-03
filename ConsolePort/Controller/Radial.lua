---------------------------------------------------------------
-- Radial handler for pie menus
---------------------------------------------------------------
-- This handler configures headers as pie menus, providing API
-- to convert an angle in deg. to a menu index and vice versa.
-- Keystrokes and specific stick inputs are interrupted by the
-- handler and dispatched to the display layer on the header.

local Radial, Dispatcher, RadialMixin, _, db = CPAPI.EventHandler(ConsolePortRadial), CreateFrame('Frame'), {}, ...;
db:Register('Radial', Radial):Execute([[
	----------------------------------------------------------
	HEADERS = newtable()  -- maintain references to headers
	STICKS  = newtable()  -- track config name to stick ID
	ANGLE_IDX_ONE, VALID_VEC_LEN, COS_DELTA = 90, .5, -1;    
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
		if this.intercept[stick] then
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
	self.focusFrame = nil;
	self:EnableGamePadStick(false)
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
			size or self:GetAttribute('size')
		);
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

function RadialMixin:GetPointForIndex(index)
	return 'CENTER', Radial:GetPointForIndex(index, self:GetAttribute('size'), self:GetWidth())
end

function RadialMixin:GetIndexForPos(x, y, len)
	return Radial:GetIndexForStickPosition(x, y, len, self:GetAttribute('size'))
end

function RadialMixin:OnLoad(data)
	self:CreateEnvironment()
	self:SetInterrupt(data.sticks)
	self:SetIntercept(data.target)
	self:SetAttribute('size', data.size)

	self:WrapScript(self, 'OnShow', [[
		-- crickets
	]])
	self:WrapScript(self, 'OnHide', [[
		-- crickets
	]])
	return self
end

function RadialMixin:OnShow()
	Dispatcher:SetFocus(self)
end

function RadialMixin:OnHide()
	Dispatcher:ClearFocus(self)
end

function RadialMixin:OnInput(x, y, len, stick)
	-- replace with callback
end


---------------------------------------------------------------
-- Restricted pie slicer
---------------------------------------------------------------
Radial.Env = {
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
		return COS_DELTA * (radius * math.cos(angle)), (radius * math.sin(angle))
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
		local pos = sticks[ tonumber(id) or STICKS[id] ]
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
		local offset, index = math.huge
		for i=1, size do
			local distance = math.abs(angle - self:Run(GetAngleForIndex, i, size))
			if distance < offset then
				offset, index = distance, i
			end
		end
		return index
	]];
}


---------------------------------------------------------------
-- Radial handler API
---------------------------------------------------------------
function Radial:Register(header, name, ...)
	header:SetFrameRef('radial', self)
	header:Execute('radial = self:GetFrameRef("radial")')
	self:SetFrameRef(name, header)
	self:Execute(('HEADERS["%s"] = self:GetFrameRef("%s")'):format(name, name))
	db('table/mixin')(header, RadialMixin)
	return header:OnLoad(...)
end

function Radial:OnDataLoaded()
	for attr, val in pairs({
		ANGLE_IDX_ONE = db('Settings/radialStartIndexAt') % 360; -- angle at which index should start
		VALID_VEC_LEN = 1 - db('Settings/radialActionDeadzone'); -- vector length for valid action
		COS_DELTA     = db('Settings/radialCosineDelta');        -- delta for the cosine value
	}) do
		self:Execute(('%s = %d;'):format(attr, val))
		self[attr] = val
	end
	return self
end

function Radial:OnActiveDeviceChanged()
	self:Execute('wipe(STICKS)')
	for id, name in db:For('Gamepad/Index/Stick/ID') do
		self:Execute(('STICKS["%s"] = %d'):format(name, id))
	end
	return self
end

function Radial:CreateEnvironment()
	for func, body in pairs(self.Env) do
		self:SetAttribute(func, body)
		self:Execute(('%s = self:GetAttribute("%s")'):format(func, func))
	end
	return self
end


---------------------------------------------------------------
-- Unrestricted data access
---------------------------------------------------------------
function Radial:GetAngleForIndex(index, size)
	local step = 360 / size
	return ((self.ANGLE_IDX_ONE + ((index - 1) * step)) % 360)
end

function Radial:GetPointForIndex(index, size, radius)
	local angle = self:GetAngleForIndex(index, size)
	return self.COS_DELTA * (radius * math.cos(angle)), (radius * math.sin(angle))
end

function Radial:GetIndexForStickPosition(x, y, len, size)
	if not len or len < self.VALID_VEC_LEN then return end
	local angle = math.deg(math.atan2(x, y)) + self.ANGLE_IDX_ONE
	local offset, index = math.huge
	for i=1, size do
		local distance = math.abs(angle - self:GetAngleForIndex(i, size))
		if distance < offset then
			offset, index = distance, i
		end
	end
	return index
end


---------------------------------------------------------------
-- Set environment on handler and feed stick data
---------------------------------------------------------------
Radial:CreateEnvironment()
RadialMixin.CreateEnvironment = Radial.CreateEnvironment;
---------------------------------------------------------------
db:RegisterVarCallback('Gamepad/Active', Radial.OnActiveDeviceChanged, Radial)
db:RegisterVarCallback('Settings/radialStartIndexAt', Radial.OnDataLoaded, Radial)
db:RegisterVarCallback('Settings/radialActionDeadzone', Radial.OnDataLoaded, Radial)
db:RegisterVarCallback('Settings/radialCosineDelta', Radial.OnDataLoaded, Radial)