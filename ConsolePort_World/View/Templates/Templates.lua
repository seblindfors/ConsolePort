---------------------------------------------------------------
CPAnimatedLootHeaderMixin = {};
---------------------------------------------------------------

function CPAnimatedLootHeaderMixin:SetDurationMultiplier(multiplier)
	for _, animation in ipairs({self.HeaderOpenAnim:GetAnimations()}) do
		animation:SetDuration(animation:GetDuration() * multiplier)
	end
end

function CPAnimatedLootHeaderMixin:Play()
	self.HeaderOpenAnim:Stop()
	self.HeaderOpenAnim:Play()
end

function CPAnimatedLootHeaderMixin:SetText(...)
	self.Text:SetText(...)
end