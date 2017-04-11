local Titles, _, L = {}, ...
local UI = ConsolePortUI
L.TitlesMixin = Titles

local NORMAL_QUEST_DISPLAY = NORMAL_QUEST_DISPLAY:gsub(0, 'f')
local TRIVIAL_QUEST_DISPLAY = TRIVIAL_QUEST_DISPLAY:gsub(0, 'f')

----------------------------------
-- Display
----------------------------------
function Titles:AdjustHeight(newHeight)
	self:SetScript('OnUpdate', function(self)
		local height = self:GetHeight()
		local diff = newHeight - height
		if abs(newHeight - height) < 0.5 then
			self:SetHeight(newHeight)
			self:SetScript('OnUpdate', nil)
		else
			self:SetHeight(height + ( diff / 10 ) )
		end
	end)
end

function Titles:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	else
		self:Hide()
	end
end

function Titles:OnHide()
	for i, button in pairs(self.Buttons) do
		button:UnlockHighlight()
		button:Hide()
	end
	wipe(self.Active)
	self.focus = nil
	self.numActive = 0
	self.idx = 1
end

function Titles:GetNumActive()
	return self.numActive or 0
end

function Titles:GetButton(index)
	local button = self.Buttons[index]
	if not button then
		button = CreateFrame('Button', _ .. 'TitleButton' .. index, self)
	--	L.Mixin(button, L.ButtonMixin, L.ScalerMixin)
		UI:ApplyMixin(button, nil, L.ButtonMixin, 'ScaleOnFocus')
		button:Init(index)
		self.Buttons[index] = button
	end
	button:Show()
	return button
end

function Titles:UpdateActive()
	local newHeight, numActive = 0, 0
	wipe(self.Active)
	for i, button in pairs(self.Buttons) do
		if button:IsVisible() then
			newHeight = newHeight + button:GetHeight()
			numActive = numActive + 1
			self.Active[i] = button
		end
	end
	self.numActive = numActive
	self:AdjustHeight(newHeight)
	-- Mixed in from Selector in Logic.lua
	self:SetFocus(1)
end

----------------------------------
-- Gossip
----------------------------------
function Titles:GOSSIP_SHOW()
	self.idx = 1
	self.type = 'Gossip'
	self:Show()
	self:UpdateAvailableQuests(GetGossipAvailableQuests())
	self:UpdateActiveQuests(GetGossipActiveQuests())
	self:UpdateGossipOptions(GetGossipOptions())
	for i = self.idx, #self.Buttons do
		self.Buttons[i]:Hide()
	end
	self:UpdateActive()
end

function Titles:UpdateAvailableQuests(...)
	local titleIndex = 1
	for i = 1, select('#', ...), 7 do
		local button = self:GetButton(self.idx)
		local 	titleText, level, isTrivial, frequency, 
				isRepeatable, isLegendary = select(i, ...)
		----------------------------------
		local qType = ( isTrivial and TRIVIAL_QUEST_DISPLAY )
		button:SetFormattedText(qType or NORMAL_QUEST_DISPLAY, titleText)
		----------------------------------
		local icon = ( isLegendary and 'AvailableLegendaryQuestIcon' ) or
					( frequency == LE_QUEST_FREQUENCY_DAILY and 'DailyQuestIcon') or
					( frequency == LE_QUEST_FREQUENCY_WEEKLY and 'DailyQuestIcon' ) or
					( isRepeatable and 'DailyActiveQuestIcon' ) or
					( 'AvailableQuestIcon' )
		button:SetGossipQuestIcon(icon, qType and 0.5)
		----------------------------------
		button:SetGossipID(titleIndex)
		button.type = 'Available'
		----------------------------------
		self.idx = self.idx + 1
		titleIndex = titleIndex + 1
	end
end

