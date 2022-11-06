local _, env = ...;
---------------------------------------------------------------
-- Shortcuts
---------------------------------------------------------------
local Shortcuts, Shortcut = CreateFromMixins(env.DynamicMixin, env.FlexibleMixin), {}
env.ComboShortcutsMixin = Shortcuts;

function Shortcut:OnClick()
	local scrollFraction = self.container:ScrollTo(self:GetID(), self.container:GetNumActive())
	self.container:SetFocusByIndex(self:GetAttribute('button'))
	env.Bindings:NotifyComboFocus(self:GetID(), self:GetAttribute('button'), scrollFraction)
end

function Shortcuts:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	self:SetFlexibleElement(self, self.Child)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonIconTemplate', Shortcut, nil, self.Child);
end

function Shortcuts:OnScrollFinished()
	local widget = self:GetFocusWidget()
	if widget then
		widget:Uncheck()
	end
end

function Shortcuts:OnShow()
	local device, map = env:GetActiveDeviceAndMap()
	if not device or not map then 
		return self.Child:SetSize(0, 0)
	end

	local id, width, height, prev = 1, self.Child:GetWidth(), 0;
	for i=0, #map do
		local button = map[i].Binding;
		-- assert this button has an icon
		if ( device:IsButtonValidForBinding(button) ) then
			local widget, newObj = self:Acquire(button)

			if newObj then
				local widgetWidth = widget:GetWidth()
				width = widgetWidth > width and widgetWidth or width;
				widget.container = self;
				widget:SetSiblings(self.Registry)
				CPAPI.Start(widget)
			end

			CPAPI.SetTextureOrAtlas(widget.Icon, {device:GetIconForButton(button)})
			widget:SetAttribute('button', button)
			widget:SetID(id)
			widget:Show()
			widget:SetPoint('TOP', prev or self.Child, prev and 'BOTTOM' or 'TOP', 0, 0)

			height = height + widget:GetHeight()
			id, prev = id + 1, widget;
		end
	end
	self.Child:SetSize(width, height)
end
