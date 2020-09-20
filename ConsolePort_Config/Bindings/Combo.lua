local db, _, env = ConsolePort:DB(), ...;
---------------------------------------------------------------
-- Combinations (abbrev. combos)
---------------------------------------------------------------
local Combos, Combo = CreateFromMixins(env.DynamicMixin, env.FlexibleMixin), CreateFromMixins(env.BindingInfoMixin, {
	-- true for events related to action bar, false for events related to bindings.
	Events = {
		ACTIONBAR_SLOT_CHANGED = true;
		UPDATE_SHAPESHIFT_FORM = true;
		ACTIONBAR_SHOWGRID     = false;
		ACTIONBAR_HIDEGRID     = false;
	};
}); env.CombosMixin = Combos;

function Combo:UpdateBinding(combo)
	local name, texture, actionID = self:GetBindingInfo(self:GetBinding(), nil)
	self:SetText(name)
	self.ActionIcon:SetAlpha(texture and 1 or 0)
	self.Mask:SetAlpha(texture and 1 or 0)
	self.ActionIcon:SetTexture(texture)
	self:SetAttribute('action', actionID)
	for event, state in pairs(self.Events) do
		if ( not state == not actionID ) then
			self:RegisterEvent(event)
		else
			self:UnregisterEvent(event)
		end
	end
end

function Combo:GetBinding()
	return GetBindingAction(self:GetAttribute('combo')), self:GetAttribute('action')
end

function Combo:GetAction()
	return self:GetAttribute('action')
end

function Combo:OnEvent(event, ...)
	-- action bar
	if (event == 'ACTIONBAR_SLOT_CHANGED') then
		local actionID = ...;
		if (actionID == self:GetAttribute('action')) then
			self:UpdateBinding()
		end
	elseif (event == 'UPDATE_SHAPESHIFT_FORM') then
		self:UpdateBinding()
	-- normal binding
	elseif (event == 'ACTIONBAR_SHOWGRID') then
		self:SetEnabled(false)
		self:SetAlpha(0.5)
	elseif (event == 'ACTIONBAR_HIDEGRID') then
		self:SetEnabled(true)
		self:SetAlpha(1)
	end
end

function Combo:OnReceiveDrag()
	if GetCursorInfo() and self:GetAttribute('action') then
		PlaceAction(self:GetAttribute('action'))
	end
end

function Combo:OnDragStart()
	if self:GetAttribute('action') then
		PickupAction(self:GetAttribute('action'))
	end
end

function Combo:OnClick()
	local isActionDrop;
	if GetCursorInfo() and self:GetAttribute('action') then
		PlaceAction(self:GetAttribute('action'))
		self:SetChecked(false)
		isActionDrop = true;
	end
	self:OnChecked(self:GetChecked())
	if not isActionDrop then
		env.Bindings:NotifyBindingFocus(self, self:GetChecked(), true)
	end
end

function Combo:OnShow()
	self:UpdateBinding()
end

function Combo:OnChecked(show)
	CPIndexButtonMixin.OnChecked(self, show)
end

function Combos:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	self:SetFlexibleElement(self, self.Child)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingComboTemplate', Combo, nil, self.Child)
end

function Combos:OnShow()
	local device, map = self.parent:GetActiveDeviceAndMap()
	local mods = self.parent:GetActiveModifiers()
	if not device or not map or not mods then
		return self.Child:SetSize(0, 0)
	end

	local id, width, height, prev = 1, self.Child:GetWidth(), 0;
	for i=0, #map do
		local binding = map[i].Binding;
		-- assert this button has an icon
		if ( device:GetIconIDForButton(binding) ) then

			for mod, keys in db.table.mpairs(mods) do
				local widget, newObj = self:Acquire(mod..binding)
				if newObj then
					local widgetWidth = widget:GetWidth()
					width = widgetWidth > width and widgetWidth or width;
					widget.container = self;
					widget:SetSiblings(self.Registry)
					widget:SetDrawOutline(true)
					widget:RegisterForDrag('LeftButton')
					CPAPI.Start(widget)
				end

				local data = self.parent:GetHotkeyData(binding, mod, 64, 32)
				local modstring = '';

				for i, mod in ripairs(data.modifier) do
					modstring = modstring .. ('|T%s:0:0:0:0:32:32:8:24:8:24|t'):format(mod)
				end

				widget.Modifier:SetText(modstring)
				widget:SetIcon(data.button)
				widget:SetID(id)
				widget:SetAttribute('combo', mod..binding)
				widget:Show()
				widget:SetPoint('TOP', prev or self.Child, prev and 'BOTTOM' or 'TOP', 0, 0)

				prev, height = widget, height + widget:GetHeight();
			end

			id = id + 1;
		end
	end
	self:SetAttribute('numsets', id)
	self.Child:SetSize(width, height)
end