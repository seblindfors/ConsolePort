local addOn, db = ...
local KEY = db.KEY
local TUTORIAL = db.TUTORIAL.BIND
local TEXTURE = db.TEXTURE

local BIND_TARGET 	 	= false
local BIND_MODIFIER 	= nil
local CONF_BUTTON 		= nil

local CP				= "CP"
local CONF				= "_CONF"
local CHECK 			= "_CHECK"
local CONFBG			= "_CONF_BG"
local GUIDE				= "_GUIDE"
local NOMOD				= "_NOMOD"
local SHIFT				= "_SHIFT"
local CTRL				= "_CTRL"
local CTRLSH			= "_CTRLSH"
local BIND 				= "BINDING_NAME_"

local NewBindingSet = nil 
local NewBindingButtons = nil 

db.HotKeys = {}

---------------------------------------------------------------
-- Table: Recursive table duplicator
---------------------------------------------------------------
local function Copy(src)
	local srcType = type(src)
	local copy
	if srcType == "table" then
		copy = {}
		for key, value in next, src, nil do
			copy[Copy(key)] = Copy(value)
		end
		setmetatable(copy, Copy(getmetatable(src)))
	else
		copy = src
	end
	return copy
end

---------------------------------------------------------------
-- Table: Recursive table comparator
---------------------------------------------------------------
local function Compare(t1, t2)
	if t1 == t2 then
		return true
	end
	if type(t1) ~= "table" then
		return false
	end
	local mt1, mt2 = getmetatable(t1), getmetatable(t2)
	if not Compare(mt1,mt2) then
		return false
	end
	for k1, v1 in pairs(t1) do
		local v2 = t2[k1]
		if not Compare(v1,v2) then
			return false
		end
	end
	for k2, v2 in pairs(t2) do
		local v1 = t1[k2]
		if not Compare(v1,v2) then
			return false
		end
	end
	return true
end

---------------------------------------------------------------
-- Config: Returns converted modifier for binding table use
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
-- Config: Returns converted modifier for faux binding use
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
-- Config: Returns events for mouselook
---------------------------------------------------------------
local function GetMouseSettings()
	return {
		{ 	event 	= {"PLAYER_STARTED_MOVING"},
			desc 	= "Player starts moving",
			toggle 	= ConsolePortMouse.Events["PLAYER_STARTED_MOVING"]
		},
		{ 	event	= {"PLAYER_TARGET_CHANGED"},
			desc 	= "Player changes target",
			toggle 	= ConsolePortMouse.Events["PLAYER_TARGET_CHANGED"]
		},
		{	event 	= {"CURRENT_SPELL_CAST_CHANGED"},
			desc 	= "Player casts a direct spell",
			toggle 	= ConsolePortMouse.Events["CURRENT_SPELL_CAST_CHANGED"]
		},
		{	event 	= {"GOSSIP_SHOW", "GOSSIP_CLOSED"},
			desc 	= "NPC interaction",
			toggle 	= ConsolePortMouse.Events["GOSSIP_SHOW"]
		},
		{	event 	= {"MERCHANT_SHOW", "MERCHANT_CLOSED"},
			desc 	= "Merchant interaction", 
			toggle 	= ConsolePortMouse.Events["MERCHANT_SHOW"]
		},
		{	event	= {"TAXIMAP_OPENED", "TAXIMAP_CLOSED"},
			desc 	= "Flight master interaction",
			toggle 	= ConsolePortMouse.Events["TAXIMAP_OPENED"]
		},
		{	event	= {"QUEST_GREETING", "QUEST_DETAIL", "QUEST_PROGRESS", "QUEST_COMPLETE", "QUEST_FINISHED"},
			desc 	= "Quest giver interaction",
			toggle 	= ConsolePortMouse.Events["QUEST_GREETING"]
		},
		{ 	event	= {"QUEST_AUTOCOMPLETE"},
			desc 	= "Popup quest completion",
			toggle 	= ConsolePortMouse.Events["QUEST_AUTOCOMPLETE"]
		},
		{ 	event 	= {"SHIPMENT_CRAFTER_OPENED", "SHIPMENT_CRAFTER_CLOSED"},
			desc 	= "Garrison work order",
			toggle 	= ConsolePortMouse.Events["SHIPMENT_CRAFTER_OPENED"]
		},
		{	event	= {"LOOT_OPENED"},
			desc 	= "Loot window opened",
			toggle 	= ConsolePortMouse.Events["LOOT_OPENED"]
		},
		{	event	= {"LOOT_CLOSED"},
			desc 	= "Loot window closed",
			toggle 	= ConsolePortMouse.Events["LOOT_CLOSED"]
		}
	}
end

