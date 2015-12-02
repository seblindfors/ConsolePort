---------------------------------------------------------------
-- Binds.lua: Binding manager and functions related to bindings
---------------------------------------------------------------
-- Creates the faux binding manager and all things related
-- to bindings. Also includes hotkey texture management.
-- The system converts one static binding for each button
-- into four combinations (no mod, shift, ctrl, shift+ctrl)
-- which then run override bindings that perish on logout.

local addOn, db = ...
local KEY = db.KEY
local TUTORIAL = db.TUTORIAL.BIND
local TEXTURE = db.TEXTURE

local CONF				= "_CONF"
local NOMOD				= "_NOMOD"
local SHIFT				= "_SHIFT"
local CTRL				= "_CTRL"
local CTRLSH			= "_CTRLSH"
local BIND 				= "BINDING_NAME_"

local NewBindingSet
local NewBindingButtons

local Compare = db.Compare
local Copy = db.Copy

---------------------------------------------------------------
-- Binds: Returns converted modifier for binding table use
---------------------------------------------------------------
local function GetBindingModifier(modifier)
	local modName = {
		_NOMOD 		= "action",
		_SHIFT 		= "shift",
		_CTRL 		= "ctrl",
		_CTRLSH 	= "ctrlsh",
	}
	return modName[modifier]
end

---------------------------------------------------------------
-- Binds: Returns converted modifier for faux binding use
---------------------------------------------------------------
local function GetBindingPrefix(modifier)
	local modName = {
		_SHIFT 	= "SHIFT",
		_CTRL 	= "CTRL",
		_CTRLSH = "CTRL-SHIFT",
	}
	return modName[modifier]
end

---------------------------------------------------------------
-- Binds: Hotkey textures for action buttons / UI
---------------------------------------------------------------
local function GetActionButtons(buttons, this)
	buttons = buttons or {}
	this = this or UIParent
	if this:IsForbidden() then
		return buttons
	end
	if this:GetAttribute("action") or this.action then
		buttons[this] = this:GetAttribute("action") or this.action 
	end
	for _, object in pairs({this:GetChildren()}) do
		GetActionButtons(buttons, object)
	end
	return buttons
end

local function ShowHotKey(index, secureBtn, actionButton)
	local HotKey = secureBtn.HotKeys[index]
	HotKey:SetParent(actionButton)
	HotKey:SetText(secureBtn.HotKey)
	HotKey:ClearAllPoints()
	HotKey:SetPoint("TOPRIGHT", actionButton, 0, 0)
	HotKey:Show()
end

local function ShowInterfaceHotKey(button)
	for i, HotKey in pairs(button.HotKeys) do
		HotKey:Hide()
	end
	button.HotKeys[1] = button.HotKeys[1] or button:CreateFontString(nil, "OVERLAY", "ChatFontNormal")
	ShowHotKey(1, button, button.action)
end

function ConsolePort:LoadHotKeyTextures()
	local set = NewBindingSet or ConsolePortBindingSet
	local actionButtons = GetActionButtons()
	local index, modifier, binding, ID

	for secureBtn in pairs(db.SECURE) do
		for i, HotKey in pairs(secureBtn.HotKeys) do
			HotKey:Hide()
		end
		index = 0
		modifier = GetBindingModifier(secureBtn.mod)
		binding = set[secureBtn.name][modifier]
		ID = self:GetActionID(binding)

		if ID then
			for actionButton, actionID in pairs(actionButtons) do
				if 	ID == actionID or 
					self:GetActionBinding(ID) == self:GetActionBinding(actionID) then
					index = index + 1
					secureBtn.HotKeys[index] = 	secureBtn.HotKeys[index] or
												secureBtn:CreateFontString(nil, "OVERLAY", "ChatFontNormal")

					ShowHotKey(index, secureBtn, actionButton)

					if actionButton.HotKey then
						actionButton.HotKey:SetAlpha(0)
					end
				end
			end
		elseif secureBtn.action then
			ShowInterfaceHotKey(secureBtn)
		end
	end
end

---------------------------------------------------------------
-- Binds: Reload, save and revert binds
---------------------------------------------------------------
local function ReloadBindings()
	ConsolePort:LoadInterfaceBindings()
	ConsolePort:LoadBindingSet()
	ConsolePort:LoadHotKeyTextures()
