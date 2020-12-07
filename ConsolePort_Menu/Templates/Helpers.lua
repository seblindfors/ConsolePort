local _, env = ...; env.db = ConsolePort:DB();

CPLineSheenMixin = {}

function CPLineSheenMixin:SetDirection(direction, multiplier)
	assert(type(direction) == 'string', 'LineGlow:SetDirection("LEFT" or "RIGHT", multiplier)');
	assert(type(multiplier) == 'number', 'LineGlow:SetDirection("LEFT" or "RIGHT", multiplier)');
	if direction == 'LEFT' then
		self.OnShowAnim.LineSheenTranslation:SetOffset(-230 * multiplier, 0)
	elseif direction == 'RIGHT' then
		self.OnShowAnim.LineSheenTranslation:SetOffset(230 * multiplier, 0)
	end
end

function CPLineSheenMixin:OnShow()
	self.OnShowAnim:Play()
end

function CPLineSheenMixin:OnHide()
	self.OnShowAnim:Stop()
end