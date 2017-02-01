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
		InCombat, PlaySound, After,
		-- Fade wrappers
		FadeIn, FadeOut,
		-- Table functions
		select, ipairs, pairs, wipe, abs, tinsert, pcall,
		-- Misc
		ConsolePort, Override, current, old =
		--------------------------------------------
		db.KEY, db.SECURE, db.TEXTURE, "CP_M1", "CP_M2",
		SetOverrideBindingClick, ClearOverrideBindings,
		InCombatLockdown, PlaySound, C_Timer.After,
		db.UIFrameFadeIn, db.UIFrameFadeOut,
		select, ipairs, pairs, wipe, abs, tinsert, pcall,
		ConsolePort, {}
---------------------------------------------------------------
		-- Cursor frame and scroll helpers
local 	Cursor, ClickWrapper, StepL, StepR, Scroll =
		CreateFrame("Frame", "ConsolePortCursor", UIParent),
		CreateFrame("Button", "ConsolePortCursorClickWrapper"),
		CreateFrame("Button", "ConsolePortCursorStepL"),
		CreateFrame("Button", "ConsolePortCursorStepR"),
		CreateFrame("Frame")

ConsolePort.Cursor = Cursor

-- Store hybrid onload to check whether a scrollframe can be scrolled automatically
local hybridScroll = HybridScrollFrame_OnLoad

local function IsSafe()
	return ( not InCombat() ) or Cursor.InsecureMode
end

---------------------------------------------------------------
-- Wrappers for overriding click bindings
---------------------------------------------------------------

function Override:Click(owner, old, button, mouseClick, mod)
	local key1, key2 = GetBindingKey(old)
	if key1 then 
		SetOverride(owner, true, mod and mod..key1 or key1, button, mouseClick)
	end
	if key2 then
		SetOverride(owner, true, mod and mod..key2 or key2, button, mouseClick)
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
	self:Shift(owner, "CP_L_UP", up:GetName() or "CP_L_UP"..modifier, "LeftButton")
	self:Shift(owner, "CP_L_DOWN", down:GetName() or "CP_L_DOWN"..modifier, "LeftButton")
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
	local newType
	if object == "EditBox" then
		newType = self.IndicatorS
	elseif object == "Slider" then
		newType = self.ScrollGuide
	elseif texture then
		newType = texture
	else
		newType = self.Indicator
	end
	if newType ~= self.type then
		self.Button:SetTexture(newType)
	end
	self.type = newType
end

function Cursor:SetPosition(node)
	self:SetTexture()
	self.anchor = node.customAnchor or {"TOPLEFT", node, "CENTER", 0, 0}
	self:Move()
	if not self:IsVisible() then
		self:Show()
	end
end

function Cursor:Scale()
	if old == current and not self.Flash then return end
	if current then
		local scaleAmount, scaleDuration = 1.15, 0.2
		if self.Flash then
			scaleAmount = 1.75
			scaleDuration = 0.5
			FadeOut(self.Spell, 1, 1, 0.1)
		end
		self.Flash = nil
		self.Enlarge:SetScale(scaleAmount, scaleAmount)
		self.Shrink:SetScale(1/scaleAmount, 1/scaleAmount)
		self.Shrink:SetDuration(scaleDuration)
		self.Highlight:SetParent(self)
		self.Scaling:Stop()
		self.Scaling:Play()
	end
end

function Cursor:ScaleOnFinished()
	if current then
		self:GetParent().Highlight:SetParent(current.node)
	end
end

function Cursor:Move(anchor)
	if current then
		self.Pointer:ClearAllPoints()
		self.Highlight:ClearAllPoints()
		self.Highlight:SetParent(self)
		self.Pointer:SetParent(current.node)
		self.Pointer:SetPoint(unpack(self.anchor))
		local newX, newY = self.Pointer:GetCenter()
		local oldX, oldY = self:GetCenter()
		if ( not current.node.noAnimation ) and oldX and oldY and newX and newY and self:IsVisible() then
			self.Translate:SetOffset(newX - oldX, newY - oldY)
			self.Enlarge:SetStartDelay(0.05)
			self.Moving:Play()
		else
			self.Enlarge:SetStartDelay(0)
			self.MoveOnFinished(self.Moving)
		end
	end
