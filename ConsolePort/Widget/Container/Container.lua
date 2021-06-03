local Carpenter, _, db = LibStub:GetLibrary('Carpenter'), ...;
CPContainerMixin = CreateFromMixins(CPBackgroundMixin, CPFocusPoolMixin, CPButtonCatcherMixin);
CPHeaderMixin, CPPanelMixin = CreateFromMixins(CPFocusPoolMixin), CreateFromMixins(CPFocusPoolMixin);

---------------------------------------------------------------
-- Container
---------------------------------------------------------------
function CPContainerMixin:OnContainerLoad()
	local r, g, b = CPAPI.GetWebColor(CPAPI.GetClassFile()):GetRGB()
	local inset, headerHeight = 8, 64;

	CPFocusPoolMixin.OnLoad(self)
	CPBackgroundMixin.OnLoad(self)
	CPButtonCatcherMixin.OnLoad(self)

	self:RegisterForDrag('LeftButton')
	self:SetBackgroundInsets(true)
	self:SetBackdrop(CPAPI.Backdrops.Frame)
	self:SetBackdropColor(r, g, b)

	-- Create container frames
	Carpenter:BuildFrame(self, {
		Header = {
			_Type   = 'Frame';
			_Setup  = 'BackdropTemplate';
			_Mixin  = CPHeaderMixin;
			_Height = headerHeight;
			_Points = {
				{'TOPLEFT', inset-1, -inset+1};
				{'TOPRIGHT', -inset+1, -inset+1};
			};
			_Backdrop = CPAPI.Backdrops.Header;
			_OnLoad = function(self)
				local nR, nG, nB = CPAPI.NormalizeColor(r, g, b)
				CPFocusPoolMixin.OnLoad(self)
				CPBackgroundMixin.OnBackdropLoaded(self)
				self.Center:SetBlendMode('ADD')
				self.Center:SetVertexColor(nR, nG, nB)
			end;
			{
				Shadow = {
					_Type  = 'Texture';
					_Setup = {'BACKGROUND', nil, -6};
					_Texture = CPAPI.GetAsset([[Textures\Frame\Backdrop_Vertex_White]]);
					_Gradient = {'VERTICAL', 0, 0, 0, 0, 0, 0, 0, 0.3};
					_Points = {
						{'TOPLEFT', 'parent', 'BOTTOMLEFT', 1, 0};
						{'BOTTOMRIGHT', 'parent', 'BOTTOMRIGHT', -1, -30};
					};
				};
				Tint = {
					_Type  = 'Texture';
					_Setup = {'BACKGROUND', nil, -7};
					_Texture = CPAPI.GetAsset([[Textures\Frame\Gradient_White_Horizontal]]);
					_Vertex = {r, g, b};
					_Points = {
						{'TOPLEFT', 'parent.Center', 'TOPLEFT', 0, 0};
						{'BOTTOMRIGHT', 'parent.Center', 'BOTTOMRIGHT', 0, 0};
					};
				};
				Logo = {
					_Type  = 'Button';
					_Size  = {headerHeight * 0.9, headerHeight * 0.9};
					_Point = {'LEFT', headerHeight * 0.1, -2};
					_SetNormalTexture = CPAPI.GetAsset([[Textures\Logo\CP_Thumb]]);
					_SetPushedTexture = CPAPI.GetAsset([[Textures\Logo\CP_Thumb]]);
					_OnLoad = function(self)
						local pushed = self:GetPushedTexture()
						pushed:ClearAllPoints()
						pushed:SetSize(self:GetSize())
						pushed:SetPoint('CENTER', 0, -2)
						self:GetParent():GetParent().TopNavButton = self;
					end;
					_OnClick = function(self)
						self:GetParent():GetParent():ShowDefaultFrame(true)
					end;
				};
				Close = {
					_Type = 'Button';
					_Size = {16.25, 20};
					_Point = {'TOPRIGHT', -8, -8};
					_SetNormalTexture = CPAPI.GetAsset([[Textures\Frame\General_Assets]]);
					_SetHighlightTexture = CPAPI.GetAsset([[Textures\Frame\General_Assets]]);
					_OnLoad = function(self)
						local normal, hilite = self:GetNormalTexture(), self:GetHighlightTexture()
						normal:SetTexCoord(0, 0.40625, 0.5, 1)
						hilite:SetTexCoord(0, 0.40625, 0.5, 1)
					end;
					_OnClick = function()
						self:Hide()
					end;
				};
				Index = {
					_Type   = 'ScrollFrame';
					_Setup  = {'CPSmoothScrollTemplate'};
					_SetScrollOrientation = 'Horizontal';
					_Points = {
						{'TOPLEFT', headerHeight * 1.1, 0};
						{'BOTTOMRIGHT', -(headerHeight * 1.1), 0};
					};
					_OnLoad = function(self)
						self.GetVerticalScrollRange = function() return 0 end;
						self.Child:SetHeight(self:GetParent():GetHeight())
						self.Child.Pool = self:GetParent():CreateFramePool('IndexButton',
							'CPContainerHeaderButtonTemplate', {}, nil, self.Child);
					end;
				};
			};
		};
		Container = {
			_Type   = 'Frame';
			_SetClipsChildren = true;
			_Points = {
				{'TOPLEFT', 'parent.Header', 'BOTTOMLEFT', 1, 2};
				{'BOTTOMRIGHT', -inset+1, inset};
			};
		};
	}, nil, true)
	self:CreateFramePool('Frame', nil, CPPanelMixin, nil, self.Container)
	self:SetBackgroundVertexColor(.75, .75, .75, 1)
	db('Stack'):AddFrame(self)
	return self.Header, self.Container;
