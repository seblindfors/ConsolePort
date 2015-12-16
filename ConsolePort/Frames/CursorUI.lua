---------------------------------------------------------------
-- CursorUI.lua: Interface cursor and node management.
---------------------------------------------------------------
-- Creates a cursor used to manage the interface with D-pad.
-- Operates recursively on a stack of frames provided in
-- UICore.lua and calculates appropriate actions based on
-- node priority and where nodes are drawn on screen.

local addOn, db = ...
local KEY 		= db.KEY
local SECURE 	= db.SECURE
local TEXTURE 	= db.TEXTURE
local L1, L2 	= "CP_TL1", "CP_TL2"
---------------------------------------------------------------
local MAX_WIDTH, MAX_HEIGHT
---------------------------------------------------------------
local nodes, current, old, rebindNode = {}
---------------------------------------------------------------
-- Upvalue functions since they are used very frequently.
local SetOverrideBindingClick = SetOverrideBindingClick
local ClearOverrideBindings = ClearOverrideBindings
local InCombatLockdown = InCombatLockdown
local PlaySound = PlaySound
local FadeOut = db.UIFrameFadeOut
local FadeIn = db.UIFrameFadeIn
---------------------------------------------------------------
local tinsert = tinsert
local ipairs = ipairs
local pairs = pairs
local wipe = wipe
---------------------------------------------------------------
local ConsolePort = ConsolePort
---------------------------------------------------------------
-- Initiate the cursor frame
local Cursor = CreateFrame("Frame", addOn.."Cursor", UIParent)
ConsolePort.Cursor = Cursor
---------------------------------------------------------------
-- UIControl: Wrappers for overriding click bindings
---------------------------------------------------------------
local function OverrideBindingClick(owner, old, button, mouseClick, mod)
	if not InCombatLockdown() then
		local key1, key2 = GetBindingKey(old)
		if key1 then SetOverrideBindingClick(owner, true, mod and mod..key1 or key1, button, mouseClick) end
		if key2 then SetOverrideBindingClick(owner, true, mod and mod..key2 or key2, button, mouseClick) end
	end
end

local function OverrideBindingShiftClick(owner, old, button, mouseClick)
	OverrideBindingClick(owner, old, button, mouseClick, "SHIFT-")
end

local function OverrideBindingCtrlClick(owner, old, button, mouseClick)
	OverrideBindingClick(owner, old, button, mouseClick, "CTRL-")
end

local function OverrideScroll(owner, up, down)
	if 	owner.Scroll == L1 then
		OverrideBindingShiftClick(owner, "CP_L_UP", up:GetName() or "CP_L_UP_SHIFT", "LeftButton")
		OverrideBindingShiftClick(owner, "CP_L_DOWN", down:GetName() or "CP_L_DOWN_SHIFT", "LeftButton")
	else
		OverrideBindingCtrlClick(owner, "CP_L_UP", up:GetName() or "CP_L_UP_CTRL", "LeftButton")
		OverrideBindingCtrlClick(owner, "CP_L_DOWN", down:GetName() or "CP_L_DOWN_CTRL", "LeftButton")
	end
end

local function SetClickButton(button, clickbutton)
	button:SetAttribute("type", "click")
	button:SetAttribute("clickbutton", clickbutton)
end

---------------------------------------------------------------
-- UIControl: Cursor texture functions
---------------------------------------------------------------
function Cursor:SetTexture(texture)
	local object = current and current.object 
	self.Button:SetTexture(texture or object == "EditBox" and self.IndicatorS or object == "Slider" and self.ScrollGuide or self.Indicator)
end

function Cursor:SetPosition(anchor, object)
	self:SetTexture()
	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", anchor, "CENTER", -4, 4)
	self:SetHighlight()
	self:Animate()
	PlaySound("igMainMenuOptionCheckBoxOn")
	if not self:IsVisible() then
		self:Show()
	end