end

local function ExportCharacterSettings()
	local this = GetUnitName("player").."-"..GetRealmName()
	if 	not Compare(ConsolePortBindingSet, ConsolePort:GetDefaultBindingSet()) or
		not Compare(ConsolePortBindingButtons, ConsolePort:GetDefaultBindingButtons()) then
		if not ConsolePortCharacterSettings then
			ConsolePortCharacterSettings = {}
		end
		if not ConsolePortCharacterSettings[this] then
			ConsolePortCharacterSettings[this] = {}
		end
		ConsolePortCharacterSettings[this] = {
			BindingSet = ConsolePortBindingSet,
			BindingBtn = ConsolePortBindingButtons,
			MouseEvent = ConsolePortMouse.Events,
		}
	elseif ConsolePortCharacterSettings then
		ConsolePortCharacterSettings[this] = nil
	end
end

local function SubmitBindings()
	if 	NewBindingSet or NewBindingButtons then
		ConsolePortBindingSet = NewBindingSet or ConsolePortBindingSet
		ConsolePortBindingButtons = NewBindingButtons or ConsolePortBindingButtons
		if not InCombatLockdown() then
			ReloadBindings()
		else
			ReloadUI()
		end
		ExportCharacterSettings()
	end
end

local function RevertBindings()
	if 	NewBindingButtons or NewBindingSet then
		NewBindingButtons = nil
		NewBindingSet = nil
		ConsolePort:LoadHotKeyTextures()
		if not InCombatLockdown() then
			ReloadBindings()
		else
			ReloadUI()
		end
	end
end

---------------------------------------------------------------
-- Binds: Secure UI/Button rebind animation
---------------------------------------------------------------
local function AnimateBindingChange(target, destination)
	if not ConsolePortAnimationFrame then
		local AniFrame = CreateFrame("FRAME", "ConsolePortAnimationFrame", UIParent)
		AniFrame.texture = AniFrame:CreateTexture()
		AniFrame:SetFrameStrata("TOOLTIP")
		AniFrame:SetSize(40,40)
		AniFrame.texture:SetAllPoints(AniFrame)
		AniFrame.group = AniFrame:CreateAnimationGroup()
		AniFrame.animation = AniFrame.group:CreateAnimation("Translation")
		AniFrame.animation:SetDuration(0.6)
		AniFrame.animation:SetSmoothing("OUT")
		AniFrame.group:SetScript("OnPlay", function()
			AniFrame:Show()
		end)
		AniFrame.group:SetScript("OnFinished", function()
			AniFrame:Hide()
			AniFrame.dest.background:SetTexture(AniFrame.texture:GetTexture())
			db.UIFrameFadeIn(AniFrame.dest.background, 1.5, 0.25, 1)
			db.UIFrameFlash(db.Binds.FlashGlow, 0.25, 0.25, 0.75, false, 0.25, 0)
		end)
	end
	local AniFrame = ConsolePortAnimationFrame
	local dX, dY = destination:GetCenter()
	local tX, tY = target:GetCenter()
	AniFrame.texture:SetTexture(target.icon and target.icon:GetTexture())
	AniFrame.dest = destination
	AniFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", tX,tY)
	AniFrame.animation:SetOffset((dX-tX), (dY-tY))
	AniFrame.group:Play()
end

