if select(5, GetAddOnInfo('ConsolePortHelp')) ~= 'DEMAND_LOADED' then return end
local _, db = ...
local Atlas, mixin, spairs = db.Atlas, db.table.mixin, db.table.spairs
local WindowMixin, IndexButton, HTMLHandler, selectedIndex = {}, {}, {}

function HTMLHandler:website(address, linkType)
	StaticPopupDialogs['CONSOLEPORT_EXTERNALLINK'] = {
		text = db.TUTORIAL.SLASH.EXTERNALLINK:format(linkType),
		button1 = CLOSE,
		showAlert = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
		hasEditBox = 1,
		enterClicksFirstButton = true,
		exclusive = true,
		OnAccept = ConsolePort.ClearPopup,
		OnCancel = ConsolePort.ClearPopup,
		OnShow = function(self, data)
			self.editBox:SetText(data)
		end,
	}
	ConsolePort:ShowPopup('CONSOLEPORT_EXTERNALLINK', nil, nil, address)
end

function HTMLHandler:slash(message)
	local handler = strmatch(message, '^(/[^%s]+)') or ''
	local subCmd = ''
	if ( handler ~= message ) then
		subCmd = message:sub(handler:len() + 2)
	end
	handler = handler:upper():sub(2)
	local cmd = SlashCmdList[handler]
	if cmd then
		cmd(subCmd)
	end
end

function HTMLHandler:run(message) -- don't feed broken scripts
	local func, errMsg, pcallOK = loadstring(message)
	if func then
		pcallOK, errMsg = pcall(func)
		if pcallOK then return end
	end
	print('HTML function call failed:', errMsg)
end

function HTMLHandler:page(message)
	for i, button in pairs(self.Index.Buttons) do
		if button.pageID == message then
			ConsolePort:SetCurrentNode(button)
		--	if selectedIndex then
		--		selectedIndex.SelectedTexture:Hide()
		--	end
		--	button.SelectedTexture:Show()
		--	selectedIndex = button
			return
		end
	end
end

function HTMLHandler:OnHyperlinkClick(linkData)
	local startPoint, endPoint = linkData:find('%a+:')
	local linkType = linkData:sub(startPoint, endPoint - 1)
	local address = linkData:sub(endPoint + 1)

	if self[linkType] then
		self[linkType](self, address, linkType)
	end
end

function HTMLHandler:GetCursorPoint()
	self.activeCursorPoints = self.activeCursorPoints + 1
	local point = self.cursorPoints[self.activeCursorPoints] 
	if not point then
		point = CreateFrame('Button', nil, self)
		point.parent = self
		point:SetSize(4, 4)
		point:SetScript('OnClick', function(self)
			if self.script then
				self.parent:OnHyperlinkClick(self.script)
			end
		end)
		self.cursorPoints[self.activeCursorPoints] = point
	end
	point:Show()
	return point
end

function HTMLHandler:ResetCursorPoints()
	self.activeCursorPoints = 0
	for i, point in pairs(self.cursorPoints) do
		point.script = nil
		point:ClearAllPoints()
		point:Hide()
	end
end

function HTMLHandler:ShowPage(content, references)
	self:ResetCursorPoints()
	self:SetText(content)
	for _, region in pairs({self:GetRegions()}) do
		if region:IsObjectType('FontString') then
			local key = region:GetText()
			for refText, refScript in pairs(references) do
				if key:match(refText) then
					local pointButton = self:GetCursorPoint()
					pointButton:SetPoint('TOP', region, 'BOTTOM', 0, 0)
					pointButton.script = refScript
				end
			end
		end
	end
end

function IndexButton:OnClick()
	if selectedIndex then
		selectedIndex.SelectedTexture:Hide()
	end
	self.SelectedTexture:Show()
	selectedIndex = self
	self.HTML:ShowPage(self.content, self.references)
end

function IndexButton:ParseContent()
	for element in self.content:gmatch('<a href=%b""%b></a>') do
		local linkStart = select(2, element:find('href="'))
		local linkEnd = element:find('">')
		local textStart = linkEnd and linkEnd + 2
		local textEnd = element:find("</a>")
		if textStart and textEnd and linkStart and linkEnd then
			-- key: clickable text, value: parsable link
			self.references[element:sub(textStart, textEnd - 1)] = element:sub(linkStart + 1, linkEnd - 1)
		end
	end
