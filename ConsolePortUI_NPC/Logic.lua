local _, L = ...
local UI, NPC, TalkBox, Selector = ConsolePortUI, {}, {}, {}
local frame = L.frame
local KEY = ConsolePort:GetData().KEY
local Control = UI:GetControlHandle()

function NPC:OnShow()
	Control:AddHint(KEY.TRIANGLE, GOODBYE)
end

----------------------------------
-- Event handler
----------------------------------
function NPC:OnEvent(event, ...)
	self:ResetElements()
	if self[event] then
		event = self[event](self, ...) or event
	end
	self.TalkBox.lastEvent = event
	self.lastEvent = event
	self.timeStamp = GetTime()
	self:UpdateItems()
end

----------------------------------
-- Events
----------------------------------
function NPC:GOSSIP_SHOW(...)
	if self:IsGossipAvailable() then
		self:PlayIntro('GOSSIP_SHOW')
		self:UpdateTalkingHead(GetUnitName('npc'), GetGossipText(), 'GossipGossip')
	end
end

function NPC:GOSSIP_CLOSED(...)
	self:PlayOutro()
end

function NPC:QUEST_GREETING(...)
	self:PlayIntro('QUEST_GREETING')
	self:UpdateTalkingHead(GetUnitName('questnpc') or GetUnitName('npc'), GetGreetingText(), 'AvailableQuest')
end

function NPC:QUEST_PROGRESS(...) -- special case, doesn't use QuestInfo
	Control:AddHint(KEY.CROSS, CONTINUE)
	local npcType
	if IsQuestCompletable() then
		Control:SetHintEnabled(KEY.CROSS)
		npcType = 'ActiveQuest'
	else
		Control:SetHintDisabled(KEY.CROSS)
		npcType = 'IncompleteQuest'
	end
	self:PlayIntro('QUEST_PROGRESS')
	self:UpdateTalkingHead(GetTitleText(), GetProgressText(), npcType)
	local elements = self.TalkBox.Elements
	local hasItems = elements:ShowProgress('Stone')
	elements:UpdateBoundaries()
	if hasItems then
		local width, height = elements.Progress:GetSize()
		-- Extra: 32 padding + 8 offset from talkbox + 8 px bottom offset
		self.TalkBox:SetExtraOffset(height + 48) 
		return
	end
	self:ResetElements()
end

function NPC:QUEST_COMPLETE(...)
	self:PlayIntro('QUEST_COMPLETE')
	self:UpdateTalkingHead(GetTitleText(), GetRewardText(), 'ActiveQuest')
	self:AddQuestInfo('QUEST_REWARD')
	self.Inspector.HintText = CHOOSE
	Control:AddHint(KEY.CROSS, COMPLETE_QUEST)
end

function NPC:QUEST_FINISHED(...)
	self:PlayOutro()
end

function NPC:QUEST_DETAIL(...)
	local questStartItemID = ...
	if ( QuestIsFromAdventureMap() ) or
		( QuestIsFromAreaTrigger() ) or --and QuestGetAutoAccept() ) or
		(questStartItemID ~= nil and questStartItemID ~= 0) then
		self:ForceClose()
		return
	end
	self:PlayIntro('QUEST_DETAIL')
	self:UpdateTalkingHead(GetTitleText(), GetQuestText(), 'AvailableQuest')
	self:AddQuestInfo('QUEST_DETAIL')
	self.Inspector.HintText = nil
	Control:AddHint(KEY.CROSS, ACCEPT)
end

function NPC:QUEST_ITEM_UPDATE()
	local questEvent = (self.lastEvent ~= 'QUEST_ITEM_UPDATE') and self.lastEvent or self.questEvent
	self.questEvent = questEvent

	if questEvent and self[questEvent] then
		self[questEvent](self)
		return questEvent
	end
end

----------------------------------
-- Content handlers (items)
----------------------------------
function NPC:SetItemTooltip(tooltip, item)
	local objType = item.objectType
	tooltip.Button:SetScript('OnClick', function() item:Click() end)
	if objType == 'item' then
		tooltip:SetQuestItem(item.type, item:GetID())
	elseif objType == 'currency' then
		tooltip:SetQuestCurrency(item.type, item:GetID())
	end
	tooltip.Icon.Texture:SetTexture(item.itemTexture or item.Icon:GetTexture())