---------------------------------------------------------------
-- Binds: Secure UI/Button binding changer
---------------------------------------------------------------
local function ChangeButtonBinding(actionButton)
	local buttonName 	= actionButton:GetName()
	local confButton 	= _G[buttonName..CONF]
	local tableIndex 	= actionButton.name
	local modifier 		= actionButton.mod
	local focusFrame 	= ConsolePort:GetCurrentNode()
	local focusFrameName = focusFrame:GetName()
	-- Rebind checkup
	if 	focusFrameName and
		focusFrame:IsObjectType("Button") then

		local isValid = false
		local isStatic = false

		if focusFrame.Binding then
			isStatic = true
			isValid = true
		elseif focusFrame:GetParent() ~= ConsolePortRebindFrame then
			isStatic = false
			isValid = true
		end

		if isValid then
			if not NewBindingSet then
				NewBindingSet = Copy(ConsolePortBindingSet)
			end
			if not NewBindingButtons then
				NewBindingButtons = Copy(ConsolePortBindingButtons)
			end

			local mod = GetBindingModifier(modifier)

			if isStatic then
				local text = _G[BIND..focusFrame.Binding] or focusFrame.Binding
				NewBindingSet[tableIndex][mod] = focusFrame.Binding
				NewBindingButtons[tableIndex][mod] = nil
				actionButton.action = nil
				confButton:SetText(text)
				isValid = text
			else
				local newAction = focusFrame:GetAttribute("action") or focusFrame.action or focusFrame

				local actionBinding = ConsolePort:GetActionBinding(newAction)
				if actionBinding then
					local text = _G[BIND..actionBinding] or focusFrameName
					NewBindingSet[tableIndex][mod] = actionBinding
					NewBindingButtons[tableIndex][mod] = nil
					actionButton.action = nil
					confButton:SetText(text)
					isValid = text
				else
					NewBindingSet[tableIndex][mod] = "CLICK "..buttonName..":LeftButton"
					NewBindingButtons[tableIndex][mod] = focusFrameName
					confButton:SetText(focusFrameName)
					isValid = focusFrameName
				end

			end

			AnimateBindingChange(focusFrame, confButton)
			ReloadBindings()
		end

		return isValid
	end
end

---------------------------------------------------------------
-- Binds: Static key binding table
---------------------------------------------------------------
local function CreateStaticBindButton(parent, num, clickScript)
	local button = CreateFrame("Button", "$parentButton"..num, parent, "OptionsListButtonTemplate")
	button:SetHeight(16)
	button:SetScript("OnClick", clickScript)
	tinsert(parent.Buttons, button)
	if num == 1 then
		button:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -4)
		button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -4, -4)
	else
		button:SetPoint("TOPLEFT", parent.Buttons[num-1], "BOTTOMLEFT")
		button:SetPoint("TOPRIGHT", parent.Buttons[num-1], "BOTTOMRIGHT")
	end
	return button
end

local function BindValueOnClick(self)
	if ConsolePortRebindFrame.isRebinding and not InCombatLockdown() then
		ConsolePort:SetCurrentNode(self)
		ConsolePortRebindFrame.isRebinding:GetScript("OnClick")(ConsolePortRebindFrame.isRebinding, "LeftButton")
	end
end

local function BindHeaderOnClick(self)
	local bindings = self.Bindings
	local buttons = self.ValueList.Buttons
	for i, button in pairs(buttons) do
		button:Hide()
	end
	local vCount = 0
	for i, binding in pairs(bindings) do
		vCount = vCount + 1 
		local button = buttons[i] or CreateStaticBindButton(self.ValueList, vCount, BindValueOnClick)
		local font = _G[button:GetName().."Text"]
		font:SetTextColor(binding.binding and 1, 1, 1, 1 or 1, 0, 1, 1)
		button:SetEnabled(binding.binding and true or false)
		button:SetText(binding.name)
		button:Show()
		button.Binding = binding.binding
	end
	self.ValueList:SetHeight(vCount*16)
	self.ValueList:SetWidth(218)
end

local function RefreshHeaderList(self)
	local buttons = self.Buttons
	local bindings = self.Bindings
	local category, name
	wipe(bindings)
	for i=1, GetNumBindings() do
		binding, header = GetBinding(i)
		if header then
			category = _G[header] or header
			if not bindings[category] then
				bindings[category] = {}
			end
			name = _G[BIND..binding] or _G["BINDING_"..binding]
			tinsert(bindings[category], {name = name, binding = _G[BIND..binding] and binding})
		elseif 	(binding:match("^HEADER") and not
				binding:match("^HEADER_BLANK") and not
				binding:match("^CP_")) or not
				binding:match("^HEADER") then
			if not bindings[TUTORIAL.OTHERCATEGORY] then
				bindings[TUTORIAL.OTHERCATEGORY] = {}
			end
			name = _G[BIND..binding] or _G["BINDING_"..binding]
			tinsert(bindings[TUTORIAL.OTHERCATEGORY], {name = name, binding = _G[BIND..binding] and binding})
		end
	end
	bindings["ConsolePort "] = ConsolePort:GetAddonBindings()
	local hCount = 0
	for i, button in pairs(self.Buttons) do
		button:Hide()
	end
	for category, bindings in db.pairsByKeys(bindings) do
		hCount = hCount + 1
		local button = buttons[hCount] or CreateStaticBindButton(self, hCount, BindHeaderOnClick)
		button:SetText(category)
		button:Show()
		button.Bindings = bindings
		button.ValueList = self.Values
	end
	self:SetHeight(hCount*16)
	self:GetParent():SetHeight(hCount*(16+1) <= 330 and hCount*(16+1) or 330)
	self:SetWidth(218)
