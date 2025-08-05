local env, db = CPAPI.GetEnv(...);
local Guide = env:GetContextPanel();

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local EditType = EnumUtil.MakeEnum('Binding', 'Action')
local EDIT_AB = ('%s: %s'):format(EDIT, BINDING_NAME_ACTIONBUTTON1:gsub('%d', ''))
local EDIT_KB = ('%s: %s'):format(EDIT, KEY_BINDING)

---------------------------------------------------------------
local EditorLip = CreateFromMixins(CPScrollBoxLip)
---------------------------------------------------------------

function EditorLip:OnLoad()
	self:InitDefault()
end

function EditorLip:GetLipHeight()
	return self:GetScrollView():GetExtent() + 2;
end

---------------------------------------------------------------
local BindingIcon = CreateFromMixins(env.Elements.BindingIcon)
---------------------------------------------------------------

function BindingIcon:OnIconChanged(result, saveResult)
	local parent     = self:GetParent()
	local parentData = parent:GetElementData():GetData()
	local bindingID  = parentData.bindingID;
	parent.Icon:SetTexture(parentData.element:DetermineIcon(result, nil, bindingID))
	if saveResult then
		db.Bindings:SetIcon(bindingID, result)
	end
end

---------------------------------------------------------------
local BindingSlotter = CreateFromMixins(env.Elements.ActionSlotter)
---------------------------------------------------------------
BindingSlotter.xml = 'CPOverviewBindingMapper';

function BindingSlotter:Data(datapoint)
	local data = env.Elements.ActionSlotter.Data(self, datapoint)
	data.bindingID = datapoint.binding;
	data.chord     = datapoint.chord;
	data.element   = datapoint.element;
	data.hasAction = datapoint.slot > 0 and datapoint.slot ~= CPAPI.ExtraActionButtonID;
	return data;
end

function BindingSlotter:OnAcquire(new)
	if new then
		Mixin(self, BindingSlotter)
		self:SetScript('OnEvent', CPAPI.EventMixin.OnEvent)
		self:EnableMouse(false)
		self.InnerContent:SetScale(0.5) -- correct the background scale
		CPAPI.Specialize(self.BindingIcon, BindingIcon)
	end
	self:InitButtons()
	self.Info:SetPoint('TOPLEFT', 46, 0)
	self.Info:SetPoint('BOTTOMRIGHT', self[1], 'BOTTOMLEFT', -4, 0)
	db:RegisterCallback('OnActionPageChanged', self.UpdateActivePage, self)
	env:RegisterCallback('OnActionSlotHighlight', self.UpdateSlotHighlight, self)
	self:RegisterEvent('ACTIONBAR_SLOT_CHANGED')
end

function BindingSlotter:OnRelease()
	local button = self[1];
	if button then
		button:UnlockHighlight()
		env.Elements.ActionbarMapper.ReleaseActionbarMapperButton(button)
		self[1] = nil;
	end
	db:UnregisterCallback('OnActionPageChanged', self)
	env:UnregisterCallback('OnActionSlotHighlight', self)
	self:UnregisterEvent('ACTIONBAR_SLOT_CHANGED')
end

function BindingSlotter:UpdateChildren(data)
	local button = self[1];
	local hasAction = data.hasAction;
	button:SetID(data.slot)
	button:SetShown(hasAction)
	button:SetOnClickEvent('Overview.OnActionClicked')
	button:SetPairMode(true)
	button:SetEditMode(true)
	button:SetPairText(EDIT_AB)

	local binding = self.Binding;
	binding:SetShown(not hasAction)
	binding:SetText(hasAction and '' or db.Hotkeys:GetButtonSlugForChord(data.chord, false, true, ' '))

	local bindingIcon = self.BindingIcon;
	bindingIcon:SetShown(not hasAction and data.bindingID)
end

function BindingSlotter:OnInfoEnter()
	local data = self:GetElementData():GetData()
	if ( data.hasAction ) then
		return env.Elements.ActionbarMapper.OnInfoEnter(self)
	end
	return ExecuteFrameScript(data.element, 'OnEnter')
end

function BindingSlotter:OnInfoLeave()
	local data = self:GetElementData():GetData()
	if ( data.hasAction ) then
		return env.Elements.ActionbarMapper.OnInfoLeave(self)
	end
	return ExecuteFrameScript(data.element, 'OnLeave')
end

---------------------------------------------------------------
local Editor = {};
---------------------------------------------------------------
Editor.GetSearchTitle = CPAPI.Static(SETTINGS_SEARCH_RESULTS);

