---------------------------------------------------------------
-- Interface cursor
---------------------------------------------------------------
-- Creates a cursor used to manage the interface with D-pad.
-- Operates recursively on frames and calculates appropriate
-- actions based on node priority and position on screen.
-- Leverages Controller\UINode.lua for interface scans.

local name, env, db = ...; db = env.db;
local Cursor, Node, Input, Stack, Scroll, Fade, Hooks =
	CPAPI.EventHandler(ConsolePortCursor, {
		'PLAYER_REGEN_ENABLED';
		'PLAYER_REGEN_DISABLED';
		'ADDON_ACTION_FORBIDDEN';
	}),
	LibStub('ConsolePortNode'),
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

	function Cursor:IsDynamicControl(key)
		return self.DynamicControls and tContains(self.DynamicControls, key)
	end

	function Cursor:SetBasicControls()
		local controls = self:GetBasicControls()
		for button, settings in pairs(controls) do
			Input:SetCommand(button, self, true, 'LeftButton', 'UIControl', unpack(settings));
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
		target, changed = Node.NavigateToBestCandidateV2(self.Cur, key)
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
	return Node.NavigateToBestCandidateV2(self.Cur, key)
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
	return (node and node == self:GetCurrentNode())
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
	local script = node and node:GetScript('OnDragStart')
	if script then
		local widget = Input:GetActiveWidget(db('Settings/UICursorLeftClick'), self)
		local click = widget:HasClickButton()
		if widget and widget.state and click then
			widget:ClearClickButton()
			widget:EmulateFrontend(click, 'NORMAL', 'OnMouseUp')
			script(node, 'LeftButton')
			return true;
		end
	end
end

do local function GetCloseButton(node)
		if node.CloseButton then
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
		local closeButton = FindCloseButton(node)
		if C_Widget.IsFrameWidget(closeButton) and cancelButton then
			Input:SetButton(cancelButton, self, closeButton, true, 'LeftButton')
		end
	end
end


---------------------------------------------------------------
-- Cursor textures and animations
---------------------------------------------------------------
do	local f, path = format, 'Gamepad/Active/Icons/%s-64';
	-- lambdas to handle texture swapping without caching icons
	local function left  () return db('UIpointerDefaultIcon') and db(f(path, db('UICursorLeftClick'))) end
	local function mod   () return db(f(path, db('Gamepad/Index/Modifier/Key/' .. db('UImodifierCommands')) or '')) end
	local function opt   () return db(f(path, db('UICursorSpecial'))) end
	local function right () return db(f(path, db('UICursorRightClick'))) end

	Cursor.Textures = CPAPI.Proxy({
		Right    = right;
		Modifier = mod;
		-- object cases
		EditBox  = opt;
		Slider   = nop;
		Frame    = nop;
	}, function() return left end)
	-- remove texture evaluator so cursor refreshes on next movement
	local function ResetTexture(self)
		self.textureEvaluator = nil;
		self.useAtlasIcons = db('useAtlasIcons')
	end
	db:RegisterCallbacks(ResetTexture, Cursor,
		'Gamepad/Active',
		'Settings/UIpointerDefaultIcon',
		'Settings/useAtlasIcons'
	);
	ResetTexture(Cursor)
end

function Cursor:SetTexture(texture)
	local object = texture or self:GetCurrentObjectType()
	local evaluator = self.Textures[object]
	if ( evaluator ~= self.textureEvaluator ) then
		local node = self:GetCurrentNode()
		if self.useAtlasIcons then
			local atlas = evaluator(node)
			if atlas then
				self.Display.Button:SetAtlas(atlas)
			else
				self.Display.Button:SetTexture(nil)
			end
		else
			self.Display.Button:SetTexture(evaluator(node))
		end
	end
	self.textureEvaluator = evaluator;
end

