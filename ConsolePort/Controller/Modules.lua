---------------------------------------------------------------
-- Modules
---------------------------------------------------------------
-- Registry of the load-on-demand modules, each gated by an
-- enable setting. Enabled modules are loaded when the core has
-- finished loading and whenever their setting is turned on; a
-- loaded module can only be turned off by reloading the interface.
--
-- This file is loaded last in the core so that the handler frame
-- is created after every other core frame; loading a module fires
-- a nested ADDON_LOADED, which must not reach core handlers that
-- are still waiting for their own.

local Modules, _, db = CPAPI.CreateEventHandler({'Frame', '$parentModules', ConsolePort}), ...;
local L = db.Locale;
db:Register('Modules', Modules)

local function Asset(name)
	return CPAPI.GetAsset(([[Tutorial\%s]]):format(name))
end

Modules.Registry = {
	{	id       = 'Bar';
		addon    = 'ConsolePort_Bar';
		variable = 'moduleActionBar';
		image    = Asset('UnitHotkey');
		presets  = {
			{ id = 'Default';         name = DEFAULT };
			{ id = 'CrossbarMinimal'; name = 'Crossbar: Minimal' };
			{ id = 'CrossbarTriple';  name = 'Crossbar: Triple' };
		};
	};
	{	id       = 'Menu';
		addon    = 'ConsolePort_Menu';
		variable = 'moduleGameMenu';
		image    = Asset('TargetNearest');
	};
	{	id       = 'Rings';
		addon    = 'ConsolePort_Rings';
		variable = 'moduleRings';
		image    = Asset('TargetScan');
	};
	{	id       = 'Target';
		addon    = CPAPI.TargetAddOn;
		variable = 'moduleTarget';
		image    = Asset('RaidCursor');
	};
	{	id       = 'Cursor';
		addon    = CPAPI.CursorAddOn;
		variable = 'UIenableCursor';
		name     = 'Interface Cursor';
		desc     = 'Navigate the interface with the gamepad using a virtual cursor.';
		image    = Asset('TargetScan');
	};
	{	id       = 'World';
		addon    = 'ConsolePort_World';
		variable = 'moduleWorld';
		image    = Asset('TargetNearest');
	};
	{	id       = 'Keyboard';
		addon    = 'ConsolePort_Keyboard';
		variable = 'keyboardEnable';
		name     = 'Keyboard';
		desc     = 'Radial on-screen keyboard for typing with the gamepad.';
		image    = Asset('UnitHotkey');
	};
};

---------------------------------------------------------------
-- API
---------------------------------------------------------------
function Modules:Enumerate()
	return ipairs(self.Registry)
end

function Modules:GetInfo(entry)
	local variable = db.Variables[entry.variable];
	return L(entry.name or variable.name), L(entry.desc or variable.desc);
end

function Modules:IsEnabled(entry)
	return not not db(entry.variable)
end

function Modules:IsLoaded(entry)
	return CPAPI.IsAddOnLoaded(entry.addon)
end

function Modules:SetEnabled(entry, enabled)
	db('Settings/'..entry.variable, not not enabled)
end

function Modules:Load(entry)
	if self:IsLoaded(entry) then return true end;
	CPAPI.EnableAddOn(entry.addon)
	local loaded, reason = CPAPI.LoadAddOn(entry.addon)
	if not loaded then
		CPAPI.Log('Failed to load %s. Reason: %s\nPlease check your installation.',
			(entry.addon:gsub('_', ' ')), _G['ADDON_'..tostring(reason)])
	end
	return loaded;
end

function Modules:PromptReload(entry)
	CPAPI.Popup('ConsolePort_Module_Reload', {
		text      = L'%s will be disabled the next time the interface is reloaded.';
		button1   = RELOADUI;
		button2   = CANCEL;
		timeout   = 0;
		showAlert = 1;
		OnAccept  = ReloadUI;
	}, (self:GetInfo(entry)))
end

function Modules:OnVariableChanged(entry, enabled)
	if enabled then
		db:RunSafe(self.Load, self, entry)
	elseif self:IsLoaded(entry) then
		self:PromptReload(entry)
	end
end

function Modules:OnDataLoaded()
	for _, entry in self:Enumerate() do
		db:RegisterCallback('Settings/'..entry.variable, self.OnVariableChanged, self, entry)
		if self:IsEnabled(entry) then
			self:Load(entry)
		end
	end
	return CPAPI.BurnAfterReading;
end
