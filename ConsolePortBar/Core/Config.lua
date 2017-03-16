local addOn, ab = ...
local db = ab.data
local Bar = ab.bar
local WindowMixin, Layout, Button, Position, Color, Bool, Profiler, Preset = {}, {}, {}, {}, {}, {}, {}, {}

local VALID_POINTS = {
	TOP = true, 
	LEFT = true, TOPLEFT = true, BOTTOMLEFT = true,
	RIGHT = true, TOPRIGHT = true, BOTTOMRIGHT = true,
	BOTTOM = true,
	CENTER = true,
}
local VALID_DIRS = {
	up = true,
	left = true,
	down = true,
	right = true,
	[''] = true,
}

function Button:OnShow()
	local entry = self.Layout.cfg[self.Binding]
	local point = entry and entry.point
	local size = entry and entry.size
	local dir = entry and entry.dir
	self:SetChecked(entry and true or false)
	if dir then
		self.direction:Enable()
		self.direction:SetText(dir)
		self.Wrapper:UpdateOrientation(dir)
	else
		self.direction:Disable()
		self.direction:SetText('')
	end
	if size then
		self.size:Enable()
		self.size:SetNumber(size)
		self.Wrapper:SetSize(size)
	else
		self.size:Disable()
		self.size:SetText('')
	end
	if point then
		self.Wrapper:SetPoint(unpack(point))
		self.Wrapper:Show()
		self.point:Enable() self.xOffset:Enable() self.yOffset:Enable()
		self.point:SetText(point[1]) self.xOffset:SetText(point[2]) self.yOffset:SetText(point[3])
	else
		self.Wrapper:SetPoint()
		self.Wrapper:Hide()
		self.size:Disable() self.point:Disable() self.xOffset:Disable() self.yOffset:Disable()
		self.point:SetText('') self.xOffset:SetText('') self.yOffset:SetText('')
	end
end

function Button:OnClick()
	if not self.Layout.cfg[self.Binding] then
		self.Layout.cfg[self.Binding] = ab:GetDefaultButtonLayout(self.Binding) or { point = {'CENTER', 0, 0}, dir = 'down', size = 64}
	else
		self.Layout.cfg[self.Binding] = nil
	end
	self:OnShow()
end

function Button:UpdateButton(id, setting, value)
	local entry = self.Layout.cfg[self.Binding]
	local settings = entry and entry[setting]
	if type(settings) == 'table' then
		settings[id] = value
	else
		entry[setting] = value
	end
	if entry.dir then
		self.Wrapper:UpdateOrientation(entry.dir)
	end
	if entry.point then
		self.Wrapper:SetPoint(unpack(entry.point))
	end
	if entry.size then
		self.Wrapper:SetSize(entry.size)
	end
end

function Position:OnLoad(id, type, width, valids, filter, prev, next)
	self.Owner = self:GetParent()
	self.Layout = self.Owner.Layout
	self.Binding = self.Owner.Binding
	self.Wrapper = self.Owner.Wrapper
	self.Next = next
	self.Prev = prev
	self.type = type
	self.valids = valids
	self.filter = filter
	self:SetAutoFocus(false)
	self:SetFont(CombatLogFont:GetFont())
	self:SetBackdrop(db.Atlas.Backdrops.FullSmall)
	self:SetID(id)
	self:SetJustifyH('CENTER')
	self:SetSize(width, 42)
end

function Position:OnDeltaChanged(delta)
	if self.isNumeric and self.Owner:GetChecked() then
		local number = self:GetNumber()
		self:SetNumber(number + (  delta * 5 ) )
		self.Owner:UpdateButton(self:GetID(), self.type, self:GetNumber())
	end
end

function Position:OnEscapePressed()
	self.Owner:UpdateButton(self:GetID(), self.type, self.Backup)
	self:ClearFocus()
end

function Position:OnEnterPressed()
	self:ClearFocus()
end

function Position:OnTabPressed()
	self:OnEnterPressed()
	if IsShiftKeyDown() and self.Prev and self.Prev:IsEnabled() then
		self.Prev:SetFocus()
	elseif self.Next and self.Next:IsEnabled() then
		self.Next:SetFocus()
	end
end

function Position:OnMouseUp(button)
	if self.clickToConfirm and self:HasFocus() then
		if button == 'LeftButton' then
			self:OnEnterPressed()
		elseif button == 'RightButton' then
			self:OnEscapePressed()
		end
	else
		self.clickToConfirm = true
	end
end

function Position:OnCursorChanged()
	self.clickToConfirm = nil
