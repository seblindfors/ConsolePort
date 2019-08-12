local _, L = ...
local Menu = L.Menu
local Control = ConsolePortUI:GetControlHandle()

function Menu:OnShow()
	if UIDoFramesIntersect(self, Minimap) and Minimap:IsShown() then
		self.minimapHidden = true
		Minimap:Hide()
		MinimapCluster:Hide()
	end
end

function Menu:OnHide()
	if self.minimapHidden then
		Minimap:Show()
		MinimapCluster:Show()
		self.minimapHidden = false
	end
end

for name, script in pairs({
	_onshow = [[
		self:RunAttribute('SetCurrent', 0, 1)
		RegisterStateDriver(self, 'modifier', '[mod:shift,mod:ctrl] true; nil')
	]],
	_onhide = [[
		UnregisterStateDriver(self, 'modifier')
	]],
	['_onstate-modifier'] = [[
		if newstate then
			for i = 1, numheaders do
				self:RunAttribute('ShowHeader', i)
			end
		else
			for i = 1, numheaders do
				if i ~= hID then
					self:RunAttribute('ClearHeader', i)
				end
			end
		end
	]],
	SetHeaderID = [[
		hID = ...
	]],
	ShowHeader = [[
		local hID = ...
		local header = headers[hID]
		for _, button in ipairs(newtable(header:GetChildren())) do
			local condition = button:GetAttribute('condition')
			if condition then
				local show = self:Run(condition)
				if show then
					button:Show()
				else
					button:Hide()
				end
			else
				button:Show()
			end
		end
	]],
	ClearHeader = [[
		for _, button in ipairs(newtable(header:GetChildren())) do
			button:Hide()
		end
	]],
	SetHeader = [[
		local buttons = newtable(header:GetChildren())
		local highIndex = 0
		if header:GetAttribute('onheaderset') then
			highestIndex = header:RunAttribute('onheaderset')
		else
			for _, button in pairs(buttons) do
				local condition = button:GetAttribute('condition')
				local currentID
				if condition then
					local show = self:Run(condition)
					if show then
						currentID = tonumber(button:GetID())
					end
				else
					currentID = tonumber(button:GetID())
				end
				if currentID and currentID > highIndex then
					highIndex = currentID
				end
			end
			highestIndex = highIndex
		end
	]],
	SetCurrent = [[
		local newIndex, delta = ...
		bID = newIndex + delta
		if current then
			current:CallMethod('OnLeave')
		end
		local header = headers[hID]
		if header then
			current = header:GetFrameRef(tostring(bID))
			if current and current:IsShown() then
				current:CallMethod('OnEnter')
			elseif bID > 1 and bID < highestIndex then
				self:RunAttribute('SetCurrent', bID, delta)
			end
		end
	]],
	OnInput = [[
		-- Click on a button
		if key == CROSS and current then
			current:CallMethod('SetButtonState', down and 'PUSHED' or 'NORMAL')
			if not down then
				returnHandler, returnValue = 'macrotext', '/click ' .. current:GetName()
			end

		-- Alternative clicks
		elseif key == CIRCLE and current then
			current:CallMethod('SetButtonState', down and 'PUSHED' or 'NORMAL')
			if not down then
				if current:GetAttribute('circleclick') then
					current:RunAttribute('circleclick')
				end
			end
		elseif key == SQUARE and current then
			current:CallMethod('SetButtonState', down and 'PUSHED' or 'NORMAL')
			if not down then
				if current:GetAttribute('squareclick') then
					current:RunAttribute('squareclick')
				end
			end
		elseif key == TRIANGLE and current then
			current:CallMethod('SetButtonState', down and 'PUSHED' or 'NORMAL')
			if not down then
				if current:GetAttribute('triangleclick') then
					current:RunAttribute('triangleclick')
				end
			end

		elseif ( key == CENTER or key == OPTIONS or key == SHARE ) and down then
			returnHandler, returnValue = 'macrotext', '/click GameMenuButtonContinue'

		-- Select button
		elseif key == UP and down and bID > 1 then
			self:RunAttribute('SetCurrent', bID, -1)
		elseif key == DOWN and down and bID < highestIndex then
			self:RunAttribute('SetCurrent', bID, 1)

		-- Select header
		elseif key == LEFT and down and hID > 1 then
			self:RunAttribute('ChangeHeader', -1)
		elseif key == RIGHT and down and hID < numheaders then
			self:RunAttribute('ChangeHeader', 1)
		end

		return 'macro', returnHandler, returnValue
	]],
}) do Menu:AppendSecureScript(name, script) end

Menu:HookScript('OnShow', Menu.OnShow)
Menu:HookScript('OnHide', Menu.OnHide)