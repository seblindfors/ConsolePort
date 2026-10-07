local _, env, db, L = ...; db = env.db; L = db.Locale;
local BUTTON_SIZE    = 40;
local BUTTON_GAP     = 4;
local PADDING        = 12;
local GAP            = 8;
local MAX_PER_LINE   = 6;
local POPOUT_ATLAS   = 'helptip-arrow';
local POPOUT_WIDTH, POPOUT_HEIGHT = 26, 11;
local POPOUT_OVERLAP = 2;
local POPOUT_IDLE    = 0.5;
local CONTAINER      = Enum.ItemClass.Container;
local QUIVER         = Enum.ItemClass.Quiver;
local SUBCLASS       = Enum.ItemContainerSubclass or {};
local SUBCLASS_BAG   = SUBCLASS.Bag or 0;
local SUBCLASS_SOUL  = SUBCLASS.Soul or 1;
local SUBCLASS_REAGENT = SUBCLASS.Reagent or 11;
local STANDARD_BAGS  = { [SUBCLASS_BAG] = true, [SUBCLASS_SOUL] = true };
local NUM_EQUIPPED   = NUM_TOTAL_EQUIPPED_BAG_SLOTS or NUM_BAG_SLOTS;
-- The art points down and rotates as a quad at its native size.
local Directions = {
	-- direction: flyout anchor, slot anchor, rotation, popout size, offset sign, column based
	UP    = { 'BOTTOM', 'TOP',    math.pi,       POPOUT_WIDTH,  POPOUT_HEIGHT,  0,  1, false };
	DOWN  = { 'TOP',    'BOTTOM', 0,             POPOUT_WIDTH,  POPOUT_HEIGHT,  0, -1, false };
	RIGHT = { 'LEFT',   'RIGHT',  math.pi * 0.5, POPOUT_HEIGHT, POPOUT_WIDTH,   1,  0, true  };
	LEFT  = { 'RIGHT',  'LEFT',   math.pi * 1.5, POPOUT_HEIGHT, POPOUT_WIDTH,  -1,  0, true  };
};

local function FitsReagentSlot(info)
	if ( info.classID ~= CONTAINER ) then return false end;
	if CPAPI.IsCamelotVersion then
		return not STANDARD_BAGS[info.subclassID];
	end
	return info.subclassID == SUBCLASS_REAGENT;
end

local function FitsStandardSlot(info)
	if ( info.classID == QUIVER ) then return true end;
	if ( info.classID ~= CONTAINER ) then return false end;
	return info.subclassID ~= SUBCLASS_REAGENT;
end

local function IsReplacementBag(itemID, forReagentSlot)
	local info = CPAPI.GetItemInfoInstant(itemID)
	if forReagentSlot then
		return FitsReagentSlot(info), info.icon;
	end
	return FitsStandardSlot(info), info.icon;
end

local function GetSlotAnchor(slot)
	return slot.icon or slot;
end

local function GetReplacementBags(forReagentSlot)
	local bags = {};
	for bagID = BACKPACK_CONTAINER, NUM_EQUIPPED do
		for slotIndex = 1, CPAPI.GetContainerNumSlots(bagID) do
			local itemID = CPAPI.GetContainerItemID(bagID, slotIndex)
			if itemID then
				local isReplacement, icon = IsReplacementBag(itemID, forReagentSlot)
				if isReplacement then
					tinsert(bags, { bagID = bagID; slotIndex = slotIndex; itemID = itemID; icon = icon });
				end
			end
		end
	end
	return bags;
end

---------------------------------------------------------------
CPBagFlyoutButton = {};
---------------------------------------------------------------

function CPBagFlyoutButton:SetBag(data)
	self.bagID, self.slotIndex, self.itemID = data.bagID, data.slotIndex, data.itemID;
	self.Icon:SetTexture(data.icon)
	local quality = CPAPI.GetContainerItemInfo(data.bagID, data.slotIndex).quality;
	local color = quality and ITEM_QUALITY_COLORS[quality];
	self.Border:SetShown(not not color)
	if color then
		self.Border:SetVertexColor(color.r, color.g, color.b)
	end
end

function CPBagFlyoutButton:OnClick()
	self:GetParent():Equip(self.bagID, self.slotIndex)
end

function CPBagFlyoutButton:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	GameTooltip:SetBagItem(self.bagID, self.slotIndex)
	GameTooltip_AddInstructionLine(GameTooltip, L'Click to equip this bag in the slot.')
	GameTooltip:Show()
end

function CPBagFlyoutButton:OnLeave()
	GameTooltip:Hide()
end

---------------------------------------------------------------
CPBagFlyout = {};
---------------------------------------------------------------

function CPBagFlyout:OnLoad()
	CPAPI.ApplyNineSlice(self.Border, CPAPI.Backdrops.Dropdown)
	self.Empty:SetText(L'No spare bags in inventory.')
	self.pool = CreateFramePool('Button', self, 'CPBagFlyoutButtonTemplate')
	self.OnCancelClick = GenerateClosure(self.Hide, self)
	self.direction = 'UP';
	self:RegisterEvent('BAG_UPDATE_DELAYED')
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
end

