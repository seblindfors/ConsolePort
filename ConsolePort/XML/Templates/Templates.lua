CPFrameWithTooltipMixin = {}

function CPFrameWithTooltipMixin:OnLoad()
	if self.simpleTooltipLine then
		self:AddTooltipLine(self.simpleTooltipLine, HIGHLIGHT_FONT_COLOR)
	end
end

function CPFrameWithTooltipMixin:ClearTooltipLines()
	self.tooltipLines = nil
end

function CPFrameWithTooltipMixin:AddTooltipLine(lineText, lineColor)
	if not self.tooltipLines then
		self.tooltipLines = {}
	end

	table.insert(self.tooltipLines, {text = lineText, color = lineColor or NORMAL_FONT_COLOR})
end

function CPFrameWithTooltipMixin:AddBlankTooltipLine()
	self:AddTooltipLine(' ')
end

function CPFrameWithTooltipMixin:GetAppropriateTooltip()
	return CPNoHeaderTooltip
end

function CPFrameWithTooltipMixin:SetupAnchors(tooltip)
	if self.tooltipAnchor == 'ANCHOR_TOPRIGHT' then
		tooltip:SetOwner(self, 'ANCHOR_NONE')
		tooltip:SetPoint('TOPLEFT', self, 'TOPRIGHT', self.tooltipXOffset, self.tooltipYOffset)
	elseif self.tooltipAnchor == 'ANCHOR_TOPLEFT' then
		tooltip:SetOwner(self, 'ANCHOR_NONE')
		tooltip:SetPoint('TOPRIGHT', self, 'TOPLEFT', -self.tooltipXOffset, self.tooltipYOffset)
	elseif self.tooltipAnchor == 'ANCHOR_BOTTOMRIGHT' then
		tooltip:SetOwner(self, 'ANCHOR_NONE')
		tooltip:SetPoint('TOPLEFT', self, 'BOTTOMRIGHT', self.tooltipXOffset, self.tooltipYOffset)
	elseif self.tooltipAnchor == 'ANCHOR_BOTTOMLEFT' then
		tooltip:SetOwner(self, 'ANCHOR_NONE')
		tooltip:SetPoint('TOPRIGHT', self, 'BOTTOMLEFT', -self.tooltipXOffset, self.tooltipYOffset)
	else
		tooltip:SetOwner(self, self.tooltipAnchor, self.tooltipXOffset, self.tooltipYOffset)
	end
end

function CPFrameWithTooltipMixin:AddExtraStuffToTooltip()
end

function CPFrameWithTooltipMixin:OnEnter()
	if self.tooltipLines then
		local tooltip = self:GetAppropriateTooltip()

		self:SetupAnchors(tooltip)

		if self.tooltipMinWidth then
			tooltip:SetMinimumWidth(self.tooltipMinWidth)
		end

		if self.tooltipPadding then
			tooltip:SetPadding(self.tooltipPadding, self.tooltipPadding, self.tooltipPadding, self.tooltipPadding)
		end

		for _, lineInfo in ipairs(self.tooltipLines) do
			GameTooltip_AddColoredLine(tooltip, lineInfo.text, lineInfo.color)
		end

		self:AddExtraStuffToTooltip()

		tooltip:Show()
	end
end

function CPFrameWithTooltipMixin:OnLeave()
	local tooltip = self:GetAppropriateTooltip()
	tooltip:Hide()
end


CPMaskedButtonMixin = CreateFromMixins(CPFrameWithTooltipMixin)

