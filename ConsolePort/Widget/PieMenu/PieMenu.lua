local Clamp, atan2, _, db = Clamp, math.atan2, ...;
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
		self.ActiveSlice:SetVertexColor(NORMAL_FONT_COLOR:GetRGB())
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

function CPPieMenuMixin:UpdateBackgroundAssets(len, isValid)
	if not self.isSlicedPie then return end;
	local bgAlpha = Clamp(1 - (len + len/1.5), 0.5, 1)
	local activeAlpha = Clamp(math.sqrt(math.sqrt(len)), 0, 1)
	local activeColor = self.SliceColors[ isValid and 'Active' or 'Hilite' ];
	self.ActiveSlice:SetVertexColor(activeColor:GetRGB())
	self.ActiveSlice:SetAlpha(activeAlpha)
	for slice in self.SlicePool:EnumerateActive() do
		slice:SetAlpha(bgAlpha)
	end
end

function CPPieMenuMixin:UpdateBackgroundFocus(index)
	if not self.isSlicedPie then return end;
	self.ActiveSlice:SetIndex(index, self:GetNumActive())
end

function CPPieMenuMixin:UpdatePieSlices(isShown, numSlices)
    if not self.isSlicedPie then return end;
    if not isShown then
		self.ActiveSlice:SetAlpha(0)
		return;
	end
	self.SlicePool:ReleaseAll()
	local slices = numSlices or self:GetNumActive()
	local width, height = self:GetSize()
	for i = 1, slices do
		local slice, newObj = self.SlicePool:Acquire()
		slice:SetAlpha(1)
		slice:SetPoint('CENTER')
		slice:SetIndex(i - 1, slices)
		slice:UpdateSize(width, height)
		slice:Show()
		if newObj then
			slice:SynchronizeAnimation(self.ActiveSlice)
		end
	end
end

function CPPieMenuMixin:UpdatePieSliceSize(width, height)
	if not self.isSlicedPie then return end;
	self.InnerMask:SetSize(width * BG_FRACTION, height * BG_FRACTION)
	self.ActiveSlice:UpdateSize(width, height)
	if not self.SlicePool then return end; -- TODO: error here for some reason?
	for slice in self.SlicePool:EnumerateActive() do
		slice:UpdateSize(width, height)
	end
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
			self.StickySlice:SetVertexColor(self.SliceColors.Sticky:GetRGB())
		end
		if self.ActiveSlice then
			self.ActiveSlice:SetVertexColor(self.SliceColors.Normal:GetRGB())
		end
		for slice in self.SlicePool:EnumerateActive() do
			slice:SetVertexColor(self.SliceColors.Normal:GetRGB())
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
	self:SetVertexColor(CPPieMenuMixin.SliceColors.Normal:GetRGB())
	self:Lower()
end

function CPPieSliceMixin:SetIndex(index, numActive)
    if not index then return end;
    local startAngle, endAngle = self:GetParent():GetBoundingAnglesForIndex(index, numActive)
	local enableMasking = not numActive or numActive > 1;
	self.RectMask1:SetRotation(-(math.rad(startAngle)))
	self.RectMask2:SetRotation(-(math.rad(endAngle)) + math.pi)
	self.RectMask1:SetShown(enableMasking)
	self.RectMask2:SetShown(enableMasking)
end

function CPPieSliceMixin:SetVertexColor(r, g, b)
	self.Slice:SetVertexColor(r, g, b)
end

function CPPieSliceMixin:UpdateSize(width, height)
	if not width or not height then
		width, height = self:GetParent():GetSize()
	end
	self:SetSize(width * SLICE_FRACTION, height * SLICE_FRACTION)
	self.Slice:SetSize(width * BG_FRACTION, height * BG_FRACTION)
	self.RectMask1:SetSize(width * MASK_FRACTION, height * MASK_FRACTION)
	self.RectMask2:SetSize(width * MASK_FRACTION, height * MASK_FRACTION)
end

function CPPieSliceMixin:SynchronizeAnimation(other)
	self.BgAnim:Restart(false, other.BgAnim:GetElapsed())
end