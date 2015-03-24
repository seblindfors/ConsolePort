local _
local _, G = ...;
local BUTTON_HEIGHT	 	= 40;
local BUTTON_WIDTH 	 	= 180;
local OVERLAY_WIDTH		= 170;
local OVERLAY_HEIGHT	= 34;

local BIND_TARGET 	 	= false;
local BIND_MODIFIER 	= nil;
local CONF_BUTTON 		= nil;

local CP				= "CP";
local CONF				= "_CONF";
local CHECK 			= "_CHECK";
local CONFBG			= "_CONF_BG";
local GUIDE				= "_GUIDE";
local NOMOD				= "_NOMOD";
local SHIFT				= "_SHIFT";
local CTRL				= "_CTRL";
local CTRLSH			= "_CTRLSH";
local TEXTURE			= "TEXTURE_";
local BIND 				= "BINDING_NAME_";

local ConsolePortSaveBindingSet = nil;
local ConsolePortSaveBindings = nil;

G.HotKeys = {};

local function AnimateBindingChange(target, destination)
	if not ConsolePortAnimationFrame then
		local f = CreateFrame("FRAME", "ConsolePortAnimationFrame");
		local t = f:CreateTexture();
		local aniGroup = f:CreateAnimationGroup();
		local ani = aniGroup:CreateAnimation("Translation");
		f:SetFrameStrata("TOOLTIP");
		f:SetSize(40,40);
		t:SetAllPoints(f);
		f.texture = t;
		f.group = aniGroup;
		f.animation = ani;
		f.correction = 0.725;
		ani:SetDuration(0.6);
		ani:SetSmoothing("OUT");
		aniGroup:SetScript("OnPlay", function()
			f:Show();
		     ActionButton_ShowOverlayGlow(f.target);
		end);
		aniGroup:SetScript("OnFinished", function()
			f:Hide();
			if f.target.icon then
				f.dest.background.texture:SetTexture(f.target.icon:GetTexture());
			else
				f.dest.background.texture:SetTexture(nil);
			end
			UIFrameFadeIn(f.dest.background, 1.5, 1, 0.25);
			ActionButton_HideOverlayGlow(f.target);
		end);
	end
	local f = ConsolePortAnimationFrame;
	local dX, dY = destination:GetCenter();
	local tX, tY = target:GetCenter();
	if target.icon then
		f.texture:SetTexture(target.icon:GetTexture());
	else
		f.texture:SetTexture("Interface\\TUTORIALFRAME\\UI-TutorialFrame-GloveCursor");
	end
	f.target = target;
	f.dest = destination;
	f:SetPoint("CENTER", target, "CENTER", 0,0);
	f.animation:SetOffset((dX-tX)*f.correction, (dY-tY)*f.correction);
	f.group:Play();
end

local function GetMouseSettings()
	local mouseSettings = {
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
		{	event	= {"LOOT_CLOSED"},
			desc 	= "Loot window closed",
			toggle 	= ConsolePortMouseSettings["LOOT_CLOSED"]
		}
	}
	return mouseSettings;
end

local function ChangeBinding(bindingName, bindingTitle)
	CONF_BUTTON:SetText(bindingTitle);
	if not ConsolePortSaveBindingSet then
		ConsolePortSaveBindingSet = ConsolePortBindingSet;
	end
	local modifier;
	if not BIND_MODIFIER then modifier = "action";
	elseif BIND_MODIFIER == "SHIFT" then modifier = "shift";
	elseif BIND_MODIFIER == "CTRL" then modifier = "ctrl";
	elseif BIND_MODIFIER == "CTRL-SHIFT" then modifier = "ctrlsh"; end;
	ConsolePortSaveBindingSet[BIND_TARGET][modifier] = bindingName;
end

local function SubmitBindings()
	if ConsolePortSaveBindingSet or ConsolePortSaveBindings then
		if not InCombatLockdown() then
			for i, guide in pairs(G.HotKeys) do
				guide:SetTexture(nil);
				if 	guide:GetParent().HotKey then
					guide:GetParent().HotKey:SetAlpha(1);
				end
			end
			ConsolePort:ReloadBindingActions();
			ConsolePort:LoadBindingSet();
		else
			ReloadUI();
		end
	end
end

