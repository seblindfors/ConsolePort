local LibDynamite, _, db = LibStub:GetLibrary('LibDynamite'), ...;
CPContainerMixin = CreateFromMixins(CPBackgroundMixin, CPAmbienceMixin, CPFocusPoolMixin);
CPHeaderMixin, CPHeaderIndexMixin = CreateFromMixins(CPFocusPoolMixin), {}
CPPanelMixin, CPColumnMixin = CreateFromMixins(CPFocusPoolMixin), {};

---------------------------------------------------------------
-- Container
---------------------------------------------------------------
function CPContainerMixin:OnContainerLoad()
	local r, g, b = CPAPI.GetWebColor(CPAPI.GetClassFile()):GetRGB()
	local inset, headerHeight = 8, 64;

	CPAmbienceMixin.OnLoad(self)
	CPFocusPoolMixin.OnLoad(self)
	CPBackgroundMixin.OnLoad(self)

	self:RegisterForDrag('LeftButton')
	self:SetBackgroundInsets(true)
	self:SetBackdrop(CPAPI.Backdrops.Frame)
	self:SetBackdropColor(r, g, b)

	-- Create container frames
	LibDynamite:BuildFrame(self, {
		Header = {
			['<Type>']   = 'Frame';
			['<Setup>']  = 'BackdropTemplate';
			['<Mixin>']  = CPHeaderMixin;
			['<Height>'] = headerHeight;
			['<Points>'] = {
				{'TOPLEFT', inset-1, -inset+1};
				{'TOPRIGHT', -inset+1, -inset+1};
			};
			['<Backdrop>'] = CPAPI.Backdrops.Header;
			['<OnLoad>'] = function(self)
				local nR, nG, nB = CPAPI.NormalizeColor(r, g, b)
				CPFocusPoolMixin.OnLoad(self)
				CPBackgroundMixin.OnBackdropLoaded(self)
				self.Center:SetBlendMode('ADD')
				self.Center:SetVertexColor(nR, nG, nB)
				self:SetBackdropBorderColor(r+0.25, g+0.25, b+0.25, 1)
			end;
			{
				Shadow = {
					['<Type>']  = 'Texture';
					['<Setup>'] = {'BACKGROUND', nil, -6};
					['<Texture>'] = CPAPI.GetAsset([[Textures\Frame\Backdrop_Vertex_White]]);
					['<Gradient>'] = {'VERTICAL', 0, 0, 0, 0, 0, 0, 0, 0.5};
					['<Points>'] = {
						{'TOPLEFT', 'parent', 'BOTTOMLEFT', 1, 0};
						{'BOTTOMRIGHT', 'parent', 'BOTTOMRIGHT', -1, -20};
					};
				};
				Tint = {
					['<Type>']  = 'Texture';
					['<Setup>'] = {'BACKGROUND', nil, -7};
					['<Texture>'] = CPAPI.GetAsset([[Textures\Frame\Gradient_White_Horizontal]]);
					['<Vertex>'] = {r, g, b};
					['<Points>'] = {
						{'TOPLEFT', 'parent.Center', 'TOPLEFT', 0, 0};
						{'BOTTOMRIGHT', 'parent.Center', 'BOTTOMRIGHT', 0, 0};
					};
				};
				Logo = {
					['<Type>']  = 'Texture';
					['<Setup>'] = {'ARTWORK'};
					['<Size>']  = {headerHeight * 0.9, headerHeight * 0.9};
					['<Point>'] = {'LEFT', headerHeight * 0.1, -2};
					['<Texture>'] = CPAPI.GetAsset([[Textures\Logo\CP_Thumb]]);
				};
				Index = {
					['<Type>']   = 'ScrollFrame';
					['<Setup>']  = {'CPSmoothScrollTemplate'};
					['<SetScrollOrientation>'] = 'Horizontal';
					['<Points>'] = {
						{'TOPLEFT', headerHeight * 1.1, 0};
						{'BOTTOMRIGHT', 0, 0};
					};
					['<OnLoad>'] = function(self)
						self.Child:SetHeight(self:GetParent():GetHeight())
						self.Child.Pool = self:GetParent():CreateFramePool('IndexButton',
							'CPContainerHeaderButtonTemplate', {}, nil, self.Child);
					end;
				};
			};
		};
		Container = {
			['<Type>']   = 'Frame';
			['<SetClipsChildren>'] = true;
			['<Points>'] = {
				{'TOPLEFT', 'parent.Header', 'BOTTOMLEFT', 1, -1};
				{'BOTTOMRIGHT', -inset+1, inset};
			};
		};
	}, nil, true)
	self:CreateFramePool('Frame', nil, CPPanelMixin, nil, self.Container)
	return self.Header, self.Container;
