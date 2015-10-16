local addOn, db = ...
local UI 		= db.UI
local KEY 		= db.KEY
local TEXTURE 	= db.TEXTURE
local NOMOD 	= "_NOMOD"
local L1, L2 	= "CP_TR3", "CP_TR4"
local nodes, current, old, rebindNode = {}, nil, nil, nil

--- Localize frequently used globals
-- Functions
local SetOverrideBindingClick = SetOverrideBindingClick
local ClearOverrideBindings = ClearOverrideBindings
local InCombatLockdown = InCombatLockdown
local tinsert = tinsert
local ipairs = ipairs
local pairs = pairs
local wipe = wipe
-- Widgets
local ConsolePort = ConsolePort
local UIParent = UIParent


-- Initiate the cursor frame
local Cursor = CreateFrame("Frame", addOn.."Cursor", UIParent)

---------------------------------------------------------------
-- UIControl: Override click bindings
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

---------------------------------------------------------------
-- UIControl: Cursor texture functions
---------------------------------------------------------------
local function SetCursorTexture(self, texture)
	local object = current and current.object 
	self.Button:SetTexture(texture or object == "Slider" and self.ScrollGuide or self.Indicator)
end

local function SetCursorPosition(self, anchor, object)
	self:SetTexture()
	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", anchor, "CENTER", -4, 4)
	self:Show()
end

local function AnimateCursor(self)
	if not self.Animation then
		self.Animation = CreateFrame("FRAME", nil, UIParent)
		self.Animation.Texture = self.Animation:CreateTexture()
		self.Animation.Button = self.Animation:CreateTexture()
		self.Animation.Group = self.Animation:CreateAnimationGroup()
		self.Animation.Type = self.Animation.Group:CreateAnimation("Translation")
		local Animation = self.Animation
		local Texture = Animation.Texture
		local Button = Animation.Button
		local Group = Animation.Group
		local Type = Animation.Type
		Animation:SetFrameStrata("TOOLTIP")
		Animation:SetSize(46,46);
		Texture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Cursor")
		Texture:SetAllPoints(Animation)
		Button:SetPoint("TOPLEFT", Animation, "TOPLEFT", 15, -18)
		Button:SetPoint("BOTTOMRIGHT", Animation, "BOTTOMRIGHT", -9, 6)
		Type:SetDuration(0.1)
		Type:SetSmoothing("NONE")
		Group:SetScript("OnPlay", function()
			self:SetAlpha(0)
			Animation:Show()
		end)
		Group:SetScript("OnFinished", function()
			self:SetAlpha(1)
			Animation:Hide()
		end)
	elseif old == current then
		return
	elseif old and current then
		local Animation = self.Animation;
		local dX, dY = current.node:GetCenter()
		local tX, tY = old.node:GetCenter()
		if dX and dY and tX and tY then
			Animation:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", tX-4, tY+4)
			Animation.Type:SetOffset((dX-tX), (dY-tY))
			Animation.Button:SetTexture(self.Button:GetTexture())
			Animation.Group:Play()
		end
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

local function IsNodeDrawn(node)
	local x, y = node:GetCenter()
	if 	x and x <= UIParent:GetWidth() and x >= 0 and
		y and y <= UIParent:GetHeight() and y >= 0 then
		return true
	end
end

local function GetNodes(parent)
	if parent.ignoreNode then
		return
	end
	local children = {parent:GetChildren()}
	local object = parent:GetObjectType()
	if 	object ~= "Slider" and not parent.hasArrow then
		for i, child in pairs(children) do
			GetNodes(child)
		end
	end
	if 	HasInteraction(parent, object) and IsNodeDrawn(parent) then
		local x, y = parent:GetCenter()
		if parent.hasPriority then
			tinsert(nodes, 1, {node = parent, object = object, X = x, Y = y})
		else
			tinsert(nodes, {node = parent, object = object, X = x, Y = y})
		end
	end
end

local function ClearNodes()
	if current then
		local node = current.node
		local leave = node:GetScript("OnLeave")
		if node:IsObjectType("Button") then
			node:UnlockHighlight()
		end
		if leave then
			leave(node)
		end
		old = current
	end
	wipe(nodes)
