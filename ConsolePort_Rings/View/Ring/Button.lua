local env = CPAPI.GetEnv(...)
---------------------------------------------------------------
-- Display button mixin
---------------------------------------------------------------
local Button, ActionButton = env.DisplayButton, env.ActionButton;

function Button:OnLoad()
	self:SetPreventSkinning(true)
	self:Initialize()
	self:SetScript('OnHide', self.OnClear)
	self:SetScript('OnShow', self.UpdateLocal)
	self:SetRotation(self.rotation or 0)
	self.icon.SetTexture = ActionButton.SkinUtility.SetTexture;
	self:Skin()
end

function Button:SetFocused(focused)
	self.isFocused = focused;
end

function Button:IsFocused()
	return self.isFocused;
end

function Button:GetStateType()
	return self._state_type;
end

function Button:GetStateAction()
	return self._state_action;
end

function Button:IsCustomType()
	return not not self.RunCustom; -- see LAB
end

function Button:IsOwned(parent)
	return self:GetParent() == parent;
end

---------------------------------------------------------------
-- Button events
---------------------------------------------------------------
Button.Skin = ActionButton.Skin.UtilityRingButton;

function Button:OnFocus()
	self:LockHighlight()
	if not self:IsFocused() then
		self:SetFocused(true)
		self:OnFocusSet()
	end
end

function Button:OnFocusSet()
	if not self:IsCustomType() then
		self:SetFocusTooltip()
	end
	env:TriggerEvent('OnButtonFocus', self, true)
end

function Button:OnClear()
	self:SetFocused(false)
	self:UnlockHighlight()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
	env:TriggerEvent('OnButtonFocus', self, false)
end

function Button:UpdateLocal()
	self:SetFocused(false)
	self:SetRotation(self.rotation or 0)
	self:Skin()
	RunNextFrame(function()
		env:TriggerEvent('OnButtonUpdated', self)
		local spellId = self:GetSpellId()
		if spellId and CPAPI.IsSpellOverlayed(spellId) then
			self:ShowOverlayGlow()
		else
			self:HideOverlayGlow()
		end
	end)
end

---------------------------------------------------------------
-- Button data
---------------------------------------------------------------
function Button:SetFocusTooltip()
	if GameTooltip:IsOwned(self) then
		return;
	end
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	self:SetTooltip()
	if self.disableHints then return end;

	local use = env.Frame:GetTooltipUsePrompt()
	local remove = env.Frame:GetTooltipRemovePrompt()
	if use then
		GameTooltip:AddLine(use)
	end
	if ( remove and remove ~= use ) then
		GameTooltip:AddLine(remove)
	end
	GameTooltip:Show()
end

function Button:GetActiveText()
	if self:IsCustomType() then
		return self:GetStateAction().text;
	end
	return self.Name:GetText()
end