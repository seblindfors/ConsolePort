local _, L = ...
local UI, Control, db = ConsolePortUI:GetEssentials()
local KEY = db.KEY
local LootButton = {}
L.LootButton = LootButton

local LOOT_PASS, LOOT_NEED, LOOT_GREED, LOOT_DISENCHANT = 0, 1, 2, 3

function LootButton:OnClick()
	RollOnLoot(self.Obj.rollID, LOOT_GREED)
end

function LootButton:OnCircleClicked(button, down)
	RollOnLoot(self.Obj.rollID, LOOT_DISENCHANT)
end

function LootButton:OnSquareClicked(button, down)
	RollOnLoot(self.Obj.rollID, LOOT_NEED)
end

function LootButton:OnTriangleClicked(button, down)
	RollOnLoot(self.Obj.rollID, LOOT_PASS)
end

function LootButton:ResetRollOptions()
	self.canNeed = false
	self.canGreed = false
	self.canDisenchant = false
end

function LootButton:OnEnter()
	self:LockHighlight()
	db.UIFrameFadeIn(self.Hilite, 0.15, self.Hilite:GetAlpha(), 1)

	Control:ResetHintBar()
	local rollID = self.Obj.rollID
	if rollID then
		if self.canGreed then
			Control:AddHint(KEY.CROSS, GREED)
		end
		if self.canNeed then
			Control:AddHint(KEY.SQUARE, NEED)
		end
		if self.canDisenchant then
			Control:AddHint(KEY.TRIANGLE, ROLL_DISENCHANT)
		end
		Control:AddHint(KEY.TRIANGLE, PASS)
		GameTooltip:SetOwner(self, 'ANCHOR_BOTTOM')
		GameTooltip:SetLootRollItem(rollID)
	end
end

function LootButton:OnLeave()
	self:UnlockHighlight()
	db.UIFrameFadeOut(self.Hilite, 0.2, self.Hilite:GetAlpha(), 0)
	GameTooltip:Hide()
	Control:ResetHintBar()
end

function LootButton:OnUpdate()
	local rollID = self.Obj.rollID
	self:UpdateTimer(rollID)
	if rollID then
		if ( GameTooltip:IsOwned(self) ) then
			GameTooltip:SetOwner(self, 'ANCHOR_BOTTOM')
			GameTooltip:SetLootRollItem(rollID)
			if self.tooltipLines then
				for _, line in pairs(self.tooltipLines) do
					GameTooltip:AddLine(line)
				end
				GameTooltip:Show()
			end
		end
	end
end

function LootButton:OnHide()
	self:OnLeave()
	db.UIFrameFadeOut(self, 0.1, self.Hilite:GetAlpha(), 0)
end

function LootButton:Animate()
	local id = self:GetID() or 1
	C_Timer.After(id * 0.01, function()
		db.UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
	end)
end

function LootButton:UpdateItemQuality(quality)
	local color = ITEM_QUALITY_COLORS[quality]
	self.Label:SetVertexColor(color.r, color.g, color.b)
	self.HighlightTexture:SetVertexColor(color.r, color.g, color.b)
	self.Mask:SetAtlas(LOOT_BORDER_BY_QUALITY[quality] or LOOT_BORDER_BY_QUALITY[LE_ITEM_QUALITY_UNCOMMON])
end

function LootButton:UpdateTimer(rollID)
	if rollID then
		local left = GetLootRollTimeLeft(rollID)
		local min, max = self.Timer:GetMinMaxValues()
		if ( (left < min) or (left > max) ) then
			left = min
		end
		self.Timer:Show()
		self.Timer:SetValue(left)
	else
		self.Timer:Hide()
	end
end

function LootButton:OnShow()
	local 	texture, name, count, quality, bindOnPickUp, 
			canNeed, canGreed, canDisenchant,
			reasonNeed, reasonGreed, reasonDisenchant, deSkillRequired = GetLootRollItemInfo(self.Obj.rollID or -1)
	if (name == nil) then
		return
	end

	self:OnLeave()
	self:Animate()
	self:ResetRollOptions()
	self:UpdateItemQuality(quality)

	self.Icon:SetTexture(texture)
	self:SetText(name)

	self.tooltipLines = {}

--	if ( count > 1 ) then
--		self.IconFrame.Count:SetText(count)
--		self.IconFrame.Count:Show()
--	else
--		self.IconFrame.Count:Hide()
--	end

	if ( canNeed ) then
		self.canNeed = true
	else
		self.tooltipLines[#self.tooltipLines + 1] = _G['LOOT_ROLL_INELIGIBLE_REASON'..reasonNeed]
	end
	if ( canGreed) then
		self.canGreed = true
	else
		self.tooltipLines[#self.tooltipLines + 1] = _G['LOOT_ROLL_INELIGIBLE_REASON'..reasonGreed]
	end
	if ( canDisenchant) then
		self.canDisenchant = true
	else
		self.tooltipLines[#self.tooltipLines + 1] = format(_G['LOOT_ROLL_INELIGIBLE_REASON'..reasonDisenchant], deSkillRequired)
	end
--	self.Timer:SetFrameLevel(self:GetFrameLevel() - 1);
end

function LootButton:OnLoad()
	L.Button.OnLoad(self)

	ConsolePort:RemoveFrame(self.Obj)

	self.HighlightTexture:SetTexCoord(0, 0.640625, 0, 1)
	self.HighlightTexture:SetTexture([[Interface\AddOns\ConsolePort\Textures\Window\Highlight]])

	self.Timer = CreateFrame('StatusBar', '$parentTimer', self)
	self.Timer:SetSize(190, 8)
	self.Timer:SetPoint('BOTTOM', 0, 2)
	self.Timer:SetMinMaxValues(0, 60000)
	self.Timer:SetStatusBarTexture([[Interface\PaperDollInfoFrame\UI-Character-Skills-Bar]])
	self.Timer:SetStatusBarColor(1, 1, 1)
end


L.lootButtonProbeScript = [[
local count = ...
local isShown = count and count > 0
local lootHeader = self:GetParent()
local menuParent = lootHeader:GetParent()
if isShown then 
	self:SetAttribute('condition', 'return true')
else
	self:Hide()
	self:SetAttribute('condition', 'return false')
end
if lootHeader:GetAttribute('focused') and menuParent:IsVisible() then
	local numLootButtons = lootHeader:GetAttribute('pc') or 0
	if numLootButtons < 2 and not isShown then
		menuParent:RunAttribute('SetHeaderID', 4)
	end
	menuParent:RunAttribute('_onshow')
end
]]

L.lootHeaderOnSetScript = [[
local highestIndex, prevButton, currButton = 0
for i=1,4 do
	currButton = self:GetFrameRef(tostring(i))
	if currButton:GetAttribute('pc') > 0 then
		currButton:ClearAllPoints()
		if prevButton then 
			currButton:SetPoint("TOP", prevButton, "BOTTOM", 0, 0)
		else 
			currButton:SetPoint("TOP", self, "BOTTOM", -90, -16)
		end 
		prevButton = currButton 
		highestIndex = i
	end 
end 
return highestIndex
]]