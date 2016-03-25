---------------------------------------------------------------
-- Binds.lua: Binding manager and functions related to bindings
---------------------------------------------------------------
-- Creates the faux binding manager and all things related
-- to bindings. Also includes hotkey texture management.
-- The system converts one static binding for each button
-- into four combinations (no mod, shift, ctrl, shift+ctrl)
-- which then run override bindings that perish on logout.
-- 
-- This system is somewhat nonsensical, because it's fundamental
-- to the addon's functionality, but constructed poorly due to
-- limited lua knowledge at the time of original conceptualization.

local _, db = ...
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
local NewUIBindingRefs

local FadeIn = db.UIFrameFadeIn
local FadeOut = db.UIFrameFadeOut

local pairsByKeys = db.Table.pairsByKeys
local Compare = db.Table.Compare
local Copy = db.Table.Copy

---------------------------------------------------------------
-- Binds: Get new binding sets and UI references
---------------------------------------------------------------
local function GetNewBindingSet(default)
	if default then
		NewBindingSet = ConsolePort:GetDefaultBindingSet()
	elseif not NewBindingSet then
		NewBindingSet = Copy(db.Bindings) or ConsolePort:GetDefaultBindingSet()
	end
	return NewBindingSet
end

local function GetNewUIBindingRefs(default)
	if default then
		NewUIBindingRefs = ConsolePort:GetDefaultUIBindingRefs()
	elseif not NewUIBindingRefs then
		NewUIBindingRefs = Copy(db.Bindbtns) or ConsolePort:GetDefaultUIBindingRefs()
	end
	return NewUIBindingRefs
end

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
-- Binds: Returns modifier extension for finding action button
---------------------------------------------------------------
local function GetBindingExtension(modifier)
	local modName = {
		action 		= "_NOMOD",
		shift 		= "_SHIFT",
		ctrl 		= "_CTRL",
		ctrlsh  	= "_CTRLSH"
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
-- Binds: Recursively gather all action buttons 
---------------------------------------------------------------
local function GetActionButtons(buttons, this)
	buttons = buttons or {}
	this = this or UIParent
	if this:IsForbidden() then
		return buttons
	end
	local action = this:GetAttribute("action")
	if action then
		buttons[this] = action
	end
	for _, object in pairs({this:GetChildren()}) do
		GetActionButtons(buttons, object)
	end
	return buttons
end

---------------------------------------------------------------
-- Binds: Reload, save and revert binds
---------------------------------------------------------------
local function ReloadBindings()
	ConsolePort:LoadInterfaceBindings()
	ConsolePort:LoadBindingSet()
	ConsolePort:LoadHotKeyTextures(NewBindingSet)
end

local function ExportCharacterSettings()
	local this = GetUnitName("player").."-"..GetRealmName()
	local class = select(2, UnitClass("player"))
	if 	not Compare(db.Bindings, ConsolePort:GetDefaultBindingSet()) or
		not Compare(db.Bindbtns, ConsolePort:GetDefaultUIBindingRefs()) then
		if not ConsolePortCharacterSettings then
			ConsolePortCharacterSettings = {}
		end
		ConsolePortCharacterSettings[this] = {
			BindingSet = db.Bindings,
			BindingBtn = db.Bindbtns,
			MouseEvent = db.Mouse.Events,
			Type = db.Settings.type,
			Class = class,
		}
	elseif ConsolePortCharacterSettings then
		ConsolePortCharacterSettings[this] = nil
	end
end

local function SubmitBindings()
	if 	NewBindingSet or NewUIBindingRefs then
		db.Bindings = NewBindingSet or db.Bindings
		db.Bindbtns = NewUIBindingRefs or db.Bindbtns
		ConsolePortBindingSet = db.Bindings
		ConsolePortBindingButtons = db.Bindbtns
		ReloadBindings()
		ExportCharacterSettings()
	end
end

local function RevertBindings()
	if 	NewUIBindingRefs or NewBindingSet then
		NewUIBindingRefs = nil
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
			FadeIn(AniFrame.dest.background, 1.5, 0.25, 1)
			db.UIFrameFlash(db.Binds.Controller.FlashGlow, 0.25, 0.25, 0.75, false, 0.25, 0)
		end)
	end
	local AniFrame = ConsolePortAnimationFrame
	local dX, dY = destination:GetCenter()
	local tX, tY = target:GetCenter()
	local targetIcon = target.icon or target.Icon
	local texture = targetIcon.IsObjectType and targetIcon:IsObjectType("Texture") and targetIcon:GetTexture() 
	AniFrame.texture:SetTexture(texture)
	AniFrame.dest = destination
	AniFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", tX,tY)
	AniFrame.animation:SetOffset((dX-tX), (dY-tY))
	AniFrame.group:Stop()
	AniFrame.group:Play()
end

---------------------------------------------------------------
-- Binds: Secure UI/Button binding changer
---------------------------------------------------------------
local function ClearButtonBinding(actionButton)
	local set = GetNewBindingSet()
	local name = actionButton.name
	local mod = GetBindingModifier(actionButton.mod)
	if set[name] and set[name][mod] then
		set[name][mod] = nil
	end
end

