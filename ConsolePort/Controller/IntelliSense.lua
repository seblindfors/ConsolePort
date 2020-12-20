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
		db.Mouse:ClearCenteredCursor()
	end
end

function Intellisense:OnNodeLeave()
	self.dressupItem = nil;
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
			if (node.UpdateTooltip == ContainerFrameItemButton_OnUpdate) then
				Intellinode.OnContainerButtonModifiedClick(node, 'LeftButton')
				return true;
			end
		end
	end
end

function Intellisense:IsModifiedClick()
	return next(db.Gamepad:GetModifiersHeld()) ~= nil;
end

function Intellisense:GetSpecialActionPrompt(text)
	local device = db('Gamepad/Active')
	return device and device:GetTooltipButtonPrompt(
		db('Settings/UICursorSpecial'),
		L(text), 64
	);
end

function Intellisense:SetPendingActionToUtilityRing(action, tooltip)
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

function Intellisense:SetPendingDressupItem(item, tooltip)
	self.dressupItem = item;
	if tooltip then
		local prompt = self:GetSpecialActionPrompt(INSPECT)
		if prompt then
			tooltip:AddLine(prompt)
			tooltip:Show()
		end
	end
end

function Intellisense:SetPendingInspectItem(item, tooltip)
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
	if not InCombatLockdown() and db.Cursor:IsCurrentNode(self:GetOwner()) then

		local name, link = self:GetItem()
		local numOwned = GetItemCount(link)
		local isEquipped = IsEquippedItem(link)
		local isEquippable = IsEquippableItem(link)

		if ( GetItemSpell(link) and numOwned > 0 ) then
			Intellisense:SetPendingActionToUtilityRing(
				{type = 'item', item = link, link = link}, self);
		elseif isEquippable and not isEquipped then
			Intellisense:SetPendingDressupItem(link, self);
		elseif isEquippable and isEquipped then
			Intellisense:SetPendingInspectItem(self:GetOwner():GetID(), self)
		end
	end
end)

GameTooltip:HookScript('OnTooltipSetSpell', function(self)
	if not InCombatLockdown() and db.Cursor:IsCurrentNode(self:GetOwner()) then
		local name, spellID = self:GetSpell()
		if spellID and not IsPassiveSpell(spellID) then
			local isKnown = IsSpellKnown(spellID)
			if not isKnown then
				local mountID = C_MountJournal.GetMountFromSpell(spellID)
				if mountID then
					isKnown = (select(11, C_MountJournal.GetMountInfoByID(mountID)))
					spellID = name;
				end
			end
			if isKnown then
				Intellisense:SetPendingActionToUtilityRing(
					{type = 'spell', spell = spellID, link = GetSpellLink(spellID)}, self)
			end
		end
	end
end)

GameTooltip:HookScript('OnHide', function(self)
	db.Utility:ClearPendingAction()
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