local function GetAddonSettings()
	return {
		{	cvar = "flipMod",
			desc = "Flip modifiers (requires reload)",
			toggle = ConsolePortSettings.flipMod,
		},
		{	cvar = "autoExtra",
			desc = "Auto bind appropriate quest items",
			toggle = ConsolePortSettings.autoExtra,
		}
	}
end

---------------------------------------------------------------
-- Config: Reset button guides
---------------------------------------------------------------
local function ResetGuides()
	for i, guide in pairs(db.HotKeys) do
		guide:SetTexture(nil)
		if 	guide:GetParent().HotKey then
			guide:GetParent().HotKey:SetAlpha(1)
		end
	end
	wipe(db.HotKeys)
end

---------------------------------------------------------------
-- Config: Reload, save and revert binds
---------------------------------------------------------------
local function ReloadBindings()
	ConsolePort:ReloadBindingActions()
	ConsolePort:LoadBindingSet()
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
			ResetGuides()
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
		if not InCombatLockdown() then
			ReloadBindings()
		else
			ReloadUI()
		end
	end
end

---------------------------------------------------------------
-- Config: Secure UI/Button rebind animation
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
-- Config: Secure UI/Button binding changer
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
				local text = _G["BINDING_NAME_"..focusFrame.Binding] or focusFrame.Binding
				NewBindingSet[tableIndex][mod] = focusFrame.Binding
				NewBindingButtons[tableIndex][mod] = nil
				_G[buttonName].action = nil
				confButton:SetText(text)
				isValid = text
			else
				NewBindingSet[tableIndex][mod] = "CLICK "..buttonName..":LeftButton"
				NewBindingButtons[tableIndex][mod] = focusFrameName
				confButton:SetText(focusFrameName)
				isValid = focusFrameName
			end

			AnimateBindingChange(focusFrame, confButton)
			ResetGuides()
			ReloadBindings()
		end

		return isValid
	end
end

---------------------------------------------------------------
-- Config: Static key binding table
---------------------------------------------------------------
local function GetAddonBindings()
	return {
		{name = "ConsolePort Extra", binding = "CLICK ConsolePortExtraButton:LeftButton"},
		{name = BINDING_NAME_CP_TOGGLEMOUSE, binding = "CP_TOGGLEMOUSE"},
		{name = BINDING_NAME_CP_CAMZOOMIN, binding = "CP_CAMZOOMIN"},
		{name = BINDING_NAME_CP_CAMZOOMOUT, binding = "CP_CAMZOOMOUT"},
	}
end

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
			name = _G["BINDING_NAME_"..binding] or _G["BINDING_"..binding]
			tinsert(bindings[category], {name = name, binding = _G["BINDING_NAME_"..binding] and binding})
		elseif 	(binding:match("^HEADER") and not
				binding:match("^HEADER_BLANK") and not
				binding:match("^CP_")) or not
				binding:match("^HEADER") then
			if not bindings["Other"] then
				bindings["Other"] = {}
			end
			name = _G["BINDING_NAME_"..binding] or _G["BINDING_"..binding]
			tinsert(bindings["Other"], {name = name, binding = _G["BINDING_NAME_"..binding] and binding})
		end
	end
	bindings["ConsolePort "] = GetAddonBindings()
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
-- Config: Dynamic secure/UI button 
---------------------------------------------------------------
local function GetStaticBinding(self)
	local key  = GetBindingKey(self.name)
	local binding 
	if key then
		key = self.modifier and self.modifier.."-"..key or key
		binding = _G[BIND..GetBindingAction(key, true)]
	end
	if not binding then
		binding = _G[BIND..ConsolePortBindingSet[self.secure.name][GetBindingModifier(self.secure.mod)]]
	end
	return binding 
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
	elseif self.secure.buttonWatch then
		self:SetText(format("|cFFFF1111%s|r", self.secure.buttonWatch))
	elseif GetStaticBinding(self) then
		self:SetText(GetStaticBinding(self))
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
				ConsolePort:UIControl(KEY.PREPARE, KEY.STATE_DOWN)
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
-- Config: Create addon dummy bindings
---------------------------------------------------------------
function ConsolePort:LoadBindingSet()
	local keys = NewBindingSet or ConsolePortBindingSet
	local w = WorldFrame
	ClearOverrideBindings(w)
	for name, key in pairs(keys) do
		if key.action 	then self:OverrideBinding(w, true, nil, 			name, key.action)	end
		if key.ctrl 	then self:OverrideBinding(w, true, "CTRL", 			name, key.ctrl) 	end 
		if key.shift 	then self:OverrideBinding(w, true, "SHIFT",			name, key.shift) 	end
		if key.ctrlsh 	then self:OverrideBinding(w, true, "CTRL-SHIFT", 	name, key.ctrlsh)	end
	end
end

