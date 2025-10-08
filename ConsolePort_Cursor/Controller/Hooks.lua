---------------------------------------------------------------
-- Hooks
---------------------------------------------------------------
-- Hooks for the interface cursor to do magic things.

local env, db, _, L = CPAPI.GetEnv(...)
local Hooks = db:Register('Hooks', {}, true); env.Hooks = Hooks;
local Hooknode = {};

function Hooks:OnNodeLeave()
	self.dressupItem,
	self.bagLocation,
	self.itemLocation,
	self.inventorySlotID,
	self.spellID = nil;
end


function Hooks:ProcessInterfaceCursorEvent(button, down, node)
	if down ~= false then return end;
	if self:IsCancelClick(button) then
		local cancelClickHandler = self:GetCancelClickHandler(node)
		if cancelClickHandler then
			cancelClickHandler(node, button, down)
			return true;
		end
	else
		local specialClickHandler = self:GetSpecialClickHandler(node)
		if specialClickHandler then
			specialClickHandler(node, button, down)
			return true;
		elseif node and node:IsObjectType('EditBox') then
			if node:HasFocus() then
				node:ClearFocus()
			else
				node:SetFocus()
			end
		elseif self.inventorySlotID then
			Hooknode.OnInventoryButtonModifiedClick(node, 'LeftButton')
			return true;
		elseif self.dressupItem then
			Hooknode.OnDressupButtonModifiedClick(node, 'LeftButton')
			return true;
		elseif self.itemLocation then
			db.ItemMenu:SetItem(self.itemLocation:GetBagAndSlot())
		elseif self.bagLocation then
			PickupBagFromSlot(self.bagLocation)
		elseif self.spellID then
			db.SpellMenu:SetSpell(self.spellID)
		elseif ConsolePort:HasPendingRingAction() then
			return ConsolePort:PostPendingRingAction()
		end
	end
end

function Hooks:ProcessInterfaceClickEvent(script, node)
	if (script == 'OnMouseUp') then
		if GetCursorInfo() then
			local isActionButton = (node:IsProtected() and node:GetAttribute('type') == 'action')
			local actionID = isActionButton and (node.CalculateAction and node:CalculateAction() or node:GetAttribute('action'))
			if actionID then
				PlaceAction(actionID)
				return true;
			end
		elseif self:IsModifiedClick() then
			-- HACK: identify a container slot button
			if (node.UpdateTooltip and node.UpdateTooltip == ContainerFrameItemButton_OnUpdate) then
				Hooknode.OnContainerButtonModifiedClick(node, 'LeftButton')
				return true;
			end
		end
	end
end

function Hooks:IsModifiedClick()
	return next(db.Gamepad:GetModifiersHeld()) ~= nil;
end

function Hooks:IsCancelClick(button)
	return button == db('UICursorCancel');
end

function Hooks:GetSpecialClickHandler(node)
	return node and (node.OnSpecialClick or node:GetAttribute(env.Attributes.SpecialClick));
end

function Hooks:GetCancelClickHandler(node)
	return node and (node.OnCancelClick or node:GetAttribute(env.Attributes.CancelClick));
end


---------------------------------------------------------------
-- Special handling for container item buttons
---------------------------------------------------------------
do  local IsWidget, GetID, GetParent, GetScript =
		C_Widget.IsFrameWidget, UIParent.GetID, UIParent.GetParent, UIParent.GetScript;

	local TryIdentifyContainerSlot = CPAPI.IsRetailVersion and function(node)
		return node.GetSlotAndBagID == ContainerFrameItemButtonMixin.GetSlotAndBagID;
	end or function(node)
		-- Since the classic container slot buttons are hard to identify by script or inheritance,
		-- we have to rely on some reasonably unique property for identification.
		return not not node.JunkIcon and not not node.SplitStack;
	end

	local TryIdentifyContainerBag = function(node)
		return GetScript(node, 'OnEnter') == ContainerFramePortraitButton_OnEnter and GetID(node) ~= 0;
	end

	function Hooks:GetItemLocationFromNode(node)
		return IsWidget(node) and TryIdentifyContainerSlot(node) and
			(CPAPI.IsRetailVersion and ItemLocation:CreateFromBagAndSlot(node:GetBagID(), node:GetID()) or
			ItemLocation:CreateFromBagAndSlot(GetID(GetParent(node)), GetID(node))) or nil;
	end

	function Hooks:GetBagLocationFromNode(node)
		return IsWidget(node) and TryIdentifyContainerBag(node) and
			CPAPI.ContainerIDToInventoryID(node:GetID());
	end
end

---------------------------------------------------------------
-- Prompts
---------------------------------------------------------------
function Hooks:IsPromptProcessingValid(node)
	return not InCombatLockdown()
		and db.Cursor:IsCurrentNode(node)
		and not node:GetAttribute(env.Attributes.DisableHooks)
end

function Hooks:GetSpecialActionPrompt(text)
	local device = db('Gamepad/Active')
	return device and device:GetTooltipButtonPrompt(
		db('Settings/UICursorSpecial'),
		L(text), 64
	);