end

function WindowMixin:AddPage(pageID, pageTable, depth)
	self.pageCount = self.pageCount + 1
	depth = depth + 1

	local index = self.Index
	local width = 230 - (depth * 10)
	local button = Atlas.GetFutureButton('$parentIndexButton'..self.pageCount, index.Child, nil, nil, width, 32, true)
	mixin(button, IndexButton)
	index:AddButton(button, depth * 10)

	button:SetText(pageID)
	button.Label:SetTextColor(1, 1, 1)
	button.Label:SetJustifyH('LEFT')
	button.Label:ClearAllPoints()
	button.Label:SetPoint('LEFT', 30, 0)

	button.pageID = pageID
	button.content = pageTable.content
	button.HTML = self.HTML
	button.references = {}

	button:ParseContent()

	if pageTable.children then
		for childID, childTable in spairs(pageTable.children) do
			self:AddPage(childID, childTable, depth)
		end
	end
	return button
end

local errorText =
[[<HTML><BODY>
<H1 align="center">Woops! Something went wrong!</H1>
<IMG src="Interface\Common\spacer" align="center" width="1" height="27"/>
<p align="center">The tutorial content failed to load.</p>
</BODY></HTML>]]

db.PANELS[#db.PANELS + 1] = {
	name = HELP_LABEL, 
	header  = HELP_LABEL, 
	mixin = WindowMixin,
	noDefault = true,
	onLoad = function(self, core)
		local HTML = CreateFrame('SimpleHTML', '$parentHTML', self)
		self.HTML = HTML

		mixin(HTML, HTMLHandler)

		-- Fonts used
		HTML:SetFontObject(Game12Font)
		HTML:SetFont('p', [[Fonts\FRIZQT__.ttf]], 14, '')
		HTML:SetFont('h2', Game13Font:GetFont())
		HTML:SetFont('h1', Fancy22Font:GetFont())

		-- Font colors
		HTML:SetTextColor('p', 1, 1, 1)
		HTML:SetTextColor('h2', Fancy22Font:GetTextColor())
		HTML:SetTextColor('h1', Fancy22Font:GetTextColor())

		HTML:SetText(errorText)

		if not LoadAddOn('ConsolePortHelp') then
			return
		end

		self.pageCount = 0
		self.Index = Atlas.GetScrollFrame('$parentIndexFrame', self, {
			childWidth = 250,
			stepSize = 32,
		})

		self.Index:SetPoint('TOPLEFT', 16, -16)
		self.Index:SetPoint('BOTTOMRIGHT', self, 'BOTTOMLEFT', 250, 16)

		HTML:SetPoint('TOPLEFT', self.Index, 'TOPRIGHT', 48, -16)
		HTML:SetSize(654, 602)
		HTML.Index = self.Index

		-- Set up cursor points for clicking on links with the controller
		HTML.cursorPoints = {}
		HTML.activeCursorPoints = 0

		HTML.Backdrop = CreateFrame('Frame', '$parentBackdrop', HTML)
		HTML.Backdrop:SetBackdrop(Atlas.Backdrops.Border)
		HTML.Backdrop:SetPoint('TOPLEFT', -32, 32)
		HTML.Backdrop:SetPoint('BOTTOMRIGHT', 32, -32)
		HTML.Backdrop:SetFrameLevel(self:GetFrameLevel() - 1)
		HTML:HookScript('OnShow', function(self)
			self.Backdrop:Show()
		end)
		HTML:HookScript('OnHide', function(self)
			self.Backdrop:Hide()
		end)

		-- Generate index
		self.Pages, self.WelcomePage = ConsolePortHelp:GetPages()
		local welcomeIndex = self:AddPage('|cff69ccf0Introduction|r', {content = self.WelcomePage}, -1)
		welcomeIndex:Click()
		for pageID, pageTable in spairs(self.Pages) do
			self:AddPage(pageID, pageTable, -1)
		end
		self.Index:Refresh(self.pageCount)
		
	end
}