end

function Position:OnEditFocusGained()
	if self.isNumeric then
		self.Backup = self:GetNumber()
		self:SetScript('OnMouseWheel', self.OnDeltaChanged)
	else
		self.Backup = self:GetText()
	end
	self.Backup = self.isNumeric and self:GetNumber() or self:GetText()
end

function Position:OnEditFocusLost()
	local entry = self.Layout.cfg[self.Binding]
	local val = entry and entry[self.type]
	if val then
		self:SetText((type(val) == 'table' and val[self:GetID()]) or val)
		self:SetTextColor(1, 1, 1)
	end
	self:SetScript('OnMouseWheel', nil)
	self.Backup = nil
	self.clickToConfirm = nil
end

function Position:OnTextChanged(userInput)
	if userInput then
		if self.isNumeric then
			local number = self:GetNumber()
			if tonumber(self:GetText()) then
				self:SetTextColor(1, 1, 1)
			else
				self:SetTextColor(.75, .75, .75)
			end
			self.Owner:UpdateButton(self:GetID(), self.type, number)
		else
			local text = self:GetText()
			if self.valids[self.filter(text)] then
				self:SetTextColor(1, 1, 1)
				self.Owner:UpdateButton(self:GetID(), self.type, self.filter(text))
			else
				self:SetTextColor(.75, .75, .75)
			end
		end
	end
end

function Bool:OnClick()
	self:SetChecked(self:GetChecked())
	ab.cfg[self.cvar] = self:GetChecked()
	ab.bar:OnLoad(ab.cfg, true)
end

function Bool:OnShow()
	self:SetChecked(ab.cfg[self.cvar])
end

function Color:OnClick(button)
	if button == 'LeftButton' then
		local r, g, b, a = ab:GetRGBColorFor(self.element)
		ColorPickerFrame:SetColorRGB(r, g, b, a)
		ColorPickerFrame.hasOpacity = true
		ColorPickerFrame.opacity = 1 - a
		ColorPickerFrame.previousValues = {r, g, b, a}
		ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = 
		self.Callback, self.Callback, self.Callback
		ColorPickerFrame:Hide()
		ColorPickerFrame:Show()
		ColorPickerFrame:GetScript('OnColorSelect')(ColorPickerFrame, r, g, b)
	else
		local r, g, b, a = ab:GetRGBColorFor(self.element, true)
		ab.cfg[self.id] = {r, g, b, a}
		Bar:OnLoad(ab.cfg, true)
		self:OnShow()
	end
end

function Color:OnEnter()
	local r, g, b, a = ab:GetRGBColorFor(self.element)
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	GameTooltip:SetText(format(db.ACTIONBAR.CFG_COLOR_TOOLTIP, floor(r * 255), floor(g * 255), floor(b * 255), floor(a * 100)))
end

function Color:OnLeave()
	GameTooltip:Hide()
end

function Color:OnShow()
	local r, g, b, a = ab:GetRGBColorFor(self.element)
	self.Display:SetColorTexture(r, g, b, a)
end