local function GenerateBindingsTable()
	local BindingsTable = {};
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
		local t = {};
		local SubMenu =  {
			text = item.name,
			hasArrow = true,
			notCheckable = true
		}
		for i=item.start, item.stop do
			local binding = {
				text = _G["BINDING_NAME_"..GetBinding(i)],
				notCheckable = true,
				func = function() ChangeBinding(GetBinding(i), _G["BINDING_NAME_"..GetBinding(i)]); end
			}
			tinsert(t, binding);
		end
		SubMenu.menuList = t;
		tinsert(BindingsTable, SubMenu);
	end
	return BindingsTable;
end 

local bindMenu = GenerateBindingsTable();
local bindMenuFrame = CreateFrame("Frame", "ConsolePortBindMenu", UIParent, "UIDropDownMenuTemplate")

local function CreateConfigStaticButton(name, modifier, xoffset, yoffset)
	local title;
	if 		modifier == "SHIFT" 	 then title = name..SHIFT..CONF;
	elseif 	modifier == "CTRL" 		 then title = name..CTRL..CONF;
	elseif 	modifier == "CTRL-SHIFT" then title = name..CTRLSH..CONF;
	else 	title = name..NOMOD..CONF;
	end
	local b = CreateFrame("BUTTON", title, G.binds, "UIMenuButtonStretchTemplate");
	b:SetWidth(BUTTON_WIDTH);
	b:SetHeight(BUTTON_HEIGHT);
	b:SetPoint("TOPLEFT", G.binds, xoffset*BUTTON_WIDTH-60, -BUTTON_HEIGHT*yoffset);
	b.OnShow = function(self)
		local key1, key2 = GetBindingKey(name);
		if key1 then b.key1 = key1; end;
		if key2 then b.key2 = key2; end;
		if key1 or key2 then
			local key;
			if key1 then key = key1; else key = key2; end;
			if modifier then key = modifier.."-"..key; end;
			b:SetText(_G[BIND..GetBindingAction(key, true)]);
		end
	end
	b:SetScript("OnShow", b.OnShow);
	b:SetScript("OnClick", function(self, button, down)
		BIND_TARGET = name;
		CONF_BUTTON = self;
		BIND_MODIFIER = modifier;
		EasyMenu(bindMenu, bindMenuFrame, "cursor", 0 , 0, "MENU");
	end);
end

function ConsolePort:CreateConfigButton(name, xoffset, yoffset)
	local f = CreateFrame("FRAME", name..CONFBG, G.binds);
	local b = CreateFrame("BUTTON", name..CONF, G.binds, "UIMenuButtonStretchTemplate");
	local t = f:CreateTexture(nil, "background");
	local a = _G[name];
	b:SetBackdrop(nil);
	b:SetWidth(BUTTON_WIDTH);
	b:SetHeight(BUTTON_HEIGHT);
	b:SetPoint("TOPLEFT", G.binds, xoffset*BUTTON_WIDTH-60, -BUTTON_HEIGHT*yoffset);
	t:SetTexCoord(0.05, 0.95, 0.45, 0.65);
	t:SetAllPoints(f);
	f.texture = t;
	f:SetPoint("CENTER", b);
	f:SetWidth(OVERLAY_WIDTH);
	f:SetHeight(OVERLAY_HEIGHT);
	f:SetAlpha(0.25);
	f:Show();
	b.background = f;
	b.secure = a;
	b.OnShow = function(self)
		self:SetText(a.action:GetName());
		if a.action.icon and a.action.icon:IsVisible() then
			self.background.texture:SetTexture(a.action.icon:GetTexture());
		else
			self.background.texture:SetTexture(nil);
		end
	end
	b:SetScript("OnShow", b.OnShow);
	b:SetScript("OnClick", function()
		ConsolePort:ChangeButtonBinding(a);
	end);
	b:SetAlpha(1);
	b:Show();
end	

function ConsolePort:CreateIndicator(parent, size, anchor, button)
	local f = CreateFrame("BUTTON", nil, parent);
	local t = f:CreateTexture(nil, "BACKGROUND");
	local o = f:CreateTexture(nil, "OVERLAY");
	button = string.upper(button);
	f.texture = t;
	f.overlay = o;
	o:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder.blp");
	o:SetPoint("TOPLEFT", f, G["GUIDE_BORDER_X_"..size], G["GUIDE_BORDER_Y_"..size]);
	o:SetWidth(G["GUIDE_BORDER_S_"..size]);
	o:SetHeight(G["GUIDE_BORDER_S_"..size]);
	t:SetTexture(G[TEXTURE..button]);
	t:SetAllPoints(f);
	f:SetPoint(anchor, parent, G["GUIDE_BUTTON_"..anchor.."_"..size.."_X"], G["GUIDE_BUTTON_"..anchor.."_"..size.."_Y"]);
	f:SetWidth(G["GUIDE_BUTTON_S_"..size]);
	f:SetHeight(G["GUIDE_BUTTON_S_"..size]);
	f:SetAlpha(1);
	f:SetScript("OnShow", function(self)
		UIFrameFadeIn(self, 0.3, 0, 1);
	end);
	f:Show();
	return f;