function CPBagFlyout:OnEvent(event)
	if ( event == 'PLAYER_REGEN_DISABLED' ) then
		return self:Hide();
	end
	if self:IsShown() then
		self:Update()
	end
end

function CPBagFlyout:SetDirection(direction)
	self.direction = direction;
	if self:IsShown() then
		self:Anchor()
		self:Update()
	end
end

function CPBagFlyout:Toggle(slot, forReagentSlot)
	if self:IsShown() and ( self.slot == slot ) then
		return self:Hide();
	end
	if InCombatLockdown() then return end;
	self.slot, self.forReagentSlot = slot, forReagentSlot;
	self:Anchor()
	self:Update()
	self:Show()
end

function CPBagFlyout:Anchor()
	local point, relPoint, _, _, _, dx, dy = unpack(Directions[self.direction]);
	self:ClearAllPoints()
	self:SetPoint(point, GetSlotAnchor(self.slot), relPoint, dx * GAP, dy * GAP)
end

function CPBagFlyout:SetBorderAlpha(alpha)
	self.Border:SetAlpha(alpha)
end

function CPBagFlyout:Update()
	self.pool:ReleaseAll()
	local buttons = {};
	for i, data in ipairs(GetReplacementBags(self.forReagentSlot)) do
		local button = self.pool:Acquire()
		button:SetBag(data)
		button:Show()
		button.OnCancelClick = self.OnCancelClick;
		buttons[i] = button;
	end
	local count = #buttons;
	self.Empty:SetShown(count == 0)
	if ( count == 0 ) then
		return self:SetSize(self.Empty:GetStringWidth() + PADDING * 2, BUTTON_SIZE + PADDING * 2);
	end
	local isColumnBased = select(8, unpack(Directions[self.direction]));
	local stride = math.min(count, MAX_PER_LINE);
	local lines  = math.ceil(count / stride);
	local layout = GridLayoutUtil.CreateStandardGridLayout(stride, BUTTON_GAP, BUTTON_GAP, 1, -1, isColumnBased);
	local anchor = AnchorUtil.CreateAnchor('TOPLEFT', self, 'TOPLEFT', PADDING, -PADDING);
	GridLayoutUtil.ApplyGridLayout(buttons, anchor, layout)
	local long  = stride * BUTTON_SIZE + (stride - 1) * BUTTON_GAP + PADDING * 2;
	local short = lines  * BUTTON_SIZE + (lines  - 1) * BUTTON_GAP + PADDING * 2;
	if isColumnBased then
		self:SetSize(short, long)
	else
		self:SetSize(long, short)
	end
end

function CPBagFlyout:Equip(bagID, slotIndex)
	if InCombatLockdown() then return end;
	ClearCursor()
	CPAPI.PickupContainerItem(bagID, slotIndex)
	if CursorHasItem() then
		PutItemInBag(self.slot:GetID())
	end
	ClearCursor()
	self:Hide()
end

---------------------------------------------------------------
CPBagFlyoutPopout = {};
---------------------------------------------------------------

function CPBagFlyoutPopout:OnLoad()
	CPAPI.SetAtlas(self.NormalTexture, POPOUT_ATLAS, false)
	CPAPI.SetAtlas(self.HighlightTexture, POPOUT_ATLAS, false)
	self.ignoreInLayout = true;
	self:SetAlpha(POPOUT_IDLE)
end

function CPBagFlyoutPopout:SetSlot(slot, flyout, forReagentSlot)
	self.slot, self.flyout, self.forReagentSlot = slot, flyout, forReagentSlot;
	self:SetFrameLevel(slot:GetFrameLevel() + 1)
	slot:HookScript('OnEnter', GenerateClosure(self.SetAlpha, self, 1))
	slot:HookScript('OnLeave', GenerateClosure(self.SetAlpha, self, POPOUT_IDLE))
end

function CPBagFlyoutPopout:SetDirection(direction)
	local point, relPoint, rotation, width, height, dx, dy = unpack(Directions[direction]);
	self.NormalTexture:SetRotation(rotation)
	self.HighlightTexture:SetRotation(rotation)
	self:SetSize(width, height)
	self:ClearAllPoints()
	self:SetPoint(point, GetSlotAnchor(self.slot), relPoint, dx * -POPOUT_OVERLAP, dy * -POPOUT_OVERLAP)
end

function CPBagFlyoutPopout:OnClick()
	self.flyout:Toggle(self.slot, self.forReagentSlot)
end

function CPBagFlyoutPopout:OnEnter()
	self:SetAlpha(1)
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	GameTooltip_SetTitle(GameTooltip, L'Swap Bag')
	if InCombatLockdown() then
		GameTooltip_AddErrorLine(GameTooltip, L'Cannot swap bags in combat.')
	else
		GameTooltip_AddInstructionLine(GameTooltip, L'Pick a replacement bag from your inventory.')
	end
	GameTooltip:Show()
end

function CPBagFlyoutPopout:OnLeave()
	self:SetAlpha(POPOUT_IDLE)
	GameTooltip:Hide()
end
