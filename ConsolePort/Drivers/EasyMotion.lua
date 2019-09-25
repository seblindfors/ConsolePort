---------------------------------------------------------------
-- EasyMotion.lua: Combo shortcuts for targeting
---------------------------------------------------------------
-- Creates a set of combinations for different pools of units,
-- in order to alleviate targeting. A healer's delight. 
-- Thanks to Yoki for original concept! :) 

local addOn, db = ...
---------------------------------------------------------------
-- Key sets and their integer identifiers for input processing
local Key = {
	L = {
		UP 		= ConsolePort:GetUIControlKey('CP_L_UP'),
		DOWN 	= ConsolePort:GetUIControlKey('CP_L_DOWN'),
		LEFT 	= ConsolePort:GetUIControlKey('CP_L_LEFT'),
		RIGHT 	= ConsolePort:GetUIControlKey('CP_L_RIGHT'),
	},
	R = {
		UP		= ConsolePort:GetUIControlKey('CP_R_UP'),
		DOWN 	= ConsolePort:GetUIControlKey('CP_R_DOWN'),
		LEFT 	= ConsolePort:GetUIControlKey('CP_R_LEFT'),
		RIGHT 	= ConsolePort:GetUIControlKey('CP_R_RIGHT'),
	},
}

local Index = {}
for side, set in pairs(Key) do
	for name, id in pairs(set) do
		Index[id] = ('CP_%s_%s'):format(side, name)
	end
end

---------------------------------------------------------------
-- Get action/input handlers, EasyMotion -> EM for brevity
local EM, Input = ConsolePortEasyMotionButton, ConsolePortEasyMotionInput
-- Link functions for world targeting
EM.HighlightTarget = TargetPriorityHighlightStart
EM.GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit

-- Mixin functions for the hotkey display
local HotkeyMixin, GroupMixin = {}, {}

-- Initialize secure namespace
---------------------------------------------------------------
EM:Execute([[
	-- References to other frames
	headers = newtable()

	-- Unit tables
	units, ignore, plates, sorted = newtable(), newtable(), newtable(), newtable()

	-- Binding tables
	btns, bindings, lookup = newtable(), newtable(), newtable()

	-- Ignore mouseover/target
	ignore.mouseover = true
	ignore.target = true

	bindRef = 'ConsolePortEasyMotionInput'
	MAX = self:GetAttribute('maxcombos')
]])

for side, set in pairs(Key) do
	EM:Execute('btns.'..side..' = newtable()')
	for name, keyID in pairs(set) do
		EM:Execute(format([[ btns.%s.%s = '%s' ]], side, name, keyID))
	end
end

