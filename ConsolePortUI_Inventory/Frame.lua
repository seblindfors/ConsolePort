local _, L = ...
local UI = ConsolePortUI
local Mixin = ConsolePort:GetData().table.mixin

local frame = UI:CreateFrame('Frame', _, UIParent, 'CPUIFrameTemplate, SecureHandlerBaseTemplate, SecureHandlerShowHideTemplate, SecureHandlerStateTemplate', {
	SetMovable = true,
	EnableMouse = true,
	RegisterForDrag = 'LeftButton',
	{
		Active = {},
		MoneyFrame = {
			Type = 'Frame',
			Setup = {'SmallMoneyFrameTemplate'},
			Show = true,
			Clear = true,
			Point = {'TOPRIGHT', -24, -24},
		},
	}
})

frame:SetScript('OnDragStart', frame.StartMoving)
frame:SetScript('OnDragStop', frame.StopMovingOrSizing)
frame:Execute([[
	-------------------------
	activeItems = newtable()
	-------------------------
	bID = 1
	gridSize = 0
	numActive = 0
	-------------------------
]])

for state, driver in pairs({
	combat = {
		condition = '[combat] true; nil',
		script = [[
			inCombat = newstate
		]],
	},
}) do 
	RegisterStateDriver(frame, state, driver.condition)
	frame:SetAttribute('_onstate-'..state, driver.script)
end

for name, script in pairs({

	_onshow = [[
		numActive = self:RunAttribute('UpdateActive')
	 	gridSize = self:RunAttribute('CalculateGrid', numActive)

		self:RunAttribute('AdjustBags', gridSize)
		self:RunAttribute('SetCurrent', bID)
		self:CallMethod('Update')
	]],

	__onhide = [[
		--print('Hiding away...')
	]],

	OnInput = [[
		local key, down = ...
		local returnHandler, returnValue
		local currentID = bID

		-------------------------
		-- Click on a button
		if key == CROSS and current then
			current:CallMethod('SetButtonState', down and 'PUSHED' or 'NORMAL')
			if not down then
				returnHandler, returnValue = 'macrotext', '/click ' .. current:GetName()
			--	self:GetFrameRef('control'):SetAttribute('macrotext', )
			end

		-------------------------

		elseif key == SQUARE and current then
			if not down then
				current:CallMethod('OnModifiedClick')
			end

		-------------------------

		-- Close the bags
		elseif ( key == CENTER or key == OPTIONS or key == SHARE ) and down then
			for bagID=0, 12 do
				local original = self:GetFrameRef('container'..bagID)
				original:Hide()
			end

		elseif ( key == CIRCLE ) then
			if not inCombat then
				if down then
					cachedPickupSlot = bID
				else
					if cachedPickupSlot == bID then
						self:CallMethod('PickupItem', current:GetName())
					elseif cachedPickupSlot then
						self:CallMethod('MoveItem', activeItems[cachedPickupSlot]:GetName(), current:GetName())
					end
				end
			else
				cachedPickupSlot = nil
			end

		-------------------------

		-- Up/down
		elseif key == UP and down then
			if ( bID - gridSize ) >= 1 then 
				bID = bID - gridSize
			else
				bID = numActive - (gridSize - bID)
			end
		elseif key == DOWN and down then
			if ( bID + gridSize ) <= numActive then
				bID = bID + gridSize
			else
				bID = bID % gridSize
			end


		-- Left/right
		elseif key == LEFT and down then
			if bID > 1 then
				bID = bID - 1
			else
				bID = numActive
			end
		elseif key == RIGHT and down then
			if bID < numActive then 
				bID = bID + 1
			else
				bID = 1
			end
		end
		
		-------------------------

		-- Assert bID within range 
		if bID > numActive then
			--print(format("Button ID %d is above threshold %d. Setting to max.", bID, numActive))
			bID = numActive
		end

		-------------------------

		-- Update the callback attribute if bID changed
		if bID ~= currentID then
			self:RunAttribute('SetCurrent', bID)
		end

		-------------------------

		-- Play a notification sound when inputting
		if down then
			self:CallMethod('OnButtonPressed')
		end

		return 'macro', returnHandler, returnValue
		-------------------------
	]],

	AdjustBags = [[
		local gridSize = ...
		local sz = 42
		local realSz = sz + 0

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
				((idx-1) % gridSize) * (realSz) + 12, 
				-((ceil(idx/gridSize) - 1) * (realSz)) -12 - 60)

		end
		self:SetWidth(gridSize * (realSz) + 20)
		self:SetHeight(ceil(#activeItems/gridSize) * (realSz) + 36 + 54)
	--	print("Active items:", numActive, #activeItems)
	--	print("Grid size:", gridSize)
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

do  -- Bag setup 
	-------------------------
	frame:Hide()
	frame:SetPoint('BOTTOM', 0, 100)
	frame:SetFrameStrata('HIGH')
	frame:SetSize(1, 1)

	frame:SetIcon([[Interface\Icons\INV_Misc_Bag_29]])
	frame:SetTitle(INVENTORY_TOOLTIP)

	UI.Media:SetBackdrop(frame, 'GOSSIP_BG')
	UI:RegisterFrame(frame, 'Inv', nil, true)

	Mixin(frame, L.InventoryMixin)
	frame:OnLoad()
	-------------------------
	local ItemButtonMixin = L.ItemButtonMixin

	-------------------------------------------------
	-- Hook the individual bag frames in order to provide
	-- a show/hide event for the container frame.
	-- Show if any bag is shown, hide if all bags are hidden.
	-------------------------------------------------
	for bag = 0, 12 do
		local container = _G['ContainerFrame' .. (bag + 1)]
		UI:CreateProbe(frame, container, 'showhide')
		UI:HideFrame(container)

		frame:SetFrameRef('container' .. bag, container)
		-------------------------------------------------
		-- Create secure item buttons and hook them to show
		-- when the probed originals are shown, allowing
		-- the container to adapt dynamically to how many
		-- items are shown at a given time.
		-------------------------------------------------
		for slot = 1, 36 do
			local id = ((bag)*36) + slot
			local button = _G['ContainerFrame' .. (bag+1) .. 'Item' .. slot]
			local secureButton = CreateFrame('ItemButton', _..'Item'..id, frame, 'CPUIInventoryItemButtonTemplate, SecureActionButtonTemplate')

			secureButton:SetAttribute('type', 'item')
			secureButton:SetAttribute('bag', bag)
			secureButton:SetAttribute('slot', slot)
			secureButton:Hide()

			Mixin(secureButton, ItemButtonMixin)

			UI:CreateProbe(secureButton, button, 'showhide')
			frame:SetFrameRef( tostring(id), secureButton)

		end
	end
end