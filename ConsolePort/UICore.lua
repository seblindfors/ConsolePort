local addOn, db = ...
local KEY = db.KEY
local UIControls = db.UI.Controls
local focusFrame = nil
local defaultActions = true
local focusAttr = nil

local addOns = {	
	Blizzard_AchievementUI 		= {	"AchievementFrame" },
	Blizzard_ArchaeologyUI 		= {	"ArchaeologyFrame" },
	Blizzard_AuctionUI 			= { "AuctionFrame" },
	Blizzard_BarbershopUI		= { "BarberShopFrame" },
	Blizzard_Calendar			= {	"CalendarFrame" },
	Blizzard_Collections		= {	"CollectionsJournal" },
	Blizzard_DeathRecap			= {	"DeathRecapFrame" },
	Blizzard_EncounterJournal 	= {	"EncounterJournal" },
	Blizzard_GarrisonUI			= {
		"GarrisonBuildingFrame",
		"GarrisonLandingPage",
		"GarrisonMissionFrame",
		"GarrisonMonumentFrame",
		"GarrisonCapacitiveDisplayFrame",
		"GarrisonShipyardFrame" },
	Blizzard_GuildUI			= {	"GuildFrame" },
	Blizzard_InspectUI			= {	"InspectFrame" },
	Blizzard_ItemAlterationUI 	= {	"TransmogrifyFrame" },
	Blizzard_LookingForGuildUI 	= {	"LookingForGuildFrame" },
	Blizzard_MacroUI 			= {	"MacroFrame" },
	Blizzard_QuestChoice 		= {	"QuestChoiceFrame" },
	Blizzard_TalentUI 			= {	"PlayerTalentFrame" },
	Blizzard_TradeSkillUI		= { "TradeSkillFrame" },
	Blizzard_TrainerUI 			= {	"ClassTrainerFrame" },
	Blizzard_VoidStorageUI		= {	"VoidStorageFrame" },
-- Core
	ConsolePort					= {
		"AddonList",
		"BankFrame",
		"BasicScriptErrors",
		"CharacterFrame",
		"ChatMenu",
		"CinematicFrameCloseDialog",
		"ContainerFrame1",
		"ContainerFrame2",
		"ContainerFrame3",
		"ContainerFrame4",
		"ContainerFrame5",
		"ContainerFrame6",
		"ContainerFrame7",
		"ContainerFrame8",
		"ContainerFrame9",
		"ContainerFrame10",
		"ContainerFrame11",
		"ContainerFrame12",
		"ContainerFrame13",
		"DropDownList1",
		"DropDownList2",
		"FriendsFrame",	
		"GameMenuFrame",
		"GossipFrame",	
		"GuildInviteFrame",
		"InterfaceOptionsFrame",
		"ItemRefTooltip",
		"ItemTextFrame",
		"LootFrame",	
		"MailFrame",	
		"MerchantFrame",
		"OpenMailFrame",
		"PetBattleFrame",
		"PetitionFrame",
		"PVEFrame",
		"QuestFrame",	
		"QuestLogPopupDetailFrame",
		"SpellBookFrame",
		"SpellFlyout",	
		"SplashFrame",	
		"StackSplitFrame",
		"TaxiFrame",	
		"VideoOptionsFrame",	
		"WorldMapFrame",
		"GroupLootFrame1",
		"GroupLootFrame2",
		"GroupLootFrame3",
		"GroupLootFrame4" }
}

local hasPriority = {
	ContainerFrame1Item16,
	GossipTitleButton1,
	HonorFrameSoloQueueButton,
	LFDQueueFrameFindGroupButton,
	MerchantItem1ItemButton,
	MerchantRepairAllButton,
	PaperDollSidebarTab3,
	QuestFrameAcceptButton,
	QuestFrameCompleteButton,
	QuestFrameCompleteQuestButton,
	QuestTitleButton1,
	QuestMapFrame.DetailsFrame.BackButton,
	QuestScrollFrame.ViewAll,
}

