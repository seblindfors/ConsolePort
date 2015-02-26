local _
local _, G = ...;
local iterator = 1;

function ConsolePort:Book(key, state)
	local spells = {};
	local currentTab = SpellBookFrame.selectedSkillLine;
	local a, b, offSet, numSpells = GetSpellTabInfo(currentTab);
	local count = offSet + numSpells;
	for i=1, 11, 2 do
		table.insert(spells, _G["SpellButton"..i]);
	end
	for i=2, 12, 2 do
		table.insert(spells, _G["SpellButton"..i]);
	end
	if key == G.PREPARE then iterator = 1;
	elseif 		state == G.STATE_DOWN then
		local 	old = iterator;
		if 		key == G.UP 	then iterator = iterator - 1;
		elseif	key == G.DOWN 	then iterator = iterator + 1;
		elseif 	key == G.RIGHT 	then iterator = iterator + 6;
		elseif 	key == G.LEFT 	then iterator = iterator - 6; end;
		if iterator > 12 and SpellBookNextPageButton:IsEnabled() then
			SpellBookNextPageButton:Click();
			iterator = old - 6;
		elseif iterator < 1 and SpellBookPrevPageButton:IsEnabled() then
			SpellBookPrevPageButton:Click();
			iterator = old + 6;
		elseif iterator < 1 or iterator > 12 then
			iterator = old;
		end
		if not SpellBook_GetSpellBookSlot(spells[iterator]) then
			iterator = 1;
		end
		local slot = spells[iterator];
		local index, type, spellID = SpellBook_GetSpellBookSlot(slot);
		local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(spellID);
		ConsolePort:Highlight(iterator, spells);
		slot:GetScript("OnEnter")(slot);
		if not InCombatLockdown() then
			CP_R_RIGHT_NOMOD:SetAttribute("type", "spell");
			CP_R_RIGHT_NOMOD:SetAttribute("spell", name);
		end
		if 	key == G.SQUARE and
			not slot.IsPassive then
			MouselookStop();
			PickupSpell(spellID);
		elseif key == G.TRIANGLE then
			local allTabs = { SpellBookSideTabsFrame:GetChildren() };
			local activeTabs = {};
			for i, tab in pairs(allTabs) do
				if not tab.isOffSpec and tab.tooltip then
					table.insert(activeTabs, tab);
				end
			end
			if 		currentTab == 1 then activeTabs[2]:Click();
			elseif 	currentTab == 2 then activeTabs[1]:Click(); end;
			iterator = 1;
			local slot = spells[iterator];
			slot:GetScript("OnEnter")(slot);
		end
	end
end