local function GetDefaultGuideTexture(button)
	local triggers = {
		CP_TR1 = db.TEXTURE.RONE,
		CP_TR2 = db.TEXTURE.RTWO,
		CP_TR3 = db.TEXTURE.LONE,
		CP_TR4 = db.TEXTURE.LTWO,
	}
	return triggers[button] or db.TEXTURE[strupper(db.NAME[button])]
end

---------------------------------------------------------------
-- Config: Hotkey guides on UI button 
---------------------------------------------------------------
function ConsolePort:UpdateActionGuideTexture(button, key, mod1, mod2)
	if button.HotKey then
		button.HotKey:SetAlpha(0)
	end
	if not button.guide then
		button.guide = button:CreateTexture(nil, "OVERLAY", nil, 7)
		button.guide:SetPoint("TOPRIGHT", button, 0, 0)
		button.guide:SetSize(14, 14)
		tinsert(db.HotKeys, button.guide)
	end
	button.guide:SetTexture(GetDefaultGuideTexture(key))
	self:UpdateModifiedActionGuideTexture(button, mod1, "TOP")
	self:UpdateModifiedActionGuideTexture(button, mod2, "TOPLEFT")
end

function ConsolePort:UpdateModifiedActionGuideTexture(button, modifier, anchor)
	local mod
	if 		anchor == "TOP"  	then mod = "mod1"
	elseif 	anchor == "TOPLEFT" then mod = "mod2" end
	if  modifier and not button[mod] then
		button[mod] = button:CreateTexture(nil, "OVERLAY", nil, 7)
		button[mod]:SetPoint(anchor, button, 0, 0)
		button[mod]:SetSize(14, 14)
		tinsert(db.HotKeys, button[mod])
	elseif not modifier and button[mod] then
		button[mod]:SetTexture(nil)
	end
	if 	modifier then
		button[mod]:SetTexture(GetDefaultGuideTexture(modifier))
	end
end

---------------------------------------------------------------
-- Config: Reload bindings from table
---------------------------------------------------------------
function ConsolePort:ReloadBindingAction(button, UIbutton, name, mod1, mod2)
	local action = _G[UIbutton]
	if action then
		button.action = action
		button:Reset()
		button:Revert()
		if 	button.action:GetParent() == MainMenuBarArtFrame and
			button.action.action and button.action:GetID() <= 6 then
			self:UpdateActionGuideTexture(_G["OverrideActionBarButton"..button.action:GetID()], name, mod1, mod2)
		end
		self:UpdateActionGuideTexture(button.action, name, mod1, mod2)
		if button.action.HotKey then
			button.action.HotKey:SetAlpha(0)
		end
	else
		self:AddButtonWatch(button, UIbutton, name, mod1, mod2)
	end
end

function ConsolePort:ReloadBindingActions()
	local keys = NewBindingButtons or ConsolePortBindingButtons
	for name, key in pairs(keys) do
		if key.action then 
			self:ReloadBindingAction(_G[name..NOMOD], key.action, name, nil, nil)
		end
		if key.ctrl then
			self:ReloadBindingAction(_G[name..CTRL], key.ctrl, name, "CP_TR4", nil)
		end
		if key.shift then
			self:ReloadBindingAction(_G[name..SHIFT], key.shift, name, "CP_TR3", nil)
		end
		if key.ctrlsh then
			self:ReloadBindingAction(_G[name..CTRLSH], key.ctrlsh, name, "CP_TR4", "CP_TR3")
		end
	end
end

---------------------------------------------------------------
-- Config: Binding palette show function
---------------------------------------------------------------
local function BindingsOnShow(self)
	self.Tutorial:SetText(TUTORIAL.DEFAULT)
	self.Rebind:Hide()
	self.dropdown:initialize()
end

---------------------------------------------------------------
-- Config: Import profile functions 
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
	self:GetParent().dropdown.text:SetText("Choose character")
	BindingsOnShow(self:GetParent())
end

local function ResetControllerOnClick(self)
	InterfaceOptionsFrame:Hide()
	ConsolePort:CreateSplashFrame()
	ConsolePort:UIControl(KEY.PREPARE, KEY.STATE_DOWN)
end

local function ResetBindingsOnClick(self)
	if not InCombatLockdown() then
		InterfaceOptionsFrame:Hide()
		local bindings = ConsolePort:GetBindingNames()
		for i, binding in pairs(bindings) do
			local key1, key2 = GetBindingKey(binding)
			if key1 then SetBinding(key1) end
			if key2 then SetBinding(key2) end
		end
		SaveBindings(GetCurrentBindingSet())
		ConsolePort:CreateBindingWizard()
	end
end

