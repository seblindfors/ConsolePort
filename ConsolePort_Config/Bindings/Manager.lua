local _, env = ...; local db = env.db;
local BindingInfo = env.BindingInfo;

---------------------------------------------------------------
-- Mixins
---------------------------------------------------------------
local BindingManager = CreateFromMixins(CPFocusPoolMixin);
local Binding = CreateFromMixins(CPIndexButtonMixin)
local Header = CreateFromMixins(CPIndexButtonMixin, CPFocusPoolMixin, env.ScaleToContentMixin)
env.BindingManager = BindingManager;

---------------------------------------------------------------
-- Regular bindings
---------------------------------------------------------------
function Binding:UpdateBinding()
	local binding = self:GetAttribute('binding')
	if binding then
		local slug = db('Hotkeys'):GetButtonSlugForBinding(binding)
		self.Slug:SetText(slug)
		self:SetAttribute('slug', slug)
	else
		self.Slug:SetText(nil)
		self.Slug:SetAttribute('slug', nil)
	end
end

function Binding:GetBinding()
	local id = self:GetID()
	return self:GetAttribute('binding'), id > 0 and id or nil;
end

function Binding:GetAction()
	return nil;
end

function Binding:ClearKeys(key, ...)
	if key then
		SetBinding(key, nil)
		self:ClearKeys(...)
	end
end

function Binding:OnClick(button)
	if ( button == 'RightButton' ) then
		local binding = self:GetBinding()
		if not BindingInfo:IsReadonlyBinding(binding) then
			self:ClearKeys(db('Gamepad'):GetBindingKey(binding))
		end
		self:SetChecked(false)
		self:OnChecked(false)
	else
		env.Bindings:NotifyBindingFocus(self, self:GetChecked(), true)
	end
end

function Binding:OnEnter()
	CPIndexButtonMixin.OnIndexButtonEnter(self)
end

function Binding:OnLeave()
	CPIndexButtonMixin.OnIndexButtonLeave(self)
end

function Binding:OnLoad()
	self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	CPAPI.Start(self)
end

---------------------------------------------------------------
-- Headers
---------------------------------------------------------------
function Header:OnLoad()
	self:SetMeasurementOrigin(self, self.Content, self:GetWidth(), 20)
	CPFocusPoolMixin.OnLoad(self)
	self:SetScript('OnEnter', CPIndexButtonMixin.OnIndexButtonEnter)
	self:SetScript('OnLeave', CPIndexButtonMixin.OnIndexButtonLeave)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingActionTemplate', Binding, nil, self.Content)
end

function Header:OnEvent()
	self:UpdateBinding()
end

function Header:UpdateBinding()
	for widget in self:EnumerateActive() do
		widget:UpdateBinding()
	end
end

function Header:OnExpand()
	self.Hilite:Hide()
	self:SetHeight(nil)
	self:RegisterEvent('UPDATE_BINDINGS')
	self:SetScript('OnEvent', self.OnEvent)
end

function Header:OnCollapse()
	self:UnregisterAllEvents()
	self:SetScript('OnEvent', nil)
	self.Hilite:Show()
	self:SetHeight(40)
	self:ReleaseAll()
end

function Header:OnChecked(show)
	CPIndexButtonMixin.OnChecked(self, show)
	self.Content:SetShown(show)
	if show then
		local bindings, i, separator = self.Bindings, 0, 0
		for idx, data in ipairs(bindings) do
			if ( data.binding and not data.binding:match('^HEADER_BLANK') ) then
				i = i + 1;
				local widget, newObj = self:Acquire(i)
				if newObj then
					widget:OnLoad()
					widget:SetDrawOutline(true)
				end
				widget:SetText(data.name or data.binding)
				widget:SetAttribute('binding', data.binding)
				widget:Show()
				widget:UpdateBinding()
				if (i == 1) then
					widget:SetPoint('TOPLEFT', 16, 0)
				elseif (i % 2 == 0) then
					widget:SetPoint('LEFT', self.Registry[i-1], 'RIGHT', 8, 0)
				else
					widget:SetPoint('TOP', self.Registry[i-2], 'BOTTOM', 0, -10-separator)
				end
				separator = 0;
			else
				separator = 20;
			end
		end
		self:OnExpand()
	else
		self:OnCollapse()
	end
end

---------------------------------------------------------------
-- Actionbars
---------------------------------------------------------------
local Actionbutton, Actionbar, Actionpage = CreateFromMixins(Binding), CreateFromMixins(Header), CreateFromMixins(Header)

function Actionbutton:OnClick(...)
	if GetCursorInfo() then
		PlaceAction(self:GetID())
		self:SetChecked(false)
	else
		Binding.OnClick(self)
	end
	self:OnChecked(self:GetChecked())
end

function Actionbutton:GetAction()
	return self:GetID()
