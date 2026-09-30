local _, env = ...;
---------------------------------------------------------------
CPGlyph = CreateFromMixins(env.ConfigurableWidgetMixin, env.AnimatedWidgetMixin);
---------------------------------------------------------------
-- Draws the buttons of a modifier combination, fixed or whichever
-- layer is live. Listens rather than being driven, since the
-- controller can only write to protected frames.
---------------------------------------------------------------
local db = env.db;

function CPGlyph:OnLoad()
	self.textures = {};
	env:RegisterCallback('OnDataLoaded', self.OnDataLoaded, self)
	db:RegisterCallback('OnLayerChanged', self.OnLayerChanged, self)
end

function CPGlyph:OnLayerChanged(prefix)
	self.layer = prefix;
	if self.props and self.props.dynamic then
		self:Refresh()
	end
end

function CPGlyph:SetProps(props)
	self:SetDynamicProps(props)
	self:OnDataLoaded()
	self:OnDriverChanged()
	self:Show()
end

function CPGlyph:OnPropsUpdated()
	self:SetProps(self.props)
end

function CPGlyph:OnDataLoaded()
	self.prefix = nil; -- force a redraw, the device may have changed
	self:Refresh()
	return CPAPI.KeepMeForLater;
end

---------------------------------------------------------------
-- @return prefix : modifier combination to draw
function CPGlyph:GetPrefix()
	if self.props.dynamic then
		return self.layer or db.Layers:GetActiveLayer();
	end
	return CPAPI.ConvertDriver(self.props.modifier or '');
end

function CPGlyph:GetTexture(index)
	local texture = self.textures[index];
	if not texture then
		texture = self:CreateTexture(nil, 'ARTWORK')
		self.textures[index] = texture;
	end
	return texture;
end

function CPGlyph:Refresh()
	local prefix = self:GetPrefix();
	if ( prefix == self.prefix ) then return end;
	self.prefix = prefix;
	self:Draw(prefix)
end

function CPGlyph:Draw(prefix)
	local device  = db('Gamepad/Active');
	local mapping = db.Gamepad.Index.Modifier.Prefix;
	local size    = tonumber(self.props.size) or 32;
	local spacing = tonumber(self.props.spacing) or 4;

	local buttons = {};
	for token in prefix:gmatch('[^%-]+') do
		local button = device and mapping[token..'-'];
		if button then
			buttons[#buttons + 1] = button;
		end
	end

	-- Centred on the anchor, independent of the frame's size.
	local count  = #buttons;
	local stride = size + spacing;
	local origin = -( ( count - 1 ) * stride ) / 2;

	for i, button in ipairs(buttons) do
		local texture = self:GetTexture(i);
		CPAPI.SetTextureOrAtlas(texture, {device:GetIconForButton(button, 64)})
		texture:SetSize(size, size)
		texture:ClearAllPoints()
		texture:SetPoint('CENTER', self, 'CENTER', origin + ( i - 1 ) * stride, 0)
		texture:Show()
	end

	for i = count + 1, #self.textures do
		self.textures[i]:Hide()
	end
	self:SetSize(math.max(size, count * size + math.max(0, count - 1) * spacing), size)
end

---------------------------------------------------------------
do  local glyphCounter = CreateCounter();
	env:AddFactory('Glyph', function()
		return CreateFrame('Frame', 'ConsolePortActionBarGlyph'..glyphCounter(), env.Manager, 'CPGlyph')
	end, env.Interface.Glyph)
end
