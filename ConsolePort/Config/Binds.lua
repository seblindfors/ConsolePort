---------------------------------------------------------------
-- Binds.lua: Binding manager and functions related to bindings
---------------------------------------------------------------
-- Creates the faux binding manager and all things related
-- to bindings. Also includes hotkey texture management.
-- The system converts one static binding for each button
-- into four combinations (no mod, shift, ctrl, shift+ctrl)
-- which then run override bindings that perish on logout.

local _, db = ...
---------------------------------------------------------------
		-- Resources
local 	TUTORIAL, BIND, TEXTURE, ICONS,
		-- Utils
		FadeIn, FadeOut, Hex2RGB,
		-- Table functions
		Mixin, spairs, compare, copy,
		-- Mixins
		BindingMixin, ButtonMixin, CatcherMixin, 
		HeaderMixin, LayoutMixin, RebindMixin,
		ShortcutMixin, SwapperMixin, WindowMixin,
		-- Reference variables
		window, rebindFrame, newBindingSet = 
		-------------------------------------
		db.TUTORIAL.BIND, "BINDING_NAME_", db.TEXTURE, db.ICONS,
		db.UIFrameFadeIn, db.UIFrameFadeOut, db.Hex2RGB,
		db.table.mixin, db.table.spairs, db.table.compare, db.table.copy,
		{}, {}, {}, {}, {}, {}, {}, {}, {}
---------------------------------------------------------------
local config = {
	-- Custom descriptions for L3/R3
	customDescription = {
		["CP_T_L3"] = TUTORIAL.LEFTCLICK,
		["CP_T_R3"] = TUTORIAL.RIGHTCLICK,
	},
	-- Button templates
	listButton = {
		iconPoint = {"LEFT", "RIGHT", -40, 0},
		textPoint = {"LEFT", "LEFT", 8, 0},
		width = 200,
	},
	configButton = {
		width = 50,
		height = 50,
		iconPoint = {"LEFT", "RIGHT", 190, 0},
		textPoint = {"LEFT", "LEFT", 46, 0},
		buttonPoint = {"CENTER", 0, 0},
		hitRects = {0, -230,  0, 0},
		anchor = {"TOPLEFT", "CENTER", 100, -16},
		useButton = true,
		textWidth = 200,
	},
	-- Controller layout setup
	layOut = {
		LEFT = {
			position = {"TOP", -420, 0},
			iconPoint = {"RIGHT", "LEFT", -4, 0},
			textPoint = {"LEFT", "LEFT", 36, 0},
			buttonPoint = {"CENTER", 0, 0},
			hitRects = {0, -190,  0, 0},
		},
		RIGHT = {
			position = {"TOP", 420, 0},
			iconPoint = {"LEFT", "RIGHT", 4, 0},
			textPoint = {"RIGHT", "RIGHT", -36, 0},
			buttonPoint = {"CENTER", 0, 0},
			hitRects = {-190, 0, 0, 0},
		},
		CENTER = {
			position = {"CENTER", 0, 0},
			iconPoint = {"BOTTOM", "TOP", 0, 4},
			textPoint = {"TOP", "BOTTOM", 0, -8},
			buttonPoint = {"CENTER", 0, 0},
			hitRects = {-90, -90, 0, -40},
		},
	},
	-- Modifier functions
	configButtonModifier = {
		["SHIFT-"] = function(self)
			local icon = self:CreateTexture("$parent_M1", "OVERLAY", nil, 7)
			icon:SetSize(24, 24)
			icon:SetPoint("TOPRIGHT", self, "TOP", 0, 4)
			icon:SetTexture(db.ICONS.CP_M1)
		end,
		["CTRL-"] = function(self)
			local icon = self:CreateTexture("$parent_M2", "OVERLAY", nil, 7)
			icon:SetSize(24, 24)
			icon:SetPoint("TOPRIGHT", self, "TOP", 0, 4)
			icon:SetTexture(db.ICONS.CP_M2)
		end,
		["CTRL-SHIFT-"] = function(self)
			local icon1 = self:CreateTexture("$parent_M1", "OVERLAY", nil, 7)
			local icon2 = self:CreateTexture("$parent_M2", "OVERLAY", nil, 7)
			icon1:SetSize(24, 24)
			icon1:SetPoint("TOPRIGHT", self, "TOP", 0, 4)
			icon1:SetTexture(db.ICONS.CP_M1)		
			icon2:SetSize(24, 24)
			icon2:SetPoint("LEFT", icon1, "CENTER")
			icon2:SetTexture(db.ICONS.CP_M2)
		end,
	},
	-- Override mouse bindings
	mouseBindings = {
		["CP_T_L3"] = "BUTTON1",
		["CP_T_R3"] = "BUTTON2",
	},
	mouseDefault = {
		["BUTTON1"] = "CAMERAORSELECTORMOVE",
		["BUTTON2"] = "TURNORACTION",
	},
	-- Display button texture setup
	displayButton = {
		LeftNormal = 	{1, {0.1064, 0.2080, 0.3886, 0.4462}, 	{83.2, 47.2}, {"LEFT", 0, 0}},
		RightNormal = 	{2, {0.2080, 0.1064, 0.3886, 0.4462},	{83.2, 47.2}, {"RIGHT", 0, 0}},
		LeftEnabled = 	{1, {0.0009, 0.0937, 0.3896, 0.4365},	{76, 38.4},	 {"LEFT", 3.2, 3.2}},
		RightEnabled = 	{2, {0.0937, 0.0009, 0.3896, 0.4365},	{76, 38.4},  {"RIGHT", -3.2, 3.2}},
		Controller = 	{3, {0, 0.0498, 0.4423, 0.4707},		{40.8, 23.2}},
		Grid = 			{3, {0.0517, 0.0761, 0.4453, 0.4628}, 	{20, 14.4}},
	},
	headerColors = {
		[BINDING_HEADER_ACTIONBAR] 		= 'ffffff';
		[BINDING_HEADER_MULTIACTIONBAR] = 'ffffff';
		[BINDING_HEADER_MOVEMENT] 		= '00ffbb';
		[BINDING_HEADER_TARGETING]		= '21ff00';
		[BINDING_HEADER_RAID_TARGET]	= '21ff00';
		[BINDING_HEADER_INTERFACE]		= 'ffcc00';
		[BINDING_HEADER_CHAT]			= 'aaaaaa';
		[BINDING_HEADER_MISC]			= 'aaaaaa';
		[BINDING_HEADER_CAMERA] 		= 'aaaaaa';
		[BINDING_HEADER_VEHICLE] 		= 'aaaaaa';
	},
}
---------------------------------------------------------------

