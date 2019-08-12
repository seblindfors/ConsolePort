local _, db = ...
---------------------------------------------------------------
ConsolePortMenuButtonMixin = CreateFromMixins(ConsolePortActionButtonMixin)
---------------------------------------------------------------

function ConsolePortMenuButtonMixin:OnEnter()
	self:LockHighlight()

	if self:GetAttribute('hintOnEnter') then
		self:ShowHints()
	end
	if self.Hilite.flashTimer then
		db.UIFrameFlashStop(self.Hilite, self.Hilite:GetAlpha())
	end
	db.UIFrameFadeIn(self.Hilite, 0.15, self.Hilite:GetAlpha(), 1)
	if self.OnEnterHook then
		self:OnEnterHook()
	end
end

function ConsolePortMenuButtonMixin:OnLeave()
	self:UnlockHighlight()

	if self:GetAttribute('hintOnLeave') then
		self:HideHints()
	end
	db.UIFrameFadeOut(self.Hilite, 0.2, self.Hilite:GetAlpha(), 0)
	if self.OnLeaveHook then
		self:OnLeaveHook()
	end
end

function ConsolePortMenuButtonMixin:SetPulse(enabled)
	if enabled then db.UIFrameFlash(self.Hilite, 0.5, 0.5, -1, true, 0.2, 0.1)
	else db.UIFrameFlashStop(self.Hilite, 0) end
end

---------------------------------------------------------------

function ConsolePortMenuButtonMixin:ShowHints()
	local hints  = self.ControlHints
	local handle = self.ControlHandle
	if not hints or not handle then return end
	----------------------------
	-- add hints in order of lookup declaration
	for key in ConsolePort:IterateUIControlKeys() do
		local hint = hints[key]
		if hint then
			handle:AddHint(key, hint)
		end
	end
end

function ConsolePortMenuButtonMixin:HideHints()
	local hints  = self.ControlHints
	local handle = self.ControlHandle
	if not hints or not handle then return end
	----------------------------
	for key in pairs(hints) do
		handle:RemoveHint(key)
	end
end

function ConsolePortMenuButtonMixin:SetHint(handle, key, text)
	assert(handle, 'ConsolePortMenuButtonMixin: invalid control handle')
	assert(key,    'ConsolePortMenuButtonMixin: invalid control key')
	assert(text,   'ConsolePortMenuButtonMixin: invalid control text')
	self.ControlHints = self.ControlHints or {}
	self.ControlHints[key] = text
	self.ControlHandle = handle
end

function ConsolePortMenuButtonMixin:SetHintTriggers(onEnter, onLeave, onShow, onHide)
	self:SetAttribute('hintOnEnter', onEnter)
	self:SetAttribute('hintOnLeave', onLeave)
	self:SetAttribute('hintOnShow', onShow)
	self:SetAttribute('hintOnHide', onHide)
end

---------------------------------------------------------------