function Layout:OnShow()
	self.cfg = ab.cfg.layout
	for i, button in pairs(self.Buttons) do
		button:Show()
	end
	self.Popout:Show()
	self:Refresh(#self.Buttons)
end

function Layout:OnHide()
	for i, button in pairs(self.Buttons) do
		button:Hide()
	end
end

function Layout:CreateHeader(...)
	local frame = CreateFrame('Frame', nil, self.Child)
	frame:SetSize(1, 42)
	frame.Objects = {}
	for i, info in pairs({...}) do
		local object = frame['Create' .. info.type](frame, unpack(info.setup))
		local anchor = frame.Objects[i-1]
		object['Set' .. info.data](object, type(info.val) == 'table' and unpack(info.val) or info.val)
		object:SetPoint('LEFT', anchor or frame, anchor and 'RIGHT' or 'LEFT', info.x or 0, info.y or 0)
		frame.Objects[#frame.Objects + 1] = object
	end
	self:AddButton(frame, 12, 0)
	return frame
end

function Layout:CreateButton(binding, icon)
	local button = CreateFrame('CheckButton', '$parent'..binding, self.Child, 'ChatConfigCheckButtonTemplate')
	button.Layout = self
	button.Binding = binding
	button.Wrapper = ab.libs.registry[binding]
	button.Icon = button:CreateTexture('$parentIcon', 'ARTWORK')
	button.Icon:SetTexture(db.TEXTURE[binding])
	button.Icon:SetSize(28, 28)
	button.Icon:SetPoint('LEFT', button, 'RIGHT', 4, 0)
	button.point = CreateFrame('EditBox', '$parentPoint', button)
	button.xOffset = CreateFrame('EditBox', '$parentxOffset', button)
	button.yOffset = CreateFrame('EditBox', '$parentyOffset', button)
	button.direction = CreateFrame('EditBox', '$parentDirection', button)
	button.size = CreateFrame('EditBox', '$parentSize', button)
	button.size:SetPoint('LEFT', button.Icon, 'RIGHT', 0, 0)
	button.point:SetPoint('LEFT', button.size, 'RIGHT', -4, 0)
	button.xOffset:SetPoint('LEFT', button.point, 'RIGHT', -4, 0)
	button.yOffset:SetPoint('LEFT', button.xOffset, 'RIGHT', -4, 0)
	button.direction:SetPoint('LEFT', button.yOffset, 'RIGHT', -4, 0)

	db.table.mixin(button.size, Position)
	db.table.mixin(button.point, Position)
	db.table.mixin(button.xOffset, Position)
	db.table.mixin(button.yOffset, Position)
	db.table.mixin(button.direction, Position)

	button.size:OnLoad(1, 'size', 75, nil, nil, nil, button.point)

	button.point:OnLoad(1, 'point', 150, VALID_POINTS, strupper, button.size, button.xOffset)
	button.xOffset:OnLoad(2, 'point', 75, nil, nil, button.point, button.yOffset)
	button.yOffset:OnLoad(3, 'point', 75, nil, nil, button.xOffset, button.direction)

	button.direction:OnLoad(1, 'dir', 100, VALID_DIRS, strlower, button.yOffset)

	button.size:SetNumeric(true)
	button.size.isNumeric = true
	button.xOffset.isNumeric = true
	button.yOffset.isNumeric = true

	db.table.mixin(button, Button)
	button:OnShow()
	return button
end

function Layout:CreateBooleanSwitch(cvar, desc)
	local button = CreateFrame('CheckButton', '$parent'..cvar, self.Child, 'ChatConfigCheckButtonTemplate')
	button.text = button:CreateFontString(nil, 'OVERLAY', 'FocusFontSmall')
	button.text:SetPoint('LEFT', 30, 0)
	button.text:SetText(desc)
	button:SetChecked(ab.cfg and ab.cfg[cvar])
	button.cvar = cvar
	db.table.mixin(button, Bool)
	return button
end

function Preset:SetData(name, cfg, class)
	local viewer = self.Viewer
	self.cfg = db.table.copy(cfg)
	self:SetText((class and '|c'..RAID_CLASS_COLORS[class].colorStr..name) or name)

	if self.cfg then
		for binding, data in pairs(self.cfg.layout) do
			viewer.Pins[binding] = viewer.Pins[binding] or viewer:CreateTexture(nil, 'ARTWORK')
			
			local pin = viewer.Pins[binding]
			pin:SetTexture(db.ICONS[binding])

			local p, xOff, yOff = unpack(data.point)
			local s = data.size or 64

			xOff = xOff * 0.25
			yOff = yOff * 0.25
			s = s * 0.25

			pin:SetPoint(p, xOff, yOff)
			pin:SetSize(s, s)

		end
		viewer:SetWidth((self.cfg.width or 1105) * 0.25)
		if self.cfg.showart then		
			local art, coords = ab:GetCover()
			if art and coords then
				viewer.Art:SetTexture(art)
				viewer.Art:SetTexCoord(unpack(coords))
				viewer.Art:Show()
			else
				viewer.Art:Hide()
			end
		end
		self:Show()
	end
end

function Preset:OnClick()
	Bar:OnLoad(db.table.copy(self.cfg), true)
	self.Layout:Hide()
	self.Layout:Show()
end

function Preset:OnEnter()
	local settings = ab:GetSimpleSettings(self.cfg)
	local ttLine = '|T%s:24:24:0:0|t %s'
	local yes, no = 'Interface\\RAIDFRAME\\ReadyCheck-Ready', 'Interface\\RAIDFRAME\\ReadyCheck-NotReady'
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	GameTooltip:AddLine(self.Label:GetText())
	for _, data in pairs(settings) do
		GameTooltip:AddLine(ttLine:format(data.toggle and yes or no, data.desc))
	end
	GameTooltip:Show()
end

function Preset:OnLeave()
	GameTooltip:Hide()
end

function Profiler:CreatePreset()
	local id = self.numActive
	local preset = db.Atlas.GetFutureButton('$parentPreset'..id, self.Child, nil, nil, 300, 46, true)
	local viewer = CreateFrame('Frame', '$parentViewer', preset)

	viewer:SetClipsChildren(true)
	viewer:SetPoint('TOP', preset, 'BOTTOM', 0, 0)
	viewer:SetSize(250, 84)
	viewer.Pins = {}


	viewer.Line = viewer:CreateTexture(nil, 'BACKGROUND', nil, 3)
	viewer.Line:SetPoint('TOP', 0, 0)
	viewer.Line:SetSize(280, 54)

	viewer.Art = viewer:CreateTexture(nil, 'BACKGROUND', nil, 3)
	viewer.Art:SetPoint('TOP', 0, 0)
	viewer.Art:SetSize(280, 54)
	viewer.Art:SetAlpha(0.5)

	viewer.Line:SetTexture('Interface\\LevelUp\\MinorTalents.blp')
	viewer.Line:SetTexCoord(0, 0.8164, 0.6660, 0.7968)
	viewer.Line:SetAlpha(0.35)

	db.table.mixin(preset, Preset)

	preset.Layout = self.Layout
	preset.Viewer = viewer
	preset:Show()
	self:AddButton(preset, 24, 0)
	self.Buttons[id] = preset
	return preset
end

function Profiler:GetPresetFromPool()
	self.numActive = self.numActive + 1
	return self.Buttons[self.numActive] or self:CreatePreset()
end

function Profiler:AddPreset(name, cfg, class)
	local profile = self:GetPresetFromPool()
	profile:SetData(name, cfg, class)
end

function Profiler:OnShow()
	self.numActive = 0
	for _, profile in pairs(self.Buttons) do
		profile:Hide()
	end
	local default = ab:GetDefaultSettings()
	local current = ab.cfg
	local compare = db.table.compare

	self:AddPreset(REFORGE_CURRENT, current)

	for name, settings in db.table.spairs(ab:GetPresets()) do
		self:AddPreset(name, settings)
	end

	if ConsolePortCharacterSettings then
		for character, settings in db.table.spairs(ConsolePortCharacterSettings) do
			if settings.Bar then
				local setup = settings.Bar
				if not compare(setup, default) and not compare(setup, current) then 
					self:AddPreset(character, setup, settings.Class)
				end
			end
		end
	end
	self:Refresh(self.numActive)
end

function WindowMixin:Default()
	Bar:OnLoad(ab:GetDefaultSettings())
	if self.Layout and self.Layout:IsVisible() then
		self.Layout:Hide()
		self.Layout:Show()
	end
end

function WindowMixin:Save()
	Bar:OnLoad(ab.cfg)
	return nil, 'Bar', ( not db.table.compare(ab.cfg, ab:GetDefaultSettings()) and ab.cfg)
end

function WindowMixin:Cancel()
	if self.Backup then
		Bar:OnLoad(self.Backup)
		self.Backup = nil
	end
end

function WindowMixin:CreateLayoutModule()
	local layout = db.Atlas.GetScrollFrame('$parentLayout', self, {
		childKey = 'List',
		childWidth = 530,
		stepSize = 42,
	})
	layout:SetPoint('TOPLEFT', 32, -32)
	layout:SetSize(530, 600)
	layout.cfg = ab.cfg.layout
	db.table.mixin(layout, Layout)

	local info = ab:GetSimpleSettings()
	for i=1, #info, 2 do
		local frame = CreateFrame('Frame')
		frame:SetSize(530, 42)
		local b1 = layout:CreateBooleanSwitch(info[i].cvar, info[i].desc)
		local b2 = layout:CreateBooleanSwitch(info[i+1].cvar, info[i+1].desc)
		b1:SetPoint('LEFT', frame, 'LEFT', 24, 0)
		b2:SetPoint('CENTER', frame, 'CENTER', 0, 0)
		layout:AddButton(frame)
	end

	-- Color header
	local colors = layout:CreateHeader(
		{val = 'Colors:', x = 0, data = 'Text', type = 'FontString', setup = {nil, 'ARTWORK', 'FocusFontSmall'}},
		{val = 'Border', x = 64, data = 'Text', type = 'FontString', setup = {nil, 'ARTWORK', 'FocusFontSmall'}},
		{val = 'Cooldown', x = 64, data = 'Text', type = 'FontString', setup = {nil, 'ARTWORK', 'FocusFontSmall'}},
		{val = 'Tint', x = 64, data = 'Text', type = 'FontString', setup = {nil, 'ARTWORK', 'FocusFontSmall'}},
		{val = 'Bars', x = 64, data = 'Text', type = 'FontString', setup = {nil, 'ARTWORK', 'FocusFontSmall'}}
	)

	for i, id in pairs({'borderRGB', 'swipeRGB', 'tintRGB', 'expRGB'}) do
		local color = CreateFrame('Button', nil, colors)
		color:SetSize(24, 24)
		color:SetPoint('RIGHT', colors.Objects[i+1], 'LEFT', -8, 0)
		color.Display = color:CreateTexture(nil, 'ARTWORK')
		color.Display:SetAllPoints()
		color:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
		color.id = id
		color.element = id:gsub('RGB', '')
		color.Callback = function(revertRGB)
			if revertRGB then
				ab.cfg[id] = revertRGB
			else
				local r, g, b = ColorPickerFrame:GetColorRGB()
				local a = OpacitySliderFrame:GetValue()
				ab.cfg[id] = {r, g, b, 1 - a}
			end
			color.Display:SetColorTexture(unpack(ab.cfg[id]))
			Bar:OnLoad(ab.cfg, true)
		end,
		db.table.mixin(color, Color)
	end

	-- Button header
	layout:CreateHeader(
		{val = 'Size', x = 78, data = 'Text', type = 'FontString', setup = {nil, 'ARTWORK', 'FocusFontSmall'}},
		{val = 'Anchor', x = 67, data = 'Text', type = 'FontString', setup = {nil, 'ARTWORK', 'FocusFontSmall'}},
		{val = 'X', x = 78, data = 'Text', type = 'FontString', setup = {nil, 'ARTWORK', 'FocusFontSmall'}},
		{val = 'Y', x = 58, data = 'Text', type = 'FontString', setup = {nil, 'ARTWORK', 'FocusFontSmall'}},
		{val = 'Facing', x = 52, data = 'Text', type = 'FontString', setup = {nil, 'ARTWORK', 'FocusFontSmall'}}
	)

	local prev
	for binding in ConsolePort:GetBindings() do
		local button = layout:CreateButton(binding)
		if prev then
			prev.direction.Next = button.size
			button.size.Prev = prev.direction
		end
		prev = button
		layout:AddButton(button, 12, 0)
	end

	local popout = CreateFrame('Button', '$parentPopout', self)
	popout:SetSize(16, 16)
	popout:SetFrameLevel(10)
	popout:SetPoint('TOPLEFT', layout, 'TOPLEFT', -4, 4)
	popout:SetNormalTexture('Interface\\AddOns\\ConsolePort\\Textures\\Window\\Popout')
	popout:SetScript('OnClick', function()
		ConsolePortPopup:SetPopup(BINDING_HEADER_ACTIONBAR, layout, nil, nil, 600, 580)
		ConsolePortConfig:Hide()
		popout:Hide()
	end)
	layout.Popout = popout
	layout.Panel = self
	self.Layout = layout
	self.Layout:OnShow()
	self.CreateLayoutModule = nil
	return layout
end

function WindowMixin:GetLayoutModule()
	return self.Layout or self:CreateLayoutModule()
end

function WindowMixin:CreateProfiler()
	local profiler = db.Atlas.GetScrollFrame('$parentProfiler', self, {
		childKey = 'List',
		childWidth = 330,
		stepSize = 100,
	})
	profiler:SetPoint('TOPRIGHT', -52, -32)
	profiler:SetSize(330, 600)
	profiler.numActive = 0
	-- layout will exist at this point.
	profiler.Layout = self.Layout
	db.table.mixin(profiler, Profiler)
	self.CreateProfiler = nil
	return profiler
end

function WindowMixin:OnShow()
	self.Layout:SetParent(self)
	self.Layout:ClearAllPoints()
	self.Layout:SetPoint('TOPLEFT', 32, -32)
	self.Layout:SetSize(530, 600)
	self.Layout.Backdrop:Show()
	self.Backup = db.table.copy(ab.cfg)
end

ab.configuration = ConsolePortConfig:AddPanel({
	name = 'ActionBarTab',
	header = BINDING_HEADER_ACTIONBAR, 
	mixin = WindowMixin,
	onFirstShow = function(self, core)
		if not self.Layout then
			self:CreateLayoutModule()
		end
		self.Presets = self:CreateProfiler()
	end
})

function Bar:ShowLayoutPopup()
	local layout = ab.configuration:GetLayoutModule()
	layout.Popout:Click()
end