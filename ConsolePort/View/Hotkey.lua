local _, db = ...;
local HotkeyMixin, HotkeyHandler = {}, CPAPI.CreateEventHandler({'Frame', 'ConsolePortHotkeyHandler'}, {
	'CVAR_UPDATE';
	'UPDATE_BINDINGS';
	'MODIFIER_STATE_CHANGED';
})
db:Register('Hotkeys', HotkeyHandler)
HotkeyHandler.Widgets = CreateFramePool('Frame', HotkeyHandler)

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function HotkeyHandler:CVAR_UPDATE(...)
	-- not even sure this fires for gamepad stuff
end

function HotkeyHandler:UPDATE_BINDINGS(...)
	self:UpdateHotkeys()
end

function HotkeyHandler:MODIFIER_STATE_CHANGED(...)
	for self.Widgets:EnumerateActive() do
		-- dispatch modifier
	end
end

function HotkeyHandler:OnDataLoaded()

end

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

function HotkeyHandler:AcquireAnchor(host)
	local frame, newObj = self.Widgets:Acquire()
	if newObj then
		Mixin(frame, HotkeyMixin)
		frame.textures = CreateTexturePool(frame, 'ARTWORK')
	end
	frame:SetParent(host)
	frame:Show()
	return frame
end

function HotkeyHandler:UpdateHotkeys()
	self.Widgets:ReleaseAll()

	local device = db.Gamepad:GetActiveDevice()
	local bindings = db.Gamepad:GetActiveBindings()
	local bindingToActionID = {}

	for btnID, set in pairs(bindings) do
		for modID, binding in pairs(set) do
			local actionBarID = db('Actionbar/Binding/'..binding)
			if actionBarID then
				bindingToActionID[actionBarID] = {
					modifier = self:GetIconsForModifier({strsplit('-', modID)}, device, 32);
					button = device:GetIconForBinding(btnID, 32);
				};
			end
		end
	end

	for host, action in db.Actionbar:GetActionButtons() do
		local data = bindingToActionID[action]
		if data then
			data.host = host
			self:AcquireAnchor(host):SetData(data)
		end
	end
end

ConsolePort:RegisterVarCallback('Gamepad/Active', HotkeyHandler.UpdateHotkeys, HotkeyHandler)


---------------------------------------------------------------
-- Hotkey mixin
---------------------------------------------------------------
HotkeyMixin.template = 'Default'; -- TODO: remove hardcoded

function HotkeyMixin:SetData(data)
	self.data = data
	self:SetSize(1, 1)
	self.textures:ReleaseAll()
	if data.host.HotKey then
		data.host.HotKey:SetAlpha(0)
	end
	-- TODO: allow more templates
	local signature = 'return function(self, pool, button, modifier, host)' 
	local render, msg = loadstring(signature..self.Templates[self.template])
	if render then
		return render()(self, self.textures, data.button, data.modifier, data.host)
	end
	error('Hotkey template failed to compile:\n' .. msg)
end


---------------------------------------------------------------
-- Hotkey mixin
---------------------------------------------------------------
-- TODO: write more templates, allow some kind of savedvar for this
HotkeyMixin.Templates = {
	Default = [[
		self:SetPoint('TOPRIGHT', host, 0, 0)
		local cur = pool:Acquire()

		cur:SetSize(24, 24)
		cur:SetPoint('TOPRIGHT', 4, 4)
		cur:SetTexture(button)
		cur:Show()

		for i = #modifier, 1, -1 do
			local mod = pool:Acquire()
			mod:SetSize(24, 24)
			mod:SetPoint('RIGHT', cur, 'LEFT', 14, 0)
			mod:SetTexture(modifier[i])
			mod:Show()
			cur = mod
		end
	end]];
};
db('Hotkeys/Template', HotkeyMixin.Templates)
