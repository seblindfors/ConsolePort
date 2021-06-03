local Keyboard, GetCurrentKeyBoardFocus, bitbor = ConsolePortKeyboard, GetCurrentKeyBoardFocus, bit.bor;
local IsShiftKeyDown, IsControlKeyDown, IsAltKeyDown = IsShiftKeyDown, IsControlKeyDown, IsAltKeyDown;
local Observer, _, env = CreateFrame('Frame'), ...;

function Observer:UpdateFocus()
	local focus = self.forceFrame;
	if focus == nil then
		focus = GetCurrentKeyBoardFocus()
	end

	local valid = focus and not focus:GetAttribute('hidekeyboard');
	local changed = focus ~= self.focusFrame;
	if changed then
		self.focusFrame = focus;
	end

	return focus, changed, valid;
end

function Observer:OnUpdate(elapsed)
	local focus, changed, valid = self:UpdateFocus()
	if changed then
		Keyboard:OnFocusChanged(valid and focus)
	end
	if not valid or not Keyboard:IsShown() then return end
	Keyboard:SetState(1 + bitbor(
		IsShiftKeyDown()   and 0x1 or 0,
		IsControlKeyDown() and 0x2 or 0,
		IsAltKeyDown()     and 0x4 or 0)
	);
	local text, pos = focus:GetText(), focus:GetUTF8CursorPosition()
	if text ~= self.focusText or pos ~= self.focusPos then
		self.focusText, self.focusPos = text, pos;
		Keyboard:OnTextChanged(text, pos)
	end
end

function Keyboard:ForceFocus(frame)
	Observer.forceFrame = frame;
end

function env:ToggleObserver(enabled)
	Observer:SetScript('OnUpdate', enabled and Observer.OnUpdate or nil)
	if not enabled then
		Observer.focusFrame = nil;
	end
end