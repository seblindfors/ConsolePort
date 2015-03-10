local _
local _, G = ...;
local BIND_TARGET 	 	= false;
local CONF_BUTTON 		= nil;
local CP 				= "CP";
local CONF 				= "_CONF";
local CONFBG 			= "_CONF_BG";
local GUIDE 			= "_GUIDE";
local NOMOD				= "_NOMOD";
local SHIFT 			= "_SHIFT";
local CTRL 				= "_CTRL";
local CTRLSH 			= "_CTRLSH";
local TEXTURE 			= "TEXTURE_";
G.ConsolePort_Loaded = false;
G.ButtonGuides 		 = {};

-- Sort table by non-numeric key
local function pairsByKeys(t,f)
	local a = {};
		for n in pairs(t) do table.insert(a, n); end;
		table.sort(a, f);
		local i = 0;      -- iterator variable
		local iter = function ()   -- iterator function
			i = i + 1;
			if a[i] == nil then return nil;
			else return a[i], t[a[i]];
			end;
		end;
	return iter;
end;


function ConsolePort:GetIndicatorButtons(button)
	local t = {};
	-- Circle
	if button == BINDING_NAME_CP_R_RIGHT then t = {
		{frame = OverrideActionBarButton3,	size = "SMALL", anchor = "CENTER" },
		{frame = QuestFrameAcceptButton, 	size = "SMALL", anchor = "LEFT"	},
		{frame = QuestFrameCompleteButton, 	size = "SMALL", anchor = "LEFT"	},
		{frame = QuestFrameCompleteQuestButton, size = "SMALL", anchor = "LEFT"	},
		{frame = QuestLogPopupDetailFrameTrackButton, size = "SMALL", anchor = "RIGHT" },
		{frame = QuestMapFrame.DetailsFrame.TrackButton, size = "SMALL", anchor = "RIGHT"},
		{frame = QuestMapFrame.DetailsFrame.CompleteQuestFrame.CompleteButton, size = "SMALL", anchor = "RIGHT"},
		{frame = GuildInviteFrameDeclineButton, size = "SMALL", anchor = "RIGHT" },
		{frame = PetitionFrameSignButton, 	size = "SMALL", anchor = "LEFT" },
		{frame = StackSplitCancelButton, 	size = "SMALL", anchor = "RIGHT"},
		{frame = StaticPopup1Button2, 		size = "SMALL", anchor = "RIGHT"},
		{frame = StaticPopup2Button2, 		size = "SMALL", anchor = "RIGHT"},
		{frame = StaticPopup3Button2, 		size = "SMALL", anchor = "RIGHT"},
		{frame = StaticPopup4Button2, 		size = "SMALL", anchor = "RIGHT"},
		{frame = StaticPopup1Button3, 		size = "SMALL", anchor = "RIGHT"},
		{frame = StaticPopup2Button3, 		size = "SMALL", anchor = "RIGHT"},
		{frame = StaticPopup3Button3, 		size = "SMALL", anchor = "RIGHT"},
		{frame = StaticPopup4Button3, 		size = "SMALL", anchor = "RIGHT"},	
		{frame = GroupLootFrame1.GreedButton, size = "SMALL", anchor = "LEFT"},
		{frame = GroupLootFrame2.GreedButton, size = "SMALL", anchor = "LEFT"},
		{frame = GroupLootFrame3.GreedButton, size = "SMALL", anchor = "LEFT"},
		{frame = GroupLootFrame4.GreedButton, size = "SMALL", anchor = "LEFT"},
		{frame = QuestScrollFrame.ViewAll, 	size = "LARGE", anchor = "LEFT"},
		{frame = SplashFrame.BottomCloseButton, size = "SMALL", anchor = "LEFT"},
		{frame = CinematicFrameCloseDialogResumeButton, size = "SMALL", anchor = "RIGHT"}
	}
	-- Square
	elseif button == BINDING_NAME_CP_R_LEFT then t = { 
		{frame = OverrideActionBarButton1,	size = "SMALL", anchor = "CENTER" },
		{frame = QuestLogPopupDetailFrameAbandonButton, size = "SMALL", anchor = "LEFT" },
		{frame = QuestMapFrame.DetailsFrame.AbandonButton, size = "SMALL", anchor = "LEFT"},
		{frame = WorldMapFrameTutorialButton, size = "SMALL", anchor = "RIGHT"},
		{frame = GuildInviteFrameJoinButton, size = "SMALL", anchor = "LEFT"},
		{frame = StackSplitOkayButton, 		size = "SMALL", anchor = "LEFT"},
		{frame = StaticPopup1Button1, 		size = "SMALL", anchor = "LEFT"},
		{frame = StaticPopup2Button1, 		size = "SMALL", anchor = "LEFT"},
		{frame = StaticPopup3Button1, 		size = "SMALL", anchor = "LEFT"},
		{frame = StaticPopup4Button1, 		size = "SMALL", anchor = "LEFT"},
		{frame = GroupLootFrame1.NeedButton, size = "SMALL", anchor = "LEFT"},
		{frame = GroupLootFrame2.NeedButton, size = "SMALL", anchor = "LEFT"},
		{frame = GroupLootFrame3.NeedButton, size = "SMALL", anchor = "LEFT"},
		{frame = GroupLootFrame4.NeedButton, size = "SMALL", anchor = "LEFT"},
		{frame = CinematicFrameCloseDialogConfirmButton, size = "SMALL", anchor = "LEFT"}
	}
	-- Triangle
	elseif button == BINDING_NAME_CP_R_UP then t = {
		{frame = OverrideActionBarButton2,	size = "SMALL", anchor = "CENTER" },
		{frame = QuestFrameDeclineButton,	size = "SMALL", anchor = "RIGHT"},
		{frame = QuestFrameGoodbyeButton,	size = "SMALL", anchor = "RIGHT"},
		{frame = QuestLogPopupDetailFrame.ShowMapButton, size = "SMALL", anchor = "RIGHT" },
		{frame = SpellBookSkillLineTab2, 	size = "SMALL", anchor = "BOTTOM"},
		{frame = PlayerSpecTab2, 			size = "SMALL", anchor = "BOTTOM"},
		{frame = GossipFrameGreetingGoodbyeButton,		size = "SMALL", anchor = "RIGHT"},
		{frame = QuestMapFrame.DetailsFrame.BackButton, size = "SMALL", anchor = "LEFT"},
		{frame = WorldMapFrame.UIElementsFrame.TrackingOptionsButton.Button, size = "LARGE", anchor = "LEFT"},
		{frame = PetitionFrameCancelButton,  size = "SMALL", anchor = "RIGHT"},
		{frame = GroupLootFrame1.PassButton, size = "SMALL", anchor = "RIGHT"},
		{frame = GroupLootFrame2.PassButton, size = "SMALL", anchor = "RIGHT"},
		{frame = GroupLootFrame3.PassButton, size = "SMALL", anchor = "RIGHT"},
		{frame = GroupLootFrame4.PassButton, size = "SMALL", anchor = "RIGHT"},
	}
	elseif button == "Up" then t = {
		{frame = OverrideActionBarButton5,	size = "SMALL", anchor = "CENTER" },
		{frame = GameMenuFrame, 			size = "SMALL", anchor = "LEFT"}
	}
	elseif button == "Left"	then t = {
		{frame = OverrideActionBarButton4,	size = "SMALL", anchor = "CENTER" }
	}
	elseif button == "Right" then t = {
		{frame = OverrideActionBarButton6,	size = "SMALL", anchor = "CENTER" }
	}
	elseif button == "Down"	then t = {
		{frame = GameMenuFrame, 			size = "SMALL", anchor = "RIGHT"},
		{frame = GroupLootFrame1.DisenchantButton, size = "SMALL", anchor = "RIGHT"},
		{frame = GroupLootFrame2.DisenchantButton, size = "SMALL", anchor = "RIGHT"},
		{frame = GroupLootFrame3.DisenchantButton, size = "SMALL", anchor = "RIGHT"},
		{frame = GroupLootFrame4.DisenchantButton, size = "SMALL", anchor = "RIGHT"},
	}
	end
	return t;
