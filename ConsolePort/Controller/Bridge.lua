---------------------------------------------------------------
-- Bridge
---------------------------------------------------------------
-- Context-aware bridge module for other internal modules,
-- processing based on multiple factors in an isolated sandbox.

local _, db = ...; local L = db.Locale;
local Bridge = db:Register('Bridge', {})


function Bridge:ProcessInterfaceCursorEvent(button, down, node)
	if ( down == false ) and db.Utility:HasPendingAction() then
		return db.Utility:PostPendingAction()
	end
end

function Bridge:GetSpecialActionPrompt(text)
	local device = db('Gamepad/Active')
	return device and device:GetTooltipButtonPrompt(
		db('Settings/UICursor/Special'),
		L(text), 64
	);
end

function Bridge:SetPendingActionToUtilityRing(action, tooltip)
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

GameTooltip:HookScript('OnTooltipSetItem', function(self)
	if not InCombatLockdown() and db.Cursor:IsCurrentNode(self:GetOwner()) then
		local name, link = self:GetItem()
		if ( GetItemSpell(link) and GetItemCount(link) > 0 ) then
			Bridge:SetPendingActionToUtilityRing({type = 'item', item = link, link = link}, self);
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
				Bridge:SetPendingActionToUtilityRing({type = 'spell', spell = spellID, link = GetSpellLink(spellID)}, self)
			end
		end
	end
end)

GameTooltip:HookScript('OnHide', function(self)
	db.Utility:ClearPendingAction()
end)