function Titles:UpdateActiveQuests(...)
	local titleIndex = 1
	local numActiveQuestData = select("#", ...)
	self.hasActiveQuests = (numActiveQuestData > 0)
	for i = 1, numActiveQuestData, 6 do
		local button = self:GetButton(self.idx)
		local 	titleText, level, isTrivial, 
				isComplete, isLegendary = select(i, ...)
		----------------------------------
		local qType = ( isTrivial and TRIVIAL_QUEST_DISPLAY )
		button:SetFormattedText(qType or NORMAL_QUEST_DISPLAY, titleText)
		----------------------------------
		local icon = ( isComplete and isLegendary and 'ActiveLegendaryQuestIcon') or
					( isComplete and 'ActiveQuestIcon' ) or
					( 'InCompleteQuestIcon' )
		button:SetGossipQuestIcon(icon, qType and 0.5)
		----------------------------------
		button:SetGossipID(titleIndex)
		button.type = 'Active'
		----------------------------------
		self.idx = self.idx + 1
		titleIndex = titleIndex + 1
	end
end

function Titles:UpdateGossipOptions(...)
	local titleIndex = 1
	for i=1, select('#', ...), 2 do
		local button = self:GetButton(self.idx)
		local titleText, icon = select(i, ...)
		----------------------------------
		button:SetText(titleText)
		button:SetGossipIcon(icon)
		----------------------------------
		button:SetGossipID(titleIndex)
		button.type = 'Gossip'
		----------------------------------
		self.idx = self.idx + 1
		titleIndex = titleIndex + 1
	end
end

function Titles:UNIT_QUEST_LOG_CHANGED()
	if self:IsVisible() then
		if ( self.type == 'Gossip' and self.hasActiveQuests ) then
			self:Hide()
			self:GOSSIP_SHOW()
		elseif ( self.type == 'Quests' ) then
			self:Hide()
			self:QUEST_GREETING()
		end
	end
end

----------------------------------
-- Quest
----------------------------------
function Titles:QUEST_GREETING()
	self.idx = 1
	self.type = 'Quests'
	self:Show()
	self:UpdateActiveGreetingQuests(GetNumActiveQuests())
	self:UpdateAvailableGreetingQuests(GetNumAvailableQuests())
	for i = self.idx, #self.Buttons do
		self.Buttons[i]:Hide()
	end
	self:UpdateActive()
end


function Titles:UpdateActiveGreetingQuests(numActiveQuests)
	for i=1, numActiveQuests do
		local button = self:GetButton(self.idx)
		local title, isComplete = GetActiveTitle(i)
		----------------------------------
		local qType = ( IsActiveQuestTrivial(i) and TRIVIAL_QUEST_DISPLAY )
		button:SetFormattedText(qType or NORMAL_QUEST_DISPLAY, title)
		----------------------------------
		local icon = ( isComplete and IsActiveQuestLegendary(i) and 'ActiveLegendaryQuestIcon' ) or
					( isComplete and 'ActiveQuestIcon') or
					( 'InCompleteQuestIcon' )
		button:SetGossipQuestIcon(icon, qType and 0.75)
		----------------------------------
		button:SetGossipID(i)
		button.type = 'ActiveQuest'
		----------------------------------
		self.idx = self.idx + 1
	end
end

function Titles:UpdateAvailableGreetingQuests(numAvailableQuests)
	for i=1, numAvailableQuests do
		local button = self:GetButton(self.idx)
		local title = GetAvailableTitle(i)
		local isTrivial, frequency, isRepeatable, isLegendary = GetAvailableQuestInfo(i)
		----------------------------------
		local qType = ( isTrivial and TRIVIAL_QUEST_DISPLAY )
		button:SetFormattedText(qType or NORMAL_QUEST_DISPLAY, title)
		----------------------------------
		local icon = ( isLegendary and 'AvailableLegendaryQuestIcon' ) or
					( frequency == LE_QUEST_FREQUENCY_DAILY and 'DailyQuestIcon') or
					( frequency == LE_QUEST_FREQUENCY_WEEKLY and 'DailyQuestIcon' ) or
					( isRepeatable and 'DailyActiveQuestIcon' ) or
					( 'AvailableQuestIcon' )
		button:SetGossipQuestIcon(icon, qType and 0.5)
		----------------------------------
		button:SetGossipID(i)
		button.type = 'AvailableQuest'
		----------------------------------
		self.idx = self.idx + 1
	end
end