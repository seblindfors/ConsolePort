---------------------------------------------------------------
-- Button.lua: Secure action button management 
---------------------------------------------------------------
-- Creates all secure action buttons used by the addon.
-- These buttons are also used to bind UI widgets, since
-- direct 'clicking' causes taint to spread in a lot of cases.
-- These buttons are under-the-hood and invisible to the user.

local _, db = ...
local CORE, HANDLE, KEY = ConsolePort, ConsolePortButtonHandler, db.KEY
---------------------------------------------------------------
local Button = {}
---------------------------------------------------------------
RegisterStateDriver(HANDLE, 'combat', '[combat] true; nil')
HANDLE:SetAttribute('_onstate-combat', [[
	control:ChildUpdate('combat', newstate)
]])
---------------------------------------------------------------

-- Input scripts
---------------------------------------------------------------
function Button:OnMouseDown()
	local func = self:GetAttribute('type')
	local click = self:GetAttribute('clickbutton')
	self.state = KEY.STATE_DOWN
	self.timer = 0
	-- simulate button clicks by setting pushed state on focused button
	if 	(func == 'click' or func == 'action') and click then
		click:SetButtonState('PUSHED')
		return
	end
	-- Fire function twice where keystate is requested
	if 	self[func] then self[func](self) end
end

function Button:OnMouseUp()
	local func = self:GetAttribute('type')
	local click = self:GetAttribute('clickbutton')
	self.state = KEY.STATE_UP
	-- revert simulated button click
	if 	(func == 'click' or func == 'action') and click then
		click:SetButtonState('NORMAL')
	end
end

function Button:PostClick()
	local click = self:GetAttribute('clickbutton')
	if click and not click:IsEnabled() then
		self:SetAttribute('clickbutton', nil)
	end
end

-- Run UI control 
---------------------------------------------------------------
function Button:UIControl()
	self:Show()
	CORE:UIControl(self.command, self.state)
end

-- Clear button override
---------------------------------------------------------------
function Button:Clear(manualClear)
	self.timer = 0
	self.state = KEY.STATE_UP
	if manualClear then
		self:Hide()
		self:SetAttribute('clickbutton', nil)
	end
end

-- HotKey textures and indicators
---------------------------------------------------------------
function Button:ShowHotkey(index, actionButton)
	local hotkey = self.HotKeys[index]
	hotkey:SetParent(actionButton)
	hotkey:ClearAllPoints()
	hotkey:SetPoint('TOPRIGHT', actionButton, 0, 0)
	hotkey:Show()
end

function Button:ShowInterfaceHotkey(custom, forceStyle)
	for i, hotkey in pairs(self.HotKeys) do
		hotkey:Hide()
	end
	self.HotKeys[1] = self.HotKeys[1] or self:CreateHotkey(forceStyle)
	self:ShowHotkey(1, custom or self.action)
end

---------------------------------------------------------------

-- Variables to be mixed in on init
Button.timer = 0
Button.state = KEY.STATE_UP

-- Optional repeater
local function CheckHeldDown(self, elapsed)
	self.timer = self.timer + elapsed
	if self.timer >= self.tickNext and self.state == KEY.STATE_DOWN then
		local func = self:GetAttribute('type')
		if func and func ~= 'action' and self[func] then self[func](self) end
		self.timer = 0
	end
end

local keyUpdate = {
	[KEY.UP] = {'OnUpdate', CheckHeldDown},
	[KEY.DOWN] = {'OnUpdate', CheckHeldDown},
	[KEY.LEFT] = {'OnUpdate', CheckHeldDown},
	[KEY.RIGHT] = {'OnUpdate', CheckHeldDown},
}

---------------------------------------------------------------
-- SecureButton: Set/get
---------------------------------------------------------------
function ConsolePort:SetSecureButton(name, modifier, command)
	local btn = CreateFrame('Button', name..modifier, ConsolePortButtonHandler, 'SecureActionButtonTemplate, SecureHandlerBaseTemplate')
	btn:Hide()
	btn.command = command
	btn.name = name
	btn.mod = modifier
	-----------------------------------------------------------
	btn.HotKeys = {}
	btn.CreateHotkey = db.CreateHotkey
	-----------------------------------------------------------
	btn:SetAttribute('_childupdate-combat', [[
		if message then
			self:SetAttribute('clickbutton', nil)
			self:Hide()
			self:CallMethod('Clear')
		end
	]])
	-----------------------------------------------------------
	db.table.mixin(btn, Button)
	-----------------------------------------------------------
	local keyUpdate = keyUpdate[command]
	if keyUpdate and not db('UIdisableHoldRepeat') then
		btn.tickNext = db('UIholdRepeatDelay')
		btn:SetScript(unpack(keyUpdate))
	end
    db.SECURE[btn] = true
    return btn
end

function ConsolePort:GetSecureButton(name, modifier)
	return _G[name .. modifier]
end

---------------------------------------------------------------
-- SecureButton: secure navigation (NYI)
---------------------------------------------------------------