---------------------------------------------------------------
-- Config: Save mouse info/reload events
---------------------------------------------------------------
local function SaveMouseConfig(self)
	for i, Check in pairs(self.Events) do
		for i, Event in pairs(Check.Events) do
			ConsolePortMouse.Events[Event] = Check:GetChecked()
		end
	end
	ConsolePortMouse.Cursor.Left = self.LeftClick.button
	ConsolePortMouse.Cursor.Right = self.RightClick.button
	ConsolePortMouse.Cursor.Scroll = self.ScrollClick.button
	ConsolePort:LoadEvents()
	ConsolePort:SetupCursor()
end

---------------------------------------------------------------
-- Config: Save general addon cvars
---------------------------------------------------------------
local function SaveGeneralConfig(self)
	for i, Check in pairs(self.General) do
		ConsolePortSettings[Check.Cvar] = Check:GetChecked()
	end
end

---------------------------------------------------------------
-- Config: Binding buttons and tooltip
---------------------------------------------------------------
local function SetBindingTooltip(self)
	GameTooltip:Hide()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
	GameTooltip:AddLine("Bindings")
	if not self.bindings then
		self.bindings = {
			{	button = _G[self.name..NOMOD], mod = "",
				icons = self.texture,
			},
			{	button = _G[self.name..SHIFT], mod = "SHIFT-",
				icons = format(self.icon, db.TEXTURE.LONE)..self.texture,
			},
			{	button = _G[self.name..CTRL], mod = "CTRL-",
				icons = format(self.icon, db.TEXTURE.LTWO)..self.texture,
			},
			{	button = _G[self.name..CTRLSH], mod = "CTRL-SHIFT-",
				icons = format(self.icon, db.TEXTURE.LONE)..format(self.icon, db.TEXTURE.LTWO)..self.texture,
			},
		}
	end
	local indices = { "action", "shift", "ctrl", "ctrlsh" }
	for i, binding in pairs(self.bindings) do
		local text 	= 	binding.button and
						binding.button.action and
						binding.button.action.icon and
						binding.button.action.icon:GetTexture() and
						format(self.icon, binding.button.action.icon:GetTexture()) or
						binding.button and
						binding.button.action and
						binding.button.action:GetName() or
						NewBindingSet and
						_G["BINDING_NAME_"..NewBindingSet[self.name][indices[i]]] or
						_G["BINDING_NAME_"..ConsolePortBindingSet[self.name][indices[i]]] or
						_G["BINDING_NAME_"..GetBindingAction(binding.mod..GetBindingKey(self.name), true)] or "N/A"
		GameTooltip:AddDoubleLine(binding.icons, text, 1,1,1,1,1,1)
	end
	GameTooltip:AddLine("<Click to change>")
	GameTooltip:Show()
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
-- Config: UICtrl addons/frames scripts
---------------------------------------------------------------
local function NewAddonOnClick(self)
	local self = self:GetParent()
	local dialog = StaticPopup_Show("CONSOLEPORT_ADDADDON")
	if dialog then
		dialog.data = self.AddonList
	end
end

local function NewFrameOnClick(self)
	local self = self:GetParent()
	if self.CurrentAddon then
		local dialog = StaticPopup_Show("CONSOLEPORT_ADDFRAME", self.CurrentAddon:GetText())
		if dialog then
			dialog.data = self.CurrentAddon
		end
	end
end

local function RemoveAddonOnClick(self)
	local self = self:GetParent()
	local addonList = self.parent.AddonList
	local addon = self:GetText()
	local dialog = StaticPopup_Show("CONSOLEPORT_REMOVEADDON", addon)
	if dialog then
		dialog.data = addonList
		dialog.data2 = addon
	end
end

local function RemoveFrameOnClick(self)
	local self = self:GetParent()
	local frame = self:GetText()
	local owner = self.owner
	local addon = owner:GetText()
	local dialog = StaticPopup_Show("CONSOLEPORT_REMOVEFRAME", frame, addon)
	if dialog then
		dialog.data = self
		dialog.data2 = owner
	end
end

---------------------------------------------------------------
-- Config: UICtrl addons and frames
---------------------------------------------------------------
local function CreateUICtrlConfigButton(parent, num, clickScript, removeScript)
	local button = CreateFrame("Button", "$parentButton"..num, parent, "OptionsListButtonTemplate")
	button:SetHeight(24)
	button:SetScript("OnClick", clickScript)
	button.Remove = CreateFrame("Button", "$parentRemove", button)
	button.Remove:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
	button.Remove:SetSize(14, 14)
	button.Remove:SetPoint("RIGHT", button, "RIGHT", -8, 0)
	button.Remove:SetAlpha(0.5)
	button.Remove:SetScript("OnClick", removeScript)
	tinsert(parent.Buttons, button)
	if num == 1 then
		button:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, 0)
		button:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -4, 0)
	else
		button:SetPoint("TOPLEFT", parent.Buttons[num-1], "BOTTOMLEFT")
		button:SetPoint("TOPRIGHT", parent.Buttons[num-1], "BOTTOMRIGHT")
	end
	return button