function Editor:OnLoad()
	env.SettingsRenderer.Init(self)
	self:SetPoint('TOP')
	self:SetPoint('BOTTOM', 0, 0)
	CPAPI.SpecializeOnce(self.Lip, EditorLip)
	CPScrollBoxSettingsTree.InitDefault(self.Settings)
	CPAPI.Next(env.RegisterCallback, env, 'Overview.EditInput', self.EditInput, self)

	env:RegisterCallback('Overview.OnActionClicked', self.OnActionClicked, self)
	env:RegisterCallback('Overview.OnBindingClicked', self.OnBindingClicked, self)
	env:RegisterCallback('Overview.OnHide', self.ReleaseIndex, self)
end

function Editor:OnHide()
	self:SetTargetChord(nil)
	self:SetShown(false)
	env:TriggerEvent('Overview.EditorClosed', self)
	if self.returnToNode then
		ConsolePort:SetCursorNodeIfActive(self.returnToNode)
		self.returnToNode = nil;
	end
end

function Editor:FadeIn()
	db.Alpha.FadeIn(self, 0.2, self:GetAlpha(), 1)
end

function Editor:FadeOut()
	db.Alpha.FadeOut(self, 0.2, self:GetAlpha(), 0)
end

function Editor:OnIndexChanged()
	self:SetEditType(nil)
	self:Reindex()
	self:EditBinding(self.chord:GetData())
end

function Editor:OnActionClicked()
	self:EditAction(self.chord:GetData())
end

function Editor:OnBindingClicked(bindingID, _, readOnlyText)
	if readOnlyText then
		return UIErrorsFrame:AddMessage(readOnlyText:trim(), 1.0, 0.1, 0.1, 1.0);
	end
	if self.chord:SetBinding(bindingID) then
		self:EditBinding(self.chord:GetData())
	end
end

---------------------------------------------------------------
-- Edit types
---------------------------------------------------------------
function Editor:SetTargetChord(chord)
	if self.chord then
		self.chord:UnlockHighlight()
	end
	self.chord = chord;
	if chord then
		chord:LockHighlight()
		return true;
	end
	return false;
end

function Editor:EditInput(chord)
	self:FadeIn()
	self:SetShown(true)
	self.returnToNode = nil;
	if not self:SetTargetChord(chord) then
		return error('OverviewEditor:EditInput called with no chord.')
	end
	return self:EditBinding(chord:GetData())
end

function Editor:EditBinding(data)
	local interface = self:GetIndex()
	local bindings = interface[SETTING_GROUP_GAMEPLAY];
	local dataProvider = self.Settings:GetDataProvider()

	if self:SetEditType(EditType.Binding) then
		dataProvider:Flush()
		self:Render(dataProvider, GENERAL, bindings[GENERAL], false, false, true, true)
		self:Render(dataProvider, ACTIONBARS_LABEL, bindings[ACTIONBARS_LABEL], true)
		self:Render(dataProvider, KEY_BINDINGS_MAC, bindings[KEY_BINDINGS_MAC], true)
	end

	local lipProvider = self.Lip:GetDataProvider()
	lipProvider:Flush()

	local Elements = env.Elements;
	for i, element in ipairs({
		Elements.Title:New(EDIT_KB);
		BindingSlotter:New(self:GetSlotterData(data));
		Elements.Divider:New(1);
		Elements.Back:New({
			callback = GenerateClosure(self.Hide, self);
		});
		Elements.Button:New({
			text  = REMOVE;
			atlas = 'common-icon-redx';
			callback = function()
				env:SetBinding(data.chord, nil)
				self:EditBinding(self.chord:GetData())
			end;
		});
		Elements.Search:New({
			dispatch = false;
			callback = function(text)
				self:HandleBindingSearch(text, dataProvider)
			end
		});
	}) do
		lipProvider:InsertAtIndex(element, i)
	end
	self.Lip:SetOwner(self.Settings:GetScrollView())

	-- Set focus to the back button.
	CPAPI.Next(function()
		local lipScrollView = self.Lip:GetScrollView()
		local elementData, target = self.Lip:FindFirstOfType(env.Elements.Back, lipScrollView)
		if elementData then
			target = lipScrollView:FindFrame(elementData)
		end
		if target then
			if not self.returnToNode then
				self.returnToNode = self.chord;
			end
			return ConsolePort:SetCursorNodeIfActive(target)
		end
	end)
end