end

local function SetCurrent()
	if old and old.node:IsVisible() and IsNodeDrawn(old.node) then
		current = old
	elseif (not current and nodes[1]) or (current and nodes[1] and not current.node:IsVisible()) then
		current = nodes[1]
	end
end

local function RefreshNodes(self)
	if not InCombatLockdown() then
		ClearNodes()
		ClearOverrideBindings(Cursor)
		for i, frame in pairs(self:GetFrameStack()) do
			GetNodes(frame)
		end
		SetCurrent()
	end
end

local function FindClosestNode(key)
	if current then
		local destY, destX, diffY, diffX
		local thisY = current.Y
		local thisX = current.X
		local nodeY = 10000 -- default values have to 
		local nodeX = 10000 -- exceed screen resolution
		local swap 	= false
		for i, destination in ipairs(nodes) do
			destY = destination.Y
			destX = destination.X
			diffY = abs(thisY-destY)
			diffX = abs(thisX-destX)
			if diffX + diffY < nodeX + nodeY then
				if 	key == KEY.UP then
					if 	diffY > diffX and 	-- up/down
						destY > thisY then 	-- up
						swap = true
					end
				elseif key == KEY.DOWN then
					if 	diffY > diffX and 	-- up/down
						destY < thisY then 	-- down
						swap = true
					end
				elseif key == KEY.LEFT then
					if 	diffY < diffX and 	-- left/right
						destX < thisX then 	-- left
						swap = true
					end
				elseif key == KEY.RIGHT then
					if 	diffY < diffX and 	-- left/right
						destX > thisX then 	-- right
						swap = true
					end
				end
			end
			if swap then
				nodeX = diffX
				nodeY = diffY
				current = destination
				swap = false
			end
		end
	end
end

local function EnterNode(self, node, object, state)
	if IsClickable[object] and node:IsEnabled() then
		local name = rebindNode and nil or node.direction and node:GetName()
		self:SetClickButton(Cursor.LeftClick, rebindNode or node)
		self:SetClickButton(Cursor.RightClick, rebindNode or node)
		OverrideBindingClick(Cursor, Cursor.Left, 	name or Cursor.Left..NOMOD, 	"LeftButton")
		OverrideBindingClick(Cursor, Cursor.Right, 	name or Cursor.Right..NOMOD, 	"RightButton")
		-- Check for HotKey to avoid taint on action buttons in rebind mode
		local enter = not node.HotKey and node:GetScript("OnEnter")
		node:LockHighlight()
		if enter and state == KEY.STATE_UP then
			enter(node)
		end
	else
		self:SetClickButton(Cursor.LeftClick, nil)
		self:SetClickButton(Cursor.RightClick, nil)
	end
end

-- Perform special actions for triangle input
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
			self:UpdateExtraButton(GetItemSpell(link) and link)
		-- Spell button
		elseif node.SpellName then
			local _,_, spellID = SpellBook_GetSpellBookSlot(node)
			if 	not node.IsPassive then
				PickupSpell(spellID)
			end
		end
	end
end

---------------------------------------------------------------
-- UIControl: Cursor scripts and events
---------------------------------------------------------------
local function UpdateCursor(self, elapsed)
	self.Timer = self.Timer + elapsed
	while self.Timer > 0.1 do
		if not current or (current and not current.node:IsVisible()) or (current and not IsNodeDrawn(current.node)) then
			self:Hide()
			current = nil
			if 	not InCombatLockdown() and
				ConsolePort:HasUIFocus()  then
				ConsolePort:UIControl(KEY.PREPARE, KEY.STATE_DOWN)
			end
		end
		self.Timer = self.Timer - 0.1
	end
end

local function OnHide(self)
	ClearNodes()
	if not InCombatLockdown() then
		ClearOverrideBindings(self)
	end
end

