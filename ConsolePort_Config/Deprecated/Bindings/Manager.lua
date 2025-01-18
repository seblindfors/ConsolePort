local _, env, db, L = ...; db, L = env.db, env.L;
local BindingInfo = env.BindingInfo;

local FIXED_OFFSET, LEFT_PANEL_WIDTH, RIGHT_PANEL_WIDTH = 8, 360, 600;
---------------------------------------------------------------
-- Mixins
---------------------------------------------------------------
local BindingManager = CreateFromMixins(CPFocusPoolMixin);
local Binding = CreateFromMixins(CPIndexButtonMixin)
local Wrapper = CreateFromMixins(CPIndexButtonMixin, CPFocusPoolMixin, env.ScaleToContentMixin)
env.BindingManager = BindingManager;

---------------------------------------------------------------
-- Regular bindings
---------------------------------------------------------------
function Binding:UpdateBinding()
	local binding = self:GetAttribute('binding')
	if binding then
		local slug = db('Hotkeys'):GetButtonSlugsForBinding(binding, self.KeySeparator, self.KeyLimit)
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
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	GameTooltip:SetText(self:GetText())
	local desc, image = db.Bindings:GetDescriptionForBinding(self:GetBinding(), true)
	if desc then
		GameTooltip:AddLine(desc, 1, 1, 1, true)
	end
	if image then
		GameTooltip:AddLine('\n')
		GameTooltip:AddLine(image)
	end
	GameTooltip:Show()
	-- Don't show this tooltip on small screens where it intersects the config
	if UIDoFramesIntersect(GameTooltip, env.Config) then
		GameTooltip:Hide()
	end
end

function Binding:OnLeave()
	CPIndexButtonMixin.OnIndexButtonLeave(self)
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function Binding:OnLoad()
	self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
	CPAPI.Start(self)
end

Binding.KeySeparator = ' | ';

---------------------------------------------------------------
-- Headers
---------------------------------------------------------------
function Wrapper:OnLoad()
	self:SetMeasurementOrigin(self, self.Content, self:GetWidth(), 20)
	CPFocusPoolMixin.OnLoad(self)
	self:SetScript('OnEnter', CPIndexButtonMixin.OnIndexButtonEnter)
	self:SetScript('OnLeave', CPIndexButtonMixin.OnIndexButtonLeave)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingActionTemplate', Binding, nil, self.Content)
end

function Wrapper:OnEvent()
	self:UpdateBinding()
end

function Wrapper:UpdateBinding()
	for widget in self:EnumerateActive() do
		widget:UpdateBinding()
	end
end

function Wrapper:OnExpand()
	self.Hilite:Hide()
	self:SetHeight(nil)
	self:RegisterEvent('UPDATE_BINDINGS')
	self:SetScript('OnEvent', self.OnEvent)
end

function Wrapper:OnCollapse()
	self:UnregisterAllEvents()
	self:SetScript('OnEvent', nil)
	self.Hilite:Show()
	self:SetHeight(40)
	self:ReleaseAll()
end

function Wrapper:OnChecked(show)
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
local Actionbutton, Actionpage, Actionbar = CreateFromMixins(Binding), CreateFromMixins(Wrapper), CreateFromMixins(CPFocusPoolMixin, env.ScaleToContentMixin)

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
	self:SetSize(42, 42)
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
		GameTooltip:AddLine(('%s: %s'):format(KEY_BINDING, slug), GameFontGreen:GetTextColor())
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

Actionbutton.KeySeparator = '\n';
Actionbutton.KeyLimit = 3;

---------------------------------------------------------------
-- Actionpage
---------------------------------------------------------------
function Actionpage:OnLoad()
	self:SetPoint('TOP')
	self:SetMeasurementOrigin(self, self.Content, self:GetWidth(), 20)
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
	Wrapper.OnExpand(self)
	self:SetBackdropBorderColor(CPIndexButtonMixin.IndexColors.Border:GetRGBA())
	self:RegisterEvent('ACTIONBAR_SLOT_CHANGED')
end

function Actionpage:OnCollapse()
	self:UnregisterAllEvents()
	self:SetScript('OnEvent', nil)
	self.Hilite:Show()
	self:SetHeight(40)
end