end

---------------------------------------------------------------
-- Binds: Dynamic secure/UI button 
---------------------------------------------------------------
local function GetStaticBindingName(self)
	local key  = GetBindingKey(self.name)
	local binding 
	if key then
		key = self.modifier and self.modifier.."-"..key or key
		binding = _G[BIND..GetBindingAction(key, true)]
	end
	if not binding then
		binding = _G[BIND..ConsolePortBindingSet[self.name][GetBindingModifier(self.secure.mod)]]
	end
	return binding 
end

local function GetStaticBinding(self)
	return ConsolePortBindingSet[self.secure.name][GetBindingModifier(self.secure.mod)]
end

local function DynamicConfigButtonOnShow(self)
	self.indicator:SetText(self.icon)
	if self.secure.action then
		self:SetText(self.secure.action:GetName())
		if self.secure.action.icon and self.secure.action.icon:IsVisible() then
			self.background:SetTexture(self.secure.action.icon:GetTexture())
		else
			self.background:SetTexture(nil)
		end
	elseif self.secure.widgetTracker then
		self:SetText(format("|cFFFF1111%s|r", self.secure.widgetTracker))
	elseif GetStaticBindingName(self) then
		self:SetText(GetStaticBindingName(self))
		self.background:SetTexture(ConsolePort:GetActionTexture(GetStaticBinding(self)))
	else
		self.background:SetTexture(nil)
	end
end

local function DynamicConfigButtonOnClick(self, mouseButton)
	if not InCombatLockdown() then
		if not ConsolePortRebindFrame.isRebinding then
			db.Binds.Tutorial:SetText(format(TUTORIAL.REBIND, self.indicator:GetText()))
			ConsolePort:SetRebinding(self)
			ConsolePort:SetCurrentNode(self.secure.action)
		else
			local stopRebind = true
			if mouseButton == "LeftButton" then
				local frame = ConsolePort:GetCurrentNode()
				local name = frame:GetName()
				if 	frame:GetParent() == ConsolePortRebindFrameStaticHeaders then
					stopRebind = false
					BindHeaderOnClick(frame)
				else 
					local newBind = ChangeButtonBinding(self.secure)
					if newBind then
						db.Binds.Tutorial:SetText(format(TUTORIAL.APPLIED, self.indicator:GetText(), newBind))
					else
						db.Binds.Tutorial:SetText(TUTORIAL.INVALID)
					end
				end
			else
				db.Binds.Tutorial:SetText(format(TUTORIAL.COMBO, db.Binds.Rebind.button.bindings[1].icons))
			end
			if stopRebind then
				ConsolePort:SetRebinding(false)
				ConsolePort:SetCurrentNode(self)
				ConsolePort:SetButtonActionsUI()
				ConsolePort:UIControl()
			end
		end
	end
end

function ConsolePort:CreateConfigButton(name, mod, modNum)
	local button = CreateFrame("BUTTON", name..mod..CONF, db.Binds.Rebind, "OptionsListButtonTemplate")
	button:SetBackdrop(nil)
	button:SetSize(390,40)
	button:SetPoint("TOP", db.Binds.Rebind, "TOP", 0, -40*modNum-8)
	button.hasPriority = mod == NOMOD
	button.text:SetJustifyH("CENTER")

	button.indicator = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.indicator:SetPoint("LEFT", button, "LEFT", 4, 0)

	button.background = button:CreateTexture(nil, "OVERLAY")
	button.background:SetPoint("RIGHT", button, "RIGHT", -4, 0)
	button.background:SetSize(34, 34)

	button.modifier = GetBindingPrefix(mod)
	button.name = name

	button.secure = _G[name..mod]
	button:SetScript("OnShow", DynamicConfigButtonOnShow)
	button:SetScript("OnClick", DynamicConfigButtonOnClick)
	button:SetAlpha(1)
	button:Show()
	if not db.Binds.Buttons[name] then
		db.Binds.Buttons[name] = {}
	end
	tinsert(db.Binds.Buttons[name], button)
