---------------------------------------------------------------
-- Intellisense
---------------------------------------------------------------
-- Context-aware bridge module for other internal modules,
-- processing based on multiple factors in an isolated sandbox.

local _, db = ...; local L = db.Locale;
local Intellisense = db:Register('Intellisense', {})
local Intellinode = {};

function Intellisense:OnHintsFocus()
	if db('mouseHandlingEnabled') then
		db.Mouse:SetCameraControl()
	end
end

function Intellisense:OnNodeLeave()
	self.dressupItem = nil;
	self.bagLocation = nil;
	self.itemLocation = nil;
	self.inventorySlotID = nil;
end

db:RegisterCallback('OnHintsFocus', Intellisense.OnHintsFocus, Intellisense)

function Intellisense:ProcessInterfaceCursorEvent(button, down, node)
	if (down == false) then
		if node and node:IsObjectType('EditBox') then
			if node:HasFocus() then
				node:ClearFocus()
			else
				node:SetFocus()
			end
		elseif self.inventorySlotID then
			Intellinode.OnInventoryButtonModifiedClick(node, 'LeftButton')
			return true;
		elseif self.dressupItem then
			Intellinode.OnDressupButtonModifiedClick(node, 'LeftButton')
			return true;
		elseif self.itemLocation then
			db.ItemMenu:SetItem(self.itemLocation:GetBagAndSlot())
		elseif self.bagLocation then
			PickupBagFromSlot(self.bagLocation)
		elseif db.Utility:HasPendingAction() then
			return db.Utility:PostPendingAction()
		end
	end
end

function Intellisense:ProcessInterfaceClickEvent(script, node)
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
				Intellinode.OnContainerButtonModifiedClick(node, 'LeftButton')
				return true;
			end
		end
	end
end

function Intellisense:IsModifiedClick()
	return next(db.Gamepad:GetModifiersHeld()) ~= nil;
end


---------------------------------------------------------------
-- Special handling for container item buttons
---------------------------------------------------------------
do  local IsWidget, GetID, GetParent, GetScript =
		C_Widget.IsFrameWidget, UIParent.GetID, UIParent.GetParent, UIParent.GetScript;

	local TryIdentifyContainerSlot = CPAPI.IsRetailVersion and function(node)
		return node.UpdateTooltip == ContainerFrameItemButton_OnUpdate;
	end or function(node)
		return node.UpdateTooltip == ContainerFrameItemButton_OnEnter;
	end

	local TryIdentifyContainerBag = function(node)
		return GetScript(node, 'OnEnter') == ContainerFramePortraitButton_OnEnter and GetID(node) ~= 0;
	end

	function Intellisense:GetItemLocationFromNode(node)
		return IsWidget(node) and TryIdentifyContainerSlot(node) and
			ItemLocation:CreateFromBagAndSlot(GetID(GetParent(node)), GetID(node)) or nil;
	end

	function Intellisense:GetBagLocationFromNode(node)
		return IsWidget(node) and TryIdentifyContainerBag(node) and
			ContainerIDToInventoryID(node:GetID());
	end
end

---------------------------------------------------------------
-- Prompts
---------------------------------------------------------------
function Intellisense:GetSpecialActionPrompt(text)
	local device = db('Gamepad/Active')
	return device and device:GetTooltipButtonPrompt(
		db('Settings/UICursorSpecial'),
		L(text), 64
	);
end

function Intellisense:SetPendingItemMenu(tooltip, itemLocation)
	self.itemLocation = itemLocation;
	local prompt = self:GetSpecialActionPrompt(OPTIONS)
	if prompt then
		tooltip:AddLine(prompt)
		tooltip:Show()
	end
end

function Intellisense:SetPendingBagPickup(tooltip, bagLocation)
	self.bagLocation = bagLocation;
	local prompt = self:GetSpecialActionPrompt(L'Pickup')
	if prompt then
		tooltip:AddLine(prompt)
		tooltip:Show()
	end
end

function Intellisense:SetPendingActionToUtilityRing(tooltip, action)
	self.pendingAction = action;
	if db.Utility:SetPendingAction(1, action) then
		if tooltip then
			local prompt = self:GetSpecialActionPrompt('Add to Utility Ring')
			if prompt then
				tooltip:AddLine(prompt)
				tooltip:Show()
			end
		end
	else
		local _, existingIndex = db.Utility:IsUniqueAction(1, action)
		if existingIndex then
			db.Utility:SetPendingRemove(1, action)
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

