local _, env, db = ...; db = env.db;
local GameMenu, GameMenuButtonMixin = GameMenuFrame, CreateFromMixins(CPActionButton);
local Selector = Mixin(CPAPI.EventHandler(ConsolePortMenuRing), CPAPI.SecureEnvironmentMixin);

---------------------------------------------------------------
-- Consts
---------------------------------------------------------------
local IsWoW11Version   = select(4, GetBuildInfo()) >= 110000; -- TODO: remove when 11.0.* is released
local GameMenuBinding  = 'TOGGLEGAMEMENU';
local EMPTY_HINT_TEXT  = YELLOW_FONT_COLOR:WrapTextInColorCode(EMPTY);
local STICK_BTN_DIR    = {
	UP    = true;
	DOWN  = true;
	LEFT  = true;
	RIGHT = true;
};

local ENABLE_MENU_STICK_INPUTS = {
	SIDE = {
		-- Left stick triggers the game menu to close, enabling the ring
		L = 'TOGGLEGAMEMENU';
		-- Right stick cancels the ring, PAD2 is the cancel button
		R = 'CLICK '..Selector:GetName()..':PAD2';
	};
};

---------------------------------------------------------------
-- Input configurations
---------------------------------------------------------------
Selector.Configuration = {
	Left = {
		Buttons = {
			Accept = 'PAD1';
			Cancel = 'PAD2';
			Extra1 = 'PAD3';
			Extra2 = 'PAD4';
		};
		Sticks = {
			L = true;
			R = false;
		};
	};
	Right = {
		Buttons = {
			Accept = 'PADDDOWN';
			Cancel = 'PADDRIGHT';
			Extra1 = 'PADDLEFT';
			Extra2 = 'PADDUP';
		};
		Sticks = {
			L = false;
			R = true;
		};
	};
};

---------------------------------------------------------------
-- Secure environment
---------------------------------------------------------------
Selector:RegisterForClicks('AnyDown')
Selector:SetAttribute('numbuttons', 0)
Selector:SetFrameRef('trigger', Selector.Trigger)
Selector:Run([[
	selector = self;
	trigger  = self:GetFrameRef('trigger');
	BUTTONS  = {};
	BINDINGS = {};
	TRIGGERS = {};
	COMMANDS = {};
]])