end

function Cursor:Animate()
	if old == current and not self.Flash then
		return
	end
	if current then
		if old and not old.node:IsVisible() or self.Flash then
			self.Flash = nil
			self.Scale1:SetScale(1.75, 1.75)
			self.Scale2:SetScale(1/1.75, 1/1.75)
			self.Scale2:SetDuration(0.5)
			FadeOut(self.Glow, 1.5, 1, 0.25)
		else
			self.Scale1:SetScale(1.25, 1.25)
			self.Scale2:SetScale(1/1.25, 1/1.25)
			self.Scale2:SetDuration(0.2)
		end
		self.Highlight:SetParent(self)
		self.Group:Stop()
		self.Group:Play()
	end
end

function Cursor:OnFinished()
	self = self:GetParent()
	if current then
		self.Highlight:SetParent(current.node)
	end
end

function Cursor:SetHighlight()
	local highlight = current and current.node.GetHighlightTexture and current.node:GetHighlightTexture()
	if highlight and current.node:IsEnabled() then
		if highlight:GetAtlas() then
			self.Highlight:SetAtlas(highlight:GetAtlas())
		else
			self.Highlight:SetTexture(highlight:GetTexture())
			self.Highlight:SetBlendMode(highlight:GetBlendMode())
			self.Highlight:SetVertexColor(highlight:GetVertexColor())
		end
		self.Highlight:SetSize(highlight:GetSize())
		self.Highlight:SetTexCoord(highlight:GetTexCoord())
		self.Highlight:ClearAllPoints()
		self.Highlight:SetPoint(highlight:GetPoint())
		self.Highlight:Show()
	else
		self.Highlight:ClearAllPoints()
		self.Highlight:Hide()
	end
end

---------------------------------------------------------------
-- UIControl: Node management functions
---------------------------------------------------------------
local IsUsable = {
	Button 		= true,
	CheckButton = true,
	EditBox 	= true,
	Slider 		= true,
	Frame 		= false
}

local IsClickable = {
	Button 		= true,
	CheckButton = true,
	EditBox 	= false,
	Slider 		= false,
	Frame 		= false
}

local function HasInteraction(node, object)
	if  node:IsMouseEnabled() and
		node:IsVisible() and
		IsUsable[object] then
		if IsClickable[object] then
			return node:HasScript("OnClick")
		else
			return true
		end
	else
		return false
	end
end

local function GetScrollFrame(node)
	if node then
		if node:IsObjectType("ScrollFrame") then
			return node
		else
			return GetScrollFrame(node:GetParent())
		end
	end
end

local function IsNodeDrawn(node)
	local x, y = node:GetCenter()
	local scrollFrame = GetScrollFrame(node)
	if 	x and x <= MAX_WIDTH and x >= 0 and
		y and y <= MAX_HEIGHT and y >= 0 then
		-- if the node is a scroll child and it's anchored inside the scroll frame
		if scrollFrame and scrollFrame == GetScrollFrame(select(2, node:GetPoint())) then
			local left, bottom, width, height = scrollFrame:GetRect()
			if 	x > left and x < left+width and
				y > bottom and y < bottom+height then
				return true
			end
		else
			return true
		end
	end
end

local function GetNodes(node)
	if node.ignoreNode then
		return
	end
	local object = node:GetObjectType()
	if 	object ~= "Slider" and not node.hasArrow then
		for i, child in pairs({node:GetChildren()}) do
			GetNodes(child)
		end
	end
	if 	HasInteraction(node, object) and IsNodeDrawn(node) then
		if node.hasPriority then
			tinsert(nodes, 1, {node = node, object = object})
		else
			tinsert(nodes, {node = node, object = object})
		end
	end
end