local function ChangeButtonBinding(actionButton)
	local buttonName 	= actionButton:GetName()
	local confButton 	= _G[buttonName..CONF]
	local tableIndex 	= actionButton.name
	local modifier 		= actionButton.mod
	local focusFrame 	= ConsolePort:GetCurrentNode()
	local focusFrameName = focusFrame:GetName()
	-- Rebind checkup
	if 	focusFrameName and focusFrame:IsObjectType("Button") then

		local isValid
		local swapIndex, swapMod, swapText

		local focusedBinding = focusFrame.StaticBinding

		isValid = focusedBinding ~= nil or focusFrame:GetParent() ~= ConsolePortRebindFrame

		if isValid then

			local set = GetNewBindingSet()
			local refs = GetNewUIBindingRefs()

			-- create sub tables if they don't exist (if controller was changed)
			if not set[tableIndex] then
				set[tableIndex] = {}
			end					
			if not refs[tableIndex] then
				refs[tableIndex] = {}
			end

			-----------------------

			local mod = GetBindingModifier(modifier)
			local currentButtonRef = set[tableIndex]
			local currentUIRef = refs[tableIndex]

			-- specific to the list of bindings
			if focusedBinding then
				local text = _G[BIND..focusedBinding] or focusedBinding
				-- check for duplicate bindings 
				for bindName, bindTable in pairs(set) do
					for bindMod, bindAction in pairs(bindTable) do
						if focusedBinding == bindAction then
							swapIndex = bindName
							swapMod = bindMod
							break
						end
					end
				end
				
				local swappedButton

				if swapIndex then
					if not set[swapIndex] then
						set[swapIndex] = {}
					end

					swappedButton = set[swapIndex]
					swappedButton[swapMod] = currentButtonRef[mod]

					swapText = confButton:GetText()
				end

				currentButtonRef[mod] = focusedBinding

				currentUIRef[mod] = nil
				actionButton.action = nil
				confButton:SetText(text)
				isValid = text
			else -- action buttons, interface buttons
				local newAction = focusFrame:GetAttribute("action") or focusFrame
				local actionBinding = ConsolePort:GetActionBinding(newAction or focusFrameName)

				-- item is an action button
				if actionBinding then 
					local text = _G[BIND..actionBinding] or focusFrameName

					-- check for duplicate bindings
					for bindName, bindTable in pairs(set) do
						for bindMod, bindAction in pairs(bindTable) do
							if actionBinding == bindAction then
								swapIndex = bindName
								swapMod = bindMod
								break
							end
						end
					end

					if swapIndex then
						set[swapIndex][swapMod] = currentButtonRef[mod]
						swapText = confButton:GetText()
					end

					currentButtonRef[mod] = actionBinding

					currentUIRef[mod] = nil
					actionButton.action = nil
					confButton:SetText(text)
					isValid = text

				else -- item is a non-action interface button

					currentButtonRef[mod] = "CLICK "..buttonName..":LeftButton"
					currentUIRef[mod] = focusFrameName

					confButton:SetText(focusFrameName)
					isValid = focusFrameName
				end

			end

			-- don't add swap info if the binding was swapped to itself
			if swapIndex and swapIndex == tableIndex and swapMod == mod then
				swapIndex = nil
				swapText = nil
			end

			AnimateBindingChange(focusFrame, confButton)
			ReloadBindings()
		end

		return isValid, swapIndex and swapIndex..GetBindingExtension(swapMod), swapText
	end
end

---------------------------------------------------------------
-- Binds: Static key binding table
---------------------------------------------------------------
local function CreateListButton(parent, num, clickScript, width, height)
	local button = db.Atlas.GetFutureButton("$parentButton"..num, parent, nil, nil, width, height)
	button:SetScript("OnClick", clickScript)
	tinsert(parent.Buttons, button)
	if num == 1 then
		button:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, 0)
		button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -16, 0)
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

local function BindHeaderSetValues(self)
	local bindings = self.Bindings
	local buttons = self.ValueList.Buttons
	for i, button in pairs(buttons) do
		button:Hide()
	end
	local vCount = 0
	for i, binding in pairs(bindings) do
		vCount = vCount + 1 
		local button = buttons[i] or CreateListButton(self.ValueList, vCount, BindValueOnClick, 200, 32)
		local font = button.Label
		if not binding.binding then
			button.Cover:Hide()
			button.Icon:Hide()
		else
			local texture = ConsolePort:GetActionTexture(binding.binding)
			if texture then
				button.Icon:SetTexture(texture)
				button.Icon:SetTexCoord(3/64, 61/64, 21/64, 26/64)
				button.Icon:ClearAllPoints()
				button.Icon:SetPoint("CENTER", button, "CENTER", 0, 0)
				button.Icon:SetSize(192, 24)
				button.Icon:SetAlpha(0.25)
				button.Icon:Show()
			else
				button.Icon:SetTexture(nil)
				button.Icon:Hide()
			end
			button.Cover:Show()
		end
		font:SetTextColor(binding.binding and 1, 1, 1, 1 or 1, 0, 1, 1)
		button:SetEnabled(binding.binding and true or false)
		button:SetText(binding.name)
		button:Show()
		button.StaticBinding = binding.binding
		FadeIn(button, vCount*0.05, 0, 1)
	end
	self.ValueList:SetHeight(vCount*32)
	self.ValueList:GetParent():SetHeight(vCount*(32+1)+8 <= 536 and vCount*(32+1)+8 or 536)
end

local function BindHeaderOnClick(self)
	local selected = self:GetParent().selected
	if  self ~= selected then
		if selected then
			selected.SelectedTexture:Hide()
		end
		self:GetParent().selected = self
		self.SelectedTexture:Show()
	elseif selected == self then
		self:GetParent().selected = nil
		self.SelectedTexture:Hide()
 	end
	BindHeaderSetValues(self)
end

local function BindHeaderOnEnter(self)
	if not self:GetParent().selected then
		BindHeaderSetValues(self)
	end
end

local function RefreshHeaderList(self)
	local buttons = self.Buttons
	local bindings = self.Bindings
	local category, name, binding, header
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
	bindings["ConsolePort "] = nil
	bindings[" |cFFFF6600"..TUTORIAL.MAINCATEGORY.."|r "] = ConsolePort:GetAddonBindings()
	local hCount = 0
	for i, button in pairs(buttons) do
		button:Hide()
	end
	for category, bindings in pairsByKeys(bindings) do
		hCount = hCount + 1
		local button = buttons[hCount] or CreateListButton(self, hCount, BindHeaderOnClick, 200, 32)
		button:SetScript("OnEnter", BindHeaderOnEnter)
		button:SetText(category)
		button:Show()
		button.Bindings = bindings
		button.ValueList = self.Values
		FadeIn(button, hCount*0.05, 0, 1)
	end
	self:SetHeight(hCount*32)
	self:GetParent():SetHeight(hCount*(32+1)+8 <= 536 and hCount*(32+1)+8 or 536)
end