end

--ConsolePort:CreateIndicator(parent, size, anchor, button)
function ConsolePort:CreateConfigGuideButton(name, title, parent, xoffset, yoffset)
	local f = CreateFrame("Frame", name..GUIDE, parent);
	local fN = title;
	if 		string.find(fN, "Trigger 1") then fN = "RONE";
	elseif 	string.find(fN, "Trigger 2") then fN = "RTWO"; end;
	f.guide = ConsolePort:CreateIndicator(f, "SMALL", "CENTER", fN);
	f.guide:SetScript("OnShow", nil);
	f:SetPoint("TOPLEFT", parent, xoffset+20, -BUTTON_HEIGHT*yoffset);
	f:SetWidth(100);
	f:SetHeight(BUTTON_HEIGHT);
	f:SetAlpha(1);
	f.guide:SetAlpha(0.5);
	f:Show();
	return f;
end


function ConsolePort:LoadBindingSet()
	local keys = ConsolePortSaveBindingSet or ConsolePortBindingSet;
	local w = WorldFrame;
	ClearOverrideBindings(w);
	for name, key in pairs(keys) do
		if key.action 	then ConsolePort:OverrideBinding(w, true, nil, 			name, key.action);	end
		if key.ctrl 	then ConsolePort:OverrideBinding(w, true, "CTRL", 		name, key.ctrl); 	end 
		if key.shift 	then ConsolePort:OverrideBinding(w, true, "SHIFT",		name, key.shift); 	end
		if key.ctrlsh 	then ConsolePort:OverrideBinding(w, true, "CTRL-SHIFT", name, key.ctrlsh);	end
	end
end

function ConsolePort:GetDefaultGuideTexture(button)
	if 		button == "CP_TR1" 		then return G.TEXTURE_RONE;
	elseif 	button == "CP_TR2" 		then return G.TEXTURE_RTWO;
	elseif 	button == "CP_TR3" 		then return G.TEXTURE_LONE;
	elseif 	button == "CP_TR4" 		then return G.TEXTURE_LTWO;
	else 	return G[TEXTURE..string.upper(G["NAME_"..button])];
	end
end

function ConsolePort:UpdateActionGuideTexture(button, key, mod1, mod2)
	if button.HotKey then
		button.HotKey:SetAlpha(0);
	end
	if not button.guide then
		button.guide = button:CreateTexture();
		button.guide:SetPoint("TOPRIGHT", button, 0, 0);
		button.guide:SetSize(14, 14);
		tinsert(G.HotKeys, button.guide);
	end
	button.guide:SetTexture(ConsolePort:GetDefaultGuideTexture(key));
	ConsolePort:UpdateModifiedActionGuideTexture(button, mod1, "TOP");
	ConsolePort:UpdateModifiedActionGuideTexture(button, mod2, "TOPLEFT");
end

function ConsolePort:UpdateModifiedActionGuideTexture(button, modifier, anchor)
	local mod;
	if 		anchor == "TOP"  	then mod = "mod1";
	elseif 	anchor == "TOPLEFT" then mod = "mod2"; end;
	if  modifier and not button[mod] then
		button[mod] = button:CreateTexture();
		button[mod]:SetPoint(anchor, button, 0, 0);
		button[mod]:SetSize(14, 14);
		tinsert(G.HotKeys, button.guide);
	elseif not modifier and button[mod] then
		button[mod]:Hide();
	end
	if 	modifier then
		button[mod]:SetTexture(ConsolePort:GetDefaultGuideTexture(modifier));
	end
end

function ConsolePort:ReloadBindingAction(button, action, name, mod1, mod2)
	button.action = action;
	button.reset();
	button.revert();
	if 	button.action:GetParent() == MainMenuBarArtFrame and
		button.action.action and button.action:GetID() <= 6 then
		ConsolePort:UpdateActionGuideTexture(_G["OverrideActionBarButton"..button.action:GetID()], name, mod1, mod2);
	end
	ConsolePort:UpdateActionGuideTexture(button.action, name, mod1, mod2);
	if button.action.HotKey then
		button.action.HotKey:SetAlpha(0);
	end