--[[
-- raid cursor filters:
local function _filternode()
	local node = node
	local unit = node:GetAttribute('unit')
	local action = node:GetAttribute('action')

	if unit and not action then
		if self:RunAttribute('_isdrawn', node:GetRect()) then
			CACHE[node] = true
			NODES[node] = true
		end
	elseif action and tonumber(action) then
		ACTION[node] = unit or false
		CACHE[node] = true
	end
end

local function _filterchild()
	if not node or not child then return end
	local nodeunit  = node:GetAttribute('unit')
	local childunit = child:GetAttribute('unit')
	return (childunit == nil) or (childunit ~= nodeunit)
end

local function _filterold()
	return UnitExists(oldnode:GetAttribute('unit'))
end
]]
---------------------------------------------------------------
local ENV_DPAD = {
	-----------------------------------------------------------
	-- Default filters
	-----------------------------------------------------------
	_filternode = [[
		if self:RunAttribute('_isdrawn', node:GetRect()) then
			CACHE[node] = true
			NODES[node] = true
		end
	]];
	-----------------------------------------------------------
	_filterchild = [[
		return child and not child:GetAttribute('ignoreNode')
	]];
	-----------------------------------------------------------
	_filterold = [[
		return true
	]];
	-----------------------------------------------------------
	-- Node recognition and caching
	-----------------------------------------------------------
	_updatenodes = [[
		for i, object in ipairs(newtable(self:GetParent():GetChildren())) do
			node = object; self:RunAttribute('_getnodes');
		end
	]];
	-----------------------------------------------------------
	_getnodes = [[
		if node and node:IsProtected() then
			self:RunAttribute('_childscan')
			self:RunAttribute('_cachenode')
		end
	]];
	-----------------------------------------------------------
	_childscan = [[
		local parent = node
		for i, object in ipairs(newtable(parent:GetChildren())) do
			if object:IsProtected() then
				child = object
				if self:RunAttribute('_filterchild') then
					node = child; self:RunAttribute('_getnodes')
				end
			end
		end
		node = parent
	]];
	-----------------------------------------------------------
	_cachenode = [[
		if not CACHE[node] then
			self:RunAttribute('_filternode')
		end
	]];
	-----------------------------------------------------------
	-- Rectangle properties
	-----------------------------------------------------------
	_getcenter = [[
		local rL, rB, rW, rH = ...
		return (rL + rW / 2), (rB + rH / 2)
	]];
	-----------------------------------------------------------
	_isdrawn = [[
		local rL, rB, rW, rH = ...
		return rL and rB and rW > 0 and rH > 0
	]];
	-----------------------------------------------------------
	_absxy = [[
		local x1, x2, y1, y2 = ...
		local x, y = abs(x1 - x2), abs(y1 - y2)
		return x, y, x + y
	]];
	-----------------------------------------------------------
	_sumxy = [[
		return select(3, self:RunAttribute('_absxy', ...))
	]];
	-----------------------------------------------------------
	-- Node selection
	-----------------------------------------------------------
	_setnodebydistance = [[
		local cX, cY = ...
		local targ, dest
		if cX and cY then
			for node in pairs(NODES) do
				if (node ~= old) and node:IsVisible() then
					local nX, nY = self:RunAttribute('_getcenter', node:GetRect())
					local dist = self:RunAttribute('_sumxy', cX, nX, cY, nY)

					if not dest or dist < dest then
						targ = node
						dest = dist
					end
				end
			end
			if targ then
				curnode = targ
				return true
			end
		end
	]];
	-----------------------------------------------------------
	_setnodebyshown = [[
		for node in pairs(NODES) do
			if node:IsVisible() then
				curnode = node
				break
			end
		end
	]];
	-----------------------------------------------------------
	_setanynode = [[
		local old = oldnode
		if old and old:IsVisible() and self:RunAttribute('_filterold') then
			curnode = old; return;
		end
		if (not curnode or not curnode:IsVisible()) and next(NODES) then
			local cX, cY = self:RunAttribute('_getcenter', self:GetRect())
			if not self:RunAttribute('_setnodebydistance', cX, cY) then
				self:RunAttribute('_setnodebyshown')
			end
		end
	]];
	-----------------------------------------------------------
	_keyUP    = [[ local tX, tY, nX, nY, dX, dY = ... return dY > dX and nY > tY ]];
	_keyDOWN  = [[ local tX, tY, nX, nY, dX, dY = ... return dY > dX and nY < tY ]];
	_keyLEFT  = [[ local tX, tY, nX, nY, dX, dY = ... return dY < dX and nX < tX ]];
	_keyRIGHT = [[ local tX, tY, nX, nY, dX, dY = ... return dY < dX and nX > tX ]];
	-----------------------------------------------------------
	_setnodebykey = [[
		local key = ...
		if curnode and (key ~= 0) then
			local rL, rB, rW, rH = curnode:GetRect()
			local tX, tY = self:RunAttribute('_getcenter', curnode:GetRect())
			local cX, cY = math.huge, math.huge
			for node in pairs(NODES) do
				local nX, nY = self:RunAttribute('_getcenter', node:GetRect())
				local dX, dY, dist = self:RunAttribute('_absxy', tX, nX, tY, nY)

				if ( dist < cX + cY ) then
					if self:RunAttribute('_key' .. key, tX, tY, nX, nY, dX, dY) then
						curnode, cX, cY = node, dX, dY;
					end
				end
			end
		end
	]];
	-----------------------------------------------------------
	_selectnewnode = [[
		if curnode then oldnode = curnode; end
		self:RunAttribute('_setanynode')
		self:RunAttribute('_setnodebykey', ...)
		self:RunAttribute('_postnodeselect')
	]];
}
--------------------------------------------------
