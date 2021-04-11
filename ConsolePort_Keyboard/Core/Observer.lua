local Keyboard, GetCurrentKeyBoardFocus, bitbor = ConsolePortKeyboard, GetCurrentKeyBoardFocus, bit.bor;
local IsShiftKeyDown, IsControlKeyDown, IsAltKeyDown = IsShiftKeyDown, IsControlKeyDown, IsAltKeyDown;
CreateFrame('Frame'):SetScript('OnUpdate', function(self, elapsed)
	local focus = GetCurrentKeyBoardFocus()
	if focus ~= self.focusFrame then
		self.focusFrame = focus;
		Keyboard:OnFocusChanged(focus)
	end
	Keyboard:SetState(1 + bitbor(
		IsShiftKeyDown()   and 0x1 or 0,
		IsControlKeyDown() and 0x2 or 0,
		IsAltKeyDown()     and 0x4 or 0)
	);
end)