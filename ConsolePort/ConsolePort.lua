-- ConsolePort 
local _
local addOn, G = ...;
local interval = 0.1;
local time = 0;

local MouseIsCentered  = false;
local f = ConsolePort;
local m = ConsolePort:CreateMouseLooker();
local HookFrames = {};
local FocusFrame = nil;

function ConsolePort:GetFocusFrame()
	return FocusFrame;
end

-- In preparation for mouse look options
local function MouseLookOnHover()
	if MouseIsOver(m) then
		return true;
	end
end

local function ToggleMouseLook(frameEvent)
	if 	ConsolePortMouseSettings then
		return ConsolePortMouseSettings[frameEvent];
	end
	return true;
end

-- Recursively desaturate textures
local function SetDesaturation(frame, value)
  for i, child in pairs({frame:GetChildren()}) do
     SetDesaturation(child, value);
  end
  for i, region in pairs({frame:GetRegions()}) do
     if region.SetDesaturated then
        region:SetDesaturated(value);
     end
  end
end

local function PostLoadHook(hookFrame, prepFunction, attribute, priority)
	local Hook = { 
		frame = hookFrame,
		func = prepFunction,
		attr = attribute,
		isPrepared = false,
		isFaded = false
	}
	Hook.frame:HookScript("OnShow", function(self)
		FocusFrame = Hook;
		if InCombatLockdown() then
			UIFrameFadeIn(Hook.frame, 0.2, 0, 0.5);
		else
			UIFrameFadeIn(Hook.frame, 0.2, 0, 1);
		end
	end);
	Hook.frame:HookScript("OnHide", function(self)
		Hook.isPrepared = false;
		GameTooltip:Hide();
	end);
	if priority then tinsert(HookFrames, priority, Hook);
	else tinsert(HookFrames, Hook); end;
end

local function LoadHooks ()
	local LoadFrames = {
		{ PaperDollFrame, 			ConsolePort.Gear, 	"Gear" 	},
		{ GameMenuFrame, 			ConsolePort.Menu, 	"Menu" 	},
		{ ContainerFrame1, 			ConsolePort.Bags, 	"Bags" 	},
		{ ContainerFrame2, 			ConsolePort.Bags,	"Bags" 	},
		{ ContainerFrame3, 			ConsolePort.Bags, 	"Bags" 	},
		{ ContainerFrame4, 			ConsolePort.Bags, 	"Bags" 	},
		{ ContainerFrame5, 			ConsolePort.Bags, 	"Bags" 	},
		{ MerchantFrame, 			ConsolePort.Shop, 	"Shop"	},
		{ WorldMapFrame, 			ConsolePort.Map, 	"Map" 	},
		{ TaxiFrame, 				ConsolePort.Taxi, 	"Taxi"	},
		{ SpellBookSpellIconsFrame,	ConsolePort.Book,	"Book"	},
		{ QuestFrame, 				ConsolePort.Quest, 	"Quest"	},
		{ QuestLogPopupDetailFrame, ConsolePort.Quest,	"Quest"	},
		{ GossipFrame, 				ConsolePort.Gossip,	"Gossip"},
		{ GuildInviteFrame,			ConsolePort.Guild,	"Guild"	},
		{ PetitionFrame, 			ConsolePort.Misc,	"Misc"	},
		{ StackSplitFrame,			ConsolePort.Stack, 	"Stack"	},
		{ GroupLootFrame1,			ConsolePort.Loot,	"Loot"	},
		{ GroupLootFrame2,			ConsolePort.Loot,	"Loot"	},
		{ GroupLootFrame3,			ConsolePort.Loot,	"Loot"	},
		{ GroupLootFrame4,			ConsolePort.Loot,	"Loot"	},
		{ LootFrame,				ConsolePort.Loot, 	"Loot"	},
		{ StaticPopup1,				ConsolePort.Popup,	"Popup"	},
		{ StaticPopup2,				ConsolePort.Popup,	"Popup"	},
		{ StaticPopup3,				ConsolePort.Popup,	"Popup"	},
		{ StaticPopup4,				ConsolePort.Popup,	"Popup"	},
		{ CinematicFrame,			ConsolePort.Misc,	"Misc"	},
		{ SplashFrame,				ConsolePort.Misc,	"Misc"	},
	}
	for i, Frame in pairs(LoadFrames) do
		PostLoadHook(Frame[1], Frame[2], Frame[3], i);
	end
end

