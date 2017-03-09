----------------------------------
-- Initial setup.
----------------------------------
local _, L = ...
local frame = ConsolePortUI_NPC
local talkbox = frame.TalkBox
local titles = frame.TitleButtons
local db = ConsolePort:GetData()
local KEY = db.KEY
local UI = ConsolePortUI
local Control = UI:GetControlHandle()
L.frame = frame
L.db = db
L.Mixin = UI.Utils.Mixin

----------------------------------
-- Register events for main frame
----------------------------------
for _, event in pairs({
	'ADDON_LOADED',
	'GOSSIP_CLOSED',	-- Close gossip frame
	'GOSSIP_SHOW',		-- Show gossip options, can be a mix of gossip/quests
	'QUEST_COMPLETE',	-- Quest completed
	'QUEST_DETAIL',		-- Quest details/objectives/accept frame
	'QUEST_FINISHED',	-- Fires when quest frame is closed
	'QUEST_GREETING',	-- Multiple quests to choose from, but no gossip options
	'QUEST_IGNORED',	-- Ignore the currently shown quest
	'QUEST_PROGRESS',	-- Fires when you click on a quest you're currently on
	'QUEST_ITEM_UPDATE', -- Item update while in convo, refresh frames.
}) do frame:RegisterEvent(event) end

----------------------------------
-- Register events for titlebuttons
----------------------------------
for _, event in pairs({
	'GOSSIP_CLOSED',	-- Hide buttons
	'GOSSIP_SHOW',		-- Show gossip options, can be a mix of gossip/quests
	'QUEST_COMPLETE',	-- Hide when going from gossip -> complete
	'QUEST_DETAIL',		-- Hide when going from gossip -> detail
	'QUEST_FINISHED',	-- Hide when going from gossip -> finished 
	'QUEST_GREETING',	-- Show quest options, why is this a thing again?
	'QUEST_IGNORED',	-- Hide when using ignore binding?
	'QUEST_PROGRESS',	-- Hide when going from gossip -> active quest
--	'QUEST_LOG_UPDATE',	-- If quest changes while interacting
}) do titles:RegisterEvent(event) end

titles:RegisterUnitEvent('UNIT_QUEST_LOG_CHANGED', 'player')

----------------------------------
-- Load SavedVaribles
----------------------------------
frame.ADDON_LOADED = function(self, name)
	if name == _ then
		-- NomiCakes fix
		if select(4, GetAddOnInfo('NomiCakes')) then
			function self:ADDON_LOADED(name)
				if name == 'NomiCakes' then
					NomiCakesGossipButtonName = _ .. 'TitleButton'
					self.ADDON_LOADED = nil
					self:UnregisterEvent('ADDON_LOADED')
				end
			end
		else
			self.ADDON_LOADED = nil
			self:UnregisterEvent('ADDON_LOADED')
		end

		ConsolePortUIConfig = ConsolePortUIConfig or {}

		L.cfg = ConsolePortUIConfig.NPC or L.GetDefaultConfig()
		ConsolePortUIConfig.NPC = L.cfg

		talkbox:SetScale(L.Get('boxscale'))
		titles:SetScale(L.Get('titlescale'))
		self:SetScale(L.Get('scale'))

		talkbox:SetPoint(L.Get('boxpoint'), UIParent, L.Get('boxoffsetX'), L.Get('boxoffsetY'))
		titles:SetPoint('CENTER', UIParent, 'CENTER', L.Get('titleoffset'), 0)
	end
end

----------------------------------
-- Hide regular frames
----------------------------------
UI:CreateProbe(frame, GossipFrame, 'showhide')
UI:CreateProbe(frame, QuestFrame, 'showhide')
UI:RegisterFrame(frame, 'NPC', nil, true)
UI:HideFrame(GossipFrame)
UI:HideFrame(QuestFrame)
----------------------------------

-- ----------------------------------
-- -- Set backdrops on elements
-- ----------------------------------
-- talkbox.Elements:SetBackdrop(L.Backdrops.TALKBOX)
-- talkbox.Hilite:SetBackdrop(L.Backdrops.GOSSIP_HILITE)

