local _, G = ...;

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
local BIND 				= "BINDING_NAME_";

local SaveBindingSet = nil; -- static
local SaveBindingBtn = nil; -- dynamic

G.HotKeys = {};

local function Copy(src)
	local srcType = type(src);
	local copy;
	if srcType == "table" then
		copy = {};
		for key, value in next, src, nil do
			copy[Copy(key)] = Copy(value);
		end
		setmetatable(copy, Copy(getmetatable(src)));
	else
		copy = src;
	end
	return copy;
end

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
	if not SaveBindingSet then
		SaveBindingSet = Copy(ConsolePortBindingSet);
	end
	local modifier;
	if not BIND_MODIFIER then modifier = "action";
	elseif BIND_MODIFIER == "SHIFT" then modifier = "shift";
	elseif BIND_MODIFIER == "CTRL" then modifier = "ctrl";
	elseif BIND_MODIFIER == "CTRL-SHIFT" then modifier = "ctrlsh"; end;
	SaveBindingSet[BIND_TARGET][modifier] = bindingName;
end

local function ResetGuides()
	for i, guide in pairs(G.HotKeys) do
		guide:SetTexture(nil);
		if 	guide:GetParent().HotKey then
			guide:GetParent().HotKey:SetAlpha(1);
		end
	end
end

local function ReloadBindings()
	ConsolePort:ReloadBindingActions();
	ConsolePort:LoadBindingSet();
end

local function SubmitBindings()
	if 	SaveBindingSet or SaveBindingBtn then
		ConsolePortBindingSet = SaveBindingSet or ConsolePortBindingSet;
		ConsolePortBindingButtons = SaveBindingBtn or ConsolePortBindingButtons;
		if not InCombatLockdown() then
			ResetGuides();
			ReloadBindings();
		else
			ReloadUI();
		end
	end
end

local function RevertBindings()
	if 	SaveBindingBtn or SaveBindingSet then
		SaveBindingBtn = nil;
		SaveBindingSet = nil;
		if not InCombatLockdown() then
			ReloadBindings();
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
			local bind = _G[BIND..GetBinding(i)];
			local binding = {
				text = bind,
				notCheckable = true,
				func = function() ChangeBinding(GetBinding(i), bind); end
			}
			tinsert(t, binding);
		end
		SubMenu.menuList = t;
		tinsert(BindingsTable, SubMenu);
	end
	local ExtraBind = "CLICK ConsolePortExtraButton:LeftButton";
	local binding = {
		text = _G[BIND..ExtraBind],
		notCheckable = true,
		func = function() ChangeBinding(ExtraBind, _G[BIND..ExtraBind]); end;
	}
	tinsert(BindingsTable, binding);
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
	local b = CreateFrame("BUTTON", title, G.Binds, "UIMenuButtonStretchTemplate");
	b:SetWidth(180);
	b:SetHeight(40);
	b:SetPoint("TOPLEFT", G.Binds, xoffset*180-60, -40*yoffset);
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
	tinsert(G.Binds.Buttons, b);
end

function ConsolePort:CreateConfigButton(name, xoffset, yoffset)
	local f = CreateFrame("FRAME", name..CONFBG, G.Binds);
	local b = CreateFrame("BUTTON", name..CONF, G.Binds, "UIMenuButtonStretchTemplate");
	local t = f:CreateTexture(nil, "background");
	local a = _G[name];
	b:SetBackdrop(nil);
	b:SetWidth(180);
	b:SetHeight(40);
	b:SetPoint("TOPLEFT", G.Binds, xoffset*180-60, -40*yoffset);
	t:SetTexCoord(0.05, 0.95, 0.45, 0.65);
	t:SetAllPoints(f);
	f.texture = t;
	f:SetPoint("CENTER", b);
	f:SetWidth(170);
	f:SetHeight(34);
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
	tinsert(G.Binds.Buttons, b);
end	