---------------------------------------------------------------
-- Binds: Dynamic secure/UI button 
---------------------------------------------------------------
local function GetStaticBindingName(self)
	local set = NewBindingSet or db.Bindings
	local subSet = set and set[self.name]
	local modifier = GetBindingModifier(self.secure.mod)
	local binding = subSet and subSet[modifier]
	return binding and _G[BIND..binding]
end

local function GetStaticBinding(self)
	local subSet = db.Bindings[self.secure.name]
	return subSet and subSet[GetBindingModifier(self.secure.mod)]
end

local function DynamicConfigButtonOnShow(self)
	self.StaticBinding = GetStaticBinding(self)
	self.indicator:SetText(self.icon)
	self.SelectedTexture:Hide()
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
		self:SetText(TUTORIAL.NOTASSIGNED)
		self.background:SetTexture(nil)
	end
end

local function DynamicConfigButtonOnClick(self, mouseButton)
	local tutorial = db.Binds.Tutorial
	if not InCombatLockdown() then
		if not ConsolePortRebindFrame.isRebinding then
			if mouseButton == "RightButton" then
				ClearButtonBinding(self.secure)
				tutorial:SetText(format(TUTORIAL.UNASSIGN, self.indicator:GetText()))
			else
				self.SelectedTexture:Show()
				tutorial:SetText(format(TUTORIAL.REBIND, self.indicator:GetText()))
				ConsolePort:SetRebinding(self)
				ConsolePort:SetCurrentNode(self.secure.action)
			end
		else
			local stopRebind = true
			if mouseButton == "LeftButton" then
				local frame = ConsolePort:GetCurrentNode()
				local name = frame:GetName()
				if 	frame:GetParent() == ConsolePortRebindFrameHeaders then
					stopRebind = false
					BindHeaderOnClick(frame)
				else 
					local newBind, swapped, swapBind = ChangeButtonBinding(self.secure)
					if newBind and swapped then
						local swappedTexture = _G[swapped].HotKey
						if swappedTexture then
							if swapBind == TUTORIAL.NOTASSIGNED then
								tutorial:SetText(format(TUTORIAL.SWAPUNASSIGN, self.indicator:GetText(), newBind, swappedTexture))
							else
								tutorial:SetText(format(TUTORIAL.SWAPPED, self.indicator:GetText(), newBind, swappedTexture, swapBind))
							end
						else
							tutorial:SetText(format(TUTORIAL.APPLIED, self.indicator:GetText(), newBind))
						end
					elseif newBind then
						tutorial:SetText(format(TUTORIAL.APPLIED, self.indicator:GetText(), newBind))
					else
						tutorial:SetText(TUTORIAL.INVALID)
					end
				end
			else
				tutorial:SetText(TUTORIAL.COMBO)
			end
			if stopRebind then
				self.SelectedTexture:Hide()
				ConsolePort:SetRebinding(false)
				ConsolePort:SetCurrentNode(self)
				ConsolePort:SetButtonActionsUI()
				ConsolePort:UIControl()
			end
		end
		for _, button in pairs(db.Binds.Buttons[self.name]) do
			button:Hide()
			button:Show()
		end
	end
end
function ConsolePort:CreateConfigButton(name, mod, modNum)
	local button = db.Atlas.GetFutureButton(name..mod..CONF, db.Binds.Rebind)
	button.SelectedTexture:SetTexCoord(button.HighlightTexture:GetTexCoord())
	button:SetSize(440, 46)
	button:SetPoint("TOP", db.Binds.Rebind, "TOP", 0, -44*modNum-18)

	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	button.indicator = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.indicator:SetPoint("LEFT", button, "LEFT", 4, 0)

	button.background = button:CreateTexture(nil, "OVERLAY")
	button.background:SetPoint("RIGHT", button, "RIGHT", -32, 0)
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
local MouseOverrides = {
	["CP_TL3"] = "BUTTON1",
	["CP_TR3"] = "BUTTON2",
}

local function SetFauxBinding(self, modifier, original, override)
	if not InCombatLockdown() then
		if original and override then
			local key1, key2 = GetBindingKey(original) or MouseOverrides[original]
			if key1 then SetOverrideBinding(self, false, modifier..key1, override) end
			if key2 then SetOverrideBinding(self, false, modifier..key2, override) end
		end
	end
end

local function SetFauxMouseBindings(self, keys)
	local modifiers = {
		"SHIFT-", "CTRL-", "CTRL-SHIFT-",
	}
	local default = {
		["BUTTON1"] = "CAMERAORSELECTORMOVE",
		["BUTTON2"] = "TURNORACTION",
	}
	for stick, button in pairs(MouseOverrides) do
		if keys[stick] and keys[stick].action then
			for _, modifier in pairs(modifiers) do
				SetOverrideBinding(self, false, modifier..button, default[button])
			end
		end
	end
end

local function SetFauxMovementBindings(self)
	local movement = {
		MOVEFORWARD 	= {"W", "UP"},
		MOVEBACKWARD 	= {"S", "DOWN"},
		STRAFELEFT 		= {"A", "LEFT"},
		STRAFERIGHT 	= {"D", "RIGHT"},
	}
	local modifiers = {
		"", "SHIFT-", "CTRL-", "CTRL-SHIFT-",
	}
	if db.Settings.turnCharacter then
		movement.TURNLEFT = movement.STRAFELEFT
		movement.TURNRIGHT = movement.STRAFERIGHT
	end
	for direction, keys in pairsByKeys(movement) do
		for _, key in pairs(keys) do
			for _, modifier in pairs(modifiers) do
				SetOverrideBinding(self, false, modifier..key, direction)
			end
		end
	end
end

function ConsolePort:LoadBindingSet()
	if not InCombatLockdown() then
		local keys = NewBindingSet or db.Bindings
		local handler = ConsolePortButtonHandler
		ClearOverrideBindings(handler)
		SetFauxMovementBindings(handler)
		SetFauxMouseBindings(handler, keys)
		for name, key in pairs(keys) do
			SetFauxBinding(handler, "", 	name, key.action)
			SetFauxBinding(handler, "CTRL-", name, key.ctrl)
			SetFauxBinding(handler, "SHIFT-", name, key.shift)
			SetFauxBinding(handler, "CTRL-SHIFT-", name, key.ctrlsh)
		end
		self:RemoveUpdateSnippet(self.LoadBindingSet)
		return keys
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
		button:ShowInterfaceHotKey()
	else
		self:AddWidgetTracker(button, UIbutton)
	end
