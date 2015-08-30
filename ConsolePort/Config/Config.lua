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

--[[
|---------------------------------------|
| Config: Recursive table duplicator 	|
|---------------------------------------|
]]--
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

--[[
|---------------------------------------|
| Config: Secure/UI button animation 	|
|---------------------------------------|
]]--
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
			UIFrameFadeIn(AniFrame.dest.background, 1.5, 0.25, 1)
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


--[[
|---------------------------------------|
| Config: Returns events for mouselook	|
|---------------------------------------|
]]--
local function GetMouseSettings()
	return {
		{ 	event 	= {"PLAYER_STARTED_MOVING"},
			desc 	= "Player starts moving",
			toggle 	= ConsolePortMouseSettings["PLAYER_STARTED_MOVING"]
		},
		{ 	event	= {"PLAYER_TARGET_CHANGED"},
			desc 	= "Player changes target",
			toggle 	= ConsolePortMouseSettings["PLAYER_TARGET_CHANGED"]
		},
		{	event 	= {"CURRENT_SPELL_CAST_CHANGED"},
			desc 	= "Player casts a direct spell",
			toggle 	= ConsolePortMouseSettings["CURRENT_SPELL_CAST_CHANGED"]
		},
		{	event 	= {"GOSSIP_SHOW", "GOSSIP_CLOSED"},
			desc 	= "NPC interaction",
			toggle 	= ConsolePortMouseSettings["GOSSIP_SHOW"]
		},
		{	event 	= {"MERCHANT_SHOW", "MERCHANT_CLOSED"},
			desc 	= "Merchant interaction", 
			toggle 	= ConsolePortMouseSettings["MERCHANT_SHOW"]
		},
		{	event	= {"TAXIMAP_OPENED", "TAXIMAP_CLOSED"},
			desc 	= "Flight master interaction",
			toggle 	= ConsolePortMouseSettings["TAXIMAP_OPENED"]
		},
		{	event	= {"QUEST_GREETING", "QUEST_DETAIL", "QUEST_PROGRESS", "QUEST_COMPLETE", "QUEST_FINISHED"},
			desc 	= "Quest giver interaction",
			toggle 	= ConsolePortMouseSettings["QUEST_GREETING"]
		},
		{ 	event	= {"QUEST_AUTOCOMPLETE"},
			desc 	= "Popup quest completion",
			toggle 	= ConsolePortMouseSettings["QUEST_AUTOCOMPLETE"]
		},
		{ 	event 	= {"SHIPMENT_CRAFTER_OPENED", "SHIPMENT_CRAFTER_CLOSED"},
			desc 	= "Garrison work order",
			toggle 	= ConsolePortMouseSettings["SHIPMENT_CRAFTER_OPENED"]
		},
		{	event	= {"LOOT_OPENED"},
			desc 	= "Loot window opened",
			toggle 	= ConsolePortMouseSettings["LOOT_OPENED"]
		},
		{	event	= {"LOOT_CLOSED"},
			desc 	= "Loot window closed",
			toggle 	= ConsolePortMouseSettings["LOOT_CLOSED"]
		}
	}
end

--[[
|---------------------------------------|
| Config: Add static binding to new set |
|---------------------------------------|
]]--
local function ChangeBinding(bindingName, bindingTitle)
	CONF_BUTTON:SetText(bindingTitle)
	if not NewBindingSet then
		NewBindingSet = Copy(ConsolePortBindingSet)
	end
	local modifiers = {
		["SHIFT"] 		= "shift",
		["CTRL"]		= "ctrl",
		["CTRL-SHIFT"] 	= "ctrlsh",
	}
	local modifier = modifiers[BIND_MODIFIER] or "action"
	NewBindingSet[BIND_TARGET][modifier] = bindingName
end

local function ResetGuides()
	for i, guide in pairs(db.HotKeys) do
		guide:SetTexture(nil)
		if 	guide:GetParent().HotKey then
			guide:GetParent().HotKey:SetAlpha(1)
		end
	end
end


--[[
|---------------------------------------|
| Config: Reload, save and revert binds |
|---------------------------------------|
]]--
local function ReloadBindings()
	ConsolePort:ReloadBindingActions()
	ConsolePort:LoadBindingSet()
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