end

function Hooks:GetRightActionPrompt(text)
	local device = db('Gamepad/Active')
	return device and device:GetTooltipButtonPrompt(
		db('Settings/UICursorRightClick'),
		L(text), 64
	);
end

function Hooks:SetPendingItemMenu(tooltip, itemLocation)
	self.itemLocation = itemLocation;
	local prompt = self:GetSpecialActionPrompt(OPTIONS)
	if prompt then
		tooltip:AddLine(prompt)
		tooltip:Show()
	end
end

function Hooks:SetUseItemPrompt(tooltip, text)
	local prompt = self:GetRightActionPrompt(text)
	if prompt then
		tooltip:AddLine(prompt)
		tooltip:Show()
	end
end

function Hooks:SetSellItemPrompt(tooltip, itemLocation)
	local bagID, slotID = itemLocation:GetBagAndSlot()
	if bagID and slotID then
		if ( CPAPI.GetContainerItemInfo(bagID, slotID).hasNoValue == false ) then
			local prompt = self:GetRightActionPrompt(L'Sell')
			if prompt then
				tooltip:AddLine(prompt)
				tooltip:Show()
			end
		end
	end
end

function Hooks:SetPendingSpellMenu(tooltip, spellID)
	self.spellID = spellID;
	local prompt = self:GetSpecialActionPrompt(OPTIONS)
	if prompt then
		tooltip:AddLine(prompt)
		tooltip:Show()
	end
end

function Hooks:SetPendingBagPickup(tooltip, bagLocation)
	self.bagLocation = bagLocation;
	local prompt = self:GetSpecialActionPrompt(L'Pickup')
	if prompt then
		tooltip:AddLine(prompt)
		tooltip:Show()
	end
end

function Hooks:SetPendingActionToUtilityRing(tooltip, owner, action)
	if owner.ignoreUtilityRing then
		return
	end

	self.pendingAction = action;
	if ConsolePort:SetPendingRingAction(1, action) then
		if tooltip then
			local prompt = self:GetSpecialActionPrompt('Add to Utility Ring')
			if prompt then
				tooltip:AddLine(prompt)
				tooltip:Show()
			end
		end
	else
		local _, existingIndex = ConsolePort:IsUniqueRingAction(1, action)
		if existingIndex then
			ConsolePort:SetPendingRingRemove(1, action)
			if tooltip then
				local prompt = self:GetSpecialActionPrompt('Remove from Utility Ring')
				if prompt then
					tooltip:AddLine(prompt)
					tooltip:Show()
				end
			end
		end
	end
end

function Hooks:SetPendingDressupItem(tooltip, item)
	self.dressupItem = item;
	if tooltip then
		local prompt = self:GetSpecialActionPrompt(INSPECT)
		if prompt then
			tooltip:AddLine(prompt)
			tooltip:Show()
		end
	end
end

function Hooks:SetPendingInspectItem(tooltip, item)
	if tonumber(item) then
		self.inventorySlotID = item;
		if tooltip then
			local prompt = self:GetSpecialActionPrompt(('%s / %s'):format(INSPECT, ARTIFACTS_PERK_TAB or SOCKET_GEMS))
			if prompt then
				tooltip:AddLine(prompt)
				tooltip:Show()
			end
		end
		return
	end
end


