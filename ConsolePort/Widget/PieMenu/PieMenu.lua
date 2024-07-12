local Clamp, atan2, sqrt, _, db = Clamp, math.atan2, math.sqrt, ...;
local ARROW_SIZE_W_FRACTION, ARROW_SIZE_H_FRACTION, BG_POINT_INSET = 0.1, 0.8, 422/500;
---------------------------------------------------------------
-- Intrinsic mixin
---------------------------------------------------------------
CPPieMenuMixin = CreateFromMixins(CPFocusPoolMixin, CPGradientMixin);

function CPPieMenuMixin:OnPreLoad()
	CPFocusPoolMixin.OnLoad(self)
	CPGradientMixin.OnLoad(self)
	if self.isSlicedPie then
		self.SlicePool = CreateFramePool('PieSlice', self)
		self.BG:SetTexture(nil)
		self:RegisterColorCallbacks()
	end
end

function CPPieMenuMixin:CreateFramePool(template, mixin, resetterFunc)
	CPFocusPoolMixin.CreateFramePool(self, 'CheckButton', template, mixin, resetterFunc)
end

function CPPieMenuMixin:OnPostShow()
	self:UpdatePieSlices(true)
end

function CPPieMenuMixin:OnPostHide()
	CPFocusPoolMixin.OnPostHide(self)
	self.Arrow:SetAlpha(0)
	self.BG:SetVertexColor(1, 1, 1, 0)
	self:UpdatePieSlices(false)
end

function CPPieMenuMixin:OnPostSizeChanged()
	local width, height = self:GetSize()
	local x, y = (BG_POINT_INSET * width) - width, (BG_POINT_INSET * height) - height;
	self.Arrow:SetSize(width * ARROW_SIZE_W_FRACTION, height * ARROW_SIZE_H_FRACTION)
	self.BG:SetPoint('TOPLEFT', -x, y)
	self.BG:SetPoint('BOTTOMRIGHT', x, -y)
	self:UpdatePieSliceSize(width, height)
end

function CPPieMenuMixin:SetFocusByIndex(index, pointerIndex)
	local newObj, oldObj = CPFocusPoolMixin.SetFocusByIndex(self, index)
	if ( oldObj ) then
		oldObj:OnClear()
	end
	if ( newObj ) then
		newObj:OnFocus(oldObj)
	end
	self:UpdateBackgroundFocus(pointerIndex)
	return newObj
end

function CPPieMenuMixin:ReflectStickPosition(x, y, len, isValid)
	local color = isValid and self.VertexColor or self.VertexValid;
	self.Arrow:SetVertexColor(color:GetRGBA())

	local r, g, b = self.VertexColor:GetRGBA()
	CPAPI.SetGradient(self.BG, self:GetMixGradient(r * len, g * len, b * len, len))
	self.Arrow:SetAlpha(Clamp(len + len/1.5, 0, 1))

	local rotation = self:GetRotation(x, y)
	self.BG:SetRotation(rotation)
	self.Arrow:SetRotation(rotation)

	self:UpdateBackgroundAssets(len, isValid)

	return rotation;
end

function CPPieMenuMixin:GetRotation(x, y)
	return -atan2(x, y)
end

---------------------------------------------------------------
-- Sliced pie mixin
---------------------------------------------------------------
local SLICE_FRACTION, BG_FRACTION, MASK_FRACTION = 512/300, 480/300, 512/300;
local LINE_MUL, LINE_OFFSET_DIV = 1.25, 2.75;

function CPPieMenuMixin:UpdateBackgroundAssets(len, isValid)
	if not self.isSlicedPie then return end;
	local bgAlpha = Clamp(1 - (len + len/1.5), 0.5, 1)
	local activeAlpha = sqrt(sqrt(len))
	local activeColor = self.SliceColors[ isValid and 'Active' or 'Hilite' ];
	self.ActiveSlice:SetColor(activeColor)
	self.ActiveSlice:SetOpacity(activeAlpha)
	for slice in self.SlicePool:EnumerateActive() do
		slice:SetOpacity(bgAlpha)
	end
end

function CPPieMenuMixin:UpdateBackgroundFocus(index)
	if not self.isSlicedPie then return end;
	self.ActiveSlice:SetIndex(index, self:GetNumVisible())
end

function CPPieMenuMixin:UpdatePieSlices(isShown, numSlices)
	if not self.isSlicedPie then return end;
	if not isShown then
		self.ActiveSlice:SetOpacity(0)
		return;
	end
	self.SlicePool:ReleaseAll()
	local slices = numSlices or self:GetNumVisible()
	local width, height = self:GetSize()
	for i = 1, slices do
		local slice, newObj = self.SlicePool:Acquire()
		slice:SetOpacity(1)
		slice:SetPoint('CENTER')
		slice:SetText(nil)
		slice:UpdateSize(width, height)
		slice:SetIndex(i, slices)
		slice:Show()
		if newObj then
			slice:SynchronizeAnimation(self.ActiveSlice)
			slice:SetTextSize(self.sliceTextSize)
		end
	end