end

function ConsolePort:LoadInterfaceBindings()
	local buttons = NewUIBindingRefs or db.Bindbtns
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
	ConsolePort:SetCurrentNode(self.BindCatcher)
	FadeIn(self.Overlay, 1, 0, 1)
	self.Tutorial:SetText(TUTORIAL.DEFAULT)
	self.Rebind:Hide()
end

local function BindingsOnEvent(self, event)
	if event == "PLAYER_REGEN_DISABLED" then
		self.Rebind:Hide()
		self.Tutorial:SetText(TUTORIAL.COMBATTEXT)
	elseif event == "PLAYER_REGEN_ENABLED" then
		self.Tutorial:SetText(TUTORIAL.DEFAULT)
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
	for i, button in pairs(buttons) do
		button:Hide()
	end

	local profiles = Copy(ConsolePortCharacterSettings)
	self.ProfileData = profiles

	for name, data in pairs(db.Controllers) do
		profiles["|cFFFFFFFF"..name.."|r"..TUTORIAL.PROFILEPRESET] = {
			Type = name,
			BindingSet = data.Bindings, 
			BindingBtn = ConsolePort:GetDefaultUIBindingRefs(),
			Preset = true,
		}
	end

	for character, settings in pairsByKeys(profiles) do
		pCount = pCount + 1
		local button = buttons[pCount] or CreateListButton(self, pCount, ProfileOnSelect)
		button:SetText(character)
		button:Show()
		if settings.Class then
			local cc = RAID_CLASS_COLORS[settings.Class]
			button.Cover:SetVertexColor(cc.r, cc.g, cc.b, 1)
		elseif settings.Preset then
			button.Cover:SetAlpha(0.25)
		else
			button.Cover:SetVertexColor(1, 1, 1, 1)
		end
		if settings.Type and db.Controllers[settings.Type] then
			button.Controller = button:CreateTexture(nil, "OVERLAY")
			button.Controller:SetSize(32, 32)
			button.Controller:SetPoint("LEFT", button, "LEFT", 12, 0)
			button.Controller:SetTexture("Interface\\AddOns\\ConsolePort\\Controllers\\"..settings.Type.."\\Icons64x64\\CP_C_OPTION")
		end
		button.Popup = popup
		button.name = character
		FadeIn(button, pCount*0.1, 0, 1)
	end
	self:SetHeight(pCount*46+8)
	self:GetParent():SetHeight(pCount*(46+1)+8 <= maxHeight and pCount*(46+1)+8 or maxHeight)
	popup:SetSelection(nil)
end

local function ImportOnClick(self)
	if not InCombatLockdown() then
		local character = ConsolePortPopup:GetSelection()
		local settings = db.Binds.Import.Profiles.ProfileData[character]
		if settings then
			db.Binds.Tutorial:SetText(format(TUTORIAL.IMPORT, character))
			NewBindingSet = Copy(settings.BindingSet)
			NewUIBindingRefs = Copy(settings.BindingBtn)
			ReloadBindings()
			ConsolePort:SetButtonActionsUI()
			for _, Button in pairs(db.Binds.Overlay.Buttons) do
				Button:Hide()
				Button:Show()
			end
		end
	else
		db.Binds.Tutorial:SetText(TUTORIAL.COMBAT)
	end
end

local function RemoveOnClick(self)
	local selected = ConsolePortPopup:GetSelection()
	if ConsolePortCharacterSettings and selected then
		ConsolePortCharacterSettings[selected] = nil
	end
	RefreshProfileList(db.Binds.Import.Profiles)
end

---------------------------------------------------------------
-- Binds: Binding buttons and tooltip
---------------------------------------------------------------
local function ClearBindingTooltip(self)
	local tooltip = ConsolePortConfig.Tooltip
	if tooltip:GetOwner() == self then
		tooltip:Hide()
	end
end

local function GetBindingText(self, secure, static, modifier)

	local id = static and ConsolePort:GetActionID(static)

	if secure and secure.action then
		if secure.action.icon and secure.action.icon:GetTexture() then
			return format(self.icon, secure.action.icon:GetTexture())
		elseif secure.action:GetName() then
			return secure.action:GetName()
		end
	elseif id then
		local actionpage = MainMenuBarArtFrame:GetAttribute("actionpage")

		id = id <= 24 and id + (actionpage - 1) * 12 or id

		local texture = GetActionTexture(id)
		local binding = _G[BIND..static]

		local actionType, actionID, subType, spellID = GetActionInfo(id)

		local name
		if actionType == "spell" and actionID then
			name = GetSpellInfo(actionID) or TUTORIAL.SPELL
		elseif actionType == "item" and actionID then
			name = GetItemInfo(actionID) or TUTORIAL.ITEM
		elseif actionType == "macro" then
			name = GetActionText(id)..TUTORIAL.MACRO
		elseif actionType == "companion" then
			name = TUTORIAL[subType]
		elseif actionType == "summonmount" then
			name = TUTORIAL.MOUNT
		elseif actionType == "equipmentset" then
			name = actionID..TUTORIAL.EQSET
		end

		name = name and binding and name.."\n|cFF575757"..binding

		if name then
			return name, texture
		elseif texture then
			local header

			if static and _G[BIND..static] then
				header = _G[self:GetParent().Bindings[static]]
				header = header and _G[BIND..static].."\n|cFF575757"..header or _G[BIND..static]
			end

			return header, texture
		else
			local header = _G[self:GetParent().Bindings[static]]
			return header and _G[BIND..static].."\n|cFF575757"..header or _G[BIND..static]
		end
	elseif static and _G[BIND..static] then
		local header = _G[self:GetParent().Bindings[static]]
		return header and _G[BIND..static].."\n|cFF575757"..header or _G[BIND..static]
	else
		return self.Default or TUTORIAL.NOTASSIGNED
	end
