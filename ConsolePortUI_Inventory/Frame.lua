local _, L = ...
local UI = ConsolePortUI
local Mixin = UI.Utils.Mixin

local frame = UI:CreateFrame('Frame', _, UIParent, 'SecureHandlerBaseTemplate, SecureHandlerShowHideTemplate, SecureHandlerStateTemplate', {
	Active = {},
})

frame:Execute([[
	-------------------------
	activeItems = newtable()
	-------------------------
	bID = 1
	gridSize = 0
	numActive = 0
	-------------------------
]])

for name, script in pairs({

	_onshow = [[
		numActive = self:RunAttribute('UpdateActive')
	 	gridSize = self:RunAttribute('CalculateGrid', numActive)

		self:RunAttribute('AdjustBags', gridSize)
		self:RunAttribute('SetCurrent', bID)
		self:CallMethod('Update')
	]],

	__onhide = [[
		print('Hiding away...')
	]],

	OnInput = [[
		local key, down = ...
		local currentID = bID

		-- Click on a button
		if key == CROSS and current then
			current:CallMethod('SetButtonState', down and 'PUSHED' or 'NORMAL')
			if not down then
				self:GetFrameRef('control'):SetAttribute('macrotext', '/click ' .. current:GetName())
			end
		elseif ( key == CENTER or key == OPTIONS or key == SHARE ) and down then
			self:CallMethod('Close')

		-- Up/down
		elseif key == UP and down and ( bID - gridSize ) >= 1 then
			bID = bID - gridSize
		elseif key == DOWN and down and ( bID + gridSize ) <= numActive then
			bID = bID + gridSize


		-- Left/right
		elseif key == LEFT and down and bID > 1 then
			bID = bID - 1
		elseif key == RIGHT and down and bID < numActive then
			bID = bID + 1
		end

		if bID > numActive then
			bID = numActive
		end

		if bID ~= currentID then
			self:RunAttribute('SetCurrent', bID)
		end

		-- Play a notification sound when inputting
		if down then
			self:CallMethod('OnButtonPressed')
		end
	]],

	AdjustBags = [[
		local gridSize = ...
		local sz = 42

		for bagID=0, 12 do
			local original = self:GetFrameRef('container'..bagID)
			original:SetWidth(0)
			original:SetHeight(0)
		end

		for idx, button in pairs(activeItems) do
			button:ClearAllPoints()
			button:SetWidth(sz)
			button:SetHeight(sz)

			button:SetPoint('TOPLEFT', self, 'TOPLEFT', 
				((idx-1) % gridSize) * (sz + 4), 
				-((ceil(idx/gridSize) - 1) * (sz + 4)) )

		end

		self:SetWidth(gridSize * sz)
		self:SetHeight(ceil(#activeItems/gridSize) * sz)
	]],

	SetCurrent = [[
		local id = ...
		if id then
			current = activeItems[id]
			if current then
				self:CallMethod('OnButtonFocused', current:GetName())
			end
		end
	]],

	UpdateActive = [[
		wipe(activeItems)
		for i=1, 468 do
			local button = self:GetFrameRef(tostring(i))
			if button:IsVisible() then
				self:CallMethod('OnButtonShow', button:GetName())
				activeItems[#activeItems + 1] = button
			end
		end
		return #activeItems
	]],

	CalculateGrid = [[
		local numItems = ...
		local root = floor(math.sqrt(numItems))
		local startPoint = root + floor(root/2)
		for i=startPoint, 4, -1 do
			if numItems % i == 0 or (i == root) then
				return i
			end
		end
		return startPoint
	]],

}) do frame:SetAttribute(name, script) end


do
	frame:Hide()
	frame:SetPoint('CENTER')
	frame:SetFrameStrata('HIGH')
	frame:SetSize(1, 1)
	UI:RegisterFrame(frame, 'Inv', nil, true)

	Mixin(frame, L.InventoryMixin)

	for bag = 0, 12 do
		local container = _G['ContainerFrame' .. (bag + 1)]
		UI:CreateProbe(frame, container, 'showhide')
		UI:HideFrame(container)

		frame:SetFrameRef('container' .. bag, container)

		for slot = 1, 36 do
			local id = ((bag)*36) + slot
			local button = _G['ContainerFrame' .. (bag+1) .. 'Item' .. slot]
			local secureButton = CreateFrame('Button', _..'Item'..id, frame, 'ItemButtonTemplate, SecureActionButtonTemplate')

			secureButton:SetAttribute('type', 'item')
			secureButton:SetAttribute('bag', bag)
			secureButton:SetAttribute('slot', slot)
			secureButton:Hide()

			UI:CreateProbe(secureButton, button, 'showhide')
			frame:SetFrameRef( tostring(id), secureButton)

		end
	end
end