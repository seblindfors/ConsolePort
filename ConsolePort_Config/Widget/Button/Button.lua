local env, _, _, L = CPAPI.GetEnv(...)
---------------------------------------------------------------
CPStateButtonMixin = CreateFromMixins(ButtonStateBehaviorMixin);
---------------------------------------------------------------

function CPStateButtonMixin:SetChecked(checked, noAnimation)
	CPAPI.Index(self).SetChecked(self, checked)
	self:OnButtonStateChanged(noAnimation)
end

---------------------------------------------------------------
CPSquareIconButtonMixin = CreateFromMixins(SquareIconButtonMixin);
---------------------------------------------------------------

function CPSquareIconButtonMixin:OnLoad()
	SquareIconButtonMixin.OnLoad(self)
	self:OnMouseUp()
end

function CPSquareIconButtonMixin:OnMouseUp()
	self.Icon:SetPoint('CENTER', 0.5, 0)
end

function CPSquareIconButtonMixin:OnMouseDown()
	if self:IsEnabled() then
		self.Icon:SetPoint('CENTER', 0.5, -1);
	end
end

---------------------------------------------------------------
CPHeader = CreateFromMixins(CPStateButtonMixin); do
---------------------------------------------------------------
	local Flags = CPAPI.CreateFlags('Disabled', 'Down', 'Over', 'Collapsed')
	local Decor = {
		[Flags.Disabled + Flags.Collapsed] = {
			atlas = 'glues-characterselect-icon-plus-disabled';
			color = DISABLED_FONT_COLOR;
		};
		[Flags.Disabled] = {
			atlas = 'glues-characterselect-icon-minus-disabled';
			color = DISABLED_FONT_COLOR;
		};
		[Flags.Down + Flags.Collapsed] = {
			atlas = 'glues-characterselect-plus-pressed';
			color = HIGHLIGHT_FONT_COLOR;
		};
		[Flags.Over + Flags.Collapsed] = {
			atlas = 'glues-characterselect-icon-plus-hover';
			color = HIGHLIGHT_FONT_COLOR;
		};
		[Flags.Down] = {
			atlas = 'glues-characterselect-icon-minus-pressed';
			color = HIGHLIGHT_FONT_COLOR;
		};
		[Flags.Over] = {
			atlas = 'glues-characterselect-icon-minus-hover';
			color = HIGHLIGHT_FONT_COLOR;
		};
		[Flags.Collapsed] = {
			atlas = 'glues-characterselect-icon-plus';
			color = HIGHLIGHT_FONT_COLOR;
		};
		{ -- Default
			atlas = 'glues-characterselect-icon-minus';
			color = HIGHLIGHT_FONT_COLOR;
		};
	};
	CPHeader.Flags, CPHeader.Decor = Flags, Decor;
end

function CPHeader:OnLoad()
	local x, y = 1, -1;
	self:SetDisplacedRegions(x, y, self.Icon, self.Text);
end

function CPHeader:OnEnter()
	ButtonStateBehaviorMixin.OnEnter(self);

	self.Highlight:Show();
end

function CPHeader:OnLeave()
	ButtonStateBehaviorMixin.OnLeave(self);

	self.Highlight:Hide();
end

function CPHeader:OnClick()
	self:OnButtonStateChanged()
end

function CPHeader:OnButtonStateChanged()
	local state = self.Flags({
		Disabled  = not self:IsEnabled(),
		Down      = self:IsDown(),
		Over      = self:IsOver(),
		Collapsed = self:GetChecked(),
	}, self.Decor)
	self.Text:SetTextColor(state.color:GetRGBA())
	CPAPI.SetAtlas(self.Icon, state.atlas, TextureKitConstants.UseAtlasSize)
end