--[[
|---------------------------------------|
| Config: Dropdown keybinding table   	|
|---------------------------------------|
]]--
local function GenerateBindingsTable()
	local BindingsTable = {}
	local SubTables = {
		{name = "Movement keys", 		start = 8,		stop = 15 },
		{name = "Chat", 				start = 16, 	stop = 25 },
		{name = "Action Bar", 			start =	26, 	stop = 37 },
		{name = "Extra Bar", 			start = 38,		stop = 58 },
		{name = "Action Page", 			start = 59,		stop = 66 },
		{name = "Left Bottom Bar",		start = 69,		stop = 80 },
		{name = "Right Bottom Bar", 	start = 82,		stop = 93 },
		{name = "Right Side Bar", 		start = 95,		stop = 106},
		{name = "Left Side Bar", 		start = 108,	stop = 119},
		{name = "Target (tab)", 		start = 120,	stop = 128},
		{name = "Target friend", 		start = 129,	stop = 137},
		{name = "Target enemy", 		start = 138,	stop = 149},
		{name = "Target general",		start = 150,	stop = 162},
		{name = "Bags and menu", 		start = 163,	stop = 169},
		{name = "Character", 			start = 171, 	stop = 174},
		{name = "Spells and talents", 	start = 176,	stop = 181},
		{name = "Quest and map", 		start = 186, 	stop = 192},
		{name = "Social", 				start = 194, 	stop = 200},
		{name = "PvE / PvP",			start = 202, 	stop = 204},
		{name = "Collections",			start = 206, 	stop = 210},
		{name = "Information",			start = 212, 	stop = 213},
		{name = "Miscellaneous",		start = 214,	stop = 228},
		{name = "Camera",				start = 229,	stop = 248},
		{name = "Target Markers",		start = 249,	stop = 257},
		{name = "Vehicle Controls",		start = 258, 	stop = 266}
	}
	for _, item in ipairs(SubTables) do
		local t = {}
		local SubMenu =  {
			text = item.name,
			hasArrow = true,
			notCheckable = true
		}
		for i=item.start, item.stop do
			local bind = _G[BIND..GetBinding(i)]
			local binding = {
				text = bind,
				notCheckable = true,
				func = function() ChangeBinding(GetBinding(i), bind) CloseDropDownMenus() end
			}
			tinsert(t, binding)
		end
		SubMenu.menuList = t
		tinsert(BindingsTable, SubMenu)
	end
	local ExtraBind = "CLICK ConsolePortExtraButton:LeftButton"
	local binding = {
		text = _G[BIND..ExtraBind],
		notCheckable = true,
		func = function() ChangeBinding(ExtraBind, _G[BIND..ExtraBind]) end
	}
	tinsert(BindingsTable, binding)
	return BindingsTable
end 

local bindMenu = GenerateBindingsTable()
local bindMenuFrame = CreateFrame("Frame", "ConsolePortBindMenu", UIParent, "UIDropDownMenuTemplate")


--[[
|---------------------------------------|
| Config: Static blizzard API button  	|
|---------------------------------------|
]]--
local function CreateConfigStaticButton(name, modifier, modNum)
	local title = name.."%s"..CONF
	local title = 	modifier == "SHIFT" 		and format(title, SHIFT) 	or
					modifier == "CTRL"			and format(title, CTRL) 	or
					modifier == "CTRL-SHIFT" 	and format(title, CTRLSH) 	or format(title, NOMOD)
	local button = CreateFrame("BUTTON", title, db.Binds.Rebind, "UIMenuButtonStretchTemplate")
	button.hasPriority = modifier == nil
	button.indicator = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.indicator:SetPoint("LEFT", button, "LEFT", 4, 0)
	button:SetSize(320, 40)
	button:SetPoint("TOPLEFT", db.Binds.Rebind, 10, -40*modNum-28)
	button.OnShow = function(self)
		local key1, key2 = GetBindingKey(name)
		if key1 then self.key1 = key1 end
		if key2 then self.key2 = key2 end
		if key1 or key2 then
			local key
			if key1 then key = key1 else key = key2 end
			if modifier then key = modifier.."-"..key end
			self:SetText(_G[BIND..GetBindingAction(key, true)])
			self.indicator:SetText(self.icon)
		end
	end

	button:SetScript("OnShow", button.OnShow)
	button:SetScript("OnClick", function(self, button, down)
		BIND_TARGET = name
		CONF_BUTTON = self
		BIND_MODIFIER = modifier
		if DropDownList1:IsVisible() then
			db.Binds.Tutorial:SetText(format(TUTORIAL.COMBO, db.Binds.Rebind.button.bindings[1].icons))
			CloseDropDownMenus()
		else
			db.Binds.Tutorial:SetText(format(TUTORIAL.STATIC, self.indicator:GetText()))
			EasyMenu(bindMenu, bindMenuFrame, self, 320 , 0, "MENU")
		end
	end)
	if not db.Binds.Buttons[name] then
		db.Binds.Buttons[name] = {}
	end
	tinsert(db.Binds.Buttons[name], button)
