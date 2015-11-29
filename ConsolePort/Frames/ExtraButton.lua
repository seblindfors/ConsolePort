---------------------------------------------------------------
-- ExtraButton.lua: Custom extra button to quick bind items
---------------------------------------------------------------
-- Creates an extra button that will automatically bind quest
-- items from the objective tracker. The user may also manually
-- assign items from container buttons inside bag frames.
-- Pretty stupid behaviour at the moment.

local Extra
local watchQuests = {}
local questItem

local function OnUpdate(self, elapsed)
	if not self.itemID and not self.forceShow and not InCombatLockdown() then
		self:Hide()
	end
	if 	self.glow and self.glow > 0 then
		self.glow = self.glow - elapsed
	elseif self.glow then
		self.glow = nil
	end
end

local function UpdateItem(self)
	if 	not self.forceShow then
		local count = GetItemCount(self:GetAttribute("item"))
		if count < 1 then
			if ConsolePortSettings.autoExtra then
				self:CheckQuest()
			else
				self:UpdateButton()
			end
		elseif self.itemID then
			local time, cooldown, _ = GetItemCooldown(self.itemID)
			self.cooldown:SetCooldown(time, cooldown)
		end
	end
end

local function OnEvent(self, event, ...)
	if event == "PLAYER_REGEN_DISABLED" then
		self:RegisterForDrag()
	elseif event == "PLAYER_REGEN_ENABLED" then
		self:RegisterForDrag("LeftButton")
	elseif 	event == "QUEST_LOG_UPDATE" or
			event == "BAG_UPDATE" or
			event == "BAG_UPDATE_COOLDOWN" then
		self:UpdateItem()
	end
end

local function OnEnter(self)
	if self.itemID then
		GameTooltip:SetOwner(self)
		GameTooltip:ClearLines()
		GameTooltip:SetItemByID(self.itemID)
		GameTooltip:Show()
	end
end

local function OnLeave(self)
	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide()
	end
end

local function CheckQuest(self)
	local count = 0
	watchQuests = {}
	for i=1, GetNumQuestWatches() do
		tinsert(watchQuests, GetQuestIndexForWatch(i))
	end
	for _, i in pairs(watchQuests) do
		if GetQuestLogSpecialItemInfo(i) then
			count = count + 1
			if not questItem then
				questItem = GetQuestLogSpecialItemInfo(i)
			end
		end
	end
	if count == 1 then
		self:UpdateButton(questItem)
	else
		self:UpdateButton()
	end
end

local function ForceShow(self, force)
	if force then
		self.forceShow = true
		self:Show()
	else
		self.forceShow = false
	end
end

local function CreateExtraButton()
	local extra = CreateFrame("BUTTON", "ConsolePortExtraButton", UIParent, "SecureActionButtonTemplate, ActionButtonTemplate")

	extra.Update = OnUpdate
	extra.ForceShow = ForceShow
	extra.UpdateItem = UpdateItem
	extra.CheckQuest = CheckQuest
	extra.UpdateButton = ConsolePort.UpdateExtraButton

	extra:SetMovable(true)
	extra:RegisterForDrag("LeftButton")
	extra:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	extra:RegisterEvent("PLAYER_REGEN_ENABLED")
	extra:RegisterEvent("PLAYER_REGEN_DISABLED")
	extra:RegisterEvent("QUEST_LOG_UPDATE")
	extra:RegisterEvent("BAG_UPDATE")
	extra:RegisterEvent("BAG_UPDATE_COOLDOWN")
	extra:SetScript("OnDragStart", extra.StartMoving)
	extra:SetScript("OnDragStop", extra.StopMovingOrSizing)
	extra:SetScript("OnUpdate", OnUpdate)
	extra:SetScript("OnEvent", OnEvent)
	extra:SetScript("OnEnter", OnEnter)
	extra:SetScript("OnLeave", OnLeave)
	extra:HookScript("OnDragStart", OnLeave)
	extra:SetSize(52, 52)
	extra:SetPoint("BOTTOM", ExtraActionButton1, "TOP", 0, 30)
	extra:SetAttribute("type", "item")

	extra.cooldown = CreateFrame("COOLDOWN", nil, extra, "CooldownFrameTemplate")
	extra.cooldown:SetAllPoints(extra)
	extra.cooldown:SetSize(52,52)

	extra.style = extra:CreateTexture(nil, "OVERLAY", nil, 0)
	extra.style:SetSize(256,128)
	extra.style:SetPoint("CENTER", extra, "CENTER", -2, 0)
	extra.style:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\ExtraButton"..(ConsolePortSettings.type == "PS4" and "PS4" or "Xbox"))

	extra.quest = extra:CreateTexture(nil, "OVERLAY", nil, 7)
	extra.quest:SetSize(64,64)
	extra.quest:SetPoint("CENTER", extra, "CENTER", 0, -26)
	extra.quest:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\QuestButton")

	CreateExtraButton = nil

	return extra
end

function ConsolePort:UpdateExtraButton(item)
	if not InCombatLockdown() then
		if not Extra then
			Extra = CreateExtraButton()
		end
		if 	item and GetItemCount(item) > 0 and GetItemInfo(item) ~= Extra:GetAttribute("item") then
			local name, link, _, _, _, class, sub, _, _, texture = GetItemInfo(item)
			local _, itemID = strsplit(":", strmatch(link, "item[%-?%d:]+"))
			Extra.itemID = itemID 
			Extra.quest:SetShown(class=="Quest")
			Extra.glow = 1
			Extra:SetAttribute("item", link)
			Extra.icon:SetTexture(texture)
			Extra:SetAlpha(1)
			Extra:Show()
			Extra:UpdateItem()
		else
			Extra.itemID = nil
			Extra.icon:SetTexture(nil)
			Extra:SetAttribute("item", nil)
			Extra:Hide()
		end
	end
end
