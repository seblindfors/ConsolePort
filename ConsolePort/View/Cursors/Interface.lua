---------------------------------------------------------------
-- Interface cursor
---------------------------------------------------------------
-- Creates a cursor used to manage the interface with D-pad.
-- Operates recursively on frames and calculates appropriate
-- actions based on node priority and position on screen.
-- Leverages Controller\UINode.lua for interface scans.

local _, db = ...;
local Cursor, Node, Input, Stack, Scroll, Fade, Intellisense = 
	CPAPI.EventHandler(ConsolePortCursor),
	ConsolePortNode,
	ConsolePortInputHandler,
	ConsolePortUIStackHandler,
	CreateFrame('Frame'),
	db.Alpha.Fader, db.Intellisense;

db:Register('Cursor', Cursor)
Cursor.InCombat = InCombatLockdown;

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function Cursor:OnDataLoaded()
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	self:UpdatePointer()
end

function Cursor:PLAYER_REGEN_DISABLED()
	-- TODO: relinquish to stack control
	if self:IsShown() then
		Fade.Out(self, 0.2, self:GetAlpha(), 0)
		self:ShowAfterCombat(true)
		self:SetFlashNextNode()
		self:Release()
	end
end

function Cursor:PLAYER_REGEN_ENABLED()
	-- time lock this in case it fires more than once
	if not self.timeLock and self.showAfterCombat then
		self.timeLock = true
		C_Timer.After(db('UIleaveCombatDelay'), function()
			Fade.In(self, 0.2, self:GetAlpha(), 1)
			if not self:InCombat() and self:IsShown() then
				self:SetBasicControls()
				self:Refresh()
			end
			self.timeLock = nil
			self.showAfterCombat = nil
		end)
	-- in case the cursor is showing and waiting to hide OOC
	elseif self:IsShown() and not self.showAfterCombat then
		self:Hide()
	end
end

function Cursor:MODIFIER_STATE_CHANGED()
	-- TODO: implement this? maybe?
end

---------------------------------------------------------------
-- Cursor state
---------------------------------------------------------------
function Cursor:OnClick()
	self:SetEnabled(not self:IsShown())
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
end

function Cursor:OnHide()
	self.timer = 0
	self:SetAlpha(1)
	self:SetFlashNextNode()
	self:Release()
	self.Blocker:Hide()
end

function Cursor:Release()
	Node.ClearCache()
	self:OnLeaveNode(self:GetCurrentNode())
	self:SetHighlight()
	Input:Release(self)
end

function Cursor:IsObstructed()
	return self:InCombat(), not db('UIenableCursor')
end

function Cursor:IsAnimating()
	return self.ScaleInOut:IsPlaying()
end

function Cursor:ShowAfterCombat(enabled)
	self.showAfterCombat = enabled
end

function Cursor:ScanUI()
	if db('UIaccessUnlimited') then
		Node(UIParent, DropDownList1, DropDownList2)
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