function Actionpage:SetPages(pages)
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
				widget:SetPoint('TOPLEFT', 6, 0)
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
	CPFocusPoolMixin.OnLoad(self)
	self:SetSize(RIGHT_PANEL_WIDTH, 40)
	self:SetPoint('TOP', anchorTo, 'BOTTOM', 0, -8)
	self:SetMeasurementOrigin(self, self, RIGHT_PANEL_WIDTH, 0)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingActionBarTemplate', Actionpage, nil, self)
	self:SetScript('OnShow', self.OnShow)
	self:Hide()
	self:Show()
end

function Actionbar:OnShow()
	self:ReleaseAll()
	
	local prev;
	for i, pages in ipairs(db.Actionbar.Pages) do
		if pages() then
			local desc = db.Actionbar.Names[pages];
			local widget, newObj = self:TryAcquireRegistered(i)
			if newObj then
				widget:OnLoad()
			end
			widget:SetID(i)
			widget:SetText(desc)
			widget:SetPages(pages)
			widget:Show()
			widget:SetDrawOutline(true)
			if prev then
				widget:SetPoint('TOP', prev, 'BOTTOM', 0, -6)
			else
				widget:SetPoint('TOP')
			end
			prev = widget;
		end
	end
	self:SetHeight(nil)
end

---------------------------------------------------------------
-- Binding manager
---------------------------------------------------------------
function BindingManager:OnShow()
	local bindings, headers, wasUpdated = BindingInfo:RefreshDictionary()
	if not self.bindingsFirstDrawn or wasUpdated then
		self:ReleaseCategories()
		if not self.bindingsFirstDrawn then
			-- Create custom action bar handler
			self.Header = self:CreateHeader('|TInterface\\Store\\category-icon-weapons:18:18:0:0:64:64:18:46:18:46|t  ' .. BINDING_HEADER_ACTIONBAR, nil)
			self.Actionbar = Mixin(CreateFrame('Frame', nil, self.Child), Actionbar)
			self.Actionbar:OnLoad(self.Header)
		end
		self:DrawCategories(bindings, headers)
		self.bindingsFirstDrawn = true;
	end
	self:RegisterEvent('UPDATE_BINDINGS')
end

function BindingManager:OnHide()
	self:UnregisterEvent('UPDATE_BINDINGS')
end

function BindingManager:ReleaseCategories()
	self:ReleaseAll()
	self.Shortcuts:ReleaseAll()
	self.Headers:ReleaseAll()
end

function BindingManager:CreateHeader(group, anchor) group = group:trim()
	local header = self.Headers:Acquire()
	header:SetScript('OnEnter', nop)
	header:SetText(L(group))
	header:Show()
	if anchor then
		header:SetPoint('TOP', anchor, 'BOTTOM', 0, -FIXED_OFFSET * 2)
	else
		header:SetPoint('TOP', 0, -FIXED_OFFSET)
	end
	local shortcut = self.Shortcuts:Create(group, header)
	shortcut:SetWidth(LEFT_PANEL_WIDTH - FIXED_OFFSET * 2)
	return header, shortcut;
end

function BindingManager:DrawCategories(bindings, headers)
	local prev = self.Actionbar;

	for category, set in db.table.spairs(bindings) do
		prev = self:CreateHeader(category, prev)

		local separator = 0;
		for i, data in ipairs(set) do
			if ( data.binding and not data.binding:match('^HEADER_BLANK') ) then
				local widget, newObj = self:Acquire(i)
				if newObj then
					widget:OnLoad()
					widget:SetDrawOutline(true)
				end
				widget:SetText(data.name or data.binding)
				widget:SetAttribute('binding', data.binding)
				widget:Show()
				widget:UpdateBinding()
				widget:SetPoint('TOP', prev, 'BOTTOM', 0, 2-FIXED_OFFSET-separator)
				prev, separator = widget, 0;
			else
				separator = 20;
			end
		end
	end
	self.Child:SetHeight(nil)
	self.Shortcuts:Update()
end

function BindingManager:UpdateBindings()
	for widget in self:EnumerateActive() do
		widget:UpdateBinding()
	end
end

function BindingManager:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	env.OpaqueMixin.OnLoad(self)
	self.Headers = CreateFramePool('Frame', self.Child, 'CPConfigHeaderTemplate')
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingActionTemplate', Binding, nil, self.Child)
	Mixin(self.Child, env.ScaleToContentMixin)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self.Child, self.Child, RIGHT_PANEL_WIDTH, FIXED_OFFSET)
	self:SetScript('OnEvent', self.UpdateBindings)
end