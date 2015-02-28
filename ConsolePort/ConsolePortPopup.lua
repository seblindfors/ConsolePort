local _
local _, G = ...;
local interval = 0.3;
local frameTimers = { 0,0,0,0,0,0,0,0 };
local lootInspect = GroupLootFrame1.IconFrame:GetScript("OnEnter");
local lootLeave   = GroupLootFrame1.IconFrame:GetScript("OnLeave");
local lootHasTooltip = false;
local popupFrames = {
	GroupLootFrame1,
	GroupLootFrame2,
	GroupLootFrame3,
	GroupLootFrame4,
	StaticPopup1,
	StaticPopup2,
	StaticPopup3,
	StaticPopup4
}

local function IsStaticPopup(i) return i>4; end;

local function IsLootFrame(i) return i<=4; end;

local function ButtonsLinked(button, clickbutton)
	return button:GetAttribute("clickbutton") == clickbutton;
end

for i, frame in pairs(popupFrames) do
	frame:HookScript("OnUpdate", function(self, elapsed)
		frameTimers[i] = frameTimers[i] + elapsed;
		while frameTimers[i] > interval do
			if 	self:IsVisible() then
				if popupFrames[i+1] and popupFrames[i+1]:IsVisible() then
					self:SetAlpha(popupFrames[i+1]:GetAlpha()*0.75);
				else
					self:SetAlpha(1);
				end
				if 	self:GetAlpha() == 1 and
					not InCombatLockdown() then
					if IsStaticPopup(i) then
						if not ButtonsLinked(CP_R_RIGHT_NOMOD, _G[self:GetName().."Button2"]) then
							ConsolePort:SetClickButton(CP_R_RIGHT_NOMOD, _G[self:GetName().."Button2"]);
							ConsolePort:SetClickButton(CP_R_LEFT_NOMOD, _G[self:GetName().."Button1"]);
						end
					elseif IsLootFrame(i) then
						if 	IsShiftKeyDown() then
							lootInspect(self.IconFrame);
							lootHasTooltip = self;
						elseif lootHasTooltip == self then
							lootLeave(self.IconFrame);
							lootHasTooltip = nil;
						end
						if not ButtonsLinked(CP_R_UP_NOMOD, self.PassButton) then
							ConsolePort:SetClickButton(CP_R_RIGHT_NOMOD, self.GreedButton);
							ConsolePort:SetClickButton(CP_R_LEFT_NOMOD, self.NeedButton);
							ConsolePort:SetClickButton(CP_R_UP_NOMOD, self.PassButton);
							if self.DisenchantButton:IsVisible() then
								ConsolePort:SetClickButton(CP_L_DOWN_NOMOD, self.DisenchantButton);
							end
						end
					end
				end
			end
			frameTimers[i] = frameTimers[i] - interval;
		end
	end);
end

function ConsolePort:Popup (key, state)
	return;
end

function ConsolePort:Loot (key, state)
	return;
end