end

-- ConsolePort:CreateIndicator(parent, size, anchor, button)
function ConsolePort:GetIndicatorSet()
	local t = {
		BINDING_NAME_CP_R_UP,
		BINDING_NAME_CP_R_RIGHT,
		BINDING_NAME_CP_R_LEFT,
		"Up","Down","Left","Right",
	}
	for i, button in pairs(t) do
		local indicators = ConsolePort:GetIndicatorButtons(button);
		for k, indicator in pairs(indicators) do
			table.insert(G.ButtonGuides, ConsolePort:CreateIndicator(indicator.frame, indicator.size, indicator.anchor, button));
		end
	end
end

function ConsolePort:CreateSecureButton(name, modifier, clickbutton, UIcommand)
	local btn 	= CreateFrame("Button", name..modifier, UIParent, "SecureActionButtonTemplate");
	local self 	= btn;
	btn.name 	= name;
	btn.timer 	= 0;
	btn.state 	= G.STATE_UP;
	btn.action 	= _G[clickbutton];
	btn.command = UIcommand;
	btn.mod 	= modifier;
	btn.revert 	= function(self) ConsolePort:SetClickButton(btn, btn.action); 	end;
	btn.taxi 	= function(self) ConsolePort:Taxi(self.command, self.state); 	end;
	btn.gossip 	= function(self) ConsolePort:Gossip(self.command, self.state); 	end;
	btn.quest 	= function(self) ConsolePort:Quest(self.command, self.state); 	end;
	btn.map 	= function(self) ConsolePort:Map(self.command, self.state); 	end;
	btn.book 	= function(self) ConsolePort:Book(self.command, self.state); 	end;
	btn.spec 	= function(self) ConsolePort:Spec(self.command, self.state); 	end;
	btn.glyph 	= function(self) ConsolePort:Spec(self.command, self.state); 	end;
	btn.bags 	= function(self) ConsolePort:Bags(self.command, self.state);	end;
	btn.gear 	= function(self) ConsolePort:Gear(self.command, self.state);	end;
	btn.shop 	= function(self) ConsolePort:Shop(self.command, self.state);	end;
	btn.misc 	= function(self) ConsolePort:Misc(self.command, self.state);	end;
	btn.popup 	= function(self) ConsolePort:Popup(self.command, self.state); 	end;
	btn.loot 	= function(self) ConsolePort:Loot(self.command, self.state); 	end;
	btn.stack 	= function(self) ConsolePort:Stack(self.command, self.state); 	end;
