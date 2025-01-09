---------------------------------------------------------------
-- Secure unit popup menu handling
---------------------------------------------------------------
-- Provides combat-safe controls for the unit menu.
-- See View\Popup\UnitMenu.lua for the actual menu.

local _, db = ...;
local UnitMenuSecure = db:Register('UnitMenuSecure', Mixin(CPAPI.DataHandler(ConsolePortUnit), CPAPI.SecureEnvironmentMixin, {
	Buttons = { -- Cautiously hardcoded until someone complains
		ACCEPT = 'PAD1';
		CANCEL = 'PAD2';
		CLOSE  = 'PAD3';
		UP     = 'PADDUP';
		DOWN   = 'PADDDOWN';
	};
	Hints = {
		ACCEPT = ACCEPT;
		CANCEL = BACK;
		CLOSE  = CLOSE;
	};
	Bindings = {
		Next = {
			macrotext = '/targetfriend 0';
			binding   = 'TARGETNEARESTFRIEND';
		};
		Prev = {
			macrotext = '/targetfriend 1';
			binding   = 'TARGETPREVIOUSFRIEND';
		};
		NextPlayer = {
			macrotext = '/targetfriendplayer 0';
			binding   = 'TARGETNEARESTFRIENDPLAYER';
		};
		PrevPlayer = {
			macrotext = '/targetfriendplayer 1';
			binding   = 'TARGETPREVIOUSFRIENDPLAYER';
		};
	};
}))

---------------------------------------------------------------
-- Inscure
---------------------------------------------------------------
function UnitMenuSecure:SetUnit(unit)
	self:Run([[
		self::SetUnit(%q)
	]], unit or 'none')
end

function UnitMenuSecure:GetPreferredUnit()
	local raid = db.Raid:GetAttribute(CPAPI.RaidCursorUnit)
	return ( raid and UnitExists(raid) and raid )
		or ( UnitExists('target') and 'target' )
		or 'player';
end

function UnitMenuSecure:ToggleMenu(unit)
	local insecureMenu = db.UnitMenu;
	insecureMenu:SetUnit(unit, true)

	local handle = self:ToggleHintFocus(unit)
	if unit then
		for cmd, hint in pairs(self.Hints) do
			handle:AddHint(self.Buttons[cmd], hint)
		end
	end
end

function UnitMenuSecure:ToggleHintFocus(enabled)
	local handle, insecureMenu = db.UIHandle, db.UnitMenu;
	if enabled then
		handle:ResetHintBar()
		handle:SetHintFocus(insecureMenu)
	else
		if handle:IsHintFocus(insecureMenu) then
			handle:HideHintBar()
		end
		handle:ClearHintsForFrame(insecureMenu)
	end
	return handle;
end

function UnitMenuSecure:ForwardCommand(command)
	db.UnitMenu:Execute(command)
end

function UnitMenuSecure:OnDataLoaded()
	self:SetAttribute('clickbutton', db.UnitMenu.SecureProxy)
	self:SetFrameRef('Cursor', db.Raid)
	self:Execute([[cursor = self:GetFrameRef('Cursor')]])
end

---------------------------------------------------------------
-- Secure
---------------------------------------------------------------
UnitMenuSecure:RegisterForClicks('AnyDown')
UnitMenuSecure:Execute([[
	UNIT_DRIVER = '[@%s,exists] %s; nil';
	BUTTONS = newtable();
	ESCAPES = newtable();
]]) for cmd, button in pairs(UnitMenuSecure.Buttons) do
	UnitMenuSecure:Run([[
		BUTTONS[%q] = %q;
	]], cmd, button)
end

UnitMenuSecure:CreateEnvironment({
	['_onstate-unit'] = [[
		self::UpdateUnit(newstate)
	]];
	UpdateUnit = [[
		local unit = ...;
		self::ToggleMenu(unit)
		if not unit then
			self:ClearBindings()
			UnregisterStateDriver(self, 'unit')
		else
			local name = self:GetName()
			for escape in pairs(ESCAPES) do
				self:SetBindingClick(true, escape, name, BUTTONS.CLOSE)
			end
			for cmd, button in pairs(BUTTONS) do
				self:SetBindingClick(true, button, name, button)
			end
		end
	]];
	SetUnit = [[
		local unit = ...;
		local driver  = UNIT_DRIVER:format(unit, unit)
		local isValid = SecureCmdOptionParse(driver) == unit;

		if isValid then
			RegisterStateDriver(self, 'unit', driver)
		end

		self::UpdateUnit(isValid and unit or nil)
	]];
	ToggleMenu = [[
		local unit = ...;
		self:SetAttribute('unit', unit)
		self:CallMethod('ToggleMenu', unit)
	]];
	GetPreferredUnit = ([[
		return cursor:GetAttribute(%q)
			or UnitExists('target') and 'target'
			or 'player';
	]]):format(CPAPI.RaidCursorUnit);
}, true)