function Cursor:ToggleScrollIndicator(enabled)
	self.Display.Scroller:SetPoint('LEFT', self.Display.Button, 'RIGHT', self.Display.Button:GetTexture() and 2 or -16, 0)
	if self.isScrollingActive == enabled then return end;
	local evaluator = self.Textures.Modifier;
	local texture   = evaluator and evaluator() or nil;
	local newAlpha  = ( enabled and texture and 1 ) or 0;
	Fade.In(self.Display.ScrollUp,   0.2, self.Display.ScrollUp:GetAlpha(),   newAlpha)
	Fade.In(self.Display.ScrollDown, 0.2, self.Display.ScrollDown:GetAlpha(), newAlpha)
	Fade.In(self.Display.Scroller,   0.2, self.Display.Scroller:GetAlpha(),   newAlpha)
	if enabled then
		if self.useAtlasIcons then
			if texture then
				self.Display.Scroller:SetAtlas(texture)
			else
				self.Display.Scroller:SetTexture(nil)
			end
		else
			self.Display.Scroller:SetTexture(texture)
		end
	end
	self.isScrollingActive = enabled;
end

function Cursor:SetAnchor(node)
	self.hasCustomAnchor = node.customCursorAnchor
	self.anchor = self.hasCustomAnchor or {'TOPLEFT', node, 'CENTER', Node.GetCenterPos(node)}
end

function Cursor:GetCustomAnchor()
	return self.hasCustomAnchor
end

function Cursor:GetAnchor()
	return self.anchor
end

function Cursor:RefreshAnchor()
	if not self:GetCustomAnchor() then
		local node = self:GetCurrentNode()
		self:ClearAllPoints()
		self:SetPoint('CENTER', node, 'CENTER', Node.GetCenterPos(node))
	end
end

function Cursor:SetPosition(node)
	self:SetTexture()
	self:SetAnchor(node)
	self:Show()
	self:Move()
end

function Cursor:Move()
	local node = self:GetCurrentNode()
	if node then
		self:ClearHighlight()
		local newX, newY = Node.GetCenter(node)
		local oldX, oldY = self:GetCenter()
		if oldX and oldY and newX and newY and self:IsVisible() then
			self.Enlarge:SetStartDelay(0.05)
			self.ScaleInOut:ConfigureScale()
			self:Chime()
		else
			self.Enlarge:SetStartDelay(0)
		end
		self:SetHighlight(node)
	end
end

function Cursor:Chime()
	if not self.enableSound then return end;
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON, 'Master', false, false)
end

function Cursor:UpdatePointer()
	self.Display:SetSize(db('UIpointerSize'))
	self.Display:SetOffset(db('UIpointerOffset'))
	self.Display:SetRotationEnabled(db('UIpointerAnimation'))
	self.Display.animationSpeed = db('UItravelTime');
	self.enableSound = db('UIpointerSound')
end

db:RegisterCallbacks(Cursor.UpdatePointer, Cursor,
	'Settings/UItravelTime',
	'Settings/UIpointerSize',
	'Settings/UIpointerOffset',
	'Settings/UIpointerAnimation',
	'Settings/UIpointerSound'
);

-- Highlight mime
---------------------------------------------------------------
function Cursor:ClearHighlight()
	self.Mime:Clear()
end


function Cursor:SetHighlight(node)
	if node and (not node.IsEnabled or node:IsEnabled()) and not node:GetAttribute(env.Attributes.IgnoreMime) then
		self.Mime:SetNode(node)
	else
		self:ClearHighlight()
	end
end

function Cursor.Mime:SetFontString(region)
	if region:IsShown() and region:GetFont() then
		local obj = self.Fonts:Acquire()
		obj:SetFont(obj.GetFont(region))
		obj:SetText(obj.GetText(region))
		obj:SetTextColor(obj.GetTextColor(region))
		obj:SetJustifyH(obj.GetJustifyH(region))
		obj:SetJustifyV(obj.GetJustifyV(region))
		obj:SetSize(obj.GetSize(region))
		for i=1, obj.GetNumPoints(region) do
			obj:SetPoint(obj.GetPoint(region, i))
		end
		obj:Show()
	end
end