end

function NPC:GetItemColumn(owner, id)
	local columns = owner and owner.Columns
	if columns and id then
		local column = columns[id]
		local anchor = columns[id - 1]
		if not column then
			column = CreateFrame('Frame', '$parentColumn'..id, owner)
			column:SetSize(1, 1) -- set size to make sure children are drawn
			UI:ApplyMixin(column, nil, 'AdjustToChildren')
			columns[id] = column
		end
		if anchor then
			column:SetPoint('TOPLEFT', anchor, 'TOPRIGHT', 30, 0)
		else
			column:SetPoint('TOPLEFT', owner, 0, 0)
		end
		column:Show()
		return column
	end
end

function NPC:ShowItems()
	local inspector = self.Inspector
	local elements = self.TalkBox.Elements
	local rewardsFrame = elements.Content.RewardsFrame
	local items = inspector.Items
	local active = inspector.Active
	local extras = inspector.Extras
	local choices = inspector.Choices
	local hasChoice
	extras:SetSize(1, 1)
	choices:SetSize(1, 1)
	inspector:Show()
	for id, item in pairs(items) do
		local tooltip = UI:GetTooltip()
		local owner = item.type == 'choice' and choices or extras
		local tooltips = owner.Tooltips
	--	local id = #tooltips + 1
		local columnID = ( id % 3 == 0 ) and 3 or ( id % 3 )
		local column = self:GetItemColumn(owner, columnID)

		tooltip:SetParent(column)
		tooltip:SetOwner(column, "ANCHOR_NONE")
		tooltip.owner = owner

		self:SetItemTooltip(tooltip, item)

		tooltips[id] = tooltip
		active[id] = tooltip.Button

		-- if item is choice, add to active pool
		if item.objectType == 'item' then
			hasChoice = true
			tooltip.Button:SetID(id)
			if item.type == 'choice' then
				tooltip:SetCheckable(elements.chooseItems)
				if elements.itemChoice == item:GetID() then
					tooltip:SetChecked(true)
				end
			end
		end
		local width, height = tooltip:GetSize()
		tooltip:SetSize(width + 30, height + 8)

		if column.lastItem then
			tooltip:SetPoint('TOP', column.lastItem, 'BOTTOM', 0, 0)
		else
			tooltip:SetPoint('TOP', column, 'TOP', 0, 0)
		end

		column.lastItem = tooltip
	end
	if self.TalkBox.Elements.Progress.ReqText:IsVisible() then
		extras.Text:SetText(self.TalkBox.Elements.Progress.ReqText:GetText())
	end
	if rewardsFrame.ItemChooseText:IsVisible() then
		choices.Text:SetText(rewardsFrame.ItemChooseText:GetText())
	elseif rewardsFrame.ItemReceiveText:IsVisible() then
		if hasChoice then
			choices.Text:SetText(rewardsFrame.ItemReceiveText:GetText())
		else
			extras.Text:SetText(rewardsFrame.ItemReceiveText:GetText())
		end
	end
	inspector.Threshold = #active
	inspector:AdjustToChildren()
	inspector:SetFocus(1)
end

function NPC:UpdateItems()
	local items, numItems = self:GetItems()
	if numItems > 0 then
		self.hasItems = true
		Control:AddHint(KEY.CIRCLE, INSPECT)
	else
		self.hasItems = false
		Control:RemoveHint(KEY.CIRCLE)
	end
end

