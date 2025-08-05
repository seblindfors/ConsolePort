local env, db = CPAPI.GetEnv(...);

---------------------------------------------------------------
-- Settings Panel
---------------------------------------------------------------
-- This file defines the specifics to the Settings panel, which
-- runs off the main database and data provider.
--
---@see DataProvider.lua for what the settings panel contains.
---@see Elements.lua for the UI elements used in the settings panel.
---@see Panel.lua for how the settings panel is structured.
---@see Renderer.lua for how settings are rendered.

local Settings = env:CreatePanel({
	name = SETTINGS;
})

function Settings:OnInit()
	if not env:GetActiveDeviceAndMap() then
		self:SetEnabled(false)
		db:RegisterCallback('Gamepad/Active', function(self)
			self:SetEnabled(true)
			CPAPI.Next(db.UnregisterCallback, db, 'Gamepad/Active', self)
		end, self)
	end
end

function Settings:OnLoad()
	CPAPI.Start(self)
	self:Reindex()
	self:SetActiveCategory(GENERAL, self.index[SETTING_GROUP_SYSTEM][GENERAL])
	db:RegisterCallback('OnDependencyChanged', self.OnDependencyChanged, self)
	db:RegisterCallback('OnVariablesChanged', self.OnIndexChanged, self)
	db:RegisterCallback('Settings/useCharacterSettings', self.OnToggleCharacterSettings, self)
end

function Settings:OnDefaults()
	db:TriggerEvent('OnVariablesReset')
	CPAPI.Log('Settings have been reset to default.')
end

function Settings:OnToggleCharacterSettings(value)
	if self.toggleSettingsMutex then return end;
	self.toggleSettingsMutex = true;
	db:TriggerEvent('OnToggleCharacterSettings', value)
	self.toggleSettingsMutex = nil;
end