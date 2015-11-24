local addOn, db = ...
local KEY = db.KEY
local UIControls = db.UIControls
local hasUIFocus = false

-- UIControl tables
local stack = {}

-- UIControl frame watcher
local frameWatchers = 0
local hasFrameWatch = false
local frameWatch = {}
local specialframes = {}

--- Localize frequently used globals
-- Functions
local InCombatLockdown = InCombatLockdown
local tinsert = tinsert
local pairs = pairs
local wipe = wipe
-- Widgets
local ConsolePort = ConsolePort

function ConsolePort:GetDefaultUIFrames()
	return {	
		Blizzard_AchievementUI 		= { "AchievementFrame" },
		Blizzard_ArchaeologyUI 		= { "ArchaeologyFrame" },
		Blizzard_AuctionUI 			= { "AuctionFrame" },
		Blizzard_BarbershopUI		= { "BarberShopFrame" },
		Blizzard_Calendar			= { "CalendarFrame" },
		Blizzard_Collections		= { "CollectionsJournal" },
		Blizzard_DeathRecap			= { "DeathRecapFrame" },
		Blizzard_EncounterJournal 	= { "EncounterJournal" },
		Blizzard_GarrisonUI			= {
			"GarrisonBuildingFrame", "GarrisonCapacitiveDisplayFrame",
			"GarrisonLandingPage", "GarrisonMissionFrame",
			"GarrisonMonumentFrame", "GarrisonShipyardFrame" },
		Blizzard_GuildUI			= { "GuildFrame" },
		Blizzard_InspectUI			= { "InspectFrame" },
		Blizzard_ItemAlterationUI 	= { "TransmogrifyFrame" },
		Blizzard_LookingForGuildUI 	= { "LookingForGuildFrame" },
		Blizzard_MacroUI 			= { "MacroFrame" },
		Blizzard_QuestChoice 		= { "QuestChoiceFrame" },
		Blizzard_TalentUI 			= { "PlayerTalentFrame" },
		Blizzard_TradeSkillUI		= { "TradeSkillFrame" },
		Blizzard_TrainerUI 			= { "ClassTrainerFrame" },
		Blizzard_VoidStorageUI		= { "VoidStorageFrame" },
	-- Core
		ConsolePort					= {
			"StaticPopup1", "StaticPopup2", "StaticPopup3", "StaticPopup4",
			"AddonList", "BagHelpBox", "BankFrame", "BasicScriptErrors",
			"CharacterFrame", "ChatMenu", "CinematicFrameCloseDialog", "ContainerFrame1",
			"ContainerFrame2", "ContainerFrame3", "ContainerFrame4", "ContainerFrame5",
			"ContainerFrame6", "ContainerFrame7", "ContainerFrame8", "ContainerFrame9",
			"ContainerFrame10", "ContainerFrame11", "ContainerFrame12", "ContainerFrame13",
			"DressUpFrame", "DropDownList1", "DropDownList2", "FriendsFrame",	
			"GameMenuFrame", "GossipFrame",	"GuildInviteFrame", "InterfaceOptionsFrame",
			"ItemRefTooltip", "ItemTextFrame", "LFDRoleCheckPopup", "LFGDungeonReadyDialog", "LFGInvitePopup",
			"LootFrame", "MailFrame", "MerchantFrame", "OpenMailFrame",
			"PetBattleFrame", "PetitionFrame", "PVEFrame", "PVPReadyDialog",
			"QuestFrame","QuestLogPopupDetailFrame","RecruitAFriendFrame", "SpellBookFrame",
			"SpellFlyout", "SplashFrame", "StackSplitFrame", "TaxiFrame", "TutorialFrame",
			"VideoOptionsFrame", "WorldMapFrame",
			"GroupLootFrame1", "GroupLootFrame2", "GroupLootFrame3", "GroupLootFrame4"
		},
	}
end

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

local function FrameShow(self)
	ConsolePort:UpdateFrames()
end

local function FrameHide(self)
	hasUIFocus = nil
	ConsolePort:UpdateFrames()
end

local function CheckFrameWatchers(self)
	frameWatchers = 0
	for frame, _ in pairs(frameWatch) do
		if self:AddFrame(frame) then
			frameWatch[frame] = nil
		else
			frameWatchers = frameWatchers + 1
		end
	end
	if 	frameWatchers == 0 then
		hasFrameWatch = false
	end
end

local function CheckSpecialFrames(self)
	local frames = UISpecialFrames
	for i, frame in pairs(frames) do
		if not specialframes[frame] then
			if self:AddFrame(frame) then
				specialframes[frame] = true
			end
		end
	end
end

function ConsolePort:AddFrame(frame, priority)
	local UIControl = _G[frame]
	if 	UIControl then
		UIControl:HookScript("OnShow", FrameShow)
		UIControl:HookScript("OnHide", FrameHide)
		if priority then tinsert(UIControls, priority, UIControl)
		else tinsert(UIControls, UIControl) end
		return true
	else
		self:AddFrameWatch(frame)
	end
end

function ConsolePort:CheckLoadedAddons()
	local addOnList = ConsolePortUIFrames
	for name, frames in pairs(addOnList) do
		if IsAddOnLoaded(name) then
			for i, frame in pairs(frames) do
				self:AddFrame(frame)
			end
		end
	end
end

function ConsolePort:UpdateFrames()
	if not InCombatLockdown() then
		local defaultActions = true
		if hasFrameWatch then
			CheckFrameWatchers(self)
		end
		CheckSpecialFrames(self)
		for i, UIControl in pairs(UIControls) do
			if 	UIControl:IsVisible() and
				UIControl:GetPoint() then
				defaultActions = false
				if not hasUIFocus then
					hasUIFocus = true
					self.Cursor:Show()
					self:SetButtonActionsUI()
					self:UIControl(KEY.PREPARE, KEY.STATE_UP)
				end
				break
			end
		end
		if defaultActions then
			self:SetButtonActionsDefault()
		end
	end
end

function ConsolePort:HasUIFocus()
	return hasUIFocus
end

function ConsolePort:AddFrameWatch(frame)
	frameWatch[frame] = true
	hasFrameWatch = true
end

function ConsolePort:GetFrameStack()
	wipe(stack)
	if ConsolePortRebindFrame:IsVisible() then
		if ConsolePortRebindFrame.isRebinding then
			for _, Frame in pairs({UIParent:GetChildren()}) do
				if not Frame:IsForbidden() and
					Frame:IsVisible() and
					Frame ~= InterfaceOptionsFrame then
					tinsert(stack, Frame)
				end
			end
		end
		tinsert(stack, DropDownList1)
		tinsert(stack, DropDownList2)
		tinsert(stack, ConsolePortRebindFrame)
	else
		for _, UIControl in pairs(UIControls) do
			if 	UIControl:IsVisible() and 
				UIControl:GetPoint() then
				tinsert(stack, UIControl)
			end
		end
	end
	return stack
end