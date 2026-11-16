local env, db = CPAPI.GetEnv(...);
env.LootButtonMixin = CreateFromMixins(CPActionButtonMixin);
---------------------------------------------------------------
local LOOT_SLOT_ITEM = LOOT_SLOT_ITEM or Enum.LootSlotType and Enum.LootSlotType.Item;
local LOOT_SLOT_CURRENCY = LOOT_SLOT_CURRENCY or Enum.LootSlotType and Enum.LootSlotType.Currency;

local sharedBackdrop;
local function RestoreSharedBackdrop()
	if sharedBackdrop then
		local backdrop = sharedBackdrop;
		sharedBackdrop = nil;
		backdrop:Show()
	end
end

-- The shared tooltip can be reused without the loot button losing focus first.
if GameTooltip:HasScript('OnTooltipCleared') then
	GameTooltip:HookScript('OnTooltipCleared', RestoreSharedBackdrop)
end
GameTooltip:HookScript('OnHide', RestoreSharedBackdrop)
hooksecurefunc(GameTooltip, 'SetOwner', RestoreSharedBackdrop)

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

	if ( slotType == LOOT_SLOT_ITEM or slotType == LOOT_SLOT_CURRENCY ) then
		local tooltip = GetTooltip()
		tooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT', 0, 50)
		if ( slotType == LOOT_SLOT_ITEM ) then
			tooltip:SetLootItem(slot)
		else
			tooltip:SetLootCurrency(slot)
		end

		if CPAPI.Scrub(tooltip:IsOwned(self)) then
			self.lootTooltip = tooltip;
			self.Text:SetAlpha(0)
			self:SetScript('OnUpdate', self.OnUpdate)
		end
	elseif ( slotType == LOOT_SLOT_MONEY ) then
		self:SetClampedSize(330, 50)
	end

	self:LockHighlight()
	self.QuestTexture:SetDrawLayer('HIGHLIGHT', 7)
end

function LootButton:OnLeave()
	local tooltip = self.lootTooltip;
	self.lootTooltip = nil;
	self:SetScript('OnUpdate', nil)
	if tooltip and CPAPI.Scrub(tooltip:IsOwned(self)) then
		if tooltip == GameTooltip then
			RestoreSharedBackdrop()
		end
		tooltip:Hide()
	end
	self.NameFrame:SetSize(300, 50)
	self.Text:SetAlpha(1)
	self:UnlockHighlight()
	self.QuestTexture:SetDrawLayer('OVERLAY')
end

function LootButton:OnUpdate()
	local tooltip = self.lootTooltip;
	if not tooltip or not CPAPI.Scrub(tooltip:IsOwned(self)) then
		return self:OnLeave()
	end

	local width = ( CPAPI.Scrub(tooltip:GetWidth()) or 330 ) + 50;
	local height = CPAPI.Scrub(tooltip:GetHeight()) or 50;
	self:SetClampedSize(width, height)

	local backdrop = tooltip.NineSlice;
	if backdrop and backdrop:IsShown() then
		if tooltip == GameTooltip then
			sharedBackdrop = backdrop;
		end
		backdrop:Hide()
	end
	tooltip:SetAnchorType('ANCHOR_BOTTOMRIGHT', 0, (tooltip:NumLines() == 1) and 40 or 50)
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
local ParseMoney;
do local MoneyFormatters = {};
	for matchString, textureString in pairs({
		[GOLD_AMOUNT]   = GOLD_AMOUNT_TEXTURE;
		[SILVER_AMOUNT] = SILVER_AMOUNT_TEXTURE;
		[COPPER_AMOUNT] = COPPER_AMOUNT_TEXTURE;
	}) do
		local amountString = matchString:format(0):gsub('0', '(%%d+)')
		local resultString = textureString:format(0, 0, 0):gsub('0', '%%1', 1)
		MoneyFormatters[amountString] = resultString;
	end

	function ParseMoney(str)
		local new = str;
		for pattern, texture in pairs(MoneyFormatters) do
			new = new:gsub(pattern, texture);
		end
		if (new ~= str) then
			new = new:gsub('\n', ' ');
		end
		return new;
	end
end

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
	self:SetText(ParseMoney(name))
	self:SetQuestItem(isQuestItem)
end
