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

local FadeIn = db.UIFrameFadeIn
local FadeOut = db.UIFrameFadeOut

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
	if this:GetAttribute("action") or this.action then
		buttons[this] = this:GetAttribute("action") or this.action 
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
		not Compare(db.Bindbtns, ConsolePort:GetDefaultBindingButtons()) then
		if not ConsolePortCharacterSettings then
			ConsolePortCharacterSettings = {}
		end
		if not ConsolePortCharacterSettings[this] then
			ConsolePortCharacterSettings[this] = {}
		end
		ConsolePortCharacterSettings[this] = {
			BindingSet = db.Bindings,
			BindingBtn = db.Bindbtns,
			MouseEvent = db.Mouse.Events,
			Class = class,
		}
	elseif ConsolePortCharacterSettings then
		ConsolePortCharacterSettings[this] = nil
	end
end

local function SubmitBindings()
	if 	NewBindingSet or NewBindingButtons then
		db.Bindings = NewBindingSet or db.Bindings
		db.Bindbtns = NewBindingButtons or db.Bindbtns
		ConsolePortBindingSet = db.Bindings
		ConsolePortBindingButtons = db.Bindbtns
		ReloadBindings()
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
			FadeIn(AniFrame.dest.background, 1.5, 0.25, 1)
			db.UIFrameFlash(db.Binds.Controller.FlashGlow, 0.25, 0.25, 0.75, false, 0.25, 0)
		end)
	end
	local AniFrame = ConsolePortAnimationFrame
	local dX, dY = destination:GetCenter()
	local tX, tY = target:GetCenter()
	AniFrame.texture:SetTexture(target.icon and target.icon:GetTexture() or target.Icon and target.Icon:GetTexture())
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
		local swapIndex, swapMod, swapText

		if focusFrame.Binding then
			isStatic = true
			isValid = true
		elseif focusFrame:GetParent() ~= ConsolePortRebindFrame then
			isStatic = false
			isValid = true
		end

		if isValid then
			if not NewBindingSet then
				NewBindingSet = Copy(db.Bindings)
			end
			if not NewBindingButtons then
				NewBindingButtons = Copy(db.Bindbtns)
			end

			local mod = GetBindingModifier(modifier)

			-- specific to the list of bindings
			if isStatic then
				local text = _G[BIND..focusFrame.Binding] or focusFrame.Binding
				-- check for duplicate bindings 
				for bindName, bindTable in pairs(NewBindingSet) do
					for bindMod, bindAction in pairs(bindTable) do
						if focusFrame.Binding == bindAction then
							swapIndex = bindName
							swapMod = bindMod
							break
						end
					end
				end
				if swapIndex then
					NewBindingSet[swapIndex][swapMod] = NewBindingSet[tableIndex][mod]
					swapText = confButton:GetText()
				end
				NewBindingSet[tableIndex][mod] = focusFrame.Binding
				NewBindingButtons[tableIndex][mod] = nil
				actionButton.action = nil
				confButton:SetText(text)
				isValid = text
			else -- action buttons, interface buttons
				local newAction = focusFrame:GetAttribute("action") or focusFrame.action or focusFrame

				local actionBinding = ConsolePort:GetActionBinding(newAction or focusFrameName)
				if actionBinding then -- item is an action button
					local text = _G[BIND..actionBinding] or focusFrameName
					-- check for duplicate bindings
					for bindName, bindTable in pairs(NewBindingSet) do
						for bindMod, bindAction in pairs(bindTable) do
							if actionBinding == bindAction then
								swapIndex = bindName
								swapMod = bindMod
								break
							end
						end
					end
					if swapIndex then
						NewBindingSet[swapIndex][swapMod] = NewBindingSet[tableIndex][mod]
						swapText = confButton:GetText()
					end
					NewBindingSet[tableIndex][mod] = actionBinding
					NewBindingButtons[tableIndex][mod] = nil
					actionButton.action = nil
					confButton:SetText(text)
					isValid = text
				else -- item is a non-action interface button
					NewBindingSet[tableIndex][mod] = "CLICK "..buttonName..":LeftButton"
					NewBindingButtons[tableIndex][mod] = focusFrameName
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
		button:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
		button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
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
		button.Binding = binding.binding
		FadeIn(button, vCount*0.05, 0, 1)
	end
	self.ValueList:SetHeight(vCount*32+8)
	self.ValueList:GetParent():SetHeight(vCount*(32+1)+8 <= 552 and vCount*(32+1)+8 or 552)
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
	for i, button in pairs(buttons) do
		button:Hide()
	end
	for category, bindings in db.pairsByKeys(bindings) do
		hCount = hCount + 1
		local button = buttons[hCount] or CreateListButton(self, hCount, BindHeaderOnClick, 200, 32)
		button:SetScript("OnEnter", BindHeaderOnEnter)
		button:SetText(category)
		button:Show()
		button.Bindings = bindings
		button.ValueList = self.Values
		FadeIn(button, hCount*0.05, 0, 1)
	end
	self:SetHeight(hCount*32+8)
	self:GetParent():SetHeight(hCount*(32+1)+8 <= 552 and hCount*(32+1)+8 or 552)