end

---------------------------------------------------------------
-- Binds: Create addon dummy bindings
---------------------------------------------------------------
local function SetFauxBinding(self, modifier, old, new)
	if not InCombatLockdown() then
		local key1, key2 = GetBindingKey(old)
		if key1 then SetOverrideBinding(self, false, modifier..key1, new) end
		if key2 then SetOverrideBinding(self, false, modifier..key2, new) end
	end
end

local function SetFauxMovementBindings(self)
	local movement
	if ConsolePortSettings.turnCharacter then movement = {
		MOVEFORWARD 	= {"W", "UP"},
		MOVEBACKWARD 	= {"S", "DOWN"},
		TURNLEFT 		= {"A", "LEFT"},
		TURNRIGHT 		= {"D", "RIGHT"},
	}
	else movement = {
		MOVEFORWARD 	= {"W", "UP"},
		MOVEBACKWARD 	= {"S", "DOWN"},
		STRAFELEFT 		= {"A", "LEFT"},
		STRAFERIGHT 	= {"D", "RIGHT"},
		}
	end
	local modifiers = {
		"", "SHIFT-", "CTRL-", "CTRL-SHIFT-",
	}
	for direction, keys in pairs(movement) do
		for _, key in pairs(keys) do
			for _, modifier in pairs(modifiers) do
				SetOverrideBinding(self, false, modifier..key, direction)
			end
		end
	end
end

function ConsolePort:LoadBindingSet()
	local keys = NewBindingSet or ConsolePortBindingSet
	local w = WorldFrame
	ClearOverrideBindings(w)
	SetFauxMovementBindings(w)
	for name, key in pairs(keys) do
		SetFauxBinding(w, "", 	name, key.action)
		SetFauxBinding(w, "CTRL-", name, key.ctrl)
		SetFauxBinding(w, "SHIFT-", name, key.shift)
		SetFauxBinding(w, "CTRL-SHIFT-", name, key.ctrlsh)
	end
end

---------------------------------------------------------------
-- Binds: Reload bindings from table
---------------------------------------------------------------
function ConsolePort:LoadInterfaceBinding(button, UIbutton)
	local action = _G[UIbutton]
	if action then
		button.action = action
		button:Reset()
		button:Revert()
		if button.action.HotKey then
			button.action.HotKey:SetAlpha(0)
		end
		ShowInterfaceHotKey(button)
	else
		self:AddWidgetTracker(button, UIbutton)
	end
end

function ConsolePort:LoadInterfaceBindings()
	local buttons = NewBindingButtons or ConsolePortBindingButtons
	local extensions = { action = NOMOD, ctrlsh = CTRLSH, shift = SHIFT, ctrl = CTRL}
	for name, button in pairs(buttons) do
		for modifier, UIbutton in pairs(button) do
			local extension = extensions[modifier]
			if extension then
				self:LoadInterfaceBinding(_G[name..extension], UIbutton)
			end 
		end 
	end
end

---------------------------------------------------------------
-- Binds: Binding palette show function
---------------------------------------------------------------
local function BindingsOnShow(self)
	self.Tutorial:SetText(TUTORIAL.DEFAULT)
	self.Rebind:Hide()
	self.dropdown:initialize()
end

---------------------------------------------------------------
-- Binds: Import profile functions 
---------------------------------------------------------------
local function ImportOnClick(self)
	if not InCombatLockdown() then
		local character = self:GetParent().dropdown.text:GetText()
		local settings = ConsolePortCharacterSettings[character]
		if settings then
			db.Binds.Tutorial:SetText(format(TUTORIAL.IMPORT, character))
			NewBindingSet = Copy(settings.BindingSet)
			NewBindingButtons = Copy(settings.BindingBtn)
			ReloadBindings()
			ConsolePort:SetButtonActionsUI()
			for i, Buttons in pairs(db.Binds.Buttons) do
				for i, Button in pairs(Buttons) do
					Button:OnShow()
				end
			end
		end
	else
		db.Binds.Tutorial:SetText(TUTORIAL.COMBAT)
	end
