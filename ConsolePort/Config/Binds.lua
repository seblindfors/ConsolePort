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
		-- Fade wrappers
		FadeIn, FadeOut,
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
		db.UIFrameFadeIn, db.UIFrameFadeOut,
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
	-- Hard-coded movement bindings
	movement = {
		MOVEFORWARD 	= {"W", "UP"},
		MOVEBACKWARD 	= {"S", "DOWN"},
		STRAFELEFT 		= {"A", "LEFT"},
		STRAFERIGHT 	= {"D", "RIGHT"},
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
	self.Label:SetTextColor(notHeader and 1, 1, 1, 1 or 1, 0.82, 0, 1)
	self:SetEnabled(notHeader and true or false)
	self.Cover:SetShown(notHeader and true or false)

	self:Refresh()

	if notHeader then
		key, mod = ConsolePort:GetCurrentBindingOwner(binding, newBindingSet)
		if key and mod then
			local texture = format(self[mod], ICONS[key])
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
		self.hotKey:SetText(format(BindingMixin[owner.modifier], ICONS[owner.name]))
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
	local set = newBindingSet or ConsolePortBindingSet
	local vCount = 0
	local config = config.listButton
	config.omitHeader = true
	for i, binding in pairs(bindings) do
		vCount = vCount + 1
		local button = buttons[i] or BindingMixin:CreateButton("$parentButton"..vCount, self.ValueList, true, config)
		button:SetBinding(binding.binding)
		button.name = binding.name
		button:OnShow()
	end
	self.ValueList:Refresh(vCount)
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

function ConsolePort:CreateConfigButton(name, mod, secure)
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
end

---------------------------------------------------------------
-- Binds: Create addon dummy bindings
---------------------------------------------------------------
local function SetFakeBinding(self, modifier, original, override)
	if original and override then
		local key1, key2 = GetBindingKey(original) or config.mouseBindings[original]
	--	print(GetTime(), original, key1, key2)
		if key1 then SetOverrideBinding(self, false, modifier..key1, override) end
		if key2 then SetOverrideBinding(self, false, modifier..key2, override) end
	end
end

local function SetMouseBindings(self, handler, keys)
	for stick, button in pairs(config.mouseBindings) do
		if keys[stick] and keys[stick][""] then
			for modifier in ConsolePort:GetModifiers() do
				if modifier ~= "" then
					SetOverrideBinding(handler, false, modifier..button, config.mouseDefault[button])
				end
			end
		end
	end
end

local function SetMovementBindings(self, handler)
	local movement = config.movement
	if db.Settings.turnCharacter then
		movement.TURNLEFT = movement.STRAFELEFT
		movement.TURNRIGHT = movement.STRAFERIGHT
		movement.STRAFELEFT = nil
		movement.STRAFERIGHT = nil
	elseif not movement.STRAFELEFT or not movement.STRAFERIGHT then
		movement.STRAFELEFT = movement.TURNLEFT
		movement.STRAFERIGHT = movement.TURNRIGHT
		movement.TURNLEFT = nil
		movement.TURNRIGHT = nil
	end
	for direction, keys in spairs(movement) do
		for _, key in pairs(keys) do
			for modifier in self:GetModifiers() do
				SetOverrideBinding(handler, false, modifier..key, direction)
			end
		end
	end
end

function ConsolePort:LoadBindingSet()
	local calibration = db.Settings.calibration
	if calibration then
		for binding, key in pairs(calibration) do
			SetBinding(key, binding)
		end
	end
	local keys = newBindingSet or db.Bindings
	local handler = ConsolePortButtonHandler
	ClearOverrideBindings(handler)
	SetMovementBindings(self, handler)
	SetMouseBindings(self, handler, keys)
	for name, key in pairs(keys) do
		for modifier in self:GetModifiers() do
			SetFakeBinding(handler, modifier, name, key[modifier])
		end
	end
	self:RemoveUpdateSnippet(self.LoadBindingSet)
	return keys
end

function ConsolePort:LoadInterfaceBinding(button, UIbutton)
	local action = _G[UIbutton]
	if action then
		button.action = action
		button:Reset()
		button:Revert()
		if button.action.HotKey then
			button.action.HotKey:SetAlpha(0)
		end
		button:ShowInterfaceHotKey()
	else
		self:AddWidgetTracker(button, UIbutton)
	end
end

---------------------------------------------------------------
-- Binds: Import profile functions 
---------------------------------------------------------------
local function ProfileOnSelect(self)
	local buttons = self:GetParent().Buttons
	for _, button in pairs(buttons) do
		button.SelectedTexture:Hide()
	end
	self.SelectedTexture:Show()
	self.Popup:SetSelection(self.name)
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

	for name, data in pairs(db.Controllers) do
		profiles["|cFFFFFFFF"..name.."|r"..TUTORIAL.PROFILEPRESET] = {
			Type = name,
			BindingSet = data.Bindings,
			Preset = true,
		}
	end

	profiles["|cFFFFFFFF"..TUTORIAL.PROFILEEMPTY.."|r"..TUTORIAL.PROFILEPRESET] = {
		BindingSet = {},
		Preset = true,
	}

	for character, settings in spairs(profiles) do
		pCount = pCount + 1
		local button = buttons[pCount]
		if not button then
			button = db.Atlas.GetFutureButton("$parentButton"..pCount, self)
			button:SetScript("OnClick", ProfileOnSelect)
			self:AddButton(button, 56)
		end
		button:SetText(character)
		button:Show()
		button.preset = settings.Preset
		if settings.Class then
			local cc = RAID_CLASS_COLORS[settings.Class]
			button.Cover:SetVertexColor(cc.r, cc.g, cc.b, 1)
		elseif settings.Preset then
			button.Cover:SetAlpha(0.25)
		else
			button.Cover:SetVertexColor(1, 1, 1, 1)
		end
		if settings.Type and db.Controllers[settings.Type] then
			button.Controller = button.Controller or button:CreateTexture(nil, "OVERLAY")
			button.Controller:SetSize(32, 32)
			button.Controller:SetPoint("RIGHT", button, "LEFT", -8, 0)
			button.Controller:SetTexture("Interface\\AddOns\\ConsolePort\\Controllers\\"..settings.Type.."\\Icons64\\CP_X_CENTER")
		elseif button.Controller then
			button.Controller:SetTexture()
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
		window.Tutorial:SetText(format(TUTORIAL.IMPORT, character))
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
	ConsolePortConfig.Tooltip:Hide()
	ConsolePortCursor:Hide()
	window.BindCatcher:SetAlpha(0)
	window.Tutorial:SetAlpha(0)
	window:OnShow(2)
	C_Timer.After(0.1, function()
		ConsolePort:ScrollToNode(window.Buttons[self.name][1], rebindFrame)
	end)
end

function LayoutMixin:OnEnter()
	local tooltip = ConsolePortConfig.Tooltip
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
	local tooltip = ConsolePortConfig.Tooltip
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
	if not db.Settings.disableUI and not ConsolePort:IsCurrentNode(window.Display) then
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
function WindowMixin:Export()
	local this = GetUnitName("player").."-"..GetRealmName()
	local class = select(2, UnitClass("player"))
	if 	not compare(db.Bindings, ConsolePort:GetDefaultBindingSet()) then
		if not ConsolePortCharacterSettings then
			ConsolePortCharacterSettings = {}
		end
		ConsolePortCharacterSettings[this] = {
			BindingSet = db.Bindings,
			MouseEvent = db.Mouse.Events,
			Type = db.Settings.type,
			Class = class,
		}
	elseif ConsolePortCharacterSettings then
		ConsolePortCharacterSettings[this] = nil
	end
end

function WindowMixin:Reload()
	ConsolePort:LoadBindingSet()
	ConsolePort:LoadHotKeyTextures(newBindingSet)

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
	GetNewBindingSet(true)
	self:Reload()
end

function WindowMixin:Save()
	if 	newBindingSet then
		db.Bindings = newBindingSet

		newBindingSet = nil

		ConsolePortBindingSet = db.Bindings
		self:Reload()
		self:Export()
	end
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
		self.Controller:Show()
		if not db.Settings.disableUI then
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
		self.Tutorial:ClearAllPoints()
		self.Tutorial:SetPoint("BOTTOMLEFT", 32, 20)
		self.Tutorial:SetJustifyH("LEFT")
		self.Tutorial:SetTextColor(0.75, 0.75, 0.75)
		self.Tutorial:SetText(format(TUTORIAL.COMBO, ICONS[db.Mouse.Cursor.Left], ICONS[db.Mouse.Cursor.Right]))
	end
end

---------------------------------------------------------------
db.PANELS[#db.PANELS + 1] = {"Binds", TUTORIAL.HEADER, nil, WindowMixin, function(self, Binds)
	local settings = db.Settings
	local player = GetUnitName("player").."-"..GetRealmName()
	local cc = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

	Binds.Controller = CreateFrame("Frame", "$parentController", Binds)
	Binds.Controller:SetPoint("CENTER", 0, 0)
	Binds.Controller:SetSize(512, 512)

	Binds.Controller.Texture = Binds.Controller:CreateTexture("$parentTexture", "ARTWORK")
	Binds.Controller.Texture:SetTexture("Interface\\AddOns\\ConsolePort\\Controllers\\"..settings.type.."\\Front")
	Binds.Controller.Texture:SetAllPoints(Binds.Controller)

	Binds.Controller.FlashGlow = Binds.Controller:CreateTexture("$parentGlow", "OVERLAY")
	Binds.Controller.FlashGlow:SetTexture("Interface\\AddOns\\ConsolePort\\Controllers\\"..settings.type.."\\FrontHighlight")
	Binds.Controller.FlashGlow:SetAllPoints(Binds.Controller)
	Binds.Controller.FlashGlow:SetAlpha(0)
	Binds.Controller.FlashGlow:SetVertexColor(cc.r, cc.g, cc.b)

	Binds.Overlay = CreateFrame("Frame", "$parentOverlay", Binds.Controller)
	Binds.Overlay:SetPoint("CENTER", 0, 0)
	Binds.Overlay:SetSize(1024, 512)
	Binds.Overlay.Lines = Binds.Overlay:CreateTexture("$parentLines", "OVERLAY", nil, 7)
	Binds.Overlay.Lines:SetTexture("Interface\\AddOns\\ConsolePort\\Controllers\\"..settings.type.."\\Overlay")
	Binds.Overlay.Lines:SetAllPoints(Binds.Overlay)
	Binds.Overlay.Lines:SetVertexColor(cc.r * 1.25, cc.g * 1.25, cc.b * 1.25, 0.75)

	Binds.Overlay.Buttons = {}

	Binds.Tutorial = Binds:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Binds.Tutorial.SetNewText = Binds.Tutorial.SetText

	function Binds.Tutorial:SetText(...)
		self:SetNewText(...)
		FadeIn(self, 1, 0, 1)
	end

---------------------------------------------------------------

	Binds.BindCatcher = db.Atlas.GetFutureButton("$parentBindCatcher", Binds.Controller, nil, nil, 350)
	Binds.BindCatcher.HighlightTexture:ClearAllPoints()
	Binds.BindCatcher.HighlightTexture:SetPoint("TOP", Binds.BindCatcher, "TOP")
	Binds.BindCatcher:SetHeight(64)
	Binds.BindCatcher:SetPoint("TOP", 0, -30)
	Binds.BindCatcher.Cover:Hide()
	Binds.BindCatcher.hasPriority = true

	Mixin(Binds.BindCatcher, CatcherMixin)

---------------------------------------------------------------

	Binds.Import = db.Atlas.GetFutureButton("$parentImport", Binds)
	Binds.Import.Popup = ConsolePortPopup
	Binds.Import:SetPoint("LEFT", ConsolePortConfigDefault, "RIGHT", 0, 0)
	Binds.Import:SetText(TUTORIAL.IMPORTBUTTON)
	Binds.Import:SetScript("OnClick", function(self)
		self.Popup:SetPopup(self:GetText(), self.ProfileScroll, self.Import, self.Remove)
	end)

	Binds.Import.Import = CreateFrame("Button", Binds.Import)
	Binds.Import.Import:SetText(TUTORIAL.IMPORTBUTTON)
	Binds.Import.Import:SetScript("OnClick", ImportOnClick)

	Binds.Import.Remove = CreateFrame("Button", Binds.Import)
	Binds.Import.Remove:SetText(TUTORIAL.REMOVEBUTTON)
	Binds.Import.Remove:SetScript("OnClick", RemoveOnClick)
	Binds.Import.Remove.dontHide = true

	Binds.Import.ProfileScroll = db.Atlas.GetScrollFrame("$parentProfileScrollFrame", Binds.Import, {
		childKey = "Profiles",
		childWidth = 350,
		stepSize = 50,
		noBackdrop = true,
	})

	-- offset the scrollbar as to not clip the edge of the popup frame
	Binds.Import.ProfileScroll.ScrollBar:ClearAllPoints()
	Binds.Import.ProfileScroll.ScrollBar:SetPoint("TOPLEFT", Binds.Import.ProfileScroll, "TOPRIGHT", -28, 0)
	Binds.Import.ProfileScroll.ScrollBar:SetPoint("BOTTOMLEFT", Binds.Import.ProfileScroll, "BOTTOMRIGHT", -28, 0)

	Binds.Import.Profiles = Binds.Import.ProfileScroll.Child
	Binds.Import.Profiles:SetScript("OnShow", RefreshProfileList)
	Binds.Import.ProfileScroll:Hide()

---------------------------------------------------------------

	Binds.Display = CreateFrame("CheckButton", "$parentDisplayButton", Binds)
	Binds.Display:SetID(settings.bindView or 1)

	for name, config in pairs(config.displayButton) do
		local texture = Binds.Display:CreateTexture(nil, "ARTWORK", nil, config[1])
		Binds.Display[name] = texture

		texture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
		texture:SetTexCoord(unpack(config[2]))
		texture:SetSize(unpack(config[3]))

		local point = config[4]
		if point then
			texture:SetPoint(unpack(point))
		end
	end

	config.displayButton = nil

	function Binds.Display:OnShow()
		local view = self:GetID()
		self.LeftEnabled:SetShown(view == 2)
		self.RightEnabled:SetShown(view == 1)
	end

	function Binds.Display:OnClick()
		local view = self:GetID() == 1 and 2 or 1
		settings.bindView = view
		self:SetID(view)
		self:GetParent():OnShow()
	end

	Mixin(Binds.Display, Binds.Display)

	Binds.Display:SetPoint("BOTTOM", 0, 20)
	Binds.Display:SetSize(161.6, 47.2)

	Binds.Display.LeftEnabled:SetAlpha(0.25)
	Binds.Display.LeftEnabled:SetBlendMode("ADD")

	Binds.Display.RightEnabled:SetAlpha(0.25)
	Binds.Display.RightEnabled:SetBlendMode("ADD")

	Binds.Display.Controller:SetPoint("CENTER", Binds.Display.LeftNormal, "CENTER", 1.2, 3.2)
	Binds.Display.Grid:SetPoint("CENTER", Binds.Display.RightNormal, "CENTER", -1.2, 3.2)

---------------------------------------------------------------

	Binds.Buttons = {}

	local customDescription = config.customDescription
	customDescription[settings.CP_M2] = TUTORIAL.CTRL
	customDescription[settings.CP_M1] = TUTORIAL.SHIFT

	local triggers = {
		[settings.CP_T1] = "CP_T1",
		[settings.CP_T2] = "CP_T2",
	}

	local iconPath = "Interface\\AddOns\\ConsolePort\\Controllers\\"..settings.type.."\\Icons64\\"
	local distanceFromEdge = 420
	if db.Layout then
		local layout = config.layOut
		for buttonName, info in pairs(db.Layout) do
			if not (settings.skipGuideBtn and buttonName == "CP_X_CENTER") then
				local texture = iconPath..buttonName
				local settings = layout[info.anchor]
				local 	position, iconPoint, textPoint, buttonPoint, hitRects = 
						settings.position, settings.iconPoint, settings.textPoint, settings.buttonPoint, settings.hitRects

				position[3] = (info.index - 1) * -48 - 80

				local custom = customDescription[buttonName]
				local name = triggers[buttonName] or buttonName

				local button = db.Atlas.GetBindingMetaButton(name.."_BINDING", Binds.Overlay, {
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
					Binds.Overlay.Buttons[#Binds.Overlay.Buttons + 1] = button
				end
			end
		end
		config.layOut = nil
	else
		-- If the controller has no layout settings, use grid. NYI
		settings.bindView = 2
		Binds.Display:SetID(2)
		Binds.Display:SetButtonState("DISABLED")
	end

---------------------------------------------------------------

	Binds.Rebind = db.Atlas.GetScrollFrame("ConsolePortRebindFrame", Binds, {
		childKey = "List",
		childWidth = 250,
		stepSize = 50,
	})

	rebindFrame = Binds.Rebind

	rebindFrame:SetPoint("TOPLEFT", 86, -32)
	rebindFrame:SetPoint("BOTTOMRIGHT", Binds, "BOTTOM", -116, 84)

	Mixin(rebindFrame, RebindMixin)

	rebindFrame.HeaderScroll = db.Atlas.GetScrollFrame("$parentHeaderScrollFrame", rebindFrame, {
		childKey = "Headers",
		childWidth = 232,
		stepSize = 50,
	})

	rebindFrame.ValueScroll = db.Atlas.GetScrollFrame("$parentValueScrollFrame", rebindFrame, {
		childKey = "Values",
		childWidth = 232,
		stepSize = 50,
	})

	rebindFrame.ShortcutScroll = db.Atlas.GetScrollFrame("$parentShortcuts", rebindFrame, {
		childWidth = 40,
		stepSize = 50,
	})

	rebindFrame.Swapper = SwapperMixin:CreateButton("$parentSwapper", rebindFrame, config.listButton)
	rebindFrame.Swapper:SetPoint("BOTTOMRIGHT", Binds, -60, 20)
	rebindFrame.Swapper.name = TUTORIAL.SWAPPER

	rebindFrame.ShortcutScroll:SetPoint("TOPRIGHT", rebindFrame, "TOPLEFT", -16, 0)
	rebindFrame.ShortcutScroll:SetPoint("BOTTOMLEFT", -54, 0)
	rebindFrame.ShortcutScroll.ScrollBar:ClearAllPoints()
	rebindFrame.ShortcutScroll.ScrollBar:Hide()
	rebindFrame.ShortcutScroll.Backdrop:SetPoint("BOTTOMRIGHT", 24, -16)

	rebindFrame.HeaderScroll:HookScript("OnMouseWheel", RebindMixin.OnMouseWheel)
	rebindFrame.HeaderScroll:SetPoint("TOPLEFT", rebindFrame, "TOPRIGHT", 32, 0)
	rebindFrame.HeaderScroll:SetPoint("BOTTOMRIGHT", 276, 0)

	rebindFrame.Headers = rebindFrame.HeaderScroll.Child
	rebindFrame.Headers:SetScript("OnShow", RefreshHeaderList)

	rebindFrame.Values = rebindFrame.ValueScroll.Child
	rebindFrame.Headers.Values = rebindFrame.Values

	rebindFrame.ValueScroll:HookScript("OnMouseWheel", RebindMixin.OnMouseWheel)
	rebindFrame.ValueScroll:SetPoint("TOPLEFT", rebindFrame.HeaderScroll, "TOPRIGHT", 32, 0)
	rebindFrame.ValueScroll:SetPoint("BOTTOMRIGHT", Binds, "BOTTOMRIGHT", -56, 84)

	window = Binds
end}
