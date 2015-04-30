local _, G = ...;
local KEY = G.KEY;
local iterator = 1;
local slot = nil;
local spells = {};
for i=1, 11, 2 do
	tinsert(spells, _G["SpellButton"..i]);
end
for i=2, 12, 2 do
	tinsert(spells, _G["SpellButton"..i]);
end

local function ResetIterator(self)
	if self == SpellBookNextPageButton then
		if iterator > 6 then
			iterator = iterator - 6;
		end
	elseif self == SpellBookPrevPageButton then
		if iterator < 6 then
			iterator = iterator + 6;
		end
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
	if  self:IsVisible() and
		ConsolePort:GetFocusFrame().frame == self and
		not InCombatLockdown() then
		slot = spells[iterator];
		ConsolePort:Highlight(iterator, spells);
		slot:GetScript("OnEnter")(slot);
		local _,_, spellID = SpellBook_GetSpellBookSlot(slot);
		local name = GetSpellInfo(spellID);
		CP_R_RIGHT_NOMOD:SetAttribute("type", "spell");
		CP_R_RIGHT_NOMOD:SetAttribute("spell", name);
		if CP_L_RIGHT_NOMOD.state == KEY.STATE_UP then
			if 	iterator >= 7 and SpellBookNextPageButton:IsEnabled() then
				ConsolePort:SetClickButton(CP_L_RIGHT_NOMOD, SpellBookNextPageButton);
			else
				CP_L_RIGHT_NOMOD:SetAttribute("type", "Book");
			end
		end
		if CP_L_LEFT_NOMOD.state == KEY.STATE_UP then
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
	if key == KEY.PREPARE then iterator = 1;
	elseif 		state == KEY.STATE_DOWN then
		local 	old = iterator;
		if 		key == KEY.UP 	then iterator = iterator - 1;
		elseif	key == KEY.DOWN 	then iterator = iterator + 1;
		elseif 	key == KEY.RIGHT 	then iterator = iterator + 6;
		elseif 	key == KEY.LEFT 	then iterator = iterator - 6; end;
		if iterator < 1 or iterator > 12 then
			iterator = old;
		end
		if not SpellBook_GetSpellBookSlot(spells[iterator]) then
			iterator = old;
		end
		local _,_, spellID = SpellBook_GetSpellBookSlot(slot);
		if 	key == KEY.SQUARE and
			not slot.IsPassive then
			MouselookStop();
			PickupSpell(spellID);
		elseif key == KEY.TRIANGLE then
			local allTabs = { SpellBookSideTabsFrame:GetChildren() };
			local activeTabs = {};
			for i, tab in pairs(allTabs) do
				if not tab.isOffSpec and tab.tooltip then
					tinsert(activeTabs, tab);
				end
			end
			if 		currentTab == 1 then activeTabs[2]:Click();
			elseif 	currentTab == 2 then activeTabs[1]:Click(); end;
			iterator = 1;
		end
	end
end