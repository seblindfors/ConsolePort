local addOn, db = ...
local KEY 		= db.KEY
local TEXTURE 	= db.TEXTURE
local nodes, current, old = {}, nil, nil

local doNothing = CreateFrame("Button", nil, UIParent)

local Cursor = CreateFrame("Frame", addOn.."Cursor", UIParent)
Cursor.Icon = Cursor:CreateTexture(nil, "OVERLAY")
Cursor.Icon:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Cursor")
Cursor.Icon:SetAllPoints(Cursor)
Cursor.Button = Cursor:CreateTexture(nil, "ARTWORK")
Cursor.Button:SetPoint("TOPLEFT", Cursor, "TOPLEFT", 15, -18)
Cursor.Button:SetPoint("BOTTOMRIGHT", Cursor, "BOTTOMRIGHT", -9, 6)

Cursor:SetSize(46,46)
Cursor.Timer = 0

local function OnShow(self)
	self.Button:SetTexture(TEXTURE.CIRCLE or TEXTURE.B)
end

local function OnHide(self)
	if not InCombatLockdown() then
		ClearOverrideBindings(self)
	end
end

local function OnEvent(self)
	ClearOverrideBindings(self)
end

local function SetCursorPosition(anchor)
	if not Cursor:IsVisible() then
		Cursor:Show()
	end
	Cursor:ClearAllPoints()
	Cursor:SetPoint("TOPLEFT", anchor, "CENTER", -4, 4)
	Cursor:SetFrameStrata("TOOLTIP")
end

local function AnimateCursor()
	if not Cursor.Animation then
		Cursor.Animation = CreateFrame("FRAME", nil, UIParent)
		Cursor.Animation.Texture = Cursor.Animation:CreateTexture()
		Cursor.Animation.Button = Cursor.Animation:CreateTexture()
		Cursor.Animation.Group = Cursor.Animation:CreateAnimationGroup()
		Cursor.Animation.Type = Cursor.Animation.Group:CreateAnimation("Translation")
		local Animation = Cursor.Animation
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
			Cursor:SetAlpha(0)
			Animation:Show()
		end)
		Group:SetScript("OnFinished", function()
			Cursor:SetAlpha(1)
			Animation:Hide()
		end)
	elseif old == current then
		return
	elseif old and current then
		local Animation = Cursor.Animation;
		local dX, dY = current.node:GetCenter();
		local tX, tY = old.node:GetCenter();
		Animation:SetPoint("TOPLEFT", old.node, "CENTER", -4, 4);
		Animation.Type:SetOffset((dX-tX), (dY-tY))
		Animation.Button:SetTexture(Cursor.Button:GetTexture())
		Animation.Group:Play()
	end
end

local function UpdateCursor(self, elapsed)
	self.Timer = self.Timer + elapsed
	while self.Timer > 0.1 do
		if not current or (current and not current.node:IsVisible()) then
			self:Hide()
			current = nil
		end
		self.Timer = self.Timer - 0.1
	end
end

Cursor:SetScript("OnEvent", OnEvent)
Cursor:SetScript("OnHide", OnHide)
Cursor:SetScript("OnShow", OnShow)
Cursor:SetScript("OnUpdate", UpdateCursor)
Cursor:RegisterEvent("PLAYER_REGEN_DISABLED")

local function FindClosestNode(key)
	if current then
		local thisY = current.Y
		local thisX = current.X
		local nodeY = 10000
		local nodeX = 10000
		local swap 	= false
		for i, destination in ipairs(nodes) do
			local destY = destination.Y
			local destX = destination.X
			local diffY = abs(thisY-destY)
			local diffX = abs(thisX-destX)
			local total = diffX + diffY
			if total < nodeX + nodeY then
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

local function ClearNodes()
	if current then
		local node = current.node
		local leave = node:GetScript("OnLeave")
		node:UnlockHighlight()
		if leave then
			leave(node)
		end
		old = current
	end
	nodes = {}
end

local function Setcurrent()
	if 	(not current and nodes[1]) or
		(current and nodes[1] and not current.node:IsVisible()) then
		current = nodes[1]
		return true
	elseif current and current.node:IsVisible() then
		return true
	else
		return false
	end
end

local function GetNodes(parent)
	if parent.ignoreNode then
		return
	end
	local children = {parent:GetChildren()}
	for i, child in pairs(children) do
		GetNodes(child)
	end
	if 	parent:IsObjectType("Button") and
		parent:IsMouseEnabled() and
		parent:HasScript("OnClick") and
		parent:IsVisible() then
		local x, y = parent:GetCenter()
		if x and y then
			tinsert(nodes, {node = parent, X = x, Y = y})
		end
	end
end

local function RefreshNodes(self)
	ClearNodes()
	ClearOverrideBindings(Cursor)
	for i, frame in pairs(self:GetFrameStack()) do
		GetNodes(frame)
	end
	Setcurrent()
end

local function EnterNode(self, node)
	if node:IsEnabled() then
		if node.direction then
			self:OverrideBindingClick(Cursor, "CP_R_RIGHT", node:GetName(), "LeftButton");
		else
			self:SetClickButton(CP_R_RIGHT_NOMOD, node)
			-- not perfect
			if node:GetName() then
				self:OverrideBindingClick(Cursor, "CP_R_LEFT", node:GetName(), "RightButton");
			end
		end
		local enter = node:GetScript("OnEnter")
		node:LockHighlight()
		if enter then
			enter(node)
		end
	else
		self:SetClickButton(CP_R_RIGHT_NOMOD, doNothing)
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

function ConsolePort:General(key, state)
	RefreshNodes(self)
	if state == KEY.STATE_DOWN then
		FindClosestNode(key)
	elseif key == KEY.TRIANGLE then
		SpecialAction(self)
	end
	local node = current and current.node
	if node then
		EnterNode(self, node)
		SetCursorPosition(node)
		AnimateCursor()
	end
end