end

function Actionbutton:OnDragStart()
	PickupAction(self:GetID())
	self:SetChecked(false)
end

function Actionbutton:OnReceiveDrag()
	PlaceAction(self:GetID())
end

function Actionbutton:OnLoad()
	self:SetDrawOutline(true)
	self:RegisterForDrag('LeftButton')
	CPAPI.Start(self)
end

function Actionbutton:OnShow()
	self:UpdateInfo()
	self:UpdateBinding()
end

function Actionbutton:OnEnter()
	CPIndexButtonMixin.OnIndexButtonEnter(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	GameTooltip:SetAction(self:GetID())
	GameTooltip:AddLine(self:GetAttribute('name'))
	local slug = self:GetAttribute('slug')
	if slug then
		GameTooltip:AddLine(('%s: %s'):format(KEY_BINDING, self.Slug:GetText()), GameFontGreen:GetTextColor())
	end
	GameTooltip:Show()
end

function Actionbutton:OnLeave()
	CPIndexButtonMixin.OnIndexButtonLeave(self)
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:Hide()
	end
end

function Actionbutton:OnHide()
	if ( GameTooltip:IsOwned(self) ) then
		GameTooltip:Hide()
	end
end

function Actionbutton:UpdateInfo()
	local texture = GetActionTexture(self:GetID())
	self.Icon:SetTexture(texture or CPAPI.GetAsset([[Textures\Button\EmptyIcon]]))
	self.Icon:SetDesaturated(not texture or false)
	if not texture then
		self.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
	else
		self.Icon:SetVertexColor(1, 1, 1, 1)
	end
end

---------------------------------------------------------------
-- Actionpage
---------------------------------------------------------------
function Actionpage:OnLoad()
	self:SetPoint('TOP')
	self:SetMeasurementOrigin(self, self.Content, self:GetWidth(), 0)
	CPFocusPoolMixin.OnLoad(self)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingActionButtonTemplate', Actionbutton, nil, self.Content)
end

function Actionpage:OnEvent(event, ...)
	if (event == 'UPDATE_BINDINGS') then
		for widget in self:EnumerateActive() do
			widget:UpdateBinding()
		end
	elseif (event == 'ACTIONBAR_SLOT_CHANGED') then
		local actionID = ...;
		if self.Registry[actionID] then
			self.Registry[actionID]:UpdateInfo()
		end
	end
end

function Actionpage:OnExpand()
	Header.OnExpand(self)
	self:RegisterEvent('ACTIONBAR_SLOT_CHANGED')
end

function Actionpage:OnCollapse()
	self:UnregisterAllEvents()
	self:SetScript('OnEvent', nil)
	self.Hilite:Show()
	self:SetHeight(40)
end

function Actionpage:SetPages(pages)
	-- NOTE: nullify to stop this from redrawing and causing problems.
	-- if the header has been opened once, there is no memory saved by
	-- releasing it and redrawing.
	self.pages = pages;
end

function Actionpage:DrawPages()
	if not self.pages then return end;
	self:ReleaseAll()

	local row, data = NUM_ACTIONBAR_BUTTONS, BindingInfo.Actionbar;
	local index, prevCol, prevRow = 1;
	
	for _, page in ipairs(self.pages) do
		local offset = (page - 1) * row;

		for slot=1, row do
			local i = offset + slot;
			local name, binding;
			if data[i] then
				name, binding = data[i].name, data[i].binding;
			else -- fallback for bonusbars, since they have no discrete bindings.
				binding = db('Actionbar/Action/'..i)
				name = BindingInfo:GetBindingName(binding)
			end

			local widget, newObj = self:Acquire(i)
			if newObj then
				widget:OnLoad()
			end

			widget:SetID(i)
			widget:SetAttribute('name', name)
			widget:SetAttribute('binding', binding)
			widget:Hide()
			widget:Show()

			if (index == 1) then
				widget:SetPoint('TOPLEFT', 8, 0)
				prevRow = widget;
			elseif (index % row == 1) then
				widget:SetPoint('TOP', prevRow, 'BOTTOM', 0, -6)
				prevRow = widget;
			else
				widget:SetPoint('LEFT', prevCol, 'RIGHT', 6, 0)
			end
			index, prevCol = index + 1, widget;
		end
	end
	self:SetPages(nil)
end

function Actionpage:OnChecked(show)
	CPIndexButtonMixin.OnChecked(self, show)
	self.Content:SetShown(show)
	if show then
		self:DrawPages()
		self:OnExpand()
	else
		self:OnCollapse()
	end
end

---------------------------------------------------------------
-- Actionbars
---------------------------------------------------------------
function Actionbar:OnLoad(anchorTo)
	self:SetText(BINDING_HEADER_ACTIONBAR) --'|TInterface\\Store\\category-icon-weapons:24:24:4:0:64:64:14:50:14:50|t'
	self:SetPoint('TOP', anchorTo, 'BOTTOM', 0, -8)
	self:SetMeasurementOrigin(self, self.Content, self:GetWidth(), 20)
	self:SetScript('OnEnter', CPIndexButtonMixin.OnIndexButtonEnter)
	self:SetScript('OnLeave', CPIndexButtonMixin.OnIndexButtonLeave)
	CPFocusPoolMixin.OnLoad(self)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingActionBarTemplate', Actionpage, nil, self.Content)
end

function Actionbar:GetPages()
	local showExtra = GetNumShapeshiftForms() > 0 or db('bindingShowExtraBars')
	return ipairs({
		-- (1) Page 1 / Page 2
		-- (2) Bottom Left / Bottom Right
		-- (3) Right / Right 2
		-- (4) Stances / Shapeshifting
		{{1, 2}, ('%s / %s'):format(BINDING_NAME_ACTIONPAGE1, BINDING_NAME_ACTIONPAGE2)};
		{{6, 5}, ('%s / %s'):format(SHOW_MULTIBAR1_TEXT, SHOW_MULTIBAR2_TEXT)};
		{{3, 4}, ('%s / %s'):format(SHOW_MULTIBAR3_TEXT, SHOW_MULTIBAR4_TEXT)}; showExtra and 
		{{7, 8, 9, 10}, ('%s / %s'):format(TUTORIAL_TITLE61_WARRIOR, TUTORIAL_TITLE61_DRUID)} or nil;
	})
end

function Actionbar:OnChecked(show)
	CPIndexButtonMixin.OnChecked(self, show)
	self.Content:SetShown(show)
	if show then
		local prev;
		for i, pageSet in self:GetPages() do
			local bars, desc = pageSet[1], pageSet[2]
			local widget, newObj = self:TryAcquireRegistered(i)
			if newObj then
				widget:OnLoad()
			end
			widget:SetID(i)
			widget:SetText(desc)
			widget:SetPages(bars)
			widget:Show()
			if prev then
				widget:SetPoint('TOP', prev, 'BOTTOM', 0, -6)
			else
				widget:SetPoint('TOP')
			end
			prev = widget;
		end
		self:OnExpand()
	else
		self:OnCollapse()
	end
--	self:GetParent():ScaleToContent()
end

---------------------------------------------------------------
-- Binding manager
---------------------------------------------------------------
function BindingManager:OnShow()
	local bindings, headers, wasUpdated = BindingInfo:RefreshDictionary()
	if not self.bindingsFirstDrawn or wasUpdated then
		self:ReleaseAll()
		self:DrawCategories(bindings, headers)
		self.bindingsFirstDrawn = true;
	end
	self:RefreshHeader()
end

function BindingManager:RefreshHeader()
	local ACCOUNT_BINDINGS, CHARACTER_BINDINGS = 1, 2;
	local header = self.Header;
	local isCharacterBindings = (GetCurrentBindingSet() == CHARACTER_BINDINGS)

	header.PortraitMask:SetShown(isCharacterBindings)
	header.Portrait:SetShown(isCharacterBindings)
	header.Button:SetShown(isCharacterBindings)

	if (isCharacterBindings) then
		local texture, coords = CPAPI.GetWebClassIcon()
		header.Button:SetTexture(texture)
		header.Button:SetTexCoord(unpack(coords))
		header.Button:SetSize(24, 24)

		SetPortraitTexture(header.Portrait, 'player')
		header.Text:SetText(CHARACTER_KEY_BINDINGS:format(CPAPI.GetPlayerName(true)))
	else
		header.Text:SetText(KEY_BINDINGS)
	end
end

function BindingManager:DrawCategories(bindings, headers)
	local prev = self.Actionbar;
	for header, set in db.table.spairs(bindings) do
		local widget, newObj = self:Acquire(header)
		if newObj then
			widget:OnLoad()
		end
		widget:SetText(header)
		widget:SetPoint('TOP', prev, 'BOTTOM', 0, -12)
		widget:Show()
		widget.Bindings = set;
		prev = widget;
	end
	self.Child:SetHeight(nil)
end

function BindingManager:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	env.OpaqueMixin.OnLoad(self)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingHeaderTemplate', Header, nil, self.Child)
	Mixin(self.Child, env.ScaleToContentMixin)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self.Child, self.Child, 600, 12)

	-- Create custom action bar handler
	self.Header = CreateFrame('Frame', nil, self.Child, 'CPConfigIconHeaderTemplate')
	self.Header:SetPoint('TOP', 0, -12)
	self.Actionbar = Mixin(CreateFrame('IndexButton', nil, self.Child, 'CPIndexButtonBindingHeaderTemplate'), Actionbar)
	self.Actionbar:OnLoad(self.Header)
end