end

function Cursor:MoveOnFinished()
	PlaySound("igMainMenuOptionCheckBoxOn")
	local self = self:GetParent()
	self:ClearAllPoints()
	self:SetHighlight(current and current.node)
	self:SetPoint(unpack(self.anchor))
	self:Scale()
end

function Cursor:SetHighlight(node)
	local self = self or Cursor
	local mime = self.Highlight
	local highlight = node and node.GetHighlightTexture and node:GetHighlightTexture()
	if highlight and node:IsEnabled() then
		if highlight:GetAtlas() then
			mime:SetAtlas(highlight:GetAtlas())
		else
			mime:SetTexture(highlight:GetTexture())
			mime:SetBlendMode(highlight:GetBlendMode())
			mime:SetVertexColor(highlight:GetVertexColor())
		end
		mime:SetSize(highlight:GetSize())
		mime:SetTexCoord(highlight:GetTexCoord())
		mime:ClearAllPoints()
		mime:SetPoint(highlight:GetPoint())
		mime:Show()
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
-- Node management functions
---------------------------------------------------------------
local IsUsable = {
	Button 		= true,
	CheckButton = true,
	EditBox 	= true,
	Slider 		= true,
}

local IsClickable = {
	Button 		= true,
	CheckButton = true,
}

local DropDownMacros = {
	SET_FOCUS = "/focus %s",
	CLEAR_FOCUS = "/clearfocus",
	PET_DISMISS = "/petdismiss",
}

local Node = {
	[KEY.UP] 	= function(destY, _, vert, horz, _, thisY) return (vert > horz and destY > thisY) end,
	[KEY.DOWN] 	= function(destY, _, vert, horz, _, thisY) return (vert > horz and destY < thisY) end,
	[KEY.LEFT] 	= function(_, destX, vert, horz, thisX, _) return (vert < horz and destX < thisX) end,
	[KEY.RIGHT] = function(_, destX, vert, horz, thisX, _) return (vert < horz and destX > thisX) end,
	cache = {}
}

function Node:IsInteractive(node, object)
	return not node.includeChildren and node:IsMouseEnabled() and node:IsVisible() and IsUsable[object]
end

function Node:IsDrawn(node, scrollFrame)
	local x, y = node:GetCenter()
	local top = node:GetTop()
	if 	x and x <= MAX_WIDTH and x >= 0 and
		y and y <= MAX_HEIGHT and y >= 0 then
		-- if the node is a scroll child and it's anchored inside the scroll frame
		if scrollFrame and select(2, node:GetPoint()) == scrollFrame then
			local left, bottom, width, height = scrollFrame:GetRect()
			if left and bottom and width and height then
				if 	x > left and x < ( left + width + 20 ) and -- +20 padding to include sliders
					y > bottom and y < ( bottom + height ) then
					return true
				end
			end
		else
			return true
		end
	end
end

