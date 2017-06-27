local _, L = ...
local UI = ConsolePortUI
local Mixin = UI.Utils.Mixin

local frame = UI:CreateFrame('Frame', _, UIParent, 'CPUIFrameTemplate, SecureHandlerBaseTemplate, SecureHandlerShowHideTemplate, SecureHandlerStateTemplate', {
	MoneyFrame = {
		Type = 'Frame',
		Setup = {'SmallMoneyFrameTemplate'},
		Show = true,
		Clear = true,
		Point = {'TOPRIGHT', -24, -24},
	},
	Bags = {
		Type = 'Frame',
		Fill = true,
		Setup = {'SecureHandlerBaseTemplate'},
		Mixin =  L.InventoryMixin,
		{
			Active = {},
		},
	},
	Merchant = {
		Type = 'Frame',
		Fill = true,
		Hide = true,
		Setup = {'SecureHandlerBaseTemplate'},
		Mixin = L.MerchantMixin,
		Probe = {MerchantFrame, 'showhide'},
		{
			Tabs = {},
			Items = {
				Type = 'ScrollFrame',
				Size = {500, 460},
				Point = {'BOTTOMRIGHT', -32, 32},
				{
					Buttons = {},
					BGFrame = {
						Type = 'Frame',
						Background = 'SCROLLBG',
						Level = 2,
						Points = {
							{'TOPLEFT', -16, 16},
							{'BOTTOMRIGHT', 16, -16},
						},
					},
				},
			},
			ItemTab = {
				Type = 'Button',
				Setup = {'CharacterFrameTabButtonTemplate'},
				Point = {'TOPRIGHT', -400, -50},
				Text = MERCHANT,
				ID = 1,
			},
			FilterTab = {
				Type = 'Button',
				Setup = {'CharacterFrameTabButtonTemplate'},
				Point = {'TOPRIGHT', -270, -50},
				Text = FILTER,
				ID = 2,
			},
			BuybackTab = {
				Type = 'Button',
				Setup = {'CharacterFrameTabButtonTemplate'},
				Point = {'TOPRIGHT', -140, -50},
				Text = BUYBACK,
				ID = 3,
			},
			RepairAll = {
				Type = 'Button',
				Size = {50, 50},
				Point = {'TOPLEFT', 30, -100},
				Events = {'UPDATE_INVENTORY_DURABILITY'},
				OnEvent = function(self)
					local _, canRepair = GetRepairAllCost();
					if ( not canRepair ) then
						self.Icon:SetDesaturated(true)
						SetDesaturation(MerchantGuildBankRepairButtonIcon, true)
						self:Disable()
					else
						self.Icon:SetDesaturated(false)
						SetDesaturation(MerchantGuildBankRepairButtonIcon, false)
						self:Enable()
					end
				end,
				OnClick = function(self)
					RepairAllItems()
					PlaySound('ITEM_REPAIR')
					GameTooltip:Hide()
				end,
				OnLoad = function(self)
					self:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
				end,
				{
					Icon = {
						Type = 'Texture',
						Setup = {'BORDER'},
						Fill = true,
						Texture = [[Interface\MerchantFrame\UI-Merchant-RepairIcons]],
						Coords = {0.28125, 0.5625, 0, 0.5625},
					},
				},
			},
		},
	},
})

frame:SetFrameRef('merchant', frame.Merchant)
frame:SetFrameRef('bags', frame.Bags)
frame:Execute([[
	-------------------------
	activeItems = newtable()
	-------------------------
	bID = 1
	gridSize = 0
	numActive = 0
	-------------------------
	merchant = self:GetFrameRef('merchant')
	bags = self:GetFrameRef('bags')
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
		self:RunAttribute('UpdateBags')

		if merchant:IsVisible() then
			self:RunAttribute('ShowMerchant')
		else
			self:RunAttribute('ShowBags')
		end

	]],

	__onhide = [[
	]],

	OnInput = [[
		local key, down = ...

		if merchant:IsVisible() then
			return self:RunAttribute('OnMerchantInput', key, down)
		else
			return self:RunAttribute('OnBagInput', key, down)
		end
	]],

	UpdateBags = [[
		numActive = self:RunAttribute('UpdateActive')
	 	gridSize = self:RunAttribute('CalculateGrid', numActive)

		self:RunAttribute('AdjustBags', gridSize)
		self:RunAttribute('SetCurrent', bID)
		bags:CallMethod('Update')
	]],

	ShowBags = [[
		merchant:Hide()
		bags:Show()
		bags:SetAllPoints()

		self:RunAttribute('UpdateBags')
	--	bags:CallMethod('OnBagsShown')
	]],

	ShowMerchant = [[
		bags:Hide()
		bags:ClearAllPoints()
		merchant:Show()

		self:SetWidth(700)
		self:SetHeight(600)
	]],

	OnMerchantInput = [[
		local key, down = ...

		-------------------------
		-- T1 pressed, change to bag interface
		-------------------------
		if key == T1 then
			if down then
				self:RunAttribute('ShowBags')
			end
		else -- Process merchant handling insecurely
			merchant:CallMethod('OnInput', key, down)
		end
	]],

	OnBagInput = [[
		local key, down = ...
		local returnHandler, returnValue
		local currentID = bID

		-------------------------
		-- T1 pressed, change to merchant interface
		-------------------------
		-- use probe counter, since merchant may be hidden, but can be shown.
		if key == T1 and down then
			local merchantProbeCount = merchant:GetAttribute('pc')
			if merchantProbeCount and merchantProbeCount > 0 then
				self:RunAttribute('ShowMerchant')
			end
			return
		end

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
						bags:CallMethod('PickupItem', current:GetName())
					elseif cachedPickupSlot then
						bags:CallMethod('MoveItem', activeItems[cachedPickupSlot]:GetName(), current:GetName())
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
			bags:CallMethod('OnButtonPressed')
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
	]],

	SetCurrent = [[
		local id = ...
		if id then
			current = activeItems[id]
			if current then
				current:CallMethod('OnFocusGained')
			end
		end
	]],

	UpdateActive = [[
		wipe(activeItems)
		for i=1, 468 do
			local button = self:GetFrameRef(tostring(i))
			if button:IsVisible() then
				bags:CallMethod('OnButtonShow', button:GetName())
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

	UI.Media:SetBackdrop(frame, 'GOSSIP_BG')
	UI:RegisterFrame(frame, 'Inv', nil, true, true)

	--- TEMPORARY
	ConsolePort:RemoveFrame(MerchantFrame)
	---
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
			local secureButton = CreateFrame('Button', _..'Item'..id, frame.Bags, 'CPUIInventoryItemButtonTemplate, SecureActionButtonTemplate')

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