---------------------------------------------------------------
-- Binds: Get new binding sets
---------------------------------------------------------------
local function GetNewBindingSet(default)
	if default then
		newBindingSet = ConsolePort:GetDefaultBindingSet()
	elseif not newBindingSet then
		newBindingSet = copy(db.Bindings) or ConsolePort:GetDefaultBindingSet()
	end
	return newBindingSet
end

---------------------------------------------------------------
-- BindingMixin: Meta button which displays its binding owner 
---------------------------------------------------------------
function BindingMixin:CreateButton(name, parent, isScrollButton, config)
	local button = db.Atlas.GetBindingMetaButton(name, parent, config)
	db.Atlas.SetFutureButtonStyle(button)
	button.Label:SetJustifyH("LEFT")
	button.hotKey = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.hotKey:SetPoint("TOPRIGHT", 4, 4)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	if isScrollButton then
		parent:AddButton(button)
	end

	-- add these format strings to draw icons on binding buttons.
	-- need to be populated post load because they're using saved variables
	if not BindingMixin[""] then
		BindingMixin[""] = "|T%s:24:24:0:0|t"
		BindingMixin["SHIFT-"] = "|T" .. ICONS.CP_M1 .. ":24:24:11:0|t|T%s:24:24:0:0|t"
		BindingMixin["CTRL-"] = "|T" .. ICONS.CP_M2 .. ":24:24:11:0|t|T%s:24:24:0:0|t"
		BindingMixin["CTRL-SHIFT-"] = "|T" .. ICONS.CP_M1 .. ":24:24:22:0|t" .. BindingMixin["CTRL-"]
	end

	Mixin(button, BindingMixin)
	button.CreateButton = nil

	return button
end

function BindingMixin:SetBinding(binding)
	self.binding = binding
	self:OnShow()
end

function BindingMixin:OnShow()
	local binding = self.binding
	local notHeader = binding and not binding:match("^HEADER")
	local key, mod, owner

	self.hotKey:SetText()
	self.ignoreNode = not notHeader
	self:SetEnabled(notHeader and true or false)
	self.Cover:SetShown(notHeader and true or false)
	self.Label:SetTextColor(1, notHeader and 1 or 0.82, notHeader and 1 or 0, 1)

	self:Refresh()

	if notHeader then
		key, mod = ConsolePort:GetCurrentBindingOwner(binding, newBindingSet)
		if key and mod then
			local texture = self[mod] and format(self[mod], ICONS[key])
			self.hotKey:SetText(texture)
			owner = _G[key..mod.."_CONF"]
		end
		self.Cover:Show()
	elseif binding then
		self:SetText(_G["BINDING_"..binding])
	elseif self.name then
		self:SetText(self.name)
	end
	self.key = key
	self.mod = mod
	self.owner = owner
end

function BindingMixin:OnClick(button)
	local swapper = rebindFrame.Swapper
	if button == "RightButton" and self.owner then
		self.owner:SetBinding()
		self.owner.SelectedTexture:Hide()
		swapper:SetBinding()
		window:Reload()
		return
	end
	if not swapper:HasOwner() and self.owner then
		swapper:SetOwner(self.owner)
	elseif swapper:HasOwner() then
		swapper:SwapToBinding(self.binding, self.owner)
	end
end

---------------------------------------------------------------
-- SwapperMixin: swaps bindings - inherits BindingMixin
---------------------------------------------------------------
function SwapperMixin:CreateButton(name, parent, config)
	config.omitHeader = nil

	local button = BindingMixin:CreateButton(name, parent, false, config)
	Mixin(button, SwapperMixin)
	button:SetScript("OnClick", SwapperMixin.OnClick)
	return button
end

function SwapperMixin:SetOwner(owner)
	self.owner = owner
	if owner.binding then
		self:SetBinding(owner.binding)
	else
		self.Cover:Show()
		self.Icon:SetTexture()
		self.Mask:Hide()
		self:SetText(owner:GetText())
		self.hotKey:SetFormattedText(BindingMixin[owner.modifier], ICONS[owner.name])
	end
	self:SetEnabled(true)
end

function SwapperMixin:HasOwner() return self.owner and true or false end

function SwapperMixin:SwapToBinding(binding, oldOwner)
	if self.owner then
		if oldOwner then
			local oldBinding = self.owner:GetBinding()
			oldOwner:SetBinding(oldBinding)
		end
		self.owner:SetBinding(binding)
		self.owner.SelectedTexture:Hide()
		self:SetBinding()
		window:Reload()
	end
end

function SwapperMixin:OnClick(button)
	if button == "LeftButton" then
		if self.owner then
			FadeOut(self.owner.Line, 5, 1, 0.35)
			ConsolePort:ScrollToNode(self.owner, rebindFrame, true)
		end
	else
		if self.owner then
			self.owner.SelectedTexture:Hide()
		end
		self:SetBinding()
	end
end