function Cursor.Mime:SetTexture(region)
	if region:IsShown() then
		local obj = self.Textures:Acquire()
		if obj.GetAtlas(region) then
			obj:SetAtlas(obj.GetAtlas(region))
		else
			local texture = obj.GetTexture(region)
			-- DEPRECATED: returns File Data ID <num> in 9.0
			if (type(texture) == 'string') and texture:find('^[Cc]olor-') then
				obj:SetColorTexture(CPAPI.Hex2RGB(texture:sub(7), true))
			else
				obj:SetTexture(texture)
			end
		end
		obj:SetBlendMode(obj.GetBlendMode(region))
		obj:SetTexCoord(obj.GetTexCoord(region))
		obj:SetVertexColor(obj.GetVertexColor(region))
		obj:SetSize(obj.GetSize(region))
		obj:SetRotation(obj.GetRotation(region))
		for i=1, obj.GetNumPoints(region) do
			obj:SetPoint(obj.GetPoint(region, i))
		end
		obj:Show()
	end
end

function Cursor.Mime:SetNode(node)
	self:MimeRegions(node:GetRegions())
	self:ClearAllPoints()
	self:SetSize(node:GetSize())
	self:SetScale(node:GetEffectiveScale() / Cursor:GetEffectiveScale())
	self:Show()
	for i=1, node:GetNumPoints() do
		self:SetPoint(node:GetPoint(i))
	end
	self.Scale:Stop()
	self.Scale:Play()
end

function Cursor.Mime:Clear()
	self.Fonts:ReleaseAll()
	self.Textures:ReleaseAll()
	self:Hide()
end

function Cursor.Mime:MimeRegions(region, ...)
	if region then
		if (region:GetDrawLayer() == 'HIGHLIGHT') then
			if (region:GetObjectType() == 'Texture') then
				self:SetTexture(region)
			elseif (region:GetObjectType() == 'FontString') then
				self:SetFontString(region)
			end
		end
		self:MimeRegions(...)
	end
end

-- Animation scripts
---------------------------------------------------------------
function Cursor:SetFlashNextNode()
	self.ScaleInOut.Flash = true;
end

function Cursor.ScaleInOut:ConfigureScale()
	local cur, old = Cursor:GetCurrent(), Cursor:GetOld()
	if (cur == old) and not self.Flash then
		self.Shrink:SetDuration(0)
		self.Enlarge:SetDuration(0)
	elseif cur then
		local scaleAmount, shrinkDuration = 1.15, 0.2
		if self.Flash then
			scaleAmount = 1.75
			shrinkDuration = 0.5
		end
		self.Flash = nil
		self.Enlarge:SetScale(scaleAmount, scaleAmount)
		self.Shrink:SetScale(1/scaleAmount, 1/scaleAmount)
		self.Shrink:SetDuration(shrinkDuration)
		self.Enlarge:SetDuration(.1)
	end
end

function Cursor.Mime.Scale:OnPlay()
	self.Enlarge:SetScale(Cursor.ScaleInOut.Enlarge:GetScale())
	self.Shrink:SetScale(Cursor.ScaleInOut.Shrink:GetScale())

	self.Enlarge:SetDuration(Cursor.ScaleInOut.Enlarge:GetDuration())
	self.Shrink:SetDuration(Cursor.ScaleInOut.Shrink:GetDuration())

	self.Enlarge:SetStartDelay(Cursor.ScaleInOut.Enlarge:GetStartDelay())
	self.Shrink:SetStartDelay(Cursor.ScaleInOut.Shrink:GetStartDelay())
end

function Cursor.ScaleInOut:OnPlay()
	Cursor.Mime:SetParent(Cursor:GetCurrentNode() or Cursor)
end

do  -- Set up animation scripts
	local animationGroups = {Cursor.ScaleInOut, Cursor.Mime.Scale}

	local function setupScripts(w)
		for k, v in pairs(w) do
			if w:HasScript(k) then w:SetScript(k, v) end
		end
	end

	for _, group in pairs(animationGroups) do
		setupScripts(group)
		for _, animation in pairs({group:GetAnimations()}) do
			setupScripts(animation)
		end
	end

	-- Convenience references to animations
	Cursor.Enlarge = Cursor.ScaleInOut.Enlarge;
	Cursor.Shrink  = Cursor.ScaleInOut.Shrink;
end

---------------------------------------------------------------
-- Initialize the cursor
---------------------------------------------------------------
CPAPI.Start(Cursor)
Cursor:UpdatePointer()