--	btn.list 	= function(self) ConsolePort:List(self.command, self.state);	end; -- Causes execution taint atm
	btn.menu 	= function(self) ConsolePort:Menu(self.command, self.state); 	end;
	btn.rebind 	= function(self) ConsolePort:ChangeButtonBinding(self); 		end;
	btn:SetAttribute("type", "click");
	btn:SetAttribute("clickbutton", btn.action);
	btn:SetAttribute("toggleForVehicle", true);
	btn:RegisterEvent("PLAYER_REGEN_DISABLED");
	btn:RegisterEvent("UNIT_ENTERED_VEHICLE");
	btn:RegisterEvent("UNIT_EXITED_VEHICLE");
	btn:SetScript("OnEvent", function(self, event, ...)
		if not UnitInVehicle("player") then
			btn:SetAttribute("clickbutton", btn.action);
		elseif UnitInVehicle("player") and btn.vehicle then
			btn:SetAttribute("clickbutton", btn.vehicle);
		end
		btn:SetAttribute("type", "click");
	end);
	btn:HookScript("OnMouseDown", function(self, button)
		local func = self:GetAttribute("type");
		local click = self:GetAttribute("clickbutton");
		self.state = G.STATE_DOWN;
		self.timer = 0;
		-- Fire function twice where keystate is requested
		if 	func == "click" then click:SetButtonState("PUSHED"); return; end;
		if 	self[func] then self[func](self); end;
	end);
	btn:HookScript("OnMouseUp", function(self, button)
		local func = self:GetAttribute("type");
		local click = self:GetAttribute("clickbutton");
		self.state = G.STATE_UP;
		if func == "click" then click:SetButtonState("NORMAL"); end
	end);
	if 	btn.command == G.UP or
		btn.command == G.DOWN or
		btn.command == G.LEFT or
		btn.command == G.RIGHT then
		btn:SetScript("OnUpdate", function(self, elapsed)
			self.timer = self.timer + elapsed;
			if self.timer >= 0.2 and btn.state == G.STATE_DOWN then
				local func = self:GetAttribute("type");
				if self[func] then self[func](self); end;
				self.timer = 0;
			end
		end);
	end
