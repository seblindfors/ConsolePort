local _, L = ...
local UI, Control, Data = ConsolePortUI:GetEssentials()
local KEY = Data.KEY
local LootButton = {}
L.LootButtonMixin = LootButton

local tooltipBackdrop
local tipR, tipG, tipB

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
		GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT', 0, 50)
		GameTooltip:SetLootItem(slot)
		CursorUpdate(self)
	end
	if ( slotType == LOOT_SLOT_CURRENCY ) then
		GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT', 0, 50)
		GameTooltip:SetLootCurrency(slot)
		CursorUpdate(self)
	end
	if GameTooltip:IsOwned(self) then
		local backdrop = GameTooltip:GetBackdrop()
		if backdrop then
			tipR, tipG, tipB = GameTooltip:GetBackdropColor()
			tooltipBackdrop = backdrop
		end
		GameTooltip:SetBackdrop(nil)
		local width, height = (GameTooltip:GetWidth() or 330) + 50, (GameTooltip:GetHeight() or 50)
		self.NameFrame:SetSize(width < 330 and 330 or width, height < 50 and 50 or height)
		self.Text:SetAlpha(0)
		self.hasTooltipFocus = true
	end
	self:LockHighlight()
	self.QuestTexture:SetDrawLayer('HIGHLIGHT', 7)
end

function LootButton:OnUpdate()
	if self.hasTooltipFocus and not GameTooltip:IsOwned(self) then
		self:OnLeave()
	end
end

function LootButton:OnLeave()
	GameTooltip:Hide()
	if tooltipBackdrop then
		GameTooltip:SetBackdrop(tooltipBackdrop)
		GameTooltip:SetBackdropColor(tipR, tipG, tipB)
	end
	ResetCursor()
	self.hasTooltipFocus = false
	self.NameFrame:SetSize(300, 50)
	self.Text:SetAlpha(1)
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
	local texture, name, quantity, currencyID, quality, locked, isQuestItem, questId, isActive = GetLootSlotInfo(self:GetID())
	self:SetIcon(texture)
	self:SetCount(quantity)
	self:SetQuality(quality)
	self:SetText(name)
	self:SetQuestItem(isQuestItem)
end