UnitMenuSecure:Wrap('PreClick', ([[
	local genericClick = button == 'LeftButton';
	local unitOrButton = button;

	if genericClick then
		unitOrButton = self::GetPreferredUnit()
	end

	local type = %q;
	self:SetAttribute(type, nil)
	if ( unitOrButton == BUTTONS.CLOSE ) then
		return self::UpdateUnit(nil)
	elseif ( unitOrButton == BUTTONS.ACCEPT ) then
		return self:SetAttribute(type, 'click')
	end
	for cmd, btn in pairs(BUTTONS) do
		if ( unitOrButton == btn ) then
			return self:CallMethod('ForwardCommand', cmd)
		end
	end
	self::SetUnit(unitOrButton)
]]):format(CPAPI.ActionTypePress))

---------------------------------------------------------------
local UnitMenuTrigger = {
---------------------------------------------------------------
	TimeUntilHints   = 0.25;
	TimeUntilTrigger = 1.5;
	PreClickHandler = ([[
		local type = %q;
		self:SetAttribute(type, down and 'macro' or nil)
	]]):format(CPAPI.ActionTypePress);
};

function UnitMenuTrigger:OnLoad()
	self:SetAttribute(CPAPI.ActionPressAndHold, true)
	self:SetAttribute('macrotext', self.macrotext)
	self:SetAttribute('binding', self.binding)
	self:RegisterForClicks('AnyDown', 'AnyUp')
	self:HookScript('OnClick', self.OnContext)
	self.secure = UnitMenuSecure;
	self.secure:WrapScript(self, 'PreClick', self.PreClickHandler)
end

function UnitMenuTrigger:SetOverride(key)
	SetOverrideBindingClick(self, false, key, self:GetName(), key:match('[^-]+$'))
end

function UnitMenuTrigger:ClearOverrides()
	ClearOverrideBindings(self)
end

function UnitMenuTrigger:OnContext(button, enable)
	if self.display then
		self.secure:ToggleHintFocus(false)
	end
	self.timer, self.display, self.button = 0, false, enable and button or nil;
	self:SetScript('OnUpdate', enable and self.OnContextUpdate or nil)
end

function UnitMenuTrigger:OnContextUpdate(elapsed)
	if InCombatLockdown() or not UnitExists('target') then
		return self:OnContext(self.button, false)
	end
	self.timer = self.timer + elapsed;
	if self.timer > self.TimeUntilTrigger then
		self:OnContext(self.button, false)
		self.secure:Run([[ self::SetUnit('target') ]])
	elseif not self.display and self.timer > self.TimeUntilHints then
		self.display = true;
		local handle = self.secure:ToggleHintFocus(true)
		local hint = handle:AddHint(self.button, OPTIONS_MENU)
		hint:SetTimer(self.TimeUntilTrigger - self.timer)
	end
end

---------------------------------------------------------------
-- Secure bindings
---------------------------------------------------------------
db:RegisterSafeCallback('OnNewBindings', function(self)
	local function GetEscape(key, ...)
		if not key then return end;
		return ('ESCAPES[%q] = true;'):format(key), GetEscape(...)
	end

	local escapeBindings = {};
	self:Execute([[ wipe(ESCAPES) ]])
	tAppendAll(escapeBindings, { GetEscape(GetBindingKey(db.Bindings.Proxied.ToggleGameMenu)) })
	tAppendAll(escapeBindings, { GetEscape(GetBindingKey(db.Bindings.Custom.MenuRing)) })
	self:Execute(table.concat(escapeBindings, '\n'))

	local function AcquireTargetButton(cmd, info)
		local button = info.button;
		if not button then
			button = CreateFrame('Button', '$parent'..cmd, UnitMenuSecure, 'SecureActionButtonTemplate')
			FrameUtil.SpecializeFrameWithMixins(button, UnitMenuTrigger, info)
			info.button = button;
		end
		return button;
	end

	for cmd, info in pairs(self.Bindings) do
		if info.button then info.button:ClearOverrides() end;
		for key in db.Gamepad:EnumerateBindingKeys(info.binding) do
			AcquireTargetButton(cmd, info):SetOverride(key)
		end
	end
end, UnitMenuSecure)