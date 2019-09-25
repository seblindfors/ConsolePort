---------------------------------------------------------------
-- Cursors\Interface.lua: Interface cursor and node management.
---------------------------------------------------------------
-- Creates a cursor used to manage the interface with D-pad.
-- Operates recursively on a stack of frames provided in
-- UICore.lua and calculates appropriate actions based on
-- node priority and where nodes are drawn on screen.

local addOn, db = ...
---------------------------------------------------------------
local MAX_WIDTH, MAX_HEIGHT = UIParent:GetSize()
---------------------------------------------------------------
UIParent:HookScript("OnSizeChanged", function(self, width, height) MAX_WIDTH, MAX_HEIGHT = width, height end)
---------------------------------------------------------------
		-- Resources
local	KEY, SECURE, TEXTURE, M1, M2,
		-- Override wrappers
	 	SetOverride, ClearOverride,
		-- General functions
		InCombat, After,
		-- Utils
		FadeIn, FadeOut, Hex2RGB,
		-- Std functions
		select, ipairs, pairs, wipe, tinsert, pcall,
		-- Misc
		ConsolePort, Override, current, old =
		--------------------------------------------
		db.KEY, db.SECURE, db.TEXTURE, "CP_M1", "CP_M2",
		SetOverrideBindingClick, ClearOverrideBindings,
		InCombatLockdown, C_Timer.After,
		db.UIFrameFadeIn, db.UIFrameFadeOut, db.Hex2RGB,
		select, ipairs, pairs, wipe, tinsert, pcall,
		ConsolePort, {}
---------------------------------------------------------------
		-- Cursor frame and scroll helpers
local 	Cursor, ClickWrapper, StepL, StepR, Scroll =
		ConsolePortCursor,
		CreateFrame("Button", "ConsolePortCursorClickWrapper"),
		CreateFrame("Button", "ConsolePortCursorStepL"),
		CreateFrame("Button", "ConsolePortCursorStepR"),
		CreateFrame("Frame")

-- Store hybrid onload to check whether a scrollframe can be scrolled automatically
local hybridScroll = HybridScrollFrame_OnLoad

local function IsSafe()
	return ( not InCombat() ) or Cursor.InsecureMode
end

---------------------------------------------------------------
-- Wrappers for overriding click bindings
---------------------------------------------------------------

function Override:Click(owner, old, button, mouseClick, mod)
	for i=1, select('#', GetBindingKey(old)) do
		local key = select(i, GetBindingKey(old))
		SetOverride(owner, true, mod and mod..key or key, button, mouseClick)
	end
end

function Override:Shift(owner, old, button, mouseClick)
	self:Click(owner, old, button, mouseClick, "SHIFT-")
end

function Override:Ctrl(owner, old, button, mouseClick)
	self:Click(owner, old, button, mouseClick, "CTRL-")
end

function Override:HorizontalScroll(owner, widget)
	local wrapperFunc = owner.Scroll == M1 and self.Shift or self.Ctrl
	wrapperFunc(self, owner, "CP_L_LEFT", "ConsolePortCursorStepL", "LeftButton")
	wrapperFunc(self, owner, "CP_L_RIGHT", "ConsolePortCursorStepR", "LeftButton")
	StepL.widget = widget
	StepR.widget = widget
end

function Override:Scroll(owner, up, down)
	local wrapperFunc = owner.Scroll == M1 and self.Shift or self.Ctrl
	local modifier = owner.Scroll == M1 and "SHIFT-" or "CTRL-"
	self:Shift(owner, "CP_L_UP", up and up:GetName() or "CP_L_UP"..modifier, "LeftButton")
	self:Shift(owner, "CP_L_DOWN", down and down:GetName() or "CP_L_DOWN"..modifier, "LeftButton")
end

function Override:Button(button, clickbutton)
	button:SetAttribute("type", "click")
	button:SetAttribute("clickbutton", clickbutton)
end

function Override:Macro(button, macrotext)
	button:SetAttribute("type", "macro")
	button:SetAttribute("macrotext", macrotext)
end

---------------------------------------------------------------
-- Cursor textures and animations
---------------------------------------------------------------
function Cursor:SetTexture(texture)
	local object = current and current.object
	local newType = (object == 'EditBox' and self.IndicatorS) or (object == 'Slider' and self.Modifier) or texture or self.Indicator
	if newType ~= self.type then
		self.Button:SetTexture(newType)
	end
	self.type = newType
end

