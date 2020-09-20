local _, env = ...;
---------------------------------------------------------------
-- Shortcuts
---------------------------------------------------------------
local Shortcuts, Shortcut = CreateFromMixins(env.DynamicMixin), {}
env.ShortcutsMixin = Shortcuts;

function Shortcut:OnClick()
	local scrollFraction = self.container:ScrollTo(self:GetID(), self.container:GetNumActive())
	self.container:SetFocusByIndex(self:GetAttribute('button'))
	env.Bindings:NotifyComboFocus(self:GetID(), self:GetAttribute('button'), scrollFraction)
end

function Shortcuts:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonIconTemplate', Shortcut, nil, self.Child);
end

function Shortcuts:OnScrollFinished()
	local widget = self:GetFocusWidget()
	if widget then
		widget:SetChecked(false)
		widget:OnChecked(false)
	end
end

function Shortcuts:OnShow()
	local device, map = self.parent:GetActiveDeviceAndMap()
	if not device or not map then 
		return self.Child:SetSize(0, 0)
	end

	local id, width, height, prev = 1, self.Child:GetWidth(), 0;
	for i=0, #map do
		local binding = map[i].Binding;
		-- assert this button has an icon
		if ( device:GetIconIDForButton(binding) ) then

			local icon = device:GetIconForButton(binding)
			local widget, newObj = self:Acquire(binding)

			if newObj then
				local widgetWidth = widget:GetWidth()
				width = widgetWidth > width and widgetWidth or width;
				widget.container = self;
				widget:SetSiblings(self.Registry)
				CPAPI.Start(widget)
			end

			widget:SetAttribute('button', binding)
			widget:SetIcon(icon)
			widget:SetID(id)
			widget:Show()
			widget:SetPoint('TOP', prev or self.Child, prev and 'BOTTOM' or 'TOP', 0, 0)

			height = height + widget:GetHeight()
			id, prev = id + 1, widget;
		end
	end
	self.Child:SetSize(width, height)
end
