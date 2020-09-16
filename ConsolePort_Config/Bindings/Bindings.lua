local db, _, env = ConsolePort:DB(), ...;
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
	local scrollFraction = self.container:ScrollTo(self:GetID(), self.container:GetNumActive())
	self.container:SetFocusByIndex(self:GetAttribute('button'))
	self.container.parent:NotifyFocus(self:GetID(), self:GetAttribute('button'), scrollFraction)
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

---------------------------------------------------------------
-- Combinations (abbrev. combos)
---------------------------------------------------------------
local Combos, Combo = CreateFromMixins(DynamicMixin), CreateFromMixins(env.BindingInfoMixin)

function Combo:UpdateBinding(combo)
	local name, texture, actionID = self:GetBindingInfo(GetBindingAction(combo))
	self:SetText(name)
	self.ActionIcon:SetAlpha(texture and 1 or 0)
	self.Mask:SetAlpha(texture and 1 or 0)
	if texture then
		SetPortraitToTexture(self.ActionIcon, texture) -- bug if action texture isnt 64x64, replace with mask
	end
	if actionID then
		self:SetAttribute('action', actionID)
		self:RegisterEvent('ACTIONBAR_SLOT_CHANGED')
		self:RegisterEvent('UPDATE_SHAPESHIFT_FORM')
	else
		self:SetAttribute('action', nil)
		self:UnregisterEvent('ACTIONBAR_SLOT_CHANGED')
		self:UnregisterEvent('UPDATE_SHAPESHIFT_FORM')
	end
end

function Combo:OnEvent(event, ...)
	if (event == 'ACTIONBAR_SLOT_CHANGED') then
		local actionID = ...;
		if (actionID == self:GetAttribute('action')) then
			self:UpdateBinding(self:GetAttribute('combo'))
		end
	elseif (event == 'UPDATE_SHAPESHIFT_FORM') then
		self:UpdateBinding(self:GetAttribute('combo'))
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
	if GetCursorInfo() and self:GetAttribute('action') then
		PlaceAction(self:GetAttribute('action'))
		self:SetChecked(false)
	end
	self:OnChecked(self:GetChecked())
end

function Combo:OnShow()
	self:UpdateBinding(self:GetAttribute('combo'))
end

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

			for mod, keys in db.table.mpairs(mods) do -- TODO: the order is wrong
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

---------------------------------------------------------------
-- Main frame
---------------------------------------------------------------
function BindingsMixin:OnShow()
	self.container:OnContainerSizeChanged()
end

function BindingsMixin:OnActiveDeviceChanged(device)
	self.device = device;
end

function BindingsMixin:NotifyFocus(id, name, fraction)
	local combo = self.Combinations:GetWidgetByID(id, name)
	if fraction then
		self.Combinations:ScrollToOffset(fraction)
	end
end

function BindingsMixin:OnLoad()
	local shortcuts = self:CreateScrollableColumn('Shortcuts', {
		['<Mixin>']  = Shortcuts;
		['<Width>']  = 0.01;
		['<SetDelta>'] = 60;
		['<Points>'] = {
			{'TOPLEFT', 0, 0};
			{'BOTTOMLEFT', 0, 0};
		};
		{
			Line = {
				['<Type>'] = 'CheckButton';
				['<Setup>'] = 'BackdropTemplate';
				['<Width>'] = 24;
				['<Points>'] = {
					{'TOPLEFT', 'parent', 'TOPRIGHT', 0, 0};
					{'BOTTOMLEFT', 'parent', 'BOTTOMRIGHT', 0, 0};
				};
				['<Backdrop>'] = CPAPI.Backdrops.Opaque;
				['<SetBackdropBorderColor>'] = {0.15, 0.15, 0.15, 1};
				['<SetNormalTexture>'] = 'Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton';
				['<SetHighlightTexture>'] = 'Interface\\PaperDollInfoFrame\\UI-GearManager-FlyoutButton';
				['state'] = false;
				['<OnLoad>'] = function(self)
					local r, g, b = CPAPI.GetWebColor(CPAPI.GetClassFile()):GetRGB()
					self:SetBackdropBorderColor(0.15, 0.15, 0.15, 1)
					self.Center:SetGradientAlpha('HORIZONTAL', r*2, g*2, b*2, 1, r/1.25, g/1.25, b/1.25, 1)
					local normal = self:GetNormalTexture()
					local hilite = self:GetHighlightTexture()
					normal:ClearAllPoints()
					normal:SetPoint('CENTER', -1, 0)
					normal:SetSize(16, 32)
					hilite:ClearAllPoints()
					hilite:SetPoint('CENTER', -1, 0)
					hilite:SetSize(16, 32)
					EquipmentFlyoutPopoutButton_SetReversed(self, false)
				end;
				['<OnClick>'] = function(self)
					local parent = self:GetParent()
					local target = self:GetChecked() and parent.Child:GetWidth() or 0.01;
					EquipmentFlyoutPopoutButton_SetReversed(self, self:GetChecked())
					self:SetScript('OnUpdate', function(self, elapsed)
						local current = parent:GetWidth()
						if abs(current - target) < 2 then
							parent:SetWidth(target)
							self:SetScript('OnUpdate', nil)
							return
						end
						local delta = current > target and -1 or 1
						parent:SetWidth(current + (delta * abs(current - target) / 5))
					end)
				end;
			};
		}
	})
	local combos = self:CreateScrollableColumn('Combinations', {
		['<Mixin>']  = Combos;
		['<Width>']  = 300;
		['<SetDelta>'] = 60;
		['<Points>'] = {
			{'TOPLEFT', shortcuts.Line, 'TOPRIGHT', 0, 0};
			{'BOTTOMLEFT', shortcuts.Line, 'BOTTOMRIGHT', 0, 0};
		};
		['<Hooks>'] = {
			['OnMouseWheel'] = function(self)
				if not shortcuts.Line:GetChecked() then
					shortcuts.Line:Click()
				end
			end;
		};
	})
	local manager = self:CreateScrollableColumn('Manager', {
		['<Mixin>'] = env.BindingManager;
		['<Setup>'] = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		['<Width>'] = 600;
		['<Backdrop>'] = CPAPI.Backdrops.Opaque;
		['<Points>'] = {
			{'TOPLEFT', combos, 'TOPRIGHT', 0, 1};
			{'BOTTOMLEFT', combos, 'BOTTOMRIGHT', 0, -1};
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