end

---------------------------------------------------------------
-- Binds: Dynamic secure/UI button 
---------------------------------------------------------------
local function GetStaticBindingName(self)
	local binding =	NewBindingSet and _G[BIND..NewBindingSet[self.name][GetBindingModifier(self.secure.mod)]] or
					db.Bindings and _G[BIND..db.Bindings[self.name][GetBindingModifier(self.secure.mod)]]
	return binding 
end

local function GetStaticBinding(self)
	return db.Bindings[self.secure.name][GetBindingModifier(self.secure.mod)]
end

local function DynamicConfigButtonOnShow(self)
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
		self.background:SetTexture(nil)
	end
end

local function DynamicConfigButtonOnClick(self, mouseButton)
	if not InCombatLockdown() then
		if not ConsolePortRebindFrame.isRebinding then
			self.SelectedTexture:Show()
			db.Binds.Tutorial:SetText(format(TUTORIAL.REBIND, self.indicator:GetText()))
			ConsolePort:SetRebinding(self)
			ConsolePort:SetCurrentNode(self.secure.action)
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
						db.Binds.Tutorial:SetText(format(TUTORIAL.SWAPPED, self.indicator:GetText(), newBind, swappedTexture, swapBind))
					elseif newBind then
						db.Binds.Tutorial:SetText(format(TUTORIAL.APPLIED, self.indicator:GetText(), newBind))
					else
						db.Binds.Tutorial:SetText(TUTORIAL.INVALID)
					end
				end
			else
				db.Binds.Tutorial:SetText(TUTORIAL.COMBO)
			end
			if stopRebind then
				self.SelectedTexture:Hide()
				ConsolePort:SetRebinding(false)
				ConsolePort:SetCurrentNode(self)
				ConsolePort:SetButtonActionsUI()
				ConsolePort:UIControl()
			end
		end
	end
end
function ConsolePort:CreateConfigButton(name, mod, modNum)
	local button = db.Atlas.GetFutureButton(name..mod..CONF, db.Binds.Rebind)
	button.SelectedTexture:SetTexCoord(button.HighlightTexture:GetTexCoord())
	button:SetSize(440, 46)
	button:SetPoint("TOP", db.Binds.Rebind, "TOP", 0, -44*modNum-10)

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
local function SetFauxBinding(self, modifier, old, new)
	if not InCombatLockdown() then
		if old and new then
			local key1, key2 = GetBindingKey(old)
			if key1 then SetOverrideBinding(self, false, modifier..key1, new) end
			if key2 then SetOverrideBinding(self, false, modifier..key2, new) end
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
	for direction, keys in db.pairsByKeys(movement) do
		for _, key in pairs(keys) do
			for _, modifier in pairs(modifiers) do
				SetOverrideBinding(self, false, modifier..key, direction)
			end
		end
	end
