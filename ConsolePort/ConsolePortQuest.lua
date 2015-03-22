local _
local _, G = ...;
local iterator = 1;

-- Write for QuestLogPopupDetailFrame
function ConsolePort:Quest (key, state)
	local GreetingFrame = QuestGreetingScrollChildFrame:IsVisible();
	if 	key == G.CIRCLE and not GreetingFrame then
		local VisibleButton;
		if 		QuestFrameCompleteQuestButton:IsVisible() 	then VisibleButton = QuestFrameCompleteQuestButton;		
		elseif 	QuestFrameCompleteButton:IsVisible() 		then VisibleButton = QuestFrameCompleteButton;
		elseif 	QuestFrameAcceptButton:IsVisible() 			then VisibleButton = QuestFrameAcceptButton;
		elseif	QuestLogPopupDetailFrameTrackButton:IsVisible() then VisibleButton = QuestLogPopupDetailFrameTrackButton; end;
		if VisibleButton then ConsolePort:Button(VisibleButton, state); end;
	elseif 	key == G.SQUARE then
		local VisibleButton;
		if 		QuestLogPopupDetailFrameAbandonButton:IsVisible() then VisibleButton = QuestLogPopupDetailFrameAbandonButton; end;
		if VisibleButton then ConsolePort:Button(VisibleButton, state); end;
	elseif	key == G.TRIANGLE then
		local VisibleButton;
		if 		QuestFrameDeclineButton:IsVisible() then VisibleButton = QuestFrameDeclineButton;
		elseif 	QuestLogPopupDetailFrame.ShowMapButton:IsVisible() then VisibleButton = QuestLogPopupDetailFrame.ShowMapButton;
		elseif	QuestFrameGoodbyeButton then VisibleButton = QuestFrameGoodbyeButton end;
		if VisibleButton then ConsolePort:Button(VisibleButton, state); end;
	elseif	key == G.UP and not GreetingFrame then
		ConsolePort:Button(QuestLogPopupDetailFrameScrollFrameScrollBarScrollUpButton, state);
		ConsolePort:Button(QuestDetailScrollFrameScrollBarScrollUpButton, state);
		ConsolePort:Button(QuestProgressScrollFrameScrollBarScrollUpButton, state);
		ConsolePort:Button(QuestRewardScrollFrameScrollBarScrollUpButton, state);
	elseif	key == G.DOWN and not GreetingFrame then
		ConsolePort:Button(QuestLogPopupDetailFrameScrollFrameScrollBarScrollDownButton, state);
		ConsolePort:Button(QuestDetailScrollFrameScrollBarScrollDownButton, state);
		ConsolePort:Button(QuestProgressScrollFrameScrollBarScrollDownButton, state);
		ConsolePort:Button(QuestRewardScrollFrameScrollBarScrollDownButton, state);
	elseif 	key == "rewards" or 
			key == "preview" or 
			key == G.LEFT or 
			key == G.RIGHT then
		local rewards = { QuestInfoRewardsFrame:GetChildren() };
		local items = {};
		local count = 0;
		for i, item in pairs(rewards) do
			if item.objectType == "item" then
				tinsert(items, item);
				count = count + 1;
			end
		end
		if 		key == G.LEFT  and state == G.STATE_DOWN 	then iterator = iterator - 1
		elseif 	key == G.RIGHT and state == G.STATE_DOWN	then iterator = iterator + 1 end 
		if 		iterator > count then iterator = 1
		elseif 	iterator < 1 	 then iterator = count end
		local item = items[iterator];
		if item then 
			item:Click();
			if 	IsShiftKeyDown() then 
				item:GetScript("OnEnter")(item);
			elseif not IsShiftKeyDown() then
				item:GetScript("OnLeave")(item);
			end
		end
	elseif (key == G.UP or 
			key == G.DOWN or 
			key == G.CIRCLE or 
			key == G.PREPARE) and state == G.STATE_UP then
		local options = { QuestGreetingScrollChildFrame:GetChildren() };
		local count = 0;
		local valid = {};
		for i, item in ipairs(options) do
			-- Bug? :IsShown() 
			if item["isActive"] ~= nil then
				tinsert(valid, i);
				count = count + 1;
			end
		end
		if key == G.UP then
			iterator = iterator - 1;
			if iterator < 1 then iterator = count end
			ConsolePort:Highlight(valid[iterator], options);
		elseif	key == G.DOWN then 
			iterator = iterator + 1;
			if iterator > count then iterator = 1 end
			ConsolePort:Highlight(valid[iterator], options);
		elseif	key == G.CIRCLE then
			options[valid[iterator]]:Click();
			iterator = 1;
		elseif	key == G.PREPARE then
			iterator = 1;
			options[1]:LockHighlight();
			for i=2, count do
				options[i]:UnlockHighlight();
			end
		end
	end
end