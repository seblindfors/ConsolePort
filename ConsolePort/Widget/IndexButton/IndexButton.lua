CPIndexButtonMixin = {
	IndexColors = {
		Normal  = CreateColor(0, 0, 0, .5);
		Checked = CreateColor(1, 0.7451, 0, 1);
		Hilite  = CreateColor(0, 0.68235, 1, 1);
		Border  = CreateColor(0.15, 0.15, 0.15, 1);
		CheckBG = CreateColor(0.20784,0.12549,0.06666,0.8);
	};
};

function CPIndexButtonMixin:OnIndexButtonLoad()
	self.CheckedThumb:SetStartPoint('TOPLEFT', 2, 0)
	self.CheckedThumb:SetEndPoint('BOTTOMLEFT', 2, 0)
	self.HiliteThumb:SetStartPoint('TOPLEFT', 2, 0)
	self.HiliteThumb:SetEndPoint('BOTTOMLEFT', 2, 0)
end

function CPIndexButtonMixin:OnIndexButtonClick(...)
	-- do something with the click
	self:OnChecked(self:GetChecked())
end

function CPIndexButtonMixin:OnChecked(checked)
	self:ToggleOutline(checked)
	self.CheckedThumb:SetShown(checked)
	self.Background:SetColorTexture(self:GetBackgroundColor():GetRGBA())
	if checked then
		self:UncheckSiblings()
	end
end

function CPIndexButtonMixin:SetSiblings(siblings)
	self.Siblings = siblings;
end

function CPIndexButtonMixin:UncheckSiblings()
	if self.Siblings then
		for sibling in pairs(self.Siblings) do
			if ( sibling ~= self ) then
				sibling:SetChecked(false)
			end
		end
	end
end

function CPIndexButtonMixin:GetBackgroundColor()
	return self.IndexColors[self:GetChecked() and 'CheckBG' or 'Normal'];
end

function CPIndexButtonMixin:GetOutlineColor()
	return self.IndexColors[self:GetChecked() and 'Checked' or 'Border'];
end

function CPIndexButtonMixin:SetDrawOutline(enabled)
	self.drawOutline = enabled;
	if enabled and not self.OutlineTextures then
		self.OutlineTextures = {
			['TopLeft-TopRight'] = self:CreateLine(nil, 'ARTWORK', 'CPLineTemplateBorder');
			['TopLeft-BottomLeft'] = self:CreateLine(nil, 'ARTWORK', 'CPLineTemplateBorder');
			['TopRight-BottomRight'] = self:CreateLine(nil, 'ARTWORK', 'CPLineTemplateBorder');
			['BottomLeft-BottomRight'] = self:CreateLine(nil, 'ARTWORK', 'CPLineTemplateBorder');
		};
		local color = self:GetOutlineColor()
		for points, line in pairs(self.OutlineTextures) do
			local start, stop = ('-'):split(points)
			line:SetStartPoint(start:upper(), 0, 0)
			line:SetEndPoint(stop:upper(), 0, 0)
			line:SetColorTexture(color:GetRGBA())
		end
		self.Hilite:SetPoint('TOPLEFT', -1, 1)
		self.Hilite:SetPoint('BOTTOMRIGHT', 1, -1)
	elseif self.OutlineTextures then
		self.Hilite:SetAllPoints()
		for _, line in pairs(self.OutlineTextures) do
			line:Hide()
		end
	end
end

function CPIndexButtonMixin:ToggleOutline(enabled)
	if self.drawOutline and self.OutlineTextures then
		local color = self:GetOutlineColor()
		for _, line in pairs(self.OutlineTextures) do
			line:SetColorTexture(color:GetRGBA())
		end
	end
end