end

local function RefreshFrameList(self)
	local addonButtons = self.parent.AddonList.Buttons
	local frameButtons = self.parent.FrameList.Buttons
	local frameList = self.parent.FrameList

	self.parent.NewFrame:SetButtonState("NORMAL")
	self.parent.CurrentAddon = self

	local header = self.parent.FrameListText
	header:SetText(format("Frames in |cffffe00a%s|r:", self:GetText()))

	for i, button in pairs(addonButtons) do
		button:UnlockHighlight()
	end
	self:LockHighlight()

	for i, button in pairs(frameButtons) do
		button:Hide()
	end

	local frames = self.list
	local num = 0
	for i, frame in pairs(frames) do
		num = num + 1
		local button
		if not frameButtons[num] then
			button = CreateUICtrlConfigButton(frameList, num, nil, RemoveFrameOnClick)
		else
			button = frameButtons[num]
		end
		button:Show()
		button:SetText(frame)
		button.list = frames
		button.owner = self
	end

	frameList:SetHeight(num*24)
end

local function RefreshAddonList(self)
	local list = ConsolePortUIFrames
	for i, button in pairs(self.Buttons) do
		button:Hide()
	end

	local num = 0
	for addon, frames in db.pairsByKeys(list) do
		num = num + 1
		local button
		if not self.Buttons[num] then
			button = CreateUICtrlConfigButton(self, num, RefreshFrameList, RemoveAddonOnClick)
			button.parent = self.parent
		else
			button = self.Buttons[num]
		end
		button:Show()
		button:SetText(addon)
		button.list = frames
	end

	self:SetHeight(num*24)
end

---------------------------------------------------------------
-- Config: UICtrl popup functions
---------------------------------------------------------------
local function AddFramePopupAccept(self, addonButton)
	local list = ConsolePortUIFrames
	local addon = list[addonButton:GetText()]
	if addon then
		local exists
		local name = self.editBox:GetText():trim()
		for i, frame in pairs(addon) do
			if frame == name then
				exists = true
				break
			end
		end
		if not exists then
			tinsert(addon, name)
		end
	end
	RefreshFrameList(addonButton)
	ConsolePort:CheckLoadedAddons()
end

local function AddAddonPopupAccept(self, addonList)
	local list = ConsolePortUIFrames
	local addon = self.editBox:GetText():trim()
	if not list[addon] then
		list[addon] = {}
	end
	RefreshAddonList(addonList)
end

local function RemoveAddonPopupAccept(self, addonList, addon)
	local list = ConsolePortUIFrames
	list[addon] = nil
	RefreshAddonList(addonList)
	ConsolePort:CheckLoadedAddons()
end

local function RemoveFramePopupAccept(self, frame, addon)
	local list = ConsolePortUIFrames[addon:GetText()]
	local name = frame:GetText()
	for i, frame in pairs(list) do
		if frame == name then
			list[i] = nil
			break
		end
	end
	RefreshFrameList(addon)
	ConsolePort:CheckLoadedAddons()
end

---------------------------------------------------------------
-- Config: Default functions	
---------------------------------------------------------------
local function LoadDefaultUICtrl(self)
	ConsolePortUIFrames = ConsolePort:GetDefaultUIFrames()
	RefreshAddonList(self.AddonList)
end

local function LoadDefaultBinds(self)
	self.Tutorial:SetText(TUTORIAL.RESET)
	NewBindingSet = ConsolePort:GetDefaultBindingSet()
	NewBindingButtons = ConsolePort:GetDefaultBindingButtons()
end

---------------------------------------------------------------
-- Config: Create panel and children 
---------------------------------------------------------------
local function CreatePanel(parent, name, title, header, okay, cancel, default)
	local panel = CreateFrame("FRAME", addOn.."ConfigFrame"..name, parent)

	panel.name = title
	panel.okay = okay
	panel.cancel = cancel
	panel.default = default
	panel.parent = parent.name

	panel.Header = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	panel.Header:SetText(header)
	panel.Header:SetPoint("TOPLEFT", panel, 16, -16)

	InterfaceOptions_AddCategory(panel)
	return panel
end

