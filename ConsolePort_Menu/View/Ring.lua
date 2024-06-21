local _, env, db = ...; db = env.db;
local GameMenuButtonMixin = CreateFromMixins(CPActionButton);
local Selector = Mixin(CPAPI.EventHandler(ConsolePortMenuRing), CPAPI.SecureEnvironmentMixin);

---------------------------------------------------------------
-- Consts
---------------------------------------------------------------
local GAMEMENUBINDING  = 'TOGGLEGAMEMENU';
local BTN_NAME_PREFIX  = 'CPM%s';

---------------------------------------------------------------
-- ¯\_(ツ)_/¯
---------------------------------------------------------------
local EVIL_BUTTON_NAME = GenerateClosure(function(s, i) return s:format(string.char(96+i)) end, BTN_NAME_PREFIX)
local EVIL_MACRO_ICON  = 136243;
local EVIL_MACRO_NAME  = _;
local EVIL_MACRO_TEXT  = (function()
	local forcedMyhand = {};
	for i=1, #env.Buttons do
		forcedMyhand[i] = ('/click %s'):format(EVIL_BUTTON_NAME(i));
	end
	return table.concat(forcedMyhand, '\n')
end)()

---------------------------------------------------------------
-- Input configurations
---------------------------------------------------------------
Selector.Configuration = {
	Left = {
		Buttons = {
			Accept = 'PAD1';
			Plural = 'PAD2';
			Return = 'PADLSHOULDER';
			Switch = 'PADRSHOULDER';
		};
	};
	Right = {
		Buttons = {
			Accept = 'PADDDOWN';
			Plural = 'PADDRIGHT';
			Return = 'PADLSHOULDER';
			Switch = 'PADRSHOULDER';
		};
	};
};

---------------------------------------------------------------
-- Secure environment
---------------------------------------------------------------
Selector:RegisterForClicks('AnyDown')
Selector:SetAttribute('numbuttons', 0)
Selector:SetAttribute(CPAPI.ActionTypePress, 'macro')
Selector:SetAttribute('macrotext', EVIL_MACRO_TEXT)
Selector:SetFrameRef('trigger', Selector.Trigger)
Selector:Run([[
	selector = self;
	trigger  = self:GetFrameRef('trigger');
	BUTTONS  = {};
	TRIGGERS = {};
	COMMANDS = {};
]])

Selector.PrivateEnv = {
	-- Trigger
	OnGameMenuShow = [[
		selector::ClearAndHide(true)
		for binding, action in pairs(TRIGGERS) do
			selector:SetBinding(true, binding, action)
		end
	]];
	OnGameMenuHide = [[
		if not selector::IsButtonHeld(SWITCH) then
			selector::ClearAndHide(true)
		else
			selector::OnTrigger()
		end
	]];
	OnTrigger = [[
		selector::EnableRing()
		for binding, command in pairs(COMMANDS) do
			selector:SetBindingClick(true, binding, selector:GetName(), command)
		end
	]];
	-- Selector
	EnableRing = ([[
		self:Show()
		self:CallMethod('UpdatePieSlices', true, self:GetAttribute('numbuttons'))
		self:CallMethod('UpdateButtons')
		self:CallMethod('AddHint', ACCEPT, %q)
	]]):format(CLOSE);
	ClearAndHide = [[
		local clearInstantly = ...;
		if clearInstantly then
			self:CallMethod('ClearInstantly')
		end

		self:Hide()
		self:ClearBindings()
		self:CallMethod('RemoveHint', ACCEPT)
	]];
	PreClick = ([[
		local type = %q;

		-- Since we're clicking all buttons, clear the type to prevent actions
		for _, item in ipairs(BUTTONS) do
			item:SetAttribute(type, nil)
		end

		self::UpdateSize()
		local index = self::GetIndex(PRIMARY_STICK);
		local item = index and BUTTONS[index];
		if item then
			item:SetAttribute(type, item:GetAttribute('command'))
			if ( button == PLURAL ) then
				return;
			end
			self::ClearAndHide(false)
		else
			self::ClearAndHide(true)
		end
	]]):format(CPAPI.ActionTypeRelease);
	-- Buttons
	ButtonPostClick = ([[
		self:CallMethod('OnClear')
		self:SetAttribute(%q, self:GetAttribute('command'))
	]]):format(CPAPI.ActionTypeRelease);
};

Selector:CreateEnvironment(Selector.PrivateEnv)
Selector:Hook(Selector.Trigger, 'OnShow',  Selector.PrivateEnv.OnGameMenuShow)
Selector:Hook(Selector.Trigger, 'OnHide',  Selector.PrivateEnv.OnGameMenuHide)
Selector:Hook(Selector.Trigger, 'OnClick', Selector.PrivateEnv.OnTrigger)
Selector:Wrap('PreClick', Selector.PrivateEnv.PreClick)