end


--[[
|---------------------------------------|
| Config: Dynamic secure/UI button  	|
|---------------------------------------|
]]--
function ConsolePort:CreateConfigButton(name, mod, modNum)
	local button = CreateFrame("BUTTON", name..mod..CONF, db.Binds.Rebind, "UIMenuButtonStretchTemplate")
	button:SetBackdrop(nil)
	button:SetSize(320,40)
	button:SetPoint("TOPLEFT", db.Binds.Rebind, "TOPLEFT", 10, -40*modNum-28)
	button.hasPriority = mod == NOMOD

	button.indicator = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.indicator:SetPoint("LEFT", button, "LEFT", 4, 0)

	button.background = button:CreateTexture(nil, "OVERLAY")
	button.background:SetPoint("RIGHT", button, "RIGHT", -4, 0)
	button.background:SetSize(34, 34)

	button.secure = _G[name..mod]
	button.OnShow = function(self)
		self:SetText(self.secure.action:GetName())
		self.indicator:SetText(self.icon)
		if self.secure.action.icon and self.secure.action.icon:IsVisible() then
			self.background:SetTexture(self.secure.action.icon:GetTexture())
		else
			self.background:SetTexture(nil)
		end
	end
	button:SetScript("OnShow", button.OnShow)
	button:SetScript("OnClick", function(self, mouseButton)
		if not InCombatLockdown() then
			if not ConsolePortRebindFrame.isRebinding then
				db.Binds.Tutorial:SetText(format(TUTORIAL.DYNAMIC, self.indicator:GetText(), db.Binds.Apply, db.Binds.Cancel))
				ConsolePort:SetRebinding(self)
				ConsolePort:SetCurrentNode(self.secure.action)
			else
				if mouseButton == "LeftButton" then
					local frame = ConsolePort:GetCurrentNode()
					local name = frame:GetName()
					if ConsolePort:ChangeButtonBinding(self.secure) then
						db.Binds.Tutorial:SetText(format(TUTORIAL.APPLIED, self.indicator:GetText(), name))
					else
						db.Binds.Tutorial:SetText(TUTORIAL.INVALID)
					end
				else
					db.Binds.Tutorial:SetText(format(TUTORIAL.COMBO, db.Binds.Rebind.button.bindings[1].icons))
				end
				ConsolePort:SetRebinding(false)
				ConsolePort:SetCurrentNode(self)
				ConsolePort:SetButtonActions("UIControl")
				ConsolePort:UIControl(KEY.PREPARE, KEY.STATE_DOWN)
			end
		end
	end)
	button:SetAlpha(1)
	button:Show()
	if not db.Binds.Buttons[name] then
		db.Binds.Buttons[name] = {}
	end
	tinsert(db.Binds.Buttons[name], button)
end	


--[[
|---------------------------------------|
| Config: Create addon dummy bindings  	|
|---------------------------------------|
]]--
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


--[[
|---------------------------------------|
| Config: Hotkey guides on UI button 	|
|---------------------------------------|
]]--
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


