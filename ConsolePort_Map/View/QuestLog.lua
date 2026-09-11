local env, db, _, L = CPAPI.GetEnv(...);
---------------------------------------------------------------
-- Quest log panel
---------------------------------------------------------------
-- A paged list of the quest log next to the map, driven by the D-pad
-- while it has focus. Selecting a quest supertracks it and pans the
-- map to it; the details area shows objectives, text and rewards.
local Panel = CreateFromMixins(CPIndexPoolMixin); env.QuestLogPanelMixin = Panel;

local ROW_HEIGHT, ROWS_PER_PAGE = 22, 15;
local REWARD_SIZE, REWARD_GAP = 36, 6;

---------------------------------------------------------------
-- Rows
---------------------------------------------------------------
local Row = {};

function Row:SetEntry(entry, selected)
	self.entry = entry;
	if entry.isHeader then
		self.Text:SetText(entry.title)
		self.Text:SetFontObject(GameFontNormalSmall)
		self.Icon:SetTexture(entry.isCollapsed
			and [[Interface\Buttons\UI-PlusButton-Up]]
			or  [[Interface\Buttons\UI-MinusButton-Up]])
		self.Icon:Show()
		self.Tag:SetText(entry.quests > 0 and entry.quests or '')
	else
		self.Text:SetText(entry.title)
		self.Text:SetFontObject(entry.isComplete and GameFontGreenSmall or GameFontHighlightSmall)
		if entry.isSuperTracked or entry.isWatched then
			self.Icon:SetTexture([[Interface\WorldMap\WorldMapPartyIcon]])
			self.Icon:SetDesaturated(not entry.isSuperTracked)
			self.Icon:Show()
		else
			self.Icon:Hide()
		end
		self.Tag:SetText(entry.level and entry.level > 0 and entry.level or '')
	end
	self.Selected:SetShown(selected)
end

---------------------------------------------------------------
-- Panel
---------------------------------------------------------------
function Panel:OnLoad()
	CPIndexPoolMixin.OnLoad(self)
	self:CreateFramePool('Button', 'CPMapQuestRowTemplate', Row, nil, self.List)
	self.rewardPool = CreateFramePool('Button', self.Details.Rewards, 'CPMapRewardTemplate')
	self.offset, self.selection = 0, 1;
	self.collapsed = {};
	env:RegisterCallback('OnQuestLogChanged', self.Refresh, self)
	env:RegisterCallback('OnQuestDataLoaded', self.OnQuestDataLoaded, self)
	env:RegisterCallback('OnQuestSelected', self.SelectQuest, self)
end

