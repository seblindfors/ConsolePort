local _
local _, G = ...;
local interval = 0.1;
local frameTimers = { 0,0,0,0,0,0,0,0 };
local groupLootInspect = GroupLootFrame1.IconFrame:GetScript("OnEnter");
local groupLootLeave   = GroupLootFrame1.IconFrame:GetScript("OnLeave");
local lootInspect 	= LootButton1:GetScript("OnEnter");
local lootLeave 	= LootButton1:GetScript("OnLeave");
local lootHasTooltip = false;
local iterator = 1;
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
local lootButtons = {
	LootButton1,
	LootButton2,
	LootButton3,
	LootButton4	
}

function ConsolePort:Popup (key, state) return; end;

local function IsStaticPopup(i) return i>4; end;

local function IsLootFrame(i) return i<=4; end;

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
				if LootFrame:IsVisible() then
					self:SetAlpha(0.5);
				elseif popupFrames[i+1] and popupFrames[i+1]:IsVisible() then
					self:SetAlpha(popupFrames[i+1]:GetAlpha()*0.75);
				elseif not InCombatLockdown() then
					self:SetAlpha(1);
				end
				if 	ConsolePort:GetFocusFrame().frame == self and
					not InCombatLockdown() then
					if IsStaticPopup(i) then
						if 	not ButtonsLinked(CP_R_LEFT_NOMOD, _G[self:GetName().."Button1"]) or
							not PopupTypeAssigned(CP_R_LEFT_NOMOD, "popup") then
							CP_R_RIGHT_NOMOD:SetAttribute("type", "popup");
							CP_R_LEFT_NOMOD:SetAttribute("type", "popup");
							if _G[self:GetName().."Button3"]:IsVisible() then
								ConsolePort:SetClickButton(CP_R_RIGHT_NOMOD, _G[self:GetName().."Button3"]);
							else
								ConsolePort:SetClickButton(CP_R_RIGHT_NOMOD, _G[self:GetName().."Button2"]);
							end
							ConsolePort:SetClickButton(CP_R_LEFT_NOMOD, _G[self:GetName().."Button1"]);
						end
					elseif IsLootFrame(i) then
						if 	IsShiftKeyDown() then
							groupLootInspect(self.IconFrame);
							lootHasTooltip = self;
						elseif lootHasTooltip == self then
							groupLootLeave(self.IconFrame);
							lootHasTooltip = nil;
						end
						if 	not ButtonsLinked(CP_R_UP_NOMOD, self.PassButton) or 
							not PopupTypeAssigned(CP_R_LEFT_NOMOD, "loot") then
							CP_R_RIGHT_NOMOD:SetAttribute("type", "loot");
							CP_R_LEFT_NOMOD:SetAttribute("type", "loot");
							CP_R_UP_NOMOD:SetAttribute("type", "loot");
							CP_L_DOWN_NOMOD:SetAttribute("type", "loot");
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

LootFrameUpButton:HookScript("OnClick", function(_,_,down) if not down then iterator = 3; end; end);
LootFrameDownButton:HookScript("OnClick", function(_,_,down) if not down then iterator = 1; end; end);
LootFrame:HookScript("OnShow", function(self)
	if 	not SpellIsTargeting() and
		not IsMouseButtonDown(1) then
		MouselookStart();
	end
end);
LootFrame:HookScript("OnUpdate", function(self, elapsed)
	if self:IsVisible() then
		if ConsolePort:GetFocusFrame().frame == self then
			self:SetAlpha(1);
			if not InCombatLockdown() then
				if 	not PopupTypeAssigned(CP_R_RIGHT_NOMOD, "loot") or
					not PopupTypeAssigned(CP_L_DOWN_NOMOD, "loot") or
					not PopupTypeAssigned(CP_L_UP_NOMOD, "loot") then
					CP_R_RIGHT_NOMOD:SetAttribute("type", "loot");
					CP_L_DOWN_NOMOD:SetAttribute("type", "loot");
					CP_L_UP_NOMOD:SetAttribute("type", "loot");
				end
			end
			local lootButton = lootButtons[iterator];
			if lootButton:IsVisible() then
				if IsShiftKeyDown() then
					lootInspect(lootButton);
				else
					lootLeave(lootButton);
				end
				ConsolePort:Highlight(iterator, lootButtons);
			end
		else
			self:SetAlpha(0.5);
		end
	end
end);

for i, button in pairs(lootButtons) do
	button:HookScript("OnUpdate", function(self, elapsed)
		if self:IsVisible() then
			if 	lootButtons[iterator] == self then
				self:SetAlpha(1);
			else
				self:SetAlpha(0.5);
			end
		end
	end);
end

function ConsolePort:Loot (key, state)
	if key == G.PREPARE then iterator = 1; return; end;
	if key == G.CIRCLE and lootButtons[iterator]:IsVisible() then
		lootButtons[iterator]:Click();
		return;
	end
	if key == G.UP then 
		if iterator == 1 and LootFrameUpButton:IsVisible() then
			ConsolePort:Button(LootFrameUpButton, state);
		elseif state == G.STATE_UP and iterator ~= 1 then
			iterator = iterator - 1;
		end
	elseif key == G.DOWN then
		if ((iterator < 3) or (iterator == 3 and LootButton4:IsVisible())) and
			state == G.STATE_UP then
			iterator = iterator + 1;
		elseif iterator == 3 and LootFrameDownButton:IsVisible() then
			ConsolePort:Button(LootFrameDownButton, state);
		end
	end
end