end

function ConsolePort:LoadBindingSet()
	local keys = NewBindingSet or db.Bindings
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
		button:ShowInterfaceHotKey()
	else
		self:AddWidgetTracker(button, UIbutton)
	end
end

function ConsolePort:LoadInterfaceBindings()
	local buttons = NewBindingButtons or db.Bindbtns
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
	for character, settings in db.pairsByKeys(ConsolePortCharacterSettings) do
		pCount = pCount + 1
		local button = buttons[pCount] or CreateListButton(self, pCount, ProfileOnSelect)
		button:SetText(character)
		button:Show()
		if settings.Class then
			local cc = RAID_CLASS_COLORS[settings.Class]
			button.Cover:SetVertexColor(cc.r, cc.g, cc.b, 1)
		else
			button.Cover:SetVertexColor(1, 1, 1, 1)
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
		local settings = ConsolePortCharacterSettings[character]
		if settings then
			db.Binds.Tutorial:SetText(format(TUTORIAL.IMPORT, character))
			NewBindingSet = Copy(settings.BindingSet)
			NewBindingButtons = Copy(settings.BindingBtn)
			ReloadBindings()
			ConsolePort:SetButtonActionsUI()
			for i, Buttons in pairs(db.Binds.Buttons) do
				for i, Button in pairs(Buttons) do
					--Button:OnShow()
				end
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

local function SetBindingTooltip(self)
	local tooltip = ConsolePortConfig.Tooltip
	tooltip:Hide()
	tooltip:SetOwner(self, "ANCHOR_BOTTOM")
	tooltip:AddLine(TUTORIAL.TOOLTIPHEADER)
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
						db.Bindings[self.name][indices[i]]

		local text 	= 	binding.button.action and
						((binding.button.action.icon and
						binding.button.action.icon:GetTexture() and
						format(self.icon, binding.button.action.icon:GetTexture())) or
						binding.button.action:GetName()) or
						ConsolePort:GetActionTexture(static) and
						format(self.icon, ConsolePort:GetActionTexture(static)) or
						_G[BIND..static] or
						_G[BIND..GetBindingAction(binding.mod..GetBindingKey(self.name), true)] or "N/A"
		tooltip:AddDoubleLine(binding.icons, text, 1,1,1,1,1,1)
	end
	tooltip:AddLine(TUTORIAL.TOOLTIPCLICK)
	tooltip:Show()
end

local function SetBindingFocus(self)
	local parent = self:GetParent()
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
	NewBindingSet = ConsolePort:GetDefaultBindingSet()
	NewBindingButtons = ConsolePort:GetDefaultBindingButtons()
end