end

local function RemoveOnClick(self)
	if ConsolePortCharacterSettings then
		ConsolePortCharacterSettings[UIDropDownMenu_GetText(self:GetParent().dropdown)] = nil
	end
	self:GetParent().dropdown.text:SetText(TUTORIAL.IMPORTDEFAULT)
	BindingsOnShow(self:GetParent())
end

---------------------------------------------------------------
-- Binds: Binding buttons and tooltip
---------------------------------------------------------------
local function SetBindingTooltip(self)
	GameTooltip:Hide()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
	GameTooltip:AddLine(TUTORIAL.TOOLTIPHEADER)
	if not self.bindings then
		self.bindings = {
			{	button = _G[self.name..NOMOD], mod = "",
				icons = self.texture,
			},
			{	button = _G[self.name..SHIFT], mod = "SHIFT-",
				icons = format(self.icon, db.TEXTURE.CP_TL1)..self.texture,
			},
			{	button = _G[self.name..CTRL], mod = "CTRL-",
				icons = format(self.icon, db.TEXTURE.CP_TL2)..self.texture,
			},
			{	button = _G[self.name..CTRLSH], mod = "CTRL-SHIFT-",
				icons = format(self.icon, db.TEXTURE.CP_TL1)..format(self.icon, db.TEXTURE.CP_TL2)..self.texture,
			},
		}
	end
	local indices = { "action", "shift", "ctrl", "ctrlsh" }
	for i, binding in pairs(self.bindings) do
		local static =  NewBindingSet and NewBindingSet[self.name][indices[i]] or
						ConsolePortBindingSet[self.name][indices[i]]

		local text 	= 	binding.button.action and
						((binding.button.action.icon and
						binding.button.action.icon:GetTexture() and
						format(self.icon, binding.button.action.icon:GetTexture())) or
						binding.button.action:GetName()) or
						ConsolePort:GetActionTexture(static) and
						format(self.icon, ConsolePort:GetActionTexture(static)) or
						_G[BIND..static] or
						_G[BIND..GetBindingAction(binding.mod..GetBindingKey(self.name), true)] or "N/A"
		GameTooltip:AddDoubleLine(binding.icons, text, 1,1,1,1,1,1)
	end
	GameTooltip:AddLine(TUTORIAL.TOOLTIPCLICK)
	GameTooltip:Show()
end

local function SetBindingFocus(self)
	local parent = self:GetParent()
	parent.Rebind:SetButton(self)
	ConsolePort:SetCurrentNode(parent.Buttons[self.name][1])
end

local function RebindSetButton(self, button)
	self.button = button
	local allButtons = self:GetParent().Buttons
	local rebindButtons = allButtons[button.name]
	local bindings = button.bindings
	self.Parent.Tutorial:SetText(format(TUTORIAL.COMBO, bindings[1].icons))
	for name, modButtons in pairs(allButtons) do
		for i, button in pairs(modButtons) do
			button:Hide()
		end
	end
	for i, rebinder in pairs(rebindButtons) do
		rebinder.icon = bindings[i].icons
		rebinder:Show()
	end
	self:Show()
end

---------------------------------------------------------------
-- Binds: Default function
---------------------------------------------------------------
local function LoadDefaultBinds(self)
	self.Tutorial:SetText(TUTORIAL.RESET)
	NewBindingSet = ConsolePort:GetDefaultBindingSet()
	NewBindingButtons = ConsolePort:GetDefaultBindingButtons()
end


