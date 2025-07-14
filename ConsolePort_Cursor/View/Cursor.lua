---------------------------------------------------------------
-- Interface cursor
---------------------------------------------------------------
-- Creates a cursor used to manage the interface with D-pad.
-- Operates recursively on frames and calculates appropriate
-- actions based on node priority and position on screen.
-- Leverages ConsolePortNode for interface scans.

local env, db, name = CPAPI.GetEnv(...);
local Cursor, Node, Input, Stack, Scroll, Fade, Hooks =
	CPAPI.EventHandler(ConsolePortCursor, {
		'PLAYER_REGEN_ENABLED';
		'PLAYER_REGEN_DISABLED';
		'ADDON_ACTION_FORBIDDEN';
	}),
	env.Node,
	ConsolePortInputHandler,
	ConsolePortUIStackHandler,
	ConsolePortUIScrollHandler,
	db.Alpha.Fader, db.Hooks;

db:Register('Cursor', Cursor, true); env.Cursor = Cursor;
Cursor.InCombat = InCombatLockdown;

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function Cursor:PLAYER_REGEN_DISABLED()
	self.isCombatPaused = true;
	if self:IsShown() then
		Fade.Out(self, 0.2, self:GetAlpha(), 0)
		self:ShowAfterCombat(true)
		self:SetFlashNextNode()
		self:Release()
	end
end

function Cursor:PLAYER_REGEN_ENABLED()
	-- in case the cursor is showing and waiting to hide OOC
	if self:IsShown() and not self.showAfterCombat then
		self:Hide()
	end
	-- time lock this in case it fires more than once
	if not self.timeLock then
		self.timeLock = true;

		local clearLockedState = function()
			self.timeLock = nil;
			self.isCombatPaused = nil;
			self.onEnableCallback = nil;
		end

		if self.showAfterCombat then
			self.onEnableCallback = self.onEnableCallback or function()
				Fade.In(self, 0.2, self:GetAlpha(), 1)
				if not self:InCombat() and self:IsShown() then
					self:SetBasicControls()
					self:Refresh()
				end
			end
			C_Timer.After(db('UIleaveCombatDelay'), function()
				self.onEnableCallback()
				self.showAfterCombat = nil;
				clearLockedState()
			end)
		else -- do nothing but clear the locked state
			C_Timer.After(db('UIleaveCombatDelay'), clearLockedState)
		end
	end
end

function Cursor:ADDON_ACTION_FORBIDDEN(addOnName, action)
	if ( addOnName == name ) then
		env.HandleTaintError(action)
	end
end

---------------------------------------------------------------
-- Cursor state
---------------------------------------------------------------
function Cursor:OnClick()
	self:SetEnabled(not self:IsShown())
end

function Cursor:OnStackChanged(hasFrames)
	if db('UIshowOnDemand') or not IsGamePadFreelookEnabled() then
		return
	end
	return self:SetEnabled(hasFrames)
end

function Cursor:SetEnabled(enable)
	if enable then
		return self:Enable()
	end
	return self:Disable()
end

function Cursor:Enable()
	local inCombat, disabled = self:IsObstructed()
	if disabled then
		return
	elseif inCombat then
		return self:ShowAfterCombat(true)
	end
	if not self:IsShown() then
		self:Show()
		self:SetBasicControls()
		return self:Refresh()
	end
end

function Cursor:Disable()
	local inCombat, disabled = self:IsObstructed()
	if inCombat or disabled then
		self:ShowAfterCombat(false)
	end
	if self:IsShown() and not inCombat then
		self:Hide()
	end
end

function Cursor:OnShow()
	self:SetScale(UIParent:GetEffectiveScale())
	db:TriggerEvent('OnCursorShow', self)
end

function Cursor:OnHide()
	self.timer = 0
	self:SetAlpha(1)
	self:SetFlashNextNode()
	self:Release()
	self.Blocker:Hide()
	db:TriggerEvent('OnCursorHide', self)
end

function Cursor:Release()
	Node.ClearCache()
	self:OnLeaveNode(self:GetCurrentNode())
	self:SetHighlight()
	Input:Release(self)
end

function Cursor:IsObstructed()
	return self:InCombat(), not db('UIenableCursor'), self.isCombatPaused;