function Cursor:SetPosition(node)
	local oldAnchor = self.anchor
	self:SetTexture()
	self.anchor = node.customCursorAnchor or {"TOPLEFT", node, "CENTER", 0, 0}
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
	if current then
		self:ClearHighlight()
		local newX, newY = self:SetPointer(current.node)
		if self.MoveAndScale:IsPlaying() then
			self.MoveAndScale:Stop()
			self.MoveAndScale:OnFinished(oldAnchor)
		end
		local oldX, oldY = self:GetCenter()
		if ( not current.node.noAnimation ) and oldX and oldY and newX and newY and self:IsVisible() then
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

-- Animation scripts
---------------------------------------------------------------
function Cursor.MoveAndScale:ConfigureScale()
	if old == current and not self.Flash then
		self.Shrink:SetDuration(0)
		self.Enlarge:SetDuration(0)	
	elseif current then
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
	Cursor:SetHighlight(current and current.node)
end

function Cursor.MoveAndScale:OnPlay()
	Cursor.Highlight:SetParent(current and current.node or Cursor)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON, 'Master', false, false)
end

function Cursor.MoveAndScale:OnFinished(oldAnchor)
	Cursor:ClearAllPoints()
	Cursor:SetPoint(unpack(oldAnchor or Cursor.anchor))
end
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
				local r, g, b, a = Hex2RGB(texture:sub(7), true)
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

---------------------------------------------------------------
-- Click wrapper for insecure clicks
---------------------------------------------------------------

function ClickWrapper:SetObject(object)
	if 	object and object.IsObjectType and
		object:IsObjectType("Button") or object:IsObjectType("CheckButton") then
		self.object = object
		return true
	end
end

function ClickWrapper:RunClick() self:RunLeftClick() end

function ClickWrapper:RunLeftClick()
	if 	self.object then
		self.object:Click("LeftButton")
	end
end

function ClickWrapper:RunRightClick()
	if 	self.object then
		self.object:Click("RightButton")
	end
end

---------------------------------------------------------------
-- Node management resources
---------------------------------------------------------------
local IsUsable = {
	Button 		= true;
	CheckButton = true;
	EditBox 	= true;
	Slider 		= true;
}

local IsClickable = {
	Button 		= true;
	CheckButton = true;
	EditBox 	= true;
}

local DropDownMacros = {
	SET_FOCUS = "/focus %s";
	CLEAR_FOCUS = "/clearfocus";
	PET_DISMISS = "/petdismiss";
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
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
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
				_, difficultyHighlightColor = QuestDifficultyColors["header"]
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
-- Node management functions
---------------------------------------------------------------

local Node = {
	-- Compares distance between nodes for eligibility when filtering cached nodes
	distance = {
		[KEY.UP]    = function(_, destY, horz, vert, _, thisY) return (vert > horz and destY > thisY) end;
		[KEY.DOWN]  = function(_, destY, horz, vert, _, thisY) return (vert > horz and destY < thisY) end;
		[KEY.LEFT]  = function(destX, _, horz, vert, thisX, _) return (vert < horz and destX < thisX) end;
		[KEY.RIGHT] = function(destX, _, horz, vert, thisX, _) return (vert < horz and destX > thisX) end;
	};
	-- Compares more generally to catch any nodes located in a given direction
	direction = {
		[KEY.UP]    = function(_, destY, _, _, _, thisY) return (destY > thisY) end;
		[KEY.DOWN]  = function(_, destY, _, _, _, thisY) return (destY < thisY) end;
		[KEY.LEFT]  = function(destX, _, _, _, thisX, _) return (destX < thisX) end;
		[KEY.RIGHT] = function(destX, _, _, _, thisX, _) return (destX > thisX) end;
	};
	cache = {}; -- Temporary node cache when calculating cursor movement
	scalar = 3; -- Manhattan distance: scale primary plane to improve intuitive node selection
}

local rectIntersect, vec2Dlen, abs, huge = UIDoFramesIntersect, Vector2D_GetLength, math.abs, math.huge

function Node:GetAbsoluteDistance(x1, y1, x2, y2)
	return abs(x1 - x2), abs(y1 - y2)
end

function Node:IsCloser(hz1, vt1, hz2, vt2)
	return vec2Dlen(hz1, vt1) < vec2Dlen(hz2, vt2)
end

function Node:DoNodesIntersect(node1, node2)
	-- (1) frame level mismatch indicates node1 may overlap node2 or vice versa
	-- (2) if nodes are relative to eachother, they should be treated as non-intersecting
	-- (3) check the frame boundaries for intersection if the nodes are independent
	return 	(node1:GetFrameLevel() ~= node2:GetFrameLevel()) and 
		 	(node1:GetParent() ~= node2 and node2:GetParent() ~= node1) and 
		 	rectIntersect(node1, node2)
end

function Node:IsInteractive(node, object)
	return not node.includeChildren and node:IsMouseEnabled() and ( IsUsable[object] or HasOnEnterScript(node) )
end

function Node:IsRelevant(node)
	return node and not node.ignoreNode and not node:IsForbidden() and node:IsVisible()
end

function Node:IsTree(node)
	return not node.ignoreChildren
end

function Node:GetSuperNode(super, node)
	return node:IsObjectType('ScrollFrame') and node or super
end

function Node:IsDrawn(node, super)
	local x, y = node:GetCenter()
	if 	x and x <= MAX_WIDTH and x >= 0 and
		y and y <= MAX_HEIGHT and y >= 0 then
		if super and super:GetScrollChild() and not node:IsObjectType('Slider') then
			return rectIntersect(node, super) --or rectIntersect(node, scrollChild)
		else
			return true
		end
	end
end

function Node:CacheItem(node, object, super)
	tinsert(self.cache, node.hasPriority and 1 or #self.cache + 1, {
		node   = node;
		object = object;
		super  = super;
	});