local function UpdateFrames(self)
	local FramesOpen = 0;
	local PriorityFrame = nil;
	if 	not G.binds:IsVisible() and 
		CP_R_RIGHT_NOMOD.state ~= G.STATE_DOWN then
		for _, Hook in pairs(HookFrames) do
			if Hook.frame:IsVisible() then
				FramesOpen = FramesOpen + 1;
				PriorityFrame = Hook;
			end
		end
		if 	FocusFrame and not
			FocusFrame.frame:IsVisible() then
			FocusFrame = nil;
		end
		if 	FramesOpen == 0 then
			FocusFrame = nil;
			self:SetButtonActionsDefault();
		elseif 	FramesOpen >= 1 and not FocusFrame then
			FocusFrame = PriorityFrame;
			for _, Hook in pairs(HookFrames) do
				if 	Hook.frame:IsVisible() and
					Hook.isFaded and
					Hook.attr == FocusFrame.attr then
					Hook.frame:SetAlpha(1);
					Hook.isFaded = false;
				end
			end
		end
		if 	FocusFrame then
			if 	not FocusFrame.isPrepared then
				for _, Hook in pairs(HookFrames) do
					if Hook.frame:IsVisible() then
						if 	Hook.attr ~= FocusFrame.attr and
							not Hook.isFaded then
							Hook.frame:SetAlpha(0.5);
							Hook.isFaded = true;
						elseif Hook.isFaded then
							Hook.frame:SetAlpha(1);
							Hook.isFaded = false;
						end
					end
				end
				FocusFrame.func(self, G.PREPARE, G.STATE_UP);
				FocusFrame.isPrepared = true;
			end
			self:SetButtonActions(FocusFrame.attr);
		end
	end
end

local function OnUpdate (self, elapsed)
	time = time + elapsed;
	while time > interval do
		local TopFrameIsOverlay = (GetMouseFocus() == WorldFrame);
		local CursorIsEmpty 	= (GetCursorInfo() == nil);
		if 	MouseLookOnHover() and
			TopFrameIsOverlay and
			CursorIsEmpty and
			not MouseIsCentered and
			not SpellIsTargeting() and
			not IsMouseButtonDown(1) then
			MouselookStart();
			MouseIsCentered = true;
		elseif not MouseIsOver(m) and MouseIsCentered then
			MouseIsCentered = false;
		end
		if not InCombatLockdown() then
			UpdateFrames(self);
		end
		time = time - interval;
	end
end

local function OnEvent (self, event, ...)
	self:SetButtonMapping(self, event);
	if ConsolePortSettings and ConsolePortSettings.cam then
		self:AutoCameraView(event, ...);
	end
	if 	((event == "PLAYER_TARGET_CHANGED" and
		ToggleMouseLook(event) and
		UnitName("target")) or
		ToggleMouseLook(event)) and
		(GetMouseFocus() == WorldFrame) and 
		not SpellIsTargeting() and 
		not IsMouseButtonDown(1) then
		MouselookStart();
	end
	if		event == "MERCHANT_SHOW" then
		self:CleanBags();
		CloseAllBags();
	elseif	event == "WORLD_MAP_UPDATE" and not
			QuestScrollFrame:GetAlpha() ~= 1 then
		self:MapGetZones();
	elseif	event == "QUEST_DETAIL" or 
			event == "QUEST_COMPLETE" then
		self:RegisterEvent("MODIFIER_STATE_CHANGED");
		self:Quest("rewards", G.STATE_UP);
	elseif 	event == "QUEST_AUTOCOMPLETE" then
		local arg1 = ...;
		ShowQuestComplete(GetQuestLogIndexByID(arg1));
	elseif 	event == "MODIFIER_STATE_CHANGED" then
		self:Quest("preview", G.STATE_UP);
	-- This is a bug fix. Will be removed eventually
	elseif 	event == "QUEST_LOG_UPDATE" then
		GameTooltip:Hide();
	elseif	event == "CURRENT_SPELL_CAST_CHANGED" then
		if SpellIsTargeting() then
			MouselookStop();
		elseif 	GetMouseFocus() == WorldFrame and
				ToggleMouseLook(event) then
			MouselookStart();
		end
	elseif	event == "UNIT_ENTERING_VEHICLE" then
		local arg1 = ...;
		if arg1 == "player" then
			for i=1, NUM_OVERRIDE_BUTTONS do
				if 	_G["OverrideActionBarButton"..i].HotKey then
					_G["OverrideActionBarButton"..i].HotKey:Hide();
				end
			end
		end
	elseif	event == "ADDON_LOADED" then
		local arg1 = ...;
		if arg1 == "Blizzard_TalentUI" then
			PostLoadHook(PlayerTalentFrame, self.Spec, "Spec", 11);
			self:InitializeTalents();
		elseif arg1 == "Blizzard_GlyphUI" then
			PostLoadHook(GlyphFrame, self.Spec, "Glyph", 12);
			self:InitializeGlyphs();
		elseif arg1 == "Blizzard_DeathRecap" then
			PostLoadHook(DeathRecapFrame, self.Misc, "Misc", nil);
			self:CreateIndicator(select(8, DeathRecapFrame:GetChildren()), "SMALL", "LEFT", G.NAME_CP_R_RIGHT);
		elseif arg1 == addOn then
			LoadHooks();
			self:CreateManager();
			self:LoadStrings();
			self:OnVariablesLoaded();
			self:LoadEvents();
			self:LoadHookScripts();
			self:CreateConfigPanel();
			self:CreateBindingButtons();
			self:LoadBindingSet();
			self:GetIndicatorSet();
			self:ReloadBindingActions();
		end
	elseif	event == "PLAYER_REGEN_ENABLED" then
		ConsolePort:SetButtonActionsDefault();
		for _, Hook in pairs(HookFrames) do
			if 	Hook.frame:IsVisible() then
				UIFrameFadeIn(Hook.frame, 0.2, 0.5, 1);
			else
				Hook.frame:SetAlpha(1);
			end
		end
	elseif	event == "PLAYER_REGEN_DISABLED" then
		for _, Hook in pairs(HookFrames) do
			if 	Hook.frame:IsVisible() then
				UIFrameFadeOut(Hook.frame, 0.2, 1, 0.5);
			else
				Hook.frame:SetAlpha(0.5);
			end
		end
	end
