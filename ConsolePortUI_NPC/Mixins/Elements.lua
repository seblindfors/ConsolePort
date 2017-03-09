local TEMPLATE, Elements, _, L = {}, {}, ...
L.ElementsMixin = Elements

local TEXT_COLOR, TITLE_COLOR = GetMaterialTextColors('Stone') -- default text colors
local REWARDS_OFFSET = 10 -- vertical distance between sections
local ITEMS_PER_ROW = 2 -- modulus value for item rows
local ACTIVE_TEMPLATE

local SEAL_QUESTS = { -- Legion seal quests
	[40519] = {text = '|cff04aaff'..QUEST_KING_VARIAN_WRYNN..'|r', sealAtlas = 'Quest-Alliance-WaxSeal'},
	[43926] = {text = '|cff480404'..QUEST_WARCHIEF_VOLJIN..'|r', sealAtlas = 'Quest-Horde-WaxSeal'},
}

----------------------------------
-- Helper functions
----------------------------------
local function AddSpellToBucket(spellBuckets, type, rewardSpellIndex)
	if not spellBuckets[type] then
		spellBuckets[type] = {}
	end
	local spellBucket = spellBuckets[type]
	spellBucket[#spellBucket + 1] = rewardSpellIndex
end

local function GetItemButton(parentFrame, index, buttonType)
	local rewardButtons = parentFrame.Buttons
	if ( not rewardButtons[index] ) then
		local button = CreateFrame('BUTTON', _..(buttonType or 'QuestInfoItem')..index, parentFrame, parentFrame.buttonTemplate)
		rewardButtons[index] = button
		button.container = parentFrame:GetParent():GetParent()
		button.highlight = parentFrame.ItemHighlight
	end
	return rewardButtons[index]
end

local function UpdateItemInfo(self)
	assert(self.type)
	assert(self:GetID())
	if self.objectType == 'item' then
		local name, texture, numItems, quality, isUsable = GetQuestItemInfo(self.type, self:GetID())
		-- For the tooltip
		self.itemTexture = texture
		self.Name:SetText(name)
		SetItemButtonCount(self, numItems)
		SetItemButtonTexture(self, texture)
		if ( isUsable ) then
			SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0)
			SetItemButtonNameFrameVertexColor(self, 1.0, 1.0, 1.0)
		else
			SetItemButtonTextureVertexColor(self, 0.9, 0, 0)
			SetItemButtonNameFrameVertexColor(self, 0.9, 0, 0)
		end
		self:Show()
		return true
	elseif self.objectType == 'currency' then
		local name, texture, numItems = GetQuestCurrencyInfo(self.type, self:GetID())
		if (name and texture and numItems) then
			-- For the tooltip
			self.Name:SetText(name)
			SetItemButtonCount(self, numItems, true)
			SetItemButtonTexture(self, texture)
			SetItemButtonTextureVertexColor(self, 1.0, 1.0, 1.0)
			SetItemButtonNameFrameVertexColor(self, 1.0, 1.0, 1.0)
			return true
		else
			return self:Hide()
		end
	end
end

local function ToggleRewardElement(frame, value, anchor)
	if ( value and tonumber(value) ~= 0 ) then
		frame:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 0, -REWARDS_OFFSET)
		frame.ValueText:SetText(value)
		frame:Show()
		return true
	else
		frame:Hide()
	end
end

function Elements:UpdateBoundaries()
	self:AdjustToChildren()
	return self:AdjustToChildren()
end

