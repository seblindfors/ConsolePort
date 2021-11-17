local _, env = ...;
local BagContainer, BagSlot = CreateFromMixins(BackdropTemplateMixin), CreateFromMixins(ItemMixin)
env.BagContainerMixin = BagContainer;

local MAX_CONTAINER_ITEMS = 36;

---------------------------------------------------------------
-- 
---------------------------------------------------------------
function BagContainer:OnLoad()
	CPAPI.EventHandler(self, {
		'BAG_UPDATE';
		'BAG_UPDATE_DELAYED';
		'ITEM_LOCKED';
		'ITEM_UNLOCKED';
		'PLAYER_REGEN_ENABLED';
		'PLAYER_REGEN_DISABLED';
	})

	self:SetBackdrop({
		bgFile   = CPAPI.GetAsset('Textures\\Frame\\Backdrop_Gossip.blp');
		edgeFile = CPAPI.GetAsset('Textures\\Frame\\Edge_Gossip_BG.blp');
		edgeSize = 8;
		insets   = {left = 2, right = 2, top = 8, bottom = 8};
	})

	self.Owners, self.Buttons, self.Active = {}, {}, {};
	for bagID = 0, NUM_CONTAINER_FRAMES - 1 do
		local proxy = CreateFrame('Frame', '$parentProxy'..bagID, self, 'SecureHandlerBaseTemplate')
		proxy:SetPoint('TOPLEFT', 0, 0)
		proxy:SetSize(40, 40)
		proxy:SetID(bagID)
		self.Owners[bagID] = proxy;
	end
	self:UpdateActiveSlots()
end

function BagContainer:OnShow()
end