end

function ConsolePort:SetButtonActionsDefault()
	CP_L_UP_NOMOD.revert();
	CP_L_DOWN_NOMOD.revert();
	CP_L_RIGHT_NOMOD.revert();
	CP_L_LEFT_NOMOD.revert();
	CP_R_LEFT_NOMOD.revert();
	CP_R_RIGHT_NOMOD.revert();
	CP_R_UP_NOMOD.revert();
end

function ConsolePort:SetButtonActions (type)
	-- Exceptions are for secure button workarounds
	if (type ~= "Loot" and
		type ~= "Popup") then
		CP_R_LEFT_NOMOD:SetAttribute("type", type);
	end
	if (type == "Bags" and MerchantFrame:IsVisible()) or 
	   (type ~= "Bags" and
	   	type ~= "Book" and
	   	type ~= "Spec" and
		type ~= "Loot" and
		type ~= "Popup" and
		type ~= "Glyph") then
		CP_R_RIGHT_NOMOD:SetAttribute("type", type);
	end
	if (type ~= "Spec" and
		type ~= "Loot" and
		type ~= "Glyph") then
		CP_R_UP_NOMOD:SetAttribute("type", type);
	end
	if (type ~= "Loot" and
		type ~= "Glyph") then
		CP_L_UP_NOMOD:SetAttribute("type", type);
	end
	if (type ~= "Loot" and
		type ~= "Glyph") then
		CP_L_DOWN_NOMOD:SetAttribute("type", type);
	end
	if (type ~= "Book") then
		CP_L_RIGHT_NOMOD:SetAttribute("type", type);
	end
	if (type ~= "Book") then
		CP_L_LEFT_NOMOD:SetAttribute("type", type);
	end
end

function ConsolePort:SetClickButton (button, clickbutton)
	button:SetAttribute("type", "click");
	button:SetAttribute("clickbutton", clickbutton);
end

function ConsolePort:SetButtonMapping (self, event)
	if not InCombatLockdown() then
		ClearOverrideBindings(ConsolePort);
		if 		event == "UPDATE_BINDINGS" then
			self:LoadBindingSet();
		-- Revert to default behaviour
		elseif	event == "TAXIMAP_CLOSED" or
			  	event == "GOSSIP_CLOSED" or
			  	event == "QUEST_FINISHED" or 
			  	event == "MERCHANT_CLOSED" then
			-- Hacky fix
			GameTooltip:Hide();
			self:UnregisterEvent("MODIFIER_STATE_CHANGED");
		end
	end
