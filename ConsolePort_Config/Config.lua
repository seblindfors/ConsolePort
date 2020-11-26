local _, env = ...; local db = env.db;
local Config = CPAPI.EventHandler(ConsolePortConfig, {
	'PLAYER_REGEN_ENABLED',
	'PLAYER_REGEN_DISABLED'
}); env.Config = Config;

function Config:OnActiveDeviceChanged()
	local hasActiveDevice = db('Gamepad/Active') and true or false;
	self.Header:ToggleEnabled(hasActiveDevice)
end

function Config:OnDataLoaded()
	db:TriggerEvent('OnConfigLoaded', self, env)
end

function Config:TryClose()
	for panel in self:EnumerateActive() do
		local valid, callback = panel:Validate()
		if not valid then
			return CPAPI.Popup('ConsolePort_Config_Unsaved_Changes', {
				-- HACK: something, something, unsaved changes. good enough. :)
				text = CONFIRM_COMPACT_UNIT_FRAME_PROFILE_UNSAVED_CHANGES:format(panel.name);
				button1 = SAVE_CHANGES;
				button2 = CANCEL;
				whileDead = 1;
				showAlert = 1;
				OnHide = function()
					self:TryClose()
				end;
				OnAccept = function()
					callback(panel)
					self:TryClose()
				end;
			})
		end
	end
	self:Hide()
end

function Config:ShowAfterCombat()
	self.showAfterCombat = true;
	CPAPI.Log(env.L('Your gamepad configuration will reappear when you leave combat.'))
	self:Hide()
end

function Config:OnShow()
	if InCombatLockdown() then
		return self:ShowAfterCombat()
	end
	self:OnActiveDeviceChanged()
end

function Config:PLAYER_REGEN_DISABLED()
	if self:IsShown() then
		self:ShowAfterCombat()
	end
end

function Config:PLAYER_REGEN_ENABLED()
	if self.showAfterCombat then
		self.showAfterCombat = nil;
		db('Alpha/FadeIn')(self, 1)
		self:Show()
	end
end

db:RegisterCallback('Gamepad/Active', Config.OnActiveDeviceChanged, Config)