end

function ConsolePort:ReloadBindingActions()
	local keys = ConsolePortSaveBindings or ConsolePortBindingButtons;
	for name, key in pairs(keys) do
		if key.action then 
			ConsolePort:ReloadBindingAction(_G[name..NOMOD], _G[key.action], name, nil, nil);
		end
		if key.ctrl then
			ConsolePort:ReloadBindingAction(_G[name..CTRL], _G[key.ctrl], name, "CP_TR4", nil);
		end
		if key.shift then
			ConsolePort:ReloadBindingAction(_G[name..SHIFT], _G[key.shift], name, "CP_TR3", nil);
		end
		if key.ctrlsh then
			ConsolePort:ReloadBindingAction(_G[name..CTRLSH], _G[key.ctrlsh], name, "CP_TR4", "CP_TR3");
		end
	end
end

function ConsolePort:ChangeButtonBinding(actionButton)
	local buttonName = actionButton:GetName();
	local confButton = _G[buttonName..CONF];
	local confString = _G[actionButton.name..GUIDE];
	local tableIndex = actionButton.name;
	local modfierBtn = actionButton.mod;
	local focusFrame = GetMouseFocus();
	local focusFrameName = focusFrame:GetName();
	local NotConfigButton = focusFrame:GetParent() ~= G.binds;
	local TARGET_VALID = 	focusFrame:IsObjectType("Button") and
							focusFrameName ~= confButton:GetText() and
							NotConfigButton;
	if confButton:GetButtonState() == "PUSHED" then
		confButton:SetButtonState("NORMAL");
		confString.guide:SetAlpha(0.5);
		confButton:UnlockHighlight();
		if TARGET_VALID then
			confButton:SetText(focusFrameName);
			AnimateBindingChange(focusFrame, confButton);
			if not ConsolePortSaveBindings then
				ConsolePortSaveBindings = ConsolePortBindingButtons;
			end
			if 		modfierBtn == NOMOD 	then	ConsolePortSaveBindings[tableIndex].action 	= focusFrameName; 
			elseif 	modfierBtn == SHIFT 	then	ConsolePortSaveBindings[tableIndex].shift 	= focusFrameName; 
			elseif 	modfierBtn == CTRL 		then	ConsolePortSaveBindings[tableIndex].ctrl 	= focusFrameName; 
			elseif 	modfierBtn == CTRLSH 	then	ConsolePortSaveBindings[tableIndex].ctrlsh 	= focusFrameName;
			end
		end
	else 
		confButton:SetButtonState("PUSHED");
		confString.guide:SetAlpha(1);
		confButton:LockHighlight();
	end
end

function ConsolePort:SetButtonActionsConfig(set)
	local Buttons = ConsolePort:GetBindingButtons();
	if set and not InCombatLockdown() then
		for _, Button in ipairs(Buttons) do
			_G[Button..CTRL]:SetAttribute("type", 	"rebind");
			_G[Button..NOMOD]:SetAttribute("type", 	"rebind");
			_G[Button..SHIFT]:SetAttribute("type", 	"rebind");
			_G[Button..CTRLSH]:SetAttribute("type", "rebind");
		end
	elseif not InCombatLockdown() then
		for _, Button in ipairs(Buttons) do
			_G[Button..CTRL].revert();
			_G[Button..NOMOD].revert();
			_G[Button..SHIFT].revert();
			_G[Button..CTRLSH].revert();
		end
	end
end