end

local function SetBindingTooltip(self)
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
			{	extension = NOMOD, mod = "",
				icons = self.texture,
			},
			{	extension = SHIFT, mod = "SHIFT-",
				icons = format(self.icon, db.TEXTURE.CP_TL1)..self.texture,
			},
			{	extension = CTRL, mod = "CTRL-",
				icons = format(self.icon, db.TEXTURE.CP_TL2)..self.texture,
			},
			{	extension = CTRLSH, mod = "CTRL-SHIFT-",
				icons = format(self.icon, db.TEXTURE.CP_TL1)..format(self.icon, db.TEXTURE.CP_TL2)..self.texture,
			},
		}
	end
	local indices = { "action", "shift", "ctrl", "ctrlsh" }
	for i, binding in pairs(self.bindings) do
		local staticIndex = indices[i]
		local static
		if NewBindingSet then
			static = NewBindingSet[self.name] and NewBindingSet[self.name][staticIndex]
		else
			static = db.Bindings[self.name] and db.Bindings[self.name][staticIndex]
		end
		local text, icon = GetBindingText(self, _G[self.name..binding.extension], static, binding.mod)
		local _, newLines = gsub(text or "", "\n", "")
		newLines = strrep("\n", 2 - newLines)
		local tooltipText = (icon and text) and format(self.icon, icon).." "..text or text and text..newLines or icon and format(self.icon, icon)
		tooltip:AddDoubleLine(tooltipText, binding.icons, 1,1,1,1,1,1)
	end
	tooltip:AddLine(TUTORIAL.TOOLTIPCLICK)
	tooltip:Show()
end

local function OverlayBindingModifierChanged(self)
	self:Hide()
	self:Show()
end

local function ShowOverlayBinding(self)
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	self:RegisterEvent("MODIFIER_STATE_CHANGED")
	self:SetScript("OnEvent", OverlayBindingModifierChanged)
	local shift = IsShiftKeyDown()
	local ctrl = IsControlKeyDown()
	local extension = (ctrl and shift) and CTRLSH or ctrl and CTRL or shift and SHIFT or NOMOD
	local staticIndex = (ctrl and shift) and "ctrlsh" or ctrl and "ctrl" or shift and "shift" or "action"
	local secure = _G[self.name..extension]
	local static
	if NewBindingSet then
		static = NewBindingSet[self.name] and NewBindingSet[self.name][staticIndex]
	else
		static = db.Bindings[self.name] and db.Bindings[self.name][staticIndex]
	end
	local text, icon = GetBindingText(self, secure, static)
	if text and icon then
		self.Mask:Show()
		self.Text:SetText(text)
		SetPortraitToTexture(self.Icon, icon)
	elseif icon then
		self.Mask:Show()
		self.Text:SetText()
		SetPortraitToTexture(self.Icon, icon)
	elseif text then
		self.Mask:Hide()
		self.Icon:SetTexture()
		self.Text:SetText(text)
	end
end

local function HideOverlayBinding(self)
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")
	self:SetScript("OnEvent", nil)
end

local function SetBindingFocus(self)
	local parent = self:GetParent():GetParent()
	ConsolePortConfig.Tooltip:Hide()
	ConsolePortCursor:Hide()
	parent.Tutorial:SetAlpha(0)
	parent.Controller:SetConfigMode(self)
end

local function RebindSetButton(self, button)
	self.button = button
	local allButtons = self:GetParent():GetParent().Buttons
	local rebindButtons = allButtons[button.name]
	local bindings = button.bindings
	self.Parent.Tutorial:SetText(TUTORIAL.COMBO)
	self.rebindButtons = rebindButtons
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
-- Binds: Bind catcher
---------------------------------------------------------------
local function BindCatcherOnKey(self, key)
	local action = key and GetBindingAction(key) and _G[GetBindingAction(key).."_BINDING"]
	FadeIn(ConsolePortCursor, 0.2, ConsolePortCursor:GetAlpha(), 1)
	self:SetScript("OnKeyUp", nil)
	self:EnableKeyboard(false)
	if action then
		self:GetScript("OnHide")(self)
		SetBindingTooltip(action)
		ClearBindingTooltip(action)
		action:Click()
	elseif not db.Binds.Rebind:IsVisible() and key then
		db.Binds.Tutorial:SetText(TUTORIAL.DEFAULT)
	end
end

local function BindCatcherOnClick(self)
	self:EnableKeyboard(true)
	self:SetScript("OnKeyUp", BindCatcherOnKey)
	FadeOut(ConsolePortCursor, 0.2, ConsolePortCursor:GetAlpha(), 0)
	db.Binds.Tutorial:SetText(TUTORIAL.CATCHER)
end

local function BindCatcherOnHide(self)
	BindCatcherOnKey(self)
	FadeOut(self, 0.2, self:GetAlpha(), 0)
end

local function BindCatcherOnShow(self)
	FadeIn(self, 0.2, self:GetAlpha(), 1)
end

---------------------------------------------------------------
-- Binds: Default function
---------------------------------------------------------------
local function LoadDefaultBinds(self)
	self.Tutorial:SetText(TUTORIAL.RESET)
	GetNewBindingSet(true)
	GetNewUIBindingRefs(true)
	for _, button in pairs(self.Overlay.Buttons) do
		ShowOverlayBinding(button)
	end
	if not InCombatLockdown() then
		ReloadBindings()
	end
end