----------------------------------
-- Quest elements display
----------------------------------
function Elements:Display(template, material)
	local template = TEMPLATE[template]
	if not template then
		return 0
	end

	ACTIVE_TEMPLATE = template

	self.chooseItems = template.chooseItems

	self:SetMaterial(material)
	self.Progress:Hide()

	local content = self.Content
	local elementsTable = template.elements
	local height, lastFrame = 0
	for i = 1, #elementsTable, 3 do
		local shownFrame, bottomShownFrame = elementsTable[i](self)
		if ( shownFrame ) then
			shownFrame:SetParent(content)
			height = height + shownFrame:GetHeight() + abs(elementsTable[i+2])
			if ( lastFrame ) then
				shownFrame:SetPoint('TOPLEFT', lastFrame, 'BOTTOMLEFT', elementsTable[i+1], elementsTable[i+2])
			else
				shownFrame:SetPoint('TOPLEFT', content, 'TOPLEFT', elementsTable[i+1] , elementsTable[i+2] + 10)
			end
			shownFrame:Show()
			self.Active[#self.Active + 1] = shownFrame
			lastFrame = bottomShownFrame or shownFrame
		end
	end
	return height
end

function Elements:SetMaterial(material)
	local progress = self.Progress
	local content = self.Content
	local rewards = content.RewardsFrame
	-- nil check this
	if ( self.material ~= material ) then
		self.material = material
		local textColor, titleTextColor = GetMaterialTextColors(material)
		local r, g, b 
		if not textColor or not titleTextColor then
			textColor, titleTextColor = TEXT_COLOR, TITLE_COLOR
		end
		-- Headers
		r, g, b = unpack(titleTextColor)
		content.ObjectivesHeader:SetTextColor(r, g, b)
		progress.ReqText:SetTextColor(r, g, b)
		rewards.Header:SetTextColor(r, g, b)
		-- Other text
		r, g, b = unpack(textColor)
		content.ObjectivesText:SetTextColor(r, g, b)
		content.GroupSize:SetTextColor(r, g, b)
		content.RewardText:SetTextColor(r, g, b)
		-- Progress text
		progress.MoneyText:SetTextColor(r, g, b)
		-- Reward frame text
		rewards.ItemChooseText:SetTextColor(r, g, b)
		rewards.ItemReceiveText:SetTextColor(r, g, b)
		rewards.PlayerTitleText:SetTextColor(r, g, b)
		rewards.XPFrame.ReceiveText:SetTextColor(r, g, b)

		local spellHeaderPool = rewards.spellHeaderPool
		spellHeaderPool.textR, spellHeaderPool.textG, spellHeaderPool.textB = r, g, b
	end
end

function Elements:ShowSpecialObjectives()
	-- Show objective spell
	local spellID, spellName, spellTexture = GetCriteriaSpell()
	local specialFrame = self.Content.SpecialObjectivesFrame
	local spellObjectiveLabel = specialFrame.SpellObjectiveLearnLabel
	local spellObjective = specialFrame.SpellObjectiveFrame


	local lastFrame = nil
	local totalHeight = 0

	if (spellID) then
		spellObjective.Icon:SetTexture(spellTexture)
		spellObjective.Name:SetText(spellName)
		spellObjective.spellID = spellID

		spellObjective:ClearAllPoints()
		if (lastFrame) then
			spellObjectiveLabel:SetPoint('TOPLEFT', lastFrame, 'BOTTOMLEFT', 0, -4)
			totalHeight = totalHeight + 4
		else
			spellObjectiveLabel:SetPoint('TOPLEFT', 0, 0)
		end

		spellObjective:SetPoint('TOPLEFT', spellObjectiveLabel, 'BOTTOMLEFT', 0, -4)

		spellObjectiveLabel:SetText(LEARN_SPELL_OBJECTIVE)
		spellObjectiveLabel:SetTextColor(0, 0, 0)

		spellObjectiveLabel:Show()
		spellObjective:Show()
		totalHeight = totalHeight + spellObjective:GetHeight() + spellObjectiveLabel:GetHeight()
		lastFrame = spellObjective
	else
		spellObjective:Hide()
		spellObjectiveLabel:Hide()
	end

	if (lastFrame) then
		specialFrame:SetHeight(totalHeight)
		specialFrame:Show()
		return specialFrame
	else
		return specialFrame:Hide()
	end
end

function Elements:ShowSpacer() return self.Content.SpacerFrame end
function Elements:ShowObjectivesHeader() return self.Content.ObjectivesHeader end

function Elements:ShowObjectivesText()
	local questObjectives = GetObjectiveText()
	local objectivesText = self.Content.ObjectivesText
	objectivesText:SetText(questObjectives)
	objectivesText:SetWidth(ACTIVE_TEMPLATE.contentWidth)
	return objectivesText
end

function Elements:ShowGroupSize()
	local groupNum = GetSuggestedGroupNum()
	local groupSize = self.Content.GroupSize
	if ( groupNum > 0 ) then
		groupSize:SetText(QUEST_SUGGESTED_GROUP_NUM:format(groupNum))
		groupSize:Show()
		return groupSize
	else
		return groupSize:Hide()
	end
end

function Elements:ShowSeal()
	local frame = self.Content.SealFrame
	if ACTIVE_TEMPLATE and ACTIVE_TEMPLATE.canHaveSealMaterial then
		local sealInfo = SEAL_QUESTS[GetQuestID()]
		if sealInfo then
			frame.Text:SetText(sealInfo.text)
			frame.Texture:SetAtlas(sealInfo.sealAtlas, true) 
			frame.Texture:SetPoint('TOPLEFT', ACTIVE_TEMPLATE.sealXOffset, ACTIVE_TEMPLATE.sealYOffset)
			frame:Show()
			return frame
		end
	end
	return frame:Hide()
end

----------------------------------
-- Quest reward handling
----------------------------------
function Elements:ShowRewards()
	local elements = self
	local self = self.Content.RewardsFrame
	local rewardButtons = self.Buttons
	local 	numQuestRewards, numQuestChoices, numQuestCurrencies,
			money,
			skillName, skillPoints, skillIcon,
			xp, artifactXP, artifactCategory, honor,
			playerTitle,
			numSpellRewards
			
	local numQuestSpellRewards = 0
	local totalHeight = 0
	local GetSpell = GetRewardSpell

	do  -- Get data
		numQuestRewards = GetNumQuestRewards()
		numQuestChoices = GetNumQuestChoices()
		numQuestCurrencies = GetNumRewardCurrencies()
		money = GetRewardMoney()
		skillName, skillIcon, skillPoints = GetRewardSkillPoints()
		xp = GetRewardXP()
		artifactXP, artifactCategory = GetRewardArtifactXP()
		honor = GetRewardHonor()
		playerTitle = GetRewardTitle()
		numSpellRewards = GetNumRewardSpells()
	end

	do -- Spell rewards
		for rewardSpellIndex = 1, numSpellRewards do
			local texture, name, isTradeskillSpell, isSpellLearned, hideSpellLearnText, isBoostSpell, garrFollowerID, spellID = GetSpell(rewardSpellIndex)
			local knownSpell = IsSpellKnownOrOverridesKnown(spellID)

			-- only allow the spell reward if user can learn it
			if ( texture and not knownSpell and (not isBoostSpell or IsCharacterNewlyBoosted()) and (not garrFollowerID or not C_Garrison.IsFollowerCollected(garrFollowerID)) ) then
				numQuestSpellRewards = numQuestSpellRewards + 1
			end
		end
	end

	local totalRewards = numQuestRewards + numQuestChoices + numQuestCurrencies

	do -- Check if any rewards are present, break out if none
		if ( totalRewards == 0 and 
			money == 0 and 
			xp == 0 and 
			not playerTitle and 
			numQuestSpellRewards == 0 and 
			artifactXP == 0 ) then

			return self:Hide()
		end
	end

	do -- Hide unused rewards
		for i = totalRewards + 1, #rewardButtons do
			rewardButtons[i]:ClearAllPoints()
			rewardButtons[i]:Hide()
		end
	end

	-- Setup locals 
	local questItem, name, texture, quality, isUsable, numItems
	local rewardsCount = 0
	local lastFrame = self.Header

	local totalHeight = self.Header:GetHeight()
	local buttonHeight = self.Buttons[1]:GetHeight()

	do -- Artifact experience
		self.ArtifactXPFrame:ClearAllPoints()
		if ( artifactXP > 0 ) then
			local name, icon = C_ArtifactUI.GetArtifactXPRewardTargetInfo(artifactCategory)
			self.ArtifactXPFrame:SetPoint('TOPLEFT', lastFrame, 'BOTTOMLEFT', 0, -REWARDS_OFFSET)
			self.ArtifactXPFrame.Name:SetText(BreakUpLargeNumbers(artifactXP))
			self.ArtifactXPFrame.Icon:SetTexture(icon or 'Interface\\Icons\\INV_Misc_QuestionMark')
			self.ArtifactXPFrame:Show()

			lastFrame = self.ArtifactXPFrame
			totalHeight = totalHeight + self.ArtifactXPFrame:GetHeight() + REWARDS_OFFSET
		else
			self.ArtifactXPFrame:Hide()
		end
	end

	do -- Setup choosable rewards
		self.ItemChooseText:ClearAllPoints()
		if ( numQuestChoices > 0 ) then
			self.ItemChooseText:Show()
			self.ItemChooseText:SetPoint('TOPLEFT', lastFrame, 'BOTTOMLEFT', 0, -5)

			local index
			local baseIndex = rewardsCount
			for i = 1, numQuestChoices do
				index = i + baseIndex
				questItem = GetItemButton(self, index)
				questItem.type = 'choice'
				questItem.objectType = 'item'
				numItems = 1
				questItem:SetID(i)
				questItem:Show()

				UpdateItemInfo(questItem)

				if ( i > 1 ) then
					if ( mod(i, ITEMS_PER_ROW) == 1 ) then
						questItem:SetPoint('TOPLEFT', rewardButtons[index - 2], 'BOTTOMLEFT', 0, -2)
						lastFrame = questItem
						totalHeight = totalHeight + buttonHeight + 2
					else
						questItem:SetPoint('TOPLEFT', rewardButtons[index - 1], 'TOPRIGHT', 1, 0)
					end
				else
					questItem:SetPoint('TOPLEFT', self.ItemChooseText, 'BOTTOMLEFT', 0, -REWARDS_OFFSET)
					lastFrame = questItem
					totalHeight = totalHeight + buttonHeight + REWARDS_OFFSET
				end
				rewardsCount = rewardsCount + 1
			end
			if ( numQuestChoices == 1 ) then
				elements.chooseItems = nil
				self.ItemChooseText:SetText(REWARD_ITEMS_ONLY)
			elseif ( elements.chooseItems ) then
				self.ItemChooseText:SetText(REWARD_CHOOSE)
			else
				self.ItemChooseText:SetText(REWARD_CHOICES)
			end
			totalHeight = totalHeight + self.ItemChooseText:GetHeight() + REWARDS_OFFSET
		else
			elements.chooseItems = nil
			self.ItemChooseText:Hide()
		end
	end

	do -- Wipe reward pools
		self.spellRewardPool:ReleaseAll()
		self.followerRewardPool:ReleaseAll()
		self.spellHeaderPool:ReleaseAll()
	end

	do -- Setup spell rewards
		if ( numQuestSpellRewards > 0 ) then
			local spellBuckets = {}

			-- Generate spell buckets
			for rewardSpellIndex = 1, numSpellRewards do
				local texture, name, isTradeskillSpell, isSpellLearned, hideSpellLearnText, isBoostSpell, garrFollowerID, spellID = GetSpell(rewardSpellIndex)
				local knownSpell = IsSpellKnownOrOverridesKnown(spellID)
				if texture and not knownSpell and (not isBoostSpell or IsCharacterNewlyBoosted()) and (not garrFollowerID or not C_Garrison.IsFollowerCollected(garrFollowerID)) then
					if ( isTradeskillSpell ) then
						AddSpellToBucket(spellBuckets, QUEST_SPELL_REWARD_TYPE_TRADESKILL_SPELL, rewardSpellIndex)
					elseif ( isBoostSpell ) then
						AddSpellToBucket(spellBuckets, QUEST_SPELL_REWARD_TYPE_ABILITY, rewardSpellIndex)
					elseif ( garrFollowerID ) then
						AddSpellToBucket(spellBuckets, QUEST_SPELL_REWARD_TYPE_FOLLOWER, rewardSpellIndex)
					elseif ( not isSpellLearned ) then
						AddSpellToBucket(spellBuckets, QUEST_SPELL_REWARD_TYPE_AURA, rewardSpellIndex)
					else
						AddSpellToBucket(spellBuckets, QUEST_SPELL_REWARD_TYPE_SPELL, rewardSpellIndex)
					end
				end
			end

			-- Sort buckets in the correct order
			for orderIndex, spellBucketType in ipairs(QUEST_INFO_SPELL_REWARD_ORDERING) do
				local spellBucket = spellBuckets[spellBucketType]
				if spellBucket then
					for i, rewardSpellIndex in ipairs(spellBucket) do
						local texture, name, isTradeskillSpell, isSpellLearned, _, isBoostSpell, garrFollowerID = GetSpell(rewardSpellIndex)
						if i == 1 then
							local header = self.spellHeaderPool:Acquire()
							header:SetText(QUEST_INFO_SPELL_REWARD_TO_HEADER[spellBucketType])
							header:SetPoint('TOPLEFT', lastFrame, 'BOTTOMLEFT', 0, -REWARDS_OFFSET)
							if self.spellHeaderPool.textR and self.spellHeaderPool.textG and self.spellHeaderPool.textB then
								header:SetVertexColor(self.spellHeaderPool.textR, self.spellHeaderPool.textG, self.spellHeaderPool.textB)
							end
							header:Show()

							totalHeight = totalHeight + header:GetHeight() + REWARDS_OFFSET
							lastFrame = header
						end

						local anchorFrame
						if garrFollowerID then
							local followerFrame = self.followerRewardPool:Acquire()
							local followerInfo = C_Garrison.GetFollowerInfo(garrFollowerID)
							followerFrame.Name:SetText(followerInfo.name)
							followerFrame.Class:SetAtlas(followerInfo.classAtlas)
							followerFrame.PortraitFrame:SetupPortrait(followerInfo)
							followerFrame.ID = garrFollowerID
							followerFrame:Show()

							anchorFrame = followerFrame
						else
							local spellRewardFrame = self.spellRewardPool:Acquire()
							spellRewardFrame.Icon:SetTexture(texture)
							spellRewardFrame.Name:SetText(name)
							spellRewardFrame.rewardSpellIndex = rewardSpellIndex
							spellRewardFrame:Show()

							anchorFrame = spellRewardFrame
						end
						if i % 2 ==  1 then
							anchorFrame:SetPoint('TOPLEFT', lastFrame, 'BOTTOMLEFT', 0, -REWARDS_OFFSET)
							totalHeight = totalHeight + anchorFrame:GetHeight() + REWARDS_OFFSET

							lastFrame = anchorFrame
						else
							anchorFrame:SetPoint('LEFT', lastFrame, 'RIGHT', 1, 0)
						end
					end
				end
			end
		end
	end

	do -- Title reward
		if ( playerTitle ) then
			self.PlayerTitleText:Show()
			self.PlayerTitleText:SetPoint('TOPLEFT', lastFrame, 'BOTTOMLEFT', 0, -REWARDS_OFFSET)
			totalHeight = totalHeight +  self.PlayerTitleText:GetHeight() + REWARDS_OFFSET
			self.TitleFrame:SetPoint('TOPLEFT', self.PlayerTitleText, 'BOTTOMLEFT', 0, -REWARDS_OFFSET)
			self.TitleFrame.Name:SetText(playerTitle)
			self.TitleFrame:Show()
			lastFrame = self.TitleFrame
			totalHeight = totalHeight +  self.TitleFrame:GetHeight() + REWARDS_OFFSET
		else
			self.PlayerTitleText:Hide()
			self.TitleFrame:Hide()
		end
	end

	do -- Setup mandatory rewards
		if ( numQuestRewards > 0 or numQuestCurrencies > 0 or money > 0 or xp > 0 ) then
			-- receive text, will either say 'You will receive' or 'You will also receive'
			local questItemReceiveText = self.ItemReceiveText
			if ( numQuestChoices > 0 or numQuestSpellRewards > 0 or playerTitle ) then
				questItemReceiveText:SetText(REWARD_ITEMS)
			else
				questItemReceiveText:SetText(REWARD_ITEMS_ONLY)
			end
			questItemReceiveText:SetPoint('TOPLEFT', lastFrame, 'BOTTOMLEFT', 0, -REWARDS_OFFSET)
			questItemReceiveText:Show()
			totalHeight = totalHeight + questItemReceiveText:GetHeight() + REWARDS_OFFSET
			lastFrame = questItemReceiveText

			do -- Money rewards
				if ( money > 0 ) then
					MoneyFrame_Update(self.MoneyFrame, money)
					self.MoneyFrame:Show()
				else
					self.MoneyFrame:Hide()
				end
			end

			do -- XP rewards
				if ( ToggleRewardElement(self.XPFrame, BreakUpLargeNumbers(xp), lastFrame) ) then
					lastFrame = self.XPFrame
					totalHeight = totalHeight + self.XPFrame:GetHeight() + REWARDS_OFFSET
				end
			end

			do -- Skill Point rewards
				if ( ToggleRewardElement(self.SkillPointFrame, skillPoints, lastFrame) ) then
					lastFrame = self.SkillPointFrame
					self.SkillPointFrame.Icon:SetTexture(skillIcon)
					if (skillName) then
						self.SkillPointFrame.Name:SetFormattedText(BONUS_SKILLPOINTS, skillName)
						self.SkillPointFrame.tooltip = format(BONUS_SKILLPOINTS_TOOLTIP, skillPoints, skillName)
					else
						self.SkillPointFrame.tooltip = nil
						self.SkillPointFrame.Name:SetText('')
					end
					totalHeight = totalHeight + buttonHeight + REWARDS_OFFSET
				end
			end

			local index
			local baseIndex = rewardsCount
			local buttonIndex = 0

			do -- Item rewards
				for i = 1, numQuestRewards, 1 do
					buttonIndex = buttonIndex + 1
					index = i + baseIndex
					questItem = GetItemButton(self, index)
					questItem.type = 'reward'
					questItem.objectType = 'item'
					questItem:SetID(i)
					questItem:Show()

					UpdateItemInfo(questItem)

					if ( buttonIndex > 1 ) then
						if ( mod(buttonIndex, ITEMS_PER_ROW) == 1 ) then
							questItem:SetPoint('TOPLEFT', rewardButtons[index - 2], 'BOTTOMLEFT', 0, -2)
							lastFrame = questItem
							totalHeight = totalHeight + buttonHeight + 2
						else
							questItem:SetPoint('TOPLEFT', rewardButtons[index - 1], 'TOPRIGHT', 1, 0)
						end
					else
						questItem:SetPoint('TOPLEFT', lastFrame, 'BOTTOMLEFT', 0, -REWARDS_OFFSET)
						lastFrame = questItem
						totalHeight = totalHeight + buttonHeight + REWARDS_OFFSET
					end
					rewardsCount = rewardsCount + 1
				end
			end
			
			do -- Currency
				baseIndex = rewardsCount
				local foundCurrencies = 0
				buttonIndex = buttonIndex + 1
				for i = 1, GetMaxRewardCurrencies(), 1 do
					index = i + baseIndex
					questItem = GetItemButton(self, index)
					questItem.type = 'reward'
					questItem.objectType = 'currency'
					questItem:SetID(i)
					questItem:Show()

					if (UpdateItemInfo(questItem)) then

						if ( buttonIndex > 1 ) then
							if ( mod(buttonIndex, ITEMS_PER_ROW) == 1 ) then
								questItem:SetPoint('TOPLEFT', rewardButtons[index - 2], 'BOTTOMLEFT', 0, -2)
								lastFrame = questItem
								totalHeight = totalHeight + buttonHeight + 2
							else
								questItem:SetPoint('TOPLEFT', rewardButtons[index - 1], 'TOPRIGHT', 1, 0)
							end
						else
							questItem:SetPoint('TOPLEFT', lastFrame, 'BOTTOMLEFT', 0, -REWARDS_OFFSET)
							lastFrame = questItem
							totalHeight = totalHeight + buttonHeight + REWARDS_OFFSET
						end
						rewardsCount = rewardsCount + 1
						foundCurrencies = foundCurrencies + 1
						buttonIndex = buttonIndex + 1
						if (foundCurrencies == numQuestCurrencies) then
							break
						end
					end
				end
			end

			do -- Honor reward 
				self.HonorFrame:ClearAllPoints()
				if ( honor > 0 ) then
					local faction = UnitFactionGroup('player')
					local icon = faction and ('Interface\\Icons\\PVPCurrency-Honor-%s'):format(faction)

					self.HonorFrame:SetPoint('TOPLEFT', lastFrame, 'BOTTOMLEFT', 0, -REWARDS_OFFSET)
					self.HonorFrame.Count:SetText(BreakUpLargeNumbers(honor))
					self.HonorFrame.Name:SetText(HONOR)
					self.HonorFrame.Icon:SetTexture(icon)
					self.HonorFrame:Show()

					lastFrame = self.HonorFrame
					totalHeight = totalHeight + self.HonorFrame:GetHeight() + REWARDS_OFFSET
				else
					self.HonorFrame:Hide()
				end
			end

		else -- Hide all sub-frames
			self.ItemReceiveText:Hide()
			self.MoneyFrame:Hide()
			self.XPFrame:Hide()
			self.SkillPointFrame:Hide()
			self.HonorFrame:Hide()
		end
	end

	-- deselect item
	elements.itemChoice = 0
	if ( self.ItemHighlight ) then
		self.ItemHighlight:Hide()
	end

	self:Show()
	self:SetHeight(totalHeight)
	return self, lastFrame
end

function Elements:CompleteQuest()
	local numQuestChoices = GetNumQuestChoices()
	self.itemChoice = (numQuestChoices == 1 and 1) or self.itemChoice

	if ( self.itemChoice == 0 and numQuestChoices > 0 ) then
		QuestChooseRewardError()
	else
		GetQuestReward(self.itemChoice)
	end
end

function Elements:AcceptQuest()
	if ( QuestFlagsPVP() ) then
		StaticPopup_Show("CONFIRM_ACCEPT_PVP_QUEST")
	else
		if ( QuestGetAutoAccept() ) then
			AcknowledgeAutoAcceptQuest()
		else
			AcceptQuest()
		end
	end
	PlaySound("igQuestListOpen")
end

function Elements:ShowProgress(material)
	self:Show()
	self.Content:Hide()
	self:SetMaterial(material)
	local self = self.Progress
	local numRequiredItems = GetNumQuestItems()
	local numRequiredMoney = GetQuestMoneyToGet()
	local numRequiredCurrencies = GetNumQuestCurrencies()
	local buttonIndex, buttons = 1, self.Buttons
	if ( numRequiredItems > 0 or numRequiredMoney > 0 or numRequiredCurrencies > 0) then
		self:Show()
		self.ReqText:Show()

		-- If there's money required then anchor and display it
		if ( numRequiredMoney > 0 ) then
			MoneyFrame_Update(self.MoneyFrame, numRequiredMoney)
			
			local moneyColor, moneyVertex
			if ( numRequiredMoney > GetMoney() ) then
				moneyColor, moneyVertex = 'red', 0.2
			else
				moneyColor, moneyVertex = 'white', 0.75
			end

			self.MoneyText:SetTextColor(moneyVertex, moneyVertex, moneyVertex)
			SetMoneyFrameColor(self.MoneyFrame, moneyColor)

			self.MoneyText:Show()
			self.MoneyFrame:Show()

			-- Reanchor required item
			buttons[1]:SetPoint('TOPLEFT', self.MoneyText, 'BOTTOMLEFT', 0, -10)
		else
			self.MoneyText:Hide()
			self.MoneyFrame:Hide()
			-- Reanchor required item
			buttons[1]:SetPoint('TOPLEFT', self.ReqText, 'BOTTOMLEFT', -3, -5)
		end

		for i=1, numRequiredItems do	
			local hidden = IsQuestItemHidden(i)
			if ( hidden == 0 ) then
				local requiredItem = GetItemButton(self, buttonIndex, 'ProgressItem')
				requiredItem.type = "required"
				requiredItem.objectType = "item"
				requiredItem:SetID(i)
				requiredItem:Show()

				UpdateItemInfo(requiredItem)

				if ( buttonIndex > 1 ) then
					if ( mod(buttonIndex, ITEMS_PER_ROW) == 1 ) then
						requiredItem:SetPoint('TOPLEFT', buttons[buttonIndex - 2], 'BOTTOMLEFT', 0, -2)
					else
						requiredItem:SetPoint('TOPLEFT', buttons[buttonIndex - 1], 'TOPRIGHT', 1, 0)
					end
				end

				buttonIndex = buttonIndex + 1
			end
		end
		
		for i=1, numRequiredCurrencies do	
			local requiredItem = GetItemButton(self, buttonIndex, 'ProgressItem')
			requiredItem.type = "required"
			requiredItem.objectType = "currency"
			requiredItem:SetID(i)
			requiredItem:Show()

			UpdateItemInfo(requiredItem)

			if ( buttonIndex > 1 ) then
				if ( mod(buttonIndex, ITEMS_PER_ROW) == 1 ) then
					requiredItem:SetPoint('TOPLEFT', buttons[buttonIndex - 2], 'BOTTOMLEFT', 0, -2)
				else
					requiredItem:SetPoint('TOPLEFT', buttons[buttonIndex - 1], 'TOPRIGHT', 1, 0)
				end
			end

			buttonIndex = buttonIndex + 1
		end
	else
		self:Hide()
		self.MoneyText:Hide()
		self.MoneyFrame:Hide()
		self.ReqText:Hide()
	end

	for i=buttonIndex, #buttons do
		buttons[i]:Hide()
	end
	return self:IsShown()
end
----------------------------------
-- Quest templates
----------------------------------
TEMPLATE.QUEST_DETAIL = { chooseItems = nil, contentWidth = 507,
	canHaveSealMaterial = true, sealXOffset = 400, sealYOffset = -6,
	elements = {
		Elements.ShowObjectivesHeader, 0, -15,
		Elements.ShowObjectivesText, 0, -5,
		Elements.ShowSpecialObjectives, 0, -10,
		Elements.ShowGroupSize, 0, -10,
		Elements.ShowRewards, 0, -15,
		Elements.ShowSeal, 0, 0,
		Elements.ShowSpacer, 0, 0,
	}
}

TEMPLATE.QUEST_REWARD = { chooseItems = true, contentWidth = 507,
	canHaveSealMaterial = nil, sealXOffset = 300, sealYOffset = -6,
	elements = {
		Elements.ShowRewards, 0, -10,
		Elements.ShowSpacer, 0, 0,
	}
}