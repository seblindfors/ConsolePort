local _, L = ...
local UI, Control, Data = ConsolePortUI:GetEssentials()
local KEY = Data.KEY
local LootFrame, focusButton = {}
L.LootFrameLogicMixin = LootFrame

function LootFrame:LOOT_READY(...)
	if GetNumLootItems() < 1 then
		CloseLoot()
	else
		self:UpdateItems(true)
	end
end

function LootFrame:LOOT_SLOT_CLEARED(...)
	self:UpdateItems()
end

function LootFrame:LOOT_SLOT_CHANGED(...)
	self:UpdateItems()
end

function LootFrame:MODIFIER_STATE_CHANGED(...)
end

function LootFrame:OnShow()
	Control:AddHint(KEY.CROSS, LOOT)
	Control:AddHint(KEY.CIRCLE, ALL)
	Control:AddHint(KEY.TRIANGLE, CLOSE)

	self.Container.Header.HeaderOpenAnim:Stop()
	self.Container.Header.HeaderOpenAnim:Play()
end

function LootFrame:OnHide()
	self.Container.Header.HeaderOpenAnim:Finish()
	self.idx = 1
	if focusButton then
		focusButton:OnLeave()
	end
end

function LootFrame:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

function LootFrame:UpdateItems(fadeOnShow)
	self.itemPool:ReleaseAll()
	wipe(self.active)

	local prevButton
	local numLootItems = GetNumLootItems()

	for i = 1, GetNumLootItems() do
		if GetLootSlotInfo(i) then
			local button = self.itemPool:Acquire()
			button:SetID(i)
			button:Show()
			button:Update()

			if fadeOnShow then
				Data.UIFrameFadeIn(button, 0.3, 0, 1)
			end

			self.active[#self.active + 1] = button

			if prevButton then
				button:SetPoint('TOPRIGHT', prevButton.NameFrame, 'BOTTOMLEFT', 36, -4)
			else
				button:SetPoint('TOPLEFT', 0, -8)
			end
			prevButton = button
		end
	end
	self.Container:AdjustHeight(self.itemPool.numActiveObjects * 52)
	self:UpdateFocus(self.idx)
end

function LootFrame:UpdateFocus(index, delta)
	if delta then
		index = index + delta
	end
	local numActiveObjects = self.itemPool.numActiveObjects
	self.idx = index > numActiveObjects and numActiveObjects or index < 1 and 1 or index
	self:SetFocus(self.idx)
end

function LootFrame:SetFocus(index)
	if focusButton then
		focusButton:OnLeave()
		focusButton = nil
	end
	local button = self.active[index]
	if button then
		focusButton = button
		button:OnEnter()
	end
end

function LootFrame:LootAllItems()
	for i = GetNumLootItems(), 1, -1 do
		LootSlot(i)
	end
end

function LootFrame:OnInput(key, down)
	key = tonumber(key)
	if down then
		if key == KEY.UP then
			self:UpdateFocus(self.idx, -1)
		elseif key == KEY.DOWN then
			self:UpdateFocus(self.idx, 1)
		elseif key == KEY.CROSS and focusButton then
			focusButton:Click()
		elseif key == KEY.CIRCLE then
			self:LootAllItems()
		elseif 	key == KEY.TRIANGLE or 
				key == KEY.CENTER or 
				key == KEY.OPTIONS or 
				key == KEY.SHARE then
			CloseLoot() 
		end
	end
end

function LootFrame:OnLoad()
	for _, event in pairs({
		'LOOT_READY',
		'LOOT_OPENED',
		'LOOT_SLOT_CLEARED',
		'LOOT_SLOT_CHANGED',
		'LOOT_CLOSED',
		'LOOT_READY',
		'OPEN_MASTER_LOOT_LIST',
		'UPDATE_MASTER_LOOT_LIST',
		'MODIFIER_STATE_CHANGED',
	}) do self:RegisterEvent(event) end
	self.idx = 1
	self.itemPool = UI:CreateFramePool('Button', self.Container, 'CPUISimpleLootButtonTemplate', L.LootButtonMixin)
	self.active = {}
end