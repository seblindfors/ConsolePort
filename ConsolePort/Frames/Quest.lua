local _, db = ...;
local KEY = db.KEY;
local iterator = 1;

-- Write for QuestLogPopupDetailFrame
function ConsolePort:Quest (key, state)
	local GreetingFrame = QuestGreetingScrollChildFrame:IsVisible();
	if 	key == KEY.CIRCLE and not GreetingFrame then
		local VisibleButton;
		if 		QuestFrameCompleteQuestButton:IsVisible() 	then VisibleButton = QuestFrameCompleteQuestButton;		
		elseif 	QuestFrameCompleteButton:IsVisible() 		then VisibleButton = QuestFrameCompleteButton;
		elseif 	QuestFrameAcceptButton:IsVisible() 			then VisibleButton = QuestFrameAcceptButton;
		elseif	QuestLogPopupDetailFrameTrackButton:IsVisible() then VisibleButton = QuestLogPopupDetailFrameTrackButton; end;
		if VisibleButton then ConsolePort:Button(VisibleButton, state); end;
	elseif 	key == KEY.SQUARE then
		local VisibleButton;
		if 		QuestLogPopupDetailFrameAbandonButton:IsVisible() then VisibleButton = QuestLogPopupDetailFrameAbandonButton; end;
		if VisibleButton then ConsolePort:Button(VisibleButton, state); end;
	elseif	key == KEY.TRIANGLE then
		local VisibleButton;
		if 		QuestFrameDeclineButton:IsVisible() then VisibleButton = QuestFrameDeclineButton;
		elseif 	QuestLogPopupDetailFrame.ShowMapButton:IsVisible() then VisibleButton = QuestLogPopupDetailFrame.ShowMapButton;
		elseif	QuestFrameGoodbyeButton then VisibleButton = QuestFrameGoodbyeButton end;
		if VisibleButton then ConsolePort:Button(VisibleButton, state); end;
	elseif	key == KEY.UP and not GreetingFrame then
		ConsolePort:Button(QuestLogPopupDetailFrameScrollFrameScrollBarScrollUpButton, state);
		ConsolePort:Button(QuestDetailScrollFrameScrollBarScrollUpButton, state);
		ConsolePort:Button(QuestProgressScrollFrameScrollBarScrollUpButton, state);
		ConsolePort:Button(QuestRewardScrollFrameScrollBarScrollUpButton, state);
	elseif	key == KEY.DOWN and not GreetingFrame then
		ConsolePort:Button(QuestLogPopupDetailFrameScrollFrameScrollBarScrollDownButton, state);
		ConsolePort:Button(QuestDetailScrollFrameScrollBarScrollDownButton, state);
		ConsolePort:Button(QuestProgressScrollFrameScrollBarScrollDownButton, state);
		ConsolePort:Button(QuestRewardScrollFrameScrollBarScrollDownButton, state);
	elseif (key == "rewards" or 
			key == "preview" or 
			key == KEY.LEFT or 
			key == KEY.RIGHT) and
			QuestInfoRewardsFrame:IsVisible() then
		local rewards = { QuestInfoRewardsFrame:GetChildren() };
		local items = {};
		local count = 0;
		for i, item in pairs(rewards) do
			if item.objectType == "item" then
				tinsert(items, item);
				count = count + 1;
			end
		end
		if 		key == KEY.LEFT  and state == KEY.STATE_DOWN 	then iterator = iterator - 1
		elseif 	key == KEY.RIGHT and state == KEY.STATE_DOWN	then iterator = iterator + 1 end 
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
	elseif (key == KEY.UP or 
			key == KEY.DOWN or 
			key == KEY.CIRCLE or 
			key == KEY.PREPARE) and state == KEY.STATE_UP then
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
		if key == KEY.UP then
			iterator = iterator - 1;
			if iterator < 1 then iterator = count end
			ConsolePort:Highlight(valid[iterator], options);
		elseif	key == KEY.DOWN then 
			iterator = iterator + 1;
			if iterator > count then iterator = 1 end
			ConsolePort:Highlight(valid[iterator], options);
		elseif	key == KEY.CIRCLE then
			options[valid[iterator]]:Click();
			iterator = 1;
		elseif	key == KEY.PREPARE then
			iterator = 1;
			options[1]:LockHighlight();
			for i=2, count do
				options[i]:UnlockHighlight();
			end
		end
	end
end