end

function Cursor:IsAnimating()
	return self.ScaleInOut:IsPlaying()
end

function Cursor:ShowAfterCombat(enabled)
	self.showAfterCombat = enabled
end

function Cursor:ScanUI()
	if db('UIaccessUnlimited') then
		Node(unpack(env.UnlimitedFrameStack))
	else
		Node(Stack:GetVisibleCursorFrames())
	end
end

function Cursor:Refresh()
	self:OnLeaveNode(self:GetCurrentNode())
	self:ScanUI()
	return self:AttemptSelectNode()
end

function Cursor:RefreshToFrame(frame)
	if not self:IsShown() then
		self:Show()
		self:SetBasicControls()
		self:OnLeaveNode(self:GetCurrentNode())
		self:SetFlashNextNode()
		Node(frame)
		return self:AttemptSelectNode()
	end
end

function Cursor:SetCurrentNode(node, assertNotMouse, forceEnable)
	local isGamepadActive = IsGamePadFreelookEnabled()

	-- Prerequisites
	if not db('UIenableCursor') then return end;
	if db('UIshowOnDemand') and not self:IsShown() then return end;
	if not isGamepadActive and not forceEnable then return end;

	local object = node and Node.ScanLocal(node)[1]
	if object and (not assertNotMouse or isGamepadActive or forceEnable) then
		self:SetOnEnableCallback(function(self, object)
			self:SetBasicControls()
			self:SetFlashNextNode()
			self:SetCurrent(object)
			self:SelectAndPosition(self:GetSelectParams(object, true, true))
			self:Chime()
		end, object)
		return true;
	end
end

function Cursor:SetCurrentNodeIfActive(...)
	if self:IsShown() then
		return self:SetCurrentNode(...)
	end
end

function Cursor:SetOnEnableCallback(callback, ...)
	local inCombat, disabled, isCombatPaused = self:IsObstructed()
	if disabled then
		return
	end
	if not inCombat and not isCombatPaused then
		return callback(self, ...)
	end
	self.onEnableCallback = GenerateClosure(callback, self, ...)
end

function Cursor:OnUpdate(elapsed)
	if self:InCombat() then return end
	if not self:IsCurrentNodeDrawn() then
		self:SetFlashNextNode()
		if not self:Refresh() then
			self:Hide()
		end
	else
		self:RefreshAnchor()
	end
end

