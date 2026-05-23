-- Show/hide gamepad info:
-- /gamepad

local FRAME, PoolCount = CreateFrame('Frame', 'GamePadToolFrame', UIParent), 0
local Pool = CreateObjectPool(function(self)
	PoolCount = PoolCount + 1;
	local tooltip = CreateFrame('GameTooltip', ('GamePadTooltip%d'):format(PoolCount), UIParent, 'GamepadTooltipTemplate')
	tooltip.poolRef = self;
	return tooltip;
end, CPAPI.HideAndClearAnchors)

---------------------------------------------------------------
GamepadTooltipMixin = {};
---------------------------------------------------------------

function GamepadTooltipMixin:OnLoad()
	GameTooltip_OnLoad(self);
	self:RegisterForDrag("LeftButton");
end

function GamepadTooltipMixin:OnEnter()

end

function GamepadTooltipMixin:OnLeave()

end

function GamepadTooltipMixin:OnUpdate(elapsed)

end

function GamepadTooltipMixin:OnDragStart()
	self:StartMoving();
end

function GamepadTooltipMixin:OnDragStop()
	self:StopMovingOrSizing();
	ValidateFramePosition(self);
end

function GamepadTooltipMixin:ItemRefSetHyperlink(link)
end

function GamepadTooltipMixin:SetHyperlink(...)
end

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local sort, concat = table.sort, table.concat
local function unravel(t, i)
	local k = next(t, i)
	if k ~= nil then
		return k, unravel(t, k)
	end
end
local function spairs(t, order)
	local keys = {unravel(t)}
	if order then
		sort(keys, function(a,b) return order(t, a, b) end)
	else
		sort(keys)
	end
	local i, k = 0
	return function()
		i = i + 1
		k = keys[i]
		if k then
			return k, t[k]
		end
	end
end
local function round2f(val)
	return format('%.2f', val)
end
local function formatCvar(cvar)
	local val = GetCVar(cvar)
	return val ~= nil and val or '<nil>';
end

---------------------------------------------------------------
-- Data
---------------------------------------------------------------
local Pad, btnsUI, trackers = C_GamePad, {}, {
	gamepad  = {};
	interact = {};
	cursor   = {};
}

GamepadInfo = {}
FRAME:SetPropagateKeyboardInput(true)


do local include = {
		CursorCenteredYPos = true;
		CursorStickyCentering = true;
		CameraFollowOnStick = true;
	}
	-- Gather all commands that are related to gamepads
	for i, cmd in ipairs(ConsoleGetAllCommands()) do
		if cmd.command:lower():match('gamepad') or include[cmd.command] then
			tinsert(trackers.gamepad, cmd)
		end
		if cmd.command:lower():match('softtarget') then
			tinsert(trackers.interact, cmd)
		end
		if cmd.command:lower():match('^target') then
			tinsert(trackers.interact, cmd)
		end
		if cmd.command:lower():match('cursor') then
			tinsert(trackers.cursor, cmd)
		end
	end
	for _, tracker in pairs(trackers) do
		table.sort(tracker, function(a, b) return a.command < b.command end)
	end
end

local function showConsoleVars(tooltip, data)
	for i, cmd in ipairs(data) do
		tooltip:AddDoubleLine(cmd.command, formatCvar(cmd.command), 1, 1, 1, 1, 1, 0)
	end
	tooltip:Show()
end

local focused
local function showConsoleVarDetails(tooltip, data, i)
	local line = _G[('%sTextLeft%d'):format(tooltip:GetName(), i)]
	local cmd = data[i-1]
	if line and cmd and line:IsMouseOver() then
		if (focused ~= line) then
			GameTooltip:SetOwner(tooltip, 'ANCHOR_CURSOR')
			GameTooltip:SetText(cmd.command)
			GameTooltip:AddDoubleLine('Value', formatCvar(cmd.command), 0, 1, 0, 1, 1, 0)
			GameTooltip:AddLine(cmd.help, 1, 1, 1)
			GameTooltip:Show()
			focused = line;
		end
	end
end

local function showRealtimeInfo(tooltip)
	local id = GamePadID or Pad.GetActiveDeviceID()
	if id then
		-- Devices (raw)
		tooltip:AddDoubleLine('Name (raw)', 'ID, Vendor, Product')
		for _, i in ipairs(Pad.GetAllDeviceIDs()) do
			local device = Pad.GetDeviceRawState(i)
			if device then
				tooltip:AddDoubleLine(
					device.name,
					concat({i, device.vendorID, device.productID}, ', '),
					1, 1, 1, 1, 1, 1
				);
			end
		end
		-- Devices (mapped)
		tooltip:AddDoubleLine('Name (mapped)', 'ID')
		for _, i in ipairs(Pad.GetAllDeviceIDs()) do
			local device = Pad.GetDeviceMappedState(i)
			if device then
				tooltip:AddDoubleLine(device.name, i, 1, 1, 1, 1, 1, 1)
			end
		end
		tooltip:AddDoubleLine('Active Device ID', id, 0, 1, 0, 0, 1, 0)
		local map = Pad.GetDeviceMappedState(id)
		-- Axis readings
		tooltip:AddLine('Axis Readings')
		local axes = map.axes
		for i = 1, #axes, 2 do
			local v1, v2 = round2f(axes[i]), round2f(axes[i+1])
			tooltip:AddDoubleLine(
				v1, v2,
				1-v1, 1+v1, 1,
				1-v2, 1+v2, 1
			);
		end
		tooltip:AddDoubleLine('ButtonID', 'Index')
		for i, down in ipairs(map.buttons) do
			local flag = down and 0 or 1
			local bind = Pad.ButtonIndexToBinding(i-1)
			--GamepadInfo[i] = {conf, bind}
			tooltip:AddDoubleLine(
				bind,
				i-1,
				flag, 1, flag,
				flag, 1, flag
			);
		end
	end
	tooltip:Show()
