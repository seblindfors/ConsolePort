local db, _, env = ConsolePort:DB(), ...;
local Mapper = CreateFromMixins(env.ScaleToContentMixin, env.FlexibleMixin, env.BindingInfoMixin, env.BindingInfoMixin)
local ActionMapper = CreateFromMixins(env.ScaleToContentMixin)
env.BindingMapper = Mapper;

---------------------------------------------------------------
-- Mapper
---------------------------------------------------------------
function Mapper:OnLoad()
	env.OpaqueMixin.OnLoad(self)
	self:SetFlexibleElement(self, self.Child)
	self:SetMeasurementOrigin(self.Child, self.Child, 360, 20)

	self.Action = Mixin(CreateFrame('IndexButton', nil, self.Child, 'CPIndexButtonBindingHeaderTemplate'), ActionMapper)
	self.Action:OnLoad()

	self.ActionTooltip = CreateFrame('GameTooltip',
		'ConsolePortConfigBindingMapperTooltip', self.Child, 'GameTooltipTemplate');
	-- HACK: call SetBackdrop on show with nil value, since OnShow has no args.
	self.ActionTooltip:HookScript('OnShow', self.ActionTooltip.SetBackdrop)
	-- HACK: move action texture from another widget to the tooltip.
	self.Child.Info.ActionIcon:ClearAllPoints()
	self.Child.Info.ActionIcon:SetPoint('TOPRIGHT', self.ActionTooltip, 'TOPLEFT', -8, 0)
	CPAPI.Start(self)
end

function Mapper:OnEvent(event, ...)
	if (event == 'UPDATE_BINDINGS' or event == 'ACTIONBAR_SLOT_CHANGED') then
		self:SetBindingInfo(self:GetBinding())
	end
end

---------------------------------------------------------------
-- Binding content handling
---------------------------------------------------------------
function Mapper:SetBindingInfo(binding, transposedActionID)
	local info, change = self.Child.Info, self.Child.Change;
	if binding then
		local name = self:GetBindingName(binding)
		local label, texture, actionID = self:GetBindingInfo(binding, true)
		local slug, data = db('Hotkeys'):GetButtonSlugForBinding(binding)
		texture = actionID and GetActionTexture(transposedActionID or actionID)

		-- Set the text for the transposed action ID, make it clear
		-- which action page this widget was coming from.
		if transposedActionID then
			local page = math.ceil(transposedActionID/NUM_ACTIONBAR_BUTTONS)
			page = WrapTextInColorCode(('('..PAGE_NUMBER..')'):format(page), 'FF999999')
			label = ('%s %s'):format(label, page)

			local tooltip = self.ActionTooltip;
			tooltip:SetOwner(self.Action, "ANCHOR_NONE")
			tooltip:SetPoint('TOP', self.Action, 'BOTTOM', 0, -10)
			tooltip:SetAction(transposedActionID)
			tooltip:Show()
		else
			self.ActionTooltip:Hide()
		end

		change.Slug:SetText(slug or WrapTextInColorCode(NOT_BOUND, 'FF757575'))
		info.Label:SetText(label)
		info.ActionIcon:SetAlpha(texture and 1 or 0)
		info.Mask:SetAlpha(texture and 1 or 0)
		info.ActionIcon:SetTexture(texture)
	end
--	self:UpdateScrollChildRect()
	self.Child:SetHeight(700)
--	self:ScaleToContent()
end

---------------------------------------------------------------
-- Focused widget
---------------------------------------------------------------
function Mapper:SetFocus(widget)
	self.focusWidget = widget;
	local binding = widget and widget:GetBinding();
	if binding and not db('Gamepad'):GetBindingKey(binding) then
		self:SetCatchButton(true)
	else
		self:SetCatchButton(false)
	end
end

function Mapper:GetFocus()
	return self.focusWidget;
end

function Mapper:ClearFocus()
	if self.focusWidget then
		self.focusWidget:SetChecked(false)
		CPIndexButtonMixin.OnChecked(self.focusWidget, false)
		self.focusWidget = nil;
	end
end

function Mapper:GetBinding()
	return self:GetFocus():GetBinding()
end

function Mapper:IsWidgetFocused(widget)
	return (widget and self:GetFocus() == widget)
end

function Mapper:ToggleWidget(widget, show)
	if self:IsWidgetFocused(widget) then
		self:ClearFocus()
	elseif widget then
		self:ClearFocus()
		self:SetFocus(widget)
	else
		self:ClearFocus()
	end
	self:OnWidgetSet(self:GetFocus())
end

function Mapper:OnWidgetSet(widget)
	self:ToggleFlex(widget)
	if widget then
		self:SetBindingInfo(widget:GetBinding())
		--print(widget:GetBinding())
		--print(widget:GetAction())
		self:RegisterEvent('UPDATE_BINDINGS')
		self:RegisterEvent('ACTIONBAR_SLOT_CHANGED')
	else
		self:SetCatchButton(false)
		self:UnregisterAllEvents()
	end
	-- todo
end

---------------------------------------------------------------
-- Binding catch, set, clear olds
---------------------------------------------------------------
function Mapper:ClearKeys(key, ...)
	if key then
		SetBinding(key, nil)
		self:ClearKeys(...)
	end
end

function Mapper:ClearBinding()
	local binding = self:GetBinding()
	self:ClearKeys(db('Gamepad'):GetBindingKey(binding))
end

function Mapper:SetBinding(keychord)
	local binding, transposedActionID = self:GetBinding()
	if not db('bindingOverlapEnable') then
		self:ClearKeys(db('Gamepad'):GetBindingKey(binding))
	end
	SetBinding(keychord, binding)
	self:SetBindingInfo(binding, transposedActionID)
end

function Mapper:SetCatchButton(enabled)
	self.Child.Catch:SetShown(enabled)
	if enabled then
		local binding = self:GetBinding()
		local name = binding and self:GetBindingName(binding)
		self.Child.Help:SetBindingHelp(name)
	else
		self.Child.Help:SetDefaultHelp()
	end
end

function Mapper:OnButtonCaught(...)
	self:SetBinding(CreateKeyChordStringUsingMetaKeyState(...))
end

---------------------------------------------------------------
-- Action mapper
---------------------------------------------------------------
function ActionMapper:OnLoad()
	--C_ActionBar.PutActionInSlot
	--C_ActionBar.FindFlyoutActionButtons
	--C_ActionBar.FindSpellActionButtons
	self:SetPoint('TOP', self:GetParent().Change, 'BOTTOM', 0, -10)
	self:SetSize(340, 40)
	-- HACK: "Ability", let's hope this is all good on all locales
	self:SetText(COMBATLOG_HIGHLIGHT_ABILITY)
end