end 

function ConsolePort:GetBindingNames()
	return {
		"CP_R_LEFT",
		"CP_R_UP",
		"CP_R_RIGHT",
		"CP_L_LEFT",
		"CP_L_UP",
		"CP_L_RIGHT",
		"CP_L_DOWN",
		"CP_TR1",
		"CP_TR2",
		"CP_X_OPTION",
		"CP_L_OPTION",
		"CP_C_OPTION",
		"CP_R_OPTION"
	}
end

function ConsolePort:GetBindingButtons()
	return {
		"CP_R_LEFT",
		"CP_R_UP",
		"CP_R_RIGHT",
		"CP_L_LEFT",
		"CP_L_UP",
		"CP_L_RIGHT",
		"CP_L_DOWN",
		"CP_TR1",
		"CP_TR2",
	}
end

function ConsolePort:GetDefaultBindingSet()
	local bindingSet = {};
	local Buttons = ConsolePort:GetBindingNames();
	for _, Button in ipairs(Buttons) do
		bindingSet[Button] = ConsolePort:GetDefaultBinding(Button);
	end
	return bindingSet;
end

function ConsolePort:GetDefaultBindingButtons()
	local bindingSet = {};
	local Buttons = ConsolePort:GetBindingButtons();
	for _, Button in ipairs(Buttons) do
		bindingSet[Button] = ConsolePort:GetDefaultButton(Button);
	end
	return bindingSet;
end


function ConsolePort:GetDefaultBinding(key)
	local nomod 	= nil;
	local modshift 	= nil;
	local ctrl 		= nil;
	local shiftctrl = nil;
	-- Right side
	if 		key == "CP_X_OPTION" then
		nomod 		= "JUMP";
		modshift 	= "TARGETNEARESTENEMY";
		modctrl  	= "FOCUSTARGET";
		shiftctrl 	= "TARGETFOCUS";
	-- Utility Buttons
	elseif 	key == "CP_L_OPTION" then
		nomod 		= "OPENALLBAGS";
		modshift 	= "TOGGLECHARACTER0";
		modctrl 	= "TOGGLESPELLBOOK";
		shiftctrl 	= "TOGGLETALENTS";
	elseif 	key == "CP_C_OPTION" then
		nomod 		= "TOGGLEGAMEMENU";
		modshift 	= "EXTRAACTIONBUTTON1";
		modctrl 	= "TOGGLEAUTORUN";
		shiftctrl 	= "FOLLOWTARGET";
	elseif 	key == "CP_R_OPTION" then
		nomod 		= "TOGGLEWORLDMAP";
		modshift 	= "NEXTVIEW";
		modctrl 	= "PREVVIEW";
		shiftctrl 	= "CAMERAZOOMOUT";
	-- Actionbuttons
	elseif 	key == "CP_R_LEFT" 	or 
			key == "CP_R_UP" 	or
			key == "CP_R_RIGHT" or
			key == "CP_TR1" 	or
			key == "CP_TR2" 	or 
			key == "CP_L_DOWN" 	or 
			key == "CP_L_LEFT" 	or 
			key == "CP_L_UP" 	or 
			key == "CP_L_RIGHT" then
		nomod 		= "CLICK "..key.."_NOMOD:LeftButton";
		modshift 	= "CLICK "..key.."_SHIFT:LeftButton";
		modctrl 	= "CLICK "..key.."_CTRL:LeftButton";
		shiftctrl 	= "CLICK "..key.."_CTRLSH:LeftButton";
	end
	local binding = {
		action 	= nomod,
		shift 	= modshift,
		ctrl 	= modctrl,
		ctrlsh 	= shiftctrl
	}
	return binding;