Selector.PrivateEnv = {
	-- Trigger
	OnGameMenuShow = [[
		enabled = selector:GetAttribute('eligible') and selector::StoreBindingsForTriggers()
		if not enabled then return end;

		selector:Show()
		selector:CallMethod('UpdatePieSlices', true, self:GetAttribute('numbuttons'))
		selector:CallMethod('UpdateButtons')
		selector:CallMethod('RestyleMenu', true)
		selector:CallMethod('ShowHints', true)

		for binding, action in pairs(TRIGGERS) do
			selector:SetBinding(true, binding, action)
		end
	]];
	OnGameMenuHide = ([[
		if not enabled then return end;
		if not selector::IsTargeting() then
			selector::ClearAndHide(true)
		else
			local emptyHintText = %q;
			for binding, command in pairs(COMMANDS) do
				if command then -- active command, set binding
					selector:SetBindingClick(true, binding, selector:GetName(), command)
				end
				if ( binding == command ) then -- extra command, show hint
					selector:CallMethod('AddHint', binding, emptyHintText)
				end
			end
			for binding in pairs(BINDINGS) do
				selector:SetBindingClick(true, binding, selector:GetName())
			end
		end
		for binding in pairs(TRIGGERS) do
			selector:ClearBinding(binding)
		end
		selector:CallMethod('RestyleMenu', false)
	]]):format(EMPTY_HINT_TEXT);
	-- Selector
	ClearAndHide = ([[
		local clearInstantly = ...;
		if clearInstantly then
			self:CallMethod('ClearInstantly')
			self:CallMethod('ShowHints', false)
			self:SetAttribute(%q, nil)
			for button in pairs(COMMANDS) do
				self:SetAttribute(button, nil)
			end
		end

		self:Hide()
		self:ClearBindings()
		self:CallMethod('RestyleMenu', false)
	]]):format(CPAPI.ActionTypePress);
	-- NOTE: Forcing the left stick and XYAB for now
	IsTargeting = [[
		local _, _, len = self::GetStickPosition(PRIMARY_STICK)
		return len > 0.1;
	]];
	StoreBindingsForTriggers = [[
		wipe(BINDINGS)

		local mods = newtable(self::GetModifiersHeld())
		local btns = newtable(self::GetButtonsHeld())
		table.sort(mods)
		mods[#mods+1] = table.concat(mods)

		for _, btn in ipairs(btns) do
			BINDINGS[btn:upper()] = true;
			for _, mod in ipairs(mods) do
				BINDINGS[((mod or '')..btn):upper()] = true;
			end
		end

		return #btns > 0;
	]];
	PreClick = ([[
		if ( button == CANCEL ) then -- Right stick moved, invoke the cancel action manually.
			enabled = false; -- Set explicitly to false to prevent the menu closing from reassigning bindings
			self::OnCommandExecuted(button) -- Reuse the command executed handler to clear the trigger keys
			return self::ClearAndHide(true) -- Clear and hide the menu
		end

		self::UpdateSize()
		local index = self::GetIndex(PRIMARY_STICK);
		local item = index and BUTTONS[index];
		if item then
			if button:match('PAD') then
				self:CallMethod('AddHintFromButton', button, item:GetName())
				return self:SetAttribute(button, item:GetName())
			end

			self:SetAttribute(ACCEPT, item:GetName())
			self:SetAttribute(CANCEL, trigger:GetName())
			self:CallMethod('AddHint', CANCEL, %q)

			for button in pairs(COMMANDS) do
				local target = self:GetAttribute(button)
				if target then
					trigger:SetBindingClick(true, button, target, button)
				else
					self:CallMethod('RemoveHint', button)
				end
			end

			for binding in pairs(BINDINGS) do
				trigger:SetBindingClick(true, binding, item:GetName())
			end

			self::ClearAndHide(false)
		else
			self::ClearAndHide(true)
		end
	]]):format(CANCEL);
	OnCommandExecuted = [[
		local button = ...;
		self:SetAttribute(button, nil)
		self:CallMethod('RemoveHint', button)
		trigger:ClearBinding(button)

		local clearAll = ( button == CANCEL or button == 'LeftButton' );
		if not clearAll then
			local hasActiveBindings = false;
			for button, command in pairs(COMMANDS) do
				if command and self:GetAttribute(button) then
					hasActiveBindings = true;
					break
				end
			end
			clearAll = not hasActiveBindings;
		end

		if ( clearAll ) then
			selector:CallMethod('ShowHints', false)
			trigger:ClearBindings()
			for button in pairs(COMMANDS) do
				self:SetAttribute(button, nil)
			end
		end
	]];
	-- Buttons
	ButtonPostClick = [[
		self:CallMethod('OnClear')
		selector::OnCommandExecuted(button)
	]];
};

Selector:CreateEnvironment(Selector.PrivateEnv)
Selector:Hook(Selector.Trigger, 'OnShow', Selector.PrivateEnv.OnGameMenuShow)
Selector:Hook(Selector.Trigger, 'OnHide', Selector.PrivateEnv.OnGameMenuHide)
Selector:Hook(Selector.Trigger, 'PostClick', Selector.PrivateEnv.ButtonPostClick)
Selector:Wrap('PreClick', Selector.PrivateEnv.PreClick)

Selector:SetFrameStrata(GameMenu:GetFrameStrata())
Selector:SetFrameLevel(GameMenu:GetFrameLevel() - 1)

---------------------------------------------------------------
-- Handler
---------------------------------------------------------------
function Selector:OnDataLoaded(...)
	local counter = CreateCounter();
	self:CreateObjectPool(function()
		return CreateFrame(
			'CheckButton',
			self:GetName()..'Button'..counter(),
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

	self:SetRadialSize(IsWoW11Version and 520 or 450)
	self.buttonSize = IsWoW11Version and 64 or 48;

	self:UpdateColorSettings()
	self:OnAxisInversionChanged()
	self:OnControlsChanged()
	self:OnPrerequisiteChanged()
	self.ActiveSlice:SetAlpha(0)

	local numButtons = #env.Buttons;
	for i, data in ipairs(env.Buttons) do
		self:AddButton(i, data, numButtons)
	end
end

function Selector:OnAxisInversionChanged()
	self.axisInversion = db('radialCosineDelta')
end

function Selector:OnPrerequisiteChanged()
	local eligible = db('radialExtended')
	local rescale  = db('gameMenuScale')
	self:SetScale(rescale)
	self:SetAttribute('eligible', eligible)
	if IsWoW11Version then -- TODO: remove when 11.0.* is released
		GameMenu:SetScale(eligible and rescale * 0.8 or 1)
	end
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
		Accept = db('gameMenuButton1');
		Cancel = db('gameMenuButton2');
		Extra1 = db('gameMenuButton3');
		Extra2 = db('gameMenuButton4');
	} or config.Buttons;

	self:SetInterrupt(sticks)
	self:SetIntercept({main})

	self:Run([[
		ACCEPT, CANCEL, EXTRA1, EXTRA2, PRIMARY_STICK = %q, %q, %q, %q, %q;
		COMMANDS[ACCEPT] = 'LeftButton';
		COMMANDS[CANCEL] = false;
		COMMANDS[EXTRA1] = EXTRA1;
		COMMANDS[EXTRA2] = EXTRA2;
	]], buttons.Accept, buttons.Cancel, buttons.Extra1, buttons.Extra2, main)

	self.acceptButton = buttons.Accept;

	local enableBinding, cancelBinding = GameMenuBinding, ('CLICK %s:%s'):format(self:GetName(), buttons.Cancel);
	for modifier in db:For('Gamepad/Index/Modifier/Active') do
		for side, isTrigger in pairs(config.Sticks) do
			local binding = isTrigger and enableBinding or cancelBinding;
			for dir, enableButton in pairs(STICK_BTN_DIR) do
				if enableButton then
					self:Run([[
						TRIGGERS['%sPAD%sSTICK%s'] = %q;
					]], modifier, side, dir, binding)
				end
			end
		end
	end
end

---------------------------------------------------------------
-- Frontend
---------------------------------------------------------------
function Selector:OnInput(x, y, len, stick)
	self:SetFocusByIndex(self:GetIndexForPos(x, y, len, self:GetNumActive()))
	self:ReflectStickPosition(self.axisInversion * x, self.axisInversion * y, len, len > self:GetValidThreshold())
	if ( len < self:GetValidThreshold() and self.showHints ) then
		self:AddHint(self.acceptButton, CANCEL)
	end
end

function Selector:AddButton(i, data, size)
	local button, newObj = self:Acquire(i)
	local p, x, y = self:GetPointForIndex(i, size)
	if newObj then
		button:SetSize(self.buttonSize, self.buttonSize)
		button:RegisterForClicks('AnyDown')
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

function Selector:RestyleMenu(enabled)
	if CPAPI.IsRetailVersion then
		GameMenu.Border:SetShown(not enabled)
		GameMenu.Header:SetShown(not enabled)
	else
		GameMenuFrameHeader:SetShown(not enabled)
		NineSliceUtil.SetLayoutShown(GameMenu, not enabled)
	end
	GameMenuFrameConsolePort:SetShown(not enabled)
	local fade = db.Alpha.Fader;
	if enabled then
		fade.In(self.Background, 0.15, self.Background:GetAlpha(), 0.75)
	else
		fade.Out(self.Background, 0.15, self.Background:GetAlpha(), 0)
	end
end

function Selector:ShowHints(enabled)
	self.showHints = enabled;
	local handle = db.UIHandle;
	if enabled then
		handle:SetHintFocus(self, false)
	else
		if handle:IsHintFocus(self) then
			handle:HideHintBar()
		end
		handle:ClearHintsForFrame(self)
		ConsolePort:SetCursorObstructor(self, enabled)
	end
end

function Selector:AddHint(key, text)
	db.UIHandle:AddHint(key, text)
	ConsolePort:SetCursorObstructor(self, true)
end

function Selector:AddHintFromButton(key, button)
	db.UIHandle:AddHint(key, _G[button]:GetHint())
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
		self:SetAttribute(CPAPI.ActionTypePress, 'click')
		self:SetAttribute('clickbutton', self.ref)
	end
	if self.click then
		self:SetAttribute(CPAPI.ActionTypePress, 'custom')
		self:SetAttribute('_custom', self.click)
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

db:RegisterSafeCallback('Settings/radialCosineDelta', Selector.OnAxisInversionChanged, Selector)
db:RegisterSafeCallbacks(Selector.OnControlsChanged, Selector,
	'OnModifierChanged',
	'Settings/radialPrimaryStick',
	'Settings/gameMenuCustomSet',
	'Settings/gameMenuButton1',
	'Settings/gameMenuButton2',
	'Settings/gameMenuButton3',
	'Settings/gameMenuButton4'
);
db:RegisterSafeCallbacks(Selector.OnPrerequisiteChanged, Selector,
	'Settings/radialExtended',
	'Settings/gameMenuScale'
);