end

function ConsolePort:OverrideBinding(self, priority, modifier, old, new)
	if not InCombatLockdown() then
		local key1, key2 = GetBindingKey(old);
		if modifier then
			if key1 then key1 = modifier.."-"..key1; end;
			if key2 then key2 = modifier.."-"..key2; end;
		end
		if key1 then SetOverrideBinding(self, priority, key1, new); end;
		if key2 then SetOverrideBinding(self, priority, key2, new); end;
	end
end

function ConsolePort:OverrideBindingClick(self, old, button, mouseClick)
	if not InCombatLockdown() then
		local key1, key2 = GetBindingKey(old);
		if key1 then SetOverrideBindingClick(self, true, key1, button, mouseClick); end;
		if key2 then SetOverrideBindingClick(self, true, key2, button, mouseClick); end;
	end
end

function ConsolePort:Button (button, state)
	if 	button:IsObjectType("BUTTON") and
		button:GetButtonState() ~= "DISABLED" then
		if 	state == G.STATE_DOWN then
			button:LockHighlight();
			button:SetButtonState("PUSHED", false);
		elseif state == G.STATE_UP then
			button:UnlockHighlight();
			button:SetButtonState("NORMAL", false);
			button:Click();
		end
	end
end

function ConsolePort:Misc (key, state)
	if key == G.PREPARE then return; end;
	if 	DeathRecapFrame and
		DeathRecapFrame:IsVisible() then
		if key == G.CIRCLE then
			local button = select(8, DeathRecapFrame:GetChildren());
			ConsolePort:Button(button, state);
		end
	elseif PetitionFrame:IsVisible() then
		if key == G.CIRCLE then
			ConsolePort:Button(PetitionFrameSignButton, state);
		elseif key == G.TRIANGLE then
			ConsolePort:Button(PetitionFrameCancelButton, state);
		end
	elseif CinematicFrameCloseDialog:IsVisible() then
		if key == G.CIRCLE then
			ConsolePort:Button(CinematicFrameCloseDialogResumeButton, state);
		elseif key == G.SQUARE then
			ConsolePort:Button(CinematicFrameCloseDialogConfirmButton, state);
		end
	elseif SplashFrame:IsVisible() then
		if key == G.CIRCLE then
			ConsolePort:Button(SplashFrame.BottomCloseButton, state);
		end
	elseif 	GarrisonCapacitiveDisplayFrame then
		if GarrisonCapacitiveDisplayFrame.StartWorkOrderButton:IsVisible() then
			if key == G.CIRCLE then
				ConsolePort:Button(GarrisonCapacitiveDisplayFrame.StartWorkOrderButton, state);
			end
		end
	end
end

function ConsolePort:Highlight (index, options)
	for i, item in ipairs(options) do
		if item:IsObjectType("Button") then
			if i == index then item:LockHighlight();
			else item:UnlockHighlight(); end
		end
	end
end

function ConsolePort:Guild (key, state)
	if 		key == G.CIRCLE and GuildInviteFrame:IsVisible() then
		ConsolePort:Button(GuildInviteFrameDeclineButton, state);
	elseif	key == G.TRIANGLE and GuildInviteFrame:IsVisible() then
		ConsolePort:Button(GuildInviteFrameJoinButton, state);
	end
end

local view = 5;
local yaw = false;
function ConsolePort:AutoCameraView(event, ...)
	if	(event == "QUEST_DETAIL" or
		event == "QUEST_GREETING" or
		event == "QUEST_PROGRESS" or
		event == "QUEST_COMPLETE" or
		event == "GOSSIP_SHOW" or
		event == "TAXIMAP_OPENED" or
		event == "MERCHANT_SHOW") then
		if not yaw then FlipCameraYaw(30); yaw = true; end;
		if view ~= 3 then SaveView(5); view = 3; SetView(view); end;
	elseif
		event == "GOSSIP_CLOSED" or
		event == "QUEST_FINISHED" or
		event == "TAXIMAP_CLOSED" or
		event == "MERCHANT_CLOSED" or
		event == "PLAYER_STARTED_MOVING" then
		if yaw then FlipCameraYaw(-30); yaw = false; end;
		if view ~= 5 then view = 5; SetView(view); end;
	end
end

f:RegisterEvent("ADDON_LOADED");
f:SetScript("OnEvent", OnEvent);
f:SetScript("OnUpdate", OnUpdate);