--[[
|---------------------------------------|
| Config: Reload bindings from table 	|
|---------------------------------------|
]]--
function ConsolePort:ReloadBindingAction(button, action, name, mod1, mod2)
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
end

function ConsolePort:ReloadBindingActions()
	local keys = NewBindingButtons or ConsolePortBindingButtons
	for name, key in pairs(keys) do
		if key.action then 
			self:ReloadBindingAction(_G[name..NOMOD], _G[key.action], name, nil, nil)
		end
		if key.ctrl then
			self:ReloadBindingAction(_G[name..CTRL], _G[key.ctrl], name, "CP_TR4", nil)
		end
		if key.shift then
			self:ReloadBindingAction(_G[name..SHIFT], _G[key.shift], name, "CP_TR3", nil)
		end
		if key.ctrlsh then
			self:ReloadBindingAction(_G[name..CTRLSH], _G[key.ctrlsh], name, "CP_TR4", "CP_TR3")
		end
	end
end


--[[
|---------------------------------------|
| Config: Secure button binding change 	|
|---------------------------------------|
]]--
function ConsolePort:ChangeButtonBinding(actionButton)
	local buttonName 	= actionButton:GetName()
	local confButton 	= _G[buttonName..CONF]
	local tableIndex 	= actionButton.name
	local modifier 		= actionButton.mod
	local focusFrame 	= ConsolePort:GetCurrentNode()
	local focusFrameName = focusFrame:GetName()
	if 	focusFrameName and
		focusFrame:IsObjectType("Button") and
		focusFrame:GetParent() ~= ConsolePortRebindFrame then
		confButton:SetText(focusFrameName)
		AnimateBindingChange(focusFrame, confButton)
		if not NewBindingButtons then
			NewBindingButtons = Copy(ConsolePortBindingButtons)
		end
		local modName = {
			_NOMOD 		= "action",
			_SHIFT 		= "shift",
			_CTRL 		= "ctrl",
			_CTRLSH 	= "ctrlsh",
		}
		NewBindingButtons[tableIndex][modName[modifier]] = focusFrameName
		ResetGuides()
		ReloadBindings()
		return true
	end
end


--[[
|---------------------------------------|
| Config: Binding palette show function |
|---------------------------------------|
]]--
local function BindingsOnShow(self)
	self.Tutorial:SetText(TUTORIAL.DEFAULT)
	self.Rebind:Hide()
	self.dropdown:initialize()
end


--[[
|---------------------------------------|
| Config: Import profile functions 		|
|---------------------------------------|
]]--
local function ImportOnClick(self)
	if not InCombatLockdown() then
		local character = self:GetParent().dropdown.text:GetText()
		local settings = ConsolePortCharacterSettings[character]
		if settings then
			db.Binds.Tutorial:SetText(format(TUTORIAL.IMPORT, character))
			NewBindingSet = Copy(settings.BindingSet)
			NewBindingButtons = Copy(settings.BindingBtn)
			ReloadBindings()
			ConsolePort:SetButtonActions("UIControl")
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
	ConsolePortCharacterSettings[UIDropDownMenu_GetText(self:GetParent().dropdown)] = nil
	BindingsOnShow(self:GetParent())
end


--[[
|---------------------------------------|
| Config: Save mouse info/reload events |
|---------------------------------------|
]]--
local function SaveMouseConfig(self)
	for i, Check in pairs(self.Events) do
		for i, Event in pairs(Check.Events) do
			ConsolePortMouseSettings[Event] = Check:GetChecked()
		end
	end
	ConsolePort:LoadEvents()
end


--[[
|---------------------------------------|
| Config: Binding buttons and tooltip	|
|---------------------------------------|
]]--
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


