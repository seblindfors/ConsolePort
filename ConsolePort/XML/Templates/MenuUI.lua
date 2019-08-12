---------------------------------------------------------------
-- Menu header secure code template
---------------------------------------------------------------
local ENV_DEFAULT = {
	_onload = [[
		hID = 1
		headers = newtable()
	]];
	_onshow = [[
		self:RunAttribute('SetHeader', hID)
		local showHeader = self:GetAttribute('ShowHeader')
		if showHeader then self:Run(showHeader, hID) end
	]];
	_onhide = [[
		for i, header in ipairs(headers) do
			self:RunAttribute('ClearHeader', i)
		end
	]];
	--------------------------------
	-- @param hID : header to set, identified by ID
	SetHeader = [[
		local header = headers[...]
		if not header then return end
		header:CallMethod('SetButtonState', 'PUSHED')
		header:CallMethod('LockHighlight')
		header:SetAttribute('focused', true)
		self:CallMethod('OnHeaderSet', header:GetName(), header:GetID())
	]];
	-- @param hID : header to clear, identified by ID
	ClearHeader = [[
		local header = headers[...]
		if not header then return end
		header:CallMethod('SetButtonState', 'NORMAL')
		header:CallMethod('UnlockHighlight')
		header:SetAttribute('focused', false)
	]];
	-- @param delta : increment/decrement from current hID
	ChangeHeader = [[
		local delta = ...
		local newIndex = hID + delta
		local header = headers[newIndex]
		if header and header:IsShown() then
			hID = newIndex
			self:RunAttribute('_onhide')
			self:RunAttribute('_onshow')
		end
	]];
	-- @param returnHandler : secure button type (e.g. 'macrotext')
	-- @param returnValue : secure button action (e.g. '/click Button')
	-- @return (optional) clickType, clickHandler, clickValue
	OnInput = [[
		local key, down = ...
		local returnHandler, returnValue

		if down then
			-- Change header
			if (key == T1 and hID > 1) then
				self:RunAttribute('ChangeHeader', -1)
			elseif (key == T2 and hID < numheaders) then
				self:RunAttribute('ChangeHeader', 1)
			end

			-- Play a notification sound when inputting
			self:CallMethod('OnButtonPressed', key)
		end
	]];
}
---------------------------------------------------------------
ConsolePortMenuSecureMixin = {}
---------------------------------------------------------------

function ConsolePortMenuSecureMixin:StartEnvironment()
	for attribute, body in pairs(ENV_DEFAULT) do
		self:SetAttribute(attribute, body)
	end
	self:Execute(self:GetAttribute('_onload'))
	self.StartEnvironment = nil
end

---------------------------------------------------------------