---------------------------------------------------------------
-- Navigation and input
---------------------------------------------------------------
do  -- Create input proxy for basic controls
	local InputProxy = function(key, self, isDown)
		Cursor:Input(key, self, isDown)
	end

	local DpadRepeater = function(self, elapsed)
		self.timer = self.timer + elapsed
		if self.timer >= self:GetAttribute('ticker') and self.state then
			local func = self:GetAttribute(CPAPI.ActionTypeRelease)
			if ( func == 'UIControl' ) then
				self[func](self, self.state, self:GetAttribute('id'))
			end
			self.timer = 0
		end
	end

	local DpadInit = function(self, dpadRepeater)
		if not db('UIholdRepeatDisable') then
			self:SetAttribute('timer', -db('UIholdRepeatDelayFirst'))
			self:SetAttribute('ticker', db('UIholdRepeatDelay'))
			self:SetScript('OnUpdate', dpadRepeater)
			self:Show()
		end
	end

	local DpadClear = function(self)
		self:SetScript('OnUpdate', nil)
		self:Hide()
	end

	function Cursor:GetBasicControls()
		--  @init : (optional) function to set up properties
		--  @clear: (optional) function to run when clearing
		--  @args : (optional) properties for initialization
		if not self.DpadControls then
			self.DpadControls = {
				PADDUP    = {GenerateClosure(InputProxy, 'PADDUP'),    DpadInit, DpadClear, DpadRepeater};
				PADDDOWN  = {GenerateClosure(InputProxy, 'PADDDOWN'),  DpadInit, DpadClear, DpadRepeater};
				PADDLEFT  = {GenerateClosure(InputProxy, 'PADDLEFT'),  DpadInit, DpadClear, DpadRepeater};
				PADDRIGHT = {GenerateClosure(InputProxy, 'PADDRIGHT'), DpadInit, DpadClear, DpadRepeater};
			};
		end
		if not self.BasicControls then
			self.BasicControls = CopyTable(self.DpadControls)
		end
		for key in pairs(self.BasicControls) do
			if not self.DpadControls[key] then
				self.BasicControls[key] = nil;
			end
		end
		self.DynamicControls = {
			db('Settings/UICursorSpecial');
			db('Settings/UICursorCancel');
		};
		for _, key in ipairs(self.DynamicControls) do
			if not self.BasicControls[key] then
				self.BasicControls[key] = {GenerateClosure(InputProxy, key)}
			end
		end
		return self.BasicControls;
	end

	local SetDirectUIControl = function(self, button, settings)
		Input:SetCommand(button, self, true, 'LeftButton', 'UIControl', unpack(settings));
	end

	function Cursor:IsDynamicControl(key)
		return self.DynamicControls and tContains(self.DynamicControls, key)
	end

	function Cursor:SetBasicControls()
		Input:Release(self)
		local controls = self:GetBasicControls()
		for button, settings in pairs(controls) do
			SetDirectUIControl(self, button, settings);
		end
	end

	function Cursor:SetBasicControl(button)
		local settings = self:GetBasicControls()[button];
		if settings then
			SetDirectUIControl(self, button, settings);
		end
	end

	-- Callbacks to reset controls when inputters change
	do local function ResetControls(self) self.BasicControls, self.DynamicControls = nil; end
		db:RegisterCallbacks(ResetControls, Cursor,
			'Settings/UICursorSpecial',
			'Settings/UICursorCancel',
			'Settings/UICursorLeftClick',
			'Settings/UICursorRightClick'
		);
	end

	-- Emulated clicks for handlers that do not use OnClick (this may be unsafe)
	local EmuClick = function(self, down)
		local node, emubtn, script = self.node, self.emubtn;
		if node then
			script =
				((down == true)  and 'OnMouseDown') or
				((down == false) and 'OnMouseUp');
			if script then
				env.ExecuteScript(node, script, emubtn)
			end
			if (down and node.OnClick) then
				env.ExecuteMethod(node, 'OnClick', emubtn)
			end
		end
	end

	local EmuClickInit = function(self, node, emubtn)
		self.node   = node;
		self.emubtn = emubtn;
	end

	local EmuClickClear = function(self)
		self.node   = nil;
		self.emubtn = nil;
	end

	function Cursor:GetEmuClick(node, button)
		return button, 'UIOnMouse', EmuClick, EmuClickInit, EmuClickClear, node, button;
	end
end

function Cursor:ReverseScanUI(node, key, target, changed)
	if node then
		local parent = node:GetParent()
		Node.ScanLocal(parent)
		target, changed = Node.NavigateToBestCandidateV3(self.Cur, key)
		if changed then
			return target, changed;
		end
		return self:ReverseScanUI(parent, key)
	end
	return self.Cur, false;
end

function Cursor:ReverseScanStack(node, key, target, changed)
	if node then
		local parent = node:GetParent()
		Node.ScanLocal(parent)
		target, changed = Node.NavigateToBestCandidateV2(self.Cur, key)
		if changed then
			return target, changed;
		end
		return self:FlatScanStack(key)
	end
	return self.Cur, false;
end

function Cursor:FlatScanStack(key)
	self:ScanUI()
	return Node.NavigateToBestCandidateV3(self.Cur, key)
end

function Cursor:Navigate(key)
	-- Navigation algorithm (so I remember what this does):
	-- 1. With unlimited access, scan the entire UI stack, but prioritize the current frame.
	-- 2. With optimized algorithm, scan the current frame and its children, then the entire UI stack.
	-- 3. With neither, scan the entire visible panel UI stack.
	-- 4. If no target is found, navigate to the closest candidate.
	local target, changed;
	if db('UIaccessUnlimited') then
		target, changed = self:SetCurrent(self:ReverseScanUI(self:GetCurrentNode(), key))
	elseif db('UIalgoOptimize') then
		target, changed = self:SetCurrent(self:ReverseScanStack(self:GetCurrentNode(), key))
	else
		target, changed = self:SetCurrent(self:FlatScanStack(key))
	end
	if not changed then
		target, changed = self:SetCurrent(Node.NavigateToClosestCandidate(target, key))
	end
	return target, changed;
