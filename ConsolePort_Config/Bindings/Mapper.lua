local _, env = ...; local db = env.db;
local Mapper = CreateFromMixins(env.FlexibleMixin, env.BindingInfoMixin)
local ActionMapper = CreateFromMixins(CPFocusPoolMixin, env.ScaleToContentMixin, env.BindingInfoMixin)
local BindingHTML = {};
env.BindingMapper, env.BindingActionMapper, env.BindingHTML = Mapper, ActionMapper, BindingHTML;

---------------------------------------------------------------
-- Mapper
---------------------------------------------------------------
function Mapper:OnLoad()
	env.OpaqueMixin.OnLoad(self)
	self:SetFlexibleElement(self, 360)

	Mixin(self.Child, env.ScaleToContentMixin)
	self.Child:SetWidth(360)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self.Child, self.Child, 360, 40)
	CPAPI.Start(self)
end

function Mapper:OnEvent(event, ...)
	if (event == 'UPDATE_BINDINGS' or event == 'ACTIONBAR_SLOT_CHANGED') then
		self:SetBindingInfo(self:GetBinding())
	end
end

---------------------------------------------------------------
-- Binding content handling
---------------------------------------------------------------
function Mapper:SetBindingInfo(binding, transposedActionID)
	if binding then
		self:SetVerticalScroll(0)
		local option = self.Child.Option;
		local name = self:GetBindingName(binding)
		local label, texture, actionID = self:GetBindingInfo(binding, true)
		local slug, data = db('Hotkeys'):GetButtonSlugForBinding(binding)
		texture = actionID and GetActionTexture(transposedActionID or actionID)

		-- HACK: handle extra action button 1 case
		if (transposedActionID == 169 or actionID == 169) then
			transposedActionID, texture = nil, nil;
		end

		-- Set the text for the transposed action ID, make it clear
		-- which action page this widget was coming from.
		if transposedActionID then
			local page = math.ceil(transposedActionID/NUM_ACTIONBAR_BUTTONS)
			page = WrapTextInColorCode(('('..PAGE_NUMBER..')'):format(page), 'FF999999')
			label = ('%s %s'):format(label, page)
		end

		-- dispatch to action mapper
		option.Action:SetAction(transposedActionID)

		-- dispatch to HTML display
		self.Child.Desc:SetContent(db.Bindings:GetDescriptionForBinding(binding))

		-- set top header and key binding slug
		self.Child.Change.Slug:SetText(slug or WrapTextInColorCode(NOT_BOUND, 'FF757575'))
		self.Child.Info.Label:SetText(label)

		-- set action texture
		option.ActionIcon:SetAlpha(texture and 1 or 0)
		option.Mask:SetAlpha(texture and 1 or 0)
		option.ActionIcon:SetTexture(texture)
	end
	self.Child:SetHeight(nil)
end

---------------------------------------------------------------
-- Focused widget
---------------------------------------------------------------
function Mapper:SetFocus(widget)
	self.focusWidget = widget;
	local binding = widget and widget:GetBinding();
	local readonly = binding and self:IsReadonlyBinding(binding);
	if binding and not db.Gamepad:GetBindingKey(binding) then
		if readonly then
			self:SetCatchButton(false)
		else
			self:SetCatchButton(true)
		end
	else
		self:SetCatchButton(false)
		-- HACK: route it to the close button first, so it has
		-- a fallback if going straight into manual rebinding.
		db('Cursor'):SetCurrentNode(self.Child.Close, true)
		db('Cursor'):SetCurrentNode(self.Child.Change, true)
	end
	self.Child.Change:SetEnabled(not readonly)
end

function Mapper:GetFocus()
	return self.focusWidget;
end

function Mapper:ClearFocus(newObj)
	if self.focusWidget then
		self.focusWidget:SetChecked(false)
		CPIndexButtonMixin.OnChecked(self.focusWidget, false)
		if not newObj then
			db('Cursor'):SetCurrentNode(self.focusWidget, true)
		end
		self.focusWidget = nil;
	end
end

function Mapper:GetBinding()
	return self:GetFocus():GetBinding()
end

function Mapper:IsWidgetFocused(widget)
	return (widget and self:GetFocus() == widget)
end

function Mapper:ToggleWidget(widget, show)
	if self:IsWidgetFocused(widget) then
		self:ClearFocus()
	elseif widget then
		self:ClearFocus(widget)
		self:SetFocus(widget)
	else
		self:ClearFocus()
	end
	self:OnWidgetSet(self:GetFocus())
end

function Mapper:OnWidgetSet(widget)
	self:ToggleFlex(widget)
	if widget then
		self:SetBindingInfo(widget:GetBinding())
		self:RegisterEvent('UPDATE_BINDINGS')
		self:RegisterEvent('ACTIONBAR_SLOT_CHANGED')
	else
		self:SetCatchButton(false)
		self:UnregisterAllEvents()
	end
	-- todo
