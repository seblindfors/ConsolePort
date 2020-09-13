---------------------------------------------------------------
-- Intrinsic mixin
---------------------------------------------------------------
CPIndexButtonMixin = CreateFromMixins(BackdropTemplateMixin, {
	IndexColors = {
		Nofill  = CreateColor(0, 0, 0, 0);
		Normal  = CreateColor(0, 0, 0, .25);
		Checked = CreateColor(1, 0.7451, 0, 1);
		Hilite  = CreateColor(0, 0.68235, 1, 1);
		Border  = CreateColor(0.15, 0.15, 0.15, 1);
		CheckBG = CPAPI.GetWebColor(CPAPI.GetClassFile(), 'ee');
	};
	ThumbPosition = {
		TOP    = {'TOPLEFT', 'TOPRIGHT', 0, -2};
		LEFT   = {'TOPLEFT', 'BOTTOMLEFT', 2, 0};
		RIGHT  = {'TOPRIGHT', 'BOTTOMRIGHT', -2, 0};
		BOTTOM = {'BOTTOMLEFT', 'BOTTOMRIGHT', 0, 2};
	};
});

function CPIndexButtonMixin:OnIndexButtonLoad()
	self:SetThumbPosition('LEFT')
end

function CPIndexButtonMixin:OnIndexButtonClick(...)
	-- do something with the click
	if self.forceCheck and not self:GetChecked() then
		self:SetChecked(true)
	end 
	self:OnChecked(self:GetChecked())
end

function CPIndexButtonMixin:OnChecked(checked)
	self:ToggleOutline(checked)
	self.CheckedThumb:SetShown(checked)
	self.HiliteThumb:SetShown(not checked)
	self.Background:SetVertexColor(self:GetBackgroundColor():GetRGBA())
	if checked then
		self:UncheckSiblings()
	end
end

function CPIndexButtonMixin:SetSiblings(siblings)
	self.Siblings = siblings;
end

function CPIndexButtonMixin:SetForceChecked(enabled)
	self.forceCheck = enabled;
end

function CPIndexButtonMixin:GetForceChecked()
	return self.forceCheck and true or false;
end

function CPIndexButtonMixin:UncheckSiblings()
	if self.Siblings then
		if (#self.Siblings > 0) then
			for i, sibling in ipairs(self.Siblings) do
				if ( sibling ~= self) then
					sibling:SetChecked(false)
					sibling:OnChecked(false)
				end
			end
		else -- need to handle both as key and val
			local IsFrame = C_Widget.IsFrameWidget;
			for sibKey, sibVal in pairs(self.Siblings) do
				local sibling = IsFrame(sibKey) and sibKey or IsFrame(sibVal) and sibVal;
				if ( sibling ~= self ) then
					sibling:SetChecked(false)
					sibling:OnChecked(false)
				end
			end
		end
	end
end

function CPIndexButtonMixin:GetBackgroundColor()
	return self.IndexColors[self:GetChecked() and 'CheckBG' or self.transparent and 'Nofill' or 'Normal'];
end

function CPIndexButtonMixin:GetOutlineColor()
	return self.IndexColors[self:GetChecked() and 'Checked' or self.highlightOnly and 'Nofill' or 'Border'];
end

function CPIndexButtonMixin:SetTransparent(enabled)
	self.transparent = enabled;
	self.Background:SetVertexColor(self:GetBackgroundColor():GetRGBA())
end

function CPIndexButtonMixin:SetDrawOutline(enabled, highlightOnly)
	self.drawOutline = enabled;
	self.highlightOnly = highlightOnly;
	self:SetBackdrop(enabled and CPAPI.Backdrops.Simple or nil)
	self:SetBackdropBorderColor(self:GetOutlineColor():GetRGBA())
end

function CPIndexButtonMixin:ToggleOutline(enabled)
	if self.drawOutline then
		self:SetBackdropBorderColor(self:GetOutlineColor():GetRGBA())
		self:SetBackdropColor(self:GetBackgroundColor():GetRGBA())
	end
end

function CPIndexButtonMixin:SetThumbPosition(dir, size) size = size or 1;
	assert(self.ThumbPosition[dir], 'Position must be one of: TOP, LEFT, RIGHT, BOTTOM')
	local start, stop, xOff, yOff = unpack(self.ThumbPosition[dir])
	self.CheckedThumb:SetThickness(size * 4)
	self.HiliteThumb:SetThickness(size * 4)
	self.CheckedThumb:SetStartPoint(start, xOff * size, yOff * size)
	self.CheckedThumb:SetEndPoint(stop, xOff * size, yOff * size)
	self.HiliteThumb:SetStartPoint(start, xOff * size, yOff * size)
	self.HiliteThumb:SetEndPoint(stop, xOff * size, yOff * size)
end


---------------------------------------------------------------
-- Extensions
---------------------------------------------------------------
CPIndexButtonIconMixin = CreateFromMixins(CPIndexButtonMixin)

function CPIndexButtonMixin:SetIcon(texture)
	self.Icon:SetTexture(texture)
end

CPIndexButtonIconTextMixin = CreateFromMixins(CPIndexButtonIconMixin)

function CPIndexButtonIconTextMixin:SetIconAndText(texture, text)
	self:SetIcon(texture)
	self:SetText(text)
end