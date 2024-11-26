local db, _, env = ConsolePort:DB(), ...; env.LootButtonMixin = CreateFromMixins(CPActionButtonMixin);
---------------------------------------------------------------
local LOOT_SLOT_ITEM = LOOT_SLOT_ITEM or Enum.LootSlotType and Enum.LootSlotType.Item;
local LOOT_SLOT_CURRENCY = LOOT_SLOT_CURRENCY or Enum.LootSlotType and Enum.LootSlotType.Currency;

local function GetTooltip()
	if db('useGlobalLootTooltip') then
		return GameTooltip;
	end
	return ConsolePortLootButtonTooltip or
		CreateFrame('GameTooltip', 'ConsolePortLootButtonTooltip', ConsolePortLootFrame, 'GameTooltipTemplate')
end

---------------------------------------------------------------
-- Loot button scripts
---------------------------------------------------------------
local LootButton = env.LootButtonMixin;

function LootButton:OnLoad()
	CPAPI.Start(self)
	self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	self:RegisterForDrag('LeftButton')
	self:SetScript('OnUpdate', nil)
end

function LootButton:OnDragStart()
	self:GetParent():StartMoving()
end

function LootButton:OnDragStop()
	self:GetParent():StopMovingOrSizing()
end

function LootButton:OnClick()
	LootSlot(self:GetID())
end

function LootButton:OnEnter()
	local slot = self:GetID()
	local slotType = GetLootSlotType(slot)

	for sibling in self:GetParent():EnumerateActive() do
		sibling:OnLeave()
	end

	local tooltip = GetTooltip()
	if ( slotType == LOOT_SLOT_ITEM ) then
		tooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT', 0, 50)
		tooltip:SetLootItem(slot)
		self:SetScript('OnUpdate', self.OnUpdate)
	elseif ( slotType == LOOT_SLOT_CURRENCY ) then
		tooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT', 0, 50)
		tooltip:SetLootCurrency(slot)
		self:SetScript('OnUpdate', self.OnUpdate)
	elseif ( slotType == LOOT_SLOT_MONEY ) then
		self:SetScript('OnUpdate', nil)
		self:SetClampedSize(330, 50)
	end

	if tooltip:IsOwned(self) then
		self.Text:SetAlpha(0)
		self.hasTooltipFocus = true;
	end

	self:LockHighlight()
	self.QuestTexture:SetDrawLayer('HIGHLIGHT', 7)
end

function LootButton:OnLeave()
	local tooltip = GetTooltip()
	if tooltip:IsOwned(self) then
		tooltip.NineSlice:Show()
		tooltip:Hide()
		self:SetScript('OnUpdate', nil)
	end
	self.hasTooltipFocus = false;
	self.NameFrame:SetSize(300, 50)
	self.Text:SetAlpha(1)
	self:UnlockHighlight()
	self.QuestTexture:SetDrawLayer('OVERLAY')
end

function LootButton:OnUpdate()
	local tooltip = GetTooltip()
	local isOwned = tooltip:IsOwned(self)
	local width   = (isOwned and tooltip:GetWidth() or 330) + 50;
	local height  = (isOwned and tooltip:GetHeight() or 50);
	self:SetClampedSize(width, height)
	if self.hasTooltipFocus and not isOwned then
		self:OnLeave()
	else
		-- HACK: Readjust the tooltip if showing a single line, because it looks nicer.
		tooltip.NineSlice:Hide()
		tooltip:SetAnchorType('ANCHOR_BOTTOMRIGHT', 0, (tooltip:NumLines() == 1) and 40 or 50)
	end
end

function LootButton:SetClampedSize(width, height)
	self.NameFrame:SetSize(Clamp(width, 330, width), Clamp(height, 50, height))
end

function LootButton:OnHide()
	self:OnLeave()
end

---------------------------------------------------------------
-- Content handling
---------------------------------------------------------------
function LootButton:SetQuality(itemQuality)
	local colors = ITEM_QUALITY_COLORS[itemQuality];
	if colors then
		self.Text:SetTextColor(colors.r, colors.g, colors.b)
	else
		self.Text:SetTextColor(1, 1, 1)
	end
end

function LootButton:SetText(text)
	self.Text:SetText(text)
end

function LootButton:SetQuestItem(isQuestItem)
	self.QuestTexture:SetShown(isQuestItem)
end

function LootButton:Update()
	local texture, name, quantity, currencyID, quality, locked, isQuestItem, questId, isActive = GetLootSlotInfo(self:GetID())
	self:SetIcon(texture)
	self:SetCount(quantity)
	self:SetQuality(quality)
	self:SetText(name)
	self:SetQuestItem(isQuestItem)
end

---------------------------------------------------------------
-- Add to config
---------------------------------------------------------------
ConsolePort:AddVariables({
	useGlobalLootTooltip = {db.Data.Bool(false);
		head = ACCESSIBILITY_LABEL;
		sort = 4;
		name = 'Use Global Loot Tooltip';
		desc = 'Use global game tooltip for loot information, allowing other addons to add information to lootable items.';
		note = 'Requires ConsolePort World.';
		advd = true;
	};
})