end

function CPPieMenuMixin:UpdatePieSliceSize(width, height)
	if not self.isSlicedPie then return end;
	self.InnerMask:SetSize(width * BG_FRACTION, height * BG_FRACTION)
	self.ActiveSlice:UpdateSize(width, height)
	if not self.SlicePool then return end;
	for slice in self.SlicePool:EnumerateActive() do
		slice:UpdateSize(width, height)
	end
end

function CPPieMenuMixin:GetSlice(index)
	for slice in self.SlicePool:EnumerateActive() do
		if ( slice:GetID() == index ) then
			return slice;
		end
	end
end

function CPPieMenuMixin:SetSliceText(index, text)
	local slice = self:GetSlice(index)
	if slice then
		slice:SetText(text)
		return true;
	end
end

function CPPieMenuMixin:SetSliceTextSize(size)
	self.sliceTextSize = size;
	for slice in self.SlicePool:EnumerateActive() do
		slice:SetTextSize(size)
	end
	self.ActiveSlice:SetTextSize(size)
end

function CPPieMenuMixin:SetActiveSliceText(text)
	self.ActiveSlice:SetText(text)
end

---------------------------------------------------------------
-- Slice color settings
---------------------------------------------------------------
CPPieMenuMixin.SliceColors = {
	Normal = db.Variables('radialNormalColor'):GetObject();
	Active = db.Variables('radialActiveColor'):GetObject();
	Hilite = db.Variables('radialHiliteColor'):GetObject();
	Sticky = db.Variables('radialStickyColor'):GetObject();
	Accent = db.Variables('radialAccentColor'):GetObject();
};

local SharedColorMutex;
function CPPieMenuMixin:UpdateColorSettings()
	local function UpdateLocalColors()
		if self.StickySlice then
			self.StickySlice:SetColor(self.SliceColors.Sticky)
		end
		if self.ActiveSlice then
			self.ActiveSlice:SetColor(self.SliceColors.Active)
			self.ActiveSlice:SetOpacity(0)
			self.ActiveSlice.Separator1:SetTexture(CPAPI.GetAsset([[Textures\Pie\Pie_Separator_Active.png]]))
			self.ActiveSlice.Separator2:SetTexture(CPAPI.GetAsset([[Textures\Pie\Pie_Separator_Active.png]]))
			self.ActiveSlice:SetSeparatorColor(self.SliceColors.Hilite:GetRGBA())
		end
		for slice in self.SlicePool:EnumerateActive() do
			slice:SetColor(self.SliceColors.Normal)
		end
	end

	local function UpdateSharedColors()
		self.SliceColors.Normal = CPAPI.CreateColorFromHexString(db('radialNormalColor'))
		self.SliceColors.Active = CPAPI.CreateColorFromHexString(db('radialActiveColor'))
		self.SliceColors.Hilite = CPAPI.CreateColorFromHexString(db('radialHiliteColor'))
		self.SliceColors.Sticky = CPAPI.CreateColorFromHexString(db('radialStickyColor'))
		self.SliceColors.Accent = CPAPI.CreateColorFromHexString(db('radialAccentColor'))
	end

	if not SharedColorMutex then
		SharedColorMutex = true;
		UpdateSharedColors()
		RunNextFrame(function()
			SharedColorMutex = nil;
			UpdateLocalColors()
		end)
	else
		RunNextFrame(UpdateLocalColors)
	end
end

function CPPieMenuMixin:RegisterColorCallbacks()
	db:RegisterCallbacks(self.UpdateColorSettings, self,
		'OnDataLoaded',
		'Settings/radialNormalColor',
		'Settings/radialActiveColor',
		'Settings/radialHiliteColor',
		'Settings/radialStickyColor',
		'Settings/radialAccentColor'
	);
end

---------------------------------------------------------------
-- Pie slice mixin
---------------------------------------------------------------
CPPieSliceMixin = {};

function CPPieSliceMixin:OnPreLoad()
	self:SetColor(CPPieMenuMixin.SliceColors.Normal)
	self:Lower()
end

function CPPieSliceMixin:SetIndex(index, numActive)
	if not index then return end;
	local startAngle, endAngle, centerAngle = self:GetParent():GetBoundingRadiansForIndex(index, numActive)
	local enableMasking = not numActive or numActive > 1;
	if ( numActive == 0 ) then return end;
	self.index, self.centerAngle = index, centerAngle;
	self:RotateMasks(enableMasking, startAngle, endAngle)
	self:RotateLines(centerAngle)
	self:SetID(index)