---------------------------------------------------------------
-- Handler
---------------------------------------------------------------
function Selector:OnDataLoaded(...)
	local counter = CreateCounter();
	self:CreateObjectPool(function()
		return CreateFrame(
			'CheckButton',
			EVIL_BUTTON_NAME(counter()),
			self, 'SecureActionButtonTemplate, ActionButtonTemplate')
		end,
		function(_, self)
			self:Hide()
			self:ClearAllPoints()
			if self.OnClear then
				self:OnClear()
			end
		end, GameMenuButtonMixin)
	local sticks = db.Radial:GetStickStruct(db('radialPrimaryStick'))
	db.Radial:Register(self, 'UtilityRing', {
		sticks = sticks;
		target = {sticks[1]};
		sizer  = ([[
			local size = %d;
		]]):format(#env.Buttons);
	});

	self:SetFixedSize(450)

	self:UpdateColorSettings()
	self:OnAxisInversionChanged()
	self:OnControlsChanged()
	self:OnSizingChanged()
	self.ActiveSlice:SetAlpha(0)

	local numButtons = #env.Buttons;
	for i, data in ipairs(env.Buttons) do
		self:AddButton(i, data, numButtons)
	end
end

function Selector:OnAxisInversionChanged()
	self.axisInversion = db('radialCosineDelta')
end

function Selector:OnSizingChanged()
	self:SetScale(db('gameMenuScale'))
end

function Selector:OnControlsChanged()
	self:Run([[
		wipe(TRIGGERS)
		wipe(COMMANDS)
		self:ClearBindings()
	]])

	local sticks = db.Radial:GetStickStruct(db('radialPrimaryStick'))
	local main = sticks[1];
	local config = self.Configuration[main] or self.Configuration.Left;
	local buttons = db('gameMenuCustomSet') and {
		Accept = db('gameMenuAccept');
		Plural = db('gameMenuPlural');
		Return = db('gameMenuReturn');
		Switch = db('gameMenuSwitch');
	} or config.Buttons;

	self:SetInterrupt(sticks)
	self:SetIntercept({main})

	self:Run([[
		SWITCH, ACCEPT, PLURAL, PRIMARY_STICK = %q, %q, %q, %q;
		COMMANDS[ACCEPT] = 'LeftButton';
		COMMANDS[PLURAL] = PLURAL;
	]], buttons.Switch, buttons.Accept, buttons.Plural, main)

	self.acceptButton, self.pluralButton = buttons.Accept, buttons.Plural;

	for modifier in db:For('Gamepad/Index/Modifier/Active') do
		self:Run([[
			local binding, modifier = %q, %q;
			TRIGGERS[modifier..'%s'] = binding;
			TRIGGERS[modifier..'%s'] = binding;
		]], GAMEMENUBINDING, modifier, buttons.Return, buttons.Switch)
	end
end

function Selector:OnTerribleWorkaround(macroInfo)
	if RunMacroText or self.macroEditMutex then return end;
	self.macroEditMutex = true;
	local macroID;
	for i, info in pairs(macroInfo) do
		if ( info.name == EVIL_MACRO_NAME ) then
			macroID = i;
			break;
		end
	end
	if not macroID then
		-- Assert we have macro space available
		local global, perChar = GetNumMacros()
		if global >= MAX_ACCOUNT_MACROS and perChar >= MAX_CHARACTER_MACROS then
			self.macroEditMutex = nil;
			return CPAPI.Log('No macro space available for ConsolePort Menu. Please delete one of your macros.')
		end
		local usePerChar = global >= MAX_ACCOUNT_MACROS;
		macroID = CreateMacro(EVIL_MACRO_NAME, EVIL_MACRO_ICON, EVIL_MACRO_TEXT, usePerChar)
	end
	EditMacro(macroID, EVIL_MACRO_NAME, EVIL_MACRO_ICON, EVIL_MACRO_TEXT)
	self:SetAttribute('macro', macroID)
	self.macroEditMutex = nil;
end

---------------------------------------------------------------
-- Frontend
---------------------------------------------------------------
Selector:SetFrameStrata(GameMenuFrame:GetFrameStrata())
Selector:SetFrameLevel(GameMenuFrame:GetFrameLevel())
Selector.Filigree:SetScale(3.1)
Selector.Filigree:SetTexCoord(0, 1, 0, 1)
Selector.Filigree:SetTexture(CPAPI.GetAsset([[Textures\Pie\Pie_Background.png]]))

Selector:HookScript('OnShow', GenerateClosure(ConsolePort.SetCursorObstructor, ConsolePort, Selector, true))
Selector:HookScript('OnHide', GenerateClosure(ConsolePort.SetCursorObstructor, ConsolePort, Selector, false))

function Selector:OnInput(x, y, len, stick)
	self.Filigree:SetAlpha(Clamp(1 - len, 0, 1))
	self:SetFocusByIndex(self:GetIndexForPos(x, y, len, self:GetNumActive()))
	self:ReflectStickPosition(self.axisInversion * x, self.axisInversion * y, len, len > self:GetValidThreshold())
	if not self.showHints then return end;
	if ( len < self:GetValidThreshold() ) then
		self:AddHint(self.acceptButton, CLOSE)
		self:RemoveHint(self.pluralButton)
	else
		self:AddHint(self.pluralButton, USE)
	end
end

function Selector:AddButton(i, data, size)
	local button, newObj = self:Acquire(i)
	local p, x, y = self:GetPointForIndex(i, size)
	if newObj then
		button:SetSize(60, 60)
		button:RegisterForClicks('AnyUp')
		button:SetAttribute(CPAPI.ActionPressAndHold, true)
		button.Name:Hide()
	end
	button:SetPoint(p, x, self.axisInversion * y)
	button:SetRotation(self:GetRotation(x, y))
	button:SetID(i)
	button:Show()
	button:SetData(data)
	self:SetAttribute('numbuttons', math.max(i, self:GetAttribute('numbuttons')))
	self:SetFrameRef(tostring(i), button)
	self:Run([[
		local index  = %d;
		local button = self:GetFrameRef(tostring(index))
		BUTTONS[index] = button;
	]], i)
	self:Hook(button, 'PostClick', self.PrivateEnv.ButtonPostClick)
end

function Selector:UpdateButtons()
	for button in self:EnumerateActive() do
		button:Update()
	end
end

function Selector:ShowHints(enabled)
	self.showHints = enabled;
	local handle = db.UIHandle;
	if enabled then
		handle:SetHintFocus(self, false)
		handle:AddHint(db('gameMenuSwitch'), LOOT_NEXT_PAGE or SWITCH)
		handle:AddHint(db('gameMenuReturn'), BACK)
	else
		if handle:IsHintFocus(self) then
			handle:HideHintBar()
		end
		handle:ClearHintsForFrame(self)
	end
end

function Selector:AddHint(key, text)
	db.UIHandle:AddHint(key, text)
end

function Selector:RemoveHint(key)
	db.UIHandle:RemoveHint(key)
end

---------------------------------------------------------------
-- Buttons
---------------------------------------------------------------
local ActionButton = LibStub('ConsolePortActionButton')

function GameMenuButtonMixin:Update()
	ActionButton.Skin.RingButton(self)
	RunNextFrame(function()
		self.Name:SetText(self.text)
		if self.img then self.icon:SetTexture(self.img) end;
		self:GetParent():SetSliceText(self:GetID(), self:GetSliceText())
	end)
end

function GameMenuButtonMixin:SetData(data)
	FrameUtil.SpecializeFrameWithMixins(self, data)
	if self.ref then
		self:SetAttribute(CPAPI.ActionTypeRelease, 'click')
		self:SetAttribute('command', 'click')
		self:SetAttribute('clickbutton', self.ref)
	end
	if self.click then
		self:SetAttribute(CPAPI.ActionTypeRelease, 'custom')
		self:SetAttribute('command', 'custom')
		self:SetAttribute('_custom', function(self)
			if self:GetAttribute(CPAPI.ActionTypeRelease) then
				self.click()
			end
		end)
	end
	self:Update()
end

function GameMenuButtonMixin:OnFocus()
	local parent = self:GetParent()
	self:LockHighlight()
	db.UIHandle:AddHint(parent.acceptButton, self:GetHint())
	parent:SetActiveSliceText(self:GetSliceText())
end

function GameMenuButtonMixin:GetHint()
	return self.hint or self.text or ACCEPT;
end

function GameMenuButtonMixin:GetSliceText()
	return ('%s\n%s'):format(self.text or '', self.subtitle or '')
end

function GameMenuButtonMixin:OnClear()
	self:UnlockHighlight()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
	self:SetChecked(false)
	self:GetParent():SetActiveSliceText(nil)
end

db:RegisterSafeCallback('OnUpdateMacros', Selector.OnTerribleWorkaround, Selector)
db:RegisterSafeCallback('Settings/radialCosineDelta', Selector.OnAxisInversionChanged, Selector)
db:RegisterSafeCallbacks(Selector.OnControlsChanged, Selector,
	'OnModifierChanged',
	'Settings/radialPrimaryStick',
	'Settings/gameMenuCustomSet',
	'Settings/gameMenuAccept',
	'Settings/gameMenuPlural',
	'Settings/gameMenuReturn',
	'Settings/gameMenuSwitch'
);
db:RegisterSafeCallbacks(Selector.OnSizingChanged, Selector,
	'Settings/gameMenuScale'
);