tinsert(db.PANELS, {"Binds", TUTORIAL.HEADER, false, SubmitBindings, RevertBindings, LoadDefaultBinds, function(self, Binds)
	local player = GetUnitName("player").."-"..GetRealmName()
	local cc = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

	Binds.Controller = CreateFrame("Frame", "$parentController", Binds)
	Binds.Controller:SetPoint("CENTER", Binds, "CENTER", 0, 30)
	Binds.Controller:SetSize(512, 512)

	Binds.Controller.Group = Binds.Controller:CreateAnimationGroup()
	Binds.Controller.Group:SetScript("OnFinished", Binds.Controller.OnFinished)
	Binds.Controller.Animation = Binds.Controller.Group:CreateAnimation("Translation")
	Binds.Controller.Animation:SetSmoothing("OUT")
	Binds.Controller.Animation:SetDuration(0.2)
	Binds.Controller.Group:SetScript("OnFinished", function()
		Binds.Controller:SetPoint("CENTER", Binds.Controller.offset < 0 and Binds.Controller.offset or 0, 30)
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
		if newFocus and self.rebindFocus then
			dontAnimate = true
		end
		self.rebindFocus = newFocus
		self.offset = newFocus and -240 or abs(pos-origin)
		self.Animation:SetOffset(not dontAnimate and self.offset or 0, 0)
		self.Group:Play()
	end

	Binds.Controller.Texture = Binds.Controller:CreateTexture("$parentTexture", "ARTWORK")
	Binds.Controller.Texture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Splash\\Splash"..db.Settings.type)
	Binds.Controller.Texture:SetAllPoints(Binds.Controller)

	Binds.Controller.FlashGlow = Binds.Controller:CreateTexture("$parentGlow", "OVERLAY")
	Binds.Controller.FlashGlow:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Splash\\Splash"..db.Settings.type.."Highlight")
	Binds.Controller.FlashGlow:SetAllPoints(Binds.Controller)
	Binds.Controller.FlashGlow:SetAlpha(0)

	Binds.Tutorial = Binds.Controller:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Binds.Tutorial:SetPoint("TOP", Binds.Controller, 0, -70)
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
	for buttonName, position in pairs(db.ButtonCoords) do
		-- temporary Steam guide button fix, remove this.
		if not (db.Settings.skipGuideBtn and buttonName == "CP_C_OPTION") then
			local button = CreateFrame("Button", buttonName.."_BINDING", Binds)
			button.name = buttonName
			button.icon = "|T%s:32:32:0:0|t"
			button.texture = format(button.icon, db.TEXTURE[buttonName])
			button:SetPoint("TOPLEFT", Binds.Controller, "TOPLEFT", position.X, position.Y)
			button:SetSize(30, 30)
			button:SetScript("OnEnter", SetBindingTooltip)
			button:SetScript("OnClick", SetBindingFocus)
			button:SetScript("OnLeave", ClearBindingTooltip)
		end
	end

	db.ButtonCoords = nil

	Binds.Rebind = db.Atlas.GetGlassWindow(addOn.."RebindFrame", Binds.Controller, nil, true)
	Binds.Rebind:SetBackdrop(db.Atlas.Backdrops.Border)
	Binds.Rebind:SetPoint("BOTTOMLEFT", Binds, "BOTTOMLEFT", 24, 16)
	Binds.Rebind:SetSize(460, 200)
	Binds.Rebind:Hide()

	Binds.Rebind.SetButton = RebindSetButton
	Binds.Rebind.Parent = Binds
	Binds.Rebind:SetScript("OnHide", function (self)
		if not InCombatLockdown() and GetCVar("alwaysShowActionBars") == "0" then
			for frame, action in pairs(GetActionButtons()) do
				if not GetActionInfo(action) and frame.forceShow then
					frame.forceShow = nil
					frame:Hide()
				end
			end
		end
		Binds.BindCatcher:Show()
		Binds.Tutorial:SetText(TUTORIAL.DEFAULT)
		Binds.Controller:SetConfigMode()
		ConsolePort:SetRebinding()
		ConsolePort.rebindMode = nil
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

	Binds.Rebind.Close:SetPoint("TOPRIGHT", Binds.Rebind, "TOPRIGHT", -4, 16)
	Binds.Rebind.Close:HookScript("OnClick", function(self)
		ConsolePort:SetCurrentNode(Binds.BindCatcher)
	end)

	Binds.Rebind.Backdrop1 = CreateFrame("Frame", "$parentBackdrop1", Binds.Rebind)
	Binds.Rebind.Backdrop1:SetBackdrop(db.Atlas.Backdrops.Border)
	Binds.Rebind.Backdrop1:SetPoint("TOPLEFT", Binds, "TOP", 0, -8)
	Binds.Rebind.Backdrop1:SetPoint("BOTTOMLEFT", Binds, "BOTTOM", 0, 8)
	Binds.Rebind.Backdrop1:SetWidth(246)

	Binds.Rebind.Backdrop2 = CreateFrame("Frame", "$parentBackdrop2", Binds.Rebind)
	Binds.Rebind.Backdrop2:SetBackdrop(db.Atlas.Backdrops.Border)
	Binds.Rebind.Backdrop2:SetPoint("TOPLEFT", Binds.Rebind.Backdrop1, "TOPRIGHT", -8, 0)
	Binds.Rebind.Backdrop2:SetPoint("BOTTOMLEFT", Binds.Rebind.Backdrop1, "BOTTOMRIGHT", -8, 0)
	Binds.Rebind.Backdrop2:SetWidth(246)

	Binds.Rebind.Headers = CreateFrame("Frame", "$parentHeaders", Binds.Rebind)
	Binds.Rebind.Headers:SetWidth(232)
	Binds.Rebind.Headers.Buttons = {}
	Binds.Rebind.Headers.Bindings = {}
	Binds.Rebind.Headers:SetScript("OnShow", RefreshHeaderList)

	Binds.Rebind.HeaderScroll = CreateFrame("ScrollFrame", "$parentHeaderScrollFrame", Binds.Rebind, "UIPanelScrollFrameTemplate")
	Binds.Rebind.HeaderScroll:SetPoint("BOTTOMLEFT", Binds, "BOTTOM", 0, 16)
	Binds.Rebind.HeaderScroll:SetSize(246, 300)
	Binds.Rebind.HeaderScroll:SetScrollChild(Binds.Rebind.Headers)

	Binds.Rebind.Headers:ClearAllPoints()
	Binds.Rebind.Headers:SetPoint("TOPLEFT", Binds.Rebind.HeaderScroll, "TOPLEFT", 0, -16)

	Binds.Rebind.HeaderScroll.ScrollBar.scrollStep = 32
	Binds.Rebind.HeaderScroll.ScrollBar:ClearAllPoints()
	Binds.Rebind.HeaderScroll.ScrollBar:SetPoint("TOPLEFT", Binds.Rebind.Backdrop1, "TOPRIGHT", -28, -16)
	Binds.Rebind.HeaderScroll.ScrollBar:SetPoint("BOTTOMLEFT", Binds.Rebind.Backdrop1, "BOTTOMRIGHT", -28, 16)
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
	Binds.Rebind.ValueScroll:SetPoint("BOTTOMRIGHT", Binds, "BOTTOMRIGHT", -8, 16)
	Binds.Rebind.ValueScroll:SetWidth(246)
	Binds.Rebind.ValueScroll:SetScrollChild(Binds.Rebind.Values)

	Binds.Rebind.Values:ClearAllPoints()
	Binds.Rebind.Values:SetPoint("TOPLEFT", Binds.Rebind.ValueScroll, "TOPLEFT", 0, -16)

	Binds.Rebind.ValueScroll.ScrollBar.scrollStep = 32
	Binds.Rebind.ValueScroll.ScrollBar:ClearAllPoints()
	Binds.Rebind.ValueScroll.ScrollBar:SetPoint("TOPLEFT", Binds.Rebind.Backdrop2, "TOPRIGHT", -28, -16)
	Binds.Rebind.ValueScroll.ScrollBar:SetPoint("BOTTOMLEFT", Binds.Rebind.Backdrop2, "BOTTOMRIGHT", -28, 16)
	Binds.Rebind.ValueScroll.ScrollBar.Thumb = Binds.Rebind.ValueScroll.ScrollBar:GetThumbTexture()
	Binds.Rebind.ValueScroll.ScrollBar.Thumb:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Thumb")
	Binds.Rebind.ValueScroll.ScrollBar.Thumb:SetTexCoord(0, 1, 0, 1)
	Binds.Rebind.ValueScroll.ScrollBar.Thumb:SetSize(18, 34)
	Binds.Rebind.ValueScroll.ScrollBar.ScrollUpButton:SetAlpha(0)
	Binds.Rebind.ValueScroll.ScrollBar.ScrollDownButton:SetAlpha(0)

	self:AddFrame(addOn.."RebindFrame")
end})
