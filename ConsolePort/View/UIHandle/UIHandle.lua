local _, db = ...;
local Control = db:Register('UIHandle', ConsolePortUIHandle);

----------------------------------
-- Hint bar
----------------------------------
-- The bar appears at the bottom of the screen and displays
-- button function hints local to the focused frame.
-- Hints are controlled from the UI modules.
-- Although hints are cached for each frame in the stack,
-- the hint control will set a new hint to the current focus
-- frame, regardless of where the function call comes from.
-- Explicitly hiding a stack frame clears its hint cache.

Control.KeyIDToBindingMap = setmetatable({
    CROSS    = 'PAD1',
    CIRCLE   = 'PAD2',
    SQUARE   = 'PAD3',
    TRIANGLE = 'PAD4',
    UP       = 'PADDUP',
    DOWN     = 'PADDDOWN',
    LEFT     = 'PADDLEFT',
    RIGHT    = 'PADDRIGHT',
    SHARE    = 'PADSOCIAL',
    OPTIONS  = 'PADFORWARD',
    CENTER   = 'PADSYSTEM',
}, {
	__index = function(self, key)
		if (key == nil) then return end;
		if (key == 'M1') then
			local var = GetCVar('GamePadEmulateShift')
			return (var and var ~= 'none') and var;
		elseif (key == 'M2') then
			local var = GetCVar('GamePadEmulateCtrl')
			return (var and var ~= 'none') and var;
		elseif (key == 'T1' or key == 'T2') then
			local id = tonumber(key:match('%d'))
			local preferredKeys = {
				[1] = {
					'PADLSHOULDER';
					'PADRSHOULDER';
					'PADLTRIGGER';
					'PADRTRIGGER';
				};
				[2] = {
					'PADRTRIGGER';
					'PADLTRIGGER';
					'PADRSHOULDER';
					'PADLSHOULDER';
				};
			}
			local keysForID = preferredKeys[id]
			if keysForID then
				for _, preference in ipairs(keysForID) do
					local isValid = true;
					for _, mod in ipairs(db.Gamepad.Modsims) do
						if GetCVar('GamepadEmulate'..mod) == preference then
							isValid = false;
						end
					end
					if isValid then
						return preference;
					end
				end
			end
		elseif IsBindingForGamePad(key) then
			return key;
		end
	end;
})

db:Register('KEY', Control.KeyIDToBindingMap)

function Control:GetUIControlBinding(key)
	return self.KeyIDToBindingMap[key];
end

-- Compatibility layer
Control.ShowUI = nop;
Control.HideUI = nop;

----------------------------------
-- Hint control
----------------------------------
Control.StoredHints = {}

function Control:SetHintFocus(forceFrame, disableMouseHandling)
	self.HintBar.focus = forceFrame or self:GetAttribute('focus')
	self.focus = self.HintBar.focus;
	db:TriggerEvent('OnHintsFocus', self.focus, disableMouseHandling)
end

function Control:GetHintFocus()
	return self.focus;
end

function Control:IsHintFocus(frame)
	return (self.focus == frame);
end

function Control:ClearHintsForFrame(forceFrame)
	self.StoredHints[forceFrame or self:GetAttribute('remove')] = nil
end

function Control:RestoreHints()
	if self.focus then
		local storedHints = self.StoredHints[self.HintBar.focus]
		if storedHints then
			self:ResetHintBar()
			for key, info in pairs(storedHints) do
				self:AddHint(key, info.text)
				if not info.enabled then
					self:SetHintDisabled(key)
				end
			end
		end
	end
end

function Control:HideHintBar()
	self:ResetHintBar()
	self.HintBar:Hide()
	db:TriggerEvent('OnHintsClear', self.focus)
end

function Control:ResetHintBar()
	self.HintBar:Reset()
end

function Control:RegisterHintForFrame(frame, key, text, enabled)
	self.StoredHints[frame] = self.StoredHints[frame] or {}
	self.StoredHints[frame][key] = {text = text, enabled = enabled}
end

function Control:UnregisterHintForFrame(frame, key)
	if self.StoredHints[frame] then
		self.StoredHints[frame][key] = nil
	end
end

function Control:AddHint(key, text)
	local binding = self:GetUIControlBinding(key)
	if binding then
		local hint = self.HintBar.focus and self.HintBar:GetHintFromPool(key, true)
		if hint then
			hint:SetData(binding, text)
			hint:Enable()
			self:RegisterHintForFrame(self.focus, key, text, true)
			return hint
		end
	end
end

function Control:RemoveHint(key)
	local hint = self:GetHintForKey(key)
	if hint then
		self:UnregisterHintForFrame(self.focus, key)
		hint:Hide()
	end
end

function Control:GetHintForKey(key)
	local hint = self.HintBar:GetActiveHintForKey(key)
	if hint then
		return hint, hint:GetText()
	end
end

function Control:SetHintDisabled(key)
	local hint = self:GetHintForKey(key)
	if hint then
		hint:Disable()
		self:RegisterHintForFrame(self.focus, key, hint:GetText(), false)
	end
end

function Control:SetHintEnabled(key)
	local hint = self:GetHintForKey(key)
	if hint then
		hint:Enable()
		self:RegisterHintForFrame(self.focus, key, hint:GetText(), true)
	end
end


Control.Background = CreateFrame('Frame', nil, Control.HintBar, 'CPToolbarSixSliceFrame')
Control.Background:SetAlpha(0.5)
Control.Background:SetPoint('TOPLEFT', Control.HintBar, 'TOPLEFT', -32, 0)
Control.Background:SetPoint('BOTTOMRIGHT', Control.HintBar, 'BOTTOMRIGHT', 32, 0)