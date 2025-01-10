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
	ActionButton.Skin.UtilityRingButton(self)
end

function Button:OnFocus()
	self:LockHighlight()
	self:GetParent():SetActiveSliceText(self.Name:GetText())
	if GameTooltip:IsOwned(self) then
		return;
	end
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	self:SetTooltip()
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

function Button:OnClear()
	self:UnlockHighlight()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
	self:GetParent():SetActiveSliceText(nil)
end

function Button:UpdateLocal()
	self:SetRotation(self.rotation or 0)
	ActionButton.Skin.UtilityRingButton(self)
	RunNextFrame(function()
		self:GetParent():SetSliceText(self:GetID(), self.Name:GetText())
		local spellId = self:GetSpellId()
		if spellId and CPAPI.IsSpellOverlayed(spellId) then
			self:ShowOverlayGlow()
		else
			self:HideOverlayGlow()
		end
	end)
end