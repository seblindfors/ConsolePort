local _, L = ...
local KEY = ConsolePort:GetData().KEY
local Menu = L.Menu
local Control = ConsolePortUI:GetControlHandle()

function Menu:OnShow()
	Control:AddHint(KEY.CROSS, ACCEPT)
end

function Menu:OnButtonPressed()
	PlaySound('igMainMenuOptionCheckBoxOn')
end

for name, script in pairs({
	_onshow = [[
		self:RunAttribute('SetHeader', hID)
		self:RunAttribute('ShowHeader', hID)
		self:RunAttribute('SetCurrent', bID)
		RegisterStateDriver(self, 'modifier', '[mod:shift,mod:ctrl] true; nil')
	]],
	_onhide = [[
		self:RunAttribute('Reset')
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
					self:RunAttribute('HideHeader', i)
				end
			end
		end
	]],
	Reset = [[
		for i, header in pairs(headers) do
			header:CallMethod('SetButtonState', 'NORMAL')
			header:CallMethod('UnlockHighlight')
			self:RunAttribute('HideHeader', i)
		end
	]],
	ShowHeader = [[
		local hID = ...
		local header = headers[hID]
		local buttons = newtable(header:GetChildren())
		for _, button in pairs(buttons) do
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
	HideHeader = [[
		local hID = ...
		local header = headers[hID]
		local buttons = newtable(header:GetChildren())
		for _, button in pairs(buttons) do
			button:Hide()
		end
	]],
	SetHeader = [[
		local hID = ...
		header = headers[hID]
		header:CallMethod('SetButtonState', 'PUSHED')
		header:CallMethod('LockHighlight')

		local buttons = newtable(header:GetChildren())
		local visible = 0
		for _, button in pairs(buttons) do
			local condition = button:GetAttribute('condition')
			if condition then
				local show = self:Run(condition)
				if show then
					visible = visible + 1
				end
			else
				visible = visible + 1
			end
		end
		numbuttons = visible
	]],
	SetCurrent = [[
		local bID = ...
		if current then
			current:CallMethod('OnLeave')
		end
		if header then
			current = header:GetFrameRef(tostring(bID))
			if current:IsVisible() then
				current:CallMethod('OnEnter')
			else
				bID = 1
				self:RunAttribute('SetCurrent', bID)
			end
		end
	]],
	OnInput = [[
		local key, down = ...

		-- Click on a button
		if key == CROSS then
			current:CallMethod('SetButtonState', down and 'PUSHED' or 'NORMAL')
			if not down then
				self:GetFrameRef('control'):SetAttribute('macrotext', '/click ' .. current:GetName())
			end
		elseif ( key == CENTER or key == OPTIONS or key == SHARE ) and down then
			self:CallMethod('HideMenu')

		-- Select button
		elseif key == UP and down and bID > 1 then
			bID = bID - 1
			self:RunAttribute('SetCurrent', bID)
		elseif key == DOWN and down and bID < numbuttons then
			bID = bID + 1
			self:RunAttribute('SetCurrent', bID)


		-- Select header
		elseif key == LEFT and down and hID > 1 then
			hID = hID - 1
			bID = 1
			self:RunAttribute('_onhide')
			self:RunAttribute('_onshow')
		elseif key == RIGHT and down and hID < numheaders then
			hID = hID + 1
			bID = 1
			self:RunAttribute('_onhide')
			self:RunAttribute('_onshow')
		end

		-- Play a notification sound when inputting
		if down then
			self:CallMethod('OnButtonPressed')
		end
	]],
}) do Menu:SetAttribute(name, script) end

Menu:HookScript('OnShow', Menu.OnShow)