function Intellisense:SetPendingDressupItem(tooltip, item)
	self.dressupItem = item;
	if tooltip then
		local prompt = self:GetSpecialActionPrompt(INSPECT)
		if prompt then
			tooltip:AddLine(prompt)
			tooltip:Show()
		end
	end
end

function Intellisense:SetPendingInspectItem(tooltip, item)
	if tonumber(item) then
		self.inventorySlotID = item;
		if tooltip then
			local prompt = self:GetSpecialActionPrompt(('%s / %s'):format(INSPECT, SOCKET_GEMS))
			if prompt then
				tooltip:AddLine(prompt)
				tooltip:Show()
			end
		end
		return
	end
end

GameTooltip:HookScript('OnTooltipSetItem', function(self)
	local owner = self:GetOwner()
	if not InCombatLockdown() and db.Cursor:IsCurrentNode(owner) then
		local itemLocation = Intellisense:GetItemLocationFromNode(owner)
		if itemLocation then
			return Intellisense:SetPendingItemMenu(self, itemLocation)
		end

		local bagLocation = Intellisense:GetBagLocationFromNode(owner)
		if bagLocation then
			return Intellisense:SetPendingBagPickup(self, bagLocation)
		end

		local name, link = self:GetItem()
		local numOwned = GetItemCount(link)
		local isEquipped = IsEquippedItem(link)
		local isEquippable = IsEquippableItem(link)

		if ( GetItemSpell(link) and numOwned > 0 ) then
			Intellisense:SetPendingActionToUtilityRing(self, {
				type = 'item',
				item = link,
				link = link
			});
		elseif isEquippable and not isEquipped then
			Intellisense:SetPendingDressupItem(self, link);
		elseif isEquippable and isEquipped then
			Intellisense:SetPendingInspectItem(self, self:GetOwner():GetID())
		end
	end
end)

GameTooltip:HookScript('OnTooltipSetSpell', function(self)
	if not InCombatLockdown() and db.Cursor:IsCurrentNode(self:GetOwner()) then
		local name, spellID = self:GetSpell()
		if spellID and not IsPassiveSpell(spellID) then
			local isKnown = IsSpellKnown(spellID)
			if not isKnown then
				local mountID = CPAPI.GetMountFromSpell(spellID)
				if mountID then
					isKnown = (select(11, CPAPI.GetMountInfoByID(mountID)))
					spellID = name;
				end
			end
			if isKnown then
				Intellisense:SetPendingActionToUtilityRing(self, {
					type  = 'spell',
					spell = spellID,
					link  = GetSpellLink(spellID)
				});
			end
		end
	end
end)

GameTooltip:HookScript('OnHide', function(self)
	if self.pendingAction then
		db.Utility:ClearPendingAction()
		self.pendingAction = nil;
	end
end)

---------------------------------------------------------------
-- Node
---------------------------------------------------------------
local function WrappedExecute(func, execEnv, ...)
	local env = getfenv(func)
	setfenv(func, setmetatable(execEnv, {__index = env}))
	func(...)
	setfenv(func, env)
end

function Intellinode:OnContainerButtonModifiedClick(...)
	WrappedExecute(ContainerFrameItemButton_OnModifiedClick, {
		IsModifiedClick = function(action)
			return db.Gamepad:GetModifierHeld(GetModifiedClick(action))
		end;
	}, self, ...)
end

function Intellinode:OnDressupButtonModifiedClick()
	WrappedExecute(HandleModifiedItemClick, {
		IsModifiedClick = function(action)
			if (action == 'CHATLINK') then
				return false;
			elseif (action == 'DRESSUP') then
				return true;
			end
		end;
	}, Intellisense.dressupItem)
	Intellisense.dressupItem = nil;
end

function Intellinode:OnInventoryButtonModifiedClick()
	WrappedExecute(PaperDollItemSlotButton_OnModifiedClick, {
		IsModifiedClick = function(action)
			if (action == 'EXPANDITEM') then
				return true;
			end
		end;
	}, self)
	if not GetSocketItemInfo() then
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