tinsert(db.Panels, {"ConsolePortConfigFrameConfig", "Binds", TUTORIAL.SIDEBAR, TUTORIAL.HEADER, SubmitBindings, RevertBindings, LoadDefaultBinds, function(self, Binds)
	local player = GetUnitName("player").."-"..GetRealmName()

	Binds.Controller = Binds:CreateTexture("GameMenuTextureController", "ARTWORK")
	Binds.Controller:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Splash\\Splash"..ConsolePortSettings.type)
	Binds.Controller:SetPoint("CENTER", Binds, "CENTER")

	Binds.FlashGlow = Binds:CreateTexture("GameMenuTextureController", "OVERLAY")
	Binds.FlashGlow:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Splash\\Splash"..ConsolePortSettings.type.."Highlight")
	Binds.FlashGlow:SetPoint("CENTER", Binds, "CENTER")
	Binds.FlashGlow:SetAlpha(0)

	Binds.Tutorial = Binds:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Binds.Tutorial:SetPoint("TOP", Binds.Controller, 0, -80)

	Binds:HookScript("OnShow", BindingsOnShow)
	Binds:HookScript("OnHide", RevertBindings)
	Binds:HookScript("OnHide", HelpPlate_Hide)

	Binds.dropdown = CreateFrame("BUTTON", addOn.."ImportDropdown", Binds, "UIDropDownMenuTemplate")
	Binds.dropdown:SetPoint("TOPRIGHT", Binds, "TOPRIGHT", 0, -16)
	Binds.dropdown.middle = _G[addOn.."ImportDropdownMiddle"]
	Binds.dropdown.middle:SetWidth(150)
	Binds.dropdown:SetWidth(200)
	Binds.dropdown.text = _G[addOn.."ImportDropdownText"]
	Binds.dropdown.text:SetText(TUTORIAL.IMPORTDEFAULT)
	Binds.dropdown.info = {}
	Binds.dropdown:EnableMouse(false)
	Binds.dropdown.initialize = function(self)
		if ConsolePortCharacterSettings then
			wipe(self.info)
			for character, _ in pairs(ConsolePortCharacterSettings) do
				self.info.text = character
				self.info.value = character
				self.info.func = function(item)
					self.selectedID = item:GetID()
					self.text:SetText(character)
				end
				self.info.checked = self.info.text == player
				UIDropDownMenu_AddButton(self.info, 1)
			end
		else
			Binds.import:SetButtonState("DISABLED")
		end
	end

	Binds.import = CreateFrame("BUTTON", addOn.."ImportImport", Binds, "UIPanelButtonTemplate")
	Binds.import:SetPoint("TOPRIGHT", Binds.dropdown, "BOTTOMRIGHT", -16, 0)
	Binds.import:SetWidth(82)
	Binds.import:SetText(TUTORIAL.IMPORTBUTTON)
	Binds.import:SetScript("OnClick", ImportOnClick)

	Binds.remove = CreateFrame("BUTTON", addOn.."ImportRemove", Binds, "UIPanelButtonTemplate")
	Binds.remove:SetPoint("RIGHT", Binds.import, "LEFT", -4, 0)
	Binds.remove:SetWidth(82)
	Binds.remove:SetText(TUTORIAL.REMOVEBUTTON)
	Binds.remove:SetScript("OnClick", RemoveOnClick)

	Binds.Buttons = {}
	for buttonName, position in pairs(db.BINDINGS) do
		local button = CreateFrame("Button", buttonName.."_BINDING", Binds)
		button.name = buttonName
		button.icon = "|T%s:24:24:0:0|t"
		button.texture = format(button.icon, db.TEXTURE[buttonName])
		button:SetPoint("TOPLEFT", Binds.Controller, "TOPLEFT", position.X, position.Y)
		button:SetSize(30, 30)
		button:SetScript("OnEnter", SetBindingTooltip)
		button:SetScript("OnClick", SetBindingFocus)
		button:SetScript("OnLeave", function(self) if GameTooltip:GetOwner() == self then GameTooltip:Hide() end end)
	end

	Binds.Rebind = CreateFrame("Frame", addOn.."RebindFrame", Binds)
	Binds.Rebind:SetPoint("BOTTOM", Binds, "BOTTOM", 0, 0)
	Binds.Rebind:SetSize(400, 180)
	Binds.Rebind:Hide()

	Binds.Rebind.SetButton = RebindSetButton
	Binds.Rebind.Parent = Binds
	Binds.Rebind:RegisterEvent("PLAYER_REGEN_DISABLED")
	Binds.Rebind:SetScript("OnEvent", Binds.Rebind.Hide)
	Binds.Rebind:SetScript("OnHide", function (self)
		Binds.Tutorial:SetText(TUTORIAL.DEFAULT)
		ConsolePort:SetRebinding()
		ConsolePort.rebindMode = nil
	end)
	Binds.Rebind:SetScript("OnShow", function (self)
		ConsolePort.rebindMode = true
	end)

	Binds.Rebind.Close = CreateFrame("Button", "$parentCloseButton", Binds.Rebind)
	Binds.Rebind.Close:SetNormalTexture("Interface\\Buttons\\UI-StopButton")
	Binds.Rebind.Close:SetScript("OnClick", function(self) self:GetParent():Hide() end)
	Binds.Rebind.Close:SetPoint("TOPRIGHT", Binds.Rebind, "TOPRIGHT", -4, 16)
	Binds.Rebind.Close:SetSize(16, 16)

	Binds.Rebind.BG = Binds.Rebind:CreateTexture(nil, "BACKGROUND")
	Binds.Rebind.BG:SetAllPoints(Binds.Rebind)
	Binds.Rebind.BG:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
	Binds.Rebind.BG:SetBlendMode("ADD")
	Binds.Rebind.BG:SetVertexColor(0.5, 0, 0, 0.25)

	Binds.Rebind.Static = CreateFrame("Frame", "$parentStatic", Binds.Rebind, "InsetFrameTemplate3")
	Binds.Rebind.Static.Parent = Binds.Rebind
	Binds.Rebind.Static:SetPoint("TOPLEFT", InterfaceOptionsFrame, "TOPRIGHT", 0, 0)
	Binds.Rebind.Static:SetPoint("BOTTOMLEFT", InterfaceOptionsFrame, "BOTTOMRIGHT", 0, 0)
	Binds.Rebind.Static:SetWidth(250)

	Binds.Rebind.Static.Headers = CreateFrame("Frame", "$parentHeaders", Binds.Rebind.Static)
	Binds.Rebind.Static.Headers.Buttons = {}
	Binds.Rebind.Static.Headers.Bindings = {}
	Binds.Rebind.Static.Headers:SetScript("OnShow", RefreshHeaderList)

	Binds.Rebind.Static.HeaderScroll = CreateFrame("ScrollFrame", "$parentHeaderScrollFrame", Binds.Rebind.Static, "UIPanelScrollFrameTemplate")
	Binds.Rebind.Static.HeaderScroll:SetPoint("TOPLEFT", Binds.Rebind.Static, "TOPLEFT", 8, -8)
	Binds.Rebind.Static.HeaderScroll:SetPoint("TOPRIGHT", Binds.Rebind.Static, "TOPRIGHT", -32, -8)
	Binds.Rebind.Static.HeaderScroll:SetScrollChild(Binds.Rebind.Static.Headers)

	Binds.Rebind.Static.HeaderWrap = CreateFrame("Frame", "$parentHeaderWrap", Binds.Rebind.Static, "InsetFrameTemplate3")
	Binds.Rebind.Static.HeaderWrap:SetAllPoints(Binds.Rebind.Static.HeaderScroll)

	Binds.Rebind.Static.Values = CreateFrame("Frame", "$parentValues", Binds.Rebind.Static)
	Binds.Rebind.Static.Values.Buttons = {}
	Binds.Rebind.Static.Headers.Values = Binds.Rebind.Static.Values

	Binds.Rebind.Static.ValueScroll = CreateFrame("ScrollFrame", "$parentValueScrollFrame", Binds.Rebind.Static, "UIPanelScrollFrameTemplate")
	Binds.Rebind.Static.ValueScroll:SetPoint("TOPLEFT", Binds.Rebind.Static.Headers, "BOTTOMLEFT", 0, -16)
	Binds.Rebind.Static.ValueScroll:SetPoint("BOTTOMRIGHT", Binds.Rebind.Static, "BOTTOMRIGHT", -32, 8)
	Binds.Rebind.Static.ValueScroll:SetScrollChild(Binds.Rebind.Static.Values)

	Binds.Rebind.Static.ValueWrap = CreateFrame("Frame", "$parentValueWrap", Binds.Rebind.Static, "InsetFrameTemplate3")
	Binds.Rebind.Static.ValueWrap:SetAllPoints(Binds.Rebind.Static.ValueScroll)

	self:AddFrame(addOn.."RebindFrame")
end})