local function OnEvent(self, event)
	if 		event == "PLAYER_REGEN_DISABLED" then
		ClearOverrideBindings(self)
	elseif 	event == "MODIFIER_STATE_CHANGED" and not InCombatLockdown()  then
		if 	current and
			(self.Scroll == L1 and IsShiftKeyDown()) or
			(self.Scroll == L2 and IsControlKeyDown()) then
			self:SetTexture(TEXTURE.VERTICAL)
			local slider = current.node
			local up, down = slider:GetChildren()
			if up and down then
				if 	self.Scroll == L1 then
					OverrideBindingShiftClick(self, "CP_L_UP", up:GetName() or "CP_L_UP_SHIFT", "LeftButton")
					OverrideBindingShiftClick(self, "CP_L_DOWN", down:GetName() or "CP_L_DOWN_SHIFT", "LeftButton")
				else
					OverrideBindingCtrlClick(self, "CP_L_UP", up:GetName() or "CP_L_UP_CTRL", "LeftButton")
					OverrideBindingCtrlClick(self, "CP_L_DOWN", down:GetName() or "CP_L_DOWN_CTRL", "LeftButton")
				end
			end
		else
			self:SetTexture()
		end
	end
end

---------------------------------------------------------------
-- UIControl: Global node manipulation
---------------------------------------------------------------
function ConsolePort:GetUIControlNodes()
	return nodes
end

function ConsolePort:GetCurrentNode()
	return current and current.node
end

function ConsolePort:SetCurrentNode(UIobject)
	RefreshNodes(self)
	for i, node in pairs(nodes) do
		if node.node == UIobject then
			old = current
			current = node
			Cursor:SetPosition(node.node, node.object)
			Cursor:Animate()
			break
		end
	end
	self:UIControl(KEY.PREPARE, KEY.STATE_DOWN)
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
	RefreshNodes(self)
	if state == KEY.STATE_DOWN then
		FindClosestNode(key)
	elseif key == Cursor.SpecialAction then
		SpecialAction(self)
	end
	local node = current and current.node
	if node then
		EnterNode(self, node, current.object, state)
		Cursor:SetPosition(node, current.object)
		Cursor:Animate()
	end
end

---------------------------------------------------------------
-- UIControl: Initialize Cursor
---------------------------------------------------------------
function ConsolePort:SetupCursor()
	Cursor.Icon = Cursor.Icon or Cursor:CreateTexture(nil, "OVERLAY")
	Cursor.Icon:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Cursor")
	Cursor.Icon:SetAllPoints(Cursor)
	Cursor.Button = Cursor.Button or Cursor:CreateTexture(nil, "ARTWORK")
	Cursor.Button:SetPoint("TOPLEFT", Cursor, "TOPLEFT", 15, -18)
	Cursor.Button:SetPoint("BOTTOMRIGHT", Cursor, "BOTTOMRIGHT", -9, 6)

	Cursor:SetFrameStrata("TOOLTIP")
	Cursor:SetSize(46,46)
	Cursor.Timer = 0

	Cursor.Animate 		= AnimateCursor
	Cursor.SetTexture 	= SetCursorTexture
	Cursor.SetPosition 	= SetCursorPosition

	Cursor.Left 		= ConsolePortMouse.Cursor.Left
	Cursor.Right 		= ConsolePortMouse.Cursor.Right
	Cursor.Scroll 		= ConsolePortMouse.Cursor.Scroll
	Cursor.Special 		= ConsolePortMouse.Cursor.Special

	Cursor.LeftClick 	= _G[Cursor.Left..NOMOD]
	Cursor.RightClick 	= _G[Cursor.Right..NOMOD]
	Cursor.SpecialClick = _G[Cursor.Special..NOMOD]

	Cursor.Indicator 	= TEXTURE[strupper(db.NAME[Cursor.Left])]
	Cursor.ScrollGuide 	= Cursor.Scroll == L1 and TEXTURE.LONE or TEXTURE.LTWO

	Cursor.SpecialAction = Cursor.SpecialClick.command

	Cursor:SetScript("OnEvent", OnEvent)
	Cursor:SetScript("OnHide", OnHide)
	Cursor:SetScript("OnUpdate", UpdateCursor)
	Cursor:RegisterEvent("MODIFIER_STATE_CHANGED")
	Cursor:RegisterEvent("PLAYER_REGEN_DISABLED")
end
