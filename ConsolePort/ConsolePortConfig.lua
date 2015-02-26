local _
local _, G = ...;
local BUTTON_HEIGHT	 	= 40;
local BUTTON_WIDTH 	 	= 180;
local OVERLAY_WIDTH		= 170;
local OVERLAY_HEIGHT	= 34;
local BIND_TARGET 	 	= false;
local CONF_BUTTON 		= nil;
local CP				= "CP";
local CONF				= "_CONF";
local CONFBG			= "_CONF_BG";
local GUIDE				= "_GUIDE";
local NOMOD				= "_NOMOD";
local SHIFT				= "_SHIFT";
local CTRL				= "_CTRL";
local CTRLSH			= "_CTRLSH";
local TEXTURE			= "TEXTURE_";

G.panel				= CreateFrame( "FRAME", "ConsolePortConfMain", InterfaceOptionsFramePanelContainer );
G.binds				= CreateFrame( "FRAME", "ConsolePortChild", G.panel);
G.panel.name		= "Console Port";
G.binds.name		= "Bindings";
G.binds.parent		= G.panel.name;
G.binds.okay		= function (self) ConsolePort:SubmitBindings(); end;
G.binds:SetScript("OnShow", function(self)
	InterfaceOptionsFrame:SetWidth(1100);
	ConsolePort:SetButtonActionsConfig("rebind");
	self:SetScript("OnUpdate", function(self, elapsed)
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
	ConsolePort:SetButtonActionsConfig("click");
	self:SetScript("OnUpdate", nil);
end);
InterfaceOptions_AddCategory(G.panel);
InterfaceOptions_AddCategory(G.binds);

local function ChangeBinding(bindingName, bindingTitle)
	print(bindingName, bindingTitle, BIND_TARGET);
	_G[CONF_BUTTON]:SetText(bindingTitle);
end


local function GenerateMenuListItem(i)
	local current 	= GetBinding(i);
	local title 	= _G["BINDING_NAME_"..current];
	local binding 	= { text = title, func = function() ChangeBinding(current, title); end };
	return binding;
end

local function GenerateBindingsTable()
	local BindingsTable = {};
	local SubTables 	= {};
	local Movement 		= {};
	local ActionBar 	= {};
	local ExtraBar 		= {};
	local ActionPage 	= {};
	local MultiBarBL 	= {};
	local MultiBarBR 	= {};
	local MultiBarRR 	= {};
	local MultiBarRL 	= {};
	-- Binding iteration indices. 
	Movement.name 		= "Movement";
	Movement.jump 		= 8;
	Movement.sheathe 	= 10;
	Movement.run 		= 14;
	Movement.follow 	= 15;
	ActionBar.name 		= "Action Bar";			ActionBar.start 	= 26;		ActionBar.stop  	= 37;
	MultiBarBL.name 	= "Left Bottom Bar";	MultiBarBL.start 	= 69;		MultiBarBL.stop		= 80;
	MultiBarBR.name 	= "Right Bottom Bar";	MultiBarBR.start 	= 82;		MultiBarBR.stop 	= 93;
	MultiBarRR.name 	= "Right Side Bar";		MultiBarRR.start 	= 95;		MultiBarRR.stop 	= 106;
	MultiBarRL.name 	= "Left Side Bar";		MultiBarRL.start 	= 108;		MultiBarRL.stop 	= 119;
	ExtraBar.name 		= "Extra Bar";			ExtraBar.start 		= 38;		ExtraBar.stop		= 58;
	ActionPage.name 	= "Action Page";		ActionPage.start 	= 59;		ActionPage.stop		= 66;

	table.insert(SubTables, ActionBar);
	table.insert(SubTables, MultiBarBL);
	table.insert(SubTables, MultiBarBR);
	table.insert(SubTables, MultiBarRR);
	table.insert(SubTables, MultiBarRL);
	table.insert(SubTables, ActionPage);
	table.insert(SubTables, ExtraBar);
	for _, item in ipairs(SubTables) do
		local t = {};
		local SubMenu =  { text = item.name, hasArrow = true, notCheckable = true };
		for i=item.start, item.stop do
			table.insert(t, GenerateMenuListItem(i));
		end
		SubMenu.menuList = t;
		table.insert(BindingsTable, SubMenu);
	end
	return BindingsTable;
end 

local menu = GenerateBindingsTable();
local menuFrame = CreateFrame("Frame", "ExampleMenuFrame", UIParent, "UIDropDownMenuTemplate")

function ConsolePort:CreateConfigButton(name, xoffset, yoffset)
	local f = CreateFrame("FRAME", name..CONFBG, G.binds);
	local b = CreateFrame("BUTTON", name..CONF, G.binds, "UIMenuButtonStretchTemplate");
	local t = f:CreateTexture(nil, "background");
	local a = _G[name];
	b:SetWidth(BUTTON_WIDTH);
	b:SetHeight(BUTTON_HEIGHT);
	b:SetPoint("TOPLEFT", G.binds, xoffset*BUTTON_WIDTH-60, -BUTTON_HEIGHT*yoffset);
	t:SetTexCoord(0.05, 0.95, 0.45, 0.65);
	t:SetAllPoints(f);
	f.texture = t;
	f:SetPoint("CENTER", b);
	f:SetWidth(OVERLAY_WIDTH);
	f:SetHeight(OVERLAY_HEIGHT);
	f:SetAlpha(0.35);
	f:Show();
	b.background = f;
	b:SetScript("OnShow", function(self)
		self:SetText(a.action:GetName());
		if a.action.icon then
			self.background.texture:SetTexture(a.action.icon:GetTexture());
		end
	end);
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
	if 		string.find(fN, "Trigger 1") then fN = "LONE";
	elseif 	string.find(fN, "Trigger 2") then fN = "LTWO"; end;
	f.guide = ConsolePort:CreateIndicator(f, "SMALL", "CENTER", fN);
	f.guide:SetScript("OnShow", nil);
	f:SetPoint("TOPLEFT", parent, xoffset+20, -BUTTON_HEIGHT*yoffset);
	f:SetWidth(100);
	f:SetHeight(BUTTON_HEIGHT);
	f:SetAlpha(1);
	f.guide:SetAlpha(0.5);
	f:Show();
end

function ConsolePort:SubmitBindings()
	if ConsolePortSaveBindings then
		ConsolePortBindingButtons = ConsolePortSaveBindings;
	end
	ConsolePort:ReloadBindingActions();
end

function ConsolePort:LoadBindingSet(enabled)
	local keys = ConsolePortBindingSet;
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
	-- Right
	if 		button == "CP_R_UP" 	then return G.TEXTURE_TRIANGLE;
	elseif 	button == "CP_R_DOWN" 	then return G.TEXTURE_CROSS;
	elseif 	button == "CP_R_LEFT" 	then return G.TEXTURE_SQUARE;
	elseif 	button == "CP_R_RIGHT" 	then return G.TEXTURE_CIRCLE;
	-- Left
	elseif 	button == "CP_L_UP" 	then return G.TEXTURE_UP;
	elseif 	button == "CP_L_DOWN" 	then return G.TEXTURE_DOWN;
	elseif 	button == "CP_L_LEFT" 	then return G.TEXTURE_LEFT;
	elseif 	button == "CP_L_RIGHT" 	then return G.TEXTURE_RIGHT;
	-- Triggers
	elseif 	button == "CP_TR1" 		then return G.TEXTURE_RONE;
	elseif 	button == "CP_TR2" 		then return G.TEXTURE_RTWO;
	elseif 	button == "CP_TR3" 		then return G.TEXTURE_LONE;
	elseif 	button == "CP_TR4" 		then return G.TEXTURE_LTWO;
	end
--	elseif 	button == "CP_L_OPTION" then return TEXTURE_SELECT;
--	elseif 	button == "CP_C_OPTION" then return TEXTURE_GUIDEBTN;
--	elseif 	button == "CP_R_OPTION" then return TEXTURE_START;
end

function ConsolePort:UpdateActionGuideTexture(button, key, mod1, mod2)
	if button.HotKey then
		button.HotKey:SetAlpha(0);
	end
	if not button.guide then
		button.guide = button:CreateTexture();
		button.guide:SetPoint("TOPRIGHT", button, 0, 0);
		button.guide:SetSize(14, 14);
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
	elseif not modifier and button[mod] then
		button[mod]:Hide();
	end
	if 	modifier then
		button[mod]:SetTexture(ConsolePort:GetDefaultGuideTexture(modifier));
	end
end

function ConsolePort:ReloadBindingAction(button, action, name, mod1, mod2)
	button.action = action;
	button:SetAttribute("clickbutton", button.action);
	ConsolePort:UpdateActionGuideTexture(button.action, name, mod1, mod2);
	button.action.HotKey:SetAlpha(0);
end

function ConsolePort:ReloadBindingActions()
	local keys = ConsolePortBindingButtons;
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
	local focusParent = nil;
	local focusFrameName = focusFrame:GetName();
	if focusFrame:GetParent() then
		focusParent = focusFrame:GetParent():GetName();
	end
	local TARGET_VALID = (	focusParent == "MainMenuBarArtFrame" 	or 
							focusParent == "PetActionBarFrame" 		or
							focusParent == "StanceBarFrame" 		or
							focusParent == "MultiBarBottomLeft" 	or
							focusParent == "MultiBarBottomRight" 	or
							focusParent == "MultiBarLeft" 			or
							focusParent == "MultiBarRight") 		and
							focusFrame:IsObjectType("Button");
	if confButton:GetButtonState() == "PUSHED" then
		confButton:SetButtonState("NORMAL");
		confString.guide:SetAlpha(0.5);
		confButton:UnlockHighlight();
		if TARGET_VALID then
			confButton:SetText(focusFrameName);
			if focusFrame.icon then
				confButton.background.texture:SetTexture(focusFrame.icon:GetTexture());
			else
				confButton.background.texture:SetTexture(nil);
			end
			if not ConsolePortSaveBindings then
				ConsolePortSaveBindings = ConsolePortBindingButtons;
			end
			if 		modfierBtn == NOMOD 	then	ConsolePortSaveBindings[tableIndex].action 	= focusFrameName; 
			elseif 	modfierBtn == SHIFT 	then	ConsolePortSaveBindings[tableIndex].shift 	= focusFrameName; 
			elseif 	modfierBtn == CTRL 		then	ConsolePortSaveBindings[tableIndex].ctrl 	= focusFrameName; 
			elseif 	modfierBtn == CTRLSH 	then	ConsolePortSaveBindings[tableIndex].ctrlsh 	= focusFrameName;	end
		end
	else 
		confButton:SetButtonState("PUSHED");
		confString.guide:SetAlpha(1);
		confButton:LockHighlight();
	end
end

function ConsolePort:SetButtonActionsConfig(type)
	local Buttons = ConsolePort:GetBindingButtons();
	for _, Button in ipairs(Buttons) do
		_G[Button..CTRL]:SetAttribute("type", 	type);
		_G[Button..NOMOD]:SetAttribute("type", 	type);
		_G[Button..SHIFT]:SetAttribute("type", 	type);
		_G[Button..CTRLSH]:SetAttribute("type", 	type);
	end
end

-- Create generic strings for bindings config
ConsolePort:CreateConfigGuideButton(CP..SHIFT, 		"LONE",	G.binds, 180*2-40, 0);
ConsolePort:CreateConfigGuideButton(CP..CTRL,		"LTWO",	G.binds, 180*3-40, 0);
ConsolePort:CreateConfigGuideButton(CP..CTRLSH..1, 	"LONE",	G.binds, 180*4-55, 0);
ConsolePort:CreateConfigGuideButton(CP..CTRLSH..2,	"LTWO",	G.binds, 180*4-25, 0);



-- Make the menu appear at the cursor: 
-- EasyMenu(menu, menuFrame, "cursor", 0 , 0, "MENU");

-- Or make the menu appear at the frame:
-- menuFrame:SetPoint("Center", UIParent, "Center")
-- EasyMenu(menu, menuFrame, menuFrame, 0 , 0, "MENU");