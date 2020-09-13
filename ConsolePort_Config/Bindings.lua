local db = ConsolePort:DB()
local BindingsMixin, DynamicMixin = {}, CreateFromMixins(CPFocusPoolMixin)

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
function DynamicMixin:OnHide()
	self:ReleaseAll()
end

function DynamicMixin:GetWidgetByID(id, name)
	for regID, widget in pairs(self.Registry) do
		if ( widget:GetID() == id or name == regID ) then
			return widget;
		end
	end
end

function BindingsMixin:GetActiveDeviceAndMap()
	-- using ID to get the buttons in WinRT API order (NOTE: zero-indexed)
	return db('Gamepad/Active'), db('Gamepad/Index/Button/ID')
end

function BindingsMixin:GetActiveModifiers()
	return db('Gamepad/Index/Modifier/Active')
end

function BindingsMixin:GetHotkeyData(btnID, modID, styleMain, styleMod)
	return db('Hotkeys'):GetHotkeyData(db('Gamepad/Active'), btnID, modID, styleMain, styleMod)
end

function BindingsMixin:GetBindings()
	return db('Gamepad'):GetBindings()
end

---------------------------------------------------------------
-- Shortcuts
---------------------------------------------------------------
local Shortcuts, Shortcut = CreateFromMixins(DynamicMixin), {}

function Shortcut:OnClick()
	self.container:ScrollTo(self:GetID(), self.container:GetNumActive())
end

function Shortcuts:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonIconTemplate', Shortcut, nil, self.Child);
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

---------------------------------------------------------------
-- Combinations (abbrev. combos)
---------------------------------------------------------------
local Combos, Combo = CreateFromMixins(DynamicMixin), {}

function Combos:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
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

			for mod, keys in db.table.spairs(mods) do
				local widget, newObj = self:Acquire(mod..binding)
				if newObj then
					local widgetWidth = widget:GetWidth()
					width = widgetWidth > width and widgetWidth or width;
					widget.container = self;
					widget:SetSiblings(self.Registry)
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
	self.Child:SetSize(width, height)
end

---------------------------------------------------------------
-- Main frame
---------------------------------------------------------------
function BindingsMixin:OnShow()
	self.container:OnContainerSizeChanged()
end

function BindingsMixin:OnActiveDeviceChanged(device)
	self.device = device;
end

function BindingsMixin:OnLoad()
	local shortcuts = self:CreateScrollableColumn('Shortcuts', {
		['<Mixin>']  = Shortcuts;
		['<Width>']  = 62;
		['<SetDelta>'] = 32;
		['<Points>'] = {
			{'TOPLEFT', 0, 0};
			{'BOTTOMLEFT', 0, 0};
		};
	})
	local combos = self:CreateScrollableColumn('Combinations', {
		['<Mixin>']  = Combos;
		['<Width>']  = 250;
		['<SetDelta>'] = 32;
		['<Points>'] = {
			{'TOPLEFT', shortcuts, 'TOPRIGHT', 0, 0};
			{'BOTTOMLEFT', shortcuts, 'BOTTOMRIGHT', 0, 0};
		};
	})
	self:OnActiveDeviceChanged(db('Gamepad/Active'))
	db:RegisterCallback('Gamepad/Active', self.OnActiveDeviceChanged, self)
end

local Bindings = ConsolePortConfig:CreatePanel({
	name  = 'Bindings';
	mixin = BindingsMixin;
	scaleToParent = true;
})