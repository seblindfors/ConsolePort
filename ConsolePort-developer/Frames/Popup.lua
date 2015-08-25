local _, db = ...;
local KEY = db.KEY;
local interval = 0.1;
local frameTimers = { 0,0,0,0,0,0,0,0 };
local groupLootInspect = GroupLootFrame1.IconFrame:GetScript("OnEnter");
local groupLootLeave   = GroupLootFrame1.IconFrame:GetScript("OnLeave");
local lootInspect 	= LootButton1:GetScript("OnEnter");
local lootLeave 	= LootButton1:GetScript("OnLeave");
local lootHasTooltip = false;
local iterator = 1;
local popupFrames = {
	-- GroupLootFrame1,
	-- GroupLootFrame2,
	-- GroupLootFrame3,
	-- GroupLootFrame4,
	StaticPopup1,
	StaticPopup2,
	StaticPopup3,
	StaticPopup4
}
local lootButtons = {
	LootButton1,
	LootButton2,
	LootButton3,
	LootButton4	
}

function ConsolePort:Popup (key, state) return; end;

local function ButtonsLinked(button, clickbutton)
	return button:GetAttribute("clickbutton") == clickbutton;
end

local function PopupTypeAssigned(button, type)
	return button:GetAttribute("type") == type;
end

for i, frame in pairs(popupFrames) do
	frame:HookScript("OnUpdate", function(self, elapsed)
		frameTimers[i] = frameTimers[i] + elapsed;
		while frameTimers[i] > interval do
			if 	self:IsVisible() then
				if popupFrames[i+1] and popupFrames[i+1]:IsVisible() then
					self:SetAlpha(popupFrames[i+1]:GetAlpha()*0.75);
				elseif not InCombatLockdown() then
					self:SetAlpha(1);
				end
				if 	ConsolePort:GetFocusFrame().frame == self and
					not InCombatLockdown() then
					if 	not ButtonsLinked(CP_R_LEFT_NOMOD, _G[self:GetName().."Button1"]) or
						not PopupTypeAssigned(CP_R_LEFT_NOMOD, "Popup") then
						ClearOverrideBindings(ConsolePortCursor)
						CP_R_RIGHT_NOMOD:SetAttribute("type", "Popup");
						CP_R_LEFT_NOMOD:SetAttribute("type", "Popup");
						if _G[self:GetName().."Button3"]:IsVisible() then
							ConsolePort:SetClickButton(CP_R_RIGHT_NOMOD, _G[self:GetName().."Button3"]);
						else
							ConsolePort:SetClickButton(CP_R_RIGHT_NOMOD, _G[self:GetName().."Button2"]);
						end
						ConsolePort:SetClickButton(CP_R_LEFT_NOMOD, _G[self:GetName().."Button1"]);
					end
				end
			end
			frameTimers[i] = frameTimers[i] - interval;
		end
	end);
end

-- function ConsolePort:Loot (key, state)
-- 	if key == KEY.PREPARE then iterator = 1; return; end;
-- 	if key == KEY.CIRCLE and lootButtons[iterator]:IsVisible() then
-- 		lootButtons[iterator]:Click();
-- 		return;
-- 	end
-- 	if key == KEY.UP then 
-- 		if iterator == 1 and LootFrameUpButton:IsVisible() then
-- 			ConsolePort:Button(LootFrameUpButton, state);
-- 		elseif state == KEY.STATE_UP and iterator ~= 1 then
-- 			iterator = iterator - 1;
-- 		end
-- 	elseif key == KEY.DOWN then
-- 		if ((iterator < 3) or (iterator == 3 and LootButton4:IsVisible())) and
-- 			state == KEY.STATE_UP then
-- 			iterator = iterator + 1;
-- 		elseif iterator == 3 and LootFrameDownButton:IsVisible() then
-- 			ConsolePort:Button(LootFrameDownButton, state);
-- 		end
-- 	end
-- end