--[[
|---------------------------------------|
| Config: Create panel and children		|
|---------------------------------------|
]]--
function ConsolePort:CreateConfigPanel()
	if not db.Config then

		local player = GetUnitName("player").."-"..GetRealmName()

		local Config = CreateFrame("FRAME", addOn.."ConfigFrame", InterfaceOptionsFramePanelContainer)
		local Binds = CreateFrame( "FRAME", addOn.."ConfigFrameBinds", Config)
		local Mouse = CreateFrame("FRAME", addOn.."ConfigFrameMouse", Config)

		db.Config	= Config
		db.Binds	= Binds
		db.Mouse 	= Mouse 

		Config.name = addOn
		Config.okay = SaveMainConfig
	
		Binds.name = "Bindings"
		Binds.parent = addOn
		Binds.okay = SubmitBindings
		Binds.cancel = RevertBindings

		Binds.Controller = Binds:CreateTexture("GameMenuTextureController", "ARTWORK");
		Binds.Controller:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Splash\\Splash"..ConsolePortSettings.type);
		Binds.Controller:SetPoint("CENTER", Binds, "CENTER");

		Binds.Header = Binds:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		Binds.Header:SetText("Binding settings")
		Binds.Header:SetPoint("TOPLEFT", Binds, 16, -16)

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
					self.info.checked = self.info.text == GetUnitName("player").."-"..GetRealmName()
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
			button.isSecureButton = _G[buttonName..NOMOD] and true
			button.texture = format(button.icon, GetDefaultGuideTexture(buttonName))
			button:SetPoint("TOPLEFT", Binds.Controller, "TOPLEFT", position.X, position.Y)
			button:SetSize(30, 30)
			button:SetScript("OnEnter", SetBindingTooltip)
			button:SetScript("OnClick", function(self) Binds.Rebind:SetButton(self) ConsolePort:SetCurrentNode(Binds.Buttons[button.name][1]) end)
			button:SetScript("OnLeave", function(self) if GameTooltip:GetOwner() == self then GameTooltip:Hide() end end)
		end

		Binds.Rebind = CreateFrame("Frame", addOn.."RebindFrame", Binds, "UIPanelDialogTemplate")
		Binds.Rebind:SetPoint("BOTTOM", Binds, "BOTTOM", 0, 0)
		Binds.Rebind:SetSize(336, 200)
		Binds.Rebind:Hide()

		Binds.Rebind.SetButton = RebindSetButton
		Binds.Rebind.Close = ConsolePortRebindFrameClose
		Binds.Rebind.Parent = Binds
		Binds.Rebind:SetScript("OnHide", function (self) Binds.Tutorial:SetText(TUTORIAL.DEFAULT) ConsolePort:SetRebinding() end)
		Binds.Rebind.Close:HookScript("OnClick", function(self) CloseDropDownMenus() end)
		Binds.Rebind:RegisterEvent("PLAYER_REGEN_DISABLED")
		Binds.Rebind:SetScript("OnEvent", Binds.Rebind.Hide)

		Binds.IconFormat = "|T%s:24:24:0:0|t"
		Binds.Cancel = format(Binds.IconFormat, TEXTURE.SQUARE or TEXTURE.X)
		Binds.Apply = format(Binds.IconFormat, TEXTURE.CIRCLE or TEXTURE.B)

		self:AddFrame(Binds.Rebind)

		-- Static bindings able to call protected Blizzard API
		local optionButtons = {
			{option = "CP_X_OPTION", icon = db.NAME.CP_X_OPTION},
			{option = "CP_C_OPTION", icon = db.NAME.CP_C_OPTION},
			{option = "CP_L_OPTION", icon = db.NAME.CP_L_OPTION},
			{option = "CP_R_OPTION", icon = db.NAME.CP_R_OPTION},
		}
		for i, button in pairs(optionButtons) do
			CreateConfigStaticButton(button.option, nil, 0);
			CreateConfigStaticButton(button.option, "SHIFT", 1);
			CreateConfigStaticButton(button.option, "CTRL", 2);
			CreateConfigStaticButton(button.option, "CTRL-SHIFT", 3);
		end

		Mouse.name 	= "Mouse"
		Mouse.parent = addOn
		Mouse.okay 	= SaveMouseConfig

		Mouse.Events = {}
		Mouse.Header = Mouse:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		Mouse.Header:SetText("Toggle mouse look when...")
		Mouse.Header:SetPoint("TOPLEFT", Mouse, 16, -16)
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

		InterfaceOptions_AddCategory(Config)
		InterfaceOptions_AddCategory(Binds)
		InterfaceOptions_AddCategory(Mouse)
		
	end
end
