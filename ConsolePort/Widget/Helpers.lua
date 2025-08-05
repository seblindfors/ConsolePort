local db = select(2, ...)
---------------------------------------------------------------
-- Gradient mixin
---------------------------------------------------------------
CPGradientMixin = {};

function CPGradientMixin:OnLoad()
	self.VertexColor  = CPAPI.GetClassColorObject()
	self.VertexValid  = CreateColor(1, .81, 0, 1)
	self.VertexOrient = 'VERTICAL';
end

function CPGradientMixin:SetGradientDirection(direction)
	assert(direction == 'VERTICAL' or direction == 'HORIZONTAL', 'Valid: VERTICAL, HORIZONTAL')
	self.VertexOrient = direction;
end

function CPGradientMixin:GetClassColor()
	return self.VertexColor:GetRGB()
end

function CPGradientMixin:GetValidColor()
	return self.VertexColor:GetRGB()
end

function CPGradientMixin:GetMixGradient(...)
	return CPAPI.GetReverseMixColorGradient(self.VertexOrient, ...)
end

function CPGradientMixin:GetReverseMixGradient(...)
	return CPAPI.GetMixColorGradient(self.VertexOrient, ...)
end

function CPGradientMixin:GetFadeGradient(...)
	return self.VertexOrient, 1, 1, 1, 0, ...;
end

---------------------------------------------------------------
-- Specific button catcher with callbacks
---------------------------------------------------------------
CPButtonCatcherMixin = {};

function CPButtonCatcherMixin:OnLoad()
	self.ClosureRegistry = {};
end

function CPButtonCatcherMixin:OnGamePadButtonDown(button)
	if not self.catcherPaused then
		if self.catchAllCallback and self:IsButtonValid(button) then
			self.catchAllCallback(button)
			return self:SetPropagateKeyboardInput(false)
		elseif self.ClosureRegistry[button] then
			self.ClosureRegistry[button](button)
			return self:SetPropagateKeyboardInput(false)
		end
	end
	self:SetPropagateKeyboardInput(true)
end

function CPButtonCatcherMixin:OnKeyDown(button)
	local emulatedButton = self:GetButtonEmulation(button)
	if emulatedButton and not self.catcherPaused then
		if self.catchAllCallback and self:IsButtonValid(emulatedButton) then
			self.catchAllCallback(emulatedButton)
			return self:SetPropagateKeyboardInput(false)
		elseif self.ClosureRegistry[emulatedButton] then
			self.ClosureRegistry[emulatedButton](emulatedButton)
			return self:SetPropagateKeyboardInput(false)
		end
	end
	self:SetPropagateKeyboardInput(true)
end

function CPButtonCatcherMixin:OnHide()
	self:ReleaseClosures()
end

function CPButtonCatcherMixin:CatchAll(callback, ...)
	self.catchAllCallback = GenerateClosure(callback, ...)
	self:ToggleInputs(true)
	return true;
end

function CPButtonCatcherMixin:CatchButton(button, callback, ...)
	if not button then return end;
	local closure = GenerateClosure(callback, ...)
	self.ClosureRegistry[button] = closure;
	self:ToggleInputs(true)
	return closure; -- return the event owner
end

function CPButtonCatcherMixin:FreeButton(button, ...)
	if not button then return end;
	if select('#', ...) > 0 then
		local closure = ...;
		if closure and (self.ClosureRegistry[button] ~= closure) then
			return false; -- assert event owner if supplied
		end
	end
	self.ClosureRegistry[button] = nil;
	if not next(self.ClosureRegistry) then
		self:ToggleInputs(false)
	end
	return true;
end

function CPButtonCatcherMixin:PauseCatcher()
	self.catcherPaused = true;
end

function CPButtonCatcherMixin:ResumeCatcher()
	self.catcherPaused = false;
end

function CPButtonCatcherMixin:ReleaseClosures()
	self.catchAllCallback = nil;
	self:ToggleInputs(false)
	if self.ClosureRegistry then
		wipe(self.ClosureRegistry)
	end
end

function CPButtonCatcherMixin:ToggleInputs(enabled)
	self:EnableGamePadButton(enabled)
	self:EnableKeyboard(enabled)
end

function CPButtonCatcherMixin:GetButtonEmulation(button)
	return db.Paddles:GetEmulatedButton(button)
end

function CPButtonCatcherMixin:IsButtonValid(button)
	return CPAPI.IsButtonValidForBinding(button)
end

---------------------------------------------------------------
-- Propagation mixin
---------------------------------------------------------------
CPPropagationMixin = {};