function Panel:GetVisibleEntries()
	local visible, hidden = {}, false;
	for _, entry in ipairs(env.QuestLog:GetEntries()) do
		if entry.isHeader then
			hidden = self.collapsed[entry.title];
			entry.isCollapsed = hidden;
			visible[#visible + 1] = entry;
		elseif not hidden then
			visible[#visible + 1] = entry;
		end
	end
	return visible;
end

function Panel:Refresh()
	if not self:IsShown() then return end
	local entries = self:GetVisibleEntries()
	self.visible = entries;
	self.selection = Clamp(self.selection, 1, math.max(#entries, 1))
	if self.selection < self.offset + 1 then
		self.offset = self.selection - 1;
	elseif self.selection > self.offset + ROWS_PER_PAGE then
		self.offset = self.selection - ROWS_PER_PAGE;
	end
	self.offset = Clamp(self.offset, 0, math.max(#entries - ROWS_PER_PAGE, 0))

	self:ReleaseAll()
	for i = 1, math.min(ROWS_PER_PAGE, #entries - self.offset) do
		local entry = entries[self.offset + i];
		local row = self:Acquire(i)
		row:SetPoint('TOPLEFT', self.List, 'TOPLEFT', 0, -(i - 1) * ROW_HEIGHT)
		row:SetPoint('TOPRIGHT', self.List, 'TOPRIGHT', 0, -(i - 1) * ROW_HEIGHT)
		row:SetEntry(entry, self.hasFocus and (self.offset + i) == self.selection)
		row:Show()
	end

	if C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetMaxNumQuestsCanAccept then
		local _, numQuests = C_QuestLog.GetNumQuestLogEntries()
		self.Count:SetText(('%d / %d'):format(numQuests or 0, C_QuestLog.GetMaxNumQuestsCanAccept()))
	else
		self.Count:SetText('')
	end
	self:RefreshDetails()
end

function Panel:GetSelectedEntry()
	return self.visible and self.visible[self.selection];
end

---------------------------------------------------------------
-- Details
---------------------------------------------------------------
function Panel:RefreshDetails()
	self.refreshingDetails = true;
	local ok, err = pcall(self.RefreshDetailsInternal, self)
	self.refreshingDetails = nil;
	if not ok then error(err) end
end

function Panel:RefreshDetailsInternal()
	local entry = self:GetSelectedEntry()
	local details = self.Details;
	self.rewardPool:ReleaseAll()
	if not entry or entry.isHeader then
		details.Title:SetText(entry and entry.title or '')
		details.Objectives:SetText('')
		details.Description:SetText('')
		details.Money:SetText('')
		details.RewardsLabel:Hide()
		return
	end

	local questID, index = entry.questID, entry.questLogIndex;
	details.Title:SetText(entry.title)

	local lines = {};
	if entry.isComplete then
		lines[#lines + 1] = GREEN_FONT_COLOR:WrapTextInColorCode(env.QuestLog:GetCompletionText(index) or QUEST_WATCH_QUEST_READY or COMPLETE)
	else
		for _, objective in ipairs(env.QuestLog:GetObjectives(questID, index)) do
			if objective.text then
				local color = objective.finished and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
				lines[#lines + 1] = color:WrapTextInColorCode(QUEST_DASH..objective.text)
			end
		end
	end
	details.Objectives:SetText(table.concat(lines, '\n'))

	local description = env.QuestLog:GetText(index)
	details.Description:SetText(description)

	local rewards = env.QuestLog:GetRewards(questID)
	details.RewardsLabel:SetShown(rewards ~= nil)
	details.Money:SetText(rewards and rewards.money and rewards.money > 0 and GetMoneyString(rewards.money) or '')
	if not rewards or rewards.pending then return end

	local x = 0;
	local function AddReward(reward, isChoice)
		local button = self.rewardPool:Acquire()
		button:SetPoint('BOTTOMLEFT', details.Rewards, 'BOTTOMLEFT', x, 0)
		button.Icon:SetTexture(reward.texture)
		button.Count:SetText(reward.count and reward.count > 1 and reward.count or '')
		button.Border:SetVertexColor(isChoice and 1 or 0.7, isChoice and 0.82 or 0.7, isChoice and 0 or 0.7)
		button.itemID = reward.itemID;
		button:Show()
		x = x + REWARD_SIZE + REWARD_GAP;
	end
	for _, reward in ipairs(rewards.choices) do AddReward(reward, true) end
	for _, reward in ipairs(rewards.items) do AddReward(reward, false) end
end

function Panel:OnQuestDataLoaded(questID)
	local entry = self:GetSelectedEntry()
	if entry and entry.questID == questID and not self.refreshingDetails then
		self:RefreshDetails()
	end
end

---------------------------------------------------------------
-- Navigation
---------------------------------------------------------------
function Panel:SetFocus(hasFocus)
	self.hasFocus = hasFocus;
	self:Refresh()
	self:UpdateHints()
end

function Panel:Move(delta)
	if not self.visible or #self.visible == 0 then return end
	self.selection = Clamp(self.selection + delta, 1, #self.visible)
	self:Refresh()
	self:UpdateHints()
end

function Panel:Accept()
	local entry = self:GetSelectedEntry()
	if not entry then return end
	if entry.isHeader then
		self.collapsed[entry.title] = not self.collapsed[entry.title];
		return self:Refresh()
	end
	env.QuestLog:SetSuperTracked(entry.questID)
	self:ShowQuestOnMap(entry.questID)
end

function Panel:Track()
	local entry = self:GetSelectedEntry()
	if entry and not entry.isHeader then
		env.QuestLog:ToggleWatch(entry.questID)
	end
end

function Panel:Abandon()
	local entry = self:GetSelectedEntry()
	if entry and not entry.isHeader and env.QuestLog:CanAbandon(entry.questID) then
		env.QuestLog:ConfirmAbandon(entry.questID, entry.title)
	end
end

function Panel:Share()
	local entry = self:GetSelectedEntry()
	if entry and not entry.isHeader and env.QuestLog:CanShare(entry.questID) then
		env.QuestLog:Share(entry.questID)
	end
end

function Panel:ShowQuestOnMap(questID)
	local canvas = self:GetParent():GetActiveCanvas()
	if not canvas then return end
	local mapID = env.QuestLog:GetMapForQuest(questID) or canvas:GetMapID()
	if mapID ~= canvas:GetMapID() then
		canvas:NavigateTo(mapID)
	end
	local x, y = env.QuestLog:GetPositionOnMap(questID, canvas:GetMapID())
	if x and y then
		canvas:PanToPosition(x, y)
	end
end

function Panel:SelectQuest(questID)
	if not self.visible then return end
	for i, entry in ipairs(self.visible) do
		if entry.questID == questID then
			self.selection = i;
			return self:Refresh()
		end
	end
end

---------------------------------------------------------------
-- Input sink (installed on the canvas while the panel has focus)
---------------------------------------------------------------
function Panel:HandleButton(button)
	if not self.hasFocus then return false end
	local command = self.commands[button];
	if command then
		command(self)
		return true;
	end
	return false;
end

function Panel:UpdateCommands()
	self.commands = {
		PADDUP    = function(panel) panel:Move(-1) end;
		PADDDOWN  = function(panel) panel:Move(1) end;
		PADDLEFT  = function(panel) panel:Move(-ROWS_PER_PAGE) end;
		PADDRIGHT = function(panel) panel:Move(ROWS_PER_PAGE) end;
		[db('mapAcceptButton')] = Panel.Accept;
		[db('mapTrackButton')]  = Panel.Track;
		[db('mapWaypointButton')] = Panel.Share;
		[db('mapResetButton')]  = Panel.Abandon;
	};
end

function Panel:UpdateHints()
	local UIHandle = db.UIHandle;
	if not self.hasFocus or not UIHandle:IsHintFocus(self:GetParent()) then return end
	local entry = self:GetSelectedEntry()
	local isQuest = entry and not entry.isHeader;
	UIHandle:AddHint(db('mapAcceptButton'), isQuest and L'Show on Map' or (entry and (entry.isCollapsed and L'Expand' or L'Collapse')) or '')
	UIHandle:AddHint(db('mapCancelButton'), L'Back to Map')
	if isQuest then
		UIHandle:AddHint(db('mapTrackButton'), entry.isWatched and L'Untrack' or L'Track')
		if env.QuestLog:CanShare(entry.questID) then
			UIHandle:AddHint(db('mapWaypointButton'), SHARE_QUEST or L'Share')
		else
			UIHandle:RemoveHint(db('mapWaypointButton'))
		end
		UIHandle:AddHint(db('mapResetButton'), ABANDON_QUEST or L'Abandon')
	else
		UIHandle:RemoveHint(db('mapTrackButton'))
		UIHandle:RemoveHint(db('mapWaypointButton'))
		UIHandle:RemoveHint(db('mapResetButton'))
	end
end

function Panel:OnShow()
	self:UpdateCommands()
	self:Refresh()
end
