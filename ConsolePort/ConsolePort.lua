-- ConsolePort 
local addOn, db = ...;
local KEY = db.KEY;

local f = ConsolePort;
local m = ConsolePort:CreateMouseLooker();

local HookFrames = {};
local FocusFrame = nil;

function ConsolePort:GetFocusFrame()
	return FocusFrame;
end

local function MouseLookShouldStart()
	if 	not SpellIsTargeting() 			and
		not IsMouseButtonDown(1) 		and
		not GetCursorInfo() 			and
		MouseIsOver(m) 					and
		(GetMouseFocus() == WorldFrame) then
		return true;
	end
end

local function ToggleMouseLook(frameEvent)
	if 	ConsolePortMouseSettings then
		return ConsolePortMouseSettings[frameEvent];
	end
	return true;
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

local function LoadHooks(self)
	local LoadFrames = {
		{ AddonList,				self.General,	"General"	},
		{ BankFrame,				self.General,	"General"	},
		{ CharacterFrame, 			self.General, 	"General" 	},
		{ DropDownList1,			self.General, 	"General"	},
		{ DropDownList2,			self.General, 	"General"	},
		{ FriendsFrame,				self.General, 	"General"	},
		{ GameMenuFrame, 			self.General, 	"General" 	},
		{ GossipFrame, 				self.General,	"General"	},
		{ GuildInviteFrame,			self.General,	"General"	},
		{ InterfaceOptionsFrame,	self.General, 	"General"	},
		{ ItemRefTooltip,			self.General, 	"General"	},
		{ ItemTextFrame,			self.General,	"General"	},
		{ LootFrame,				self.General, 	"General"	},
		{ MailFrame,				self.General,	"General"	},
		{ MerchantFrame, 			self.General, 	"General"	},
		{ OpenMailFrame,			self.General, 	"General"	},
		{ PetBattleFrame,			self.General, 	"General"	},
		{ PetitionFrame, 			self.General,	"General"	},
		{ PVEFrame,					self.General,	"General"	},
	--	{ PVPReadyDialog,			self.General,	"General"	}, -- bug
		{ QuestFrame, 				self.General, 	"General"	},
		{ QuestLogPopupDetailFrame, self.General,	"General"	},
		{ SpellBookFrame,			self.General,	"General"	},
		{ SplashFrame,				self.General,	"General"	},
		{ StackSplitFrame,			self.General, 	"General"	},
		{ TaxiFrame, 				self.General, 	"General"	},
		{ VideoOptionsFrame,		self.General,	"General"	},
		{ WorldMapFrame, 			self.General, 	"General" 	},
		{ GroupLootFrame1,			self.General,	"General"	},
		{ GroupLootFrame2,			self.General,	"General"	},
		{ GroupLootFrame3,			self.General,	"General"	},
		{ GroupLootFrame4,			self.General,	"General"	},
		{ StaticPopup1,				self.Popup,		"Popup"	},
		{ StaticPopup2,				self.Popup,		"Popup"	},
		{ StaticPopup3,				self.Popup,		"Popup"	},
		{ StaticPopup4,				self.Popup,		"Popup"	},
		{ CinematicFrame,			self.Misc,		"Misc"	},
	}
	for i, Frame in pairs(LoadFrames) do
		PostLoadHook(Frame[1], Frame[2], Frame[3], i);
	end
end

local DefaultActions = true;
local FocusAttr = nil;
local function UpdateFrames(self)
	local FramesOpen = 0;
	local PriorityFrame = nil;
	if 	not db.Binds:IsVisible() then
		for _, Hook in pairs(HookFrames) do
			if Hook.frame:IsVisible() then
				FramesOpen = FramesOpen + 1;
				PriorityFrame = Hook;
			end
		end
		if 	FocusFrame and not
			FocusFrame.frame:IsVisible() then
			FocusFrame = nil;
			FocusAttr = nil;
		end
		if 	FramesOpen == 0 then
			FocusFrame = nil;
			FocusAttr = nil;
			if not DefaultActions then
				self:SetButtonActionsDefault();
				DefaultActions = true;
			end
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
				FocusFrame.func(self, KEY.PREPARE, KEY.STATE_UP);
				FocusFrame.isPrepared = true;
			end
			if FocusAttr ~= FocusFrame.attr then
				self:SetButtonActions(FocusFrame.attr);
				FocusAttr = FocusFrame.attr;
			end
			if 	DefaultActions then
				DefaultActions = false;
			end
		end
	end
end

function ConsolePort:GetFrameStack()
	local stack = {}
	for _, Hook in pairs(HookFrames) do
		if Hook.frame:IsVisible() then
			tinsert(stack, Hook.frame)
		end
	end
	return stack
end

local interval = 0.1
local time = 0
local MouseIsCentered = false
local function OnUpdate (self, elapsed)
	time = time + elapsed
	while time > interval do
		if GetCursorInfo() then
			MouselookStop()
		elseif not MouseIsCentered and
			MouseLookShouldStart() then
			MouselookStart()
			MouseIsCentered = true;
		elseif not MouseIsOver(m) and MouseIsCentered then
			MouseIsCentered = false
		end
		if not InCombatLockdown() then
			UpdateFrames(self)
		end
		time = time - interval
	end
end

local function OnEvent (self, event, ...)
	if 	self[event] then
		self[event](self, ...);
		return;
	end
	self:SetButtonMapping(self, event);
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
	elseif	event == "WORLD_MAP_UPDATE" and not
			QuestScrollFrame:GetAlpha() ~= 1 then
		self:MapGetZones();
	elseif 	event == "QUEST_AUTOCOMPLETE" then
		local arg1 = ...;
		ShowQuestComplete(GetQuestLogIndexByID(arg1));
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
	elseif	event == "PLAYER_REGEN_ENABLED" then
		self:SetButtonActionsDefault();
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

