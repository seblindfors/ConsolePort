local _, db = ...;
local Cursor, Node, Input, Scroll = CPAPI.EventHandler(ConsolePortCursor), ConsolePortNode, ConsolePortInputHandler, CreateFrame('Frame')
local STATE_UP, STATE_DOWN = false, true
local CURSOR_ACTIVE, CUR, OLD

db:Register('Cursor', Cursor)

function Cursor:OnDataLoaded()
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	-- do something when it's loaded
end

function Cursor:OnShow()

end

function Cursor:Release()
	self:ClearFocus()
	Input:Release(self)
end




--[[
TODO:

IsGamePadCursorControlEnabled
CanGamePadControlCursor
IsGamePadFreelookEnabled
SetGamePadFreeLook
CanAutoSetGamePadCursorControl
IsBindingForGamePad
SetGamePadCursorControl
]]


-- trigger for activating/deactivating cursor?
hooksecurefunc('CanAutoSetGamePadCursorControl', function(state)
	CURSOR_ACTIVE = state
	print('CanAutoSetGamePadCursorControl', CURSOR_ACTIVE)
	if state then
		Cursor:Enable(true)
	end
end)
--hooksecurefunc('SetGamePadCursorControl', function(...) print('SetGamePadCursorControl', ...) end)

do  -- Create input proxy for basic controls
	local UIControl_InputProxy = function(self, ...)
		print(...)
		self:Show()
		Cursor:Input(self, self:GetAttribute('id'), self.state)
	end

	local UIControl_DpadRepeater = function(self, elapsed)
		self.timer = self.timer + elapsed
		if self.timer >= self.UIControlTickNext and self.state == STATE_DOWN then
			local func = self:GetAttribute('type')
			if ( func == 'UIControl' ) then
				self[func](self)
			end
			self.timer = 0
		end
	end

	local UIControl_DpadInit = function(self, dpadRepeater)
		if not db('UIdisableHoldRepeat') then
			self.UIControlTickNext = db('UIholdRepeatDelay')
			self:SetScript('OnUpdate', dpadRepeater)
		end
	end

	local UIControl_DpadClear = function(self)
		self:SetScript('OnUpdate', nil)
		self:Hide()
	end

	function Cursor:GetBasicControls()
		--  @init : (optional) function to set up properties
		--  @clear: (optional) function to run when clearing
		--  @args : (optional) properties for initialization
		self.BaseControlButtons = {
			PADDUP    = {UIControl_DpadInit, UIControl_DpadClear, UIControl_DpadRepeater};
			PADDDOWN  = {UIControl_DpadInit, UIControl_DpadClear, UIControl_DpadRepeater};
			PADDLEFT  = {UIControl_DpadInit, UIControl_DpadClear, UIControl_DpadRepeater}; 
			PADDRIGHT = {UIControl_DpadInit, UIControl_DpadClear, UIControl_DpadRepeater};
			[db('Settings/UICursor/Special')] = {};
		};
		return self.BaseControlButtons
	end

	function Cursor:SetBasicControls()
		local controls = self:GetBasicControls()
		for button, settings in pairs(controls) do
			Input:Command(button, self, false, 'LeftButton',
				'UIControl',
				UIControl_InputProxy,
				unpack(settings)
			);
		end
	end
end

function Cursor:Enable(wasDisabled)
	if InCombatLockdown() then return false end
	if wasDisabled then
		self:SetBasicControls()
	end
	self:ClearFocus()
	Node(UIParent)
	self:SetCurrent()
end

function Cursor:Input(caller, key, isDown)
	self:Enable()
	if isDown then
		local curNodeChanged
		CUR, curNodeChanged = Node:NavigateToBestCandidate(CUR, key)
		if not curNodeChanged then
			CUR = Node:NavigateToClosestCandidate(key)
		end
	elseif ( key == db('Settings/UICursor/Special') ) then
		-- TODO: implement special action
	end
	local node = CUR and CUR.node
	if node then
		self:Select(node, CUR.object, CUR.super, isDown)
		if isDown or isDown == nil then
			self:SetPosition(node)
		end
	end
	return node
end

function Cursor.GetCurrentNode()
	return CUR and CUR.node
end

---------------------------------------------------------------
-- UIControl: Command parser / main func
---------------------------------------------------------------
function ConsolePort:UIControl(key, state)
	Cursor:Refresh()
	if state == KEY.STATE_DOWN then
		local curNodeChanged
		CUR, curNodeChanged = Node:GetBestCandidate(CUR, key)
		if not curNodeChanged then
			CUR = Node:GetClosestCandidate(key)
		end
	elseif key == Cursor.SpecialAction then
		SpecialAction(self)
	end
	local node = CUR and CUR.node
	if node then
		Cursor:Select(node, CUR.object, CUR.super, state)
		if state == KEY.STATE_DOWN or state == nil then
			Cursor:SetPosition(node)
		end
	end
	return node
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

