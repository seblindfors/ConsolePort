---------------------------------------------------------------
CPStateButtonMixin = CreateFromMixins(ButtonStateBehaviorMixin);
---------------------------------------------------------------

function CPStateButtonMixin:SetChecked(checked, noAnimation)
	getmetatable(self).__index.SetChecked(self, checked)
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