local env, db = CPAPI.GetEnv(...)
---------------------------------------------------------------
local Ring = ConsolePortUtilityToggle; env.Frame = Ring;
---------------------------------------------------------------

function Ring:OnSizeChanged()
	local width, height = self:GetSize()
	self.BgRunes:SetSize(width * 0.8, height * 0.8)
	self.StickySlice:UpdateSize(width, height)
end

function Ring:OnDisplay()
	self.maxInputLen = 0;
	self:OnStickyIndexChanged()
end

function Ring:OnStickyIndexChanged()
	self.stickyIndex = self:GetCurrentMetadataValue(env.Attributes.Sticky)
	local enableStickySlice = self.stickySelect and self.stickyIndex;
	self.StickySlice:SetShown(enableStickySlice)
	if enableStickySlice then
		self.StickySlice:SetAlpha(1)
		self.StickySlice:SetIndex(self.stickyIndex, self:GetAttribute('size'))
	end
end

Ring:SetScript('OnSizeChanged', Ring.OnSizeChanged)
Ring:HookScript('OnShow', Ring.OnDisplay)
env:AddLoader(function(self)
	self.maxInputLen = 0;
	self.StickySlice:Hide()
	self:RegisterColorCallbacks()
	self:UpdateColorSettings()
	if CPAPI.IsRetailVersion then
		self.BgRunes:SetAtlas('heartofazeroth-orb-activated')
	else
		self.BgRunes:SetAtlas('ChallengeMode-RuneBG')
	end
end)

---------------------------------------------------------------
-- Frontend
---------------------------------------------------------------
local Clamp = Clamp;

function Ring:OnInput(x, y, len)
	local size  = self:GetAttribute('size')
	local obj   = self:SetFocusByIndex(self:GetIndexForPos(x, y, len, size))
	local valid = self:IsValidThreshold(len)
	local rot   = self:ReflectStickPosition(self.axisInversion * x, self.axisInversion * y, len, valid)
	self:SetAnimations(obj, rot, len)

	self.maxInputLen = max(self.maxInputLen, len)
	if self.stickyIndex then
		self.StickySlice:SetAlpha(Clamp(1 - len, 0, 1))
	end
end

function Ring:GetTooltipRemovePrompt()
	if self:GetAttribute(env.Attributes.RemoveBlocked) then return end;
	return env:GetTooltipPrompt(REMOVE, self:GetAttribute(env.Attributes.RemoveButton));
end

function Ring:GetTooltipUsePrompt()
	return env:GetTooltipPrompt(USE, self:GetValidAcceptButton());
end

function Ring:GetValidAcceptButton()
	return   self:GetAttribute(env.Attributes.TriggerButton)
	or ( not self:GetAttribute(env.Attributes.AcceptBlocked)
	     and self:GetAttribute(env.Attributes.AcceptButton) );
end

function Ring:OnSelection(running)
	if running then
		self.ReportData = {};
	else
		env:TriggerEvent('OnSelectionChanged', self.ReportData)
		self.ReportData = nil;
	end
end

function Ring:OnSelectionAttributeAdded(attribute, value)
	self.ReportData[attribute] = value;
end

---------------------------------------------------------------
-- Animations
---------------------------------------------------------------
function Ring:SetAnimations(obj, rot, len)
	local pulse = Clamp(len, 0.05, 0.25)

	self.PulseAnim.PulseIn:SetFromAlpha(pulse / 2)
	self.PulseAnim.PulseIn:SetToAlpha(pulse)
	self.PulseAnim.PulseOut:SetToAlpha(pulse / 2)
	self.PulseAnim.PulseOut:SetFromAlpha(pulse)
end

Ring:HookScript('OnHide', function(self)
	self:SetAnimations(nil, 0, 0)
	self:SetSliceTextAlpha(1)
end)

---------------------------------------------------------------
-- Announcements
---------------------------------------------------------------
local Messages, MessageCount = {}, 0;

function Ring:AnnounceAddition(link, set, force)
	local slug = self:GetButtonSlugForSet(set or 'LeftButton')
	if MessageCount > 10 then
		wipe(Messages)
		MessageCount = 0;
	end
	local messageID = self:GetBindingSuffixForSet(set) .. link;
	local messageIsNew = not Messages[messageID];
	if force or messageIsNew then
		CPAPI.Log('%s was added to your utility ring. Use: %s', link, slug or NOT_BOUND)
		Messages[messageID] = true;
		if messageIsNew then
			MessageCount = MessageCount + 1;
		end
	end
end

function Ring:AnnounceRemoval(link, set)
	CPAPI.Log('%s was removed from your utility ring.', link)
	local messageID = self:GetBindingSuffixForSet(set) .. link;
	if Messages[messageID] then
		Messages[messageID] = nil;
		MessageCount = MessageCount - 1;
	end
end

---------------------------------------------------------------
-- Callbacks
---------------------------------------------------------------
env:RegisterCallback('OnButtonFocus', function(self, button, focused)
	if not button:IsOwned(self) then return end;
	if focused then
		if button:IsCustomType() then
			self:SetSliceTextAlpha(0)
		else
			self:SetActiveSliceText(button:GetActiveText())
		end
	else
		self:SetActiveSliceText(nil)
		self:SetSliceTextAlpha(1)
	end
end, Ring)

env:RegisterCallback('OnButtonUpdated', function(self, button)
	if not button:IsOwned(self) then return end;
	self:SetSliceText(button:GetID(), button:GetActiveText())
end, Ring)