---------------------------------------------------------------
-- HeaderMixin: 
---------------------------------------------------------------
function HeaderMixin:SetValues()
	local bindings = self.Bindings
	local buttons = self.ValueList.Buttons
	local config = config.listButton
	config.omitHeader = true
	for i, binding in ipairs(bindings) do
		local button = buttons[i] or BindingMixin:CreateButton("$parentButton"..i, self.ValueList, true, config)
		button:SetBinding(binding.binding)
		button.name = binding.name
		button:OnShow()
	end
	self.ValueList:Refresh(#bindings)
end

function HeaderMixin:OnClick()
	local selected = self:GetParent().selected
	if  self ~= selected then
		if selected then
			selected.SelectedTexture:Hide()
		end
		self:GetParent().selected = self
		self.SelectedTexture:Show()
 	end
	self:SetValues()
end

local function RefreshHeaderList(self)
	local buttons = self.Buttons
	local bindings = db.Atlas.BindingMeta:RefreshBindings()
	local hCount = 0
	local colors = config.headerColors
	local config = config.listButton
	config.omitHeader = false
	for category, bindings in spairs(bindings) do
		hCount = hCount + 1
		local button = buttons[hCount]
		if not button then
			button = db.Atlas.GetBindingMetaButton("$parentButton"..#buttons, self, config)
			db.Atlas.SetFutureButtonStyle(button)
			button.Label:SetJustifyH("LEFT")

			Mixin(button, HeaderMixin)
			self:AddButton(button)
		end
		if colors[category] then
			button.Label:SetTextColor(Hex2RGB(colors[category], true))
		else
			button.Label:SetTextColor(1, .82, 0)
		end
		button:SetText(category)
		button:Show()
		button.Bindings = bindings
		button.ValueList = self.Values
	end
	self:Refresh(hCount)
end

---------------------------------------------------------------
-- Binds: Config button for each combination
---------------------------------------------------------------
function ButtonMixin:SetBinding(binding) -- omit binding to clear
	local set = GetNewBindingSet()
	local subSet = set[self.name]
	if not subSet then
		set[self.name] = {}
		subSet = set[self.name]
	end
	subSet[self.modifier] = binding
	FadeOut(self.Line, 5, 1, 0.35)
	self.SelectedTexture:Hide()
	self:OnShow()
end

function ButtonMixin:GetBinding()
	local set = newBindingSet or db.Bindings
	local subSet = set and set[self.name]
	return subSet and subSet[self.modifier]
end

function ButtonMixin:OnShow()
	self.binding = self:GetBinding()
	self:Refresh()
end

function ButtonMixin:OnEnter() FadeIn(self.Line, 0.1, self.Line:GetAlpha(), 1) end
function ButtonMixin:OnLeave() FadeOut(self.Line, 0.1, self.Line:GetAlpha(), 0.35) end
function ButtonMixin:OnHide() self.Line:SetAlpha(0.35) end

function ButtonMixin:OnClick(mouseButton)
	local tutorial = window.Tutorial
	local swapper, swapOwner = rebindFrame.Swapper, rebindFrame.Swapper.owner
	if not self.reserved then
		if mouseButton == "RightButton" then
			self:SetBinding()
			self.SelectedTexture:Hide()
			swapper:SetBinding()
		else
			if swapOwner == self then
				self.SelectedTexture:Hide()
				swapper:SetBinding()
			else
				if swapOwner then
					swapOwner.SelectedTexture:Hide()
				end
				swapper:SetOwner(self)
				self.SelectedTexture:Show()
			end
		end
		window:Reload()
	end
end

function ShortcutMixin:OnEnter()
	FadeIn(self, 0.2, self:GetAlpha(), 1)
	if ConsolePort:IsCurrentNode(self) then
		ConsolePort:ScrollToNode(self.Button, rebindFrame, true)
	end
	for _, button in pairs(window.Buttons[self.name]) do
		button:OnEnter()
	end
end

function ShortcutMixin:OnLeave()
	FadeOut(self, 0.2, self:GetAlpha(), 0.35)
	for _, button in pairs(window.Buttons[self.name]) do
		button:OnLeave()
	end
end

function ShortcutMixin:OnClick()
	ConsolePort:ScrollToNode(self.Button, rebindFrame, true)
end

---------------------------------------------------------------
-- Binds: Create and handle addon bindings
---------------------------------------------------------------
local function SetTempBinding(self, modifier, original, override)
	if original and override then
		local key1, key2 = GetBindingKey(original) or config.mouseBindings[original]
		if key1 then SetOverrideBinding(self, false, modifier..key1, override) end
		if key2 then SetOverrideBinding(self, false, modifier..key2, override) end
	end
end

local function SetMouseBindings(self, handler, bindingSet)
	for stick, button in pairs(config.mouseBindings) do
		if bindingSet[stick] and bindingSet[stick][""] then
			for modifier in ConsolePort:GetModifiers() do
				if modifier ~= "" then
					SetOverrideBinding(handler, false, modifier..button, config.mouseDefault[button])
				end
			end
		end
	end
end

function ConsolePort:LoadBindingSet(newBindingSet, fireCallback)
	local calibration = db('calibration')
	if calibration then
		for binding, key in pairs(calibration) do
			SetBinding(key, binding)
		end
	end
	local bindingSet = newBindingSet or db.Bindings or {}
	local handler = ConsolePortButtonHandler
	ClearOverrideBindings(handler)
	if not db('disableStickMouse') then
		SetMouseBindings(self, handler, bindingSet)
	end
	for name, key in pairs(bindingSet) do
		local baseBinding = (not name:match('CP_T_.3')) and key['']
		for modifier in self:GetModifiers() do
			local modBinding = key[modifier]
			SetTempBinding(handler, modifier, name, modBinding or baseBinding)
		end
	end
	if fireCallback then
		self:OnNewBindings(bindingSet)
	end
	self:RemoveUpdateSnippet(self.LoadBindingSet)
	return bindingSet
end

function ConsolePort:OnNewBindings(bindings) return db.Bindings end

function ConsolePort:LoadInterfaceBinding(button, UIbutton)
	local action = _G[UIbutton]
	if action then
		button.action = action
		button:Reset()
		button:Revert()
		if button.action.HotKey then
			button.action.HotKey:SetAlpha(0)
		end
		button:ShowInterfaceHotkey()
	else
		self:AddWidgetTracker(button, UIbutton)
	end
end

---------------------------------------------------------------
-- Binds: Import profile functions 
---------------------------------------------------------------
local function ProfileOnSelect(self)
	local buttons = self:GetParent().Buttons
	local isSelected = self.SelectedTexture:IsShown()
	for _, button in ipairs(buttons) do
		button.SelectedTexture:Hide()
	end
	self.SelectedTexture:SetShown(not isSelected)
	self.Popup:SetSelection(not isSelected and self.name)
end

local function RefreshProfileList(self)
	local buttons = self.Buttons
	local popup = ConsolePortPopup
	local maxHeight = popup.Container:GetHeight()
	local pCount = 0

	if not ConsolePortCharacterSettings then
		ConsolePortCharacterSettings = {}
	end

	local profiles = copy(ConsolePortCharacterSettings)
	self.ProfileData = profiles
	-- add shared data profiles
	for character, settings in spairs(profiles) do
		if not settings.BindingSet then
			profiles[character] = nil
		end
	end
	-- add controller template presets
	for controller, data in pairs(db.Controllers) do
		profiles["|cFFFFFFFF"..controller.."|r"..TUTORIAL.PROFILEPRESET] = {
			Type = controller,
			BindingSet = data.Bindings,
			Preset = true,
		}
	end
	-- add empty preset
	profiles["|cFFFFFFFF"..EMPTY.."|r"..TUTORIAL.PROFILEPRESET] = {
		BindingSet = {},
		Preset = true,
	}

	for character, settings in spairs(profiles) do
		pCount = pCount + 1
		local button = buttons[pCount]
		if not button then
			button = db.Atlas.GetFutureButton("$parentButton"..pCount, self, nil, nil, 350)
			button.Label:SetJustifyH('LEFT')
			button.Label:ClearAllPoints()
			button.Label:SetPoint('LEFT', 24, 0)
			button.Label:SetTextColor(1, 1, 1)
			button.Label:SetWidth(260)
			button:SetScript("OnClick", ProfileOnSelect)
			self:AddButton(button, 56)
		end
		button:SetText(character:gsub('%(', '|cFFFFD200('):gsub('%) ', ')|r\n|cFF757575'))
		button.SelectedTexture:Hide()
		button:Show()
		button.preset = settings.Preset
		if settings.Class then
			local cc = RAID_CLASS_COLORS[settings.Class]
			button.Label:SetVertexColor(cc.r, cc.g, cc.b, 1)
		elseif settings.Preset then
			button.Label:SetVertexColor(1, 0.8, 0, 1)
		else
			button.Label:SetVertexColor(1, 1, 1, 1)
		end
		button.Cover:SetVertexColor(1, 1, 1, settings.Preset and 0.25 or 1)
		if settings.Type and db.Controllers[settings.Type] then
			button.Controller = button.Controller or button:CreateTexture(nil, "OVERLAY")
			button.Controller:SetSize(32, 32)
			button.Controller:SetPoint("RIGHT", button, "LEFT", -8, 0)
			button.Controller:SetTexture("Interface\\AddOns\\ConsolePort\\Controllers\\"..settings.Type.."\\Icons64\\CP_X_CENTER")
		elseif button.Controller then
			button.Controller:SetTexture()
		end
		if settings.Spec then
			button.Icon:SetTexture(CPAPI:GetSpecTextureByID(settings.Spec))
			button.Icon:ClearAllPoints()
			button.Icon:SetSize(32, 32)
			button.Icon:SetPoint('RIGHT', -8, 0)
			button.Icon:SetAlpha(1)
			button.Icon:SetDrawLayer('OVERLAY')
			button.Icon:SetMask("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Mask")
		else
			button.Icon:SetAlpha(0)
		end
		button.Popup = popup
		button.name = character
		FadeIn(button, pCount*0.1, 0, 1)
	end
	self:Refresh(pCount)
	popup:SetSelection(nil)
end

local function ImportOnClick(self)
	local character = ConsolePortPopup:GetSelection()
	local settings = window.Import.Profiles.ProfileData[character]
	if settings then
		newBindingSet = copy(settings.BindingSet)
		window.Tutorial:SetFormattedText(TUTORIAL.IMPORT, character)
		window:Reload()
	end
end

local function RemoveOnClick(self)
	local selected = ConsolePortPopup:GetSelection()
	if ConsolePortCharacterSettings and selected then
		ConsolePortCharacterSettings[selected] = nil
	end
	RefreshProfileList(window.Import.Profiles)
end

---------------------------------------------------------------
-- LayoutMixin: Layout buttons and tooltip
---------------------------------------------------------------
function LayoutMixin:OnClick()
	ConsolePortOldConfig.Tooltip:Hide()
	ConsolePortCursor:Hide()
	window.BindCatcher:SetAlpha(0)
	window.Tutorial:SetAlpha(0)
	window:OnShow(2)
	C_Timer.After(0.1, function()
		ConsolePort:ScrollToNode(window.Buttons[self.name][1], rebindFrame)
	end)
end

function LayoutMixin:OnEnter()
	local tooltip = ConsolePortOldConfig.Tooltip
	tooltip:Hide()
	if self.anchor == "CENTER" then
		tooltip:SetOwner(self, "ANCHOR_BOTTOM")
	else
		tooltip:SetOwner(self, "ANCHOR_BOTTOM"..self.anchor, 0, 46)
	end
	tooltip:AddLine(TUTORIAL.TOOLTIPHEADER)
	if not self.bindings then
		self.bindings = {
			{mod = "", icons = self.texture},
			{mod = "SHIFT-", icons = format(self.icon, db.TEXTURE.CP_M1)..self.texture},
			{mod = "CTRL-", icons = format(self.icon, db.TEXTURE.CP_M2)..self.texture},
			{mod = "CTRL-SHIFT-", icons = format(self.icon, db.TEXTURE.CP_M1)..format(self.icon, db.TEXTURE.CP_M2)..self.texture},
		}
	end
	for _, binding in pairs(self.bindings) do
		local modifier = binding.mod
		if newBindingSet then
			self.binding = newBindingSet[self.name] and newBindingSet[self.name][modifier]
		else
			self.binding = db.Bindings[self.name] and db.Bindings[self.name][modifier]
		end
		local text, icon = self:GetBindingInfo()
		local _, newLines = gsub(text or "", "\n", "")
		newLines = strrep("\n", 2 - newLines)
		local tooltipText = (icon and text) and format(self.icon, icon).." "..text or text and text..newLines or icon and format(self.icon, icon)
		tooltip:AddDoubleLine(tooltipText, binding.icons, 1,1,1,1,1,1)
	end
	tooltip:AddLine(TUTORIAL.TOOLTIPCLICK)
	tooltip:Show()
end

function LayoutMixin:OnHide()
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")
	self:SetScript("OnEvent", nil)
end

function LayoutMixin:OnLeave()
	local tooltip = ConsolePortOldConfig.Tooltip
	if tooltip:GetOwner() == self then
		tooltip:Hide()
	end
end

function LayoutMixin:OnShow()
	self:RegisterEvent("MODIFIER_STATE_CHANGED")
	self:SetScript("OnEvent", self.OnShow)
	local modifier = ConsolePort:GetCurrentModifier()
	if newBindingSet then
		self.binding = newBindingSet[self.name] and newBindingSet[self.name][modifier]
	else
		self.binding = db.Bindings[self.name] and db.Bindings[self.name][modifier]
	end
	self:Refresh()
end

---------------------------------------------------------------
-- Binds: Bind catcher
---------------------------------------------------------------
function CatcherMixin:Catch(key)
	local button = key and GetBindingAction(key) and _G[GetBindingAction(key).."_BINDING"]
	FadeIn(ConsolePortCursor, 0.2, ConsolePortCursor:GetAlpha(), 1)
	ConsolePortOldConfig:ToggleShortcuts(true)
	self:SetScript("OnKeyUp", nil)
	self:EnableKeyboard(false)
	if button then
		button:OnEnter()
		button:OnLeave()
		button:OnClick()
	elseif not rebindFrame:IsVisible() and key then
		window.Tutorial:SetText(TUTORIAL.DEFAULT)
	end
end

function CatcherMixin:OnClick()
	self:EnableKeyboard(true)
	self:SetScript("OnKeyUp", self.Catch)
	FadeOut(ConsolePortCursor, 0.2, ConsolePortCursor:GetAlpha(), 0)
	ConsolePortOldConfig:ToggleShortcuts(false)
	window.Tutorial:SetText(TUTORIAL.CATCHER)
end

function CatcherMixin:OnHide()
	self:Catch()
end

function CatcherMixin:OnShow()
	FadeIn(self, 0.2, self:GetAlpha(), 1)
end

---------------------------------------------------------------
-- RebindMixin: rebind frame setup
---------------------------------------------------------------
function RebindMixin:OnShow()
	for button in ConsolePort:GetActionButtons() do
		if not button:IsVisible() then
			button.forceShow = true
			button:Show()
		end
	end
end

function RebindMixin:OnMouseWheel()
	if not db('disableUI') and not ConsolePort:IsCurrentNode(window.Display) then
		ConsolePort:SetCurrentNode(window.Display)
	end
end

function RebindMixin:OnHide()
	ConsolePort:ClearCurrentNode()
	if GetCVar("alwaysShowActionBars") == "0" then
		for button, action in ConsolePort:GetActionButtons() do
			if not GetActionInfo(action) and button.forceShow then
				button.forceShow = nil
				button:Hide()
			end
		end
	end
end

---------------------------------------------------------------
-- WindowMixin: window wide functions
---------------------------------------------------------------
function WindowMixin:Reload(newBindings)
	ConsolePort:LoadBindingSet(newBindings)
	ConsolePort:LoadHotKeyTextures(newBindings)

	for _, button in pairs(self.Overlay.Buttons) do
		button:OnShow()
	end
	for _, buttonSet in pairs(self.Buttons) do
		for _, button in pairs(buttonSet) do
			button:OnShow()
		end
	end
	for _, button in pairs(self.Rebind.Values.Buttons) do
		if button:IsVisible() then
			button:OnShow()
		end
	end
end

function WindowMixin:Default()
	self.Tutorial:SetText(TUTORIAL.RESET)
	self:Reload(GetNewBindingSet(true))
end

function WindowMixin:Save()
	if 	newBindingSet then
		db.Bindings = newBindingSet

		newBindingSet = nil

		ConsolePortBindingSet = ConsolePortBindingSet or {}
		ConsolePortBindingSet[CPAPI:GetSpecialization()] = db.Bindings
		self:Reload()
	end
	-- callback for retrieving new bindings
	ConsolePort:OnNewBindings(db.Bindings)

	return nil, "BindingSet", ( not compare(db.Bindings, ConsolePort:GetDefaultBindingSet()) and db.Bindings )
end

function WindowMixin:Cancel()
	if 	newBindingSet then
		newBindingSet = nil
		ConsolePort:LoadHotKeyTextures()
		self:Reload()
	end
end

function WindowMixin:OnShow(override)
	local view = override or self.Display:GetID()
	self.Display:SetID(view)
	self.Display:OnShow()
	if view == 1 then
		self.Rebind:Hide()
		self.Rebind.Swapper:Hide()
		self.Rebind.ValueScroll:Hide()
		self.Rebind.HeaderScroll:Hide()
		self.Rebind.ShortcutScroll:Hide()
		self.Controller:Show()
		if not db('disableUI') then
			ConsolePort:SetCurrentNode(self.BindCatcher)
		end
		FadeIn(self.Overlay, 1, 0, 1)
		self.Tutorial:ClearAllPoints()
		self.Tutorial:SetJustifyH("CENTER")
		self.Tutorial:SetPoint("TOP", 0, -116)
		self.Tutorial:SetTextColor(1, 0.82, 0)
		self.Tutorial:SetText(TUTORIAL.DEFAULT)
	else
		self.Controller:Hide()
		self.Rebind:Show()
		self.Rebind.Swapper:Show()
		self.Rebind.ValueScroll:Show()
		self.Rebind.HeaderScroll:Show()
		self.Rebind.ShortcutScroll:Show()
		self.Tutorial:ClearAllPoints()
		self.Tutorial:SetPoint("BOTTOMLEFT", 32, 20)
		self.Tutorial:SetJustifyH("LEFT")
		self.Tutorial:SetTextColor(0.75, 0.75, 0.75)
		self.Tutorial:SetFormattedText(TUTORIAL.COMBO, ICONS[db.Mouse.Cursor.Left], ICONS[db.Mouse.Cursor.Right])
	end
end

---------------------------------------------------------------
db.PANELS[#db.PANELS + 1] = {name = "Binds", header = TUTORIAL.HEADER, mixin = WindowMixin, onLoad = function(self, core)
	local settings = db.Settings
	local player = GetUnitName("player").."-"..GetRealmName()
	local cc = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

	self.Controller = CreateFrame("Frame", "$parentController", self)
	self.Controller:SetPoint("CENTER", 0, 0)
	self.Controller:SetSize(450, 450)

	self.Controller.Texture = self.Controller:CreateTexture("$parentTexture", "ARTWORK")
	self.Controller.Texture:SetTexture("Interface\\AddOns\\ConsolePort\\Controllers\\"..settings.type.."\\Front")
	self.Controller.Texture:SetAllPoints(self.Controller)

	self.Overlay = CreateFrame("Frame", "$parentOverlay", self.Controller)
	self.Overlay:SetPoint("CENTER", 0, 0)
	self.Overlay:SetSize(1024, 512)
	self.Overlay.Lines = self.Overlay:CreateTexture("$parentLines", "OVERLAY", nil, 7)
	self.Overlay.Lines:SetTexture("Interface\\AddOns\\ConsolePort\\Controllers\\"..settings.type.."\\Overlay")
	self.Overlay.Lines:SetAllPoints(self.Overlay)
	self.Overlay.Lines:SetVertexColor(cc.r * 1.25, cc.g * 1.25, cc.b * 1.25, 0.75)

	self.Overlay.Buttons = {}

	self.Tutorial = self:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	self.Tutorial.SetNewText = self.Tutorial.SetText

	function self.Tutorial:SetText(...)
		self:SetNewText(...)
		FadeIn(self, 1, 0, 1)
	end

---------------------------------------------------------------

	self.BindCatcher = db.Atlas.GetFutureButton("$parentBindCatcher", self.Controller, nil, nil, 350)
	self.BindCatcher.HighlightTexture:ClearAllPoints()
	self.BindCatcher.HighlightTexture:SetPoint("TOP", self.BindCatcher, "TOP")
	self.BindCatcher:SetHeight(64)
	self.BindCatcher:SetPoint("TOP", 0, 0)
	self.BindCatcher.Cover:Hide()
	self.BindCatcher.hasPriority = true

	Mixin(self.BindCatcher, CatcherMixin)

---------------------------------------------------------------

	self.Import = db.Atlas.GetFutureButton("$parentImport", self)
	self.Import.Popup = ConsolePortPopup
	self.Import:SetPoint("LEFT", ConsolePortOldConfigDefault, "RIGHT", 0, 0)
	self.Import:SetText(TUTORIAL.IMPORTBUTTON)
	self.Import:SetScript("OnClick", function(self)
		self.Popup:SetPopup(self:GetText(), self.ProfileScroll, self.Import, self.Remove, 600, 500)
	end)

	self.Import.Import = CreateFrame("Button", self.Import)
	self.Import.Import:SetText(TUTORIAL.IMPORTBUTTON)
	self.Import.Import:SetScript("OnClick", ImportOnClick)

	self.Import.Remove = CreateFrame("Button", self.Import)
	self.Import.Remove:SetText(TUTORIAL.REMOVEBUTTON)
	self.Import.Remove:SetScript("OnClick", RemoveOnClick)
	self.Import.Remove.dontHide = true

	self.Import.ProfileScroll = db.Atlas.GetScrollFrame("$parentProfileScrollFrame", self.Import, {
		childKey = "Profiles",
		childWidth = 350,
		stepSize = 50,
		noBackdrop = true,
	})

	-- offset the scrollbar as to not clip the edge of the popup frame
	self.Import.ProfileScroll.ScrollBar:ClearAllPoints()
	self.Import.ProfileScroll.ScrollBar:SetPoint("TOPLEFT", self.Import.ProfileScroll, "TOPRIGHT", -28, 0)
	self.Import.ProfileScroll.ScrollBar:SetPoint("BOTTOMLEFT", self.Import.ProfileScroll, "BOTTOMRIGHT", -28, 0)

	self.Import.Profiles = self.Import.ProfileScroll.Child
	self.Import.Profiles:SetScript("OnShow", RefreshProfileList)
	self.Import.ProfileScroll:Hide()

	---------------------------------------------------------------
	
	-- Modify the frame when the advanced tool is loaded to allow import/export of serialized data.
	if IsAddOnLoaded('ConsolePortAdvanced') then
		self.Import:SetText(TUTORIAL.IMPORTEXPORT)
		local scrollFrame = self.Import.ProfileScroll
		
		-- Import button:
		local Import = CreateFrame('Button', nil, scrollFrame)
		Import:SetPoint('TOP', scrollFrame, 'BOTTOM', -16, -8)
		Import:SetNormalTexture('Interface\\AddOns\\ConsolePort\\Textures\\Window\\Popin')
		Import:SetSize(20, 20)

		Import:SetScript('OnClick', function(self)
			core:Import(function(data)
				local importedSet = data and data['Binding set']
				if importedSet then
					ConsolePortPopup:Hide()
					newBindingSet = importedSet
					window.Tutorial:SetText(TUTORIAL.IMPORTADVEXT)
					window:Reload(importedSet)
				else
					print( "|T" .. ( db.TEXTURE.CP_X_CENTER or "" ) .. ":24:24:0:0|t |cffffe00aConsolePort|r:")
					print(TUTORIAL.IMPORTINVALID)
				end
			end)
		end)

		Import:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_TOP')
			GameTooltip:SetText(TUTORIAL.IMPORTADV)
			GameTooltip:Show()
		end)

		Import:SetScript('OnLeave', function(self)
			GameTooltip:Hide()
		end)
		
		-- Export button:
		local Export = CreateFrame('Button', nil, scrollFrame)
		Export:SetPoint('TOP', scrollFrame, 'BOTTOM', 16, -8)
		Export:SetNormalTexture('Interface\\AddOns\\ConsolePort\\Textures\\Window\\Popout')
		Export:SetSize(20, 20)

		Export:SetScript('OnClick', function(self)
			local set 
			local character = ConsolePortPopup:GetSelection()
			local settings = window.Import.Profiles.ProfileData[character]
			if settings then
				set = copy(settings.BindingSet)
			else
				set = db.Bindings
			end
			if set then
				core:Export({['Binding set'] = set})
			end
		end)

		Export:SetScript('OnEnter', function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_TOP')
			local character = ConsolePortPopup:GetSelection()
			if character then
				GameTooltip:SetText(TUTORIAL.EXPORTADV:format(character))
			else
				GameTooltip:SetText(TUTORIAL.EXPORTADVCURRENT)
			end
			GameTooltip:Show()
		end)
		
		Export:SetScript('OnLeave', function(self)
			GameTooltip:Hide()
		end)
	end

---------------------------------------------------------------

	self.Display = CreateFrame("CheckButton", "$parentDisplayButton", self)
	self.Display:SetID(settings.bindView or 1)

	for name, config in pairs(config.displayButton) do
		local texture = self.Display:CreateTexture(nil, "ARTWORK", nil, config[1])
		self.Display[name] = texture

		texture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
		texture:SetTexCoord(unpack(config[2]))
		texture:SetSize(unpack(config[3]))

		local point = config[4]
		if point then
			texture:SetPoint(unpack(point))
		end
	end

	config.displayButton = nil

	function self.Display:OnShow()
		local view = self:GetID()
		self.LeftEnabled:SetShown(view == 2)
		self.RightEnabled:SetShown(view == 1)
	end

	function self.Display:OnClick()
		local view = self:GetID() == 1 and 2 or 1
		settings.bindView = view
		self:SetID(view)
		self:GetParent():OnShow()
	end

	Mixin(self.Display, self.Display)

	self.Display:SetPoint("BOTTOM", 0, 20)
	self.Display:SetSize(161.6, 47.2)

	self.Display.LeftEnabled:SetAlpha(0.25)
	self.Display.LeftEnabled:SetBlendMode("ADD")

	self.Display.RightEnabled:SetAlpha(0.25)
	self.Display.RightEnabled:SetBlendMode("ADD")

	self.Display.Controller:SetPoint("CENTER", self.Display.LeftNormal, "CENTER", 1.2, 3.2)
	self.Display.Grid:SetPoint("CENTER", self.Display.RightNormal, "CENTER", -1.2, 3.2)

---------------------------------------------------------------

	self.Buttons = {}

	local customDescription = config.customDescription
	customDescription[settings.CP_M2] = TUTORIAL.CTRL
	customDescription[settings.CP_M1] = TUTORIAL.SHIFT

	local triggers = {
		[settings.CP_T1 or 'CP_TR1'] 	= 'CP_T1',
		[settings.CP_T2 or 'CP_TR2'] 	= 'CP_T2',
		[settings.CP_T3 or 'CP_L_GRIP'] = 'CP_T3',
		[settings.CP_T4 or 'CP_R_GRIP'] = 'CP_T4',
	}

	local iconPath = "Interface\\AddOns\\ConsolePort\\Controllers\\"..settings.type.."\\Icons64\\"
	local sharedPath = "Interface\\AddOns\\ConsolePort\\Controllers\\Shared\\Icons64\\"
	local shared = db.Controller and db.Controller.Shared
	if db.Layout then
		local layout = config.layOut
		if settings.skipGuideBtn then
			db.Layout.CP_X_CENTER = nil
		end
		for buttonName, info in pairs(db.Layout) do
			local texture = ( shared and shared[buttonName] and sharedPath..buttonName ) or ( iconPath..buttonName )
			local settings = layout[info.anchor]
			local 	position, iconPoint, textPoint, buttonPoint, hitRects = 
					settings.position, settings.iconPoint, settings.textPoint, settings.buttonPoint, settings.hitRects

			position[3] = (info.index - 1) * -48 - 80

			local custom = customDescription[buttonName]
			local name = triggers[buttonName] or buttonName

			local button = db.Atlas.GetBindingMetaButton(name.."_BINDING", self.Overlay, {
				width = 30,
				height = 30,
				justifyH = info.anchor,
				textWidth = 200,
				iconPoint = iconPoint,
				textPoint = textPoint,
				buttonPoint = buttonPoint,
				buttonTexture = texture,
				useButton = true,
				hitRects = hitRects,
				default = custom,
			})

			button.anchor = info.anchor
			button.icon = "|T%s:32:32:0:0|t"
			button.texture = format(button.icon, texture)
			button:SetPoint(unpack(position))

			if not custom or config.mouseBindings[buttonName] then
				button.name = triggers[buttonName] or buttonName
				Mixin(button, LayoutMixin)
				self.Overlay.Buttons[#self.Overlay.Buttons + 1] = button
			end
		end
		config.layOut = nil
	else
		-- If the controller has no layout settings, use grid.
		settings.bindView = 2
		self.Display:SetID(2)
		self.Display:SetButtonState("DISABLED")
	end

---------------------------------------------------------------

	self.Rebind = db.Atlas.GetScrollFrame("ConsolePortRebindFrame", self, {
		childKey = "List",
		childWidth = 250,
		stepSize = 50,
	})

	rebindFrame = self.Rebind

	rebindFrame:SetPoint("TOPLEFT", 86, -32)
	rebindFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOM", -116, 84)

	Mixin(rebindFrame, RebindMixin)

	rebindFrame.HeaderScroll = db.Atlas.GetScrollFrame("$parentHeaderScrollFrame", self, {
		childKey = "Headers",
		childWidth = 232,
		stepSize = 50,
	})

	rebindFrame.ValueScroll = db.Atlas.GetScrollFrame("$parentValueScrollFrame", self, {
		childKey = "Values",
		childWidth = 232,
		stepSize = 50,
	})

	rebindFrame.ShortcutScroll = db.Atlas.GetScrollFrame("$parentShortcuts", self, {
		childWidth = 40,
		stepSize = 50,
	})

	rebindFrame.Swapper = SwapperMixin:CreateButton("$parentSwapper", self, config.listButton)
	rebindFrame.Swapper:SetPoint("BOTTOMRIGHT", self, -60, 20)
	rebindFrame.Swapper.name = TUTORIAL.SWAPPER

	rebindFrame.ShortcutScroll:SetPoint("TOPRIGHT", rebindFrame, "TOPLEFT", -16, 0)
	rebindFrame.ShortcutScroll:SetPoint("BOTTOMLEFT", rebindFrame, "BOTTOMLEFT", -54, 0)
	rebindFrame.ShortcutScroll.ScrollBar:ClearAllPoints()
	rebindFrame.ShortcutScroll.ScrollBar:Hide()
	rebindFrame.ShortcutScroll.Backdrop:SetPoint("BOTTOMRIGHT", rebindFrame, "BOTTOMRIGHT", 24, -16)

	rebindFrame.HeaderScroll:HookScript("OnMouseWheel", RebindMixin.OnMouseWheel)
	rebindFrame.HeaderScroll:SetPoint("TOPLEFT", rebindFrame, "TOPRIGHT", 32, 0)
	rebindFrame.HeaderScroll:SetPoint("BOTTOMRIGHT", rebindFrame, "BOTTOMRIGHT", 276, 0)

	rebindFrame.Headers = rebindFrame.HeaderScroll.Child
	rebindFrame.Headers:HookScript("OnShow", RefreshHeaderList)

	rebindFrame.Values = rebindFrame.ValueScroll.Child
	rebindFrame.Headers.Values = rebindFrame.Values

	rebindFrame.ValueScroll:HookScript("OnMouseWheel", RebindMixin.OnMouseWheel)
	rebindFrame.ValueScroll:SetPoint("TOPLEFT", rebindFrame.HeaderScroll, "TOPRIGHT", 32, 0)
	rebindFrame.ValueScroll:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -56, 84)

	window = self

	local function CreateRebindButton(name, mod)
		local buttonConfig = config.configButton
		buttonConfig.buttonTexture = db.TEXTURE[name]
		buttonConfig.default = config.customDescription[name]
		local button = db.Atlas.GetBindingMetaButton(name..mod.."_CONF", rebindFrame, buttonConfig)

		rebindFrame:AddButton(button, 10, -4)

		button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

		button.Line = button:CreateTexture(nil, "BACKGROUND", nil, 3)
		button.Line:SetPoint("BOTTOMLEFT", 0, 0)
		button.Line:SetSize(280, 52)

		button.Line:SetAtlas("bonusobjectives-title-bg")
		button.Line:SetTexture("Interface\\LevelUp\\MinorTalents.blp")
		button.Line:SetTexCoord(0, 0.8164, 0.6660, 0.7968)
		button.Line:SetAlpha(0.35)

		button.SelectedTexture = button.SelectedTexture or button:CreateTexture("$parentSelectedTexture", "OVERLAY")
		button.SelectedTexture:Hide()
		button.SelectedTexture:SetTexture("Interface\\PVPFrame\\PvPMegaQueue")
		button.SelectedTexture:SetPoint("TOPLEFT", 0, 0)
		button.SelectedTexture:SetPoint("BOTTOMRIGHT", 230, 0)
		button.SelectedTexture:SetTexCoord(0.00195313, 0.63867188, 0.76953125, 0.83007813)
		button.SelectedTexture:SetBlendMode("ADD")

		button.HighlightTexture = button.HighlightTexture or button:CreateTexture("$parentHighlightTexture", "HIGHLIGHT")
		button.HighlightTexture:SetTexture("Interface\\PVPFrame\\PvPMegaQueue")
		button.HighlightTexture:SetPoint("TOPLEFT", 0, 2)
		button.HighlightTexture:SetPoint("BOTTOMRIGHT", 230, 0)
		button.HighlightTexture:SetTexCoord(0.00195313, 0.63867188, 0.70703125, 0.76757813)

		button:SetHighlightTexture(button.HighlightTexture)

		button.modifier = mod
		button.name = name

		local extras = config.configButtonModifier[mod]
		if extras then
			extras(button)
		end

		if mod == "SHIFT-" then
			local shortcut = CreateFrame("Button", name..mod.."_CONF_SHORTCUT", rebindFrame.ShortcutScroll)
			shortcut:SetSize(32, 32)
			shortcut:SetAlpha(0.35)
			shortcut:SetBackdrop({bgFile = TEXTURE[name]})
			shortcut.Button = button
			shortcut.name = name

			Mixin(shortcut, ShortcutMixin)

			rebindFrame.ShortcutScroll:AddButton(shortcut, 7)
		end

		button.secure = _G[name..mod]
		button.secure.conf = button

		Mixin(button, ButtonMixin)

		if not window.Buttons[name] then
			window.Buttons[name] = {}
		end
		tinsert(window.Buttons[name], button)
		return button
	end

	for name in core:GetBindings() do
		for modifier in core:GetModifiers() do
			local secure = core:GetSecureButton(name, modifier)
			CreateRebindButton(name, modifier, secure)
		end
	end

	rebindFrame.HeaderScroll:Hide()

	rebindFrame:Refresh()
	rebindFrame.ShortcutScroll:Refresh()
end}
