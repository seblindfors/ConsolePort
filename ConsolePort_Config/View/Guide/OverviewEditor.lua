local env, db, _, L = CPAPI.GetEnv(...);
local Guide = env:GetContextPanel();

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local EditType = EnumUtil.MakeEnum('Binding', 'Action')

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
local Editor = {};
---------------------------------------------------------------
Editor.GetSearchTitle = CPAPI.Static(SETTINGS_SEARCH_RESULTS);

function Editor:OnLoad()
	env.SettingsRenderer.Init(self)
	self:SetPoint('TOP')
	self:SetPoint('BOTTOM', 0, 0)
	FrameUtil.SpecializeFrameWithMixins(self.Lip, EditorLip)
	CPScrollBoxSettingsTree.InitDefault(self.Settings)
	RunNextFrame(GenerateClosure(env.RegisterCallback, env, 'Overview.EditInput', self.EditInput, self))
end

function Editor:OnShow()
end

function Editor:OnHide()
	self:SetTargetAction(nil)
	self:SetShown(false)
	env:TriggerEvent('Overview.EditorClosed', self)
end

function Editor:FadeIn()
	db.Alpha.FadeIn(self, 0.2, self:GetAlpha(), 1)
end

function Editor:FadeOut()
	db.Alpha.FadeOut(self, 0.2, self:GetAlpha(), 0)
end

function Editor:OnIndexChanged()
	print('Editor:OnIndexChanged')
end

---------------------------------------------------------------
-- Edit types
---------------------------------------------------------------
function Editor:SetTargetAction(action)
	if self.action then
		self.action:UnlockHighlight()
	end
	self.action = action;
	if action then
		action:LockHighlight()
		return true;
	end
	return false;
end

function Editor:EditInput(action)
	self:FadeIn()
	self:SetShown(true)
	if not self:SetTargetAction(action) then
		return;
	end

	local data = action:GetData()
	if data.actionID then
		return self:EditAction(data)
	end
	return self:EditBinding(data)
end

function Editor:EditBinding(data)
	local interface = self:GetIndex()
	local bindings = interface[SETTING_GROUP_GAMEPLAY];
	local dataProvider = self.Settings:GetDataProvider()

	if self:SetEditType(EditType.Binding) then
		dataProvider:Flush()
		self:Render(dataProvider, ACTIONBARS_LABEL, bindings[ACTIONBARS_LABEL], true)
		self:Render(dataProvider, KEY_BINDINGS_MAC, bindings[KEY_BINDINGS_MAC], true)
	end
end

function Editor:EditAction(data)
	local dataProvider = self.Settings:GetDataProvider()
	local scrollView = self.Settings:GetScrollView()

	if self:SetEditType(EditType.Action) then
		dataProvider:Flush()
	end

	env.Frame:GetLoadoutSelector()
		:SetExternalLip(self.Lip)
		:SetDataProvider(dataProvider)
		:SetScrollView(scrollView)
		:SetCloseCallback(GenerateClosure(self.Hide, self))
		:SetToggleByID(false)
		:EditAction(data.actionID, data.bindingID, self.action)
end

function Editor:SetEditType(newType)
	local prev = self.editType;
	self.editType = newType;
	return prev ~= newType;
end

---------------------------------------------------------------
do -- Initializer
---------------------------------------------------------------
	local function BindingsProvider(AddSetting, GetSortIndex)
		local main, head = SETTING_GROUP_GAMEPLAY, KEY_BINDINGS_MAC;
		local sort = GetSortIndex(main, head);
		local bindings = env.BindingInfo:RefreshDictionary()

		AddSetting(main, head, {
			sort  = sort + 1;
			type  = env.Elements.Title;
			text  = CATEGORIES;
			field = { after = true };
		})

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

		-- Toggle character bindings on/off
		AddSetting(main, head, {
			sort  = 0;
			type  = env.Elements.CharacterBindings;
			field = { before = true };
		})

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
		FrameUtil.SpecializeFrameWithMixins(editor, Editor, env.SettingsRenderer)

		editor:AddProvider(ActionBarProvider)
		editor:AddProvider(BindingsProvider)

		editor:EditInput(input, container)
		container.Editor = editor;
		-- Unregister on next frame since the registry is currently iterating callbacks.
		RunNextFrame(GenerateClosure(env.UnregisterCallback, env, 'Overview.EditInput', self))
	end, Guide)
end