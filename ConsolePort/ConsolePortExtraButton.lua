local _, G = ...;
local KEY = G.KEY;
local watchQuests = {};
local questItem = nil;

local function OnUpdate(self, elapsed)
	if not self.itemID and not self.forceShow and not InCombatLockdown() then
		self:Hide();
	end
	if 	self.glow and self.glow > 0 then
		self.glow = self.glow - elapsed;
	elseif self.glow then
		ActionButton_HideOverlayGlow(self);
		self.glow = nil;
	end
end

local function UpdateItem(self)
	if 	not self.forceShow then
		local count = GetItemCount(self:GetAttribute("item"));
		if count < 1 then
			if ConsolePortSettings.autoExtra then
				self:CheckQuest();
			else
				self:UpdateButton();
			end
		elseif self.itemID then
			local time, cooldown, _ = GetItemCooldown(self.itemID);
			self.cooldown:SetCooldown(time, cooldown);
		end
	end
end

local function OnEvent(self, event, ...)
	if event == "PLAYER_REGEN_DISABLED" then
		self:RegisterForDrag();
	elseif event == "PLAYER_REGEN_ENABLED" then
		self:RegisterForDrag("LeftButton");
	elseif 	event == "QUEST_LOG_UPDATE" or
			event == "BAG_UPDATE" or
			event == "BAG_UPDATE_COOLDOWN" then
		self:UpdateItem();
	end
end

local function OnEnter(self)
	if self.itemID then
		GameTooltip:SetOwner(self);
		GameTooltip:ClearLines();
		GameTooltip:SetItemByID(self.itemID);
		GameTooltip:Show();
	end
end

local function OnLeave(self)
	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
	end
end

local function CheckQuest(self)
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
	local c = CreateFrame("COOLDOWN", nil, f, "CooldownFrameTemplate");
	local t = f:CreateTexture(nil, "OVERLAY", nil, 0);
	local q = f:CreateTexture(nil, "OVERLAY", nil, 7);
	f.Update = OnUpdate;
	f.ForceShow = ForceShow;
	f.UpdateItem = UpdateItem;
	f.CheckQuest = CheckQuest;
	f.UpdateButton = ConsolePort.UpdateExtraButton;
	f:SetMovable(true);
	f:RegisterForDrag("LeftButton");
	f:RegisterEvent("PLAYER_REGEN_ENABLED");
	f:RegisterEvent("PLAYER_REGEN_DISABLED");
	f:RegisterEvent("QUEST_LOG_UPDATE");
	f:RegisterEvent("BAG_UPDATE");
	f:RegisterEvent("BAG_UPDATE_COOLDOWN");
	f:SetScript("OnDragStart", f.StartMoving);
	f:SetScript("OnDragStop", f.StopMovingOrSizing);
	f:SetScript("OnUpdate", OnUpdate);
	f:SetScript("OnEvent", OnEvent);
	f:SetScript("OnEnter", OnEnter);
	f:SetScript("OnLeave", OnLeave);
	f:HookScript("OnDragStart", OnLeave);
	f:SetSize(52, 52);
	f:SetPoint("BOTTOM", ExtraActionButton1, "TOP", 0, 30);
	f:SetAttribute("type", "item");
	f.style = t;
	f.quest = q;
	f.cooldown = c;
	t:SetSize(256,128);
	t:SetPoint("CENTER", f, "CENTER", -2, 0);
	t:SetTexture("Interface\\AddOns\\ConsolePort\\Graphic\\ExtraButton"..ConsolePortSettings.type);
	q:SetSize(64,64);
	q:SetPoint("CENTER", f, "CENTER", 0, -26);
	q:SetTexture("Interface\\AddOns\\ConsolePort\\Graphic\\QuestButton");
	c:SetAllPoints(f);
	c:SetSize(52,52);
	return f;
end

function ConsolePort:UpdateExtraButton(item)
	if not InCombatLockdown() then
		local Extra = ConsolePortExtraButton or CreateExtraButton();
		if 	item and GetItemCount(item) > 0 and GetItemInfo(item) ~= Extra:GetAttribute("item") then
			local name, link, _, _, _, class, sub, _, _, texture = GetItemInfo(item);
			local _, itemID = strsplit(":", strmatch(link, "item[%-?%d:]+"));
			Extra.itemID = itemID; 
			Extra.quest:SetShown(class=="Quest");
			Extra.glow = 1;
			Extra:SetAttribute("item", name);
			Extra.icon:SetTexture(texture);
			Extra:SetAlpha(1);
			Extra:Show();
			Extra:UpdateItem();
			ActionButton_ShowOverlayGlow(Extra);
		else
			Extra.itemID = nil;
			Extra.icon:SetTexture(nil);
			Extra:SetAttribute("item", nil);
			Extra:Hide();
		end
	end
end