local function TriggerOnEnter(node) TriggerScript(node, 'OnEnter', SafeOnEnter) end
local function TriggerOnLeave(node) TriggerScript(node, 'OnLeave', SafeOnLeave) end


---------------------------------------------------------------
-- Node selection
---------------------------------------------------------------
function Cursor:ClearFocus()
	if CUR then
		TriggerOnLeave(CUR.node)
		OLD = CUR
	end
end

function Cursor:SetCurrent()
	CUR = Node:NavigateToArbitraryCandidate(CUR, OLD, self:GetCenter())
	if ( CUR and CUR ~= OLD ) then
		self:Select(CUR.node, CUR.object, CUR.super, STATE_UP)
	end
end

function Cursor:Select(node, object, super, state)
	local name = node.direction and node:GetName()
	local override = (IsClickable[object] and object ~= 'EditBox')

	-- Trigger OnEnter script
	if state == STATE_UP then
		TriggerOnEnter(node, state)
	end

	-- If this node has a forbidden dropdown value, override macro instead.
	local macro = DropDownMacros[node.value]

	if super and not super.ignoreScroll and not IsShiftKeyDown() and not IsControlKeyDown() then
		Scroll:To(node, super)
	end

	local scrollUp, scrollDown = Node:GetScrollButtons(node)
	if scrollUp and scrollDown then
		local modifier = db('UImodifierCommands')
		Input:Button(format('%s-%s', modifier, 'PADDUP'), self, scrollUp)
		Input:Button(format('%s-%s', modifier, 'PADDDOWN'), self, scrollDown)
	end

	if object == 'Slider' then
		-- TODO: Override:HorizontalScroll(Cursor, node)
	end

	local buttons = {
		LeftButton  = db('Settings/UICursor/LeftClick');
		RightButton = db('Settings/UICursor/RightClick');
	}

	for click, button in pairs(buttons) do
		for modifier in pairs(db('Gamepad/Index/Modifier/Active')) do
			if macro then
				local unit = UIDROPDOWNMENU_INIT_MENU.unit
				Input:Macro(button .. modifier, self, macro:format(unit or ''))
			elseif override then
				Input:Button(button .. modifier, self, node, false, click)
			else
				Input:Button(button .. modifier, self, false, false, click)
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
	local object = texture or CUR and CUR.object
	local lambda = self.Textures[object]
	if ( lambda ~= self.textureLambda ) then
		self.Button:SetTexture(lambda())
	end
	self.textureLambda = lambda
end

function Cursor:SetPosition(node)
	local oldAnchor = self.anchor
	self:SetTexture()
	self.anchor = node.customCursorAnchor or {'TOPLEFT', node, 'CENTER', 0, 0}
	self:Show()
	self:Move(oldAnchor)
end

function Cursor:SetPointer(node)
	self.Pointer:ClearAllPoints()
	self.Pointer:SetParent(node)
	self.Pointer:SetPoint(unpack(self.anchor))
	return self.Pointer:GetCenter()
end

function Cursor:Move(oldAnchor)
	if CUR then
		self:ClearHighlight()
		local newX, newY = self:SetPointer(CUR.node)
		if self.MoveAndScale:IsPlaying() then
			self.MoveAndScale:Stop()
			self.MoveAndScale:OnFinished(oldAnchor)
		end
		local oldX, oldY = self:GetCenter()
		if ( not CUR.node.noAnimation ) and oldX and oldY and newX and newY and self:IsVisible() then
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

-- Animation scripts
---------------------------------------------------------------
function Cursor.MoveAndScale:ConfigureScale()
	if OLD == CUR and not self.Flash then
		self.Shrink:SetDuration(0)
		self.Enlarge:SetDuration(0)	
	elseif CUR then
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
	Cursor:SetHighlight(CUR and CUR.node)
end

function Cursor.MoveAndScale:OnPlay()
	Cursor.Highlight:SetParent(CUR and CUR.node or Cursor)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON, 'Master', false, false)
end

function Cursor.MoveAndScale:OnFinished(oldAnchor)
	Cursor:ClearAllPoints()
	Cursor:SetPoint(unpack(oldAnchor or Cursor.anchor))
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
do 
	-- Store hybrid onload to check whether a scrollframe can be scrolled automatically
	local hybridScroll = HybridScrollFrame_OnLoad

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
		local nodeX, nodeY = node:GetCenter()
		local scrollX, scrollY = super:GetCenter()
		if nodeY and scrollY then

			-- make sure this isn't a hybrid scroll frame
			if super:GetScript('OnLoad') ~= hybridScroll then
				local currHorz, currVert = super:GetHorizontalScroll(), super:GetVerticalScroll()
				local maxHorz, maxVert = super:GetHorizontalScrollRange(), super:GetVerticalScrollRange()

				local newVert = currVert + (scrollY - nodeY)
				local newHorz = 0
			-- 	NYI
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
end