function ConsolePortMenuSecureMixin:UpdateHeaderIndex(forceCount)
	self.headers = forceCount and {} or self.headers or {}
	if ( #self.headers < 1 or forceCount ) then
		self:SetAttribute('headerwidth', 0)
		for _, child in ipairs({self:GetChildren()}) do
			local id = child:GetID()
			if child:IsObjectType('CheckButton') and id > 0 then
				self.headers[id] = child
				local width = child:GetWidth()
				if width > self:GetAttribute('headerwidth') then
					self:SetAttribute('headerwidth', width)
				end
			end
		end
	end
	return self.headers
end

function ConsolePortMenuSecureMixin:GetMinHeaderWidth()
	return self:GetAttribute('headerwidth') or 0
end

function ConsolePortMenuSecureMixin:GetNumHeaders(forceCount)
	return #self:UpdateHeaderIndex(forceCount)
end

function ConsolePortMenuSecureMixin:IterateHeaders(forceCount)
	return ipairs(self:UpdateHeaderIndex(forceCount))
end

function ConsolePortMenuSecureMixin:DrawIndex(headerFunc)
	local numHeaders = self:GetNumHeaders(true)
	local headerWidth = self:GetMinHeaderWidth()
	local startingPoint = -((headerWidth*numHeaders)/2 - headerWidth/2)

	self:Execute(format('numheaders = %s', numHeaders))

	for id, header in self:IterateHeaders() do
		header:ClearAllPoints()
		header:SetPoint('CENTER', startingPoint + (headerWidth * (id-1)), 0)

		self:SetFrameRef('newheader', header)
		self:Execute([[
			local newheader = self:GetFrameRef('newheader')
			headers[newheader:GetID()] = newheader
		]])

		if ( type(headerFunc) == 'function' ) then
			headerFunc(header, self)
		end
	end
end

---------------------------------------------------------------
-- Secure environment script handling

function ConsolePortMenuSecureMixin:SetSecureScript(attribute, body, asPrefix, asSuffix)
	if asPrefix then self:PrependSecureScript(attribute, body)
	elseif asSuffix then self:AppendSecureScript(attribute, body)
	else self:SetAttribute(attribute, body) end
end

function ConsolePortMenuSecureMixin:PrependSecureScript(attribute, body)
	local suffix = self:GetAttribute(attribute)
	self:SetAttribute(attribute, (suffix and body .. suffix) or body)
end

function ConsolePortMenuSecureMixin:AppendSecureScript(attribute, body)
	local prefix = self:GetAttribute(attribute)
	self:SetAttribute(attribute, (prefix and prefix .. body) or body)
end

---------------------------------------------------------------
-- Overridden by ConsolePortMenuArtMixin

function ConsolePortMenuSecureMixin:OnHeaderSet()
	-- called from secure env
end

function ConsolePortMenuSecureMixin:OnButtonPressed()
	-- called from secure env
end



---------------------------------------------------------------
-- Menu art header template: unified art template for menus
---------------------------------------------------------------
ConsolePortMenuArtMixin = {}

function ConsolePortMenuArtMixin:SetClassGradient(object, alpha)
	local cc = ConsolePortUI.Media.CC
	local gBase, gMulti, gAlpha = .3, 1.1, alpha or 0.5

	object:SetGradientAlpha('HORIZONTAL',
		(cc.r + gBase) * gMulti, (cc.g + gBase) * gMulti, (cc.b + gBase) * gMulti, gAlpha,
		1 - (cc.r - gBase) * gMulti, 1 - (cc.g - gBase) * gMulti, 1 - (cc.b - gBase) * gMulti, gAlpha)
end

function ConsolePortMenuArtMixin:LoadArt()
	local db = ConsolePort:GetData()
	local nR, nG, nB = db.Atlas.GetNormalizedCC()

	self.Art:SetVertexColor(nR, nG, nB, 1)
	self.Decor.TopLine:SetVertexColor(nR, nG, nB, 1)
	self:SetClassGradient(self.BG)

	self.BG:Show()
	self.Art:Show()
	self.GlowLeft:Show()
	self.GlowRight:Show()

	self.FadeIn, self.FadeOut = db.GetFaders()

	self:HookScript('OnShow', self.OnShowPlay)
	self:HookScript('OnSizeChanged', self.OnAspectRatioChanged)
	self:HookScript('OnUpdate', self.OnArtUpdate)
	self:OnAspectRatioChanged()
	self.LoadArt = nil
end

local LS_HEIGHT = 1080
local abs = math.abs
local artDisplays = {
	[[Interface\GLUES\LOADINGSCREENS\LoadingScreen_8xp_ForlornVictory_wide]];
	[[Interface\GLUES\LOADINGSCREENS\LoadScreenKalimdor4wide]];
	[[Interface\GLUES\LOADINGSCREENS\LoadScreenEasternKingdoms4wide]];
	[[Interface\GLUES\LOADINGSCREENS\LoadScreenDeathwingRaid]];
	[[Interface\GLUES\LOADINGSCREENS\LoadScreenBlizzcon2013Wide]];
}

function ConsolePortMenuArtMixin:OnArtUpdate(elapsed)
	self.artTicker = self.artTicker + elapsed
	if self.artTicker > 0.025 then
		local half, pan, base = self.halfY, self.pxPan, self.pxBase
		local isAtTop = pan - half < 0
		local isAtBottom = pan + half > LS_HEIGHT

		if isAtTop or isAtBottom then
			pan = isAtTop and half or (LS_HEIGHT - half)
			self.artIndex = self.artIndex >= #artDisplays and 1 or self.artIndex + 1
			self.Art:SetTexture(artDisplays[self.artIndex])
			self.panDelta = self.panDelta * -1
		else
			pan = pan + self.panDelta
		end

		local alpha = (((abs(abs(base - pan) - base) / base) ^ 1.25) - .6)
		if alpha >= 0 then
			self.Art:SetAlpha(alpha)
			self.Art:SetTexCoord(0, 1, (pan - half) / LS_HEIGHT, (pan + half) / LS_HEIGHT)
		end
		self.pxPan = pan
		self.artTicker = 0
	end
end

function ConsolePortMenuArtMixin:OnAspectRatioChanged()
	local x, y = self:GetSize()
	local scale = (UIParent:GetHeight() / LS_HEIGHT)
	self.halfY =  (y / scale / 2)
	self.pxBase = (LS_HEIGHT / 2)
	self.pxPan = LS_HEIGHT - (self.halfY)
	self.panDelta = -0.5
	self.artIndex = 1
	self.artTicker = 0
	self.Art:SetAlpha(0)
end


function ConsolePortMenuArtMixin:OnHeaderSet(id)
	self.Flair:ClearAllPoints()
	local header = type(id) == 'string' and _G[id] or id
	if header then
		if header.OnFocusAnim then
			header.OnFocusAnim:Play()
		end
		self.FadeOut(self.Flair, 0.5, 1, .25)
		self.Flair:SetPoint('BOTTOMLEFT', header, 'BOTTOMLEFT')
		self.Flair:SetPoint('BOTTOMRIGHT', header, 'BOTTOMRIGHT')
		self.Flair:SetHeight(64)
		self.Flair:Show()
	end
end

function ConsolePortMenuArtMixin:OnShowPlay()
	self.FadeIn(self.Emblem, 0.5, 0, 1)
end

function ConsolePortMenuArtMixin:OnButtonPressed()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end

---------------------------------------------------------------
ConsolePortLineSheenMixin = {}

function ConsolePortLineSheenMixin:SetDirection(direction, multiplier)
	assert(type(direction) == 'string', 'LineGlow:SetDirection("LEFT" or "RIGHT", multiplier)');
	assert(type(multiplier) == 'number', 'LineGlow:SetDirection("LEFT" or "RIGHT", multiplier)');
	if direction == 'LEFT' then
		self.OnShowAnim.LineSheenTranslation:SetOffset(-230 * multiplier, 0)
	elseif direction == 'RIGHT' then
		self.OnShowAnim.LineSheenTranslation:SetOffset(230 * multiplier, 0)
	end
end

function ConsolePortLineSheenMixin:OnShow()
	self.OnShowAnim:Play()
end

function ConsolePortLineSheenMixin:OnHide()
	self.OnShowAnim:Stop()
end