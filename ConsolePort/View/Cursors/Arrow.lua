---------------------------------------------------------------
-- Spinny cursor arrow
---------------------------------------------------------------
local RAD_ARROW_ROTATION, RAD_MOD, RAD_RESET = rad(45), rad(360), rad(180);
local Clamp, Node, IsGamePadInUse, IsGamePadCursor =
	Clamp, ConsolePortNode, IsGamePadFreelookEnabled, IsGamePadCursorControlEnabled;

CPCursorArrowMixin = {};

function CPCursorArrowMixin:SetRotation(rotation)
	self.rotation = rotation < 0 and RAD_MOD + rotation or rotation % RAD_MOD;
	self.ArrowNormal:SetRotation(rotation)
	self.ArrowHilite:SetRotation(rotation)
end

function CPCursorArrowMixin:ResetRotation(rotation, elapsed)
	self.timeUntilReset = Clamp((self.timeUntilReset or 0.2) - elapsed, -1, 0.2)
	if self.timeUntilReset < 0 then
		local delta = rotation < RAD_RESET and 1 or -1;
		self:SetRotation(rotation + delta * ((RAD_ARROW_ROTATION - rotation) / (self.resetAngleSpeed - elapsed)))
	end
end

function CPCursorArrowMixin:SetAngledRotation(rotation)
	self.timeUntilReset = 0.2;
	self:SetRotation(rotation)
end

function CPCursorArrowMixin:SetSize(size)
	self.ArrowNormal:SetSize(size, 18/22 * size)
	self.ArrowHilite:SetSize(size, 18/22 * size)
end

function CPCursorArrowMixin:SetOffset(value)
	self.ArrowNormal:SetPoint('TOPLEFT', value, -value)
	self.ArrowHilite:SetPoint('TOPLEFT', value, -value)
end

function CPCursorArrowMixin:OnUpdate(elapsed)
	local divisor  = self.animationSpeed - elapsed;
	local parent   = self:GetParent()

	parent.Blocker:SetShown(IsGamePadInUse() and not IsGamePadCursor())

	local cX, cY = self:GetLeft(), self:GetTop()
	local nX, nY = Node.GetCenter(parent)

	self:ClearAllPoints()
	if cX and cY and nX and nY then
		-- TODO: handle scale differences
		local diff = Node.GetDistance(cX, cY, nX, nY)
		if (  diff < 1 ) then
			self:ResetRotation(self.rotation, elapsed)
		else
			self:SetAngledRotation(rad((math.atan2(nY - cY, nX - cX) * 180 / math.pi) - 90))
		end
		self.ArrowHilite:SetAlpha(diff)
		self:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT',
			cX + ((nX - cX) / divisor),
			cY + ((nY - cY) / divisor)
		);
	elseif nX and nY then
		self:SetPoint('TOPLEFT', self:GetParent(), 'CENTER', nX, nY)
	end
end

function CPCursorArrowMixin:OnHide()
	self:GetParent().Blocker:Hide()
end

function CPCursorArrowMixin:OnShow()
	self.Group:Stop()
	self.Group:Play()
end

function CPCursorArrowMixin:OnLoad()
	self.animationSpeed  = 8;
	self.resetAngleSpeed = 16;
	self:SetRotation(RAD_ARROW_ROTATION)
end