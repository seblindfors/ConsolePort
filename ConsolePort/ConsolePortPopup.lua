local _
local _, G = ...;
local lootInspect = GroupLootFrame1.IconFrame:GetScript("OnEnter");
local lootLeave   = GroupLootFrame1.IconFrame:GetScript("OnLeave");
local lootHasTooltip = false;
local lootFrames = {
	GroupLootFrame1,
	GroupLootFrame2,
	GroupLootFrame3,
	GroupLootFrame4
}
local popupFrames = {
	StaticPopup1,
	StaticPopup2,
	StaticPopup3,
	StaticPopup4
}

local function HookFadeScripts(table)
	for i, frame in pairs(table) do
		frame:HookScript("OnUpdate", function(self, elapsed)
			if 	self:IsVisible() then
				if table[i+1] and table[i+1]:IsVisible() then
					self:SetAlpha(table[i+1]:GetAlpha()*0.6);
				else
					self:SetAlpha(1);
				end
			end
		end);
	end
end

for i, lootFrame in pairs(lootFrames) do
	lootFrame:HookScript("OnUpdate", function(self, elapsed)
		if 	self:IsVisible() and
			self:GetAlpha() == 1 and
			IsShiftKeyDown() then
			lootInspect(lootFrame.IconFrame);
			lootHasTooltip = true;
		elseif lootHasTooltip then
			lootLeave(lootFrame.IconFrame);
		end
	end);
end

HookFadeScripts(lootFrames);
HookFadeScripts(popupFrames);

function ConsolePort:Popup (key, state)
	local PopupFocus = StaticPopup1;
	if  	StaticPopup4:IsVisible() then PopupFocus = StaticPopup4;
	elseif	StaticPopup3:IsVisible() then PopupFocus = StaticPopup3;
	elseif	StaticPopup2:IsVisible() then PopupFocus = StaticPopup2; end
	PopupFocus:SetAlpha(1);
	ConsolePort:SetClickButton(CP_R_RIGHT_NOMOD, _G[PopupFocus:GetName().."Button2"]);
	ConsolePort:SetClickButton(CP_R_LEFT_NOMOD, _G[PopupFocus:GetName().."Button1"]);
end

function ConsolePort:Loot (key, state)
	local LootFocus = GroupLootFrame1;
	if  	GroupLootFrame4:IsVisible() then LootFocus = GroupLootFrame4;
	elseif	GroupLootFrame3:IsVisible() then LootFocus = GroupLootFrame3;
	elseif	GroupLootFrame2:IsVisible() then LootFocus = GroupLootFrame2; end
	LootFocus:SetAlpha(1);
	ConsolePort:SetClickButton(CP_R_RIGHT_NOMOD, LootFocus.GreedButton);
	ConsolePort:SetClickButton(CP_R_LEFT_NOMOD, LootFocus.NeedButton);
	ConsolePort:SetClickButton(CP_R_UP_NOMOD, LootFocus.PassButton);
	if LootFocus.DisenchantButton:IsVisible() then
		ConsolePort:SetClickButton(CP_L_DOWN_NOMOD, LootFocus.DisenchantButton);
	end
end