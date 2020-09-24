---------------------------------------------------------------
-- Interface cursor
---------------------------------------------------------------
-- Creates a cursor used to manage the interface with D-pad.
-- Operates recursively on frames and calculates appropriate
-- actions based on node priority and position on screen.
-- Leverages Controller\UINode.lua for interface scans.

local _, db = ...;
local Cursor, Node, Input, Scroll, Fade = 
	CPAPI.EventHandler(ConsolePortCursor),
	ConsolePortNode,
	ConsolePortInputHandler,
	CreateFrame('Frame'),
	db('Alpha/Fader');

db:Register('Cursor', Cursor)
Cursor.InCombat = InCombatLockdown;

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function Cursor:OnDataLoaded()
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	self:RegisterEvent('CURSOR_CHANGED')
end

function Cursor:PLAYER_REGEN_DISABLED()
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

function Cursor:CURSOR_CHANGED(isDefault)
	if not isDefault then
		-- TODO: QA
	--	SetGamePadCursorControl(true)
	end
end

function Cursor:MODIFIER_STATE_CHANGED()
	-- TODO: implement this? maybe?
end

---------------------------------------------------------------
-- Cursor state
---------------------------------------------------------------
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

function Cursor:OnHide()
	self.timer = 0
	self:SetAlpha(1)
	self:SetFlashNextNode()
	self:Release()
end

function Cursor:Release()
	Node.ClearCache()
	self:OnLeaveNode(self:GetCurrentNode())
	self:SetHighlight()
	Input:Release(self)
end

function Cursor:IsObstructed()
	return self:InCombat(), db('UIdisableCursor')
end

function Cursor:IsAnimating()
	return self.MoveAndScale:IsPlaying()
end

function Cursor:ShowAfterCombat(enabled)
	self.showAfterCombat = enabled
end

function Cursor:ScanUI()
	Node(UIParent, DropDownList1, DropDownList2) -- TODO: remove hardcoding
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

function Cursor:SetCurrentNode(node, uniqueTriggered)
	local object = node and Node.ScanLocal(node)[1]
	if object and (not uniqueTriggered or not GetMouseButtonClicked()) then
		self:OnLeaveNode(self:GetCurrentNode())
		self:SetCurrent(object)
		self:SetFlashNextNode()
		self:Select(self:GetSelectParams(object, true))
		self:RefreshAnchor()
		self:SetHighlight(node)
		self:Chime()
	end
end

function Cursor:OnUpdate(elapsed)
	if self:InCombat() then return end
	if not self:IsCurrentNodeDrawn() then
		self:SetFlashNextNode()
		if not self:Refresh() then
			self:Hide()
		end
	elseif not self:IsAnimating() then
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
		self.BasicControls = {
			PADDUP    = {InputProxy, DpadInit, DpadClear, DpadRepeater};
			PADDDOWN  = {InputProxy, DpadInit, DpadClear, DpadRepeater};
			PADDLEFT  = {InputProxy, DpadInit, DpadClear, DpadRepeater}; 
			PADDRIGHT = {InputProxy, DpadInit, DpadClear, DpadRepeater};
			[db('Settings/UICursor/Special')] = {InputProxy};
		};
		local clickL, clickR = GetCVar('GamePadCursorLeftClick'), GetCVar('GamePadCursorRightClick')
		if clickL then self.BasicControls[clickL] = {Disable}; end
		if clickR then self.BasicControls[clickR] = {Disable}; end
		return self.BasicControls
	end

	function Cursor:SetBasicControls()
		local controls = self:GetBasicControls()
		for button, settings in pairs(controls) do
			Input:SetCommand(button, self, false, button, 'UIControl', unpack(settings));
		end
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
	local target, changed = self:SetCurrent(self:ReverseScanUI(self:GetCurrentNode(), key))
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
		target, changed = self:Navigate(key)
	elseif ( key == db('Settings/UICursor/Special') ) then
		-- TODO: implement special action
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
		return oldObj, false
	end
	self.Old = oldObj;
	self.Cur = newObj;
	return newObj, true
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
	return obj.node, obj.object, obj.super, triggerOnEnter
end

function Cursor:GetOld()
	return self.Old;
end

function Cursor:GetOldNode()
	local obj = self:GetOld()
	return obj and obj.node
end

function Cursor:StoreCurrent()
	local current = self:GetCurrent()
	self.Old = current
	self:SetCurrent(nil)
end

---------------------------------------------------------------
-- Node management resources
---------------------------------------------------------------
local IsClickable = {
	Button 		= true;
	CheckButton = true;
	EditBox 	= true;
}