end

function Node:Scan(super, node, sibling, ...)
	if self:IsRelevant(node) then
		local object = node:GetObjectType()
		if self:IsInteractive(node, object) and self:IsDrawn(node, super) then
			self:CacheItem(node, object, super)
		end
		if self:IsTree(node) then
			self:Scan(self:GetSuperNode(super, node), node:GetChildren())
		end
	end
	if sibling then
		self:Scan(super, sibling, ...)
	end
end

function Node:RefreshAll()
	if IsSafe() then
		self:Clear()
		ClearOverride(Cursor)
		self:Scan(nil, ConsolePort:GetVisibleCursorFrames())
		self:SetCurrent()
	end
end

function Node:GetCandidateVectorForCurrent()
	local x, y = current.node:GetCenter()
	return {x = x; y = y; h = huge; v = huge}
end 

function Node:GetCandidatesForVector(vector, comparator, candidates)
	local thisX, thisY = vector.x, vector.y
	for i, destination in ipairs(self.cache) do
		local candidate = destination.node
		local destX, destY = candidate:GetCenter()
		local distX, distY = self:GetAbsoluteDistance(thisX, thisY, destX, destY)

		if 	comparator(destX, destY, distX, distY, thisX, thisY) and
			not self:DoNodesIntersect(current.node, candidate) then
			candidates[destination] = { 
				x = destX; y = destY; h = distX; v = distY;
			}
		end
	end 
	return candidates
end

function Node:SetToClosestCandidate(key, currentNodeChanged)
	if current and self.direction[key] then
		local this = self:GetCandidateVectorForCurrent()
		local candidates = self:GetCandidatesForVector(this, self.direction[key], {})

		for candidate, vector in pairs(candidates) do
			if self:IsCloser(vector.h, vector.v, this.h, this.v) then
				this = vector; current = candidate
			end
		end
	end
end

function Node:SetToBestCandidate(key, currentNodeChanged)
	if current and self.distance[key] then
		local this = self:GetCandidateVectorForCurrent()
		local candidates = self:GetCandidatesForVector(this, self.distance[key], {})

		local hMult = (key == KEY.UP or key == KEY.DOWN) and self.scalar or 1
		local vMult = (key == KEY.LEFT or key == KEY.RIGHT) and self.scalar or 1

		for candidate, vector in pairs(candidates) do
			if self:IsCloser(vector.h * hMult, vector.v * vMult, this.h, this.v) then
				this = vector; this.h = (this.h * hMult); this.v = (this.v * vMult);
				current = candidate
				currentNodeChanged = true
			end
		end
		return currentNodeChanged
	end
end

function Node:Clear()
	if current then
		TriggerOnLeave(current.node)
		old = current
	end
	wipe(self.cache)
end

function Node:GetScrollButtons(node)
	if node then
		if node:IsMouseWheelEnabled() then
			for _, frame in pairs({node:GetChildren()}) do
				if frame:IsObjectType("Slider") then
					return frame:GetChildren()
				end
			end
		elseif node:IsObjectType("Slider") then
			return node:GetChildren()
		else
			return self:GetScrollButtons(node:GetParent())
		end
	end