local ignoreNode = {
	LootFrameCloseButton,
	WorldMapTitleButton,
	WorldMapButton,
}

for i, node in pairs(hasPriority) do
	node.hasPriority = true
end

for i, node in pairs(ignoreNode) do
	node.ignoreNode = true
end

local num = 1
local function AddFrame(controlFrame, prepFunction, attribute, priority)
	local UIControl = { 
		frame = controlFrame,
		func = prepFunction,
		attr = attribute,
		isPrepared = false,
		isFaded = false
	}
	num = num + 1
	UIControl.frame:HookScript("OnShow", function(self)
		focusFrame = UIControl
		if InCombatLockdown() then
			UIFrameFadeIn(UIControl.frame, 0.2, 0, 0.5)
		else
			UIFrameFadeIn(UIControl.frame, 0.2, 0, 1)
		end
	end)
	UIControl.frame:HookScript("OnHide", function(self)
		UIControl.isPrepared = false
		GameTooltip:Hide()
	end)
	if priority then tinsert(UIControls, priority, UIControl)
	else tinsert(UIControls, UIControl) end
end

local function AddUIControlFrame(self, controlFrame)
	AddFrame(controlFrame, self.UIControl, "UIControl", nil)
end

local function AddPopupFrames(self)
	local specialFrames = {
		{ StaticPopup1,				self.Popup,		"Popup"	},
		{ StaticPopup2,				self.Popup,		"Popup"	},
		{ StaticPopup3,				self.Popup,		"Popup"	},
		{ StaticPopup4,				self.Popup,		"Popup"	},
	}
	for i, frame in pairs(specialFrames) do
		AddFrame(frame[1], frame[2], frame[3], i)
	end
end

function ConsolePort:UpdateFrames()
	local framesOpen = 0
	local priorityFrame = nil
	if 	not db.Binds:IsVisible() then
		for i, UIControl in pairs(UIControls) do
			if UIControl.frame:IsVisible() then
				framesOpen = framesOpen + 1
				priorityFrame = UIControl
			end
		end
		if 	focusFrame and not
			focusFrame.frame:IsVisible() then
			focusFrame = nil
			focusAttr = nil
		end
		if 	framesOpen == 0 then
			focusFrame = nil
			focusAttr = nil
			if not defaultActions then
				self:SetButtonActionsDefault()
				defaultActions = true
			end
		elseif 	framesOpen >= 1 and not focusFrame then
			focusFrame = priorityFrame
			for i, UIControl in pairs(UIControls) do
				if 	UIControl.frame:IsVisible() and
					UIControl.isFaded and
					UIControl.attr == focusFrame.attr then
					UIControl.frame:SetAlpha(1)
					UIControl.isFaded = false
				end
			end
		end
		if 	focusFrame then
			if 	not focusFrame.isPrepared then
				for i, UIControl in pairs(UIControls) do
					if UIControl.frame:IsVisible() then
						if 	UIControl.attr ~= focusFrame.attr and
							not UIControl.isFaded then
							UIControl.frame:SetAlpha(0.5)
							UIControl.isFaded = true
						elseif UIControl.isFaded then
							UIControl.frame:SetAlpha(1)
							UIControl.isFaded = false
						end
					end
				end
				focusFrame.func(self, KEY.PREPARE, KEY.STATE_UP)
				focusFrame.isPrepared = true
			end
			if focusAttr ~= focusFrame.attr then
				self:SetButtonActions(focusFrame.attr)
				focusAttr = focusFrame.attr
			end
			if 	defaultActions then
				defaultActions = false
			end
		end
	end
end

function ConsolePort:GetFocusFrame()
	return focusFrame
end

function ConsolePort:GetFocusAttribute()
	return focusAttr
end

function ConsolePort:ADDON_LOADED(...)
	local name = ...
	if name == addOn then
		AddPopupFrames(self)
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
		self.AddFrame = AddFrame
	end
	if addOns[name] then
		for i, frame in pairs(addOns[name]) do
			AddUIControlFrame(self, _G[frame])
		end
	end
end