end

---------------------------------------------------------------
-- Container content handling
---------------------------------------------------------------
function CPContainerMixin:OnContainerSizeChanged()
	local panel = self:GetFocusWidget()
	if panel then
		panel:OnContainerSizeChanged(self.Container:GetSize())
	end
end

function CPContainerMixin:OnContainerShow()
	self:SetDefaultClosures()
end

function CPContainerMixin:SetDefaultClosures()
	self:ReleaseClosures()
	-- TODO: special click handling?
	self.CatchLeftShoulder = self:CatchButton('PADLSHOULDER', function(self)
		local index = self.focusedID - 1;
		if index < 1 then
			return self:ShowDefaultFrame(true)
		end
		local widget = self.Header:GetHeaderAtIndex(index)
		if widget and widget:IsEnabled() then
			widget:Click()
		end
	end, self)
	self.CatchRightShoulder = self:CatchButton('PADRSHOULDER', function(self)
		local widget = self.Header:GetHeaderAtIndex(self.focusedID + 1)
		if widget and widget:IsEnabled() then
			widget:Click()
		end
	end, self)
end

function CPContainerMixin:ShowPanel(name)
	self:ShowDefaultFrame(false)
	self:SetDefaultClosures()
	local panel, old = self:SetFocusByIndex(name)
	if old then
		old:Hide()
	end
	if panel then
		if panel.OnFirstShow then
			panel:OnFirstShow()
			panel.OnFirstShow = nil;
		end
		panel:OnContainerSizeChanged(self.Container:GetSize())
		panel:Show()
	else
		self:ShowDefaultFrame(true)
	end
end

function CPContainerMixin:ShowDefaultFrame(show)
	if self.DefaultFrame then
		if show then
			local panel = self:GetFocusWidget()
			if panel then
				panel:Hide()
			end
			self.focusedID = 0;
			self.Header:UncheckAll()
			if self.DefaultFrame.OnFirstShow then
				self.DefaultFrame:OnFirstShow()
				self.DefaultFrame.OnFirstShow = nil;
			end
		end
		self.DefaultFrame:SetShown(show)
		return show;
	end
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
	local header = not data.noHeader and self.Header:CreateHeader(data.name, panel)
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
	if self.OnPanelAdded then
		self:OnPanelAdded(panel, header)
	end
	return panel, header;
end

---------------------------------------------------------------
-- Header
---------------------------------------------------------------
do  local function HeaderButtonOnClick(self)
		self.container.focusedID = self:GetID();
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
		header:SetHeight(self:GetHeight() - 2)
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

function CPHeaderMixin:GetHeaderAtIndex(index)
	local widget = self.Registry[index]
	if widget and widget:IsShown() then
		return widget;
	end
end

function CPHeaderMixin:UncheckAll()
	for header in self:EnumerateActive() do
		header:Uncheck()
	end
end

function CPHeaderMixin:ToggleEnabled(enabled)
	for header in self:EnumerateActive() do
		header:SetEnabled(enabled)
		header:SetAlpha(enabled and 1 or 0.5)
	end
end

---------------------------------------------------------------
-- Panel
---------------------------------------------------------------
function CPPanelMixin:Validate()
	return true; -- replace with callback
end

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
		_Type  = 'ScrollFrame';
		_Setup = {'CPSmoothScrollTemplate'};
		parent  = self;
		container = self:GetParent();
	}
	for k, v in pairs(struct) do blueprint[k] = v end;
	return Carpenter:BuildFrame(self, {[key] = blueprint}, false, true)[key]
end

function CPPanelMixin:CatchButton(...)
	if self:IsShown() then
		self.container:CatchButton(...)
	end
end

function CPPanelMixin:FreeButton(...)
	if self:IsShown() then
		self.container:FreeButton(...)
	end
end