---------------------------------------------------------------
-- Mouse cursor blocker to eliminate hidden motion scripts
---------------------------------------------------------------
local _, db = ...;
local IsGamePadFreelookEnabled = IsGamePadFreelookEnabled;
local IsGamePadCursorControlEnabled = IsGamePadCursorControlEnabled;
local IsUsingGamepad, IsUsingMouse = IsUsingGamepad, IsUsingMouse;
local CVar_CenterY, tonumber = db.Data.Cvar('CursorCenteredYPos'), tonumber;
local GetScaledCursorPosition, GetScreenWidth, GetScreenHeight =
	GetScaledCursorPosition, GetScreenWidth, GetScreenHeight;

CPCursorBlockerMixin = {};

function CPCursorBlockerMixin:OnLoad()
	self.BlockingFrame:Hide()
	self.BlockingFrame:SetParent(nil)
	self.BlockingFrame:SetAllPoints()
	self.BlockingFrame:SetFrameStrata('TOOLTIP')
	self.BlockingFrame:EnableMouse(true)
	self.throttledTimer = 0;
end

function CPCursorBlockerMixin:OnHide()
	self.BlockingFrame:Hide()
end

function CPCursorBlockerMixin:IsCenterPositioned()
	local c = tonumber(CVar_CenterY:Get())
	local x, y = GetScaledCursorPosition()
	local w, h = GetScreenWidth(), GetScreenHeight()
	return floor(w / 2) == floor(x) and floor(h * c) == floor(y);
end

if IsUsingGamepad and IsUsingMouse then
	function CPCursorBlockerMixin:ShouldBlockCursor()
		return not IsUsingMouse()
			and IsUsingGamepad()
			and IsGamePadFreelookEnabled()
			and not IsGamePadCursorControlEnabled()
	end

	function CPCursorBlockerMixin:OnUpdate()
		self.BlockingFrame:SetShown(self:ShouldBlockCursor())
	end
else
	function CPCursorBlockerMixin:ShouldBlockCursor()
		return IsGamePadFreelookEnabled()
			and not IsGamePadCursorControlEnabled()
			and self.isCenterPositioned;
	end

	function CPCursorBlockerMixin:OnUpdate(elapsed)
		self.BlockingFrame:SetShown(self:ShouldBlockCursor())
		self.throttledTimer = self.throttledTimer + elapsed;
		if self.throttledTimer > .1 then
			self.isCenterPositioned = self:IsCenterPositioned()
			self.throttledTimer = 0;
		end
	end
end