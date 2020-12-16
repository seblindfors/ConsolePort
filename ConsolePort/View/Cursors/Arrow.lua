---------------------------------------------------------------
-- Spinny cursor arrow
---------------------------------------------------------------
local RAD_ARROW_ROTATION, RAD_MOD, RAD_RESET = rad(45), rad(360), rad(180);
local Node, IsGamePadInUse, IsGamePadCursor =
	ConsolePortNode, IsGamePadFreelookEnabled, IsGamePadCursorControlEnabled;

CPCursorArrowMixin = {};

function CPCursorArrowMixin:SetRotation(rotation)
	self.rotation = rotation < 0 and RAD_MOD + rotation or rotation % RAD_MOD;
	self.Arrow:SetRotation(rotation)
	self.ArrowHilite:SetRotation(rotation)
end

function CPCursorArrowMixin:ResetRotation(rotation, elapsed)
	local delta = rotation < RAD_RESET and 1 or -1;
	self:SetRotation(rotation + delta * ((RAD_ARROW_ROTATION - rotation) / (self.resetAngleSpeed - elapsed)))
end

function CPCursorArrowMixin:SetDeltaRotation(delta)
	self:SetRotation(self.rotation + delta)
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
			self:SetRotation(rad((math.atan2(nY - cY, nX - cX) * 180 / math.pi) - 90))
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