local function ConfigurePanelConfig(self, Config)
	Config.ResetController = CreateFrame("BUTTON", addOn.."ResetController", Config, "UIPanelButtonTemplate")
	Config.ResetController:SetWidth(150)
	Config.ResetController:SetText("Change controller")
	Config.ResetController:SetPoint("TOPRIGHT", -16, -44)
	Config.ResetController:SetScript("OnClick", ResetControllerOnClick)

	Config.ResetBindings = CreateFrame("BUTTON", addOn.."ResetController", Config, "UIPanelButtonTemplate")
	Config.ResetBindings:SetWidth(150)
	Config.ResetBindings:SetText("Reset bindings")
	Config.ResetBindings:SetPoint("TOP", Config.ResetController, "BOTTOM", 0, -2)
	Config.ResetBindings:SetScript("OnClick", ResetBindingsOnClick)

	Config.General = {}
	for i, setting in pairs(GetAddonSettings()) do
		local check = CreateFrame("CheckButton", "$parentGeneralSetting"..i, Config, "ChatConfigCheckButtonTemplate")
		local text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		text:SetText(setting.desc)
		check:SetChecked(setting.toggle)
		check.Description = text
		check.Cvar = setting.cvar
		check:SetPoint("TOPLEFT", 16, -30*i-10)
		text:SetPoint("LEFT", check, 30, 0)
		check:Show()
		text:Show()
		tinsert(Config.General, check)
	end
end

local function ConfigurePanelBinds(self, Binds)
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
	Binds.dropdown.text:SetText("Choose character")
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
	Binds.import:SetText("Import")
	Binds.import:SetScript("OnClick", ImportOnClick)

	Binds.remove = CreateFrame("BUTTON", addOn.."ImportRemove", Binds, "UIPanelButtonTemplate")
	Binds.remove:SetPoint("RIGHT", Binds.import, "LEFT", -4, 0)
	Binds.remove:SetWidth(82)
	Binds.remove:SetText("Remove")
	Binds.remove:SetScript("OnClick", RemoveOnClick)

	Binds.Buttons = {}
	for buttonName, position in pairs(db.BINDINGS) do
		local button = CreateFrame("Button", buttonName.."_BINDING", Binds)
		button.name = buttonName
		button.icon = "|T%s:24:24:0:0|t"
		button.texture = format(button.icon, GetDefaultGuideTexture(buttonName))
		button:SetPoint("TOPLEFT", Binds.Controller, "TOPLEFT", position.X, position.Y)
		button:SetSize(30, 30)
		button:SetScript("OnEnter", SetBindingTooltip)
		button:SetScript("OnClick", function(self) Binds.Rebind:SetButton(self) ConsolePort:SetCurrentNode(Binds.Buttons[button.name][1]) end)
		button:SetScript("OnLeave", function(self) if GameTooltip:GetOwner() == self then GameTooltip:Hide() end end)
	end

	Binds.Rebind = CreateFrame("Frame", addOn.."RebindFrame", Binds)
	Binds.Rebind:SetPoint("BOTTOM", Binds, "BOTTOM", 0, 0)
	Binds.Rebind:SetSize(400, 180)
	Binds.Rebind:Hide()

	Binds.Rebind.SetButton = RebindSetButton
	Binds.Rebind.Parent = Binds
	Binds.Rebind:SetScript("OnHide", function (self) Binds.Tutorial:SetText(TUTORIAL.DEFAULT) ConsolePort:SetRebinding() end)
	Binds.Rebind:RegisterEvent("PLAYER_REGEN_DISABLED")
	Binds.Rebind:SetScript("OnEvent", Binds.Rebind.Hide)

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

	self:AddFrame(Binds.Rebind:GetName())
end