function NPC:GetItems()
	local items = self.Inspector.Items
	wipe(items)
	for _, item in pairs(self.TalkBox.Elements.Content.RewardsFrame.Buttons) do
		if item:IsVisible() then
			items[#items + 1] = item
		end
	end
	for _, item in pairs(self.TalkBox.Elements.Progress.Buttons) do
		if item:IsVisible() then
			items[#items + 1] = item
		end
	end
	return items, #items
end

----------------------------------
-- Content handlers (quest info)
----------------------------------
function NPC:AddQuestInfo(template)
	local elements = self.TalkBox.Elements
	local content = elements.Content
	local height = elements:Display(template, 'Stone')

	-- hacky fix to stop a content frame that only contains a spacer from showing. 
	if height > 20 then
		elements:Show()
		content:Show()
		elements:UpdateBoundaries()
	else
		elements:Hide()
		content:Hide()
	end
	-- Extra: 32 px padding 
	self.TalkBox:SetExtraOffset(height + 32)
	self.TalkBox.NameFrame.FadeIn:Play()
end

function NPC:IsGossipAvailable()
	-- if there is only a non-gossip option, then go to it directly
	if ( (GetNumGossipAvailableQuests() == 0) and 
		(GetNumGossipActiveQuests() == 0) and 
		(GetNumGossipOptions() == 1) and
		not ForceGossip() ) then
		local text, gossipType = GetGossipOptions()
		if ( gossipType ~= "gossip" ) then
			return false
		end
	end
	return true
end

function NPC:ResetElements()
	self.Inspector:Hide()
	local elements = self.TalkBox.Elements
	for _, frame in pairs(elements.Active) do
		frame:Hide()
	end
	wipe(elements.Active)
	elements:Hide()
	elements.Content:Hide()
	elements.Progress:Hide()
end

function NPC:UpdateTalkingHead(title, text, npcType)
	local unit
	if ( UnitExists('questnpc') and not UnitIsUnit('questnpc', 'player') and not UnitIsDead('questnpc') ) then
		unit = 'questnpc'
	elseif ( UnitExists('npc') and not UnitIsUnit('npc', 'player') and not UnitIsDead('npc') ) then
		unit = 'npc'
	else
		unit = npcType
	end
	local talkBox = self.TalkBox
	talkBox:SetExtraOffset(0)
	talkBox.StatusBar:Show()
	talkBox.MainFrame.Indicator:SetTexture('Interface\\GossipFrame\\' .. npcType .. 'Icon')
	talkBox.MainFrame.Model:SetUnit(unit)
	talkBox.NameFrame.Name:SetText(title)
	talkBox.TextFrame.Text:SetText(text)
end

----------------------------------
-- Animation players
----------------------------------
function NPC:PlayIntro(event)
	local box = self.TalkBox
	local isShown = box:IsVisible()
	box:Show()
	if IsOptionFrameOpen() then
		self:ForceClose()
	else
		self:FadeIn(nil, isShown)
		local point = L.Get('boxpoint')
		local x, y = L.Get('boxoffsetX'), L.Get('boxoffsetY')
		box:ClearAllPoints()
		if not isShown then
			box:SetPoint(point, UIParent, point, -x, -y)
		end
		box:SetOffset(box.offsetX or x, box.offsetY or y)
	end
end

function NPC:PlayOutro()
	self:FadeOut(0.5)
end

function NPC:ForceClose()
	CloseGossip()
	CloseQuest()
	self:PlayOutro()
end

----------------------------------
-- Input handler
----------------------------------
local inputs = {
	[KEY.UP] = function(self, down) 
		if down then 
			self.TitleButtons:SetPrevious()
		end
	end,
	[KEY.DOWN] = function(self, down)
		if down then
			self.TitleButtons:SetNext() 
		end
	end,
	[KEY.TRIANGLE] = function(self, down) if down then CloseGossip() CloseQuest() end end,
	[KEY.SQUARE] = function(self, down)
		if down then
			local text = self.TalkBox.TextFrame.Text
			if text:IsSequence() then
				text:ForceNext()
			end
		end
	end,
	[KEY.CIRCLE] = function(self, down)
		if down then
			if self.isInspecting then
				self.Inspector:Hide()
			elseif self.hasItems then
				self:ShowItems()
			end
		end
	end,
	[KEY.CROSS] = function(self, down)
		if down then
			-- Gossip/multiple quest choices
			if self.TitleButtons:GetMaxIndex() > 0 then
				self.TitleButtons:ClickFocused()
			-- Item inspection
			elseif self.isInspecting then
				self.Inspector:ClickFocused()
				self.Inspector:Hide()
			-- Complete quest
			elseif self.lastEvent == 'QUEST_COMPLETE' then
				-- if multiple items to choose between and none chosen
				if self.TalkBox.Elements.itemChoice == 0 and GetNumQuestChoices() > 1 then
					self:ShowItems()
				else
					self.TalkBox.Elements:CompleteQuest()
				end
			-- Accept quest
			elseif self.lastEvent == 'QUEST_DETAIL' then
				self.TalkBox.Elements:AcceptQuest()
			-- Progress quest (why are these functions named like this?)
			elseif IsQuestCompletable() then
				CompleteQuest()
			end
		end
	end,
	[KEY.LEFT] = function(self, down)
		if down then
			if self.isInspecting then
				self.Inspector:SetPrevious()
			end
		end
	end,
	[KEY.RIGHT] = function(self, down)
		if down then
			if self.isInspecting then
				self.Inspector:SetNext()
			end
		end
	end,
}


function NPC:OnInput(button, down)
	button = tonumber(button)
	if inputs[button] then
		inputs[button](self, down)
	end
end

----------------------------------
-- Button selector 
----------------------------------
function Selector:SetFocus(index)
	if self:IsVisible() and index then
		local focus = self:GetFocus()
		if focus then
			focus:UnlockHighlight()
			focus:OnLeave()
		end
		local max = self:GetMaxIndex() 
		self.index = ( index > max and max ) or ( index < 1 and 1 ) or index
		self:SetFocusHighlight()
		if max > 0 and self.HintText then
			Control:AddHint(KEY.CROSS, self.HintText)
		else
			Control:RemoveHint(KEY.CROSS)
		end
	end
end

function Selector:SetNext()
	local nextButton = self:GetNextButton(self.index, 1)
	self:SetFocus(nextButton and nextButton:GetID())
end

function Selector:SetPrevious()
	local prevButton = self:GetNextButton(self.index, -1)
	self:SetFocus(prevButton and prevButton:GetID())
end

function Selector:ClickFocused()
	local focus = self:GetFocus()
	if focus then
		focus:Click()
	end
end

function Selector:SetFocusHighlight()
	local focus = self:GetFocus()
	if focus then
		focus:LockHighlight()
		focus:OnEnter()
	end
end

function Selector:GetFocus()
	return self.Active[self.index]
end

function Selector:GetActive()
	return pairs(self.Active)
end

function Selector:GetNextButton(index, delta)
	if index then
		local modifier = delta
		while true do
			local key = index + delta
			if key < 1 or key > self.Threshold then
				return self.Active[self.index]
			end
			if self.Active[key] then
				return self.Active[key]
			else
				delta = delta + modifier
			end
		end
	end
end

function Selector:GetMaxIndex()
	local maxIndex = 0
	for i, button in pairs(self.Active) do
		if i > maxIndex then
			maxIndex = i
		end
	end
	return maxIndex
end


----------------------------------
-- TalkBox button
----------------------------------
function TalkBox:SetOffset(x, y)
	local point = L.Get('boxpoint')
	x = x or L.Get('boxoffsetX')
	y = y or L.Get('boxoffsetY')

	self.offsetX = x
	self.offsetY = y

	local isBottom = ( point == 'Bottom' )
	local isVert = ( isBottom or point == 'Top' )

	y = y +  ( isBottom and self.extraY or 0 )

	local evaluator = self[ 'Get' .. point ]
	local parent = UIParent
	local comp = isVert and y or x

	if not evaluator then
		self:SetPoint(point, parent, x, y)
		return
	end

	self:SetScript('OnUpdate', function(self)
		local offset = (evaluator(self) or 0) - (evaluator(parent) or 0)
		local diff = ( comp - offset )
		if (offset == 0) or abs( comp - offset ) < 0.3 then
			self:SetPoint(point, parent, x, y)
			self:SetScript('OnUpdate', nil)
		elseif isVert then
			self:SetPoint(point, parent, x, offset + ( diff / 10 ))
		else
			self:SetPoint(point, parent, offset + (diff / 10), y)
		end
	end)
end

function TalkBox:SetExtraOffset(newOffset)
	local currX = ( self.offsetX or L.Get('boxoffsetX') )
	local currY = ( self.offsetY or L.Get('boxoffsetY') )
	self.extraY = newOffset
	self:SetOffset(currX, currY)
end

----------------------------------
-- Mixin with scripts
----------------------------------
L.Mixin(frame, NPC)
L.Mixin(frame.TalkBox, TalkBox)
L.Mixin(frame.Inspector, Selector)
L.Mixin(frame.TitleButtons, Selector)