function ConsolePort:CreateIndicator(parent, size, anchor, button)
	local f = CreateFrame("BUTTON", nil, parent);
	local t = f:CreateTexture(nil, "BACKGROUND");
	local o = f:CreateTexture(nil, "OVERLAY");
	button = string.upper(button);
	f.texture = t;
	f.overlay = o;
	o:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder.blp");
	o:SetPoint("TOPLEFT", f, G.GUIDE["BORDER_X_"..size], G.GUIDE["BORDER_Y_"..size]);
	o:SetWidth(G.GUIDE["BORDER_S_"..size]);
	o:SetHeight(G.GUIDE["BORDER_S_"..size]);
	t:SetTexture(G.TEXTURE[button]);
	t:SetAllPoints(f);
	f:SetPoint(anchor, parent, G.GUIDE["BUTTON_"..anchor.."_"..size.."_X"], G.GUIDE["BUTTON_"..anchor.."_"..size.."_Y"]);
	f:SetWidth(G.GUIDE["BUTTON_S_"..size]);
	f:SetHeight(G.GUIDE["BUTTON_S_"..size]);
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
	f:SetPoint("TOPLEFT", parent, xoffset+20, -40*yoffset);
	f:SetWidth(100);
	f:SetHeight(40);
	f:SetAlpha(1);

	f:Show();
	return f;
end


function ConsolePort:LoadBindingSet()
	local keys = SaveBindingSet or ConsolePortBindingSet;
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
	if 		button == "CP_TR1" 		then return G.TEXTURE.RONE;
	elseif 	button == "CP_TR2" 		then return G.TEXTURE.RTWO;
	elseif 	button == "CP_TR3" 		then return G.TEXTURE.LONE;
	elseif 	button == "CP_TR4" 		then return G.TEXTURE.LTWO;
	else 	return G.TEXTURE[string.upper(G.NAME[button])];
	end
end

