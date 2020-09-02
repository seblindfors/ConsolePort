---------------------------------------------------------------
-- Radial handler for pie menus
---------------------------------------------------------------
-- This handler configures headers as pie menus, providing API
-- to convert an angle in deg. to a menu index and vice versa.
-- Keystrokes and specific stick inputs are interrupted by the
-- handler and dispatched to the display layer on the header.

local Radial, RadialMixin, _, db = CPAPI.EventHandler(ConsolePortRadial), {}, ...;
db:Register('Radial', Radial):Execute([[
	----------------------------------------------------------
	HEADERS = newtable()  -- maintain references to headers
	STICKS  = newtable()  -- track config name to stick ID
	ANGLE_IDX_ONE, VALID_VEC_LEN, COS_DELTA = 90, .5, -1;    
	----------------------------------------------------------
]])

---------------------------------------------------------------
-- RadialMixin, for headers registered as radials
---------------------------------------------------------------
RadialMixin.Env = {
	GetIndex = [[
		return radial:RunAttribute('GetIndexForStickPosition', self:GetAttribute('stick'), self:GetAttribute('size'))
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

function RadialMixin:OnGamePadStick(...)
	print(...)
end

function RadialMixin:OnLoad(data)
	-- TODO: implement data (specific stick inputs etc)
	-- may need to extend this to cover multiple needs
	self:CreateEnvironment()
	self:EnableGamePadStick(false)

	self:WrapScript(self, 'OnShow', [[
		self:EnableGamePadStick(true)
	]])
	self:WrapScript(self, 'OnHide', [[
		self:EnableGamePadStick(false)
	]])
	return self
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
	self:Execute(([[
		ANGLE_IDX_ONE = %d %% 360; -- angle at which index should start
		VALID_VEC_LEN = 1 - %d;    -- vector length for valid action
		COS_DELTA     = %d;        -- delta for the cosine value    
	]]):format(
		db('Settings/radialStartIndexAt'),
		db('Settings/radialActionDeadzone'),
		db('Settings/radialCosineDelta')
	));
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
-- Set environment on handler and feed stick data
---------------------------------------------------------------
Radial:OnDataLoaded():CreateEnvironment()
RadialMixin.CreateEnvironment = Radial.CreateEnvironment;
---------------------------------------------------------------
db:RegisterVarCallback('Gamepad/Active', Radial.OnActiveDeviceChanged, Radial)
db:RegisterVarCallback('Settings/radialStartIndexAt', Radial.OnDataLoaded, Radial)
db:RegisterVarCallback('Settings/radialActionDeadzone', Radial.OnDataLoaded, Radial)
db:RegisterVarCallback('Settings/radialCosineDelta', Radial.OnDataLoaded, Radial)