function CPMaskedButtonMixin:OnLoad()
	CPFrameWithTooltipMixin.OnLoad(self)

	self.CircleMask:SetPoint('TOPLEFT', self, 'TOPLEFT', self.circleMaskSizeOffset, -self.circleMaskSizeOffset)
	self.CircleMask:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -self.circleMaskSizeOffset, self.circleMaskSizeOffset)

	local hasRingSizes = self.ringWidth and self.ringHeight
	if hasRingSizes then
		CPAPI.SetAtlas(self.Ring, self.ringAtlas)
		CPAPI.SetAtlas(self.Flash.Ring, self.ringAtlas)
		CPAPI.SetAtlas(self.Flash.Ring2, self.ringAtlas)
		self.Ring:SetSize(self.ringWidth, self.ringHeight)
		self.Flash.Ring:SetSize(self.ringWidth, self.ringHeight)
		self.Flash.Ring2:SetSize(self.ringWidth, self.ringHeight)
	else
		CPAPI.SetAtlas(self.Ring, self.ringAtlas, true)
		CPAPI.SetAtlas(self.Flash.Ring, self.ringAtlas, true)
		CPAPI.SetAtlas(self.Flash.Ring2, self.ringAtlas, true)
	end

	self.NormalTexture:AddMaskTexture(self.CircleMask)
	self.PushedTexture:AddMaskTexture(self.CircleMask)
	self.DisabledOverlay:AddMaskTexture(self.CircleMask)
	self.DisabledOverlay:SetAlpha(self.disabledOverlayAlpha)
	self.CheckedTexture:SetSize(self.checkedTextureSize, self.checkedTextureSize)
	self.Flash.Portrait:AddMaskTexture(self.CircleMask)

	if self.flipTextures then
		self.NormalTexture:SetTexCoord(1, 0, 0, 1)
		self.PushedTexture:SetTexCoord(1, 0, 0, 1)
		self.Flash.Portrait:SetTexCoord(1, 0, 0, 1)
	end

	if self.BlackBG then
		self.BlackBG:AddMaskTexture(self.CircleMask)
	end
end

function CPMaskedButtonMixin:SetIconAtlas(atlas)
	self:SetNormalAtlas(atlas)
	self:SetPushedAtlas(atlas)
	self.Flash.Portrait:SetAtlas(atlas)
end

function CPMaskedButtonMixin:SetIcon(texture)
	local default = not texture and [[Interface\AddOns\ConsolePort\Textures\Button\EmptyIcon]]
	self:SetNormalTexture(texture or default)
	self:SetPushedTexture(texture or default)
	self.Flash.Portrait:SetTexture(texture or default)
end

function CPMaskedButtonMixin:StartFlash()
	self.Flash:Show()
	self.Flash.Anim:Play()
end

function CPMaskedButtonMixin:StopFlash()
	self.Flash.Anim:Stop()
	self.Flash:Hide()
end

function CPMaskedButtonMixin:SetEnabledState(enabled)
	self:SetEnabled(enabled)

	local normalTex = self:GetNormalTexture()
	if normalTex then
		normalTex:SetDesaturated(not enabled)
	end

	self.Ring:SetAtlas(self.ringAtlas..(enabled and '' or 'disabled'))

	self.DisabledOverlay:SetShown(not enabled)
end

function CPMaskedButtonMixin:OnMouseDown(button)
	if self:IsEnabled() then
		self.CheckedTexture:SetPoint('CENTER', self, 'CENTER', 0, -1)
		self.CircleMask:SetPoint('TOPLEFT', self.PushedTexture, 'TOPLEFT', self.circleMaskSizeOffset, -self.circleMaskSizeOffset)
		self.CircleMask:SetPoint('BOTTOMRIGHT', self.PushedTexture, 'BOTTOMRIGHT', -self.circleMaskSizeOffset, self.circleMaskSizeOffset)
		self.Ring:SetPoint('CENTER', self, 'CENTER', 0, -1)
		self.Flash:SetPoint('CENTER', self, 'CENTER', 0, -1)
	end
end

function CPMaskedButtonMixin:OnMouseUp(button)
	if button == 'RightButton' and self.expandedTooltipFrame then
		tooltipsExpanded = not tooltipsExpanded
		if GetMouseFocus() == self then
			self:OnEnter()
		end
	end

	self.CheckedTexture:SetPoint('CENTER')
	self.CircleMask:SetPoint('TOPLEFT', self.NormalTexture, 'TOPLEFT', self.circleMaskSizeOffset, -self.circleMaskSizeOffset)
	self.CircleMask:SetPoint('BOTTOMRIGHT', self.NormalTexture, 'BOTTOMRIGHT', -self.circleMaskSizeOffset, self.circleMaskSizeOffset)
	self.Ring:SetPoint('CENTER')
	self.Flash:SetPoint('CENTER')
end

function CPMaskedButtonMixin:UpdateHighlightTexture()
	if self:GetChecked() then
		CPAPI.SetAtlas(self.HighlightTexture, 'ring-select')
		self.HighlightTexture:SetPoint('TOPLEFT', self.CheckedTexture)
		self.HighlightTexture:SetPoint('BOTTOMRIGHT', self.CheckedTexture)
	else
		CPAPI.SetAtlas(self.HighlightTexture, self.ringAtlas)
		self.HighlightTexture:SetPoint('TOPLEFT', self.Ring)
		self.HighlightTexture:SetPoint('BOTTOMRIGHT', self.Ring)
	end
