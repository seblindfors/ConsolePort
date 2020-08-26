---------------------------------------------------------------
-- Hotkey management
---------------------------------------------------------------
-- This handler automatically renders icons instead of hotkey
-- strings on action buttons in the interface. 

local _, db = ...;
local HotkeyMixin, HotkeyHandler = {}, CPAPI.CreateEventHandler({'Frame', '$parentHotkeyHandler', ConsolePort}, {
	'CVAR_UPDATE';
	'UPDATE_BINDINGS';
	'MODIFIER_STATE_CHANGED';
})
db:Register('Hotkeys', HotkeyHandler)
HotkeyHandler.Textures = CreateTexturePool(HotkeyHandler, 'ARTWORK')
HotkeyHandler.Widgets = CreateFramePool('Frame', HotkeyHandler, nil, function(pool, self)
	self:Hide()
	self:ClearAllPoints()
	if self.Release then
		self:Release()
		self:ClearOwner()
	end
end)

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function HotkeyHandler:ADDON_LOADED(...)
	-- need to run this on every addon loading
	self:OnInterfaceUpdated()
end

function HotkeyHandler:CVAR_UPDATE(...)
	-- not even sure this fires for gamepad stuff
end

function HotkeyHandler:UPDATE_BINDINGS(...)
	self:OnInterfaceUpdated()
end

function HotkeyHandler:MODIFIER_STATE_CHANGED(...)
	for widget in self.Widgets:EnumerateActive() do
		-- TODO: dispatch modifier
	end
end

function HotkeyHandler:OnInterfaceUpdated()
	-- hotkey rendering is expensive, make sure it doesn't run unnecessarily
	if not self.timeLock then
		self.timeLock = true
		C_Timer.After(0.5, function()
			self:OnActiveDeviceChanged()
			self.timeLock = nil
		end)
	end
end

function HotkeyHandler:OnActiveDeviceChanged()
	local device = db.Gamepad:GetActiveDevice()
	if device then
		self:UpdateHotkeys(device)
	end
end

ConsolePort:RegisterVarCallback('Gamepad/Active', HotkeyHandler.OnActiveDeviceChanged, HotkeyHandler)

---------------------------------------------------------------
-- API
---------------------------------------------------------------
function HotkeyHandler:GetIconsForModifier(modifiers, device, style)
	for i, modifier in ipairs(modifiers) do
		local button = db('Gamepad/Index/Modifier/Key/'..modifier)
		modifiers[i] = button and device:GetIconForBinding(button, style) or nil
	end
	return modifiers
end

function HotkeyHandler:GetHotkeyData(device, btnID, modID, style)
	return {
		button = device:GetIconForBinding(btnID, style);
		modifier = self:GetIconsForModifier({strsplit('-', modID)}, device, style);
	}
end

function HotkeyHandler:GetWidget()
	local frame, newObj = self.Widgets:Acquire()
	if newObj then
		Mixin(frame, HotkeyMixin)
		frame.Textures = self.Textures
	end
	return frame
end

function HotkeyHandler:Disable()
	self:UnregisterAllEvents()
	self.Widgets:ReleaseAll()
end

function HotkeyHandler:Enable()
	for _, event in ipairs(self.Events) do
		self:RegisterEvent(event)
	end
	self:OnActiveDeviceChanged()
end

---------------------------------------------------------------
-- Binding logic
---------------------------------------------------------------
function HotkeyHandler:UpdateHotkeys(device)
	self.Widgets:ReleaseAll()
	assert(device, 'No device specified when attempting to update hotkeys.')

	local bindings = db.Gamepad:GetActiveBindings()
	local bindingToActionID = {}

	for btnID, set in pairs(bindings) do
		for modID, binding in pairs(set) do
			local actionBarID = db('Actionbar/Binding/'..binding)
			if actionBarID then
				bindingToActionID[actionBarID] = self:GetHotkeyData(device, btnID, modID, 32)
			else
				local widget = _G[(gsub(gsub(binding, 'CLICK ', ''), ':.+', ''))]
				if C_Widget.IsFrameWidget(widget) then
					self:GetWidget():SetData(self:GetHotkeyData(device, btnID, modID, 32), widget)
				end
			end
		end
	end

	-- draw on action buttons
	for owner, action in db.Actionbar:GetActionButtons() do
		local data = bindingToActionID[action]
		if data then
			self:GetWidget():SetData(data, owner)
		end
	end
end

---------------------------------------------------------------
-- Hotkey mixin
---------------------------------------------------------------
HotkeyMixin.template = 'Default'; -- TODO: remove hardcoded

function HotkeyMixin:SetData(data, owner)
	self.data = data
	self:SetSize(1, 1)

	self:Release()
	self:SetOwner(owner)

	-- TODO: allow more templates
	local signature = 'return function(self, button, modifier, owner)' 
	local render, msg = loadstring(signature..self.Templates[self.template])
	if render then
		return render()(self, data.button, data.modifier, owner)
	end
	error('Hotkey template failed to compile:\n' .. msg)
end


function HotkeyMixin:Acquire()
	local texture = self.Textures:Acquire()
	texture:SetParent(self)
	return texture
end

function HotkeyMixin:Release()
	for obj in self.Textures:EnumerateActive() do
		if ( obj:GetParent() == self ) then
			self.Textures:Release(obj)
		end
	end
end

function HotkeyMixin:SetOwner(owner)
	self:SetParent(owner)
	if owner.HotKey then
		self.preAlpha = owner.HotKey:GetAlpha()
		owner.HotKey:SetAlpha(0)
	end
	self:Show()
end

function HotkeyMixin:ClearOwner()
	local owner = self:GetParent()
	if owner and owner.HotKey and self.preAlpha then
		owner.HotKey:SetAlpha(self.preAlpha)
	end
	self.preAlpha = nil
	self:SetParent(HotkeyHandler)
end

---------------------------------------------------------------
-- Hotkey templates
---------------------------------------------------------------
-- TODO: write more templates, allow some kind of savedvar for this
HotkeyMixin.Templates = {
	Default = [[
		self:SetPoint('TOPRIGHT', owner, 0, 0)
		local cur = self:Acquire()

		cur:SetSize(24, 24)
		cur:SetPoint('TOPRIGHT', 4, 4)
		cur:SetTexture(button)
		cur:Show()

		for i = 1, #modifier do
			local mod = self:Acquire()
			mod:SetSize(24, 24)
			mod:SetPoint('RIGHT', cur, 'LEFT', 14, 0)
			mod:SetTexture(modifier[i])
			mod:Show()
			cur = mod
		end
	end]];
};
db('Hotkeys/Template', HotkeyMixin.Templates)