function Cursor:SetCurrentNode(node, assertNotMouse)
	if not db('UIenableCursor') then
		return
	end
	local object = node and Node.ScanLocal(node)[1]
	if object and (not assertNotMouse or IsGamePadFreelookEnabled()) then
		self:SetBasicControls()
		self:SetFlashNextNode()
		self:SetCurrent(object)
		self:SelectAndPosition(self:GetSelectParams(object, true))
		self:Chime()
		return true;
	end
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
	local InputProxy = function(self, ...)
		self:Show()
		Cursor:Input(self, ...)
	end

	local DpadRepeater = function(self, elapsed)
		self.timer = self.timer + elapsed
		if self.timer >= self.UIControlTickNext and self.state then
			local func = self:GetAttribute('type')
			if ( func == 'UIControl' ) then
				self[func](self, self.state, self:GetAttribute('id'))
			end
			self.timer = 0
		end
	end

	local DpadInit = function(self, dpadRepeater)
		if not db('UIholdRepeatDisable') then
			self.UIControlTickNext = db('UIholdRepeatDelay')
			self:SetScript('OnUpdate', dpadRepeater)
		end
	end

	local DpadClear = function(self)
		self:SetScript('OnUpdate', nil)
		self:Hide()
	end

	local Disable = function(self)
		self:Hide()
		Cursor:Hide()
		SetGamePadCursorControl(true)
	end

	function Cursor:GetBasicControls()
		--  @init : (optional) function to set up properties
		--  @clear: (optional) function to run when clearing
		--  @args : (optional) properties for initialization
		if not self.BasicControls then
			self.BasicControls = {
				PADDUP    = {InputProxy, DpadInit, DpadClear, DpadRepeater};
				PADDDOWN  = {InputProxy, DpadInit, DpadClear, DpadRepeater};
				PADDLEFT  = {InputProxy, DpadInit, DpadClear, DpadRepeater}; 
				PADDRIGHT = {InputProxy, DpadInit, DpadClear, DpadRepeater};
				[db('Settings/UICursorSpecial')] = {InputProxy};
			};
		end
		return self.BasicControls
	end

	function Cursor:SetBasicControls()
		local controls = self:GetBasicControls()
		for button, settings in pairs(controls) do
			Input:SetCommand(button, self, true, button, 'UIControl', unpack(settings));
		end
	end

	-- Callbacks to reset controls when inputters change
	do local function ResetControls(self) self.BasicControls = nil; end
		db:RegisterCallbacks(ResetControls, Cursor,
			'Settings/UICursorSpecial',
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
				pcall(ExecuteFrameScript, node, script, emubtn)
			end
			if (down and node.OnClick) then
				node:OnClick(emubtn)
			end
		end
	end

	local EmuClickInit = function(self, node, emubtn)
		self.node   = node;
		self.emubtn = emubtn;
	end

	local EmuClickClear = function(self)
		self.node  = nil;
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
		target, changed = Node.NavigateToBestCandidate(self.Cur, key)
		if changed then
			return target, changed
		end
		return self:ReverseScanUI(parent, key)
	end
	return self.Cur, false
end

function Cursor:Navigate(key)
	local target, changed
	if db('UIaccessUnlimited') then
		target, changed = self:SetCurrent(self:ReverseScanUI(self:GetCurrentNode(), key))
	else
		self:ScanUI()
		target, changed = self:SetCurrent(Node.NavigateToBestCandidate(self:GetCurrent(), key))
	end
	if not changed then
		target, changed = self:SetCurrent(Node.NavigateToClosestCandidate(target, key))
	end
	return target, changed
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

function Cursor:Input(caller, isDown, key)
	local target, changed
	if isDown and key then
		if not self:AttemptDragStart() then
			target, changed = self:Navigate(key)
		end
	elseif ( key == db('Settings/UICursorSpecial') ) then
		return Intellisense:ProcessInterfaceCursorEvent(key, isDown, self:GetCurrentNode())
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

function Cursor:GetSelectParams(obj, triggerOnEnter)
	return obj.node, obj.object, obj.super, triggerOnEnter;
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
-- SafeOnEnter, SafeOnLeave:
-- Replace problematic OnEnter/OnLeave scripts.
-- Original functions become taint-bearing when called insecurely
-- because they modify properties of protected objects.
---------------------------------------------------------------
do local SafeOnEnter, SafeOnLeave, SafeExecute = {}, {}, ExecuteFrameScript

	-------[[  OnEnter  ]]-------
	SafeOnEnter[ActionButton1:GetScript('OnEnter')] = function(self)
		ActionButton_SetTooltip(self)
	end
	SafeOnEnter[SpellButton1:GetScript('OnEnter')] = function(self)
		-- spellbook buttons push updates to the action bar controller in order to draw highlights
		-- on actionbuttons that holds the spell in question. this taints the action bar controller.
		local slot = SpellBook_GetSpellBookSlot(self)
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
		if ( GameTooltip:SetSpellBookItem(slot, SpellBookFrame.bookType) ) then
			self.UpdateTooltip = SafeOnEnter[SpellButton1:GetScript('OnEnter')]
		else
			self.UpdateTooltip = nil
		end
		
		if ( self.SpellHighlightTexture and self.SpellHighlightTexture:IsShown() ) then
			GameTooltip:AddLine(SPELLBOOK_SPELL_NOT_ON_ACTION_BAR, LIGHTBLUE_FONT_COLOR.r, LIGHTBLUE_FONT_COLOR.g, LIGHTBLUE_FONT_COLOR.b)
		end
		GameTooltip:Show()
	end
	if QuestMapLogTitleButton_OnEnter then
		SafeOnEnter[QuestMapLogTitleButton_OnEnter] = function(self)
			-- this replacement script runs itself, but handles a particular bug when the cursor is atop a quest button when the map is opened.
			-- all data is not yet populated so difficultyHighlightColor can be nil, which isn't checked for in the default UI code.
			if self.questLogIndex then
				local _, level, _, isHeader, _, _, _, _, _, _, _, _, _, _, _, _, isScaling = GetQuestLogTitle(self.questLogIndex)
				local _, difficultyHighlightColor = GetQuestDifficultyColor(level, isScaling)
				if ( isHeader ) then
					_, difficultyHighlightColor = QuestDifficultyColors['header']
				end
				if difficultyHighlightColor then
					QuestMapLogTitleButton_OnEnter(self)
				end
			end
		end
	end
	-------[[  OnLeave  ]]-------
	SafeOnLeave[SpellButton_OnLeave] = function(self)
		GameTooltip:Hide()
	end
	---------------------------------------------------------------
	-- Allow access to these tables for plugins and addons on demand.
	function Cursor:ReplaceOnEnter(original, replacement) SafeOnEnter[original] = replacement end
	function Cursor:ReplaceOnLeave(original, replacement) SafeOnLeave[original] = replacement end

	---------------------------------------------------------------
	-- OnEnter/OnLeave script triggers
	local function TriggerScript(node, scriptType, replacement)
		local script = replacement[node:GetScript(scriptType)]
		if script then
			pcall(script, node)
		else
			pcall(SafeExecute, node, scriptType)
		end
	end

	function Cursor:OnLeaveNode(node)
		if node then
			Intellisense:OnNodeLeave()
			TriggerScript(node, 'OnLeave', SafeOnLeave)
		end
	end

	function Cursor:OnEnterNode(node)
		if node then
			TriggerScript(node, 'OnEnter', SafeOnEnter)
		end
	end
end

---------------------------------------------------------------
-- Node management resources
---------------------------------------------------------------
do	local IsClickable = {
		Button 		= true;
		CheckButton = true;
		EditBox 	= true;
	}

	local DropDownMacros = {
		SET_FOCUS = '/focus %s';
		CLEAR_FOCUS = '/clearfocus';
		PET_DISMISS = '/petdismiss';
	}


	function Cursor:IsClickableNode(node, object)
		local isClickableObject = (IsClickable[object] and object ~= 'EditBox');
		if not isClickableObject then
			return false;
		end
		if node:GetScript('OnClick') then
			return true;
		end
		return not node:GetScript('OnMouseDown') and not node:GetScript('OnMouseUp')
	end

	function Cursor:GetMacroReplacement(node)
		return DropDownMacros[node.value];
	end
end

---------------------------------------------------------------
-- Node selection
---------------------------------------------------------------
function Cursor:SelectAndPosition(node, object, super, newMove)
	if newMove then
		self:OnLeaveNode(self:GetOldNode())
		self:SetPosition(node)
	end
	self:Select(node, object, super, newMove)
	return node
end

function Cursor:Select(node, object, super, triggerOnEnter)
	self:OnEnterNode(triggerOnEnter and node)

	-- Scroll to node center
	if super and not super:GetAttribute('nodeignorescroll')
		and not IsShiftKeyDown() and not IsControlKeyDown() then
		Scroll:To(node, super)
	end

	if (object == 'Slider') then
		-- TODO: Override:HorizontalScroll(Cursor, node)
	end

	self:SetScrollButtonsForNode(node)
	self:SetClickButtonsForNode(node,
		self:GetMacroReplacement(node),
		self:IsClickableNode(node, object)
	);
end

function Cursor:SetScrollButtonsForNode(node)
	local scrollUp, scrollDown = Node.GetScrollButtons(node)
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
		Slider   = mod;
	}, function() return left end)
	-- remove texture evaluator so cursor refreshes on next movement
	local function resetTexture(self) self.textureEvaluator = nil; end
	db:RegisterCallback('Gamepad/Active', resetTexture, Cursor)
	db:RegisterCallback('Settings/UIpointerDefaultIcon', resetTexture, Cursor)