local SwapFunc = {
	[KEY.UP] 	= function(destY, _, vert, horz, _, thisY) return (vert > horz and destY > thisY) end,
	[KEY.DOWN] 	= function(destY, _, vert, horz, _, thisY) return (vert > horz and destY < thisY) end,
	[KEY.LEFT] 	= function(_, destX, vert, horz, thisX, _) return (vert < horz and destX < thisX) end,
	[KEY.RIGHT] = function(_, destX, vert, horz, thisX, _) return (vert < horz and destX > thisX) end,
}

local function FindClosestNode(key)
	if current then
		local SwapFunc = SwapFunc[key]
		if SwapFunc then
			local destX, destY, vert, horz
			local thisX, thisY = current.node:GetCenter()
			local nodeX, nodeY = 10000, 10000
			for i, destination in ipairs(nodes) do
				destX, destY = destination.node:GetCenter()
				horz, vert = abs(thisX-destX), abs(thisY-destY)
				if 	horz + vert < nodeX + nodeY and
					SwapFunc(destY, destX, vert, horz, thisX, thisY) then
					nodeX = horz
					nodeY = vert
					current = destination
				end
			end
		end
	end
end

local function ClearNodes()
	if current then
		local node = current.node
		local leave = node:GetScript("OnLeave")
		Cursor:SetHighlight()
		if leave then
			leave(node)
		end
		old = current
	end
	wipe(nodes)
end

local function GetScrollButtons(node)
	if node then
		if node:IsObjectType("ScrollFrame") then
			for _, frame in pairs({node:GetChildren()}) do
				if frame:IsObjectType("Slider") then
					return frame:GetChildren()
				end
			end
		elseif node:IsObjectType("Slider") then
			return node:GetChildren()
		else
			return GetScrollButtons(node:GetParent())
		end
	end
end

-- Perform non secure special actions
local function SpecialAction(self)
	if current then
		local node = current.node
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
			local _, itemID = strsplit(":", strmatch(link, "item[%-?%d:]+"))
			self:AddUtilityAction("item", GetItemSpell(link) and itemID)
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
		if not current or (current and not current.node:IsVisible()) or (current and not IsNodeDrawn(current.node)) then
			self:Hide()
			current = nil
			if 	not InCombatLockdown() and
				ConsolePort:HasUIFocus()  then
				ConsolePort:UIControl()
			end
		end
		self.Timer = self.Timer - 0.1
	end
end

function Cursor:OnHide()
	self.Flash = true
	ClearNodes()
	if not InCombatLockdown() then
		ClearOverrideBindings(self)
	end
end

function Cursor:PLAYER_REGEN_DISABLED()
	self.Flash = true
	ClearOverrideBindings(self)
	FadeOut(self, 0.2, self:GetAlpha(), 0)
end

function Cursor:PLAYER_REGEN_ENABLED()
	self.Flash = true

	FadeIn(self, 0.2, self:GetAlpha(), 1)
end

function Cursor:PLAYER_ENTERING_WORLD()
	MAX_WIDTH, MAX_HEIGHT = UIParent:GetSize()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function Cursor:MODIFIER_STATE_CHANGED()
	if not InCombatLockdown() then
		if 	current and
			(self.Scroll == L1 and IsShiftKeyDown()) or
			(self.Scroll == L2 and IsControlKeyDown()) then
			self:SetTexture(self.ScrollGuide)
		else
			self:SetTexture()
		end
	end
end

function Cursor:OnEvent(event)
	self[event](self)
end

---------------------------------------------------------------
-- UIControl: Node manipulation
---------------------------------------------------------------
function ConsolePort:EnterNode(node, object, state)
	local scrollUp, scrollDown = GetScrollButtons(node)
	if scrollUp and scrollDown then
		OverrideScroll(Cursor, scrollUp, scrollDown)
	end

	local name = rebindNode and nil or node.direction and node:GetName()
	local override
	if IsClickable[object] and node:IsEnabled() then
		override = true
		local enter = not node.HotKey and node:GetScript("OnEnter")
		if enter and state == KEY.STATE_UP then
			enter(node)
		end
	end
	for click, button in pairs(Cursor.Override) do
		for extension, modifier in pairs(Cursor.Modifiers) do
			if override then
				SetClickButton(_G[button..extension], rebindNode or node)
				OverrideBindingClick(Cursor, button, name or button..extension, click, modifier)
			else
				SetClickButton(_G[button..extension], nil)
			end
		end
	end
