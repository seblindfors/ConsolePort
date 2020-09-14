local db, _, env = ConsolePort:DB(), ...;
local BindingInfo = env.BindingInfo;

---------------------------------------------------------------
-- Helper mixin to scale things dynamically
---------------------------------------------------------------
local ScaleToContentMixin = {}

function ScaleToContentMixin:SetMeasurementOrigin(top, content, width, offset)
	self.fixedWidth = width;
	self.fixedOffset = offset;
	self.topElement = top;
	self.contentElement = content;
end

function ScaleToContentMixin:CalcContentBoundary()
	local top, bottom = self.topElement:GetTop() or 0, math.huge
	for i, child in ipairs({self.contentElement:GetChildren()}) do
		if child:IsShown() then
			local childBottom = child:GetBottom()
			if childBottom then
				bottom = childBottom < bottom and childBottom or bottom;
			end
		end
	end
	return abs(top - bottom) + self.fixedOffset;
end

function ScaleToContentMixin:ScaleToContent()
	self:SetWidth(self.fixedWidth)
	self:SetHeight(self:CalcContentBoundary())
end

---------------------------------------------------------------
-- Mixins
---------------------------------------------------------------
local BindingManager = CreateFromMixins(CPFocusPoolMixin);
local Binding, Header = {}, CreateFromMixins(CPFocusPoolMixin, ScaleToContentMixin)
env.BindingManager = BindingManager;

---------------------------------------------------------------
-- Binding manager
---------------------------------------------------------------
function BindingManager:OnShow()
	local bindings, headers, wasUpdated = BindingInfo:RefreshDictionary()
	if wasUpdated then
		self:ReleaseAll()
		self:DrawCategories(bindings, headers)
	end
end

function BindingManager:DrawCategories(bindings, headers)
	local prev
	for header, set in db.table.spairs(bindings) do
		local widget, newObj = self:Acquire(header)
		if newObj then
			widget:OnLoad()
			widget:SetDrawOutline(true)
		end
		widget:SetText(header)
		widget:SetPoint('TOP', prev or self.Child, prev and 'BOTTOM' or 'TOP', 0, -16)
		widget:Show()
		widget.Bindings = set;
		prev = widget;
	end
	self.Child:ScaleToContent()
end

function BindingManager:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	local r, g, b = CPAPI.GetWebColor(CPAPI.GetClassFile()):GetRGB()
	self:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
	self.Center:SetGradientAlpha('VERTICAL', r, g, b, 0, r, g, b, 1)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingHeaderTemplate', Header, nil, self.Child)
	Mixin(self.Child, ScaleToContentMixin)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self.Child, self.Child, 600, 40)
end

---------------------------------------------------------------
-- Headers
---------------------------------------------------------------
function Header:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	self:SetMeasurementOrigin(self, self.Content, self:GetWidth(), 40)
end

function Header:OnChecked(checked)
	self.Content:SetShown(checked)
	if checked then
		-- delay creating the pool to not waste resoruces,
		-- unlikely that every category gets opened.
		if not self.FramePool then
			self:CreateFramePool('IndexButton',
				'CPIndexButtonBindingActionTemplate', Binding, nil, self.Content)
		end

		local bindings, i, separator = self.Bindings, 0, 0
		for idx, data in ipairs(bindings) do
			if ( data.binding and not data.binding:match('^HEADER_BLANK') ) then
				i = i + 1;
				local widget, newObj = self:Acquire(i)
				widget:SetText(data.name)
				widget:SetAttribute('binding', data.binding)
				widget:Show()
				widget:SetDrawOutline(true)
				widget:UpdateBinding()
				-- use modulus here to place the bindings side by side,
				-- followed by top to bottom
				if (i == 1) then
					widget:SetPoint('TOPLEFT', 16, 0)
				elseif (i % 2 == 0) then
					widget:SetPoint('LEFT', self.Registry[i-1], 'RIGHT', 8, 0)
				else
					widget:SetPoint('TOP', self.Registry[i-2], 'BOTTOM', 0, -10-separator)
				end
				separator = 0;
			else
				separator = 20;
			end
		end
		--self:SetHeight(500)
		self.Hilite:Hide()
		self.HiliteThumb:Hide()
		self:ScaleToContent()
	else
		self.Hilite:Show()
		self.HiliteThumb:Show()
		self:SetHeight(40)
		if self.FramePool then
			self:ReleaseAll()
		end
	end
	self:GetParent():ScaleToContent()
end

function Binding:UpdateBinding()
	local binding = self:GetAttribute('binding')
	if binding then
		self.Slug:SetText(db('Hotkeys'):GetButtonSlugForBinding(binding))
	end
end