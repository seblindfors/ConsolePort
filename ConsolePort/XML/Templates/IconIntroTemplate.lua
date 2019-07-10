---------------------------------------------------------------
-- Animated action button placement
---------------------------------------------------------------
-- Used to animate new actions placed on the action bar, from
-- cursor pickups and automatic spell push. 

CPIconIntroMixin = {}

function CPIconIntroMixin:CalculatePathOffset(path, x, y)
	local first, second = path:GetControlPoints()
	first:SetOffset(x / 4, y / 2)
	second:SetOffset(x, y)
end

function CPIconIntroMixin:AnimateNewActionFromCoords(button, coordX, coordY, actionID, actionTex)
	local hilite = button:GetHighlightTexture()
	if hilite then
		local glow = self.glow
		glow:ClearAllPoints()
		glow:SetPoint('CENTER', 0, 0)
		glow:SetSize(hilite:GetSize())
		glow:SetTexture(hilite:GetTexture())
		glow:SetTexCoord(hilite:GetTexCoord())
		glow:SetBlendMode(hilite:GetBlendMode())
	end

	local main = self.icon
	main.icon:SetTexture(actionTex)
	main.action = actionID

	self:ClearAllPoints()
	self:SetPoint('CENTER', button, 0, 0)
	self:SetFrameLevel(button:GetFrameLevel() + 1)

	local tX, tY = button:GetCenter()
	local w = button:GetWidth() or 0
	local oX, oY = (coordX - ( tX or 0) ) + w, (coordY - ( tY or 0))

	for path in pairs(self.paths) do
		self:CalculatePathOffset(path, oX, oY)
	end

	main.flyin:Play(1)
	self.isFree = false
end


CPIconIntroFlyinAnimMixin = {}

function CPIconIntroFlyinAnimMixin:OnAnimPlay()
	local iconFrame = self:GetParent()
	iconFrame.bg:SetTexture(iconFrame.icon:GetTexture())

	local trail = iconFrame.trail
	if trail then
		trail:Show()
		trail.flyin:Stop()
		trail.icon:SetTexture(iconFrame.icon:GetTexture())
		trail.flyin:Play(1)
		if iconFrame.isBase then
			trail:SetFrameLevel(iconFrame:GetFrameLevel()-1)
		else
			trail:SetFrameLevel(iconFrame:GetFrameLevel())
		end
	end

	if iconFrame.isBase then
		iconFrame:GetParent():Show()
		if iconFrame.glow:IsPlaying() then
			iconFrame.glow:Stop()
		end
	end
end

function CPIconIntroFlyinAnimMixin:OnAnimFinished()
	local iconFrame = self:GetParent()
	if iconFrame.isBase then
		iconFrame.glow:Play()
		iconFrame.isFree = true
	else
		iconFrame:SetFrameLevel(1)
	end
end