end


CPButtonMixin = CreateFromMixins(CPMaskedButtonMixin)

function CPButtonMixin:OnClick()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS)
end

function CPButtonMixin:SetDescription(text)
	self.Description:SetText(text)
end

function CPButtonMixin:SetEnabledState(enabled)
	CPMaskedButtonMixin.SetEnabledState(self, enabled)
	self.Description:SetFontObject(enabled and 'GameFontNormalMed3' or 'GameFontDisableMed3')
end

function CPButtonMixin:OnEnter()
	CPFrameWithTooltipMixin.OnEnter(self)
end

function CPButtonMixin:OnLeave()
	CPFrameWithTooltipMixin.OnLeave(self)
end

CPSelectionPopoutWithButtonsAndLabelMixin = {};

function CPSelectionPopoutWithButtonsAndLabelMixin:SetupSelections(selections, selectedIndex, label)
	self.SelectionPopoutButton:SetupSelections(selections, selectedIndex);
	self.Label:SetText(label);
	self:UpdateButtons();
end

function CPSelectionPopoutWithButtonsAndLabelMixin:OnEnter()
end

function CPSelectionPopoutWithButtonsAndLabelMixin:OnLeave()
end

function CPSelectionPopoutWithButtonsAndLabelMixin:Increment()
	self.SelectionPopoutButton:Increment();
end

function CPSelectionPopoutWithButtonsAndLabelMixin:Decrement()
	self.SelectionPopoutButton:Decrement();
end

function CPSelectionPopoutWithButtonsAndLabelMixin:OnPopoutShown()
end

function CPSelectionPopoutWithButtonsAndLabelMixin:HidePopout()
	self.SelectionPopoutButton:HidePopout();
end

function CPSelectionPopoutWithButtonsAndLabelMixin:OnEntryClick(entryData)
end

function CPSelectionPopoutWithButtonsAndLabelMixin:GetTooltipText()
	return self.SelectionPopoutButton:GetTooltipText();
end

function CPSelectionPopoutWithButtonsAndLabelMixin:OnEntryMouseEnter(entry)
end

function CPSelectionPopoutWithButtonsAndLabelMixin:OnEntryMouseLeave(entry)
end

function CPSelectionPopoutWithButtonsAndLabelMixin:GetMaxPopoutHeight()
end

