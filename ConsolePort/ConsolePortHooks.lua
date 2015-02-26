local _
local _, G = ...;
local function UIDefaultButtonExtend(Button, Anchor)
	Button:SetPoint(Anchor, Button:GetParent(), "BOTTOM", 0);
end

local function CinematicControllerInput(key, state)
	local keybind = GetBindingFromClick(key), button;
	if 		keybind == "CLICK CP_R_RIGHT_NOMOD:LeftButton" 	then button = G.CIRCLE;
	elseif 	keybind == "CLICK CP_R_LEFT_NOMOD:LeftButton" 	then button = G.SQUARE; end;
	if button then ConsolePort:Misc(button, state); end;
end

function ConsolePort:LoadHookScripts()
	-- Add guides to tooltips
	-- Bug: Currently shows on reagents to recipes
	GameTooltip:HookScript("OnTooltipSetItem", function(self)
		if 	not InCombatLockdown() then
			local 	CLICK_STRING;
			if		self:GetOwner():GetParent():GetName() and
					string.find(self:GetOwner():GetParent():GetName(), "MerchantItem") ~= nil then
					CLICK_STRING = G.CLICK_BUY;
			elseif 	MerchantFrame:IsVisible() 		 then CLICK_STRING = G.CLICK_SELL;
			elseif 	IsEquippedItem(self:GetItem()) 	 then CLICK_STRING = G.CLICK_REPLACE;
			elseif 	IsEquippableItem(self:GetItem()) then CLICK_STRING = G.CLICK_EQUIP;
			else 	CLICK_STRING = G.CLICK_USE; end
			if 	GetItemCount(self:GetItem(), false) ~= 0 or
				MerchantFrame:IsVisible() then
				if 	EquipmentFlyoutFrame:IsVisible() then
					self:AddLine(G.CLICK_CANCEL, 1,1,1);
				end;
				self:AddLine(CLICK_STRING, 1,1,1);
				self:AddLine(G.CLICK_PICKUP, 1,1,1);
				self:Show();
			end
		end
	end);
	GameTooltip:HookScript("OnTooltipSetSpell", function(self)
		if not InCombatLockdown() then
			if 	self:GetOwner():GetParent() == SpellBookSpellIconsFrame and not
				self:GetOwner().isPassive then
				self:AddLine(G.CLICK_USE_NOCOMBAT, 1,1,1);
				self:AddLine(G.CLICK_PICKUP, 1,1,1);
				self:Show();
			end
		end
	end);
	GameTooltip:HookScript("OnShow", function(self)
		if 	self:GetOwner() and
			self:GetOwner().questID then
			self:AddLine(G.CLICK_QUEST_DETAILS, 1,1,1);
			self:AddLine(G.CLICK_QUEST_TRACKER, 1,1,1);
		end
 	end);
	-- Map hooks
	WorldMapButton:HookScript("OnUpdate", ConsolePort.MapHighlight);
	WorldMapFrame:HookScript("OnShow", function(self)
		if QuestScrollFrame:GetAlpha() ~= 1 then 
			WorldMapFrameTutorialButton:GetChildren():Hide();
		end
	end);
	WorldMapFrame:HookScript("OnHide", function(self)
		if 	GameTooltip:GetOwner() and
			GameTooltip:GetOwner().questID then
			GameTooltip:GetOwner():GetScript("OnLeave")(GameTooltip:GetOwner());
		end
	end);
	QuestMapDetailsScrollFrame:HookScript("OnShow", function(self)
		WorldMapFrame.UIElementsFrame.CloseQuestPanelButton:Hide();
		WorldMapFrame.UIElementsFrame.TrackingOptionsButton:Hide();
	end);
	QuestMapDetailsScrollFrame:HookScript("OnHide", function(self)
		WorldMapFrame.UIElementsFrame.CloseQuestPanelButton:Show();
		WorldMapFrame.UIElementsFrame.TrackingOptionsButton:Show();
	end);
	-- Hide guides not currently in use
	QuestMapFrame.DetailsFrame.CompleteQuestFrame.CompleteButton:HookScript("OnShow", function(self)
		QuestMapFrame.DetailsFrame.TrackButton:GetChildren():Hide();
	end);
	QuestMapFrame.DetailsFrame.CompleteQuestFrame.CompleteButton:HookScript("OnHide", function(self)
		QuestMapFrame.DetailsFrame.TrackButton:GetChildren():Show();
	end);
	-- Disable keyboard input (will obstruct controller input)
	StackSplitFrame:EnableKeyboard(false);
	-- Modify default UI points, just aestethic
	UIDefaultButtonExtend(GossipFrameGreetingGoodbyeButton,	"LEFT"	);
	UIDefaultButtonExtend(QuestFrameAcceptButton, 			"RIGHT"	);
	UIDefaultButtonExtend(QuestFrameDeclineButton, 			"LEFT"	);
	UIDefaultButtonExtend(QuestFrameCompleteQuestButton,	"RIGHT" );
	UIDefaultButtonExtend(QuestFrameCompleteButton,			"RIGHT"	);
	UIDefaultButtonExtend(QuestFrameGoodbyeButton,			"LEFT"	);
	-- Add inputs to cinematic frame, behaves oddly after first dialog closing
	CinematicFrame:HookScript("OnKeyDown", function(self, key)
		CinematicControllerInput(key, G.STATE_DOWN);
	end);
	CinematicFrame:HookScript("OnKeyUp", function(self, key)
		CinematicControllerInput(key, G.STATE_UP);
	end);
end