end

function CPPieSliceMixin:RotateMasks(enableMasking, startAngle, endAngle)
	self.RectMask1:SetRotation(startAngle)
	self.RectMask2:SetRotation(endAngle)
	self.RectMask1:SetShown(enableMasking)
	self.RectMask2:SetShown(enableMasking)
	self.Separator1:SetRotation(startAngle)
	self.Separator2:SetRotation(endAngle - math.pi)
	self.Separator1:SetShown(enableMasking)
	self.Separator2:SetShown(enableMasking)
end

function CPPieSliceMixin:RotateLines(centerAngle)
	if not centerAngle then return end;
	local radius = self:GetWidth() / LINE_OFFSET_DIV;

	local startX, startY = -(radius * math.cos(centerAngle)), (radius * math.sin(centerAngle));
	local endX, endY = startX * LINE_MUL, startY * LINE_MUL;

	local flatDirection = (endX < 1) and -1 or 1;
	local flatLength = self.Text:GetStringWidth() * LINE_MUL;
	local textYDelta = (endY < 1) and -1 or 1;
	local textYOffset = self.Text:GetStringHeight();
	local flipLines = startX > endX;
	local textPoint = flipLines and 'RIGHT' or 'LEFT';

	self.Line1:SetStartPoint('CENTER', startX, startY)
	self.Line1:SetEndPoint('CENTER', endX, endY)
	self.Line2:SetStartPoint('CENTER', endX, endY)
	self.Line2:SetEndPoint('CENTER', endX + flatDirection * flatLength, endY)
	self.Text:ClearAllPoints()
	self.Text:SetPoint(textPoint, self.Line2, textPoint, 0, textYDelta * textYOffset)
	self.Text:SetJustifyH(textPoint)

	self.Line1:SetTexCoord(0, 1, flipLines and 1 or 0, flipLines and 0 or 1)
	self.Line2:SetTexCoord(0, 1, flipLines and 1 or 0, flipLines and 0 or 1)
end

function CPPieSliceMixin:SetColor(color)
	self.color = color;
	self:SetVertexColor(color.r, color.g, color.b)
	self:SetOpacity(color.a)
end

function CPPieSliceMixin:SetOpacity(a)
	self:SetAlpha(Clamp(a, 0, self.color.a))
end

function CPPieSliceMixin:SetVertexColor(r, g, b)
	self.Slice:SetVertexColor(r, g, b)
	self:SetLineColor(r, g, b)
	if not self.isActiveSlice then
		self:SetSeparatorColor(r, g, b, 0.25)
	end
end

function CPPieSliceMixin:UpdateSize(width, height)
	if not width or not height then
		width, height = self:GetParent():GetSize()
	end
	self:SetSize(width * SLICE_FRACTION, height * SLICE_FRACTION)
	self.Slice:SetSize(width * BG_FRACTION, height * BG_FRACTION)
	self.Separator1:SetSize(width * BG_FRACTION, height * BG_FRACTION)
	self.Separator2:SetSize(width * BG_FRACTION, height * BG_FRACTION)
	self.RectMask1:SetSize(width * MASK_FRACTION, height * MASK_FRACTION)
	self.RectMask2:SetSize(width * MASK_FRACTION, height * MASK_FRACTION)
end

function CPPieSliceMixin:SynchronizeAnimation(other)
	self.BgAnim:Restart(false, other.BgAnim:GetElapsed())
end

function CPPieSliceMixin:SetLineColor(r, g, b)
	self.Line1:SetVertexColor(r, g, b)
	self.Line2:SetVertexColor(r, g, b)
end

function CPPieSliceMixin:SetSeparatorColor(r, g, b, a)
	self.Separator1:SetVertexColor(r, g, b, a)
	self.Separator2:SetVertexColor(r, g, b, a)
end

function CPPieSliceMixin:SetText(text)
	local isTextEnabled = text and (text:trim()) ~= '';
	self.Line1:SetShown(isTextEnabled)
	self.Line2:SetShown(isTextEnabled)
	self.Text:SetShown(isTextEnabled)
	self.Text:SetText(text)
	if isTextEnabled then
		self:RotateLines(self.centerAngle)
	end
end

function CPPieSliceMixin:SetTextSize(size)
	if not size then return end;
	local font, _, flags = self.Text:GetFont()
	self.Text:SetFont(font, size, flags)
end

function CPPieSliceMixin:GetText()
	return self.Text:GetText()
end