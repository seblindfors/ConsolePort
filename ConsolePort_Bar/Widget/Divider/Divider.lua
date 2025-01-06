local _, env = ...;
---------------------------------------------------------------
CPDivider = CreateFromMixins(env.ConfigurableWidgetMixin, env.AnimatedWidgetMixin);
---------------------------------------------------------------

function CPDivider:OnLoad()
	env:RegisterCallbacks(self.OnDataLoaded, self, 'OnDataLoaded', 'Settings/tintColor')
end

function CPDivider:SetProps(props)
	self:SetDynamicProps(props)
	self:OnDataLoaded()
	self:OnSizeChanged()
	self:OnRotationChanged()
	self:OnDriverChanged()
	self:Show()
end

function CPDivider:OnPropsUpdated()
	self:SetProps(self.props)
end

function CPDivider:SetTintColor(r, g, b, a)
	local intensity = (tonumber(self.props.intensity) or 25) / 100;
	self.Gradient:SetGradient(env:GetColorGradient(r, g, b, a, intensity))
	self.Line:SetVertexColor(r, g, b, a)
end

function CPDivider:OnDataLoaded()
	self:SetTintColor(env:GetColorRGBA('tintColor'))
end

function CPDivider:OnSizeChanged()
	local width, height = self.props.breadth, self.props.depth;
	self.Gradient:SetSize(width, height)
	self.Line:SetSize(width, self.props.thickness)
end

function CPDivider:OnRotationChanged()
	local rotation = math.rad(self.props.rotation);
	local width, height = self.props.breadth, self.props.depth;
	local baseOffsetX, baseOffsetY = 0, 25;
	local baseBreadth, baseDepth = 400, 50;

	local offsetX = ( width / baseBreadth ) * baseOffsetX;
	local offsetY = ( height / baseDepth  ) * baseOffsetY;

	-- Rotate the offset vector
	local rotatedOffsetX = offsetX * math.cos(rotation) - offsetY * math.sin(rotation)
	local rotatedOffsetY = offsetX * math.sin(rotation) + offsetY * math.cos(rotation)

	self.Line:SetRotation(rotation)
	self.Gradient:SetRotation(rotation)
	self.Gradient:SetPoint('CENTER', rotatedOffsetX, rotatedOffsetY)
end

do local dividerCounter = CreateCounter()
	env:AddFactory('Divider', function()
		return CreateFrame('Frame', 'ConsolePortActionBarDivider'..dividerCounter(), env.Manager, 'CPDivider')
	end, env.Interface.Divider)
end