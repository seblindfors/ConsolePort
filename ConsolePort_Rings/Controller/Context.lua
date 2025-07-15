local env, db, Context = CPAPI.GetEnv(...); Context = env.Frame;
---------------------------------------------------------------
CPAPI.Specialize(Context, CPTimedButtonContextMixin)
---------------------------------------------------------------

function Context:OnTimedHintsDisplay(enabled, remaining)
	local handle = db.UIHandle:ToggleHintFocus(self, enabled)
	local button = self:GetValidAcceptButton()
	if not enabled or not button then return end;
	local hint = handle:AddHint(button, EDIT)
	hint:SetTimer(remaining)
end

function Context:OnTimedContextTrigger(button)
	env:TriggerEvent('ToggleConfig', self:GetSetID(self:GetAttribute('state')))
	env:TriggerEvent('OnSelectTab', 2) -- Loadout
	self:Run([[ self::Disable() ]])
end

function Context:IsTimedContextValid()
	return not InCombatLockdown() and self.maxInputLen < .1;
end

function Context:GetTimeUntilHints()
	return 1;
end

function Context:GetTimeUntilTrigger()
	return 2.5;
end