end

---------------------------------------------------------------
-- Container content handling
---------------------------------------------------------------
function CPContainerMixin:OnContainerShow()
	local panel = self:GetFocusWidget()
end

function CPContainerMixin:OnContainerSizeChanged()
	local panel = self:GetFocusWidget()
	if panel then
		panel:OnContainerSizeChanged(self.Container:GetSize())
	end
end

function CPContainerMixin:ShowPanel(name)
	local panel, old = self:SetFocusByIndex(name)
	if old then
		old:Hide()
	end
	panel:Show()
	panel:OnContainerSizeChanged(self.Container:GetSize())
end

function CPContainerMixin:SetHeaderHeight(height)
	self.Header:SetHeight(height)
	return self
end

function CPContainerMixin:GetContainerSize()
	return self.Container:GetSize()
end

function CPContainerMixin:CreatePanel(data)
	local panel  = self:Acquire(data.name)
	local header = self.Header:CreateHeader(data.name, panel)
	panel.header = header;
	panel.parent = self.Container;
	panel.container = self;
	panel:SetPoint('TOPLEFT')
	panel:SetPoint('TOPRIGHT')
	if data.mixin then
		db.table.mixin(panel, data.mixin)
	end
	Mixin(panel, data)
	if panel.OnLoad then
		panel:OnLoad()
	end
	return panel, header;
end


---------------------------------------------------------------
-- Header
---------------------------------------------------------------
do  local function HeaderButtonOnClick(self)
		self.container:ShowPanel(self:GetText())
		self.parent:ScrollTo(self:GetID(), self.container:GetNumActive())
	end

	function CPHeaderMixin:CreateHeader(name, panel)
		self.numHeaders = (self.numHeaders or 0) + 1
		local header = self:Acquire(self.numHeaders)
		local parent, container = self.Index, self:GetParent()
		self.Index.Child:SetWidth(header:GetWidth() * self.numHeaders)

		header.panel  = panel;
		header.parent = self.Index;
		header.container = self:GetParent()
		header:SetScript('OnClick', HeaderButtonOnClick)
		header:SetHeight(self:GetHeight())
		header:SetSiblings(self.Registry)
		header:SetThumbPosition('BOTTOM')
		header:SetTransparent(true)
		header:SetForceChecked(true)
		header:SetID(self.numHeaders)
		header:SetText(name)
		header:Show()

		if (self.numHeaders == 1) then
			header:SetPoint('LEFT', 0, 0)
		else
			header:SetPoint('LEFT', self.Registry[self.numHeaders-1], 'RIGHT', 0, 0)
		end

		return header, self.numHeaders;
	end
end

---------------------------------------------------------------
-- Panel
---------------------------------------------------------------
function CPPanelMixin:OnContainerSizeChanged(width, height)
	if self.scaleToParent then
		self:ScaleToParent(width, height)
	elseif self.scaleToContent then
		self:ScaleToContent()
	end
end

function CPPanelMixin:ScaleToParent(width, height)
	self:SetSize(width, height)
end

function CPPanelMixin:ScaleToContent()
	if not self.forbidRecursiveScale then return end;
	local top, bottom = self:GetTop() or 0, math.huge
	local left, right = self:GetLeft() or 0, 0
	for i, child in ipairs({self:GetChildren()}) do
		local childBottom = child:GetBottom()
		local childRight = child:GetRight()
		if childBottom and childBottom < bottom then
			bottom = childBottom;
		end
		if childRight and childRight > right then
			right = childRight;
		end
	end
	self:SetSize(abs(top - bottom), abs(left - right))
	self.parent:SetSize(self:GetSize())
end

function CPPanelMixin:CreateScrollableColumn(key, struct)
	local blueprint = {
		['<Type>']  = 'ScrollFrame';
		['<Setup>'] = {'CPSmoothScrollTemplate'};
		parent  = self;
		container = self:GetParent();
	}
	for k, v in pairs(struct) do blueprint[k] = v end;
	return LibDynamite:BuildFrame(self, {[key] = blueprint}, false, true)[key]
end