---------------------------------------------------------------
CPNavBarButton = {}; do
---------------------------------------------------------------
	local function SetVisuals(button, showBar, hilite, normal, disabled, atlasNames)
		button.Bar:SetShown(showBar)
		button.Highlight:ClearAllPoints()
		button.Highlight:SetPoint('TOPLEFT', hilite.topLeftX, hilite.topLeftY)
		button.Highlight:SetPoint('BOTTOMRIGHT', hilite.bottomRightX, hilite.bottomRightY)

		button.NormalTexture:SetPoint('TOPLEFT', normal.topLeftX, normal.topLeftY)
		button.NormalTexture:SetPoint('BOTTOMRIGHT', normal.bottomRightX, normal.bottomRightY)
		button.DisabledTexture:SetPoint('TOPLEFT', disabled.topLeftX, disabled.topLeftY)
		button.DisabledTexture:SetPoint('BOTTOMRIGHT', disabled.bottomRightX, disabled.bottomRightY)

		local resize, flipVertically = TextureKitConstants.IgnoreAtlasSize, true;
		for i, texture in ipairs({
			button.Highlight.Backdrop,
			button.Highlight.Line,
			button.NormalTexture,
			button.DisabledTexture
		}) do
			texture:SetAtlas(atlasNames[i], resize, nil, flipVertically)
		end

		local padding = 0;
		for _, offsets in ipairs({hilite, normal, disabled}) do
			padding = math.max(padding, abs(offsets.topLeftX), offsets.bottomRightX)
		end
		return padding;
	end

	function CPNavBarButton:SetMiddle()
		return SetVisuals(self, true,
			{ topLeftX = 0, topLeftY = -4, bottomRightX = 0, bottomRightY = 0 },
			{ topLeftX = 0, topLeftY =  0, bottomRightX = 0, bottomRightY = 0 },
			{ topLeftX = 0, topLeftY =  0, bottomRightX = 0, bottomRightY = 0 },
			{
				'glues-characterselect-tophud-selected-middle',
				'glues-characterselect-tophud-selected-line-middle',
				'glues-characterselect-tophud-middle-bg',
				'glues-characterselect-tophud-middle-dis-bg'
			}
		)
	end

	function CPNavBarButton:SetLeftMost()
		return SetVisuals(self, true,
			{ topLeftX =  -45, topLeftY = -4, bottomRightX = 0, bottomRightY = 0 },
			{ topLeftX = -102, topLeftY =  0, bottomRightX = 0, bottomRightY = 0 },
			{ topLeftX = -102, topLeftY =  0, bottomRightX = 0, bottomRightY = 0 },
			{
				'glues-characterselect-tophud-selected-left',
				'glues-characterselect-tophud-selected-line-left',
				'glues-characterselect-tophud-left-bg',
				'glues-characterselect-tophud-left-dis-bg'
			}
		)
	end

	function CPNavBarButton:SetRightMost()
		return SetVisuals(self, false,
			{ topLeftX = 0, topLeftY = -4, bottomRightX = 45,  bottomRightY = 0 },
			{ topLeftX = 0, topLeftY =  0, bottomRightX = 102, bottomRightY = 0 },
			{ topLeftX = 0, topLeftY =  0, bottomRightX = 102, bottomRightY = 0 },
			{
				'glues-characterselect-tophud-selected-right',
				'glues-characterselect-tophud-selected-line-right',
				'glues-characterselect-tophud-right-bg',
				'glues-characterselect-tophud-right-dis-bg'
			}
		)
	end
end

function CPNavBarButton:OnEnter()
	self.Highlight:Show()

	if self.formatButtonTextCallback then
		local enabled = true;
		local highlight = true;
		self:formatButtonTextCallback(enabled, highlight)
	end
end

function CPNavBarButton:OnLeave()
	if not self.lockHighlight then
		self.Highlight:Hide()
	end

	if self.formatButtonTextCallback then
		local enabled = true;
		local highlight = false;
		self:formatButtonTextCallback(enabled, highlight)
	end
end

function CPNavBarButton:OnEnable()
	self.NormalTexture:Show()
	self.DisabledTexture:Hide()
end

function CPNavBarButton:OnDisable()
	self.NormalTexture:Hide()
	self.DisabledTexture:Show()
end

function CPNavBarButton:SetLockHighlight(lockHighlight)
	self.lockHighlight = lockHighlight;
	self.Highlight:SetShown(lockHighlight or self:IsMouseOver())
end

function CPNavBarButton:SetFormatButtonTextCallback(formatButtonTextCallback)
	self.formatButtonTextCallback = formatButtonTextCallback;
end

---------------------------------------------------------------
CPIconSelectorButton = CreateFromMixins(SelectorButtonMixin)
---------------------------------------------------------------

function CPIconSelectorButton:OnLoad()
	self.Icon:AddMaskTexture(self.Mask)
end

function CPIconSelectorButton:OnEnter()
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	GameTooltip:SetText(ID)
	GameTooltip:AddLine(self:GetFileID(), 1, 1, 1)
	GameTooltip:Show()
end

function CPIconSelectorButton:OnLeave()
	GameTooltip:Hide()
end

function CPIconSelectorButton:SetIconTexture(iconTexture)
	SelectorButtonMixin.SetIconTexture(self, iconTexture)
	self.iconTexture = iconTexture;
end

function CPIconSelectorButton:GetFileID()
	if tonumber(self.iconTexture) then
		return tonumber(self.iconTexture)
	end
	return (self.iconTexture:match('([^\\]+)$'));
end

---------------------------------------------------------------
CPActionConfigButton = { GetBinding = nop };
---------------------------------------------------------------
CPAPI.Props(CPActionConfigButton)
	.Prop('OnClickEvent', 'OnBindingClicked')
	.Prop('SpecialClickEvent', 'OnActionSlotEdit')
	.Prop('PairText', CHOOSE)
	.Bool('PairMode', false)
	.Bool('EditMode', false)

function CPActionConfigButton:OnLoad()
	self.Icon:AddMaskTexture(self.Mask)
	self.Border:SetVertexColor(0.5, 0.5, 0.5)
	self.SelectedTexture:SetDrawLayer('BACKGROUND')
	self.Slug.separator = '\n';