end

function Node:Select(node, object, super, state)
	local name = node.direction and node:GetName()
	local override
	if IsClickable[object] then
		override = (object ~= 'EditBox')
	end

	-- Trigger OnEnter script
	if state == KEY.STATE_UP then
		TriggerOnEnter(node, state)
	end

	-- If this node has a forbidden dropdown value, override macro instead.
	local macro = DropDownMacros[node.value]

	if super and not super.ignoreScroll and not IsShiftKeyDown() and not IsControlKeyDown() then
		Scroll:To(node, super)
	end

	if not Cursor.InsecureMode then
		local scrollUp, scrollDown = self:GetScrollButtons(node)
		Override:Scroll(Cursor, scrollUp, scrollDown)
		if object == "Slider" then
			Override:HorizontalScroll(Cursor, node)
		end

		for click, button in pairs(Cursor.Override) do
			for modifier in ConsolePort:GetModifiers() do
				Override:Click(Cursor, button, name or button..modifier, click, modifier)
				if macro then
					local unit = UIDROPDOWNMENU_INIT_MENU.unit
					Override:Macro(_G[button..modifier], macro:format(unit or ''))
				elseif override then
					Override:Button(_G[button..modifier], node)
				else
					Override:Button(_G[button..modifier], nil)
				end
			end
		end
	else
		ClickWrapper:SetObject(node)
	end
end

function Node:SetCurrent()	
	if old and old.node:IsVisible() and Node:IsDrawn(old.node) then
		current = old
	elseif #self.cache > 0 and (not current or not current.node:IsVisible()) then
		local x, y, targNode = Cursor:GetCenter()
		if not x or not y then
			targNode = self.cache[1]
		else
			local targDist, targPrio
			for _, this in ipairs(self.cache) do
				local thisX, thisY = this.node:GetCenter()
				local thisDist = abs(x - thisX) + abs(y - thisY)
				local thisPrio = this.node.hasPriority

				if thisPrio and not targPrio then
					targNode = this
					break
				elseif not targNode or ( not targPrio and thisDist < targDist ) then
					targNode = this
					targDist = thisDist
					targPrio = thisPrio
				end
			end
		end
		current = targNode
	end
	if current and current ~= old then
		self:Select(current.node, current.object, current.super, KEY.STATE_UP)
	end
end

---------------------------------------------------------------
-- Scroll management
---------------------------------------------------------------
function Scroll:Offset(elapsed)
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

	--	print(currHorz, target.horz, newX)

		super:SetVerticalScroll(newY < 0 and 0 or newY > maxVert and maxVert or newY)
		super:SetHorizontalScroll(newX < 0 and 0 or newX > maxHorz and maxHorz or newX)
	end
	if not next(self.Active) then
		self:SetScript("OnUpdate", nil)
	end
end

function Scroll:To(node, super)
	local nodeX, nodeY = node:GetCenter()
	local scrollX, scrollY = super:GetCenter()
	if nodeY and scrollY then

		-- make sure this isn't a hybrid scroll frame
		if super:GetScript("OnLoad") ~= hybridScroll then
			local currHorz, currVert = super:GetHorizontalScroll(), super:GetVerticalScroll()
			local maxHorz, maxVert = super:GetHorizontalScrollRange(), super:GetVerticalScrollRange()

			local newVert = currVert + (scrollY - nodeY)
			local newHorz = 0
		-- 	NYI
		--	local newHorz = currHorz + (scrollX - nodeX)
		--	print(floor(currHorz), floor(scrollX), floor(nodeX), floor(newHorz))

			if not self.Active then
				self.Active = {}
			end

			self.Active[super] = {
				vert = newVert < 0 and 0 or newVert > maxVert and maxVert or newVert,
				horz = newHorz < 0 and 0 or newHorz > maxHorz and maxHorz or newHorz,
			}

			self:SetScript("OnUpdate", self.Offset)
		end
	end
end
----------