-- Run snippets
---------------------------------------------------------------
for name, script in pairs({
	-- Parse the input
	Input = [[
		key = ...
		input = input and tonumber( input .. key ) or tonumber(key)
		self:CallMethod('Filter', tostring(input))
	]],
	
	-- Set the new target
	SetTarget = [[
		local unit = lookup[input]
		if unit then
			self:SetAttribute('macrotext', '/target '..unit)
		elseif defaultToTab then
			self:SetAttribute('macrotext', '/targetenemy')
		end

		self:ClearBindings()

		if self:GetAttribute('ghostMode') then
			self:CallMethod('HideBindings', unit, true)
			self:RunAttribute('DisplayBindings', true)
			self:RunAttribute('Wipe')
		else
			self:RunAttribute('Wipe')
			self:CallMethod('HideBindings', unit)
		end

		pool = nil
	]],

	-- Create key combinations e.g. -> (1, 2, 3, ..., 12, 13, 14, ..., 122, 123, 124)
	CreateBindings = [[
		-- instantiate a keySet with a fixed format
		local keySet = newtable(set.UP, set.LEFT, set.DOWN, set.RIGHT)
		local current = 1

		for _, k1 in ipairs(keySet) do
			bindings[current] = tonumber(k1)
			current = current + 1

			for _, k2 in ipairs(keySet) do
				bindings[current] = tonumber(k2 .. k1)
				current = current + 1

				for _, k3 in ipairs(keySet) do
					bindings[current] = tonumber(k3 .. k2 .. k1)
					current = current + 1
				end
			end
		end

		table.sort(bindings)
	]],

	-- Assign units to key combinations
	AssignUnits = [[
		self:RunAttribute('CreateBindings')

		for i, unit in pairs(sorted) do
			local binding = bindings[i]
			lookup[binding] = unit
		end
	]],

	-- Refresh everything on down press
	Refresh = [[
		pool, onDown = ...
		if not onDown then
			self:RunAttribute('SetTarget')
			return
		end

		self:SetAttribute('macrotext', nil)
		self:RunAttribute('Wipe')
		self:RunAttribute('SetBindings', pool)
		self:RunAttribute('UpdateUnits', pool)
		self:RunAttribute('SortUnits')
		self:RunAttribute('AssignUnits', pool)
		self:RunAttribute('DisplayBindings')
	]],

	-- Feed existing nameplate units into the unit table
	UpdatePlates = [[
		for plate in pairs(plates) do
			units[plate] = true
		end
	]],

	-- Find existing unit frames
	UpdateFrames = [[
		local stack
		if not current then
			stack = newtable(self:GetParent():GetChildren())
		elseif current:IsVisible() then
			local unit = current:GetAttribute('unit')
			if unit and not ignore[unit] and not headers[current] then
				units[unit] = true
			end
			stack = newtable(current:GetChildren())
		end
		if stack then
			for i, frame in pairs(stack) do
				if frame:IsProtected() then
					current = frame
					self:RunAttribute('UpdateFrames')
				end
			end
		end
	]],

	-- Update sources of units
	UpdateUnits = [[
		local pool = ...

		if pool == 'frames' then
			self:RunAttribute('UpdateFrames')
		elseif pool == 'plates' or pool == 'tab' then
			self:RunAttribute('UpdatePlates')
		end
	]],

	-- Sort the units by name, to retain some coherence when setting up bindings
	SortUnits = [[
		local specific = self:GetAttribute('unitpool')
		for unit in pairs(units) do
			if ( not specific ) then
				sorted[#sorted + 1] = unit
			else
				specific = specific:gsub(';', '\n')
				for token in specific:gmatch('[%a%p]+') do
					if unit:match(token) then
						sorted[#sorted + 1] = unit
						break 
					end
				end
			end
		end
		table.sort(sorted)
	]],

	-- Set the bindings that control the input
	SetBindings = [[
		local pool = ...
		if pool == 'frames' then
			set = btns[frameSet]
			side = frameSet
			modifier = frameMod
		elseif pool == 'plates' then
			set = btns[plateSet]
			side = plateSet
			modifier = plateMod
		elseif pool == 'tab' then
			set = btns[tabSet]
			side = tabSet
			modifier = tabMod
		end
		if set then
			for binding, keyID in pairs(set) do
				local key = GetBindingKey('CP_' .. side .. '_' .. binding)
				if key then
					self:SetBindingClick(true, key, bindRef, keyID)
					self:SetBindingClick(true, modifier..key, bindRef, keyID)
				end
			end
		end
	]],

	-- Display the bindings on frames/plates
	DisplayBindings = [[
		local ghostMode = ...
		self:CallMethod('SetFramePool', pool, side)
		self:CallMethod('HideBindings', ghostMode)
		for binding, unit in pairs(lookup) do
			self:CallMethod('DisplayBinding', tostring(binding), unit, ghostMode)
		end
	]],

	-- Wipe tables and settings
	Wipe = [[
		lookup = wipe(lookup)
		units = wipe(units)
		sorted = wipe(sorted)
		bindings = wipe(bindings)
		defaultToTab = nil
		current = nil
		input = nil
		set = nil
	]],

	OnNewSettings = [[
		ignore.player = self:GetAttribute('ignorePlayer')
	]],
}) do EM:SetAttribute(name, script) end

-- EM secure input wrappers
for name, script in pairs({
	PreClick = [[
		-- Unit frames
		if button == 'LeftButton' then
			self:RunAttribute('Refresh', 'frames', down)

		-- Nameplates
		elseif button == 'RightButton' then
			self:RunAttribute('Refresh', 'plates', down)
		
		-- Combined nameplates/nearest
		elseif button == 'MiddleButton' then
			self:RunAttribute('Refresh', 'tab', down)
			if down then
				defaultToTab = true
				self:CallMethod('HighlightTarget', false)
			end
		end
	]],
}) do EM:WrapScript(EM, name, script) end

-- Secure input wrappers
for name, script in pairs({
	OnClick = [[
		if down then
			owner:RunAttribute('Input', button)
		end
	]],
}) do EM:WrapScript(Input, name, script) end

function EM:OnNewBindings(...)
	local keys = {
		plate = {ConsolePort:GetCurrentBindingOwner('CLICK ConsolePortEasyMotionButton:RightButton')},
		frame = {ConsolePort:GetCurrentBindingOwner('CLICK ConsolePortEasyMotionButton:LeftButton')},
		tab = {ConsolePort:GetCurrentBindingOwner('CLICK ConsolePortEasyMotionButton:MiddleButton')},
	}
	if db.Settings.unitHotkeyPool then
		self:SetAttribute('unitpool', db.Settings.unitHotkeyPool)
	end
	self:SetAttribute('ignorePlayer', db.Settings.unitHotkeyIgnorePlayer)
	self:SetAttribute('ghostMode', db.Settings.unitHotkeyGhostMode)
	self:Execute([[self:RunAttribute('OnNewSettings')]])
	local hSet = db.Settings.unitHotkeySet
	if hSet then
		hSet = hSet:lower()
		hSet = hSet:match('left') and 'L' or hSet:match('right') and 'R'
	end
	for unitType, info in pairs(keys) do
		local key, mod = unpack(info)
		if key and mod then
			local set = hSet or ( key:match('CP_R_') and 'L' or 'R' )
			self:Execute(format([[ %sSet = '%s' %sMod = '%s' ]], unitType, set, unitType, mod))
		end
	end
end

ConsolePort:RegisterCallback('OnNewBindings', EM.OnNewBindings, EM)


EM.FramePool = {}
EM.ActiveFrames = 0
EM.UnitFrames = {}

function EM:SetFramePool(unitType, side)
	self.unitType = unitType
	self.set = Key[side]
	if unitType == 'frames' then
		wipe(self.UnitFrames)
		self:RefreshUnitFrames()
	end
end

function EM:AddFrameForUnit(frame, unit)
	local frames = self.UnitFrames
	frames[unit] = frames[unit] or {}
	frames[unit][frame] = true
end

function EM:GetUnitFramesForUnit(unit)
	return pairs(self.UnitFrames[unit] or {})
end

function EM:RefreshUnitFrames(current)
	local stack
	if not current then
		stack = {self:GetParent():GetChildren()}
	elseif current:IsVisible() then
		local unit = current:GetAttribute('unit')
		if unit then
			self:AddFrameForUnit(current, unit)
		end
		stack = {current:GetChildren()}
	end
	if stack then
		for i, frame in pairs(stack) do
			if not frame:IsForbidden() and frame:IsProtected() then
				self:RefreshUnitFrames(frame)
			end
		end
	end
end

function EM:Filter(input)
	local filter = '^' .. input
	for idx, frame in self:GetFrames() do
		if frame.isActive and frame.binding:match(filter) then
			local icon, level, previous = frame.Keys, 0
			for id in input:gmatch('%d') do
				id = tonumber(id)
				if previous then
					previous:Hide()
					tremove(frame.ShownKeys, previous.shownID)
				end
				previous = icon[id]
				icon = icon[id]
				level = level + 1
			end
			frame:Adjust(level > 1 and level)
			frame:IndicateFilterMatch()
		else
			frame:Clear()
		end
	end
end

function EM:DisplayBinding(binding, unit, ghostMode)
	local plate = not ghostMode and self.GetNamePlateForUnit(unit)
	if plate and plate.UnitFrame then
		self:AddFrameForUnit(plate.UnitFrame, unit)
	end
	for frame in self:GetUnitFramesForUnit(unit) do
		local hotkey = self:GetHotkey(binding)
		
		hotkey:DrawIconsForBinding(binding)
		hotkey:SetAlpha(ghostMode and 0.5 or 1)
		hotkey.unit = unit

		if self.unitType == 'frames' then
			hotkey:SetUnitFrame(frame)
		end
	end
end

function EM:HideBindings(unit, ghostMode)
	self.ActiveFrames = 0
	for _, frame in self:GetFrames() do
		if unit and frame.unit == unit then
			frame:Animate(ghostMode)
		else
			frame:Clear()
		end
	end
end

function EM:GetHotkey(binding)
	local frame
	self.ActiveFrames = self.ActiveFrames + 1
	if self.ActiveFrames > #self.FramePool then
		frame = CreateFrame('Frame', 'ConsolePortEasyMotionDisplay'..self.ActiveFrames, self)
		frame:SetFrameStrata("TOOLTIP")
		frame.size = db.Settings.unitHotkeySize or 32
		frame.offsetX = db.Settings.unitHotkeyOffsetX or 0
		frame.offsetY = db.Settings.unitHotkeyOffsetY or -8
		frame.anchor = db.Settings.unitHotkeyAnchor or 'CENTER'
		frame:SetSize(1, 1)
		frame:Hide()
		frame.Keys = {}
		frame.ShownKeys = {}
		frame.GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit

		Mixin(frame, HotkeyMixin)

		self.FramePool[self.ActiveFrames] = frame
	else
		frame = self.FramePool[self.ActiveFrames]
	end
	frame.binding = binding
	frame.isActive = true
	return frame
end

function EM:GetFrames() return pairs(self.FramePool) end

function HotkeyMixin:Clear()
	self.isActive = false
	self.binding = nil
	self.unit = nil
	self:SetParent(EM)
	self:SetFrameLevel(1)
	self:SetSize(1, 1)
	self:SetScale(1)
	self:ClearAllPoints()
	self:Hide()
	for _, icon in pairs(self.ShownKeys) do
		icon:Hide()
	end
	wipe(self.ShownKeys)
end

function HotkeyMixin:Adjust(depth)
	local offset = depth and #self.ShownKeys + depth or #self.ShownKeys
	self:SetWidth( offset * ( self.size * 0.75 ) )
end

function HotkeyMixin:IndicateFilterMatch()
	if not self.Indicate then
		self.Indicate = self:CreateAnimationGroup()
		self.Indicate.Enlarge = self.Indicate:CreateAnimation('SCALE')
		---
		self.Indicate.Enlarge:SetOrigin('CENTER', 0, 0)
		self.Indicate.Enlarge:SetScale(1.35, 1.35)
		self.Indicate.Enlarge:SetDuration(0.1)
		self.Indicate.Enlarge:SetSmoothing('OUT')
		---
	end
	self.Indicate:Finish()
	self.Indicate:Play()
end

function HotkeyMixin:DrawIconsForBinding(binding)
	binding = binding or self.binding
	local icon, shown = self.Keys, 0
	for id in binding:gmatch('%d') do
		id = tonumber(id)
		local size = self.size
		if icon[id] then
			icon = icon[id]
		else
			icon[id] = self:CreateTexture(nil, 'OVERLAY')
			icon = icon[id]
			icon:SetTexture(db.ICONS[Index[id]])
			icon:SetSize(size, size)
		end
		shown = shown + 1
		self.ShownKeys[shown] = icon
		icon.shownID = shown
		icon:SetPoint('LEFT', ( shown - 1) * ( size * 0.75 ), 0)
		icon:Show()
	end
	self:Adjust()
end

function HotkeyMixin:Animate(ghostMode)
	if not self.Match then
		self.Match = self:CreateAnimationGroup()
		self.Match.Enlarge = self.Match:CreateAnimation('SCALE')
		self.Match.Shrink = self.Match:CreateAnimation('SCALE')
		self.Match.Alpha = self.Match:CreateAnimation('ALPHA')
		---
		self.Match.Enlarge:SetOrigin('CENTER', 0, 0)
		self.Match.Enlarge:SetScale(2, 2)
		self.Match.Enlarge:SetDuration(0.1)
		self.Match.Enlarge:SetSmoothing('OUT')
		---
		self.Match.Shrink:SetOrigin('CENTER', 0, 0)
		self.Match.Shrink:SetScale(0.25, 0.25)
		self.Match.Shrink:SetDuration(0.2)
		self.Match.Shrink:SetStartDelay(0.1)
		self.Match.Shrink:SetSmoothing('OUT')
		---
		self.Match.Alpha:SetStartDelay(0.1)
		self.Match.Alpha:SetFromAlpha(1)
		self.Match.Alpha:SetToAlpha(0)
		self.Match.Alpha:SetDuration(0.2)
		---
		Mixin(self.Match, GroupMixin)
	end
	self.Match:Finish()
	self.Match:SetScript('OnFinished', ghostMode and self.Match.RedrawOnFinish or self.Match.ClearOnFinish)
	self.Match:Play()
end

function HotkeyMixin:SetNamePlate(plate)
	if plate and plate.UnitFrame then
		self:SetParent(WorldFrame)
		self:SetPoint('CENTER', plate.UnitFrame, 0, 0)
		self:Show()
		self:SetScale(UIParent:GetScale())
		self:SetFrameLevel(plate.UnitFrame:GetFrameLevel() + 1)
	end
end

function HotkeyMixin:SetUnitFrame(frame)
	if frame then
		self:SetParent(UIParent)
		self:SetPoint(self.anchor, frame, self.offsetX, self.offsetY)
		self:Show()
		self:SetScale(1)
		self:SetFrameLevel(frame:GetFrameLevel() + 1)
	end
end

function GroupMixin:ClearOnFinish()
	self:GetParent():Clear()
end

function GroupMixin:RedrawOnFinish()
	local parent = self:GetParent()
	parent:DrawIconsForBinding(parent.binding)
	parent:SetAlpha(0.5)
end