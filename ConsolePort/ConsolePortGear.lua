local _, G = ...;
local iterator = 1;
local extra = 1;

function ConsolePort:Gear (key, state)
	local gear = { PaperDollItemsFrame:GetChildren() };
	if key == G.PREPARE then
		gear[1]:LockHighlight();
	end
	if not EquipmentFlyoutFrame:IsVisible() then
		if 	key == G.UP and state == G.STATE_DOWN then
			if 		iterator == 17 	then iterator = 8
			elseif 	iterator == 18	then iterator = 16
			elseif	iterator ~= 1 	then iterator = iterator - 1 end
			ConsolePort:Highlight(iterator, gear);
			gear[iterator]:GetScript("OnEnter")(gear[iterator]);
		elseif 	key == G.DOWN and state == G.STATE_DOWN then
			if 	iterator ~= 8 and
				iterator ~= 16 and
				iterator ~= 17 and
				iterator ~= 18 then
				iterator = iterator + 1;
			end
			ConsolePort:Highlight(iterator, gear);
			gear[iterator]:GetScript("OnEnter")(gear[iterator]);
		elseif	key == G.RIGHT and state == G.STATE_DOWN then
			if 		iterator == 17 	then iterator = 18
			elseif 	iterator == 18 	then iterator = 16
			elseif 	iterator == 8 	then iterator = 17
			elseif 	iterator == 16 	then iterator = 16
			elseif not 	(iterator+8 > 16) then
				iterator = iterator + 8;
			end 
			ConsolePort:Highlight(iterator, gear);
			gear[iterator]:GetScript("OnEnter")(gear[iterator]);
		elseif	key == G.LEFT and state == G.STATE_DOWN then
			if 		iterator == 18	then iterator = 17
			elseif 	iterator == 17 	then iterator = 8
			elseif 	iterator == 16 	then iterator = 18
			elseif not (iterator-8 < 1) then 
				iterator = iterator - 8;
			end		
			ConsolePort:Highlight(iterator, gear);
			gear[iterator]:GetScript("OnEnter")(gear[iterator]);
		elseif	key == G.CIRCLE then
			if state == G.STATE_DOWN then
				gear[iterator]:LockHighlight();
			elseif state == G.STATE_UP then
				EquipmentFlyout_UpdateFlyout(gear[iterator]);
				EquipmentFlyout_Show(gear[iterator]);
				gear[iterator].popoutButton.flyoutLocked = true;
				gear[iterator]:UnlockHighlight();
				extra = 1;
			end
		end
	elseif	EquipmentFlyoutFrame:IsVisible() and state == G.STATE_DOWN then
		if 		key == G.RIGHT 	then extra = extra + 1;
		elseif 	key == G.LEFT	then extra = extra - 1;
		elseif	key == G.CIRCLE then
			local items = { EquipmentFlyoutFrameButtons:GetChildren() };
			items[extra]:Click();
			gear[iterator].popoutButton.flyoutLocked = false;
			EquipmentFlyoutFrame:Hide();
		elseif 	key == G.TRIANGLE then
			gear[iterator].popoutButton.flyoutLocked = false;
			ConsolePort:Highlight(iterator, gear);
			gear[iterator]:GetScript("OnEnter")(gear[iterator]);
		end
		local items = { EquipmentFlyoutFrameButtons:GetChildren() };
		local swappables = EquipmentFlyoutFrame["totalItems"];
		if extra > swappables then extra = 1 elseif extra < 1 then extra = swappables end;
		ConsolePort:Highlight(extra, items);
		items[extra]:GetScript("OnEnter")(items[extra]);
	end
end