tinsert(db.PANELS, {"Binds", TUTORIAL.HEADER, false, SubmitBindings, RevertBindings, LoadDefaultBinds, function(self, Binds)
	local settings = db.Settings
	local player = GetUnitName("player").."-"..GetRealmName()
	local cc = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

	Binds.Controller = CreateFrame("Frame", "$parentController", Binds)
	Binds.Controller:SetPoint("CENTER", 0, 0)
	Binds.Controller:SetSize(512, 512)

	Binds.Controller.Group = Binds.Controller:CreateAnimationGroup()
	Binds.Controller.Group:SetScript("OnFinished", Binds.Controller.OnFinished)
	Binds.Controller.Animation = Binds.Controller.Group:CreateAnimation("Translation")
	Binds.Controller.Animation:SetSmoothing("OUT")
	Binds.Controller.Animation:SetDuration(0.2)
	Binds.Controller.Group:SetScript("OnFinished", function()
		Binds.Controller:SetPoint("CENTER", Binds.Controller.offset < 0 and Binds.Controller.offset or 0, 0)
		local rebindFocus = Binds.Controller.rebindFocus
		if rebindFocus then
			Binds.Rebind:SetButton(rebindFocus)
			ConsolePort:SetCurrentNode(Binds.Buttons[rebindFocus.name][1])
		end
	end)

	function Binds.Controller:SetConfigMode(newFocus)
		local dontAnimate
		local pos = self:GetCenter()
		local origin = self:GetParent():GetCenter()
		local overlay = self:GetParent().Overlay
		if newFocus and self.rebindFocus then
			dontAnimate = true
		end
		if newFocus then
			overlay:Hide()
		else
			FadeIn(overlay, 1, 0, 1)
			overlay:Show()
		end
		self.rebindFocus = newFocus
		self.offset = newFocus and -240 or abs(pos-origin)
		self.Animation:SetOffset(not dontAnimate and self.offset or 0, 0)
		self.Group:Play()
	end

	Binds.Controller.Texture = Binds.Controller:CreateTexture("$parentTexture", "ARTWORK")
	Binds.Controller.Texture:SetTexture("Interface\\AddOns\\ConsolePort\\Controllers\\"..settings.type.."\\Front")
	Binds.Controller.Texture:SetAllPoints(Binds.Controller)

	Binds.Controller.FlashGlow = Binds.Controller:CreateTexture("$parentGlow", "OVERLAY")
	Binds.Controller.FlashGlow:SetTexture("Interface\\AddOns\\ConsolePort\\Controllers\\"..settings.type.."\\FrontHighlight")
	Binds.Controller.FlashGlow:SetAllPoints(Binds.Controller)
	Binds.Controller.FlashGlow:SetAlpha(0)
	Binds.Controller.FlashGlow:SetVertexColor(cc.r, cc.g, cc.b)

	Binds.Overlay = CreateFrame("Frame", "$parentOverlay", Binds)
	Binds.Overlay:SetPoint("CENTER", 0, 0)
	Binds.Overlay:SetSize(1024, 512)
	Binds.Overlay.Lines = Binds.Overlay:CreateTexture("$parentLines", "OVERLAY", nil, 7)
	Binds.Overlay.Lines:SetTexture("Interface\\AddOns\\ConsolePort\\Controllers\\"..settings.type.."\\Overlay")
	Binds.Overlay.Lines:SetAllPoints(Binds.Overlay)
	Binds.Overlay.Lines:SetVertexColor(cc.r * 1.25, cc.g * 1.25, cc.b * 1.25, 0.75)

	Binds.Overlay.Bindings = {}
	Binds.Overlay.Buttons = {}

	local bindingCache = Binds.Overlay.Bindings
	for i=1, GetNumBindings() do
		local name, header = GetBinding(i)
		bindingCache[name] = header
	end

	Binds.Tutorial = Binds.Controller:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Binds.Tutorial:SetPoint("TOP", Binds.Controller, 0, -40)
	Binds.Tutorial.SetNewText = Binds.Tutorial.SetText

	function Binds.Tutorial:SetText(...)
		if InCombatLockdown() then
			self:SetNewText(TUTORIAL.COMBATTEXT)
		else
			self:SetNewText(...)
		end
		FadeIn(self, 1, 0, 1)
	end

	Binds:HookScript("OnEvent", BindingsOnEvent)
	Binds:HookScript("OnShow", BindingsOnShow)

	Binds:RegisterEvent("PLAYER_REGEN_ENABLED")
	Binds:RegisterEvent("PLAYER_REGEN_DISABLED")

	Binds.BindCatcher = db.Atlas.GetFutureButton("$parentBindCatcher", Binds, nil, nil, 350)
	Binds.BindCatcher.HighlightTexture:ClearAllPoints()
	Binds.BindCatcher.HighlightTexture:SetPoint("TOP", Binds.BindCatcher, "TOP")
	Binds.BindCatcher:SetHeight(64)
	Binds.BindCatcher:SetPoint("TOP", 0, -68)
	Binds.BindCatcher:SetScript("OnClick", BindCatcherOnClick)
	Binds.BindCatcher:SetScript("OnHide", BindCatcherOnHide)
	Binds.BindCatcher:SetScript("OnShow", BindCatcherOnShow)
	Binds.BindCatcher.Cover:Hide()
	Binds.BindCatcher.hasPriority = true

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

	Binds.Import.Profiles = CreateFrame("Frame", "$parentProfiles", Binds.Import)
	Binds.Import.Profiles:SetWidth(350)
	Binds.Import.Profiles.Buttons = {}
	Binds.Import.Profiles:SetScript("OnShow", RefreshProfileList)

	Binds.Import.ProfileScroll = CreateFrame("ScrollFrame", "$parentProfileScrollFrame", Binds.Import, "UIPanelScrollFrameTemplate")
	Binds.Import.ProfileScroll:SetScrollChild(Binds.Import.Profiles)
	Binds.Import.ProfileScroll:Hide()

	Binds.Import.ProfileScroll.ScrollBar.scrollStep = 32
	Binds.Import.ProfileScroll.ScrollBar:ClearAllPoints()
	Binds.Import.ProfileScroll.ScrollBar:SetPoint("TOPLEFT", Binds.Import.ProfileScroll, "TOPRIGHT", -28, -16)
	Binds.Import.ProfileScroll.ScrollBar:SetPoint("BOTTOMLEFT", Binds.Import.ProfileScroll, "BOTTOMRIGHT", -28, 16)
	Binds.Import.ProfileScroll.ScrollBar.Thumb = Binds.Import.ProfileScroll.ScrollBar:GetThumbTexture()
	Binds.Import.ProfileScroll.ScrollBar.Thumb:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Thumb")
	Binds.Import.ProfileScroll.ScrollBar.Thumb:SetTexCoord(0, 1, 0, 1)
	Binds.Import.ProfileScroll.ScrollBar.Thumb:SetSize(18, 34)
	Binds.Import.ProfileScroll.ScrollBar.ScrollUpButton:SetAlpha(0)
	Binds.Import.ProfileScroll.ScrollBar.ScrollDownButton:SetAlpha(0)

	Binds.Buttons = {}

	local staticBindings = {
		["CP_TL3"] = TUTORIAL.LEFTCLICK,
		["CP_TR3"] = TUTORIAL.RIGHTCLICK,
		[settings.ctrl] = TUTORIAL.CTRL,
		[settings.shift] = TUTORIAL.SHIFT,
	}

	local triggers = {
		[settings.trigger1] = "CP_TR1",
		[settings.trigger2] = "CP_TR2",
	}

	local iconPath = "Interface\\AddOns\\ConsolePort\\Controllers\\"..settings.type.."\\Icons64x64\\"
	for buttonName, info in pairs(db.BindLayout) do
		if not (settings.skipGuideBtn and buttonName == "CP_C_OPTION") then
			local button = CreateFrame("Button", buttonName.."_BINDING", Binds.Overlay)
			local texture = iconPath..buttonName
			--
			button.anchor = info.anchor
			button.icon = "|T%s:32:32:0:0|t"
			button.texture = format(button.icon, texture)
			--
			button:SetSize(30, 30)
			button.BG = button:CreateTexture(nil, "OVERLAY")
			button.BG:SetAllPoints(button)
			button.BG:SetTexture(texture)
			button.Text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			button.Text:SetSpacing(2)
			button.Text:SetWordWrap(true)
			button.Text:SetWidth(180)
			button.Text:SetTextHeight(11)
			button.Text:SetJustifyH(info.anchor)
			button.Icon = button:CreateTexture(nil, "ARTWORK")
			button.Icon:SetSize(30, 30)
			button.Mask = button:CreateTexture(nil, "OVERLAY", nil, 7)
			button.Mask:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\IconMask")
			button.Mask:SetPoint("CENTER", button.Icon, "CENTER", 0, 0)
			button.Mask:SetSize(32, 32)
			button.Mask:Hide()
			if info.anchor == "LEFT" then
				button.Text:SetPoint("LEFT", button, "RIGHT", 4, 0)
				button.Icon:SetPoint("RIGHT", button, "LEFT", -4, 0)
				button:SetPoint("TOP", -400, (info.index - 1) * -48 - 80)
				button:SetHitRectInsets(0, -180,  0, 0)
			elseif info.anchor == "RIGHT" then
				button.Text:SetPoint("RIGHT", button, "LEFT", -4, 0)
				button.Icon:SetPoint("LEFT", button, "RIGHT", 4, 0)
				button:SetPoint("TOP", 400, (info.index - 1) * -48 - 80)
				button:SetHitRectInsets(-180, 0,  0, 0)
			elseif info.anchor == "CENTER" then
				button.Text:SetPoint("TOP", button, "BOTTOM", 0, -12)
				button.Icon:SetPoint("BOTTOM", button, "TOP", 0, 4)
				button:SetPoint("CENTER", 0, info.index * -48 - 80)
			end
			--
			if staticBindings[buttonName] then
				button.Default = "|cFF757575"..staticBindings[buttonName].."|r"
				button.Text:SetText(button.Default)
				button.Text:SetPoint(info.anchor, info.anchor == "LEFT" and 36 or -36, 0)
			end

			if not staticBindings[buttonName] or MouseOverrides[buttonName] then
				button.name = triggers[buttonName] or buttonName
				--
				button:SetScript("OnShow", ShowOverlayBinding)
				button:SetScript("OnHide", HideOverlayBinding)
				button:SetScript("OnEnter", SetBindingTooltip)
				button:SetScript("OnClick", SetBindingFocus)
				button:SetScript("OnLeave", ClearBindingTooltip)
				tinsert(Binds.Overlay.Buttons, button)
			end
		end
	end

	db.ButtonCoords = nil

	Binds.Rebind = db.Atlas.GetGlassWindow("ConsolePortRebindFrame", Binds.Controller, nil, true, "LFGListCategoryTemplate")
	Binds.Rebind:SetBackdrop(db.Atlas.Backdrops.Border)
	Binds.Rebind:SetPoint("BOTTOMLEFT", Binds, "BOTTOMLEFT", 16, 16)
	Binds.Rebind:SetSize(476, 216)
	Binds.Rebind:Hide()

	Binds.Rebind.SetButton = RebindSetButton
	Binds.Rebind.Parent = Binds
	Binds.Rebind:SetScript("OnHide", function (self)
		Binds.BindCatcher:Show()
		Binds.Tutorial:SetText(TUTORIAL.DEFAULT)
		Binds.Controller:SetConfigMode()
		ConsolePort:SetRebinding()
		ConsolePort.rebindMode = nil
		if not InCombatLockdown() then
			ConsolePort:ClearCurrentNode()
			if GetCVar("alwaysShowActionBars") == "0" then
				for frame, action in pairs(GetActionButtons()) do
					if not GetActionInfo(action) and frame.forceShow then
						frame.forceShow = nil
						frame:Hide()
					end
				end
			end
		end
	end)
	Binds.Rebind:SetScript("OnShow", function (self)
		if InCombatLockdown() then
			self:Hide()
			return
		end
		for frame in pairs(GetActionButtons()) do
			if not frame:IsVisible() then
				frame.forceShow = true
				frame:Show()
			end
		end
		Binds.BindCatcher:Hide()
		ConsolePort.rebindMode = true
	end)

	Binds.Rebind.Close:ClearAllPoints()
	Binds.Rebind.Close:SetSize(300, 46)
	Binds.Rebind.Close:SetPoint("BOTTOM", Binds.Rebind, "TOP", 0, -12)
	Binds.Rebind.Close.Icon:Hide()
	Binds.Rebind.Close.Texture:Hide()
	Binds.Rebind.Close.Texture:ClearAllPoints()
	Binds.Rebind.Close.Label:SetJustifyH("CENTER")
	Binds.Rebind.Close.Label:ClearAllPoints()
	Binds.Rebind.Close.Label:SetPoint("CENTER", 0, 0)
	Binds.Rebind.Close:SetText(TUTORIAL.RETURN)
	Binds.Rebind.Close:HookScript("OnClick", function(self)
		ConsolePort:SetCurrentNode(Binds.BindCatcher)
	end)

	Binds.Rebind.Backdrop1 = CreateFrame("Frame", "$parentBackdrop1", Binds.Rebind)
	Binds.Rebind.Backdrop1:SetBackdrop(db.Atlas.Backdrops.Border)
	Binds.Rebind.Backdrop1:SetPoint("TOPLEFT", Binds, "TOP", -16, -8)
	Binds.Rebind.Backdrop1:SetPoint("BOTTOMLEFT", Binds, "BOTTOM", 16, 8)
	Binds.Rebind.Backdrop1:SetWidth(262)

	Binds.Rebind.Backdrop2 = CreateFrame("Frame", "$parentBackdrop2", Binds.Rebind)
	Binds.Rebind.Backdrop2:SetBackdrop(db.Atlas.Backdrops.Border)
	Binds.Rebind.Backdrop2:SetPoint("TOPLEFT", Binds.Rebind.Backdrop1, "TOPRIGHT", -24, 0)
	Binds.Rebind.Backdrop2:SetPoint("BOTTOMLEFT", Binds.Rebind.Backdrop1, "BOTTOMRIGHT", -8, 0)
	Binds.Rebind.Backdrop2:SetWidth(262)

	Binds.Rebind.Headers = CreateFrame("Frame", "$parentHeaders", Binds.Rebind)
	Binds.Rebind.Headers:SetWidth(232)
	Binds.Rebind.Headers.Buttons = {}
	Binds.Rebind.Headers.Bindings = {}
	Binds.Rebind.Headers:SetScript("OnShow", RefreshHeaderList)

	Binds.Rebind.HeaderScroll = CreateFrame("ScrollFrame", "$parentHeaderScrollFrame", Binds.Rebind, "UIPanelScrollFrameTemplate")
	Binds.Rebind.HeaderScroll:SetPoint("BOTTOMLEFT", Binds, "BOTTOM", -8, 24)
	Binds.Rebind.HeaderScroll:SetSize(246, 300)
	Binds.Rebind.HeaderScroll:SetScrollChild(Binds.Rebind.Headers)

	Binds.Rebind.Headers:ClearAllPoints()
	Binds.Rebind.Headers:SetPoint("TOPLEFT", Binds.Rebind.HeaderScroll, "TOPLEFT", 0, -16)

	Binds.Rebind.HeaderScroll.ScrollBar.scrollStep = 32
	Binds.Rebind.HeaderScroll.ScrollBar:ClearAllPoints()
	Binds.Rebind.HeaderScroll.ScrollBar:SetPoint("TOPLEFT", Binds.Rebind.Backdrop1, "TOPRIGHT", -36, -16)
	Binds.Rebind.HeaderScroll.ScrollBar:SetPoint("BOTTOMLEFT", Binds.Rebind.Backdrop1, "BOTTOMRIGHT", -36, 16)
	Binds.Rebind.HeaderScroll.ScrollBar.Thumb = Binds.Rebind.HeaderScroll.ScrollBar:GetThumbTexture()
	Binds.Rebind.HeaderScroll.ScrollBar.Thumb:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Thumb")
	Binds.Rebind.HeaderScroll.ScrollBar.Thumb:SetTexCoord(0, 1, 0, 1)
	Binds.Rebind.HeaderScroll.ScrollBar.Thumb:SetSize(18, 34)
	Binds.Rebind.HeaderScroll.ScrollBar.ScrollUpButton:SetAlpha(0)
	Binds.Rebind.HeaderScroll.ScrollBar.ScrollDownButton:SetAlpha(0)

	Binds.Rebind.Values = CreateFrame("Frame", "$parentValues", Binds.Rebind)
	Binds.Rebind.Values:SetWidth(232)
	Binds.Rebind.Values.Buttons = {}
	Binds.Rebind.Headers.Values = Binds.Rebind.Values

	Binds.Rebind.ValueScroll = CreateFrame("ScrollFrame", "$parentValueScrollFrame", Binds.Rebind, "UIPanelScrollFrameTemplate")
	Binds.Rebind.ValueScroll:SetPoint("BOTTOMRIGHT", Binds, "BOTTOMRIGHT", -8, 24)
	Binds.Rebind.ValueScroll:SetWidth(254)
	Binds.Rebind.ValueScroll:SetScrollChild(Binds.Rebind.Values)

	Binds.Rebind.Values:ClearAllPoints()
	Binds.Rebind.Values:SetPoint("TOPLEFT", Binds.Rebind.ValueScroll, "TOPLEFT", 0, -16)

	Binds.Rebind.ValueScroll.ScrollBar.scrollStep = 32
	Binds.Rebind.ValueScroll.ScrollBar:ClearAllPoints()
	Binds.Rebind.ValueScroll.ScrollBar:SetPoint("TOPLEFT", Binds.Rebind.Backdrop2, "TOPRIGHT", -36, -16)
	Binds.Rebind.ValueScroll.ScrollBar:SetPoint("BOTTOMLEFT", Binds.Rebind.Backdrop2, "BOTTOMRIGHT", -36, 16)
	Binds.Rebind.ValueScroll.ScrollBar.Thumb = Binds.Rebind.ValueScroll.ScrollBar:GetThumbTexture()
	Binds.Rebind.ValueScroll.ScrollBar.Thumb:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Thumb")
	Binds.Rebind.ValueScroll.ScrollBar.Thumb:SetTexCoord(0, 1, 0, 1)
	Binds.Rebind.ValueScroll.ScrollBar.Thumb:SetSize(18, 34)
	Binds.Rebind.ValueScroll.ScrollBar.ScrollUpButton:SetAlpha(0)
	Binds.Rebind.ValueScroll.ScrollBar.ScrollDownButton:SetAlpha(0)

	self:AddFrame("ConsolePortRebindFrame")
end})
