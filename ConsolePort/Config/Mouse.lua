---------------------------------------------------------------
-- Mouse.lua (config): Mouse look events, button overrides
---------------------------------------------------------------
-- Provides management for events that trigger mouse look.
-- Provides management for UI cursor button overrides.

local addOn, db = ...
local TEXTURE = db.TEXTURE
local TUTORIAL = db.TUTORIAL.MOUSE
---------------------------------------------------------------
-- Mouse: Returns events for mouselook
---------------------------------------------------------------
local function GetMouseSettings()
	return {
		{ 	event 	= {"PLAYER_STARTED_MOVING"},
			desc 	= TUTORIAL.STARTED_MOVING,
			toggle 	= ConsolePortMouse.Events["PLAYER_STARTED_MOVING"]
		},
		{ 	event	= {"PLAYER_TARGET_CHANGED"},
			desc 	= TUTORIAL.TARGET_CHANGED,
			toggle 	= ConsolePortMouse.Events["PLAYER_TARGET_CHANGED"]
		},
		{	event 	= {"CURRENT_SPELL_CAST_CHANGED"},
			desc 	= TUTORIAL.DIRECT_SPELL_CAST,
			toggle 	= ConsolePortMouse.Events["CURRENT_SPELL_CAST_CHANGED"]
		},
		{	event 	= {	"GOSSIP_SHOW", "GOSSIP_CLOSED",
						"MERCHANT_SHOW", "MERCHANT_CLOSED",
						"TAXIMAP_OPENED", "TAXIMAP_CLOSED",
						"QUEST_GREETING", "QUEST_DETAIL",
						"QUEST_PROGRESS", "QUEST_COMPLETE", "QUEST_FINISHED"},
			desc 	= TUTORIAL.NPC_INTERACTION,
			toggle 	= ConsolePortMouse.Events["GOSSIP_SHOW"]
		},
		{ 	event	= {"QUEST_AUTOCOMPLETE"},
			desc 	= TUTORIAL.QUEST_AUTOCOMPLETE,
			toggle 	= ConsolePortMouse.Events["QUEST_AUTOCOMPLETE"]
		},
		{ 	event 	= {"SHIPMENT_CRAFTER_OPENED", "SHIPMENT_CRAFTER_CLOSED"},
			desc 	= TUTORIAL.GARRISON_ORDER,
			toggle 	= ConsolePortMouse.Events["SHIPMENT_CRAFTER_OPENED"]
		},
		{	event	= {"LOOT_OPENED"},
			desc 	= TUTORIAL.LOOT_OPENED,
			toggle 	= ConsolePortMouse.Events["LOOT_OPENED"]
		},
		{	event	= {"LOOT_CLOSED"},
			desc 	= TUTORIAL.LOOT_CLOSED,
			toggle 	= ConsolePortMouse.Events["LOOT_CLOSED"]
		}
	}
end
---------------------------------------------------------------
-- Mouse: Save mouse info/reload events
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
	ConsolePort:LoadControllerTheme()
end

tinsert(db.Panels, {"ConsolePortConfigFrameConfig", "Mouse", TUTORIAL.SIDEBAR, TUTORIAL.HEADER, SaveMouseConfig, false, false, function(self, Mouse)
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
	Mouse.CursorHeader:SetText(TUTORIAL.VIRTUALCURSOR)
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
		CP_R_RIGHT 	= TEXTURE.CP_R_RIGHT,
		CP_R_LEFT 	= TEXTURE.CP_R_LEFT,
		CP_R_UP		= TEXTURE.CP_R_UP,
		CP_R_DOWN	= TEXTURE.CP_R_DOWN,
	}

	local scrollButtons = {
		CP_TL1 		= TEXTURE.CP_TL1,
		CP_TL2 		= TEXTURE.CP_TL2,
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
end})