local function ConfigurePanelMouse(self, Mouse)
	Mouse.Events = {}
	for i, setting in pairs(GetMouseSettings()) do
		local check = CreateFrame("CheckButton", "ConsolePortMouseEvent"..i, Mouse, "ChatConfigCheckButtonTemplate")
		local text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		text:SetText(setting.desc)
		check:SetChecked(setting.toggle)
		check.Events = setting.event
		check.Description = text
		check:SetPoint("TOPLEFT", 16, -30*i-10)
		text:SetPoint("LEFT", check, 30, 0)
		check:Show()
		text:Show()
		tinsert(Mouse.Events, check)
	end

	Mouse.CursorHeader = Mouse:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	Mouse.CursorHeader:SetText("Virtual cursor settings")
	Mouse.CursorHeader:SetPoint("TOPLEFT", Mouse, 16, -420)

	Mouse.LeftClick = Mouse:CreateTexture()
	Mouse.LeftClick:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME")
	Mouse.LeftClick:SetSize(76*0.75, 101*0.75)
	Mouse.LeftClick:SetTexCoord(0.0019531, 0.1484375, 0.4257813, 0.6210938)
	Mouse.LeftClick:SetPoint("TOPLEFT", Mouse, "TOPLEFT", 16, -450)

	Mouse.RightClick = Mouse:CreateTexture()
	Mouse.RightClick:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME")
	Mouse.RightClick:SetSize(76*0.75, 101*0.75)
	Mouse.RightClick:SetTexCoord(0.0019531, 0.1484375, 0.6269531, 0.8222656)
	Mouse.RightClick:SetPoint("LEFT", Mouse.LeftClick, "RIGHT", 85, 0)

	Mouse.SpecialClick = Mouse:CreateTexture()
	Mouse.SpecialClick:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME")
	Mouse.SpecialClick:SetSize(76*0.75, 101*0.75)
	Mouse.SpecialClick:SetTexCoord(0.1542969, 0.3007813, 0.2246094, 0.4199219)
	Mouse.SpecialClick:SetPoint("LEFT", Mouse.RightClick, "RIGHT", 85, 0)

	Mouse.ScrollClick = Mouse:CreateTexture()
	Mouse.ScrollClick:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME")
	Mouse.ScrollClick:SetSize(76*0.75, 101*0.75)
	Mouse.ScrollClick:SetTexCoord(0.0019531, 0.1484375, 0.2246094, 0.4199219)
	Mouse.ScrollClick:SetPoint("LEFT", Mouse.SpecialClick, "RIGHT", 85, 0)

	local clickButtons 	= {
		CP_R_RIGHT 	= TEXTURE[strupper(db.NAME.CP_R_RIGHT)],
		CP_R_LEFT 	= TEXTURE[strupper(db.NAME.CP_R_LEFT)],
		CP_R_UP		= TEXTURE[strupper(db.NAME.CP_R_UP)],
		CP_R_DOWN	= TEXTURE[strupper(db.NAME.CP_R_DOWN)],
	}

	local scrollButtons = {
		CP_TR3 		= db.TEXTURE.LONE,
		CP_TR4 		= db.TEXTURE.LTWO,
	}

	local RadioButtons = {
		{parent = Mouse.LeftClick, 		selection = clickButtons,	default = ConsolePortMouse.Cursor.Left},
		{parent = Mouse.RightClick, 	selection = clickButtons,	default = ConsolePortMouse.Cursor.Right},
		{parent = Mouse.SpecialClick, 	selection = clickButtons, 	default = ConsolePortMouse.Cursor.Special},
		{parent = Mouse.ScrollClick, 	selection = scrollButtons,	default = ConsolePortMouse.Cursor.Scroll},
	}

	for i, radio in pairs(RadioButtons) do
		local num = 1
		local radioSet = {}
		for name, texture in pairs(radio.selection) do
			local button = CreateFrame("CheckButton", addOn.."VirtualClick"..i..num, Mouse, "UIRadioButtonTemplate")
			button.text = _G[button:GetName().."Text"]
			button.text:SetText(format("|T%s:24:24:0:0|t", texture))
			button:SetPoint("TOPLEFT", radio.parent, "TOPRIGHT", 5, -24*(num-1)-8)
			if name == radio.default then
				radio.parent.button = name
				button:SetChecked(true)
			else
				button:SetChecked(false)
			end
			tinsert(radioSet, button)
			button:SetScript("OnClick", function(self)
				for i, button in pairs(radioSet) do
					button:SetChecked(false)
				end
				self:SetChecked(true)
				radio.parent.button = name
			end)
			num = num + 1
		end
	end
end