do -- Tooltip hooking
	local function OnTooltipSetItem(self)
		local owner = self:GetOwner()
		if Hooks:IsPromptProcessingValid(owner) then
			if Hooks:GetSpecialClickHandler(owner) then return end;

			local itemLocation = Hooks:GetItemLocationFromNode(owner)
			local _, link, itemID = self:GetItem()

			if itemLocation then
				if CPAPI.IsMerchantAvailable then
					Hooks:SetSellItemPrompt(self, itemLocation)
				elseif itemID and CPAPI.IsEquippableItem(itemID) then
					Hooks:SetUseItemPrompt(self, EQUIPSET_EQUIP or USE)
				elseif itemID and CPAPI.IsUsableItem(itemID) then
					Hooks:SetUseItemPrompt(self, USE)
				end
				return Hooks:SetPendingItemMenu(self, itemLocation)
			end

			local bagLocation = Hooks:GetBagLocationFromNode(owner)
			if bagLocation then
				return Hooks:SetPendingBagPickup(self, bagLocation)
			end

			if not link then return end;
			local numOwned     = CPAPI.GetItemCount(link)
			local isEquipped   = CPAPI.IsEquippedItem(link)
			local isEquippable = CPAPI.IsEquippableItem(link)
			local isDressable  = CPAPI.IsDressableItemByID(link)
			local isMount      = itemID and CPAPI.GetMountFromItem(itemID)

			if ( CPAPI.GetItemSpell(link) and numOwned > 0 ) then
				Hooks:SetPendingActionToUtilityRing(self, owner, {
					type = 'item';
					item = link;
					link = link;
				});
			elseif isEquippable and isEquipped then
				Hooks:SetPendingInspectItem(self, owner:GetID())
			elseif ( isEquippable and not isEquipped ) or isDressable or isMount then
				Hooks:SetPendingDressupItem(self, link);
			end
		end
	end

	local function OnTooltipSetSpell(self)
		local owner = self:GetOwner()
		if Hooks:IsPromptProcessingValid(owner) then
			if Hooks:GetSpecialClickHandler(owner) then return end;

			local name, spellID = self:GetSpell()
			if spellID and not CPAPI.IsPassiveSpell(spellID) then
				local isKnown = IsSpellKnownOrOverridesKnown(spellID) or IsPlayerSpell(spellID)
				if not isKnown then
					local mountID = CPAPI.GetMountFromSpell(spellID)
					if mountID then
						isKnown = (select(11, CPAPI.GetMountInfoByID(mountID)))
					end
				end
				if isKnown then
					Hooks:SetPendingSpellMenu(self, spellID)
				end
			end
		end
	end

	local function OnTooltipSetMount(self, info)
		local owner = self:GetOwner()
		if Hooks:IsPromptProcessingValid(owner) then
			local spellID = select(2, CPAPI.GetMountInfoByID(info.id))
			local isKnown = select(11, CPAPI.GetMountInfoByID(info.id))
			if isKnown and spellID then
				Hooks:SetPendingSpellMenu(self, spellID)
			end
		end
	end

	local function OnTooltipSetToy(self, info)
		local owner = self:GetOwner()
		if Hooks:IsPromptProcessingValid(owner) then
			local itemID = type(info) == 'table' and info.id;
			if itemID and CPAPI.PlayerHasToy(itemID) then
				local itemInfo = CPAPI.GetItemInfo(itemID)
				Hooks:SetPendingActionToUtilityRing(self, owner, {
					type = 'item';
					item = itemInfo.itemLink;
					link = itemInfo.itemLink;
				});
			end
		end
	end

	local function OnTooltipSetItemLine(self, line)
		if self:IsForbidden() then return end;
		local owner = self:GetOwner()
		if Hooks:IsPromptProcessingValid(owner) and Hooks:GetBagLocationFromNode(owner) then
			if (line.leftText or ''):match('^<') then
				line.leftText = Hooks:GetRightActionPrompt(line.leftText) or line.leftText;
			end
		end
	end

	if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Mount, OnTooltipSetMount)
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, OnTooltipSetSpell)
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, OnTooltipSetToy)
		TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataType.Item, OnTooltipSetItemLine)
	end
	if not CPAPI.IsRetailVersion then -- TooltipDataProcessor exists on Cata but is not used
		GameTooltip:HookScript('OnTooltipSetItem', OnTooltipSetItem)
		GameTooltip:HookScript('OnTooltipSetSpell', OnTooltipSetSpell)
	end

	GameTooltip:HookScript('OnShow', function(self)
		local owner = self:GetOwner()
		if Hooks:IsPromptProcessingValid(owner) then
			-- Prevent tooltip from following mouse cursor if UI cursor triggered the tooltip
			if (self:GetAnchorType() == 'ANCHOR_CURSOR') then
				self:SetAnchorType('ANCHOR_TOPLEFT')
				self:Show()
			end
		end
	end)

	GameTooltip:HookScript('OnHide', function()
		if Hooks.pendingAction then
			ConsolePort:ClearPendingRingAction()
			Hooks.pendingAction = nil;
		end
	end)
end

---------------------------------------------------------------
-- Node
---------------------------------------------------------------
local function WrappedExecute(func, execEnv, ...)
	local fenv = getfenv(func)
	setfenv(func, setmetatable(execEnv, {__index = fenv}))
	func(...)
	setfenv(func, fenv)
end

function Hooknode:OnContainerButtonModifiedClick(...)
	WrappedExecute(ContainerFrameItemButton_OnModifiedClick, {
		IsModifiedClick = function(action)
			return db.Gamepad:GetModifierHeld(GetModifiedClick(action))
		end;
	}, self, ...)
end

function Hooknode:OnDressupButtonModifiedClick()
	WrappedExecute(HandleModifiedItemClick, {
		IsModifiedClick = function(action)
			if (action == 'CHATLINK') then
				return false;
			elseif (action == 'DRESSUP') then
				return true;
			end
		end;
	}, Hooks.dressupItem)
	Hooks.dressupItem = nil;
end

function Hooknode:OnInventoryButtonModifiedClick()
	WrappedExecute(PaperDollItemSlotButton_OnModifiedClick, {
		IsModifiedClick = function(action)
			if (action == 'EXPANDITEM') then
				return true;
			end
		end;
	}, self)

	local isArtifact = GetInventoryItemQuality('player', self:GetID()) == Enum.ItemQuality.Artifact;
	local isSocketUI = GetSocketItemInfo();

	if not isSocketUI and not isArtifact then
		WrappedExecute(HandleModifiedItemClick, {
			IsModifiedClick = function(action)
				if (action == 'CHATLINK') then
					return false;
				elseif (action == 'DRESSUP') then
					return true;
				end
			end;
		}, GetInventoryItemLink('player', self:GetID()))
	end
end