local DropDownMacros = {
	SET_FOCUS = '/focus %s';
	CLEAR_FOCUS = '/clearfocus';
	PET_DISMISS = '/petdismiss';
}

---------------------------------------------------------------
-- SafeOnEnter, SafeOnLeave:
-- Replace problematic OnEnter/OnLeave scripts.
-- Original functions become taint-bearing when called insecurely
-- because they modify properties of protected objects.
---------------------------------------------------------------
local SafeOnEnter, SafeOnLeave = {}, {}
---------------------------------------------------------------
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
local function HasOnEnterScript(node)
	return node.GetScript and node:GetScript('OnEnter') and true
end

local function TriggerScript(node, scriptType, replacement)
	local script = replacement[node:GetScript(scriptType)] or node:GetScript(scriptType)
	if script then
		pcall(script, node)
	end
end

---------------------------------------------------------------
-- Node selection
---------------------------------------------------------------
function Cursor:OnLeaveNode(node)
	if node then
		TriggerScript(node, 'OnLeave', SafeOnLeave)
	end
end

function Cursor:OnEnterNode(node)
	if node then
		TriggerScript(node, 'OnEnter', SafeOnEnter)
	end
end

function Cursor:SelectAndPosition(node, object, super, newMove)
	if newMove then
		self:OnLeaveNode(self:GetOldNode())
		self:SetPosition(node)
	end
	self:Select(node, object, super, newMove)
	return node
end

function Cursor:Select(node, object, super, triggerOnEnter)
	local name = node.direction and node:GetName() -- TODO: fix this hack 
	local override = (IsClickable[object] and object ~= 'EditBox')

	self:OnEnterNode(triggerOnEnter and node)

	-- If this node has a forbidden dropdown value, override macro instead.
	local macro = DropDownMacros[node.value]
	-- TODO: ignoreScroll should not be a table key
	if super and not super.ignoreScroll and not IsShiftKeyDown() and not IsControlKeyDown() then
		Scroll:To(node, super)
	end

	self:SetScrollButtonsForNode(node)

	if object == 'Slider' then
		-- TODO: Override:HorizontalScroll(Cursor, node)
	end

	self:SetClickButtonsForNode(node, override, macro)
end

function Cursor:SetScrollButtonsForNode(node)
	local scrollUp, scrollDown = Node.GetScrollButtons(node)
	if scrollUp and scrollDown then
		local modifier = db('UImodifierCommands')
		Input:SetButton(format('%s-%s', modifier, 'PADDUP'), self, scrollUp)
		Input:SetButton(format('%s-%s', modifier, 'PADDDOWN'), self, scrollDown)
		return scrollUp, scrollDown
	end
end

function Cursor:SetClickButtonsForNode(node, isClickable, macroReplacement)
	for click, button in pairs({
		LeftButton  = db('Settings/UICursor/LeftClick');
		RightButton = db('Settings/UICursor/RightClick');
	}) do for modifier in db:For('Gamepad/Index/Modifier/Active') do
			if macroReplacement then
				local unit = UIDROPDOWNMENU_INIT_MENU.unit
				Input:Macro(button .. modifier, self, macroReplacement:format(unit or ''))
			elseif isClickable then
				Input:SetButton(button .. modifier, self, node, false, click)
			else
				Input:SetButton(button .. modifier, self, false, false, click)
			end
		end
	end
end

---------------------------------------------------------------
-- Cursor textures and animations
---------------------------------------------------------------
do  -- lambdas to handle texture swapping without caching icons
	local f, path = format, 'Gamepad/Active/Icons/%s-64';

	local function mod   () return db(f(path, db('Gamepad/Index/Modifier/Key/' .. db('UImodifierCommands')) or '')) end
	local function opt   () return db(f(path, db('Settings/UICursor/Special'))) end
	local function left  () return db(f(path, db('Settings/UICursor/LeftClick'))) end
	local function right () return db(f(path, db('Settings/UICursor/RightClick'))) end

	Cursor.Textures = CPAPI.Proxy({
		Left     = left;
		Right    = right;
		Modifier = mod;
		-- object cases
		EditBox  = opt;
		Slider   = mod;
	}, function() return left end)
end

function Cursor:SetTexture(texture)
	local object = texture or self:GetCurrentObjectType()
	local lambda = self.Textures[object]
	if ( lambda ~= self.textureLambda ) then
		self.Button:SetTexture(lambda())
	end
	self.textureLambda = lambda
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
		self:SetPoint('TOPLEFT', node, 'CENTER', Node.GetCenterPos(node))
	end
end

function Cursor:SetPosition(node)
	local oldAnchor = self:GetAnchor()
	self:SetTexture()
	self:SetAnchor(node)
	self:Show()
	self:Move(oldAnchor)