end

local function showFrontendInfo()
	TT:AddDoubleLine('State (OnGamePadButton*)', 'BindingID')
	for btn, state in spairs(btnsUI) do
		local flag = state and 0 or 1
		TT:AddDoubleLine(state and 'Down' or 'Up', btn,
			flag, 1, flag,
			flag, 1, flag
		);
	end
end

local size = 350
local half = size / 2
FRAME:Hide()
FRAME:SetSize(size, size)
FRAME:SetPoint('LEFT', TT, 'RIGHT', 0, 0)
FRAME:SetScript('OnGamePadStick', function(self, stick, x, y, len)
	if self.axisInfo then
		if not self[stick] then
			self.axisCount = (self.axisCount or 0) + 1
			local pointer = self:CreateTexture(nil, 'ARTWORK')
			local r, g, b = random(100) / 100, random(100) / 100, random(100) / 100
			pointer:SetSize(size / 20, size / 20)
			pointer:SetColorTexture(r, g, b)
			self[stick] = pointer

			local text = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
			text:SetTextColor(r, g, b)
			text:SetText(stick)
			text.point = {'BOTTOMLEFT', 16, self.axisCount * 12}
			self[stick].Text = text

			local textsquare = self:CreateTexture(nil, 'ARTWORK')
			textsquare:SetSize(8, 8)
			textsquare:SetPoint('RIGHT', text, 'LEFT', -2, 0)
			textsquare:SetColorTexture(r, g, b)
			self[stick].Square = textsquare

			local line = self:CreateTexture(nil, 'ARTWORK')
			line:SetSize(4, size)
			line:SetPoint('CENTER')
			line:SetColorTexture(r, g, b)
			self[stick].Line = line
		end
		local obj = self[stick]
		local alpha = Clamp(tonumber(len) or 0, 0, 1)
		obj:SetParent(self.axisInfo)
		obj:SetAlpha(alpha)
		obj:SetPoint('CENTER', (x * half), (y * half))
		obj.Line:SetRotation(-math.atan2(x, y))
		obj.Line:SetAlpha(alpha)
		obj.Line:SetParent(self.axisInfo)
		obj.Text:SetParent(self.axisInfo)
		obj.Text:SetPoint(unpack(obj.Text.point))
		obj.Text:SetFormattedText('%s: %.2f, %.2f', stick, x, y)
		obj.Square:SetParent(self.axisInfo)
	end
end)



FRAME:SetScript('OnGamePadButtonUp', function(_, button)
	btnsUI[button] = false
end)
FRAME:SetScript('OnGamePadButtonDown', function(_, button)
	btnsUI[button] = true
end)

FRAME:SetScript('OnHide', function(self)
	Pool:ReleaseAll()
end)

FRAME:SetScript('OnShow', function(self)
	self.consoleVars = Pool:Acquire()
	self.interactVars = Pool:Acquire()
	self.cursorVars = Pool:Acquire()
	self.realtimeInfo = Pool:Acquire()
	self.axisInfo = Pool:Acquire()

	self.consoleVars:SetOwner(UIParent, 'ANCHOR_PRESERVE')
	self.interactVars:SetOwner(UIParent, 'ANCHOR_PRESERVE')
	self.cursorVars:SetOwner(UIParent, 'ANCHOR_PRESERVE')

	self.realtimeInfo:SetOwner(UIParent, 'ANCHOR_PRESERVE')
	self.axisInfo:SetOwner(UIParent, 'ANCHOR_PRESERVE')

	self.consoleVars:SetPoint('TOPLEFT')
	self.interactVars:SetPoint('TOPRIGHT')
	self.cursorVars:SetPoint('TOP')

	self.realtimeInfo:SetPoint('BOTTOMRIGHT')
	self.axisInfo:SetPoint('BOTTOMLEFT')

	self.axisInfo:SetText('Axis')
	self.axisInfo:Show()
	self.axisInfo:SetSize(400, 400)
end)

local throttle = 0.25
local timer = 0

local function showTooltipFrame(self, frame, text, commands)
	if frame then
		frame:SetText(text)
		showConsoleVars(frame, commands)
		if frame:IsMouseOver() then
			for i=2, frame:NumLines() do
				showConsoleVarDetails(frame, commands, i)
			end
			timer = timer - throttle
		elseif GameTooltip:IsOwned(frame) then
			GameTooltip:Hide()
		end
	end
end

FRAME:SetScript('OnUpdate', function(self, elapsed)
	showTooltipFrame(self, self.consoleVars, 'Variables', trackers.gamepad)
	showTooltipFrame(self, self.interactVars, 'Interact', trackers.interact)
	showTooltipFrame(self, self.cursorVars, 'Cursor', trackers.cursor)
	if self.realtimeInfo then
		self.realtimeInfo:SetText('Gamepad')
		showRealtimeInfo(self.realtimeInfo)
	end
end)

local _ = 'Gamepad'
_G['SLASH_' .. _:upper() .. '1'] = '/' .. _:lower()
SlashCmdList[_:upper()] = function(message)
	FRAME:SetShown(not FRAME:IsShown())
end