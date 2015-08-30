local addOn, db = ...
local KEY = db.KEY
local UIControls = db.UI.Controls
local focusFrame = nil
local defaultActions = true
local focusAttr = nil

local addOns = {	
	Blizzard_AchievementUI 		= {
		"AchievementFrame" },
	Blizzard_ArchaeologyUI 		= {
		"ArchaeologyFrame" },
	Blizzard_AuctionUI 			= {
		"AuctionFrame" },
	Blizzard_BarbershopUI		= {
		"BarberShopFrame" },
	Blizzard_Calendar			= {
		"CalendarFrame" },
	Blizzard_Collections		= {
		"CollectionsJournal" },
	Blizzard_DeathRecap			= {
		"DeathRecapFrame" },
	Blizzard_EncounterJournal 	= {
		"EncounterJournal" },
	Blizzard_GarrisonUI			= {
		"GarrisonBuildingFrame",
		"GarrisonLandingPage",
		"GarrisonMissionFrame",
		"GarrisonMonumentFrame",
		"GarrisonCapacitiveDisplayFrame",
		"GarrisonShipyardFrame" },
	Blizzard_GuildUI			= {
		"GuildFrame" },
	Blizzard_InspectUI			= {
		"InspectFrame" },
	Blizzard_ItemAlterationUI 	= {
		"TransmogrifyFrame" },
	Blizzard_LookingForGuildUI 	= {
		"LookingForGuildFrame" },
	Blizzard_MacroUI 			= {
		"MacroFrame" },
	Blizzard_QuestChoice 		= {
		"QuestChoiceFrame" },
	Blizzard_TalentUI 			= {
		"PlayerTalentFrame" },
	Blizzard_TradeSkillUI		= {
		"TradeSkillFrame" },
	Blizzard_TrainerUI 			= {
		"ClassTrainerFrame" },
	Blizzard_VoidStorageUI		= {
		"VoidStorageFrame" },
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
		"DressUpFrame",
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

local function AddFrame(controlFrame, prepFunction, attribute, priority)
	local UIControl = { 
		frame = controlFrame,
		func = prepFunction,
		attr = attribute,
		isPrepared = false,
		isFaded = false
	}
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
	-- ConsolePortUIHandler:SetFrameRef("NewFrame", controlFrame)
	-- ConsolePortUIHandler:Execute([[
	-- 	local frame = self:GetFrameRef("NewFrame")
	-- 	FrameStack[frame] = true
	-- ]])
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
						UIControl.frame:SetAlpha(0.75)
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

function ConsolePort:GetFocusFrame()
	return focusFrame
end

function ConsolePort:GetFocusAttribute()
	return focusAttr
end

function ConsolePort:ADDON_LOADED(...)
	local name = ...
	if name == addOn then
		self.AddFrame = AddUIControlFrame
		self:CreateButtonHandler()
		self:LoadStrings()
		self:OnVariablesLoaded()
		self:LoadEvents()
		self:UpdateExtraButton()
		self:LoadHookScripts()
		self:LoadBindingSet()
		self:GetIndicatorSet()
		self:CreateConfigPanel()
		self:CreateBindingButtons()
		self:ReloadBindingActions()
	--	self:CreateUIHandler()
		AddPopupFrames(self)
	end
	if addOns[name] then
		for i, frame in pairs(addOns[name]) do
			AddUIControlFrame(self, _G[frame])
		end
	end
end

-- local hasPriority = {
-- 	ContainerFrame1Item16,
-- 	GossipTitleButton1,
-- 	HonorFrameSoloQueueButton,
-- 	LFDQueueFrameFindGroupButton,
-- 	MerchantItem1ItemButton,
-- 	MerchantRepairAllButton,
-- 	PaperDollSidebarTab3,
-- 	QuestFrameAcceptButton,
-- 	QuestFrameCompleteButton,
-- 	QuestFrameCompleteQuestButton,
-- 	QuestTitleButton1,
-- 	QuestMapFrame.DetailsFrame.BackButton,
-- 	QuestScrollFrame.ViewAll,
-- }

-- local ignoreNode = {
-- 	LootFrameCloseButton,
-- 	WorldMapTitleButton,
-- 	WorldMapButton,
-- }

-- function ConsolePort:CreateUIHandler()
-- 	if not ConsolePortUIHandler then
-- 		local UIHandler = CreateFrame("Frame", addOn.."UIHandler", ConsolePort, "SecureHandlerBaseTemplate")
-- 		UIHandler:Execute([[
-- 			Key = newtable()
-- 			SecureButtons = newtable()
--  			FrameStack = newtable()
--  			Nodes = newtable()
--  			Ignore = newtable()
--  			Prioritize = newtable()
 			
-- 		]])
-- 		for i, node in pairs(hasPriority) do
-- 			UIHandler:SetFrameRef("PriorityNode", node)
-- 			UIHandler:Execute([[
-- 				Prioritize[self:GetFrameRef("PriorityNode")] = true
-- 			]])
-- 		end
-- 		for i, node in pairs(ignoreNode) do
-- 			UIHandler:SetFrameRef("ignoreNode", node)
-- 			UIHandler:Execute([[
-- 				Ignore[self:GetFrameRef("ignoreNode")] = true
-- 			]])
-- 		end
-- 		UIHandler:Execute([[
-- 			IsUsable = newtable()
-- 			IsUsable.Button = true
-- 			IsUsable.CheckButton = true
-- 			IsUsable.EditBox = true
-- 			IsUsable.Slider = true
-- 			IsUsable.Frame = false
-- 		]])	
-- 		UIHandler:Execute([[
-- 			IsClickable = newtable()
-- 			IsClickable.Button = true
-- 			IsClickable.CheckButton = true
-- 			IsClickable.EditBox = false
-- 			IsClickable.Slider = false
-- 			IsClickable.Frame = false
-- 		]])
-- 		UIHandler:Execute([[
-- 			GetNodes = [=[
-- 				local node = CurrentNode
-- 				if Ignore[node] then
-- 					return
-- 				end
-- 				local children = newtable(node:GetChildren())
-- 				local object = node:GetObjectType()
-- 				if object ~= "Slider" then
-- 					for i, child in pairs(children) do
-- 						CurrentNode = child
-- 						self:Run(GetNodes)
-- 					end
-- 				end
-- 				local isValid = false
-- 				if node:IsMouseEnabled() and node:IsVisible() and IsUsable[object] then
-- 					isValid = true
-- 				end
-- 				if isValid then
-- 					local left, bottom, width, height = node:GetRect()
-- 					if left and bottom then
-- 						local x, y = left+width/2, bottom+height/2
-- 						local validNode = newtable()
-- 						validNode.node = node
-- 						validNode.object = object
-- 						validNode.X = x
-- 						validNode.Y = y
-- 						if Prioritize[node] then
-- 							tinsert(Nodes, 1, validNode)
-- 						else
-- 							tinsert(Nodes, validNode)
-- 						end
-- 					end
-- 				end
-- 			]=]
-- 		]])
-- 		UIHandler:Execute([[
-- 			SetCurrent = [=[
-- 				if old and old.node:IsVisible() then
-- 					current = old
-- 				elseif (not current and Nodes[1]) or (current and Nodes[1] and not current.node:IsVisible()) then
-- 					current = Nodes[1]
-- 				end
-- 			]=]
-- 		]])
-- 		UIHandler:Execute([[
-- 			FindClosestNode = [=[
-- 				if current then
-- 					local thisY = current.Y
-- 					local thisX = current.X
-- 					local nodeY = 10000
-- 					local nodeX = 10000
-- 					local swap 	= false
-- 					for i, destination in ipairs(Nodes) do
-- 						local destY = destination.Y
-- 						local destX = destination.X
-- 						local diffY = abs(thisY-destY)
-- 						local diffX = abs(thisX-destX)
-- 						local total = diffX + diffY
-- 						if total < nodeX + nodeY then
-- 							if 	key == Key.Up then
-- 								if 	diffY > diffX and 	-- up/down
-- 									destY > thisY then 	-- up
-- 									swap = true
-- 								end
-- 							elseif key == Key.Down then
-- 								if 	diffY > diffX and 	-- up/down
-- 									destY < thisY then 	-- down
-- 									swap = true
-- 								end
-- 							elseif key == Key.Left then
-- 								if 	diffY < diffX and 	-- left/right
-- 									destX < thisX then 	-- left
-- 									swap = true
-- 								end
-- 							elseif key == Key.Right then
-- 								if 	diffY < diffX and 	-- left/right
-- 									destX > thisX then 	-- right
-- 									swap = true
-- 								end
-- 							end
-- 						end
-- 						if swap then
-- 							nodeX = diffX
-- 							nodeY = diffY
-- 							current = destination
-- 							swap = false
-- 						end
-- 					end
-- 				end
-- 			]=]
-- 		]])
-- 		UIHandler:Execute([[
-- 			UpdateUI = [=[
-- 				local name = ...
-- 				local button = self:GetFrameRef(name)
-- 				key = button:GetAttribute("UI")
-- 				if current then
-- 					old = current
-- 				end
-- 				Nodes = newtable()
-- 				for Frame in pairs(FrameStack) do
-- 					if Frame:IsVisible() then
-- 						CurrentNode = Frame
-- 						self:Run(GetNodes)
-- 					end
-- 				end
-- 				self:Run(SetCurrent)

-- 				self:Run(FindClosestNode)
-- 				if current then 
-- 					print(current.node:GetName())
-- 				end
-- 			]=]
-- 		]])
-- 		UIHandler:SetAttribute("_onupdate", [[
-- 			print("update")
-- 		]])
-- 		UIHandler:SetFrameRef("UIParent", UIParent)
-- 		for btn in pairs(db.SECURE) do  
-- 			btn:SetFrameRef("UIHandler", UIHandler)
--     		btn:SetAttribute("UI", btn.command)
--     		btn:SetAttribute("name", _G["BINDING_NAME_"..btn.name])
-- 			UIHandler:WrapScript(btn, "OnClick", [[
-- 				self:GetFrameRef("UIHandler"):Run(UpdateUI, self:GetName())
-- 			]])
-- 			UIHandler:SetFrameRef(btn:GetName(), btn)
-- 			UIHandler:SetFrameRef("NewButton", btn)
-- 			UIHandler:Execute([[
-- 				local button = self:GetFrameRef("NewButton")
--         		SecureButtons[button:GetName()] = button
--         		Key[button:GetAttribute("name")] = button:GetAttribute("UI")
--     		]])
-- 		end
-- 	end
-- end