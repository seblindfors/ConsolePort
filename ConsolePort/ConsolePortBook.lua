local _
local _, G = ...;
local iterator = 1;
local slot = nil;
local spells = {};
for i=1, 11, 2 do
	table.insert(spells, _G["SpellButton"..i]);
end
for i=2, 12, 2 do
	table.insert(spells, _G["SpellButton"..i]);
end

local function ResetIterator(self)
	if self == SpellBookNextPageButton then
		iterator = iterator - 6;
	elseif self == SpellBookPrevPageButton then
		iterator = iterator + 6;
	else
		iterator = 1;
	end
	if not SpellBook_GetSpellBookSlot(spells[iterator]) then
		iterator = 1;
	end
end

SpellBookNextPageButton:HookScript("OnClick", ResetIterator);
SpellBookPrevPageButton:HookScript("OnClick", ResetIterator);

SpellBookSpellIconsFrame:HookScript("OnUpdate", function(self, elapsed)
	if self:IsVisible() and ConsolePort:GetFocusFrame().frame == self then
		slot = spells[iterator];
		ConsolePort:Highlight(iterator, spells);
		slot:GetScript("OnEnter")(slot);
		if not InCombatLockdown() then
			local _,_, spellID = SpellBook_GetSpellBookSlot(slot);
			local name = GetSpellInfo(spellID);
			CP_R_RIGHT_NOMOD:SetAttribute("type", "spell");
			CP_R_RIGHT_NOMOD:SetAttribute("spell", name);
		end
		if CP_L_RIGHT_NOMOD.state == G.STATE_UP then
			if 	iterator >= 7 and SpellBookNextPageButton:IsEnabled() then
				ConsolePort:SetClickButton(CP_L_RIGHT_NOMOD, SpellBookNextPageButton);
			else
				CP_L_RIGHT_NOMOD:SetAttribute("type", "Book");
			end
		end
		if CP_L_LEFT_NOMOD.state == G.STATE_UP then
			if 	iterator <= 6 and
				SpellBookPrevPageButton:IsEnabled() then
				ConsolePort:SetClickButton(CP_L_LEFT_NOMOD, SpellBookPrevPageButton);
			else
				CP_L_LEFT_NOMOD:SetAttribute("type", "Book");
			end
		end
	end
end);

function ConsolePort:Book(key, state)
	local currentTab = SpellBookFrame.selectedSkillLine;
	local a, b, offSet, numSpells = GetSpellTabInfo(currentTab);
	local count = offSet + numSpells;
	if key == G.PREPARE then iterator = 1;
	elseif 		state == G.STATE_DOWN then
		local 	old = iterator;
		if 		key == G.UP 	then iterator = iterator - 1;
		elseif	key == G.DOWN 	then iterator = iterator + 1;
		elseif 	key == G.RIGHT 	then iterator = iterator + 6;
		elseif 	key == G.LEFT 	then iterator = iterator - 6; end;
		if iterator < 1 or iterator > 12 then
			iterator = old;
		end
		if not SpellBook_GetSpellBookSlot(spells[iterator]) then
			iterator = old;
		end
		local _,_, spellID = SpellBook_GetSpellBookSlot(slot);
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
		end
	end
end