end

function CPActionConfigButton:SetID(actionID)
	CPAPI.Index(self).SetID(self, actionID)
	self:Update()
end

function CPActionConfigButton:Update()
	local bindingID, actionID = self:GetBinding()
	local texture = GetActionTexture(actionID)
	local vertexc = texture and 1 or 0.25;
	self.Icon:SetTexture(texture or CPAPI.GetAsset([[Textures\Button\EmptyIcon]]))
	self.Icon:SetVertexColor(vertexc, vertexc, vertexc)
	self.Slug:SetBinding(bindingID)
	self.Name:SetText(GetActionText(actionID))
end

function CPActionConfigButton:UpdatePrompts()
	if self:IsPairMode() then
		return self:UpdatePairModePrompts()
	end
	return self:UpdateEditPrompts()
end

function CPActionConfigButton:UpdateEditPrompts()
	local useMouseHints    = not ConsolePort:IsCursorNode(self);
	local specialClickID   = useMouseHints and 'LeftClick' or 'Special';
	local specialClickText = useMouseHints and L'Double-click to Edit Slot' or L'Edit Slot';
	local cancelClickID    = useMouseHints and 'RightClick' or 'Cancel';
	local cancelClickText  = useMouseHints and L'Double-right-click to Clear Slot' or L'Clear Slot';

	local hints = {
		env:GetTooltipPromptForClick('LeftClick',    L'Edit Binding',   useMouseHints);
		env:GetTooltipPromptForClick('RightClick',   L'Remove Binding', useMouseHints);
	};
	if not self:IsEditMode() then
		tinsert(hints, env:GetTooltipPromptForClick(specialClickID, specialClickText, useMouseHints));
	end
	tinsert(hints, env:GetTooltipPromptForClick(cancelClickID, cancelClickText, useMouseHints));

	self.tooltipHints = hints;
	return hints;
end

function CPActionConfigButton:UpdatePairModePrompts()
	local useMouseHints = not ConsolePort:IsCursorNode(self);
	self.tooltipHints = {
		env:GetTooltipPromptForClick('LeftClick', self:GetPairText(), useMouseHints);
	};
	return self.tooltipHints;
end

function CPActionConfigButton:OnEnter()
	self:LockHighlight()
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	local bindingID, actionID = self:GetBinding()
	if GetActionInfo(actionID) then
		GameTooltip:SetAction(actionID)
	else
		GameTooltip:SetText(env:GetBindingName(bindingID), WHITE_FONT_COLOR:GetRGB())
	end
	GameTooltip:AddLine(('%s: %s\n'):format(
		KEY_BINDING,
		(self.Slug:GetText() or ''):gsub('\n', ' | ')),
		GameFontGreen:GetTextColor())
	for _, line in ipairs(self:UpdatePrompts()) do
		GameTooltip:AddLine(line)
	end
	GameTooltip:Show()
end

function CPActionConfigButton:OnLeave()
	self:UnlockHighlight()
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:Hide()
	end
end

function CPActionConfigButton:OnClick(button)
	if self.clickHandler then return end;
	if GetCursorInfo() then
		return PlaceAction(self:GetID())
	end
	local callback = function()
		local isClearEvent = button == 'RightButton';
		local bindingID, actionID = self:GetBinding()
		env:TriggerEvent(self:GetOnClickEvent(),
			bindingID,    -- the bindingID to be set or cleared
			isClearEvent, -- if the binding is to be cleared
			false,        -- if the binding is readonly
			self          -- the element that was clicked
		);
		self.clickHandler = nil;
	end;
	if ConsolePort:IsCursorNode(self) then
		return callback();
	end
	self.clickHandler = C_Timer.NewTimer(0.25, callback)
end

function CPActionConfigButton:OnDoubleClick(button)
	if self.clickHandler then
		self.clickHandler = self.clickHandler:Cancel()
	end
	if button == 'RightButton' then
		return self:OnCancelClick()
	end
	self:OnSpecialClick()
end

function CPActionConfigButton:OnSpecialClick()
	if self:IsPairMode() or self:IsEditMode() then return end;
	local bindingID, actionID = self:GetBinding()
	env:TriggerEvent(self:GetSpecialClickEvent(),
		actionID,  -- the actionID to be changed
		bindingID, -- the bindingID that owns the slot
		self       -- the element that was clicked
	)
end

function CPActionConfigButton:OnCancelClick()
	if self:IsPairMode() then return end;
	self:OnDragStart()
	ClearCursor()
end

function CPActionConfigButton:OnDragStart()
	local actionID = self:GetID()
	if not actionID then return end;
	PickupAction(actionID)
end

function CPActionConfigButton:OnReceiveDrag()
	local actionID = self:GetID()
	if not actionID then return end;
	PlaceAction(actionID)
end