local function ConfigurePanelUICtrl(self, UICtrl)
	UICtrl.AddonList = CreateFrame("Frame", "$parentAddonList", UICtrl)
	UICtrl.AddonList:SetSize(260, 1000)
	UICtrl.AddonList.parent = UICtrl
	UICtrl.AddonList.Buttons = {}
	UICtrl.AddonList:SetScript("OnShow", RefreshAddonList)

	UICtrl.AddonScroll = CreateFrame("ScrollFrame", "$parentAddonScrollFrame", UICtrl, "UIPanelScrollFrameTemplate")
	UICtrl.AddonScroll:SetPoint("TOPLEFT", UICtrl, "TOPLEFT", 16, -64)
	UICtrl.AddonScroll:SetPoint("BOTTOMRIGHT", UICtrl, "BOTTOM", -32, 46)
	UICtrl.AddonScroll:SetScrollChild(UICtrl.AddonList)

	UICtrl.AddonWrap = CreateFrame("Frame", "$parentAddonWrap", UICtrl, "InsetFrameTemplate3")
	UICtrl.AddonWrap:SetPoint("TOPLEFT", UICtrl, "TOPLEFT", 14, -60)
	UICtrl.AddonWrap:SetPoint("BOTTOMRIGHT", UICtrl, "BOTTOM", -32, 42)

	UICtrl.AddonListText = UICtrl:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	UICtrl.AddonListText:SetPoint("BOTTOMLEFT", UICtrl.AddonScroll, "TOPLEFT", 0, 8)
	UICtrl.AddonListText:SetText("AddOns:")

	UICtrl.NewAddon = CreateFrame("BUTTON", "$parentNewAddonButton", UICtrl, "UIPanelButtonTemplate")
	UICtrl.NewAddon:SetPoint("TOPLEFT", UICtrl.AddonScroll, "BOTTOMLEFT", 0, -12)
	UICtrl.NewAddon:SetWidth(100)
	UICtrl.NewAddon:SetText("New addon")
	UICtrl.NewAddon:SetScript("OnClick", NewAddonOnClick)

	UICtrl.FrameList = CreateFrame("Frame", "$parentFrameList", UICtrl)
	UICtrl.FrameList:SetSize(260, 1000)
	UICtrl.FrameList.parent = UICtrl
	UICtrl.FrameList.Buttons = {}

	UICtrl.FrameScroll = CreateFrame("ScrollFrame", "$parentFrameScrollFrame", UICtrl, "UIPanelScrollFrameTemplate")
	UICtrl.FrameScroll:SetPoint("TOPRIGHT", UICtrl, "TOPRIGHT", -48, -64)
	UICtrl.FrameScroll:SetPoint("BOTTOMLEFT", UICtrl, "BOTTOM", 0, 46)
	UICtrl.FrameScroll:SetScrollChild(UICtrl.FrameList)

	UICtrl.FrameWrap = CreateFrame("Frame", "$parentFrameWrap", UICtrl, "InsetFrameTemplate3")
	UICtrl.FrameWrap:SetPoint("TOPRIGHT", UICtrl, "TOPRIGHT", -48, -60)
	UICtrl.FrameWrap:SetPoint("BOTTOMLEFT", UICtrl, "BOTTOM", -4, 42)

	UICtrl.FrameListText = UICtrl:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	UICtrl.FrameListText:SetPoint("BOTTOMLEFT", UICtrl.FrameScroll, "TOPLEFT", 0, 8)
	UICtrl.FrameListText:SetText("Frames:")

	UICtrl.NewFrame = CreateFrame("BUTTON", "$parentNewFrameButton", UICtrl, "UIPanelButtonTemplate")
	UICtrl.NewFrame:SetPoint("TOPLEFT", UICtrl.FrameScroll, "BOTTOMLEFT", 0, -12)
	UICtrl.NewFrame:SetWidth(100)
	UICtrl.NewFrame:SetText("New frame")
	UICtrl.NewFrame:SetButtonState("DISABLED")
	UICtrl.NewFrame:SetScript("OnClick", NewFrameOnClick)

	StaticPopupDialogs["CONSOLEPORT_ADDADDON"] = {
		text = "Enter name of addon or module:",
		button1 = "Add",
		button2 = "Cancel",
		showAlert = true,
		hasEditBox = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
		enterClicksFirstButton = true,
		exclusive = true,
		OnAccept = AddAddonPopupAccept,
	}

	StaticPopupDialogs["CONSOLEPORT_ADDFRAME"] = {
		text = "Enter name to add frame to addon |cffffe00a%s|r:",
		button1 = "Add",
		button2 = "Cancel",
		showAlert = true,
		hasEditBox = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
		enterClicksFirstButton = true,
		exclusive = true,
		OnAccept = AddFramePopupAccept
	}

	StaticPopupDialogs["CONSOLEPORT_REMOVEFRAME"] = {
		text = "Do you want to remove frame |cffffe00a%s|r in addon |cffffe00a%s|r from virtual cursor?",
		button1 = "Remove",
		button2 = "Cancel",
		showAlert = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
		enterClicksFirstButton = true,
		exclusive = true,
		OnAccept = RemoveFramePopupAccept
	}

	StaticPopupDialogs["CONSOLEPORT_REMOVEADDON"] = {
		text = "Do you want to remove addon |cffffe00a%s|r from virtual cursor?",
		button1 = "Remove",
		button2 = "Cancel",
		showAlert = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
		enterClicksFirstButton = true,
		exclusive = true,
		OnAccept =  RemoveAddonPopupAccept
	}
end

function ConsolePort:CreateConfigPanel()
	if not db.Config then

		local Config = CreatePanel(InterfaceOptionsFramePanelContainer, "Main", addOn, addOn, SaveGeneralConfig)
		local Binds = CreatePanel(Config, "Binds", "Bindings", "Binding settings", SubmitBindings, RevertBindings, LoadDefaultBinds)
		local Mouse = CreatePanel(Config, "Mouse", "Mouse", "Toggle mouse look when...", SaveMouseConfig)
		local UICtrl = CreatePanel(Config, "UICtrl", "Interface", "Interface settings (advanced)", nil, nil, LoadDefaultUICtrl)

		db.Config	= Config
		db.Binds	= Binds
		db.Mouse 	= Mouse
		db.UICtrl 	= UICtrl

		ConfigurePanelConfig(self, Config)
		ConfigurePanelBinds(self, Binds)
		ConfigurePanelMouse(self, Mouse)
		ConfigurePanelUICtrl(self, UICtrl)
	end
end

-- holy crap this file is a mess :(
