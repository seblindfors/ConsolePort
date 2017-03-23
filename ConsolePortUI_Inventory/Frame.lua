local _, L = ...
local UI = ConsolePortUI
local Mixin = UI.Utils.Mixin

local frame = UI:CreateFrame('Frame', _, UIParent, 'SecureHandlerBaseTemplate, SecureHandlerShowHideTemplate, SecureHandlerStateTemplate', {
	Active = {},
})

frame:Execute([[
	activeItems = newtable()
]])

for name, script in pairs({

	_onshow = [[
		local numActive = self:RunAttribute('UpdateActive')
	 	local gridSize = self:RunAttribute('CalculateGrid', numActive)

		self:RunAttribute('AdjustBags', gridSize)
		self:CallMethod('Update')
	]],

	__onhide = [[
		print('Hiding away...')
	]],

	AdjustBags = [[
		local gridSize = ...
		local sz = 42

		for bagID=1, 13 do
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

	Mixin(frame, L.InventoryMixin)

	for bag = 1, 13 do
		local container = _G['ContainerFrame' .. bag]
		UI:CreateProbe(frame, container, 'showhide')
		UI:HideFrame(container)

		frame:SetFrameRef('container' .. bag, container)

		for slot = 1, 36 do
			local id = ((bag-1)*36) + slot
			local button = _G['ContainerFrame' .. bag .. 'Item' .. slot]
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