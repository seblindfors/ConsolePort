CPMenuButtonMixin = CreateFromMixins(CPThreeSliceSmoothButtonMixin, CPLargeIconButtonMixin, CPHintFocusMixin);

function CPMenuButtonMixin:OnLoad()
	self:UpdateButton()
	self:SetHintHandle(ConsolePortUIHandle)
	self:SetHintTriggers(true)
end

function CPMenuButtonMixin:OnEnter()
	--CPSmoothButtonMixin.OnEnter(self)
	if self:GetAttribute('hintOnEnter') then
		self:ShowHints()
	end
end

function CPMenuButtonMixin:OnLeave()
	--CPSmoothButtonMixin.OnLeave(self)
	if self:GetAttribute('hintOnLeave') then
		self:HideHints()
	end
end