function ConsolePort:CreateConfigPanel()
	if not G.panel then
		G.panel				= CreateFrame( "FRAME", "ConsolePortConfigFrame", InterfaceOptionsFramePanelContainer );
		G.panel.name		= "Console Port";
		G.panel.okay 		= function (self) SaveMainConfig(); end;
		G.panel.camCheck 	= CreateFrame("CheckButton", CP..CHECK.."_CAM", G.panel, "ChatConfigCheckButtonTemplate");
		G.panel.camCheck:SetPoint("TOPLEFT", 10, -50);
		G.panel.camCheck.tooltip = "Flip and zoom camera on interaction with NPCs";
		G.panel.camCheck:SetScript("OnClick", function(self, btn, down)
			if 	self:GetChecked() then
				ConsolePortSettings.cam = true;
			else
				ConsolePortSettings.cam = false;
			end
		end);

		-- Binding palette frame
		G.binds				= CreateFrame( "FRAME", nil, G.panel);
		G.binds.name		= "Bindings";
		G.binds.parent		= G.panel.name;
		G.binds.okay		= function (self) SubmitBindings(); end;
		G.binds:SetScript("OnShow", function(self)
			InterfaceOptionsFrame:SetWidth(1100);
			self:SetScript("OnUpdate", function(self, elapsed)
				if not InCombatLockdown() then
					InterfaceOptionsFrame:SetAlpha(1);
					ConsolePort:SetButtonActionsConfig(true);
				else
					InterfaceOptionsFrame:SetAlpha(0.2);
				end
				if not 	IsModifierKeyDown() then
					_G[CP..SHIFT..GUIDE].guide:SetAlpha(0.5);
					_G[CP..CTRL..GUIDE].guide:SetAlpha(0.5);
					_G[CP..CTRLSH.."1"..GUIDE].guide:SetAlpha(0.5);
					_G[CP..CTRLSH.."2"..GUIDE].guide:SetAlpha(0.5);
				elseif 	IsShiftKeyDown() and IsControlKeyDown() then
					_G[CP..SHIFT..GUIDE].guide:SetAlpha(0.5);
					_G[CP..CTRL..GUIDE].guide:SetAlpha(0.5);
					_G[CP..CTRLSH.."1"..GUIDE].guide:SetAlpha(1);
					_G[CP..CTRLSH.."2"..GUIDE].guide:SetAlpha(1);
				elseif 	IsShiftKeyDown() then
					_G[CP..SHIFT..GUIDE].guide:SetAlpha(1);
					_G[CP..CTRL..GUIDE].guide:SetAlpha(0.5);
					_G[CP..CTRLSH.."1"..GUIDE].guide:SetAlpha(0.5);
					_G[CP..CTRLSH.."2"..GUIDE].guide:SetAlpha(0.5);
				elseif	IsControlKeyDown() then
					_G[CP..SHIFT..GUIDE].guide:SetAlpha(0.5);
					_G[CP..CTRL..GUIDE].guide:SetAlpha(1);
					_G[CP..CTRLSH.."1"..GUIDE].guide:SetAlpha(0.5);
					_G[CP..CTRLSH.."2"..GUIDE].guide:SetAlpha(0.5);
				end
			end);
		end);
		G.binds:SetScript("OnHide", function(self)
			HelpPlate_Hide();
			ConsolePortSaveBindings = nil;
			ConsolePortSaveBindingSet = nil;
			ConsolePort:SetButtonActionsConfig(false);
			self:SetScript("OnUpdate", nil);
		end);

		G.binds.bgUpper = CreateFrame("FRAME", nil, G.binds, "InsetFrameTemplate");
		G.binds.bgUpper:SetSize(856, 398);
		G.binds.bgUpper:SetPoint("TOPLEFT", G.binds, "TOPLEFT", 4, -4);
		G.binds.bgLower = CreateFrame("FRAME", nil, G.binds, "InsetFrameTemplate");
		G.binds.bgLower:SetSize(856, 165);
		G.binds.bgLower:SetPoint("TOPLEFT", G.binds, "TOPLEFT", 4, -399);
		local tutorialCursor = "|TInterface\\AddOns\\ConsolePort\\Graphic\\TutorialCursor:64:128:0:0|t";
		local exampleTexture = G.TEXTURE_Y or G.TEXTURE_TRIANGLE;
		local exampleCombo = "|T"..G.TEXTURE_LONE..":20:20:0:0|t".."|T"..exampleTexture..":20:20:0:0|t";
		local dynamicString = "       |cFFFFD200[Rebind Instructions]|r\n\n1. Mouse over an action button\n2.  Press a button combination\n"..tutorialCursor.."+   "..exampleCombo;
		local staticString = "       |cFFFFD200[Rebind Instructions]|r\n\n1.   Click on a combination\n2. Choose action from the list\n";
		local modifierString = "              |cFFFFD200[Modifiers]|r\nThese columns represent all button combinations. Every button in the list to the left\nhas four combinations each.";
		local actionString = "          |cFFFFD200[Action Buttons]|r\nThese buttons can be used for abilities, macros and items. They are also used to control the interface.";
		local optionString = "          |cFFFFD200[Option Buttons]|r\nThese buttons can be used to perform any action defined in the regular key bindings.";
		G.binds.tutorials = {
			FramePos = { x = 0,	y = 0 },
			FrameSize = { width = 700, height = 600	},
			[1] = { ButtonPos = { x = 18,	y = -196},	HighLightBox = { x = 40, y = -40, width = 60, height = 360 },	ToolTipDir = "LEFT",	ToolTipText = actionString },
			[2] = { ButtonPos = { x = 18,	y = -456},	HighLightBox = { x = 40, y = -400, width = 60, height = 160 },	ToolTipDir = "LEFT",	ToolTipText = optionString },
			[3] = { ButtonPos = { x = 180,	y = 0 },	HighLightBox = { x = 118, y = -6, width = 720, height = 32 },	ToolTipDir = "UP",	ToolTipText = modifierString},
			[4] = { ButtonPos = { x = 456,	y = -100 },	HighLightBox = { x = 118, y = -40, width = 720, height = 360 },	ToolTipDir = "DOWN",	ToolTipText = dynamicString},
			[5] = { ButtonPos = { x = 456,	y = -456},	HighLightBox = { x = 118, y = -400, width = 720, height = 160 },	ToolTipDir = "UP",	ToolTipText = staticString },
		}
		G.binds.helpButton = CreateFrame("Button", nil, G.binds, "MainHelpPlateButton");
		G.binds.helpButton:SetPoint("TOPLEFT", G.binds, "TOPLEFT", -20, 20);
		G.binds.helpButton:SetFrameStrata("TOOLTIP");
		G.binds.helpButton:SetScript("OnClick", function(...)
			if HelpPlate:IsVisible() then
				HelpPlate_Hide();
			else
				HelpPlate_Show(G.binds.tutorials, G.binds, G.binds.helpButton, true);
			end
		end);
		
		G.Mouse 		= CreateFrame("FRAME", nil, G.panel);
		G.Mouse.name 	= "Mouse";
		G.Mouse.parent 	= G.panel.name;
		G.Mouse.okay 	= function(self)
			for i, Check in pairs(G.Mouse.Events) do
				for i, Event in pairs(Check.Events) do
					ConsolePortMouseSettings[Event] = Check:GetChecked();
				end
			end
			ConsolePort:LoadEvents();
		end

		InterfaceOptions_AddCategory(G.panel);
		InterfaceOptions_AddCategory(G.binds);
		InterfaceOptions_AddCategory(G.Mouse);

		-- Create guide buttons on the binding palette
		local modButtons = {
			{modifier = SHIFT, 	texture = "LONE", xoffset = 180*2-40, xoffset2 = 180*4-55},
			{modifier = CTRL,	texture = "LTWO", xoffset = 180*3-40, xoffset2 = 180*4-25},
		}
		for i, button in pairs(modButtons) do
			ConsolePort:CreateConfigGuideButton(CP..button.modifier, button.texture, G.binds, button.xoffset, 0);
			ConsolePort:CreateConfigGuideButton(CP..CTRLSH..i, button.texture, G.binds, button.xoffset2, 0);
		end

		-- "Option buttons"; static bindings able to call protected Blizzard API
		local optionButtons = {
			{option = "CP_X_OPTION", icon = G.NAME_CP_X_OPTION},
			{option = "CP_C_OPTION", icon = G.NAME_CP_C_OPTION},
			{option = "CP_L_OPTION", icon = G.NAME_CP_L_OPTION},
			{option = "CP_R_OPTION", icon = G.NAME_CP_R_OPTION},
		}
		for i, button in pairs(optionButtons) do
			ConsolePort:CreateConfigGuideButton(button.option, button.icon, G.binds, 0, i+9);
			CreateConfigStaticButton(button.option, nil, 1, i+9);
			CreateConfigStaticButton(button.option, "SHIFT", 2, i+9);
			CreateConfigStaticButton(button.option, "CTRL", 3, i+9);
			CreateConfigStaticButton(button.option, "CTRL-SHIFT", 4, i+9);
		end

		G.Mouse.Events = {};
		G.Mouse.Header = G.Mouse:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
		G.Mouse.Header:SetText("Toggle mouse look when...");
		G.Mouse.Header:SetPoint("TOPLEFT", G.Mouse, 10, -10);
		G.Mouse.Header:Show();
		for i, setting in pairs(GetMouseSettings()) do
			local check = CreateFrame("CheckButton", "ConsolePortMouseEvent"..i, G.Mouse, "ChatConfigCheckButtonTemplate");
			local text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
			text:SetText(setting.desc);
			check:SetChecked(setting.toggle);
			check.Events = setting.event;
			check.Description = text;
			check:SetPoint("TOPLEFT", 20, -30*i);
			text:SetPoint("LEFT", check, 30, 0);
			check:Show();
			text:Show();
			tinsert(G.Mouse.Events, check);
		end
	end
end