local Radial, _, db = ConsolePortRadial, ...;
local ANGLE_IDX_ONE, VALID_VEC_LEN = 90, 0.5;
db:Register('Radial', Radial)
Radial:Execute(([[
	STICKS = newtable()
	ANGLE_IDX_ONE = %d
	VALID_VEC_LEN = %d

]]):format(ANGLE_IDX_ONE, VALID_VEC_LEN))

function Radial:OnActiveDeviceChanged()
	self:Execute('wipe(STICKS)')
	for id, name in db:For('Gamepad/Index/Stick/ID') do
		self:Execute(('STICKS["%s"] = %d'):format(name, id))
	end
end

db:RegisterVarCallback('Gamepad/Active', Radial.OnActiveDeviceChanged, Radial)


Radial.Env = {
	---------------------------------------------------------------
	-- Simple pie slicer
	---------------------------------------------------------------
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
		return -(radius * math.cos(angle)), (radius * math.sin(angle))
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

for func, body in pairs(Radial.Env) do
	Radial:SetAttribute(func, body)
	Radial:Execute(('%s = self:GetAttribute("%s")'):format(func, func))
end