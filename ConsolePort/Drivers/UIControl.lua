local _, db = ...
local UI = ConsolePortUI
local UIParent, assert, pairs = UIParent, assert, pairs
local Registry = UI.FrameRegistry
----------------------------------
local Control = ConsolePortUIHandle
----------------------------------
-- Control input handling
----------------------------------
for name, script in pairs({
----------------------------------
	SetFocusFrame = [[
		if #stack > 0 then
			focusFrame = stack[1]
			MouseHandle:SetAttribute('blockhandle', true)
			self:SetAttribute('focus', focusFrame)
			self:ClearBindings()
			for binding, identifier in pairs(keys) do
				local key = GetBindingKey(binding)
				if key then
					self:SetBindingClick(true, key, self:GetFrameRef(binding), identifier)
				end
			end
			return true
		else
			focusFrame = nil
			MouseHandle:SetAttribute('blockhandle', false)
			self:SetAttribute('focus', nil)
			self:ClearBindings()
			return false
		end
	]],

	AddFrame = [[
		local added = self:GetAttribute('add')

		local oldStack = stack
		stack = newtable()

		stack[1] = added

		for _, frame in pairs(oldStack) do
			if frame ~= added then
				stack[#stack + 1] = frame
			end
		end
	]],

	RemoveFrame = [[
		local removed = self:GetAttribute('remove')

		local oldStack = stack
		stack = newtable()

		for _, frame in pairs(oldStack) do
			if frame ~= removed then
				stack[#stack + 1] = frame
			end
		end
	]],

	RefreshFocus = [[
		if self:RunAttribute('SetFocusFrame') then
			self:CallMethod('SetHintFocus')
			self:CallMethod('RestoreHints')
			for i=2, #stack do
				self:CallMethod('SetIgnoreFadeFrame', stack[i]:GetName(), false)
			end
			if focusFrame:GetAttribute('hideUI') then
				self:CallMethod('ShowUI')
				self:CallMethod('HideUI',
					focusFrame:GetName(), 
					focusFrame:GetAttribute('hideActionBar'))
			end
		else
			self:CallMethod('SetHintFocus')
			self:CallMethod('ShowUI')
			self:CallMethod('HideHintBar')
		end
	]],

	RefreshStack = [[
		if self:GetAttribute('add') then
			self:RunAttribute('AddFrame')
		end

		if self:GetAttribute('remove') then
			self:RunAttribute('RemoveFrame')
		end

		self:SetAttribute('add', nil)
		self:SetAttribute('remove', nil)
	]],
--------------------------------------------
}) do Control:SetAttribute(name, script) end
--------------------------------------------

local secure_wrappers = {
	PreClick = [[
		self:SetAttribute('type', nil)
		self:SetAttribute('macrotext', nil)
		self:SetAttribute('clickbutton', nil)
		local frame = stack[1]
		if frame:GetAttribute('useCursor') then
			-- NYI
		elseif frame:GetAttribute('OnInput') then
			local clickType, clickHandler, clickValue = 
				frame:RunAttribute('OnInput', tonumber(button), down)
			if clickType and clickHandler and clickValue then
				self:SetAttribute('type', clickType)
				self:SetAttribute(clickHandler, clickValue)
			end
		else
			frame:CallMethod('OnInput', button, down)
		end
	]],
}

--------------------------------------------------------------------
-- Readable variables mixed into each secure environment for comparison with inputs.
-- E.g. button == 8 -> button == CROSS 
local button_identifiers = ''
for readable, identifier in pairs(db.KEY) do
	if type(identifier) == 'string' then
		button_identifiers = button_identifiers..format('%s = "%s" ', readable, identifier)
	elseif type(identifier) == 'number' then
		button_identifiers = button_identifiers..format('%s = %s ', readable, identifier)
	end
end

-- (1) Register the generated variable string on the main control frame.
-- (2) Reference the mouse handle to block interaction overrides.
-- (3) Instantiate a frame stack and a key table for input handling.
-- (4) Forward binding identifiers into the control handle.
-- (5) Create individual input handlers to provide multi-button control.
----------------------------------
Control:Execute(button_identifiers) -- (1)
Control:SetFrameRef('mouseHandle', ConsolePortMouseHandle)
Control:Execute([[
	MouseHandle = self:GetFrameRef('mouseHandle')
	Control = self
	stack, keys = newtable(), newtable()
]]) -- (2) (3)
----------------------------------
function ConsolePort:LoadUIControl()
	for binding in ConsolePort:GetBindings() do -- (3) (4)
		local UIkey = ConsolePort:GetUIControlKey(binding)
		if UIkey then
			-- keys [string binding] = [integer key]
			Control:Execute(([[ keys.%s = '%s' ]]):format(binding, UIkey))
			local inputHandler = CreateFrame('Button', '$parent_'..binding, Control, 'SecureActionButtonTemplate')
			-- Register for any input, since these will simulate integer keys.
			inputHandler:RegisterForClicks('AnyUp', 'AnyDown')
			-- Assume macro initially; input handler may change between macro/click.
			inputHandler:SetAttribute('type', 'macro')
			-- Reference the handler so it can be bound securely.
			Control:SetFrameRef(binding, inputHandler)
			-- Set up click wrappers for the input handlers.
			for name, script in pairs(secure_wrappers) do
				Control:WrapScript(inputHandler, name, script)
			end
		end
	end
	self.LoadUIControl = nil
end

----------------------------------
-- Control API
----------------------------------
function UI:GetControlHandle() return Control end
----------------------------------
function UI:RegisterFrame(frame, ID, useCursor, hideUI, hideActionBar) 
	assert(frame, 'Frame handle does not exist.')
	assert(frame:IsProtected(), 'Frame handle is not protected.')
	assert(frame.Execute, 'Frame handle does not have a base template.')
	assert(not InCombatLockdown(), 'Frame handle cannot be registered in combat.')
	assert(ID, 'Frame handle does not have an ID.') 
	Control:RegisterFrame(frame, ID, useCursor, hideUI, hideActionBar)
end
----------------------------------
Control:SetAttribute('type', 'macro')
Control:RegisterForClicks('AnyUp', 'AnyDown')

function Control:RegisterFrame(frame, ID, useCursor, hideUI, hideActionBar)
	frame:Execute(button_identifiers)
	frame:SetAttribute('useCursor', useCursor)
	frame:SetAttribute('hideUI', hideUI)
	frame:SetAttribute('hideActionBar', hideActionBar)
	frame:SetFrameRef('control', self)
	self:SetFrameRef(ID, frame)
	self:WrapScript(frame, 'OnShow', [[
		Control:SetAttribute('add', self)
		Control:RunAttribute('RefreshStack')
		Control:RunAttribute('RefreshFocus')
	]])
	self:WrapScript(frame, 'OnHide', [[
		Control:SetAttribute('remove', self)
		Control:CallMethod('ClearHintsForFrame')
		Control:RunAttribute('RefreshStack')
		Control:RunAttribute('RefreshFocus')
	]])
end

----------------------------------
-- UI Fader
----------------------------------
local UI_FADE_TIME = 0.2
local IsFrameWidget = C_Widget.IsFrameWidget
local FadeIn, FadeOut = db.GetFaders()
local updateThrottle = 0
----------------------------------
local ignoreFrames, forceFrames, toggleFrames = {}, {}, {}
----------------------------------
function Control:LoadFadeFrames()
	local defaults = ConsolePort:GetDefaultFadeFrames()
	local loaded = db.UIConfig.FadeFrames
	if not loaded or (not loaded.ignore or not loaded.force or not loaded.toggle) then
		db.UIConfig.FadeFrames = defaults
		loaded = defaults
	end

	for _, frame in pairs(loaded.ignore) do ignoreFrames[frame] = true end
	for _, frame in pairs(loaded.force) do forceFrames[frame] = true end
--	for _, frame in pairs(loaded.toggle) do toggleFrames[frame] = true end

	-- Make sure we're ignoring the actual control handle
	ignoreFrames[self:GetName()] = true
	ignoreFrames[self.HintBar:GetName()] = true
end
----------------------------------


local function GetFadeFrames(onlyActionBars, focusFrame)
	local fadeFrames, frameStack = {}
	if onlyActionBars then
		frameStack = {}
		for registeredFrame in pairs(Registry) do
			frameStack[#frameStack + 1] = registeredFrame
		end
		for actionBar in ConsolePort:GetActionBars() do
			frameStack[#frameStack + 1] = actionBar
		end
	else
		frameStack = {UIParent:GetChildren()}
	end
	----------------------------------
	local focusFrame = IsFrameWidget(focusFrame) and focusFrame or _G[focusFrame]
	local containingFrame = focusFrame and focusFrame:GetParent()
	----------------------------------
	local name, forceChild, ignoreChild, isConsolePortFrame
	----------------------------------
	for i, child in ipairs(frameStack) do
		if not child:IsForbidden() then -- assert this frame isn't forbidden
			----------------------------------
			name = child:GetName()
			forceChild = forceFrames[name]
			ignoreChild = ignoreFrames[child] or ignoreFrames[name]
			isConsolePortFrame = name and name:match('ConsolePort')
			----------------------------------
				-- assert that the containing frame is ignored, so that it doesn't also fade the focused frame.
			if 	( containingFrame ~= child ) and (
				-- if the frame is in the UI registry and not set to be ignored,
				-- valid when multiple frames are shown simultaneously to fade out unfocused frames.
				( Registry[child] and not ignoreChild ) or
				-- if the frame belongs to the ConsolePort suite and should be faded regardless
				( isConsolePortFrame and forceChild ) or
				-- if the frame is forced (action bars), or if the frame is not explicitly ignored
				( ( forceChild ) or ( not isConsolePortFrame and not ignoreChild ) ) ) then
				-- prerequisite match, feed frame to fader
				fadeFrames[child] = child.fadeInfo and child.fadeInfo.endAlpha or child:GetAlpha()
			end
		end
	end
	return fadeFrames
end

function Control:TrackMouseOver(elapsed)
	updateThrottle = updateThrottle + elapsed
	if updateThrottle > 0.5 then
		if self.fadeFrames then
			for frame, origAlpha in pairs(self.fadeFrames) do
				if frame:IsMouseOver() and frame:IsMouseEnabled() then
					FadeIn(frame, UI_FADE_TIME, frame:GetAlpha(), origAlpha)
				elseif frame:GetAlpha() > 0.1 then
					FadeOut(frame, UI_FADE_TIME, frame:GetAlpha(), 0) 
				end
			end
		else
			self:SetScript('OnUpdate', nil)
		end
		updateThrottle = 0
	end
end

function Control:SetIgnoreFadeFrame(frame, toggleIgnore, fadeInOnFinish)
	local frame = type(frame) == 'string' and _G[frame] or frame
	ignoreFrames[frame] = toggleIgnore
	if toggleIgnore then
		if self.fadeFrames then
			self.fadeFrames[frame] = nil
		end
		if fadeInOnFinish then
			FadeIn(frame, UI_FADE_TIME, frame:GetAlpha(), 1)
		end
	end
end

function Control:HideUI(focusFrame, onlyActionBars)
	if focusFrame then
		self:SetIgnoreFadeFrame(focusFrame, true, true)
	end

	local frames = GetFadeFrames(onlyActionBars, focusFrame)
	for frame in pairs(frames) do
		FadeOut(frame, fadeTime or UI_FADE_TIME, frame:GetAlpha(), 0)
	end
	self.fadeFrames = frames

	updateThrottle = 0
	self:SetScript('OnUpdate', self.TrackMouseOver)
end

function Control:ShowUI()
	if self.fadeFrames then
		for frame, origAlpha in pairs(self.fadeFrames) do
			FadeIn(frame, fadeTime or UI_FADE_TIME, frame:GetAlpha(), origAlpha)
		end
		self.fadeFrames = nil
	end
end

----------------------------------
-- Hint bar
----------------------------------
-- The bar appears at the bottom of the screen and displays
-- button function hints local to the focused frame.
-- Hints are controlled from the UI modules.
-- Although hints are cached for each frame in the stack,
-- the hint control will set a new hint to the current focus
-- frame, regardless of where the function call comes from.
-- Explicitly hiding a stack frame clears its hint cache.

----------------------------------
-- Hint control
----------------------------------
Control.StoredHints = {}

function Control:SetHintFocus(forceFrame)
	self.HintBar.focus = forceFrame or self:GetAttribute('focus')
	self.focus = self.HintBar.focus
end

function Control:IsHintFocus(frame)
	return (self.focus == frame)
end

function Control:ClearHintsForFrame(forceFrame)
	self.StoredHints[forceFrame or self:GetAttribute('remove')] = nil
end

function Control:RestoreHints()
	if self.focus then
		local storedHints = self.StoredHints[self.HintBar.focus]
		if storedHints then
			self:ResetHintBar()
			for key, info in pairs(storedHints) do
				self:AddHint(key, info.text)
				if not info.enabled then
					self:SetHintDisabled(key)
				end
			end
		end
	end
end

function Control:HideHintBar()
	self:ResetHintBar()
	self.HintBar:Hide()
end

function Control:ResetHintBar()
	self.HintBar:Reset()
end

function Control:RegisterHintForFrame(frame, key, text, enabled)
	self.StoredHints[frame] = self.StoredHints[frame] or {}
	self.StoredHints[frame][key] = {text = text, enabled = enabled}
end

function Control:UnregisterHintForFrame(frame, key)
	if self.StoredHints[frame] then
		self.StoredHints[frame][key] = nil
	end
end

function Control:AddHint(key, text)
	local binding = ConsolePort:GetUIControlBinding(key)
	if binding then
		local hint = self.HintBar.focus and self.HintBar:GetHintFromPool(key, true)
		if hint then
			hint:SetData(binding, text)
			hint:Enable()
			self:RegisterHintForFrame(self.focus, key, text, true)
			return hint
		end
	end
end

function Control:RemoveHint(key)
	local hint = self:GetHintForKey(key)
	if hint then
		self:UnregisterHintForFrame(self.focus, key)
		hint:Hide()
	end
end

function Control:GetHintForKey(key)
	local hint = self.HintBar:GetActiveHintForKey()
	if hint then
		return hint, hint:GetText()
	end
end

function Control:SetHintDisabled(key)
	local hint = self:GetHintForKey(key)
	if hint then
		hint:Disable()
		self:RegisterHintForFrame(self.focus, key, hint:GetText(), false)
	end
end

function Control:SetHintEnabled(key)
	local hint = self:GetHintForKey(key)
	if hint then
		hint:Enable()
		self:RegisterHintForFrame(self.focus, key, hint:GetText(), true)
	end
end