-- Perform non secure special actions, ruler of all hacky implementations
local function SpecialAction(self)
	if current then
		local node = current.node
		if node.SpecialClick then
			pcall(node.SpecialClick, node)
			return
		end
		-- MerchantButton
		if 	node.price then
			local maxStack = GetMerchantItemMaxStack(node:GetID())
			local _, _, price, stackCount, _, _, extendedCost = GetMerchantItemInfo(node:GetID())
			if stackCount > 1 and extendedCost then
				node:Click()
				return
			end
			local canAfford
			if 	price and price > 0 then
				canAfford = floor(GetMoney() / (price / stackCount))
			else
				canAfford = maxStack
			end
			if	maxStack > 1 then
				local maxPurchasable = min(maxStack, canAfford)
				StackSplitFrame:OpenStackSplitFrame(maxPurchasable, node, "TOPLEFT", "BOTTOMLEFT")
			end
		-- Item button
		elseif node.JunkIcon then
			local link = GetContainerItemLink(node:GetParent():GetID(), node:GetID())
			local _, itemID = strsplit(":", (strmatch(link or "", "item[%-?%d:]+")) or "")
			if GetItemSpell(link) then
				self:AddUtilityAction("item", itemID)
			else
				local _, itemCount, locked = GetContainerItemInfo(node:GetParent():GetID(), node:GetID())
				if ( not locked and itemCount and itemCount > 1) then
					node.SplitStack = function(button, split)
						SplitContainerItem(button:GetParent():GetID(), button:GetID(), split)
					end
					StackSplitFrame:OpenStackSplitFrame(itemCount, node, "BOTTOMRIGHT", "TOPRIGHT")
				end
			end
		-- Spell button
		elseif node.SpellName then
			local book, id, spellID, _ = SpellBookFrame, node:GetID()
			if 	not node.IsPassive then
				if book.bookType == BOOKTYPE_PROFESSION then
					spellID = id + node:GetParent().spellOffset
				elseif book.bookType == BOOKTYPE_PET then
					spellID = id + (SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] - 1))
				else
					local relativeSlot = id + ( SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[book.selectedSkillLine] - 1))
					if book.selectedSkillLineNumSlots and relativeSlot <= book.selectedSkillLineNumSlots then
						local slot = book.selectedSkillLineOffset + relativeSlot
						_, spellID = GetSpellBookItemInfo(slot, book.bookType)
					end
				end
				if spellID then
					PickupSpell(spellID)
				end
			end
		-- Text field
		elseif node:IsObjectType("EditBox") then
			node:SetFocus(true)
		end
	end
end

---------------------------------------------------------------
-- UIControl: Cursor scripts and events
---------------------------------------------------------------
local IsObstructed 	= ConsolePort.IsCursorObstructed
local HasUIFocus 	= ConsolePort.HasUIFocus

function Cursor:OnUpdate(elapsed)
	self.Timer = self.Timer + elapsed
	while self.Timer > 0.1 do
		if IsObstructed() then
			self:Hide()
		elseif not current or ( not current.node:IsVisible() or not Node:IsDrawn(current.node) ) then
			self:Hide()
			current = nil
			if 	IsSafe() and HasUIFocus() then
				ConsolePort:UIControl()
			end
		end
		self.Timer = self.Timer - 0.1
	end
end

function Cursor:OnHide()
	self.MoveAndScale.Flash = true
	Node:Clear()
	self:SetHighlight()
	if IsSafe() then
		ClearOverride(self)
	end
end

function Cursor:PLAYER_REGEN_DISABLED()
	self.MoveAndScale.Flash = true
	ClearOverride(self)
	FadeOut(self, 0.2, self:GetAlpha(), 0)
end

function Cursor:PLAYER_REGEN_ENABLED()
	self.MoveAndScale.Flash = true
	After(db.Settings.UIleaveCombatDelay or 0.5, function()
		if IsSafe() then
			FadeIn(self, 0.2, self:GetAlpha(), 1)
		end
	end)
end

function Cursor:PLAYER_ENTERING_WORLD()
	MAX_WIDTH, MAX_HEIGHT = UIParent:GetSize()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Cursor:MODIFIER_STATE_CHANGED()
	if IsSafe() then
		if 	current and
			(self.Scroll == M1 and IsShiftKeyDown()) or
			(self.Scroll == M2 and IsControlKeyDown()) then
			self:SetTexture(self.Modifier)
		else
			self:SetTexture()
		end
	end
end

---------------------------------------------------------------
-- Exposed node manipulation
---------------------------------------------------------------

function ConsolePort:IsCurrentNode(node) return current and current.node == node end
function ConsolePort:GetCurrentNode() return current and current.node end
function ConsolePort:SetInsecureCursorMode(enabled) Cursor.InsecureMode = enabled and true or false end

