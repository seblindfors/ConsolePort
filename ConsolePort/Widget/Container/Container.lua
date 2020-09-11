CPContainerMixin = CreateFromMixins(CPBackgroundMixin, CPAmbienceMixin);

function CPContainerMixin:OnContainerLoad()
	local r, g, b = CPAPI.GetWebColor(CPAPI.GetClassFile()):GetRGB()
	local inset = 8;

	CPAmbienceMixin.OnLoad(self)
	CPBackgroundMixin.OnLoad(self)
	self:SetBackgroundInsets(true)
	self:SetBackdrop(CPAPI.Backdrops.Frame)
	self:SetBackdropColor(r, g, b)

	-- Create container frames
	LibStub:GetLibrary('LibDynamite'):BuildFrame(self, {
		Header = {
			['<Type>']   = 'Frame';
			['<Setup>']  = 'BackdropTemplate';
			['<Height>'] = 80;
			['<Points>'] = {
				{'TOPLEFT', inset-1, -inset+1};
				{'TOPRIGHT', -inset+1, -inset+1};
			};
			['<Backdrop>'] = CPAPI.Backdrops.Header;
			['<OnLoad>'] = function(self)
				local nR, nG, nB = CPAPI.NormalizeColor(r, g, b)
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
					['<Texture>'] = CPAPI.GetAsset([[Textures\Logo\CP]]);
					['<Size>'] = {70, 70};
					['<Point>'] = {'LEFT', 10, -2};
				};
			};
		};
		Container = {
			['<Type>']   = self.containerFrameType or 'Frame';
			['<Setup>']  = self.containerFrameTemplate;
			['<Mixin>']  = self.containerFrameMixin;
			['<SetTopLevel>'] = true;
			['<Points>'] = {
				{'TOPLEFT', 'parent.Header', 'BOTTOMLEFT', 1, -1};
				{'BOTTOMRIGHT', -inset+1, inset-1};
			};
		};
	}, nil, true)
	return self.Header, self.Container;
end

function CPContainerMixin:SetHeaderHeight(height)
	self.Header:SetHeight(height)
	return self
end
