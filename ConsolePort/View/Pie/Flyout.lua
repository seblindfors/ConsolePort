if not SpellFlyout then return end;
local _, db = ...;
local SpellFlyout, FlyoutButtonMixin = SpellFlyout, CreateFromMixins(CPActionButton);
local Selector = Mixin(CPAPI.EventHandler(ConsolePortSpellFlyout, {
	'SPELL_FLYOUT_UPDATE'
}), CPAPI.SecureEnvironmentMixin);

---------------------------------------------------------------
-- Secure environment
---------------------------------------------------------------
Selector:SetFrameRef('nativeflyout', SpellFlyout)
Selector:SetAttribute('numbuttons', 0)
Selector:SetAttribute(CPAPI.ActionPressAndHold, true)
Selector:Run([[
	selector, nativeflyout = self, self:GetFrameRef('nativeflyout')
	BUTTONS = {};
]])

Selector.PrivateEnv = {
	ClearAndHide = ([[
		local clearInstantly = ...;
		if clearInstantly then
			selector:CallMethod('ClearInstantly')
			self:SetAttribute(%q, nil)
		end
		local owner = nativeflyout:GetParent()
		if owner then
			owner:Hide()
			owner:Show()
		end
		if customflyout and customflyout:IsVisible() then
			customflyout:Hide()
		end
	]]):format(CPAPI.ActionTypeRelease);
	OnFlyoutShow = [[
		local flyoutName, isCustom = ...;
		if selector::SetBindingsForTriggers()
		or isCustom and selector::SetBindingsForButton(selector::GetCustomBinding()) then
			selector::UpdateSize()
			selector:Show()
			selector:CallMethod('SetOverride', flyoutName, true)
			return true;
		else
			selector:CallMethod('SetOverride', flyoutName, false)
			selector:Hide()
		end
	]];
	OnFlyoutHide = [[
		wipe(BUTTONS)
		control:ClearBindings()
		control:Hide()
		control:CallMethod('ReleaseAll')
		self:SetAlpha(1)
	]];
	OnNativeFlyoutShow = [[
		if selector::OnFlyoutShow(nativeflyout:GetName(), false) then
			if (nativeflyout:GetWidth() > nativeflyout:GetHeight()) then
				nativeflyout:ClearAllPoints()
				nativeflyout:SetPoint('BOTTOM', selector, 'TOP', 0, selector:GetHeight() * 0.35)
			else
				nativeflyout:ClearAllPoints()
				nativeflyout:SetPoint('LEFT', selector, 'RIGHT', selector:GetWidth() * 0.75, 0)
			end
			control:CallMethod('ModifyCustomFlyout', nativeflyout:GetName())
		end
	]];
	OnNativeFlyoutHide = [[
		selector::OnFlyoutHide()
		control:CallMethod('ModifyCustomFlyout', nativeflyout:GetName())
	]];
	OnCustomFlyoutShow = [[
		if selector::OnFlyoutShow(customflyout:GetName(), true) then
			if (customflyout:GetWidth() > customflyout:GetHeight()) then
				customflyout:ClearAllPoints()
				customflyout:SetPoint('BOTTOM', selector, 'TOP', 0, selector:GetHeight() * 0.35)
			else
				customflyout:ClearAllPoints()
				customflyout:SetPoint('LEFT', selector, 'RIGHT', selector:GetWidth() * 0.75, 0)
			end
			local numActiveButtons = #BUTTONS;
			for i, button in ipairs(BUTTONS) do
				control:CallMethod('AddCustomButton', i, button:GetAttribute('spell'), button:GetName(), numActiveButtons)
			end
			control:CallMethod('ModifyCustomFlyout', customflyout:GetName())
			control:CallMethod('UpdatePieSlices', true, numActiveButtons)
		end
	]];
	OnCustomFlyoutHide = [[
		selector::OnFlyoutHide()
		control:CallMethod('ModifyCustomFlyout', customflyout:GetName())
	]];
	GetCustomBinding = ([[
		local handle = customflyout:GetAttribute('flyoutParentHandle')
		local preferred = handle:GetAttribute('%s')
		if preferred then
			return preferred;
		end
		local buttonID = handle:GetAttribute('id')
		return buttonID and tostring(buttonID):match('^PAD') and buttonID or nil;
	]]):format(CPAPI.UseCustomFlyout);
	GetNumActive = [[
		wipe(BUTTONS)
		for i, child in ipairs(newtable(nativeflyout:GetChildren())) do
			if child:IsVisible()
			and child:IsProtected()
			and child:IsObjectType('CheckButton') then
				BUTTONS[#BUTTONS+1] = child
			end
		end
		for i = 1, selector:GetAttribute('numbuttons') do
			local button = selector:GetFrameRef(tostring(i))
			if button and button:IsVisible() then
				BUTTONS[#BUTTONS+1] = button;
			end
		end
		return #BUTTONS;
	]];
	PreClick = ([[
		self::UpdateSize()
		local type = %q;
		local index = self::GetIndex('Left') or self::GetIndex('Right');
		local button = index and BUTTONS[index];
		if button then
			self:CallMethod('SetOverride', button:GetParent():GetName(), false)
			local spellID = button:GetAttribute('spell')
			if spellID then
				self:SetAttribute(type, 'spell')
				self:SetAttribute('spell', spellID)
				self::ClearAndHide(false)
			else
				self:SetAttribute(type, 'macro')
				self:SetAttribute('macrotext', '/click '..button:GetName())
			end
		else
			self::ClearAndHide(true)
		end
	]]):format(CPAPI.ActionTypeRelease);
};

Selector:CreateEnvironment(Selector.PrivateEnv)
Selector:Hook(SpellFlyout, 'OnShow', Selector.PrivateEnv.OnNativeFlyoutShow)
Selector:Hook(SpellFlyout, 'OnHide', Selector.PrivateEnv.OnNativeFlyoutHide)
Selector:Wrap('PreClick', Selector.PrivateEnv.PreClick)

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function Selector:SPELL_FLYOUT_UPDATE()
	for button in self:EnumerateActive() do
		button:Update()
	end
end

---------------------------------------------------------------
-- Handler
---------------------------------------------------------------
function Selector:OnDataLoaded(...)
	local counter = CreateCounter();
	self:CreateObjectPool(function()
		return CreateFrame(
			'CheckButton',
			self:GetName()..'Button'..counter(),
			self, 'ActionButtonTemplate')
		end,
		function(_, self)
			self:Hide()
			self:ClearAllPoints()
			if self.OnClear then
				self:OnClear()
			end
		end, FlyoutButtonMixin)
	local sticks = {'Left', 'Right'};
	db.Radial:Register(self, 'SpellFlyout', {
		sticks = sticks;
		target = sticks;
		sizer  = [[
			local size = self:RunAttribute('GetNumActive')
		]];
	});
	self:OnAxisInversionChanged()
end

function Selector:OnAxisInversionChanged()
	self.axisInversion = db('radialCosineDelta')
end

db:RegisterSafeCallback('Settings/radialCosineDelta', Selector.OnAxisInversionChanged, Selector)

---------------------------------------------------------------
-- Frontend
---------------------------------------------------------------
function Selector:OnInput(x, y, len, stick)
	self:SetFocusByIndex(self:GetIndexForPos(x, y, len, self:GetNumActive()))
	self:ReflectStickPosition(self.axisInversion * x, self.axisInversion * y, len, len > self:GetValidThreshold())
end

function Selector:OnBindingSet(btn, mod)
	if ( not mod ) then
		self.buttonTrigger = btn;
	end
end

function Selector:AddButton(i, size)
	local button, newObj = self:Acquire(i)
	local p, x, y = self:GetPointForIndex(i, size)
	if newObj then
		button:RegisterForDrag('LeftButton')
		CPAPI.Start(button)
		button:SetSize(64, 64)
		button.Name:Hide()
	end
	button:SetPoint(p, x, self.axisInversion * y)
	button:SetRotation(self:GetRotation(x, y))
	button:SetID(i)
	button:Show()
	return button;
end

function Selector:SetOverride(name, enabled)
	local frame = _G[name];
	frame:SetIgnoreParentAlpha(enabled)
	local owner = frame:GetParent()
	if owner and owner.UpdateFlyout then
		owner:UpdateFlyout(false)
	end
	if not enabled and owner and owner.SetButtonState then
		owner:SetButtonState('NORMAL')
	end
end

function Selector:AddCustomButton(i, spellID, name, size)
	local button = self:AddButton(i, size)
	button:SetData({
		overrideSpellID = spellID;
		desaturated     = false;
		offSpec         = false;
		spellID         = spellID;
		spellName       = CPAPI.GetSpellInfo(spellID).name;
		owner           = _G[name];
	})
end

function Selector:ModifyCustomFlyout(name)
	local frame = _G[name]
	if frame and frame.Background then
		frame.Background:SetShown(not frame:IsShown())
	end
end

---------------------------------------------------------------
-- Buttons
---------------------------------------------------------------
local ActionButton = LibStub('ConsolePortActionButton')

function FlyoutButtonMixin:OnFocus(newFocus)
	self:LockHighlight()
	if newFocus then
		local button = self:GetParent().buttonTrigger;
		if button then
			local device = db('Gamepad/Active')
			button = device and device:GetTooltipButtonPrompt(button, USE, 64)
		end
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		GameTooltip:SetSpellByID(self.spellID)
		if button then
			GameTooltip:AddLine(button)
		end
		GameTooltip:Show()
	end
	if self.owner then
		self.owner:LockHighlight()
	end
	self:GetParent():SetActiveSliceText(self.Name:GetText())
end

function FlyoutButtonMixin:OnClear()
	self:UnlockHighlight()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
	if self.owner then
		self.owner:UnlockHighlight()
	end
	self:GetParent():SetActiveSliceText(nil)
end

function FlyoutButtonMixin:OnDragStart()
	if (self.spellID) and not InCombatLockdown() then
		CPAPI.PickupSpell(self.spellID);
		self:RegisterEvent('CURSOR_CHANGED')
	end
end

function FlyoutButtonMixin:OnEvent()
	self:SetChecked(false)
	self:UnregisterEvent('CURSOR_CHANGED')
end

FlyoutButtonMixin.OnClick = FlyoutButtonMixin.OnDragStart;

function FlyoutButtonMixin:SetData(data)
	Mixin(self, data)
	self:Update()
end

function FlyoutButtonMixin:Update()
	if not self.spellID then return end;
	SpellFlyoutButton_UpdateCooldown(self);
	SpellFlyoutButton_UpdateCount(self);
	SpellFlyoutButton_UpdateUsable(self);
	SpellFlyoutButton_UpdateState(self);

	self.icon:SetTexture(CPAPI.GetSpellTexture(self.overrideSpellID))
	self:GetNormalTexture():SetDesaturated(self.offSpec)
	self.Name:SetText(self.spellName)
	self:SetEnabled(not self.offSpec)
	ActionButton.Skin.RingButton(self)
	RunNextFrame(function()
		self:GetParent():SetSliceText(self:GetID(), self.Name:GetText())
	end)
end

---------------------------------------------------------------
-- Hook
---------------------------------------------------------------

-- signature: (self, flyoutID, parent, direction, distance, isActionBar, specID, showFullTooltip, reason)
hooksecurefunc(SpellFlyout, 'Toggle', function(flyout, flyoutID, _, _, _, isActionBar, specID, _, reason)
	local self = Selector; self:ReleaseAll();
	if not flyout:IsShown() then return end

	-- BUG: Flyout sometimes clicks the wrong button
	local active, offSpec, _, _, numSlots = {}, specID and (specID ~= 0), GetFlyoutInfo(flyoutID)
	for i=1, numSlots do
		local spellID, overrideSpellID, isKnown, spellName, slotSpecID = GetFlyoutSlotInfo(flyoutID, i)
		local visible = true

		-- ignore Call Pet spells if there isn't a pet in that slot
		local petIndex, petName = GetCallPetSpellInfo(spellID)
		if (isActionBar and petIndex and (not petName or petName == '')) then
			visible = false;
		end

		-- show buttons
		if ( (not offSpec or slotSpecID == 0) and visible and isKnown )
		or ( offSpec and slotSpecID == specID ) then
			active[#active+1] = {
				overrideSpellID = overrideSpellID;
				desaturated     = offSpec;
				offSpec         = offSpec;
				spellID         = spellID;
				spellName       = spellName;
				reason          = reason;
				owner           = _G['SpellFlyoutButton'..#active+1];
			}
		end
	end
	for i, data in ipairs(active) do
		local button = self:AddButton(i, #active)
		button:SetData(data)
	end
	self:UpdatePieSlices(true, #active)
end)

do local LAB, hookedLAB = LibStub('LibActionButton-1.0'), false;
	LAB:RegisterCallback('OnFlyoutButtonCreated', function(_, button)
		local self = Selector;
		self:SetFrameRef(tostring(button.id), button)
		self:SetAttribute('numbuttons', button.id)
		if not hookedLAB then hookedLAB = true;
			local handler = LAB.flyoutHandler;
			self:SetFrameRef('customflyout', handler)
			self:Hook(handler, 'OnShow', self.PrivateEnv.OnCustomFlyoutShow)
			self:Hook(handler, 'OnHide', self.PrivateEnv.OnCustomFlyoutHide)
			self:Run([[ customflyout = self:GetFrameRef('customflyout') ]])
		end
	end)
end