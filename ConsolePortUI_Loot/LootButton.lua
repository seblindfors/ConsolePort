local _, L = ...
local UI = ConsolePortUI
local KEY = UI.Data.KEY
local Control = UI:GetControlHandle()
local LootButton = {}
L.LootButtonMixin = LootButton


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
	if ( slotType == LOOT_SLOT_ITEM ) then
		GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
		GameTooltip:SetLootItem(slot)
		CursorUpdate(self)
	end
	if ( slotType == LOOT_SLOT_CURRENCY ) then
		GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
		GameTooltip:SetLootCurrency(slot)
		CursorUpdate(self)
	end
	self:LockHighlight()
	self.QuestTexture:SetDrawLayer('HIGHLIGHT', 7)
end

function LootButton:OnLeave()
	GameTooltip:Hide()
	ResetCursor()
	self:UnlockHighlight()
	self.QuestTexture:SetDrawLayer('OVERLAY')
end

function LootButton:SetQuality(itemQuality)
	local colors = ITEM_QUALITY_COLORS[itemQuality]
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
	local texture, item, quantity, quality, locked, isQuestItem, questId, isActive = GetLootSlotInfo(self:GetID())
	self:SetIcon(texture)
	self:SetCount(quantity)
	self:SetQuality(quality)
	self:SetText(item)
	self:SetQuestItem(isQuestItem)
end