function ConsolePort:ADDON_LOADED(...)
	local name = ...
	if name == addOn then
		LoadHooks(self)
		self:CreateManager()
		self:LoadStrings()
		self:OnVariablesLoaded()
		self:LoadEvents()
		self:UpdateExtraButton()
		self:LoadHookScripts()
		self:CreateConfigPanel()
		self:CreateBindingButtons()
		self:LoadBindingSet()
		self:GetIndicatorSet()
		self:ReloadBindingActions()
		self.PostLoadHook = PostLoadHook
	elseif name == "Blizzard_TalentUI" then
		PostLoadHook(PlayerTalentFrame, self.General, "General", nil);
	elseif name == "Blizzard_AchievementUI" then
		PostLoadHook(AchievementFrame, self.General, "General", nil)
	elseif name == "Blizzard_ArchaeologyUI" then
		PostLoadHook(ArchaeologyFrame, self.General, "General", nil)
	elseif name == "Blizzard_Calendar" then
		PostLoadHook(CalendarFrame, self.General, "General", nil)
	elseif name == "Blizzard_Collections" then
		PostLoadHook(CollectionsJournal, self.General, "General", nil)
	elseif name == "Blizzard_DeathRecap" then
		PostLoadHook(DeathRecapFrame, self.General, "General", nil);
	elseif name == "Blizzard_EncounterJournal" then
		PostLoadHook(EncounterJournal, self.General, "General", nil)
	elseif name == "Blizzard_GarrisonUI" then
		PostLoadHook(GarrisonLandingPage, self.General, "General", nil)
		PostLoadHook(GarrisonMissionFrame, self.General, "General", nil)
		PostLoadHook(GarrisonMonumentFrame, self.General, "General", nil)
		PostLoadHook(GarrisonCapacitiveDisplayFrame, self.General, "General", nil)
	elseif name == "Blizzard_GuildUI" then
		PostLoadHook(GuildFrame, self.General, "General", nil)
	elseif name == "Blizzard_InspectUI" then
		PostLoadHook(InspectFrame, self.General, "General", nil)
	elseif name == "Blizzard_ItemAlterationUI" then
		PostLoadHook(TransmogrifyFrame, self.General, "General", nil)
	elseif name == "Blizzard_LookingForGuildUI" then
		PostLoadHook(LookingForGuildFrame, self.General, "General", nil)
	elseif name == "Blizzard_MacroUI" then
		PostLoadHook(MacroFrame, self.General, "General", nil)
	elseif name == "Blizzard_QuestChoice" then
		PostLoadHook(QuestChoiceFrame, self.General, "General", nil)
	elseif name == "Blizzard_TradeSkillUI" then
		PostLoadHook(TradeSkillFrame, self.General, "General", nil)
	elseif name == "Blizzard_TrainerUI" then
		PostLoadHook(ClassTrainerFrame, self.General, "General", nil)
	elseif name == "Blizzard_VoidStorageUI" then
		PostLoadHook(VoidStorageFrame, self.General, "General", nil)
	elseif name == "ConsolePort_Container" then
		PostLoadHook(ConsolePortContainer, self.General, "General", nil)
	end
end

function ConsolePort:GetInterfaceButtons()
	return {
		CP_L_UP_NOMOD, 		--1
		CP_L_DOWN_NOMOD,	--2
		CP_L_RIGHT_NOMOD,	--3
		CP_L_LEFT_NOMOD,	--4
		CP_R_LEFT_NOMOD,	--5
		CP_R_RIGHT_NOMOD,	--6
		CP_R_UP_NOMOD,		--7
	}
end

function ConsolePort:SetButtonActionsDefault()
	FocusAttr = nil;
	for _, button in pairs(self:GetInterfaceButtons()) do
		button.revert();
	end
end

function ConsolePort:SetButtonActions (type)
	local Buttons = self:GetInterfaceButtons();
	local IgnoreIndex = {};
	if 		type == "Loot" 		then IgnoreIndex = {1, 2, 5, 6};
	elseif 	type == "Popup" 	then IgnoreIndex = {5, 6};
	elseif 	type == "Bags" 		then IgnoreIndex = {6};
	elseif 	type == "General" 	then IgnoreIndex = {5, 6};
	end
	for _, index in pairs(IgnoreIndex) do
		Buttons[index] = nil;
	end
	for i, button in pairs(Buttons) do
		button:SetAttribute("type", type);
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
		if 	state == KEY.STATE_DOWN then
			button:LockHighlight();
			button:SetButtonState("PUSHED", false);
		elseif state == KEY.STATE_UP then
			button:UnlockHighlight();
			button:SetButtonState("NORMAL", false);
			button:Click();
		end
	end
end

function ConsolePort:Misc (key, state)
	if key == KEY.PREPARE then return; end;
	if CinematicFrameCloseDialog:IsVisible() then
		if key == KEY.CIRCLE then
			ConsolePort:Button(CinematicFrameCloseDialogResumeButton, state);
		elseif key == KEY.SQUARE then
			ConsolePort:Button(CinematicFrameCloseDialogConfirmButton, state);
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

f:RegisterEvent("ADDON_LOADED");
f:RegisterEvent("PLAYER_LOGOUT");
f:SetScript("OnEvent", OnEvent);
f:SetScript("OnUpdate", OnUpdate);
