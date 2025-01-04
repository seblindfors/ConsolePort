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
}))

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

	local handle = db.UIHandle;
	if unit then
		handle:ResetHintBar()
		handle:SetHintFocus(insecureMenu)
		for cmd, hint in pairs(self.Hints) do
			handle:AddHint(self.Buttons[cmd], hint)
		end
	else
		if handle:IsHintFocus(insecureMenu) then
			handle:HideHintBar()
		end
		handle:ClearHintsForFrame(insecureMenu)
	end
end

function UnitMenuSecure:ForwardCommand(command)
	db.UnitMenu:Execute(command)
end

function UnitMenuSecure:OnDataLoaded()
	self:SetAttribute('clickbutton', db.UnitMenu.SecureProxy)
	self:SetFrameRef('Cursor', db.Raid)
	self:Execute([[cursor = self:GetFrameRef('Cursor')]])
end

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
end, UnitMenuSecure)