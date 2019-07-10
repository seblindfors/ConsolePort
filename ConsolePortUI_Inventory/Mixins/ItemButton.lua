local _, L = ...
L.ItemButtonMixin = {}
local Item = L.ItemButtonMixin
local UI = ConsolePortUI

function Item:OnModifiedClick()
	local bag, slot = self:GetAttribute('bag'), self:GetAttribute('slot')
	if ( HandleModifiedItemClick(GetContainerItemLink(bag, slot)) ) then
		return
	end
	local _, itemCount, locked = GetContainerItemInfo(bag, slot)
	if ( not locked and itemCount and itemCount > 1) then
		self.SplitStack = function(button, split)
			SplitContainerItem(self:GetAttribute('bag'), self:GetAttribute('slot'), split)
		end
		OpenStackSplitFrame(itemCount, self, "BOTTOMRIGHT", "TOPRIGHT")
	else
		SocketContainerItem(bag, slot)
	end
end

function Item:GetBagSlotIndex()
	return self:GetAttribute('bag'), self:GetAttribute('slot')
end

function Item:Update()
	local bag, slot = self:GetBagSlotIndex()
	local	texture, itemCount, locked,
			quality, readable, _, _,
			isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot)
	local isQuestItem, questId, isActive = GetContainerItemQuestInfo(bag, slot)

	SetItemButtonTexture(self, texture)
	SetItemButtonQuality(self, quality, itemID)
	SetItemButtonCount(self, itemCount)
	SetItemButtonDesaturated(self, locked)

	local questTexture = self.QuestTexture

	if ( questId and not isActive ) then
		questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG)
		questTexture:Show()
	elseif ( questId or isQuestItem ) then
		questTexture:SetTexture(TEXTURE_ITEM_QUEST_BORDER)
		questTexture:Show()	
	else
		questTexture:Hide()
	end

	local isNewItem = C_NewItems.IsNewItem(bag, slot)
	local isBattlePayItem = IsBattlePayItem(bag, slot)

	local battlepayItemTexture = self.BattlepayItemTexture
	local newItemTexture = self.NewItemTexture
	local flash = self.flashAnim
	local newItemAnim = self.newitemglowAnim

	if ( isNewItem ) then
		if (isBattlePayItem) then
			newItemTexture:Hide()
			battlepayItemTexture:Show()
		else
			if (quality and NEW_ITEM_ATLAS_BY_QUALITY[quality]) then
				newItemTexture:SetAtlas(NEW_ITEM_ATLAS_BY_QUALITY[quality])
			else
				newItemTexture:SetAtlas("bags-glow-white")
			end
			battlepayItemTexture:Hide()
			newItemTexture:Show()
		end
		if (not flash:IsPlaying() and not newItemAnim:IsPlaying()) then
			flash:Play()
			newItemAnim:Play()
		end
	else
		battlepayItemTexture:Hide()
		newItemTexture:Hide()
		if (flash:IsPlaying() or newItemAnim:IsPlaying()) then
			flash:Stop()
			newItemAnim:Stop()
		end
	end
end

function Item:UpdateCooldown()
	local bag, slot = self:GetBagSlotIndex()
	local cooldown = self.Cooldown
	local start, duration, enable = GetContainerItemCooldown(bag, slot)
	CooldownFrame_Set(cooldown, start, duration, enable)
	if ( duration > 0 and enable == 0 ) then
		SetItemButtonTextureVertexColor(self, 0.4, 0.4, 0.4)
	else
		SetItemButtonTextureVertexColor(self, 1, 1, 1)
	end
end

function Item:OnFocusGained()
	local bag, slot = self:GetBagSlotIndex()
	local tooltip = UI:GetTooltip()
	self.tooltip = tooltip
	tooltip:SetOwner(self, "ANCHOR_NONE")

	C_NewItems.RemoveNewItem(bag, slot)

	local newItemTexture = self.NewItemTexture
	local battlepayItemTexture = self.BattlepayItemTexture
	local flash = self.flashAnim
	local newItemGlowAnim = self.newitemglowAnim
	
	newItemTexture:Hide()
	battlepayItemTexture:Hide()
	
	if (flash:IsPlaying() or newItemGlowAnim:IsPlaying()) then
		flash:Stop()
		newItemGlowAnim:Stop()
	end
	
	local showSell = nil
	local hasCooldown, repairCost, speciesID, level, breedQuality, maxHealth, power, speed, name = tooltip:SetBagItem(bag, slot)
	if(speciesID and speciesID > 0) then
		ContainerFrameItemButton_CalculateItemTooltipAnchors(self, tooltip) -- Battle pet tooltip uses the tooltip's anchor
		BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name)
		return
	else
		if (BattlePetTooltip) then
			BattlePetTooltip:Hide()
		end
	end

	local requiresCompareTooltipReanchor = ContainerFrameItemButton_CalculateItemTooltipAnchors(self, tooltip)

	if ( requiresCompareTooltipReanchor and (IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems")) ) then
		GameTooltip_ShowCompareItem(tooltip)
	end

	if ( InRepairMode() and (repairCost and repairCost > 0) ) then
		tooltip:AddLine(REPAIR_COST, nil, nil, nil, true)
		SetTooltipMoney(tooltip, repairCost)
		tooltip:Show()
	elseif ( MerchantFrame:IsShown() and MerchantFrame.selectedTab == 1 ) then
		showSell = 1
	end

	if ( IsModifiedClick("DRESSUP") and self.hasItem ) then
		ShowInspectCursor()
	elseif ( showSell ) then
		ShowContainerSellCursor(bag,slot)
	elseif ( self.readable ) then
		ShowInspectCursor()
	else
		ResetCursor()
	end

	if ArtifactFrame and self.hasItem then
		ArtifactFrame:OnInventoryItemMouseEnter(bag, slot)
	end

	-- Tooltip manipulation
	tooltip.Button:Hide()
	tooltip:DisableScaling(true)
	tooltip:SetWidth(tooltip:GetWidth() + 24)
	tooltip.Icon.Texture:SetTexture(GetContainerItemInfo(bag, slot))
end

function Item:OnFocusLost()
	if self.tooltip then
		self.tooltip:Hide()
		self.tooltip = nil
	end
	ResetCursor()

	if ArtifactFrame then
		ArtifactFrame:OnInventoryItemMouseLeave(self:GetBagSlotIndex())
	end
end

function Item:OnHide()
	self:OnFocusLost()
end