function CPPropagationMixin:SetPropagation(enabled)
	if not InCombatLockdown() then
		self:SetPropagateKeyboardInput(enabled)
	end
end

---------------------------------------------------------------
-- Combat hide mixin
---------------------------------------------------------------
CPCombatHideMixin = {};

function CPCombatHideMixin:OnLoad()
	self:SetScript('OnEvent', CPCombatHideMixin.OnEvent)
end

function CPCombatHideMixin:OnShow()
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	if InCombatLockdown() then
		CPCombatHideMixin.OnEvent(self, 'PLAYER_REGEN_DISABLED')
	end
end

function CPCombatHideMixin:OnHide()
	self:UnregisterEvent('PLAYER_REGEN_DISABLED')
end

function CPCombatHideMixin:OnEvent(event)
	if event == 'PLAYER_REGEN_DISABLED' then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		self:Hide()
	elseif event == 'PLAYER_REGEN_ENABLED' then
		self:UnregisterEvent('PLAYER_REGEN_ENABLED')
		self:Show()
	end
end


---------------------------------------------------------------
-- Timed button context
---------------------------------------------------------------
CPTimedButtonContextMixin = {
	TimeUntilHints   = 0.25;
	TimeUntilTrigger = 1.5;
};

function CPTimedButtonContextMixin:OnLoad()
	-- optional: timed context can be started manually.
	self:HookScript('OnClick', self.OnTimedContext)
end

function CPTimedButtonContextMixin:OnTimedContext(button, enable)
	if self.displayHints then
		self:OnTimedHintsDisplay(false, 0, button)
	end
	self.displayHints  = nil;
	self.contextTimer  = enable and 0 or nil;
	self.contextButton = enable and button or nil;
	if enable then
		self.prevOnUpdate = self:GetScript('OnUpdate')
		self:SetScript('OnUpdate', self.OnTimedContextUpdate)
	else
		self:SetScript('OnUpdate', self.prevOnUpdate)
		self.prevOnUpdate = nil;
	end
end

function CPTimedButtonContextMixin:OnTimedContextUpdate(elapsed)
	if self.prevOnUpdate then
		self.prevOnUpdate(self, elapsed)
	end
	if not self:IsTimedContextValid(elapsed) then
		return self:OnTimedContext(self.contextButton, false)
	end
	self.contextTimer = self.contextTimer + elapsed;

	local button, timeUntilTrigger = self.contextButton, self:GetTimeUntilTrigger();
	if self.contextTimer > timeUntilTrigger then
		self:OnTimedContext(button, false)
		self:OnTimedContextTrigger(button)
	elseif not self.displayHints and self.contextTimer > self:GetTimeUntilHints() then
		self.displayHints = true;
		self:OnTimedHintsDisplay(true, timeUntilTrigger - self.contextTimer, button)
	end
end

function CPTimedButtonContextMixin:IsTimedContextValid(elapsed)
	return true; -- override: return false to cancel the context
end

function CPTimedButtonContextMixin:GetTimeUntilHints()
	return 0.25; -- override: display hints after this time
end

function CPTimedButtonContextMixin:GetTimeUntilTrigger()
	return 1.5; -- override: trigger the context after this time
end

function CPTimedButtonContextMixin:OnTimedHintsDisplay(enabled, remaining, button)
	-- override: display any hints
end

function CPTimedButtonContextMixin:OnTimedContextTrigger(button)
	-- override: trigger the context
end

---------------------------------------------------------------
-- Self-handling binding slug
---------------------------------------------------------------
CPSlugMixin = {
	limit     = 3;         -- limit the amount of slugs displayed
	separator = ' | ';     -- separator between slugs
	notBound  = NOT_BOUND; -- text to display when not bound
};

function CPSlugMixin:OnShow()
	db:RegisterCallback('OnNewBindings', self.OnBindingChanged, self)
	self:OnBindingChanged()
end

function CPSlugMixin:OnHide()
	db:UnregisterCallback('OnNewBindings', self)
end

function CPSlugMixin:SetBinding(binding)
	self.binding = binding;
	self:OnBindingChanged()
end

function CPSlugMixin:GetBinding()
	return self.binding;
end

function CPSlugMixin:OnBindingChanged()
	if not self.binding then return self:SetText(NOT_APPLICABLE) end;
	local slug = db.Hotkeys:GetButtonSlugsForBinding(self.binding, self.separator, self.limit)
	self:SetText((slug:len() > 0 and slug) or self.notBound)
end