end

function ConsolePort:GetDefaultButton(key)
	local command 	= nil;
	local nomod 	= nil;
	local modshift 	= nil;
	local ctrl 		= nil;
	local modshiftctrl = nil;
	if 		key == "CP_R_LEFT" then
		command		= G.SQUARE;
		nomod 		= "ActionButton1";
		modshift 	= "ActionButton6";
		modctrl 	= "MultiBarBottomLeftButton1";
		shiftctrl 	= "MultiBarBottomLeftButton6";
	elseif key == "CP_R_UP" then
		command		= G.TRIANGLE;
		nomod 		= "ActionButton2";
		modshift 	= "ActionButton7";
		modctrl 	= "MultiBarBottomLeftButton2";
		shiftctrl 	= "MultiBarBottomLeftButton7";
	elseif key == "CP_R_RIGHT" then
		command 	= G.CIRCLE;
		nomod 		= "ActionButton3";
		modshift 	= "ActionButton8";
		modctrl 	= "MultiBarBottomLeftButton3";
		shiftctrl 	= "MultiBarBottomLeftButton8";
	-- Triggers
	elseif key == "CP_TR1" then
		command		= "none";
		nomod 		= "ActionButton4";
		modshift 	= "ActionButton9";
		modctrl 	= "MultiBarBottomLeftButton4";
		shiftctrl 	= "MultiBarBottomLeftButton9";
	elseif key == "CP_TR2" then
		command		= "none";
		nomod 		= "ActionButton5";
		modshift 	= "ActionButton10";
		modctrl 	= "MultiBarBottomLeftButton5";
		shiftctrl 	= "MultiBarBottomLeftButton10";
	-- Left side
	elseif key == "CP_L_DOWN" then
		command		= G.DOWN;
		nomod 		= "ActionButton11";
		modshift 	= "MultiBarBottomRightButton4";
		modctrl  	= "MultiBarBottomRightButton8";
		shiftctrl	= "MultiBarBottomRightButton12";
	elseif key == "CP_L_LEFT" then
		command		= G.LEFT;
		nomod 		= "MultiBarBottomLeftButton11";
		modshift 	= "MultiBarBottomRightButton1";
		modctrl 	= "MultiBarBottomRightButton5";
		shiftctrl 	= "MultiBarBottomRightButton9";
	elseif key == "CP_L_UP" then
		command		= G.UP;
		nomod 		= "MultiBarBottomLeftButton12";
		modshift 	= "MultiBarBottomRightButton2";
		modctrl 	= "MultiBarBottomRightButton6";
		shiftctrl 	= "MultiBarBottomRightButton10";
	elseif key == "CP_L_RIGHT" then
		command		= G.RIGHT;
		nomod 		= "ActionButton12";
		modshift 	= "MultiBarBottomRightButton3";
		modctrl 	= "MultiBarBottomRightButton7";
		shiftctrl 	= "MultiBarBottomRightButton11";
	end
	local binding = {
		ui 		= command,
		action 	= nomod,
		shift 	= modshift,
		ctrl 	= modctrl,
		ctrlsh 	= shiftctrl
	}
	return binding;
end

function ConsolePort:GetDefaultAddonSettings()
	local t = {};
	t.type = "PS4";
	t.cam = false;
	return t;