end

function Cursor:SetPointer(node)
	self.Pointer:ClearAllPoints()
	self.Pointer:SetParent(node)
	self.Pointer:SetPoint(unpack(self:GetAnchor()))
	return self.Pointer:GetCenter()
end

function Cursor:Move(oldAnchor)
	local node = self:GetCurrentNode()
	if node then
		self:ClearHighlight()
		local newX, newY = self:SetPointer(node)
		if self:IsAnimating() then
			self.MoveAndScale:Stop()
			self.MoveAndScale:OnFinished(oldAnchor)
		end
		local oldX, oldY = self:GetCenter()
		if ( not node.noAnimation ) and oldX and oldY and newX and newY and self:IsVisible() then
			local oldScale, newScale = self:GetEffectiveScale(), self.Pointer:GetEffectiveScale()
			local sDiff, sMult = oldScale / newScale, newScale / oldScale
			self.Translate:SetOffset((newX - oldX * sDiff) * sMult, (newY - oldY * sDiff) * sMult)
			self.Enlarge:SetStartDelay(0.05)
			self.MoveAndScale:ConfigureScale()
			self.MoveAndScale:Play()
		else
			self.Enlarge:SetStartDelay(0)
			self.MoveAndScale:OnFinished()
		end
	end
end

-- Highlight mime
---------------------------------------------------------------
function Cursor:ClearHighlight()
	self.Highlight:ClearAllPoints()
	self.Highlight:SetParent(self)
	self.Highlight:SetTexture(nil)
end

function Cursor:SetHighlight(node)
	local mime = self.Highlight
	local highlight = node and node.GetHighlightTexture and node:GetHighlightTexture()
	if highlight and node:IsEnabled() then
		if highlight:GetAtlas() then
			mime:SetAtlas(highlight:GetAtlas())
		else
			local texture = highlight.GetTexture and highlight:GetTexture()
			if (type(texture) == 'string') and texture:find('^[Cc]olor-') then
				local r, g, b, a = CPAPI.Hex2RGB(texture:sub(7), true)
				mime:SetColorTexture(r, g, b, a)
			else
				mime:SetTexture(texture)
			end
			mime:SetBlendMode(highlight:GetBlendMode())
			mime:SetVertexColor(highlight:GetVertexColor())
		end
		mime:SetSize(highlight:GetSize())
		mime:SetTexCoord(highlight:GetTexCoord())
		mime:SetAlpha(highlight:GetAlpha())
		mime:ClearAllPoints()
		mime:SetPoint(highlight:GetPoint())
		mime:Show()
		mime.Scale:Stop()
		mime.Scale:Play()
	else
		mime:ClearAllPoints()
		mime:Hide()
	end
end

function Cursor:Chime()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON, 'Master', false, false)
end

-- Animation scripts
---------------------------------------------------------------
function Cursor:SetFlashNextNode()
	self.MoveAndScale.Flash = true;
end

function Cursor.MoveAndScale:ConfigureScale()
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

function Cursor.Highlight.Scale:OnPlay()
	self.Enlarge:SetScale(Cursor.MoveAndScale.Enlarge:GetScale())
	self.Shrink:SetScale(Cursor.MoveAndScale.Shrink:GetScale())

	self.Enlarge:SetDuration(Cursor.MoveAndScale.Enlarge:GetDuration())
	self.Shrink:SetDuration(Cursor.MoveAndScale.Shrink:GetDuration())

	self.Enlarge:SetStartDelay(Cursor.MoveAndScale.Enlarge:GetStartDelay())
	self.Shrink:SetStartDelay(Cursor.MoveAndScale.Shrink:GetStartDelay())
end

function Cursor.MoveAndScale.Translate:OnFinished()
	Cursor:SetHighlight(Cursor:GetCurrentNode())
end

function Cursor.MoveAndScale:OnPlay()
	Cursor.Highlight:SetParent(Cursor:GetCurrentNode() or Cursor)
	Cursor:Chime()
end

function Cursor.MoveAndScale:OnFinished(oldAnchor)
	Cursor:ClearAllPoints()
	Cursor:SetPoint(unpack(oldAnchor or Cursor:GetAnchor()))
end

do  -- Set up animation scripts
	local animationGroups = {Cursor.MoveAndScale, Cursor.Highlight.Scale}

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
	Cursor.Translate = Cursor.MoveAndScale.Translate
	Cursor.Enlarge   = Cursor.MoveAndScale.Enlarge
	Cursor.Shrink    = Cursor.MoveAndScale.Shrink
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
		if super:GetScript('OnLoad') ~= HybridScrollFrame_OnLoad then
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