function CPSelectionPopoutWithButtonsAndLabelMixin:UpdateButtons()
	self.IncrementButton:SetEnabled(self.SelectionPopoutButton.selectedIndex < #self.SelectionPopoutButton.selections);
	self.DecrementButton:SetEnabled(self.SelectionPopoutButton.selectedIndex > 1);
end

CPSelectionPopoutButtonMixin = {};
local CreateAnchor = AnchorUtil.CreateAnchor;
local CreateGridLayout = AnchorUtil.CreateGridLayout;

function CPSelectionPopoutButtonMixin:OnLoad()
	self.parent = self:GetParent();
	self.SelectionDetails:SetPoint('CENTER', self.ButtonText, 'CENTER');

	self.buttonPool = CreateFramePool('BUTTON', self.Popout, 'CPSelectionPopoutEntryTemplate');
	self.initialAnchor = CreateAnchor('TOPLEFT', self.Popout, 'TOPLEFT', 6, -12);

	CPAPI.SetAtlas(self.NormalTexture, 'customize-dropdownbox')
	CPAPI.SetAtlas(self.HighlightTexture, 'customize-dropdownbox-open')
end

function CPSelectionPopoutButtonMixin:HandlesGlobalMouseEvent()
	return true;
end

function CPSelectionPopoutButtonMixin:OnEnter()
	self.parent:OnEnter();
	if not self.Popout:IsShown() then
		CPAPI.SetAtlas(self.NormalTexture, 'customize-dropdownbox-hover');
	end
end

function CPSelectionPopoutButtonMixin:OnLeave()
	self.parent:OnLeave();
	if not self.Popout:IsShown() then
		CPAPI.SetAtlas(self.NormalTexture, 'customize-dropdownbox');
	end
end

function CPSelectionPopoutButtonMixin:OnPopoutShown()
	if self.parent.OnPopoutShown then
		self.parent:OnPopoutShown();
	end
end

function CPSelectionPopoutButtonMixin:OnHide()
	self:HidePopout();
end

function CPSelectionPopoutButtonMixin:HidePopout()
	self.Popout:Hide();

	if GetMouseFocus() == self then
		CPAPI.SetAtlas(self.NormalTexture, 'customize-dropdownbox-hover');
	else
		CPAPI.SetAtlas(self.NormalTexture, 'customize-dropdownbox');
	end

	self.HighlightTexture:SetAlpha(0);
end

function CPSelectionPopoutButtonMixin:ShowPopout()
	if self.popoutNeedsUpdate then
		self:UpdatePopout();
	end

	self.Popout:Show();
	CPAPI.SetAtlas(self.NormalTexture, 'customize-dropdownbox-open');
	self.HighlightTexture:SetAlpha(0.2);
end

function CPSelectionPopoutButtonMixin:SetupSelections(selections, selectedIndex)
	self.selections = selections;
	self.selectedIndex = selectedIndex;

	if self.Popout:IsShown() then
		self:UpdatePopout();
	else
		self.popoutNeedsUpdate = true;
	end

	self:UpdateButtonDetails();
end

local MAX_POPOUT_ENTRIES_FOR_1_COLUMN = 10;
local MAX_POPOUT_ENTRIES_FOR_2_COLUMNS = 24;
local MAX_POPOUT_ENTRIES_FOR_3_COLUMNS = 36;

local function getNumColumnsAndStride(numSelections, maxStride)
	local numColumns, stride;
	if numSelections > MAX_POPOUT_ENTRIES_FOR_3_COLUMNS then
		numColumns, stride = 4, math.ceil(numSelections / 4);
	elseif numSelections > MAX_POPOUT_ENTRIES_FOR_2_COLUMNS then
		numColumns, stride = 3, math.ceil(numSelections / 3);
	elseif numSelections > MAX_POPOUT_ENTRIES_FOR_1_COLUMN then
		numColumns, stride =  2, math.ceil(numSelections / 2);
	else
		numColumns, stride =  1, numSelections;
	end

	if maxStride and stride > maxStride then
		numColumns = math.ceil(numSelections / maxStride);
		stride = math.ceil(numSelections / numColumns);
	end

	return numColumns, stride;
end

function CPSelectionPopoutButtonMixin:GetMaxPopoutStride()
	local maxPopoutHeight = self:GetParent():GetMaxPopoutHeight();
	if maxPopoutHeight then
		local selectionHeight = 20;
		return math.floor(maxPopoutHeight / selectionHeight);
	end
end

function CPSelectionPopoutButtonMixin:UpdatePopout()
	self.buttonPool:ReleaseAll();

	local numColumns, stride = getNumColumnsAndStride(#self.selections, self:GetMaxPopoutStride());
	local buttons = {};

	local hasIneligibleChoice = false;
	for _, selectionData in ipairs(self.selections) do
		if selectionData.ineligibleChoice then
			hasIneligibleChoice = true;
			break;
		end
	end

	local maxDetailsWidth = 0;
	for index, selectionData in ipairs(self.selections) do
		local button = self.buttonPool:Acquire();
		local selectionInfo = self.selections[index];

		local isSelected = (index == self.selectedIndex);
		button:SetupEntry(selectionInfo, index, isSelected, numColumns > 1, hasIneligibleChoice);
		maxDetailsWidth = math.max(maxDetailsWidth, button.SelectionDetails:GetWidth());

		table.insert(buttons, button);
	end

	for _, button in ipairs(buttons) do
		button.SelectionDetails:SetWidth(maxDetailsWidth);
		button:Layout();
		button:Show();
	end

	if stride ~= self.lastStride then
		self.layout = CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRightVertical, stride);
		self.lastStride = stride;
	end

	AnchorUtil.GridLayout(buttons, self.initialAnchor, self.layout);

	self.popoutNeedsUpdate = false;
end

function CPSelectionPopoutButtonMixin:GetCurrentSelectedData()
	return self.selections[self.selectedIndex];
end

function CPSelectionPopoutButtonMixin:UpdateButtonDetails()
	local currentSelectedData = self:GetCurrentSelectedData();
	self.SelectionDetails:SetupDetails(currentSelectedData, self.selectedIndex);
	local maxNameWidth = 126;
	if self.SelectionDetails.SelectionName:GetWidth() > maxNameWidth then
		self.SelectionDetails.SelectionName:SetWidth(maxNameWidth);
	end
	self.SelectionDetails:Layout();
end

function CPSelectionPopoutButtonMixin:GetTooltipText()
	return self.SelectionDetails:GetTooltipText();
end

function CPSelectionPopoutButtonMixin:TogglePopout()
	local showPopup = not self.Popout:IsShown();
	if showPopup then
		self:ShowPopout();
	else
		self:HidePopout();
	end
end

function CPSelectionPopoutButtonMixin:OnMouseWheel(delta)
	if delta > 0 then
		self:Increment();
	else
		self:Decrement();
	end
end

function CPSelectionPopoutButtonMixin:OnClick()
	self:TogglePopout();
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

function CPSelectionPopoutButtonMixin:OnEntryClick(entryData)
	if self.parent.OnEntryClick then
		self.parent:OnEntryClick(entryData);
	end

	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

function CPSelectionPopoutButtonMixin:OnEntryMouseEnter(entry)
	if self.parent.OnEntryMouseEnter then
		self.parent:OnEntryMouseEnter(entry);
	end
end

function CPSelectionPopoutButtonMixin:OnEntryMouseLeave(entry)
	if self.parent.OnEntryMouseLeave then
		self.parent:OnEntryMouseLeave(entry);
	end
end

function CPSelectionPopoutButtonMixin:Increment()
	local newIndex = math.min(self.selectedIndex + 1, #self.selections);
	if newIndex ~= self.selectedIndex then
		self.selectedIndex = newIndex;
		self:OnEntryClick(self:GetCurrentSelectedData());
	end
end

function CPSelectionPopoutButtonMixin:Decrement()
	local newIndex = math.max(self.selectedIndex - 1, 1);
	if newIndex ~= self.selectedIndex then
		self.selectedIndex = newIndex;
		self:OnEntryClick(self:GetCurrentSelectedData());
	end
end

CPSelectionPopoutDetailsMixin = {};

function CPSelectionPopoutDetailsMixin:OnLoad()
	CPAPI.SetAtlas(self.ColorSwatch1, 'customize-palette', true)
	CPAPI.SetAtlas(self.ColorSwatch2, 'customize-palette', false)
	CPAPI.SetAtlas(self.ColorSwatch1Glow, 'customize-palette-glow', true)
	CPAPI.SetAtlas(self.ColorSwatch2Glow, 'customize-palette-glow', false)
	CPAPI.SetAtlas(self.ColorSelected, 'customize-palette-selected', true)
end

function CPSelectionPopoutDetailsMixin:GetTooltipText()
	if self.SelectionName:IsShown() and self.SelectionName:IsTruncated() then
		return self.name;
	end

	return nil;
end

function CPSelectionPopoutDetailsMixin:AdjustWidth(multipleColumns, defaultWidth)
	local width = defaultWidth;

	if self.ColorSwatch1:IsShown() or self.ColorSwatch2:IsShown() then
		if multipleColumns then
			width = self.SelectionNumber:GetWidth() + self.ColorSwatch2:GetWidth() + 18;
		end
	elseif self.SelectionName:IsShown() then
		if multipleColumns then
			width = 108;
		end
	else
		if multipleColumns then
			width = 42;
		end
	end

	self:SetWidth(Round(width));
end

local function GetNormalSelectionTextFontColor(selectionData, isSelected)
	if isSelected then
		return NORMAL_FONT_COLOR;
	else
		return DISABLED_FONT_COLOR;
	end
end

local eligibleChoiceColor = CreateColor(.808, 0.808, 0.808);
local ineligibleChoiceColor = CreateColor(.337, 0.337, 0.337);

local function GetFailedReqSelectionTextFontColor(selectionData, isSelected)
	if isSelected then
		return NORMAL_FONT_COLOR;
	elseif selectionData.ineligibleChoice then
		return ineligibleChoiceColor;
	else
		return eligibleChoiceColor;
	end
end

function CPSelectionPopoutDetailsMixin:SetupDetails(selectionData, index, isSelected, hasAFailedReq)
	self.name = selectionData.name;
	self.index = index;

	local color1 = selectionData.swatchColor1 or selectionData.swatchColor2;
	local color2 = selectionData.swatchColor1 and selectionData.swatchColor2;
	if color1 then
		if color2 then
			self.ColorSwatch2:Show();
			self.ColorSwatch2Glow:Show();
			self.ColorSwatch2:SetVertexColor(color2:GetRGB());
			CPAPI.SetAtlas(self.ColorSwatch1, 'customize-palette-half');
		else
			self.ColorSwatch2:Hide();
			self.ColorSwatch2Glow:Hide();
			CPAPI.SetAtlas(self.ColorSwatch1, 'customize-palette');
		end

		self.ColorSwatch1:Show();
		self.ColorSwatch1Glow:Show();
		self.ColorSwatch1:SetVertexColor(color1:GetRGB());

		self.SelectionName:Hide();
		self.SelectionNumber:SetWidth(25);
	elseif selectionData.name ~= '' then
		self.ColorSwatch1:Hide();
		self.ColorSwatch1Glow:Hide();
		self.ColorSwatch2:Hide();
		self.ColorSwatch2Glow:Hide();
		self.SelectionName:Show();
		self.SelectionName:SetWidth(0);
		self.SelectionName:SetText(selectionData.name);
		self.SelectionNumber:SetWidth(25);
	else
		self.ColorSwatch1:Hide();
		self.ColorSwatch1Glow:Hide();
		self.ColorSwatch2:Hide();
		self.ColorSwatch2Glow:Hide();
		self.SelectionName:Hide();
		self.SelectionNumber:SetWidth(0);
	end

	if isSelected ~= nil then
		local fontColorFunction = hasAFailedReq and GetFailedReqSelectionTextFontColor or GetNormalSelectionTextFontColor;
		local fontColor = fontColorFunction(selectionData, isSelected);
		self.SelectionNumber:SetTextColor(fontColor:GetRGB());
		self.SelectionName:SetTextColor(fontColor:GetRGB());
		self.ColorSelected:SetShown(color1 and isSelected);
	end

	local hideNumber = ((isSelected == nil) and (color1 or (selectionData.name ~= '')));
	if hideNumber then
		self.SelectionNumber:Hide();
		self.SelectionName:SetPoint('LEFT', self, 'LEFT', 0, 0);
		self.ColorSwatch1:SetPoint('LEFT', self, 'LEFT', 0, 0);
		self.ColorSwatch2:SetPoint('LEFT', self, 'LEFT', 18, -2);
	else
		self.SelectionNumber:Show();
		self.SelectionNumber:SetText(index);
		self.SelectionName:SetPoint('LEFT', self.SelectionNumber, 'RIGHT', 0, 0);
		self.ColorSwatch1:SetPoint('LEFT', self.SelectionNumber, 'RIGHT', 0, 0);
		self.ColorSwatch2:SetPoint('LEFT', self.SelectionNumber, 'RIGHT', 18, -2);
	end
end

CPSelectionPopoutMixin = {};

function CPSelectionPopoutMixin:OnShow()
	if not CPAPI.IsRetailVersion then
		self.Border.layoutType = 'ChatBubble';
		self.Border:OnLoad()

		self.heightPadding = 12;
		self.widthPadding  = 6;
	end

	self:Layout();
	self:GetParent():OnPopoutShown();
end

CPSelectionPopoutEntryMixin = {};

function CPSelectionPopoutEntryMixin:OnLoad()
	self.SelectionDetails:SetPoint('TOPLEFT', self.ButtonText,'TOPLEFT', 14, 0);
	self.SelectionDetails.SelectionName:SetPoint('RIGHT', self.SelectionDetails, 'RIGHT');
	self.parentButton = self:GetParent():GetParent();

	CPAPI.SetAtlas(self.HighlightBGTex.Left, 'customize-dropdown-linemouseover-side', true)
	CPAPI.SetAtlas(self.HighlightBGTex.Right, 'customize-dropdown-linemouseover-side', true, true)
	CPAPI.SetAtlas(self.HighlightBGTex.Middle, 'customize-dropdown-linemouseover-middle', true)
end

function CPSelectionPopoutEntryMixin:HandlesGlobalMouseEvent(buttonID, event)
	return event == 'GLOBAL_MOUSE_DOWN' and buttonID == 'LeftButton';
end

function CPSelectionPopoutEntryMixin:SetupEntry(selectionData, index, isSelected, multipleColumns, hasAFailedReq)
	self.isSelected = isSelected;
	self.selectionData = selectionData;
	self.popoutHasAFailedReq = hasAFailedReq;

	self.SelectionDetails:SetupDetails(selectionData, index, isSelected, hasAFailedReq);
	self.SelectionDetails:AdjustWidth(multipleColumns, 116);
end

function CPSelectionPopoutEntryMixin:GetTooltipText()
	return self.SelectionDetails:GetTooltipText();
end

function CPSelectionPopoutEntryMixin:OnEnter()
	if not self.isSelected then
		self.HighlightBGTex:SetAlpha(0.15);
		self.SelectionDetails.SelectionNumber:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		self.SelectionDetails.SelectionName:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	end

	self.parentButton:OnEntryMouseEnter(self);
end

function CPSelectionPopoutEntryMixin:OnLeave()
	if not self.isSelected then
		self.HighlightBGTex:SetAlpha(0);

		local fontColorFunction = self.popoutHasAFailedReq and GetFailedReqSelectionTextFontColor or GetNormalSelectionTextFontColor;
		local fontColor = fontColorFunction(self.selectionData, self.isSelected);
		self.SelectionDetails.SelectionNumber:SetTextColor(fontColor:GetRGB());
		self.SelectionDetails.SelectionName:SetTextColor(fontColor:GetRGB());
	end

	self.parentButton:OnEntryMouseLeave(self);
end

function CPSelectionPopoutEntryMixin:OnClick()
	self.parentButton:OnEntryClick(self.selectionData);
end

CPResizeLayoutMixin = CreateFromMixins(ResizeLayoutMixin);
if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
	local function GetExtents(childFrame, left, right, top, bottom, layoutFrameScale)
		local frameLeft, frameBottom, frameWidth, frameHeight = GetUnscaledFrameRect(childFrame, layoutFrameScale);
		local frameRight = frameLeft + frameWidth;
		local frameTop = frameBottom + frameHeight;

		left = left and math.min(frameLeft, left) or frameLeft;
		right = right and math.max(frameRight, right) or frameRight;
		top = top and math.max(frameTop, top) or frameTop;
		bottom = bottom and math.min(frameBottom, bottom) or frameBottom;

		return left, right, top, bottom;
	end

	local function GetSize(desired, fixed, minimum, maximum)
		return fixed or Clamp(desired, minimum or desired, maximum or desired);
	end

	local function IsLayoutFrame(f)
		return f.IsLayoutFrame and f:IsLayoutFrame();
	end

	function CPResizeLayoutMixin:AddLayoutChildren(layoutChildren, ...)
		for i = 1, select("#", ...) do
			local region = select(i, ...);
			if region:IsShown() and not region.ignoreInLayout and (self:IgnoreLayoutIndex() or region.layoutIndex) then
				layoutChildren[#layoutChildren + 1] = region;
			end
		end
	end

	function CPResizeLayoutMixin:GetAdditionalRegions()
		-- optional;
	end

	function CPResizeLayoutMixin:GetLayoutChildren()
		local children = {};
		self:AddLayoutChildren(children, self:GetChildren());
		self:AddLayoutChildren(children, self:GetRegions());
		self:AddLayoutChildren(children, self:GetAdditionalRegions());
		if not self:IgnoreLayoutIndex() then
			table.sort(children, LayoutIndexComparator);
		end

		return children;
	end

	function CPResizeLayoutMixin:IgnoreLayoutIndex()
		return true;
	end

	function CPResizeLayoutMixin:Layout()
		-- GetExtents will fail if the LayoutFrame has 0 width or height, so set them to 1 to start
		self:SetSize(1, 1);

		-- GetExtents will also fail if the LayoutFrame has no anchors set, so if that is the case, set an anchor and then clear it after we are done
		local hadNoAnchors = (self:GetNumPoints() == 0);
		if hadNoAnchors then
			self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0);
		end

		local left, right, top, bottom;
		local layoutFrameScale = self:GetEffectiveScale();
		for childIndex, child in ipairs(self:GetLayoutChildren()) do
			if IsLayoutFrame(child) then
				child:Layout();
			end

			left, right, top, bottom = GetExtents(child, left, right, top, bottom, layoutFrameScale);
		end

		if left and right and top and bottom then
			local width = GetSize((right - left) + (self.widthPadding or 0), self.fixedWidth, self.minimumWidth, self.maximumWidth);
			local height = GetSize((top - bottom) + (self.heightPadding or 0), self.fixedHeight, self.minimumHeight, self.maximumHeight);
			self:SetSize(width, height);
		end

		if hadNoAnchors then
			self:ClearAllPoints();
		end

		self:MarkClean();
	end
end