function Editor:EditAction(data)
	local dataProvider = self.Settings:GetDataProvider()
	local scrollView = self.Settings:GetScrollView()
	local lip = self.Lip:Invalidate()

	if self:SetEditType(EditType.Action) then
		dataProvider:Flush()
	end

	env.Frame:GetLoadoutSelector()
		:SetAlternateTitle(EDIT_AB)
		:SetExternalLip(lip)
		:SetDataProvider(dataProvider)
		:SetScrollView(scrollView)
		:SetCloseCallback(function()
			self:EditBinding(self.chord:GetData())
		end)
		:SetToggleByID(false)
		:EditAction(data.actionID, data.bindingID, self.action)
end

function Editor:SetEditType(newType)
	local prev = self.editType;
	self.editType = newType;
	return prev ~= newType;
end

---------------------------------------------------------------
-- Bindings handling
---------------------------------------------------------------

function Editor:GetSlotterData(data)
	local slotter = env.LoadoutSelector.GetSlotterData(self, data.actionID or 0)
	slotter.binding = data.bindingID;
	slotter.chord   = data.chord;
	slotter.element = self.chord;
	if not data.actionID then
		slotter.field.icon = data.texture;
		slotter.field.name = data.name;
	end
	return slotter;
end

function Editor:HandleBindingSearch(text, results)
	if text then
		results:Flush()
		self:OnSearch(text, results)
		if results:IsEmpty() then
			results:Insert(env.Elements.Title:New(SEARCH))
			results:Insert(env.Elements.Results:New(SETTINGS_SEARCH_NOTHING_FOUND:gsub('%. ', '.\n')))
		end
		return;
	end
	self:SetEditType(nil)
	self:EditBinding(self.chord:GetData())
end

---------------------------------------------------------------
do -- Initializer
---------------------------------------------------------------
	local function GeneralSettingsProvider(AddSetting, GetSortIndex)
		local main, head = SETTING_GROUP_GAMEPLAY, GENERAL;

		-- Toggle character bindings on/off
		AddSetting(main, head, {
			sort  = GetSortIndex(main, head);
			type  = env.Elements.CharacterBindings;
			field = { after = true };
		})
	end

	local function BindingsProvider(AddSetting, GetSortIndex)
		local main, head = SETTING_GROUP_GAMEPLAY, KEY_BINDINGS_MAC;
		local sort = GetSortIndex(main, head);
		local bindings = env.BindingInfo:RefreshDictionary()

		for category, set in env.table.spairs(bindings) do
			local list = category:trim();
			head = list == KEY_BINDINGS_MAC and ACTIONBARS_LABEL or KEY_BINDINGS_MAC;
			sort = GetSortIndex(main, head);
			for i, info in ipairs(set) do
				AddSetting(main, head, {
					sort     = sort + i;
					type     = env.Elements.Binding;
					binding  = info.binding;
					readonly = info.readonly or nop;
					pair     = true;
					event    = 'Overview.OnBindingClicked';
					field = {
						name = info.name;
						list = list;
						xtra = true;
					};
				})
			end
		end
	end

	local function ActionBarProvider(AddSetting, GetSortIndex)
		local main, head = SETTING_GROUP_GAMEPLAY, ACTIONBARS_LABEL;
		local sort = GetSortIndex(main, head);

		for groupID, container in db:For('Actionbar/Pages') do
			local shouldDrawBars = container();
			if shouldDrawBars then
				for barIndex, barID in ipairs(container) do
					local list, name, icon, prio;

					local stanceBarInfo = db.Actionbar.Lookup.Stances[barID];
					if stanceBarInfo and stanceBarInfo.name then
						list = PRIMARY;
						icon = stanceBarInfo.iconID;
						name = stanceBarInfo.name;
						prio = 10;
					else
						list = db.Actionbar.Names[container];
						name = db.Actionbar.Names[barID];
						prio = 100;
					end

					AddSetting(main, head, {
						type  = env.Elements.ActionbarMapper;
						sort  = sort + groupID * prio + barIndex;
						bar   = barID;
						pair  = true;
						event = 'Overview.OnBindingClicked';
						field = {
							name = name;
							list = list;
							icon = icon;
							advd = true;
							expd = list == PRIMARY;
							info = stanceBarInfo;
						};
					})
				end
			end
		end

		return 'OnShapeshiftFormInfoChanged', 'Settings/bindingShowExtraBars';
	end

	env:RegisterCallback('Overview.EditInput', function(self, input, container)
		local editor = CreateFrame('Frame', nil, container, 'CPOverviewEditor')
		CPAPI.Specialize(editor, Editor, env.SettingsRenderer)

		editor:AddProvider(GeneralSettingsProvider)
		editor:AddProvider(ActionBarProvider)
		editor:AddProvider(BindingsProvider)

		editor:EditInput(input, container)
		container.Editor = editor;
		CPAPI.Next(env.UnregisterCallback, env, 'Overview.EditInput', self)
	end, Guide)
end