end

function Cursor:SetTexture(texture)
	local object = texture or self:GetCurrentObjectType()
	local evaluator = self.Textures[object]
	if ( evaluator ~= self.textureEvaluator ) then
		self.Display.Button:SetTexture(evaluator())
	end
	self.textureEvaluator = evaluator;
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

function Cursor:MoveTowardsAnchor(elapsed)
	if not self:GetCustomAnchor() then
		local divisor = 4 - elapsed; -- 4 is about right, account for FPS
		local cX, cY = self:GetLeft(), self:GetTop()
		local nX, nY = Node.GetCenter(self:GetCurrentNode())
		self:ClearAllPoints()
		if cX and cY then
			return self:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT',
				cX + ((nX - cX) / divisor),
				cY + ((nY - cY) / divisor)
			);
		end
		self:SetPoint('TOPLEFT', self:GetCurrentNode(), 'CENTER', nX, nY)
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
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON, 'Master', false, false)
end

function Cursor:UpdatePointer()
	self.Display:SetSize(db('UIpointerSize'))
	self.Display:SetOffset(db('UIpointerOffset'))
	self.Display:SetRotationEnabled(db('UIpointerAnimation'))
	self.Display.animationSpeed = db('UItravelTime');
end

db:RegisterCallbacks(Cursor.UpdatePointer, Cursor,
	'Settings/UItravelTime',
	'Settings/UIpointerSize',
	'Settings/UIpointerOffset',
	'Settings/UIpointerAnimation'
);

