local _, G = ...;
local watchQuests = {};
local questItem = nil;

local function OnUpdate(self, elapsed)
	self.timer = self.timer + elapsed;
	while self.timer > 0.5 do
		if not InCombatLockdown() and not self.forceShow then
			local count = GetItemCount(self:GetAttribute("item"));
			if count < 1 then
				if ConsolePortSettings.autoExtra then
					self:CheckQuest();
				else
					self:UpdateButton();
				end
			end
		end
		self.timer = self.timer - 0.5;
	end
	if 	self.glow and self.glow > 0 then
		self.glow = self.glow - elapsed;
	elseif self.glow then
		ActionButton_HideOverlayGlow(self);
		self.glow = nil;
	end
end

local function OnEvent(self, event, ...)
	if event == "PLAYER_REGEN_DISABLED" then
		self:RegisterForDrag();
	elseif event == "PLAYER_REGEN_ENABLED" then
		self:RegisterForDrag("LeftButton");
	elseif event == "QUEST_LOG_UPDATE" then
		self:Update(1);
	end
end

local function CheckQuest(self)
	if not InCombatLockdown() then
		watchQuests, count = {}, 0;
		for i=1, GetNumQuestWatches() do
			tinsert(watchQuests, GetQuestIndexForWatch(i));
		end
		for _, i in pairs(watchQuests) do
			if GetQuestLogSpecialItemInfo(i) then
				count = count + 1;
				if not questItem then
					questItem = GetQuestLogSpecialItemInfo(i);
				end
			end
		end
		if count == 1 then
			self:UpdateButton(questItem);
		else
			self:UpdateButton();
		end
	end
end

local function ForceShow(self, force)
	if force then
		self.forceShow = true;
		self:Show();
	else
		self.forceShow = false;
	end
end

local function CreateExtraButton()
	local f = CreateFrame("BUTTON", "ConsolePortExtraButton", UIParent, "SecureActionButtonTemplate, ActionButtonTemplate");
	local t = f:CreateTexture(nil, "OVERLAY", nil, 0);
	local q = f:CreateTexture(nil, "OVERLAY", nil, 1);
	f.timer = 0;
	f.Update = OnUpdate;
	f.ForceShow = ForceShow;
	f.CheckQuest = CheckQuest;
	f.UpdateButton = ConsolePort.UpdateExtraButton;
	f:SetMovable(true);
	f:RegisterForDrag("LeftButton");
	f:RegisterEvent("PLAYER_REGEN_ENABLED");
	f:RegisterEvent("PLAYER_REGEN_DISABLED");
	f:RegisterEvent("QUEST_LOG_UPDATE");
	f:SetScript("OnDragStart", f.StartMoving);
	f:SetScript("OnDragStop", f.StopMovingOrSizing);
	f:SetScript("OnUpdate", OnUpdate);
	f:SetScript("OnEvent", OnEvent);
	f:SetSize(52, 52);
	f:SetPoint("BOTTOM", ExtraActionButton1, "TOP", 0, 30);
	f:SetAttribute("type", "item");
	f.style = t;
	f.quest = q;
	t:SetSize(256,128);
	t:SetPoint("CENTER", f, "CENTER", -2, 0);
	t:SetTexture("Interface\\AddOns\\ConsolePort\\Graphic\\ExtraButton"..ConsolePortSettings.type);
	q:SetSize(64,64);
	q:SetPoint("CENTER", f, "CENTER", 0, -26);
	q:SetTexture("Interface\\AddOns\\ConsolePort\\Graphic\\QuestButton");
	return f;
end

function ConsolePort:UpdateExtraButton(item)
	local Extra = ConsolePortExtraButton or CreateExtraButton();
	if item and GetItemCount(item) > 0 and GetItemInfo(item) ~= Extra:GetAttribute("item") then
		local name, _, _, _, _, class, sub, _, _, texture = GetItemInfo(item);
		Extra.quest:SetShown(class=="Quest");
		Extra.glow = 1;
		Extra:SetAttribute("item", name);
		Extra.icon:SetTexture(texture);
		Extra:SetAlpha(1);
		Extra:Show();
		ActionButton_ShowOverlayGlow(Extra);
	else
		Extra.icon:SetTexture(nil);
		Extra:SetAttribute("item", nil);
		Extra:Hide();
	end
end