end

function ConsolePort:CheckCurrentNode()
	if old and old.node:IsVisible() and IsNodeDrawn(old.node) then
		current = old
	elseif (not current and #nodes > 0) or (current and #nodes > 0 and not current.node:IsVisible()) then
		local x, y, targetNode = Cursor:GetCenter()
		if not x or not y then
			targetNode = nodes[1]
		else
			local targetDistance, targetParent, newDistance, newParent, swap, nodeX, nodeY
			for i, node in pairs(nodes) do swap = false
				nodeX, nodeY = node.node:GetCenter()
				newDistance = abs(x-nodeX)+abs(y-nodeY)
				newParent = node.node:GetParent()
				-- if no target node exists yet, just assign it
				if not targetNode then
					swap = true
				elseif node.node.hasPriority and not targetNode.node.hasPriority then
					targetNode = node
					break
				elseif not targetNode.node.hasPriority and newDistance < targetDistance then
					swap = true
				end
				if swap then
					targetNode = node
					targetDistance = newDistance
					targetParent = newParent
				end
			end
		end
		current = targetNode
	end
	if current and current ~= old then
		self:EnterNode(current.node, current.object, KEY.STATE_UP)
	end
end

function ConsolePort:RefreshNodes()
	if not InCombatLockdown() then
		ClearNodes()
		ClearOverrideBindings(Cursor)
		for frame in pairs(self:GetFrameStack()) do
			GetNodes(frame)
		end
		self:CheckCurrentNode()
	end
end

function ConsolePort:GetCurrentNode()
	return current and current.node
end

function ConsolePort:SetCurrentNode(node)
	if not InCombatLockdown() then
		if node then
			local object = node:GetObjectType()
			if 	HasInteraction(node, object) and IsNodeDrawn(node) then
				local x, y = node:GetCenter()
				old = current
				current = {
					node = node,
					object = object,
				}
				Cursor:SetPosition(current.node, current.object)
			end
		end
		self:UIControl()
	end
end

---------------------------------------------------------------
-- UIControl: Toggle rebind mode	
---------------------------------------------------------------
function ConsolePort:SetRebinding(button)
	ConsolePortRebindFrame.isRebinding = button
	rebindNode = button
end

---------------------------------------------------------------
-- UIControl: Command parser / main func
---------------------------------------------------------------
function ConsolePort:UIControl(key, state)
	self:RefreshNodes()
	if state == KEY.STATE_DOWN then
		FindClosestNode(key)
	elseif key == Cursor.SpecialAction then
		SpecialAction(self)
	end
	local node = current and current.node
	if node then
		self:EnterNode(node, current.object, state)
		Cursor:SetPosition(node, current.object)
	end
end

---------------------------------------------------------------
-- UIControl: Rebinding functions for cursor
---------------------------------------------------------------
local function GetInterfaceButtons()
	return {
		CP_L_UP_NOMOD,
		CP_L_DOWN_NOMOD,
		CP_L_RIGHT_NOMOD,
		CP_L_LEFT_NOMOD,
		_G[ConsolePortMouse.Cursor.Special.."_NOMOD"],
	}
end

function ConsolePort:SetButtonActionsDefault()
	ClearOverrideBindings(self)
	for button in pairs(SECURE) do
		button:Revert()
	end
end

function ConsolePort:SetButtonActionsUI()
	local buttons, key = GetInterfaceButtons()
	for i, button in pairs(buttons) do
		OverrideBindingClick(self, button.name, button:GetName(), "LeftButton")
		button:SetAttribute("type", "UIControl")
	end
end

---------------------------------------------------------------
-- UIControl: Initialize Cursor
---------------------------------------------------------------
function ConsolePort:SetupCursor()
	Cursor.Special 		= ConsolePortMouse.Cursor.Special
	Cursor.SpecialClick = _G[Cursor.Special.."_NOMOD"]
	Cursor.SpecialAction = Cursor.SpecialClick.command

	Cursor.Override = {
		LeftButton 	= ConsolePortMouse.Cursor.Left,
		RightButton = ConsolePortMouse.Cursor.Right,
	}

	Cursor.Indicator 	= TEXTURE[ConsolePortMouse.Cursor.Left]
	Cursor.IndicatorR 	= TEXTURE[ConsolePortMouse.Cursor.Right]
	Cursor.IndicatorS 	= TEXTURE[ConsolePortMouse.Cursor.Special]

	Cursor.Scroll 		= ConsolePortMouse.Cursor.Scroll
	Cursor.ScrollGuide 	= Cursor.Scroll == L1 and TEXTURE.CP_TL1 or TEXTURE.CP_TL2


	Cursor:SetScript("OnShow", Cursor.Animate)
	Cursor:SetScript("OnEvent", Cursor.OnEvent)
	Cursor:SetScript("OnHide", Cursor.OnHide)
	Cursor:SetScript("OnUpdate", Cursor.OnUpdate)
	Cursor:RegisterEvent("MODIFIER_STATE_CHANGED")
	Cursor:RegisterEvent("PLAYER_REGEN_DISABLED")
	Cursor:RegisterEvent("PLAYER_REGEN_ENABLED")
	Cursor:RegisterEvent("PLAYER_ENTERING_WORLD")
end

Cursor.Modifiers = {
	_NOMOD	= false,
	_SHIFT 	= "SHIFT-",
	_CTRL 	= "CTRL-",
}

Cursor.Icon = Cursor:CreateTexture(nil, "OVERLAY", nil, 7)
Cursor.Icon:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Cursor")
Cursor.Icon:SetAllPoints(Cursor)

Cursor.Button = Cursor:CreateTexture(nil, "OVERLAY", nil, 6)
Cursor.Button:SetPoint("TOPLEFT", Cursor, "CENTER", -9, 6)
Cursor.Button:SetPoint("BOTTOMRIGHT", Cursor, "BOTTOMRIGHT", -9, 6)

Cursor.Highlight = Cursor:CreateTexture(nil, "OVERLAY")

Cursor:SetFrameStrata("TOOLTIP")
Cursor:SetSize(46,46)
Cursor.Timer = 0

Cursor.Glow = Cursor.Glow or CreateFrame("PlayerModel", nil, Cursor)
Cursor.Glow:SetFrameStrata("DIALOG")
Cursor.Glow:SetSize(300, 300)
Cursor.Glow:SetPoint("CENTER", 0, 0)
Cursor.Glow:SetAlpha(0.25)
Cursor.Glow:SetCamDistanceScale(5)
Cursor.Glow:SetDisplayInfo(41039)
Cursor.Glow:SetRotation(1)

Cursor.Group = Cursor:CreateAnimationGroup()
Cursor.Group:SetScript("OnFinished", Cursor.OnFinished)

Cursor.Scale1 = Cursor.Group:CreateAnimation("Scale")
Cursor.Scale1:SetDuration(0.1)
Cursor.Scale1:SetSmoothing("IN")
Cursor.Scale1:SetOrder(1)
Cursor.Scale1:SetOrigin("CENTER", 0, 0)

Cursor.Scale2 = Cursor.Group:CreateAnimation("Scale")
Cursor.Scale2:SetSmoothing("OUT")
Cursor.Scale2:SetOrder(2)
Cursor.Scale2:SetOrigin("CENTER", 0, 0)