-- Highlight mime
---------------------------------------------------------------
function Cursor:ClearHighlight()
	self.Mime:Clear()
end


function Cursor:SetHighlight(node)
	if node and (not node.IsEnabled or node:IsEnabled()) then
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
-- Scroll management
---------------------------------------------------------------
function Scroll:OnUpdate(elapsed)
	for super, target in pairs(self.Active) do
		local currHorz, currVert = super:GetHorizontalScroll(), super:GetVerticalScroll()
		local maxHorz, maxVert = super:GetHorizontalScrollRange(), super:GetVerticalScrollRange()
		-- close enough, stop scrolling and set to target
		if ( abs(currHorz - target.horz) < 2 ) and ( abs(currVert - target.vert) < 2 ) then
			super:SetVerticalScroll(target.vert)
			super:SetHorizontalScroll(target.horz)
			self.Active[super] = nil
			return
		end
		local deltaX, deltaY = ( currHorz > target.horz and -1 or 1 ), ( currVert > target.vert and -1 or 1 )
		local newX = ( currHorz + (deltaX * abs(currHorz - target.horz) / 16 * 4) )
		local newY = ( currVert + (deltaY * abs(currVert - target.vert) / 16 * 4) )

		super:SetVerticalScroll(newY < 0 and 0 or newY > maxVert and maxVert or newY)
		super:SetHorizontalScroll(newX < 0 and 0 or newX > maxHorz and maxHorz or newX)
	end
	if not next(self.Active) then
		self:SetScript('OnUpdate', nil)
	end
end

function Scroll:To(node, super)
	local nodeX, nodeY = Node.GetCenter(node)
	local scrollX, scrollY = super:GetCenter()
	if nodeY and scrollY then

		-- HACK: make sure this isn't a hybrid scroll frame
		if super:IsObjectType('ScrollFrame') and super:GetScript('OnLoad') ~= HybridScrollFrame_OnLoad then
			local currHorz, currVert = super:GetHorizontalScroll(), super:GetVerticalScroll()
			local maxHorz, maxVert = super:GetHorizontalScrollRange(), super:GetVerticalScrollRange()

			local newVert = currVert + (scrollY - nodeY)
			local newHorz = 0
		-- 	TODO: horizontal scrollers
		--	local newHorz = currHorz + (scrollX - nodeX)

			if not self.Active then
				self.Active = {}
			end

			self.Active[super] = {
				vert = newVert < 0 and 0 or newVert > maxVert and maxVert or newVert,
				horz = newHorz < 0 and 0 or newHorz > maxHorz and maxHorz or newHorz,
			}

			self:SetScript('OnUpdate', self.OnUpdate)
		end
	end
end

---------------------------------------------------------------
-- Initialize the cursor
---------------------------------------------------------------
CPAPI.Start(Cursor)
hooksecurefunc('CanAutoSetGamePadCursorControl', function(state)
	-- TODO: work on this, it's not good yet
	if not state then
	--	Cursor:SetEnabled(state)
	end
end)

hooksecurefunc('ShowUIPanel', function(frame)
	if not Cursor:InCombat() then
	--	Cursor:RefreshToFrame(frame)
	end
end)