end

---------------------------------------------------------------
-- Binding catch, set, clear olds
---------------------------------------------------------------
function Mapper:ClearBinding()
	db.table.map(SetBinding, db.Gamepad:GetBindingKey(self:GetBinding()))
end

function Mapper:SetBinding(keychord)
	local binding, transposedActionID = self:GetBinding()
	if not db('bindingOverlapEnable') then
		db.table.map(SetBinding, db.Gamepad:GetBindingKey(binding))
	end
	SetBinding(keychord, binding)
	self:SetBindingInfo(binding, transposedActionID)
end

function Mapper:SetCatchButton(enabled)
	self.Child.Catch:SetShown(enabled)
	if enabled then
		local binding = self:GetBinding()
		local name = binding and self:GetBindingName(binding)
		self.Child.Help:SetBindingHelp(name)
	else
		self.Child.Help:SetDefaultHelp()
	end
end

function Mapper:OnButtonCaught(button)
	if CPAPI.IsButtonValidForBinding(button) then
		self:SetBinding(CPAPI.CreateKeyChord(button))
		return true;
	end
end

---------------------------------------------------------------
-- Action mapper
---------------------------------------------------------------
local Action, Collection = {}, CreateFromMixins(CPFocusPoolMixin, env.ScaleToContentMixin, {
	rowSize = 7;
});

function Action:OnLoad()
	self.Slug:SetTextColor(1, 1, 1)
	self:SetDrawOutline(true)
	CPAPI.Start(self)
end

function Action:OnEnter()
	local tooltipFunc = self.tooltip;
	if tooltipFunc then
		GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
		tooltipFunc(GameTooltip, self:GetValue())
		GameTooltip:Show()
	end
end

function Action:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function Action:OnHide()
	self:OnLeave()
end

function Action:OnClick()
	local pickup = self.pickup;
	local actionID = env.Bindings.Mapper.Child.Option.Action.actionID;
	if pickup and actionID then
		pickup(self:GetValue())
		CPAPI.PutActionInSlot(actionID)
		ClearCursor()
	end
	CPIndexButtonMixin.Uncheck(self)
end

function Action:SetValue(value)
	self.value = value;
end

function Action:GetValue()
	if (type(self.value) == 'table') then
		return unpack(self.value)
	end
	return self.value;
end

function Action:Update()
	local texture = self.texture and self.texture(self:GetValue())
	self.Icon:SetTexture(texture or CPAPI.GetAsset([[Textures\Button\EmptyIcon]]))
	self.Icon:SetDesaturated(not texture or false)
	if not texture then
		self.Icon:SetVertexColor(0.5, 0.5, 0.5, 1)
	else
		self.Icon:SetVertexColor(1, 1, 1, 1)
	end

	local slug = self.text and self.text(self:GetValue())
	self.Slug:SetText(slug)
end

function Collection:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	self:SetWidth(320)
	self:SetMeasurementOrigin(self, self.Content, self:GetWidth(), 10)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingActionButtonTemplate', Action, nil, self.Content)
end

function Collection:SetData(data)
	self.data = data;
end

function Collection:Update()
	self:ReleaseAll()

	local data = self.data;
	local numRows, prevCol, prevRow = 0;

	for i, item in ipairs(data.items) do
		local widget, newObj = self:Acquire(i)
		if newObj then
			widget:OnLoad()
		end
		Mixin(widget, data)
		widget:SetValue(item)
		widget:Update()
		widget:Show()
		if (i == 1) then
			widget:SetPoint('TOPLEFT', 8, -8)
			prevRow, numRows = widget, 1;
		elseif (i % self.rowSize == 1) then
			widget:SetPoint('TOP', prevRow, 'BOTTOM', 0, -6)
			prevRow, numRows = widget, numRows + 1;
		else
			widget:SetPoint('LEFT', prevCol, 'RIGHT', 6, 0)
		end
		prevCol = widget;
	end
	self:SetHeight(nil)
end

function Collection:OnExpand()
	self.Hilite:Hide()
	self:ReleaseAll()
	self:Update()
end

function Collection:OnCollapse()
	self.Hilite:Show()
	self:ReleaseAll()
	self:SetHeight(40)
end

function Collection:OnChecked(show)
	CPIndexButtonMixin.OnChecked(self, show)
	self.Content:SetShown(show)
	if show then
		self:OnExpand()
	else
		self:OnCollapse()
	end
end

