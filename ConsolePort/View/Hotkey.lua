---------------------------------------------------------------
-- Hotkey management
---------------------------------------------------------------
-- This handler automatically renders icons instead of hotkey
-- strings on action buttons in the interface.

local _, db = ...;
local HotkeyMixin, HotkeyHandler = {}, CPAPI.CreateEventHandler({'Frame', '$parentHotkeyHandler', ConsolePort}, {
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

db:RegisterCallback('Gamepad/Active', HotkeyHandler.OnActiveDeviceChanged, HotkeyHandler)

---------------------------------------------------------------
-- API
---------------------------------------------------------------
HotkeyHandler.Format = {
	Atlas = ('|A:%s:14:14|a');
	Large = ('|A:%s:24:24|a');
	[32]  = ('|T%s:0:0:0:0:32:32:8:24:8:24|t');
	[64]  = ('|T%s:24:24:0:0:64:64:0:64:0:64|t');
};

function HotkeyHandler:GetIconsForModifier(modifiers, device, style)
	for i, modifier in ipairs(modifiers) do
		local button = db('Gamepad/Index/Modifier/Key/'..modifier)
		modifiers[i] = button and {device:GetIconForButton(button, style)} or {}
	end
	return modifiers
end

function HotkeyHandler:GetHotkeyData(device, btnID, modID, styleMain, styleMod)
	return {
		button = {device:GetIconForButton(btnID, styleMain)};
		modifier = self:GetIconsForModifier({strsplit('-', modID)}, device, styleMod);
	}
end

function HotkeyHandler:FormatIconSlug(iconData, iconFormat, atlasFormat)
	local icon, isAtlas = unpack(iconData)
	if not icon then return end;
	if isAtlas then
		return (atlasFormat or self.Format.Atlas):format(icon), icon, true;
	end
	return (iconFormat or self.Format[32]):format(icon), icon, false;
end

function HotkeyHandler:GetButtonSlug(device, btnID, modID, split, large)
	local atlasFormat = large and self.Format.Large or self.Format.Atlas;
	local iconFormat  = large and self.Format[64] or self.Format[32];
	local styleFormat = large and 64 or 32;

	local data = self:GetHotkeyData(device, btnID, modID, split and 64 or styleFormat, styleFormat)
	local slug = {};

	for i, modData in db.table.ripairs(data.modifier) do
		slug[#slug + 1] = self:FormatIconSlug(modData, iconFormat, atlasFormat)
	end

	if split then
		return slug, data;
	end

	slug[#slug + 1] = self:FormatIconSlug(data.button, iconFormat, atlasFormat)
		or _G[('KEY_ABBR_%s'):format(btnID)]
		or btnID:gsub('^PAD', '')

	return table.concat(slug)
end

function HotkeyHandler:GetActiveButtonSlug(btnID, modID, split)
	local device = db('Gamepad/Active')
	if device then
		return self:GetButtonSlug(device, btnID, modID, split)
	end
end

do local function GetBindingSlugs(self, device, split, large, key, ...)
		if key then
			local splitSlug = {strsplit('-', key)}
			local btnID = tremove(splitSlug)
			local slug, data = self:GetButtonSlug(device, btnID, table.concat(splitSlug, '-'), split, large)
			if split then
				return slug, data, GetBindingSlugs(self, device, split, large, ...)
			end
			return slug, GetBindingSlugs(self, device, split, large, ...)
		end
	end

	function HotkeyHandler:GetButtonSlugForBinding(binding, split, large)
		local device = db('Gamepad/Active')
		if not device then return end;
		return GetBindingSlugs(self, device, split, large, db.Gamepad:GetBindingKey(binding))
	end

	function HotkeyHandler:GetButtonSlugsForBinding(binding, separator, limit)
		local slugs = {self:GetButtonSlugForBinding(binding)}
		if limit then
			for i = limit + 1, #slugs do
				slugs[i] = nil;
			end
		end
		return table.concat(slugs, separator)
	end
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
	if db('disableHotkeyRendering') then return end
	if not CPAPI.IsRetailVersion then self:ReplaceHotkeyFont() end

	local bindings = db.Gamepad:GetBindings()
	local bindingToActionID = {}

	for btnID, set in pairs(bindings) do
		for modID, binding in pairs(set) do
			local actionBarID = db('Actionbar/Binding/'..binding)
			if actionBarID then
				bindingToActionID[binding] = self:GetHotkeyData(device, btnID, modID, 32, 32)
			else
				local widget = _G[(gsub(gsub(binding, 'CLICK ', ''), ':.+', ''))]
				if C_Widget.IsFrameWidget(widget) then
					self:GetWidget():SetData(self:GetHotkeyData(device, btnID, modID, 32, 32), widget)
				end
			end
		end
	end

	-- draw on action buttons
	for owner, action in db.Actionbar:GetActionButtons() do
		local data = bindingToActionID[db('Actionbar/Action/'..action)]
		if data then
			self:GetWidget():SetData(data, owner)
		end
	end
end

---------------------------------------------------------------
-- Replace font on Blizzard hotkey template
---------------------------------------------------------------
-- The original font draws an outline around each character,
-- pushing the text width over 36 px for double modifier
-- combinations. Removing the outline places 3 icons at exactly
-- 36 px without reducing the icon fidelity.
function HotkeyHandler:ReplaceHotkeyFont()
	NumberFontNormalSmallGray:SetFont('FONTS\\ARIALN.TTF', 12, '')
end

---------------------------------------------------------------
-- Hotkey mixin
---------------------------------------------------------------
HotkeyMixin.template = 'Default'; -- TODO: remove hardcoded

function HotkeyMixin:SetData(data, owner)
	if owner:GetAttribute(CPAPI.SkipHotkeyRender) then
		return
	end

	self.data = data
	self:SetSize(1, 1)

	self:Release()
	self:SetOwner(owner)

	-- TODO: allow more templates
	local signature = 'return function(self, button, modifier, owner)\n%s\nend' 
	local render, msg = loadstring(signature:format(self.Templates[self.template]))
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
		self.preShown = owner.HotKey:IsShown()
		owner.HotKey:SetAlpha(0)
		owner.HotKey:Hide()
	end
	self:Show()
end

function HotkeyMixin:ClearOwner()
	local owner = self:GetParent()
	if owner and owner.HotKey and self.preAlpha then
		owner.HotKey:SetAlpha(self.preAlpha)
		owner.HotKey:SetShown(self.preShown)
	end
	self.preShown = nil;
	self.preAlpha = nil;
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

		local _, isAtlas = unpack(button)
		local offset = isAtlas and 2 or 4;
		local size = isAtlas and 14 or 24;

		CPAPI.SetTextureOrAtlas(cur, button)
		cur:SetSize(size, size)
		cur:SetPoint('TOPRIGHT', offset, offset)
		cur:Show()

		for i = 1, #modifier do
			local mod = self:Acquire()
			CPAPI.SetTextureOrAtlas(mod, modifier[i])
			mod:SetSize(size, size)
			mod:SetPoint('RIGHT', cur, 'LEFT', isAtlas and 1 or 14, 0)
			mod:Show()
			cur = mod
		end
	]];
};
db('Hotkeys/Template', HotkeyMixin.Templates)