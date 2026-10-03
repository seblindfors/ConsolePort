---------------------------------------------------------------
-- Modules
---------------------------------------------------------------
-- Registry of the load-on-demand modules. The addon list is the
-- only record of whether a module is enabled; enabled modules are
-- loaded when the core has finished loading and whenever they are
-- switched on; a loaded module can only be turned off by reloading
-- the interface.
--
-- This file is loaded last in the core so that the handler frame
-- is created after every other core frame; loading a module fires
-- a nested ADDON_LOADED, which must not reach core handlers that
-- are still waiting for their own.

local Modules, _, db = CPAPI.CreateEventHandler({'Frame', '$parentModules', ConsolePort}), ...;
local L = db.Locale;
db:Register('Modules', Modules)

Modules.Registry = {
	{	id       = 'Bar';
		addon    = 'ConsolePort_Bar';
		name     = 'Action Bar';
		desc     = 'Replaces the default action bars with a layout designed for gamepad play.';
		presets  = {
			{ id = 'Default';         name = DEFAULT };
			{ id = 'CrossbarMinimal'; name = 'Crossbar: Minimal' };
			{ id = 'CrossbarTriple';  name = 'Crossbar: Triple' };
		};
	};
	{	id       = 'Menu';
		addon    = 'ConsolePort_Menu';
		name     = 'Menus';
		desc     = 'Item, spell and unit menus for the interface cursor, plus an optional game menu replacement.';
	};
	{	id       = 'Rings';
		addon    = 'ConsolePort_Rings';
		name     = 'Rings';
		desc     = 'Utility rings for spells, items and macros, selected with the radial stick.';
	};
	{	id       = 'Target';
		addon    = CPAPI.TargetAddOn;
		name     = 'Target';
		desc     = 'Targeting tools: raid cursor, unit hotkeys and the target ring.';
	};
	{	id       = 'Cursor';
		addon    = CPAPI.CursorAddOn;
		name     = 'Interface Cursor';
		desc     = 'Navigate the interface with the gamepad using a virtual cursor.';
	};
	{	id       = 'World';
		addon    = 'ConsolePort_World';
		name     = 'World';
		desc     = 'World interaction helpers: quick menu, loot frame and temporary ability prompts.';
	};
	{	id       = 'Keyboard';
		addon    = 'ConsolePort_Keyboard';
		name     = 'Keyboard';
		desc     = 'Radial on-screen keyboard for typing with the gamepad.';
	};
};

---------------------------------------------------------------
-- API
---------------------------------------------------------------
function Modules:Enumerate()
	return ipairs(self.Registry)
end

function Modules:GetInfo(entry)
	return L(entry.name), L(entry.desc);
end

function Modules:IsEnabled(entry)
	local state = CPAPI.GetAddOnEnableState(entry.addon)
	return state ~= nil and state > 0;
end

function Modules:IsInstalled(entry)
	return (select(4, CPAPI.GetAddOnInfo(entry.addon))) ~= nil;
end

function Modules:IsLoaded(entry)
	return CPAPI.IsAddOnLoaded(entry.addon)
end

function Modules:SetEnabled(entry, enabled)
	if enabled then
		CPAPI.EnableAddOn(entry.addon)
	else
		CPAPI.DisableAddOn(entry.addon)
	end
	self:OnEnableChanged(entry, not not enabled)
end

function Modules:Load(entry)
	if self:IsLoaded(entry) then return true end;
	local loaded, reason = CPAPI.LoadAddOn(entry.addon)
	if not loaded then
		CPAPI.Log('Failed to load %s. Reason: %s\nPlease check your installation.',
			(entry.addon:gsub('_', ' ')), _G['ADDON_'..tostring(reason)])
	end
	return loaded;
end

function Modules:PromptReload(entry)
	CPAPI.Popup('ConsolePort_Module_Reload', {
		text      = L('%s will be disabled the next time the interface is reloaded.', (self:GetInfo(entry)));
		button1   = RELOADUI;
		button2   = CANCEL;
		timeout   = 0;
		showAlert = 1;
		OnAccept  = ReloadUI;
	})
end

function Modules:OnEnableChanged(entry, enabled)
	if enabled then
		db:RunSafe(self.Load, self, entry)
	elseif self:IsLoaded(entry) then
		self:PromptReload(entry)
	end
end

---------------------------------------------------------------
-- Demand
---------------------------------------------------------------
-- Registrations that live inside a module. A call site that needs
-- one asks for it by name; if the owning module is enabled but not
-- yet loaded, it is loaded on the spot. Returns nil when the module
-- is disabled, missing, or when combat forbids loading secure code.
Modules.Providers = {
	ItemMenu       = 'Menu';
	SpellMenu      = 'Menu';
	UnitMenu       = 'Menu';
	UnitMenuSecure = 'Menu';
};

function Modules:GetEntry(id)
	for _, entry in self:Enumerate() do
		if ( entry.id == id ) then
			return entry;
		end
	end
end

function Modules:Demand(registration)
	local existing = db[registration];
	if existing then return existing end;
	local entry = self.Providers[registration];
	entry = entry and self:GetEntry(entry);
	if not entry or not self:IsEnabled(entry) or InCombatLockdown() then return end;
	self:Load(entry)
	return db[registration];
end

---------------------------------------------------------------
-- Migration
---------------------------------------------------------------
-- Module enablement used to live in settings while Modules:Load
-- re-enabled the addon on every login, so a user who switched a
-- module off has it saved as false against an enabled addon.
-- Carry that choice onto the addon list once, then drop the keys.
-- id -> { old variable, what it defaulted to before the move }
Modules.Deprecated = {
	Bar      = { 'moduleActionBar',  true  };
	Menu     = { 'moduleMenus',      true  };
	Rings    = { 'moduleRings',      true  };
	Target   = { 'moduleTarget',     true  };
	World    = { 'moduleWorld',      true  };
	Cursor   = { 'UIenableCursor',   true  };
	Keyboard = { 'keyboardEnable',   false };
};

-- Bumped when the stored shape changes, so the repair runs once per user.
local MODULE_STATE_VERSION = 1;

function Modules:MigrateFromSettings()
	if not ConsolePortSettings then return end;
	if ( ConsolePortSettings.moduleStateVersion == MODULE_STATE_VERSION ) then return end;

	for id, deprecated in pairs(self.Deprecated) do
		local varID, default = deprecated[1], deprecated[2];
		local saved;
		for _, source in ipairs({ConsolePortSettings, ConsolePortCharacterSettings}) do
			if ( source and source[varID] ~= nil ) then
				saved = source[varID];
				source[varID] = nil;
			end
		end
		local entry = self:GetEntry(id);
		if entry then
			-- Load used to enable the addon on every login, so whatever the user
			-- had on must be written to the addon list once. 3.3.3 wrote only the
			-- off case, which dropped the module for anyone who had ever unticked
			-- it in the addon list, and cleared the variable that said otherwise.
			if ( ( saved == nil ) and default or not not saved ) then
				CPAPI.EnableAddOn(entry.addon)
			elseif ( saved ~= nil ) then
				CPAPI.DisableAddOn(entry.addon)
			end
		end
	end

	ConsolePortSettings.moduleStateVersion = MODULE_STATE_VERSION;
	CPAPI.Log('Module selection now lives in the AddOns list; your modules were restored there.')
end

function Modules:OnDataLoaded()
	self:MigrateFromSettings()
	for _, entry in self:Enumerate() do
		if self:IsEnabled(entry) then
			self:Load(entry)
		end
	end
	return CPAPI.BurnAfterReading;
end