function BagContainer:UpdateActiveSlots()
	local buttons = self.Buttons;
	for i, button in ipairs(buttons) do
		button:Hide()
	end
	wipe(self.Active)
	for bagID = 0, NUM_BAG_FRAMES do
		for slotID = 1, GetContainerNumSlots(bagID) do
			local button = self:GetButton(bagID, slotID)
			button:ClearAllPoints()
			button:Show()
			self.Active[#self.Active + 1] = button;
		end
	end
	self:LayoutSlots()
end

function BagContainer:LayoutSlots()
	local itemsPerRow = math.floor(Clamp(math.sqrt(#self.Active), 4, UIParent:GetHeight() / 64))

	local prevRow, prevCol;
	for i, button in ipairs(self.Active) do
		if not prevCol then
			button:SetPoint('TOPLEFT', self, 'TOPLEFT', 16, -16)
			prevCol = button;
		elseif i % itemsPerRow == 1 then
			button:SetPoint('TOPLEFT', prevCol, 'BOTTOMLEFT', 0, -4)
			prevCol = button;
		else
			button:SetPoint('LEFT', prevRow, 'RIGHT', 4, 0)
		end
		prevRow = button;
	end

	local rows = math.ceil(#self.Active / itemsPerRow);
	self:SetSize(
		(itemsPerRow * 37) + ((itemsPerRow - 1) * 4) + 32,
		(rows * 37) + ((rows - 1) * 4) + 32
	);
end


function BagContainer:GetSlotUpdateCriteria()
	return 
		GameTooltip:GetOwner(),                 -- tooltipOwner
		MerchantFrame:IsShown(),                -- atMerchant
		ContainerFrame_ShouldDoTutorialChecks() -- shouldDoTutorialChecks
end

function BagContainer:GetButton(bagID, slotID)
	if bagID and slotID then
		local index = (MAX_CONTAINER_ITEMS * bagID) + slotID;
		local button = self.Buttons[index];
		if not button and not self.inCombat then
			button = CreateFrame('ItemButton',
					('%sBag%dSlot%d'):format(_, bagID, slotID),
					self.Owners[bagID],'SecureActionButtonTemplate, ContainerFrameItemButtonTemplate')
			button:SetID(slotID)
			button:SetAttribute('type', 'item')
			button:SetAttribute('item', ('%d %d'):format(bagID, slotID))
			button:SetAttribute('bag',  bagID)
			button:SetAttribute('slot', slotID)
			Mixin(button, BagSlot)
			button:OnLoad()
			self.Buttons[index] = button;
		end
		return button;
	end
end

---------------------------------------------------------------
-- 
---------------------------------------------------------------
function BagContainer:BAG_UPDATE(bagID)
	local tooltipOwner, atMerchant, shouldDoTutorialChecks = self:GetSlotUpdateCriteria()
	for slotID = 1, MAX_CONTAINER_ITEMS do
		local button = self:GetButton(bagID, slotID)
		if button and button:IsShown() then
			button:Update(tooltipOwner, atMerchant, shouldDoTutorialChecks)
		end
	end
end

function BagContainer:BAG_UPDATE_DELAYED()
	if not self.initializedBackpack then
		self:BAG_UPDATE(0)
		self.initializedBackpack = true;
	end
end

function BagContainer:ITEM_LOCKED(...)
	local button = self:GetButton(...)
	if button then
		SetItemButtonDesaturated(button, true)
	end
end

function BagContainer:ITEM_UNLOCKED(...)
	local button = self:GetButton(...)
	if button then
		SetItemButtonDesaturated(button, false)
	end
end

function BagContainer:PLAYER_REGEN_ENABLED()
	self.inCombat = false;
end

function BagContainer:PLAYER_REGEN_DISABLED()
	self.inCombat = true;
end

---------------------------------------------------------------
-- 
---------------------------------------------------------------
function BagSlot:OnLoad()
	self.Cooldown = _G[self:GetName() .. 'Cooldown'];
	self.QuestTexture = _G[self:GetName() .. 'IconQuestTexture'];
	self:SetItemLocation(ItemLocation:CreateFromBagAndSlot(
		self:GetAttribute('bag'), self:GetAttribute('slot')
	));
end

function BagSlot:GetBagAndSlot()
	return self:GetItemLocation():GetBagAndSlot()
end

function BagSlot:Update(tooltipOwner, atMerchant, shouldDoTutorialChecks)
	local bagID, slotID = self:GetBagAndSlot()
	local texture, itemCount, locked, quality, readable, _, itemLink, isFiltered, noValue, itemID, isBound =
		GetContainerItemInfo(bagID, slotID);
	local isQuestItem, questId, isActive = GetContainerItemQuestInfo(bagID, slotID);

	SetItemButtonTexture(self, texture)

	local doNotSuppressOverlays = false;
	SetItemButtonQuality(self, quality, itemLink, doNotSuppressOverlays, isBound);

	SetItemButtonCount(self, itemCount);
	SetItemButtonDesaturated(self, locked);

	local questTexture = self.QuestTexture;
	local battlepayItemTexture = self.BattlepayItemTexture;
	local newItemTexture = self.NewItemTexture;
	local flash = self.flashAnim;
	local newItemAnim = self.newitemglowAnim;
	local junkIcon = self.JunkIcon;

	-- Update quest item texture overlay
	if questTexture then
		if ( questId and not isActive ) then
			questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG)
			questTexture:Show()
		elseif ( questId or isQuestItem ) then
			questTexture:SetTexture(TEXTURE_ITEM_QUEST_BORDER)
			questTexture:Show()
		else
			questTexture:Hide()
		end
	end

	-- Update new/shop item highlight
	if ( newItemTexture and battlepayItemTexture ) then
		local isNewItem = C_NewItems.IsNewItem(bagID, slotID)
		local isBattlePayItem = IsBattlePayItem(bagID, slotID)

		if ( isNewItem ) then
			if (isBattlePayItem) then
				newItemTexture:Hide()
				battlepayItemTexture:Show()
			else
				if (quality and NEW_ITEM_ATLAS_BY_QUALITY[quality]) then
					newItemTexture:SetAtlas(NEW_ITEM_ATLAS_BY_QUALITY[quality])
				else
					newItemTexture:SetAtlas('bags-glow-white')
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

	-- Update whether this item can be sold as junk
	if junkIcon then
		junkIcon:SetShown(atMerchant and not noValue
			and C_Item.DoesItemExist(self:GetItemLocation())
			and quality == Enum.ItemQuality.Poor
		);
	end

	if self.UpdateItemContextMatching then
		self:UpdateItemContextMatching()
	end

	if ( texture ) then
		ContainerFrame_UpdateCooldown(bagID, self)
		self.hasItem = 1;
	else
		self.Cooldown:Hide()
		self.hasItem = nil;
	end
	self.readable = readable;
	
	if ( self == tooltipOwner ) then
		if (texture) then
			self.UpdateTooltip(self)
		else
			GameTooltip:Hide()
		end
	end
	
	self:SetMatchesSearch(not isFiltered);
	if ( not isFiltered ) then
		if shouldDoTutorialChecks then
			if ContainerFrame_CheckItemButtonForTutorials(self, itemID) then
				shouldDoTutorialChecks = false;
			end
		end
	end
end