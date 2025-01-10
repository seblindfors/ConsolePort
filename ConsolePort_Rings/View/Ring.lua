local env, db = CPAPI.GetEnv(...)
---------------------------------------------------------------
local Ring = ConsolePortUtilityToggle; env.Frame = Ring;
---------------------------------------------------------------

function Ring:OnSizeChanged()
	local width, height = self:GetSize()
	self.BgRunes:SetSize(width * 0.8, height * 0.8)
	self.StickySlice:UpdateSize(width, height)
end

function Ring:OnStickyIndexChanged()
	local hasStickySelection = self:GetAttribute('stickyIndex')
	self.StickySlice:SetShown(hasStickySelection)
	if hasStickySelection then
		self.StickySlice:SetAlpha(1)
		self.StickySlice:SetIndex(hasStickySelection)
	end
end

Ring:SetScript('OnSizeChanged', Ring.OnSizeChanged)
Ring:HookScript('OnShow', Ring.OnStickyIndexChanged)
env:AddLoader(function(self)
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

	if self:GetAttribute('stickyIndex') then
		self.StickySlice:SetAlpha(Clamp(1 - len, 0, 1))
	end
end

function Ring:GetTooltipRemovePrompt()
	if self:GetAttribute('removeButtonBlocked') then return end;
	return env:GetTooltipPrompt(REMOVE, self:GetAttribute('removeButton'));
end

function Ring:GetTooltipUsePrompt()
	return env:GetTooltipPrompt(USE, self:GetAttribute('trigger'))
end

function Ring:OnSelection(running)
	if running then
		self.ReportData = {};
	else
		db:TriggerEvent('OnUtilityRingSelectionChanged', self.ReportData)
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