end

function Cursor:AttemptSelectNode()
	local newObj = Node.NavigateToArbitraryCandidate(self.Cur, self.Old, self:GetCenter())
	local target, changed = self:SetCurrent(newObj)
	if target then
		if changed then
			self:SetFlashNextNode()
		end
		return self:SelectAndPosition(self:GetSelectParams(target, true))
	end
end

function Cursor:Input(key, caller, isDown)
	local target, changed
	if isDown and key then
		if not self:AttemptDragStart() then
			target, changed = self:Navigate(key)
		end
	elseif self:IsDynamicControl(key) then
		return Hooks:ProcessInterfaceCursorEvent(key, isDown, self:GetCurrentNode())
	end
	if ( target ) then
		return self:SelectAndPosition(self:GetSelectParams(target, isDown))
	end
end

---------------------------------------------------------------
-- Queries for the current node
---------------------------------------------------------------
function Cursor:SetCurrent(newObj)
	local oldObj = self:GetCurrent()
	if ( oldObj and newObj == oldObj ) then
		return oldObj, false;
	end
	self.Old = oldObj;
	self.Cur = newObj;
	return newObj, true;
end

function Cursor:GetCurrent()
	return self.Cur;
end

function Cursor:GetCurrentNode()
	local obj = self:GetCurrent()
	return obj and obj.node;
end

function Cursor:IsCurrentNode(node, uniqueTriggered)
	return self:IsShown() and (node and node == self:GetCurrentNode())
		and (not uniqueTriggered or not node:IsMouseOver())
end

function Cursor:GetCurrentObjectType()
	local obj = self:GetCurrent()
	return obj and obj.object;
end


function Cursor:IsCurrentNodeDrawn()
	local node = self:GetCurrentNode()
	return node and ( node:IsVisible() and Node.IsDrawn(node) )
end

function Cursor:IsValidForAutoScroll(super, force)
	if not super then return end;

	local old = self:GetOld()
	local oldSuper = old and old.super;
	local validSuper = force or super == oldSuper;
	return validSuper and
		not super:GetAttribute(env.Attributes.IgnoreScroll) and
		not IsShiftKeyDown() and
		not IsControlKeyDown()
end

function Cursor:GetSelectParams(obj, triggerOnEnter, automatic)
	return obj.node, obj.object, obj.super, triggerOnEnter, automatic;
end

function Cursor:GetOld()
	return self.Old;
end

function Cursor:GetOldNode()
	local obj = self:GetOld()
	return obj and obj.node;
end

function Cursor:StoreCurrent()
	local current = self:GetCurrent()
	self.Old = current;
	self:SetCurrent(nil)
end

---------------------------------------------------------------
-- Script handling
---------------------------------------------------------------
function Cursor:ReplaceScript(scriptType, original, replacement)
	return env.ReplaceScript(scriptType, original, replacement)
end

do	local function IsDisabledButton(node)
		return node:IsObjectType('Button') and not (node:IsEnabled() or node:GetMotionScriptsWhileDisabled())
	end

	function Cursor:OnLeaveNode(node)
		if node and not IsDisabledButton(node) then
			Hooks:OnNodeLeave()
			env.ExecuteScript(node, 'OnLeave')
		end
	end

	function Cursor:OnEnterNode(node)
		if node and not IsDisabledButton(node) then
			env.ExecuteScript(node, 'OnEnter')
		end
	end
end

---------------------------------------------------------------
-- Node management resources
---------------------------------------------------------------
function Cursor:IsClickableNode(node, object)
	local isClickableObject = (env.IsClickableType[object] and object ~= 'EditBox');
	if not isClickableObject then
		return false;
	end
	if node:GetScript('OnClick') then
		return true;
	end
	return not node:GetScript('OnMouseDown') and not node:GetScript('OnMouseUp')
end

function Cursor:GetMacroReplacement(node)
	return env.DropdownReplacementMacro[node.value];
end

---------------------------------------------------------------
-- Node selection
---------------------------------------------------------------
function Cursor:SelectAndPosition(node, object, super, newMove, automatic)
	if newMove then
		self:OnLeaveNode(self:GetOldNode())
		self:SetPosition(node)
	end
	self:Select(node, object, super, newMove, automatic)
	return node