function Node:Refresh(node, scrollFrame)
	if node.ignoreNode or node:IsForbidden() then
		return
	end
	local object = node:GetObjectType()
	if 	not node.ignoreChildren then
		for i, child in pairs({node:GetChildren()}) do
			self:Refresh(child, node.GetVerticalScroll and node or scrollFrame)
		end
	end
	if 	self:IsInteractive(node, object) and self:IsDrawn(node, scrollFrame) then
		if node.hasPriority then
			tinsert(self.cache, 1, {node = node, object = object, scrollFrame = scrollFrame})
		else
			self.cache[#self.cache + 1] = {node = node, object = object, scrollFrame = scrollFrame}
		end
	end
end

function Node:RefreshAll()
	if IsSafe() then
		self:Clear()
		ClearOverride(Cursor)
		for frame in ConsolePort:GetFrameStack() do
			self:Refresh(frame)
		end
		self:SetCurrent()
	end
end

function Node:FindClosest(key)
	if current then
		local compareDistance = self[key]
		if compareDistance then
			local destX, destY, vert, horz
			local thisX, thisY = current.node:GetCenter()
			local compH, compV = 20000, 20000 
			for i, destination in ipairs(self.cache) do
				destX, destY = destination.node:GetCenter()
				horz, vert = abs(thisX-destX), abs(thisY-destY)
				if 	horz + vert < compH + compV and
					compareDistance(destY, destX, vert, horz, thisX, thisY) then
					compH = horz
					compV = vert
					current = destination
				end
			end
		end
	end
end

function Node:Clear()
	if current then
		local node = current.node
		local leave = node:GetScript("OnLeave")
		if leave then
			pcall(leave, node)
		end
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

function Node:Select(node, object, scrollFrame, state)
	local name = node.direction and node:GetName()
	local override
	if IsClickable[object] and node:IsEnabled() then
		override = true
		local enter = not node.HotKey and node:GetScript("OnEnter")
		if enter and state == KEY.STATE_UP then
			pcall(enter, node)
		end
	end

	-- If this node has a forbidden dropdown value, override macro instead.
	local macro = DropDownMacros[node.value]

	if scrollFrame and not scrollFrame.ignoreScroll and not IsShiftKeyDown() and not IsControlKeyDown() then
		Scroll:To(node, scrollFrame)
	end

	if not Cursor.InsecureMode then
		local scrollUp, scrollDown = self:GetScrollButtons(node)
		if scrollUp and scrollDown then
			Override:Scroll(Cursor, scrollUp, scrollDown)
		elseif object == "Slider" then
			Override:HorizontalScroll(Cursor, node)
		end

		for click, button in pairs(Cursor.Override) do
			for modifier in ConsolePort:GetModifiers() do
				Override:Click(Cursor, button, name or button..modifier, click, modifier)
				if macro then
					local unit = UIDROPDOWNMENU_INIT_MENU.unit
					Override:Macro(_G[button..modifier], macro:format(unit))
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
	elseif ( not current and #self.cache > 0 ) or ( current and #self.cache > 0 and not current.node:IsVisible() ) then
		local x, y, targetNode = Cursor:GetCenter()
		if not x or not y then
			targetNode = self.cache[1]
		else
			local targetDistance, targetParent, newDistance, newParent, swap, thisX, thisY
			for i, this in pairs(self.cache) do swap = false

				thisX, thisY = this.node:GetCenter()
				newDistance = abs( x - thisX ) + abs( y - thisY )
				newParent = this.node:GetParent()
				-- if no target node exists yet, just assign it
				if not targetNode then
					swap = true
				elseif this.node.hasPriority and not targetNode.node.hasPriority then
					targetNode = this
					break
				elseif not targetNode.node.hasPriority and newDistance < targetDistance then
					swap = true
				end
				if swap then
					targetNode = this
					targetDistance = newDistance
					targetParent = newParent
				end

			end
		end
		current = targetNode
	end
	if current and current ~= old then
		self:Select(current.node, current.object, current.scrollFrame, KEY.STATE_UP)
	end
end

---------------------------------------------------------------
-- Scroll management
---------------------------------------------------------------
function Scroll:Offset(elapsed)
	for scrollFrame, target in pairs(self.Active) do
		local currHorz, currVert = scrollFrame:GetHorizontalScroll(), scrollFrame:GetVerticalScroll()
		local maxHorz, maxVert = scrollFrame:GetHorizontalScrollRange(), scrollFrame:GetVerticalScrollRange()
		-- close enough, stop scrolling and set to target
		if ( abs(currHorz - target.horz) < 2 ) and ( abs(currVert - target.vert) < 2 ) then
			scrollFrame:SetVerticalScroll(target.vert)
			scrollFrame:SetHorizontalScroll(target.horz)
			self.Active[scrollFrame] = nil
			return
		end
		local deltaX, deltaY = ( currHorz > target.horz and -1 or 1 ), ( currVert > target.vert and -1 or 1 )
		local newX = ( currHorz + (deltaX * abs(currHorz - target.horz) / 16 * 4) )
		local newY = ( currVert + (deltaY * abs(currVert - target.vert) / 16 * 4) )

	--	print(currHorz, target.horz, newX)

		scrollFrame:SetVerticalScroll(newY < 0 and 0 or newY > maxVert and maxVert or newY)
		scrollFrame:SetHorizontalScroll(newX < 0 and 0 or newX > maxHorz and maxHorz or newX)
	end
	if not next(self.Active) then
		self:SetScript("OnUpdate", nil)
	end
end

function Scroll:To(node, scrollFrame)
	local nodeX, nodeY = node:GetCenter()
	local scrollX, scrollY = scrollFrame:GetCenter()
	if nodeY and scrollY then

		-- make sure this isn't a hybrid scroll frame
		if scrollFrame:GetScript("OnLoad") ~= hybridScroll then
			local currHorz, currVert = scrollFrame:GetHorizontalScroll(), scrollFrame:GetVerticalScroll()
			local maxHorz, maxVert = scrollFrame:GetHorizontalScrollRange(), scrollFrame:GetVerticalScrollRange()

			local newVert = currVert + (scrollY - nodeY)
			local newHorz = 0
		-- 	NYI
		--	local newHorz = currHorz + (scrollX - nodeX)
		--	print(floor(currHorz), floor(scrollX), floor(nodeX), floor(newHorz))

			if not self.Active then
				self.Active = {}
			end

			self.Active[scrollFrame] = {
				vert = newVert < 0 and 0 or newVert > maxVert and maxVert or newVert,
				horz = newHorz < 0 and 0 or newHorz > maxHorz and maxHorz or newHorz,
			}

			self:SetScript("OnUpdate", self.Offset)
		end
	end
end
----------

-- Perform non secure special actions
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
				OpenStackSplitFrame(maxPurchasable, node, "TOPLEFT", "BOTTOMLEFT")
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
					OpenStackSplitFrame(itemCount, node, "BOTTOMRIGHT", "TOPRIGHT")
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
function Cursor:OnUpdate(elapsed)
	self.Timer = self.Timer + elapsed
	while self.Timer > 0.1 do
		if not current or (current and not current.node:IsVisible()) or (current and not Node:IsDrawn(current.node)) then
			self:Hide()
			current = nil
			if 	IsSafe() and
				ConsolePort:HasUIFocus()  then
				ConsolePort:UIControl()
			end
		end
		self.Timer = self.Timer - 0.1
	end
end

function Cursor:OnHide()
	self.Flash = true
	Node:Clear()
	self:SetHighlight()
	if IsSafe() then
		ClearOverride(self)
	end
end

function Cursor:OnEvent(event)
	self[event](self)
end

function Cursor:PLAYER_REGEN_DISABLED()
	self.Flash = true
	ClearOverride(self)
	FadeOut(self, 0.2, self:GetAlpha(), 0)
end

function Cursor:PLAYER_REGEN_ENABLED()
	self.Flash = true
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
			self:SetTexture(self.ScrollGuide)
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

function ConsolePort:ClearCurrentNode(dontRefresh)
	current = nil
	old = nil
	Cursor.Highlight:Hide()
	if not dontRefresh then
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
		Node:FindClosest(key)
	elseif key == Cursor.SpecialAction then
		SpecialAction(self)
	end
	local node = current and current.node
	if node then
		Node:Select(node, current.object, current.scrollFrame, state)
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
	return {
		CP_L_UP,
		CP_L_DOWN,
		CP_L_RIGHT,
		CP_L_LEFT,
		_G[db.Mouse.Cursor.Special],
	}
end

function ConsolePort:SetButtonOverride(enabled)
	if enabled then
		local buttons = GetInterfaceButtons()
		for i, button in pairs(buttons) do
			Override:Click(self, button.name, button:GetName(), "LeftButton")
			button:SetAttribute("type", "UIControl")
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

	Cursor.Special 		= db.Mouse.Cursor.Special
	Cursor.SpecialClick = _G[Cursor.Special]
	Cursor.SpecialAction = Cursor.SpecialClick.command

	Cursor.Override = {
		LeftButton 	= db.Mouse.Cursor.Left,
		RightButton = db.Mouse.Cursor.Right,
	}

	Cursor.Indicator 	= TEXTURE[db.Mouse.Cursor.Left]
	Cursor.IndicatorR 	= TEXTURE[db.Mouse.Cursor.Right]
	Cursor.IndicatorS 	= TEXTURE[db.Mouse.Cursor.Special]

	local red, green, blue = db.Atlas.Hex2RGB(db.COLOR[gsub(db.Mouse.Cursor.Left, "CP_._", "")], true)

	Cursor.Scroll 		= db.Mouse.Cursor.Scroll
	Cursor.ScrollGuide 	= Cursor.Scroll == M1 and TEXTURE.CP_M1 or TEXTURE.CP_M2

	Cursor.Spell = Cursor.Spell or CreateFrame("PlayerModel", nil, Cursor)
	Cursor.Spell:SetAlpha(0.1)
	Cursor.Spell:SetDisplayInfo(42486)
	Cursor.Spell:SetLight(true, false, 0, 0, 120, 1, red, green, blue, 100, red, green, blue)
	Cursor.Spell:SetScript("OnShow", function(self)
		self:SetSize(70, 70)
		self:SetPoint("CENTER", Cursor, "BOTTOMLEFT", 20, 13)
	end)

	Cursor:SetScript("OnEvent", Cursor.OnEvent)
	Cursor:SetScript("OnHide", Cursor.OnHide)
	Cursor:SetScript("OnUpdate", Cursor.OnUpdate)
	Cursor:RegisterEvent("MODIFIER_STATE_CHANGED")
	Cursor:RegisterEvent("PLAYER_REGEN_DISABLED")
	Cursor:RegisterEvent("PLAYER_REGEN_ENABLED")
	Cursor:RegisterEvent("PLAYER_ENTERING_WORLD")
end
---------------------------------------------------------------
do
	Cursor.Tip = Cursor:CreateTexture(nil, "OVERLAY", nil, 7)
	Cursor.Tip:SetTexture("Interface\\CURSOR\\Item")
	Cursor.Tip:SetAllPoints(Cursor)

	Cursor.Button = Cursor:CreateTexture(nil, "OVERLAY", nil, 7)
	Cursor.Button:SetPoint("CENTER", 4, -4)
	Cursor.Button:SetSize(32, 32)

	Cursor.Highlight = Cursor:CreateTexture(nil, "OVERLAY")

	Cursor:SetFrameStrata("TOOLTIP")
	Cursor:SetSize(32,32)
	Cursor.Timer = 0

	Cursor.Scaling = Cursor:CreateAnimationGroup()
	Cursor.Scaling:SetScript("OnFinished", Cursor.ScaleOnFinished)

	Cursor.Moving = Cursor:CreateAnimationGroup()
	Cursor.Moving:SetScript("OnFinished", Cursor.MoveOnFinished)

	Cursor.Translate = Cursor.Moving:CreateAnimation("Translation")
	Cursor.Translate:SetSmoothing("OUT")
	Cursor.Translate:SetDuration(0.05)

	Cursor.Pointer = CreateFrame("Frame")
	Cursor.Pointer:SetSize(32, 32)

	Cursor.Enlarge = Cursor.Scaling:CreateAnimation("Scale")
	Cursor.Enlarge:SetDuration(0.1)
	Cursor.Enlarge:SetOrder(1)
	Cursor.Enlarge:SetSmoothing("OUT")
	Cursor.Enlarge:SetOrigin("CENTER", 0, 0)

	Cursor.Shrink = Cursor.Scaling:CreateAnimation("Scale")
	Cursor.Shrink:SetSmoothing("IN")
	Cursor.Shrink:SetOrigin("CENTER", 0, 0)
	Cursor.Shrink:SetOrder(2)
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

StepL:SetScript("OnClick", StepOnClick)
StepR:SetScript("OnClick", StepOnClick)