---------------------------------------------------------------
-- Action map container
---------------------------------------------------------------
function ActionMapper:OnLoad()
	self:SetMeasurementOrigin(self, self.Content, self:GetWidth(), 0)

	-- HACK: call SetBackdrop on show with nil value, since OnShow has no args.
	self.Tooltip = CreateFrame('GameTooltip',
		'ConsolePortConfigBindingMapperTooltip', self, 'GameTooltipTemplate');
	self.Tooltip.NineSlice:HookScript('OnShow', self.Tooltip.NineSlice.Hide)

	CPFocusPoolMixin.OnLoad(self)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingActionBarTemplate', Collection, nil, self.Content)
end

function ActionMapper:OnEvent(event, ...)
	for widget in self:EnumerateActive() do
		widget:ReleaseAll()
		widget:Uncheck()
	end
	self:ReleaseAll()
	self:OnExpand()
end

function ActionMapper:OnHide()
	self:GetParent():SetText(nil)
end

function ActionMapper:OnShow()
	if self.actionID then
		self:Update(self.actionID)
	else
		self:Clear()
	end
end

function ActionMapper:Clear()
	self.actionID = nil;
	self:Hide()
end

function ActionMapper:Update(actionID)
	local tooltip, option = self.Tooltip, self:GetParent();
	tooltip:SetOwner(option, 'ANCHOR_NONE')
	tooltip:SetPoint('TOP', option, 'BOTTOM', 0, 10)
	tooltip:SetAction(actionID)
	tooltip:Show()
	if GetActionInfo(actionID) and tooltip:IsShown() then
		self:SetPoint('TOP', option, 'BOTTOM', 0, -10-tooltip:GetHeight())
		option:SetText(CURRENTLY_EQUIPPED)
	else
		self:SetPoint('TOP', option, 'BOTTOM', 0, -10)
		option:SetText(SETTINGS)
	end
end

function ActionMapper:SetAction(actionID)
	self.actionID = actionID;
	if not self:IsShown() then
		self:Show()
	else
		self:OnShow()
	end
end

-- TODO: bug with the widget pool showing wrong col after expand/collapse
function ActionMapper:OnExpand()
	self.Hilite:Hide()
	-- low-prio todo: maybe move these into collections
	if CPAPI.IsRetailVersion then
		self:RegisterEvent('PET_SPECIALIZATION_CHANGED')
		self:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
		self:RegisterEvent('PLAYER_PVP_TALENT_UPDATE')
		self:RegisterEvent('PLAYER_TALENT_UPDATE')
		self:RegisterEvent('NEW_MOUNT_ADDED')
	end
	self:RegisterEvent('BAG_UPDATE_DELAYED')
	self:RegisterEvent('UPDATE_MACROS')
	local prev
	for i, collection in ipairs(self:GetCollections()) do
		local widget, newObj = self:TryAcquireRegistered(i)
		if newObj then
			widget:OnLoad()
		end
		widget:SetText(collection.name)
		widget:SetData(collection)
		widget:Show()
		if prev then
			widget:SetPoint('TOP', prev, 'BOTTOM', 0, -6)
		else
			widget:SetPoint('TOP')
		end
		prev = widget;
	end
	self:SetHeight(nil)
end

function ActionMapper:OnCollapse()
	self.Hilite:Show()
	self:SetHeight(40)
	self:ReleaseAll()
	self:UnregisterAllEvents()
end

function ActionMapper:OnChecked(show)
	CPIndexButtonMixin.OnChecked(self, show)
	self.Content:SetShown(show)
	if show then
		self:OnExpand()
	else
		self:OnCollapse()
	end
end

---------------------------------------------------------------
-- Binding HTML container
---------------------------------------------------------------
function BindingHTML:SetContent(desc, image)
	if desc or image then
		local wrapper = ('<html><body>%s</body></html>');
		local content = '';
		if desc then
			content = ('<br/><h1 align="center">%s</h1><br/><p>%s</p>'):format(DESCRIPTION,
				desc:gsub('\t+', ''):gsub('\n\n', '<br/><br/>'))
		end
		if image then
			content = content .. ('<br/><br/><img src="%s" align="%s" width="%s" height="%s"/>'):format(
				image.file,
				image.align or 'CENTER',
				image.width or '340',
				image.height 
			);
		end
		self:SetText(wrapper:format(content))
		return self:Show()
	end
	self:Hide()
end

function BindingHTML:OnLoad()
	self:SetFontObject(CPSubtitleFont)

	self:SetFont('p', [[Fonts\FRIZQT__.ttf]], 14, '')
	self:SetFont('h2', Game13Font:GetFont())
	self:SetFont('h1', CPSubtitleFont:GetFont())

	self:SetTextColor('p', 1, 1, 1)
	self:SetTextColor('h1', Fancy22Font:GetTextColor())
	self:SetTextColor('h2', Fancy22Font:GetTextColor())
end