end

 function ConsolePort:OnVariablesLoaded()
        if not ConsolePortBindingSet then
        	ConsolePortBindingSet = ConsolePort:GetDefaultBindingSet();
        end

        if not ConsolePortBindingButtons then
        	ConsolePortBindingButtons = ConsolePort:GetDefaultBindingButtons();
        end

        if not ConsolePortSettings then
        	ConsolePortSettings = ConsolePort:GetDefaultAddonSettings();
        end

        G.ConsolePort_Loaded = true;
 end


function ConsolePort:CreateMouseLooker()
	local p = UIParent;
	local f = CreateFrame("Frame", "CP_MOUSELOOK", p);
	local t = f:CreateTexture(nil,"BACKGROUND")
	f:SetPoint("CENTER", p, 0, -50);
	f:SetWidth(70);
	f:SetHeight(180);
	f:SetAlpha(0);
	f:Show();
	return f;
end

function ConsolePort:VehicleActionBarOverride()
	CP_R_LEFT_NOMOD:SetAttribute(	"clickbutton", OverrideActionBarButton1 );
	CP_R_UP_NOMOD:SetAttribute(		"clickbutton", OverrideActionBarButton2	);
	CP_R_RIGHT_NOMOD:SetAttribute(	"clickbutton", OverrideActionBarButton3 );
	CP_L_LEFT_NOMOD:SetAttribute(	"clickbutton", OverrideActionBarButton4 );
	CP_L_UP_NOMOD:SetAttribute(		"clickbutton", OverrideActionBarButton5 );
	CP_L_RIGHT_NOMOD:SetAttribute(	"clickbutton", OverrideActionBarButton6 );
	CP_L_DOWN_NOMOD:SetAttribute(	"clickbutton", OverrideActionBarLeaveFrameLeaveButton );
end

function ConsolePort:PetBattleActionBarOverride()
	-- not done
	CP_R_LEFT_NOMOD:SetAttribute(	"clickbutton", OverrideActionBarButton1 );
	CP_R_UP_NOMOD:SetAttribute(		"clickbutton", OverrideActionBarButton2	);
	CP_R_RIGHT_NOMOD:SetAttribute(	"clickbutton", OverrideActionBarButton3 );
	CP_L_LEFT_NOMOD:SetAttribute(	"clickbutton", OverrideActionBarButton4 );
	CP_L_UP_NOMOD:SetAttribute(		"clickbutton", OverrideActionBarButton5 );
	CP_L_RIGHT_NOMOD:SetAttribute(	"clickbutton", OverrideActionBarButton6 );
	CP_L_DOWN_NOMOD:SetAttribute(	"clickbutton", OverrideActionBarLeaveFrameLeaveButton );
end
-- ConsolePort:CreateButton(name, clickbutton, UIcommand)
-- ConsolePort:CreateConfigButton(name, parent, xoffset, yoffset)
function ConsolePort:CreateBindingButtons(enabled)
	local keys = ConsolePortBindingButtons;
	local y = 1;
	table.sort(keys);
	for name, key in pairsByKeys(keys) do
		local x = 1;
		ConsolePort:CreateConfigGuideButton(name, G["NAME_"..name], G.binds, 0, y);
		if key.action 	then ConsolePort:CreateSecureButton(name, NOMOD,	key.action,	key.ui);
							 ConsolePort:CreateConfigButton(name..NOMOD, x, y);	x = x + 1;	end;
		if key.shift 	then ConsolePort:CreateSecureButton(name,	SHIFT, 	key.shift, 	key.ui);
							 ConsolePort:CreateConfigButton(name..SHIFT, x, y);	x = x + 1; 	end;
		if key.ctrl 	then ConsolePort:CreateSecureButton(name,	CTRL,  	key.ctrl, 	key.ui);
							 ConsolePort:CreateConfigButton(name..CTRL, x, y);	x = x + 1; 	end;
		if key.ctrlsh 	then ConsolePort:CreateSecureButton(name, CTRLSH,	key.ctrlsh, key.ui); 	
							 ConsolePort:CreateConfigButton(name..CTRLSH, x, y);	x = x + 1; 	end;
		y = y + 1;
	end
end