function ConsolePort:UpdateActionGuideTexture(button, key, mod1, mod2)
	if button.HotKey then
		button.HotKey:SetAlpha(0);
	end
	if not button.guide then
		button.guide = button:CreateTexture(nil, "OVERLAY", nil, 7);
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
		button[mod] = button:CreateTexture(nil, "OVERLAY", nil, 7);
		button[mod]:SetPoint(anchor, button, 0, 0);
		button[mod]:SetSize(14, 14);
		tinsert(G.HotKeys, button[mod]);
	elseif not modifier and button[mod] then
		button[mod]:SetTexture(nil);
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
	local keys = SaveBindingBtn or ConsolePortBindingButtons;
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
	local TARGET_VALID = 	focusFrame:IsObjectType("Button") and
							focusFrameName ~= confButton:GetText() and
							focusFrame:GetParent() ~= G.Binds;
	if confButton:GetButtonState() == "PUSHED" then
		confButton:SetButtonState("NORMAL");
		confButton:UnlockHighlight();
		if TARGET_VALID then
			confButton:SetText(focusFrameName);
			AnimateBindingChange(focusFrame, confButton);
			if not SaveBindingBtn then
				SaveBindingBtn = Copy(ConsolePortBindingButtons);
			end
			if 		modfierBtn == NOMOD 	then	SaveBindingBtn[tableIndex].action 	= focusFrameName; 
			elseif 	modfierBtn == SHIFT 	then	SaveBindingBtn[tableIndex].shift 	= focusFrameName; 
			elseif 	modfierBtn == CTRL 		then	SaveBindingBtn[tableIndex].ctrl 	= focusFrameName; 
			elseif 	modfierBtn == CTRLSH 	then	SaveBindingBtn[tableIndex].ctrlsh 	= focusFrameName;
			end
			ResetGuides();
			ReloadBindings();
		end
	else 
		confButton:SetButtonState("PUSHED");
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
		local player = GetUnitName("player").."-"..GetRealmName();
		G.panel				= CreateFrame( "FRAME", "ConsolePortConfigFrame", InterfaceOptionsFramePanelContainer );
		G.panel.name		= "Console Port";
		G.panel.okay 		= function (self) SaveMainConfig(); end;
		-- Binding palette frame
		G.Binds				= CreateFrame( "FRAME", nil, G.panel);
		G.Binds.Buttons 	= {};
		G.Binds.name		= "Bindings";
		G.Binds.parent		= G.panel.name;
		G.Binds.okay		= function (self) SubmitBindings(); end;
		G.Binds.cancel 		= function (self) RevertBindings(); end;
		G.Binds:SetScript("OnShow", function(self)
			InterfaceOptionsFrame:SetWidth(1100);
			ConsolePortExtraButton:ForceShow(true);
			local index, exists = 1, false;
			UIDropDownMenu_Initialize(G.Binds.dropdown, function()
				if ConsolePortCharacterSettings then
					local count = 1;
					for character, _ in pairs(ConsolePortCharacterSettings) do
						info = {};
						info.text = character;
						info.value = character;
						info.func = G.Binds.dropdown.Click;
						UIDropDownMenu_AddButton(info, 1);
						if not exists and character == player then
							exists = true;
							index = count;
						end
						count = count + 1;
					end
				else
					G.Binds.import:SetButtonState("DISABLED");
				end
			end);
			UIDropDownMenu_SetSelectedID(G.Binds.dropdown, index);
			UIDropDownMenu_SetWidth(G.Binds.dropdown, 150);
			if not ConsolePortCharacterSettings then
				UIDropDownMenu_SetText(G.Binds.dropdown, "No saved profiles");
			end
			local mods = {
				_G[CP..SHIFT..GUIDE], _G[CP..CTRL..GUIDE], _G[CP..CTRLSH.."1"..GUIDE], _G[CP..CTRLSH.."2"..GUIDE]
			}
			self:SetScript("OnUpdate", function(self, elapsed)
				if not InCombatLockdown() then
					InterfaceOptionsFrame:SetAlpha(1);
					ConsolePort:SetButtonActionsConfig(true);
				else
					InterfaceOptionsFrame:SetAlpha(0.2);
				end
				if not 	IsModifierKeyDown() then for i=1, 4 do mods[i]:SetAlpha(0.5); end
				elseif 	IsShiftKeyDown() and IsControlKeyDown() then for i=1, 2 do mods[i]:SetAlpha(0.5); mods[i+2]:SetAlpha(1); end
				elseif 	IsShiftKeyDown() then for i=2, 4 do mods[i]:SetAlpha(0.5); end mods[1]:SetAlpha(1);
				elseif	IsControlKeyDown() then for i=1, 4 do mods[i]:SetAlpha(0.5); end mods[2]:SetAlpha(1);
				end
			end);
		end);
		G.Binds:SetScript("OnHide", function(self)
			HelpPlate_Hide();
			RevertBindings();
			ConsolePort:SetButtonActionsConfig(false);
			self:SetScript("OnUpdate", nil);
			ConsolePortExtraButton:ForceShow(false);
		end);

		local insetBackgrounds = {
			{name = "bgCorner", size = {w = 272, h = 30}, 	anchor = {p = "BOTTOMRIGHT", r = "TOPRIGHT"}, 	offset = {x = -24, y = 0}},
			{name = "bgUpper", 	size = {w = 856, h = 398}, 	anchor = {p = "TOPLEFT", r = "TOPLEFT"}, 		offset = {x =  4,  y = -4}},
			{name = "bgLower", 	size = {w = 856, h = 165}, 	anchor = {p = "TOPLEFT", r = "TOPLEFT"}, 		offset = {x =  4,  y = -398}},
		}
		for _, bg in pairs(insetBackgrounds) do
			G.Binds[bg.name] = CreateFrame("FRAME", nil, G.Binds, "InsetFrameTemplate");
			G.Binds[bg.name]:SetSize(bg.size.w, bg.size.h);
			G.Binds[bg.name]:SetPoint(bg.anchor.p, G.Binds, bg.anchor.r, bg.offset.x, bg.offset.y);
		end

		G.Binds.dropdown = CreateFrame("BUTTON", "ConsolePortImportDropdown", G.Binds, "UIDropDownMenuTemplate");
		G.Binds.dropdown:SetPoint("LEFT", G.Binds.bgCorner, "LEFT", -12, -2);
		G.Binds.dropdown.Click = function (self)
			UIDropDownMenu_SetSelectedID(G.Binds.dropdown, self:GetID());
		end

		G.Binds.import = CreateFrame("BUTTON", nil, G.Binds, "UIPanelButtonTemplate");
		G.Binds.import:SetPoint("RIGHT", G.Binds.bgCorner, "RIGHT", -4, 0);
		G.Binds.import:SetWidth(96);
		G.Binds.import:SetText("Import");
		G.Binds.import:SetScript("OnClick", function(self, ...)
			local ImportTable = ConsolePortCharacterSettings[UIDropDownMenu_GetText(G.Binds.dropdown)];
			if ImportTable then
				SaveBindingSet = Copy(ImportTable.BindingSet);
				SaveBindingBtn = Copy(ImportTable.BindingBtn);
				ReloadBindings();
				for i, Button in pairs(G.Binds.Buttons) do
					Button.OnShow(Button);
				end
			end
		end);

		G.Binds.tutorials = {
			FramePos = { x = 40,	y = 8 },
			FrameSize = { width = 700, height = 600	},
			[1] = { ButtonPos = { x = 504,	y = 30},
					HighLightBox = { x = 526, y = 22, width = 274, height = 32 },
					ToolTipDir = "LEFT",	ToolTipText = G.TUTORIAL.BIND.IMPORT},
			[2] = { ButtonPos = { x = -22,	y = -204},
					HighLightBox = { x = 0, y = -48, width = 60, height = 360 },
					ToolTipDir = "LEFT",	ToolTipText = G.TUTORIAL.BIND.ACTION},
			[3] = { ButtonPos = { x = -22,	y = -464},	
					HighLightBox = { x = 0, y = -410, width = 60, height = 160 },
					ToolTipDir = "LEFT",	ToolTipText = G.TUTORIAL.BIND.OPTION},
			[4] = { ButtonPos = { x = 140,	y = -8 },
					HighLightBox = { x = 80, y = -14, width = 720, height = 32 },
					ToolTipDir = "UP",		ToolTipText = G.TUTORIAL.BIND.MOD},
			[5] = { ButtonPos = { x = 416,	y = -108 },
					HighLightBox = { x = 80, y = -48, width = 720, height = 360 },
					ToolTipDir = "DOWN",	ToolTipText = G.TUTORIAL.BIND.DYNAMIC},
			[6] = { ButtonPos = { x = 416,	y = -464},
					HighLightBox = { x = 80, y = -410, width = 720, height = 160 },
					ToolTipDir = "UP",	ToolTipText = G.TUTORIAL.BIND.STATIC },
		}
		G.Binds.helpButton = CreateFrame("Button", nil, G.Binds, "MainHelpPlateButton");
		G.Binds.helpButton:SetPoint("TOPLEFT", G.Binds, "TOPLEFT", 40, 8);
		G.Binds.helpButton:SetFrameStrata("TOOLTIP");
		G.Binds.helpButton:SetScript("OnClick", function(...)
			if HelpPlate:IsVisible() then
				HelpPlate_Hide();
			else
				HelpPlate_Show(G.Binds.tutorials, G.Binds, G.Binds.helpButton, true);
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
		InterfaceOptions_AddCategory(G.Binds);
		InterfaceOptions_AddCategory(G.Mouse);

		-- Create guide buttons on the binding palette
		local modButtons = {
			{modifier = SHIFT, 	texture = "LONE", xoffset = 180*2-40, xoffset2 = 180*4-55},
			{modifier = CTRL,	texture = "LTWO", xoffset = 180*3-40, xoffset2 = 180*4-25},
		}
		for i, button in pairs(modButtons) do
			ConsolePort:CreateConfigGuideButton(CP..button.modifier, button.texture, G.Binds, button.xoffset, 0.1);
			ConsolePort:CreateConfigGuideButton(CP..CTRLSH..i, button.texture, G.Binds, button.xoffset2, 0.1);
		end

		-- "Option buttons"; static bindings able to call protected Blizzard API
		local optionButtons = {
			{option = "CP_X_OPTION", icon = G.NAME.CP_X_OPTION},
			{option = "CP_C_OPTION", icon = G.NAME.CP_C_OPTION},
			{option = "CP_L_OPTION", icon = G.NAME.CP_L_OPTION},
			{option = "CP_R_OPTION", icon = G.NAME.CP_R_OPTION},
		}
		for i, button in pairs(optionButtons) do
			ConsolePort:CreateConfigGuideButton(button.option, button.icon, G.Binds, 0, i+9);
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