end

function Cursor:Select(node, object, super, triggerOnEnter, automatic)
	self:OnEnterNode(triggerOnEnter and node)

	-- Scroll to node center
	if self:IsValidForAutoScroll(super, automatic) then
		Scroll:To(node, super, self:GetOldNode(), automatic)
	end

	if (object == 'Slider') then
		-- TODO: Override:HorizontalScroll(Cursor, node)
	end

	self:SetScrollButtonsForNode(node, super)
	self:SetCancelButtonForNode(node)
	self:SetClickButtonsForNode(node,
		self:GetMacroReplacement(node),
		self:IsClickableNode(node, object)
	);
end

function Cursor:SetScrollButtonsForNode(node, super)
	local scrollUp, scrollDown = Scroll:GetScrollButtonsForController(node, super)
	if not scrollUp or not scrollDown then
		scrollUp, scrollDown = Node.GetScrollButtons(node)
	end
	self:ToggleScrollIndicator(scrollUp and scrollDown)
	if scrollUp and scrollDown then
		local modifier = db('UImodifierCommands')
		self.scrollers = {
			Input:SetGlobal(format('%s-%s', modifier, 'PADDUP'), self, scrollUp:GetName(), true),
			Input:SetGlobal(format('%s-%s', modifier, 'PADDDOWN'), self, scrollDown:GetName(), true)
		};
		return scrollUp, scrollDown
	end
	if self.scrollers then
		for _, widget in ipairs(self.scrollers) do
			widget:ClearOverride(self)
		end
		self.scrollers = nil;
	end
end

function Cursor:SetClickButtonsForNode(node, macroReplacement, isClickable)
	for click, button in pairs({
		LeftButton  = db('Settings/UICursorLeftClick');
		RightButton = db('Settings/UICursorRightClick');
	}) do for modifier in db:For('Gamepad/Index/Modifier/Active') do
			if macroReplacement then
				local unit = UIDROPDOWNMENU_INIT_MENU.unit
				Input:SetMacro(modifier .. button, self, macroReplacement:format(unit or ''), true)
			elseif isClickable then
				Input:SetButton(modifier .. button, self, node, true, click)
			else
				Input:SetCommand(modifier .. button, self, true, self:GetEmuClick(node, click))
			end
		end
	end
end

function Cursor:AttemptDragStart()
	local node = self:GetCurrentNode()
	local script = node and not node:GetAttribute(env.Attributes.IgnoreDrag)
		and node:GetScript('OnDragStart');
	if script then
		local widget = Input:GetActiveWidget(db('Settings/UICursorLeftClick'), self)
		local click = widget and widget:HasClickButton()
		if widget and widget.state and click then
			widget:ClearClickButton()
			widget:EmulateFrontend(click, 'NORMAL', 'OnMouseUp')
			script(node, 'LeftButton')
			return true;
		end
	end
end

do local function GetCloseButton(node)
		if rawget(node, 'CloseButton') then
			return node.CloseButton;
		end
		local nodeName = node:GetName();
		if nodeName then
			return _G[nodeName..'CloseButton'];
		end
	end

	local function FindCloseButton(node)
		if not node then return end;
		return GetCloseButton(node) or FindCloseButton(node:GetParent())
	end

	function Cursor:SetCancelButtonForNode(node)
		local cancelButton = db('Settings/UICursorCancel')
		if not cancelButton then return end;

		if Hooks:GetCancelClickHandler(node) then
			return self:SetBasicControl(cancelButton)
		end

		local closeButton = FindCloseButton(node)
		if C_Widget.IsFrameWidget(closeButton) then RunNextFrame(function()
			-- A cancel action can trigger the current node to disappear,
			-- for example by closing a dialog. If the cursor then jumps to
			-- another node that has a related close button, the script order
			-- will result in both things happening in one frame. Therefore,
			-- the cancel button needs to be mounted in the next frame instead.
			if self:InCombat() then return end;
			Input:SetButton(cancelButton, self, closeButton, true, 'LeftButton')
		end) end;
	end
end

---------------------------------------------------------------
-- Initialize the cursor
---------------------------------------------------------------
CPAPI.Start(Cursor)