function ConsolePort:SetCurrentNode(node, force)
	-- assert cursor is enabled and safe before proceeding
	if not db.Settings.disableUI and IsSafe() then
		if node then
			local object = node:GetObjectType()
			if 	Node:IsInteractive(node, object) and Node:IsDrawn(node) then
				old = current
				current = {
					node = node,
					object = object,
				}
				Cursor:SetPosition(current.node)
			end
		end
		-- new node is set for next refresh.
		-- don't refresh immediately if UI core is locked.
		if not self:IsUICoreLocked() then
			self:UIControl()
		end
	end
end

function ConsolePort:ClearCurrentNode(skipRefresh)
	current = nil
	old = nil
	Cursor.Highlight:Hide()
	if not skipRefresh then
		self:UIControl()
	end
end

function ConsolePort:ScrollToNode(node, scrollFrame, dontFocus)
	-- use responsibly
	if node and scrollFrame then
		Scroll:To(node, scrollFrame)
		local hasMoved
		if not dontFocus and not db.Settings.disableUI and Scroll:GetScript("OnUpdate") then
			Scroll:HookScript("OnUpdate", function()
				if not hasMoved and Node:IsDrawn(node, scrollFrame) then
					self:SetCurrentNode(node)
					hasMoved = true
				end
			end)
		end
	end
end

---------------------------------------------------------------
-- UIControl: Command parser / main func
---------------------------------------------------------------
function ConsolePort:UIControl(key, state)
	Node:RefreshAll()
	if 	state == KEY.STATE_DOWN then
		if not Node:SetToBestCandidate(key) then
			Node:SetToClosestCandidate(key)
		end
	elseif key == Cursor.SpecialAction then
		SpecialAction(self)
	end
	local node = current and current.node
	if node then
		Node:Select(node, current.object, current.super, state)
		if state == KEY.STATE_DOWN or state == nil then
			Cursor:SetPosition(node)
		end
	end
	return node
end

---------------------------------------------------------------
-- UIControl: Rebinding functions for cursor
---------------------------------------------------------------
local function GetInterfaceButtons()
	return ipairs({
		CP_L_UP,
		CP_L_DOWN,
		CP_L_RIGHT,
		CP_L_LEFT,
		_G[db('Mouse/Cursor/Special')],
	})
end

function ConsolePort:SetButtonOverride(enabled)
	if enabled then
		for _, button in GetInterfaceButtons() do
			Override:Click(self, button.name, button:GetName(), 'LeftButton')
			button:SetAttribute('type', 'UIControl')
		end
	else
		self:ClearCursor()
		for button in pairs(SECURE) do
			button:Clear(true)
		end
	end
end

function ConsolePort:ClearCursor() Cursor:SetParent(UIParent) ClearOverride(self) end

---------------------------------------------------------------
-- UIControl: Initialize Cursor
---------------------------------------------------------------
function ConsolePort:SetupCursor()
	if db.Settings.disableUI then
		Cursor:SetParent(UIParent)
		Cursor:Hide()
		return
	end

	local cS = db('Mouse/Cursor/Special')
	local cL = db('Mouse/Cursor/Left')
	local cR = db('Mouse/Cursor/Right')

	Cursor.Special 		= cS
	Cursor.SpecialClick = _G[Cursor.Special]
	Cursor.SpecialAction = Cursor.SpecialClick and Cursor.SpecialClick.command

	Cursor.Override = {LeftButton = cL, RightButton = cR}

	Cursor.Indicator  = TEXTURE[cL]
	Cursor.IndicatorR = TEXTURE[cR]
	Cursor.IndicatorS = TEXTURE[cS]

	Cursor.Scroll     = db('Mouse/Cursor/Scroll')
	Cursor.Modifier   = Cursor.Scroll == M1 and TEXTURE.CP_M1 or TEXTURE.CP_M2

	Cursor:SetScript('OnHide', Cursor.OnHide)
	Cursor:SetScript('OnUpdate', Cursor.OnUpdate)
end
---------------------------------------------------------------
do
	-- Set up animation scripts
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

-- Horizontal scroll wrappers
---------------------------------------------------------------
local function StepOnClick(self)
	local slider = self.widget
	if slider then
		local change = self.delta * slider:GetValueStep()
		local min, max = slider:GetMinMaxValues()
		local newValue = slider:GetValue() + change
		newValue = newValue <= min and min or newValue >= max and max or newValue
		slider:SetValue(newValue)
	end
end

StepL.delta = -1
StepR.delta = 1

StepL:SetScript('OnClick', StepOnClick)
StepR:SetScript('OnClick', StepOnClick)