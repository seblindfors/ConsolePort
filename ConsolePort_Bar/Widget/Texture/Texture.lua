local _, env = ...;
---------------------------------------------------------------
CPTexture = CreateFromMixins(env.ConfigurableWidgetMixin, env.AnimatedWidgetMixin);
---------------------------------------------------------------
local DEFAULT_COLOR = 'ffffffff';

function CPTexture:SetProps(props)
	self:SetDynamicProps(props)
	self:OnDriverChanged()
	self:Show()
end

function CPTexture:OnPropsUpdated()
	self:SetProps(self.props)
end

function CPTexture:OnDriverChanged()
	env.AnimatedWidgetMixin.OnDriverChanged(self)
	local props, Layers = self.props, env.db.Layers;
	Layers:RegisterAttributeDriver(self, 'file',   env.ConvertDriver(props.file))
	Layers:RegisterAttributeDriver(self, 'color',  env.ConvertDriver(props.color))
	Layers:RegisterAttributeDriver(self, 'width',  env.ConvertDriver(props.size.width))
	Layers:RegisterAttributeDriver(self, 'height', env.ConvertDriver(props.size.height))
end

function CPTexture:OnAttributeChanged(attribute, value)
	if ( attribute == 'file' ) then
		self:SetFile(value)
	elseif ( attribute == 'color' ) then
		self:SetColor(value)
	elseif ( attribute == 'width' ) then
		self:SetWidth(tonumber(value) or 0)
	elseif ( attribute == 'height' ) then
		self:SetHeight(tonumber(value) or 0)
	else
		env.AnimatedWidgetMixin.OnAttributeChanged(self, attribute, value)
	end
end

function CPTexture:SetFile(file)
	local fileID = tonumber(file);
	file = tostring(file or '');
	if fileID or file:find('[/\\]') then
		self.Texture:SetTexCoord(0, 1, 0, 1)
		self.Texture:SetTexture(fileID or file)
	elseif not CPAPI.SetAtlas(self.Texture, file, false) then
		self.Texture:SetTexture(nil)
	end
end

function CPTexture:SetColor(hex)
	if ( type(hex) == 'number' ) then
		hex = ('%08d'):format(hex);
	end
	hex = tostring(hex or '');
	if ( #hex ~= 8 ) then
		hex = DEFAULT_COLOR;
	end
	local color = CPAPI.CreateColorFromHexString(hex);
	self.Texture:SetVertexColor(color:GetRGBA())
end

do local textureCounter = CreateCounter()
	env:AddFactory('Texture', function()
		return CreateFrame('Frame', 'ConsolePortActionBarTexture'..textureCounter(), env.Manager, 'CPTexture')
	end, env.Interface.Texture)
end