----------------------------------
-- Model script, light
----------------------------------
local model = talkbox.MainFrame.Model
model:SetLight(unpack(L.ModelMixin.LightValues))
L.Mixin(model, L.ModelMixin)

----------------------------------
-- Main text things
----------------------------------
local text = talkbox.TextFrame.Text
Mixin(text, L.TextMixin) -- see Text.lua
-- Set array of fonts so the fontstring can be as big as possible without truncating the text
text:SetFontObjectsToTry(SystemFont_Shadow_Large, SystemFont_Shadow_Med2, SystemFont_Shadow_Med1)
-- Run a 'talk' animation on the portrait model whenever a new text is set
hooksecurefunc(text, 'SetNext', function(self, ...)
	local text = ...
	local counter = talkbox.TextFrame.SpeechProgress
	talkbox.TextFrame.FadeIn:Play()
	if text then
		model:PrepareAnimation(model:GetUnit(), text)
		if model:IsNPC() then
			if not text:match('%b<>') then
				self:SetVertexColor(1, 1, 1)
				model:SetRemainingTime(GetTime(), ( self.delays and self.delays[1]))
				if model.asking and not self:IsSequence() then
					model:Ask()
				else
					local yell = model.yelling and random(2) == 2
					if yell then model:Yell() else model:Talk() end
				end
			else
				self:SetVertexColor(1, 0.5, 0)
			end
		elseif model:IsPlayer() then
			model:Read()
		end
	end

	-- Add hints to manipulate the gossip speed
	if self:IsVisible() and ( not frame.isInspecting ) then
		counter:Hide()
		if self:IsSequence() then
			if self:IsFinished() then
				Control:AddHint(KEY.SQUARE, RESET)
			else
				counter:Show()
				counter:SetText(self:GetProgress())
				Control:AddHint(KEY.SQUARE, NEXT)
			end
		else
			Control:RemoveHint(KEY.SQUARE)
		end
		if L.Get('disableprogression') then
			self:StopProgression()
		end
	end
end)

----------------------------------
-- Misc fixes
----------------------------------
talkbox:SetParent(UIParent)
talkbox:Hide()
talkbox.TextFrame.SpeechProgress:SetFont('Fonts\\MORPHEUS.ttf', 16, '')

----------------------------------
-- Animation things
----------------------------------
frame.FadeIns = {
	talkbox.MainFrame.InAnim,
	talkbox.NameFrame.FadeIn,
	talkbox.TextFrame.FadeIn,
}

frame.FadeIn = function(self, fadeTime, stopPlay)
	db.UIFrameFadeIn(talkbox, fadeTime or 0.2, talkbox:GetAlpha(), 1)
	if ( not stopPlay ) and ( self.timeStamp ~= GetTime() ) then
		for _, Fader in pairs(self.FadeIns) do
			Fader:Play()
		end
	end
end

frame.FadeOut = function(self, fadeTime)
	db.UIFrameFadeOut(talkbox, fadeTime or 1, talkbox:GetAlpha(), 0, {
		finishedFunc = talkbox.Hide,
		finishedArg1 = talkbox,
	})
end

----------------------------------
-- Hacky hacky
-- Hook the regular talking head,
-- so that the offset is increased
-- when they are shown at the same time.
----------------------------------
hooksecurefunc('TalkingHead_LoadUI', function()
	local thf = TalkingHeadFrame
	if L.Get('boxpoint') == 'Bottom' and thf:IsVisible() then
		talkbox:SetOffset(nil, thf:GetTop() + 8)
	end
	thf:HookScript('OnShow', function(self)
		if L.Get('boxpoint') == 'Bottom' then
			talkbox:SetOffset(nil, self:GetTop() + 8)
		end
	end)
	thf:HookScript('OnHide', function(self)
		if L.Get('boxpoint') == 'Bottom' then
			talkbox:SetOffset()
		end
	end)
end)