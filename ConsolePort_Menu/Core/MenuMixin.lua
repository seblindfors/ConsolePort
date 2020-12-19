local _, env = ...;

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
		header:SetAttribute('nodepriority', 1)
		header:SetAttribute('focused', true)
		self:CallMethod('OnHeaderSet', header:GetName(), header:GetID())
	]];
	-- @param hID : header to clear, identified by ID
	ClearHeader = [[
		local header = headers[...]
		if not header then return end
		header:CallMethod('SetButtonState', 'NORMAL')
		header:CallMethod('UnlockHighlight')
		header:SetAttribute('nodepriority', 0)
		header:SetAttribute('focused', false)
		self:CallMethod('OnHeaderCleared', header:GetName(), header:GetID())
	]];
	-- @param hID : header to set, identified by ID
	ChangeHeader = [[
		local header = headers[...]
		if header and header:IsShown() then
			hID = ...;
			self:RunAttribute('_onhide')
			self:RunAttribute('_onshow')
		end
	]];
}
---------------------------------------------------------------
local Menu = {}; env.MenuMixin = Menu;
---------------------------------------------------------------

function Menu:StartEnvironment()
	for attribute, body in pairs(ENV_DEFAULT) do
		self:SetAttribute(attribute, body)
	end
	self:Execute(self:GetAttribute('_onload'))
	self.StartEnvironment = nil
end

---------------------------------------------------------------
-- @param config : table {
-- 	@param name : parentKey 
--	@param id   : (optional) numeric order ID
-- 	@param text : (optional) displayed on item
-- 	@param click : (optional) secure on click script
-- 	@param blueprint : (optional) children blueprint
--
-- 	@param type : (optional) frame type
--	@param templates : (optional) frame templates
--	@param redraw : (optional) redraw the menu
-- 	@param init   : (optional) init function
-- }
-- @return header : frame object
function Menu:AddHeader(config)
	local object = LibStub('Carpenter')(self, {
		[config.name] = {
			_ID = config.id or self:GetNumHeaders() + 1;
			_Type  = config.type or 'CheckButton';
			_Text  = config.text;
			_Setup = config.templates or {
				'SecureHandlerBaseTemplate';
				'SecureHandlerClickTemplate';
				'CPUIListCategoryTemplate';
			};
			_SetAttribute = {'_onclick', config.click};
			[1] = config.blueprint;
		};
	})
	if (type(config.init) == 'function') then
		config.init(object, self)
	end
	if config.redraw then
		self:DrawIndex()
	end
	return object;
end

function Menu:UpdateHeaderIndex(forceCount)
	self.headers = forceCount and {} or self.headers or {}
	if ( #self.headers < 1 or forceCount ) then
		self:SetAttribute('headerwidth', self:GetAttribute('indexwidth') or 0)
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

function Menu:GetMinHeaderWidth()
	return self:GetAttribute('headerwidth') or 0
end

function Menu:GetNumHeaders(forceCount)
	return #self:UpdateHeaderIndex(forceCount)
end

function Menu:IterateHeaders(forceCount)
	return ipairs(self:UpdateHeaderIndex(forceCount))
end

function Menu:DrawIndex(headerFunc)
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

function Menu:SetSecureScript(attribute, body, asPrefix, asSuffix)
	if asPrefix then self:PrependSecureScript(attribute, body)
	elseif asSuffix then self:AppendSecureScript(attribute, body)
	else self:SetAttribute(attribute, body) end
end

function Menu:PrependSecureScript(attribute, body)
	local suffix = self:GetAttribute(attribute)
	self:SetAttribute(attribute, (suffix and body .. suffix) or body)
end

function Menu:AppendSecureScript(attribute, body)
	local prefix = self:GetAttribute(attribute)
	self:SetAttribute(attribute, (prefix and prefix .. body) or body)
end

---------------------------------------------------------------
-- Art

function Menu:LoadArt()
	local db = ConsolePort:GetData()
	local nR, nG, nB = CPAPI.NormalizeColor(CPAPI.GetClassColor())

	self.TopLine:SetVertexColor(nR, nG, nB, 1)
	self:SetClassGradient(self.BG)

	self.BG:Show()
	self.GlowLeft:Show()
	self.GlowRight:Show()

	self.FadeIn, self.FadeOut = db.Alpha.FadeIn, db.Alpha.FadeOut;

	self:HookScript('OnShow', self.OnShowPlay)
	self.LoadArt = nil;
end


function Menu:SetClassGradient(object, alpha)
	local r, g, b = CPAPI.GetClassColor()
	local gBase, gMulti, gAlpha = .3, 1.1, alpha or 0.5;

	object:SetGradientAlpha('HORIZONTAL',
		(r + gBase) * gMulti, (g + gBase) * gMulti, (b + gBase) * gMulti, gAlpha,
		1 - (r - gBase) * gMulti, 1 - (g - gBase) * gMulti, 1 - (b - gBase) * gMulti, gAlpha)
end

function Menu:OnHeaderSet(id)
	self.Flair:ClearAllPoints()
	local header = type(id) == 'string' and _G[id] or id
	if header then
		if header.OnFocusAnim then
			header.OnFocusAnim:Play()
		end
		if header.OnFocus then
			header:OnFocus()
		end
		self.FadeOut(self.Flair, 0.5, 1, .25)
		self.Flair:SetPoint('BOTTOMLEFT', header, 'BOTTOMLEFT')
		self.Flair:SetPoint('BOTTOMRIGHT', header, 'BOTTOMRIGHT')
		self.Flair:SetHeight(64)
		self.Flair:Show()
	end
end

function Menu:OnHeaderCleared(id)
	local header = type(id) == 'string' and _G[id] or id
	if header and header.OnClear then
		header:OnClear()
	end
end

function Menu:OnShowPlay()
	self.FadeIn(self.Emblem, 0.5, 0, 1)
end

function Menu:OnButtonPressed()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end