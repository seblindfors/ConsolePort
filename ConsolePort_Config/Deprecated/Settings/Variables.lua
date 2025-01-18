local _, env, db, L = ...; db, L = env.db, env.L;
local PanelMixin, Widgets = {}, env.Widgets;

---------------------------------------------------------------
-- Addon settings
---------------------------------------------------------------
local SHORTCUT_WIDTH, GENERAL_WIDTH, FIXED_OFFSET, DATA_POINT = 284, 700, 8, 1;
local Setting = CreateFromMixins(CPIndexButtonMixin, env.ScaleToContentMixin)
env.SettingMixin = Setting;

function Setting:OnLoad()
	self:SetWidth(GENERAL_WIDTH - 32)
	self:SetMeasurementOrigin(self, self.Content, self:GetWidth(), 100)
	self:SetScript('OnEnter', CPIndexButtonMixin.OnIndexButtonEnter)
	self:SetScript('OnLeave', CPIndexButtonMixin.OnIndexButtonLeave)
end

function Setting:SetDependencies(deps)
	self.deps = CreateFlags(0);
	local flags, callbacks = {}, {};
	for dep, value in db.table.spairs(deps) do
		tinsert(flags, dep)
		callbacks[dep] = self:RegisterDependency(dep, value)
	end
	self.flags = FlagsUtil.MakeFlags(unpack(flags))
	for dep, callback in pairs(callbacks) do
		callback(nil, self.registry(dep))
	end
end

function Setting:RegisterCallback(callbackID, callback, ...)
	self.callbacks = self.callbacks or {};
	self.registry:RegisterCallback(callbackID, callback, self, ...)
	self.callbacks[callbackID] = callback;
	return callback;
end

function Setting:Construct(name, varID, field, newObj, registry, callbackID, owner)
	self:Hide()
	if newObj then
		self.registry = registry;
		self:SetText(L(name))
		local constructor = Widgets[varID] or Widgets[field[DATA_POINT]:GetType()];
		if constructor then
			constructor(self, varID, field, field[DATA_POINT], L(field.desc), L(field.note), owner)

			callbackID = callbackID or ('Settings/'..varID);
			local callback = function(...) registry(callbackID, ...) end;
			self:SetCallback(callback)
			self:RegisterCallback(callbackID, self.OnValueChanged)

			if (field.deps) then
				self:SetDependencies(field.deps)
			end
		end
	end
	self:Show()
end

function Setting:Reset()
	if self.SetCallback then self:SetCallback(nil) end;
	if self.registry and self.callbacks then
		for callbackID in pairs(self.callbacks) do
			self.registry:UnregisterCallback(callbackID, self)
		end
	end
	self.registry, self.callbacks = nil, nil;
end

function Setting:Get()
	return self.registry(self.variableID)
end

do -- Dependencies
	local Comparator = CPAPI.Proxy({
		['function'] = function (lhs, rhs) return not lhs(rhs) end;
	}, function() return function(lhs, rhs) return lhs ~= rhs end end)

	local TriggerDependencyChanged = CPAPI.Proxy({}, function(self, registry)
		return rawset(self, registry, CPAPI.Debounce(
			registry.TriggerEvent, registry, 'OnDependencyChanged'
		))[registry];
	end)

	local function OnDependencyChanged(self, dep, depValue, _, value)
		self.deps:SetOrClear(self.flags[dep], Comparator[type(depValue)](depValue, value))
		self.metaData.hide = self.deps:IsAnySet();
		TriggerDependencyChanged[self.registry](dep)
	end

	function Setting:RegisterDependency(dep, value)
		local callbackID = dep:match('/') and dep or ('Settings/'..dep);
		local callback = GenerateClosure(OnDependencyChanged, self, dep, value)
		return self:RegisterCallback(callbackID, callback)
	end
end

---------------------------------------------------------------
-- Shortcuts
---------------------------------------------------------------
local Shortcut, Shortcuts = {}, CreateFromMixins(CPFocusPoolMixin)
env.SettingShortcutsMixin = Shortcuts;

function Shortcut:OnLoad()
	self.Label:ClearAllPoints()
	self.Label:SetPoint('LEFT', 16, 0)
	self.Label:SetPoint('RIGHT', -16, 0)
	self.Label:SetJustifyH('LEFT')
	self.Label:SetTextColor(1, 1, 1)
	self:SetWidth(SHORTCUT_WIDTH - FIXED_OFFSET * 2)
	self:SetScript('OnClick', self.OnClick)
	self:SetDrawOutline(true)
end

function Shortcut:OnClick()
	self:SetChecked(false)
	self:OnChecked(false)
	if ConsolePort:IsCursorNode(self) then
		return ConsolePort:SetCursorNode(self.reference)
	end
	self.List:ScrollToElement(self.reference, -FIXED_OFFSET)
end

function Shortcuts:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingHeaderTemplate', Shortcut, nil, self.Child)
	Mixin(self.Child, env.ScaleToContentMixin)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self, self.Child, SHORTCUT_WIDTH, FIXED_OFFSET)
end

function Shortcuts:OnHide()
	self:ReleaseAll()
	self.lastWidget = nil;
end

function Shortcuts:Create(name, ref)
	local widget, newObj = self:Acquire(name)
	local anchor = self.lastWidget;
	if newObj then
		widget.List = self.List;
		widget:OnLoad()
	end
	widget:ClearAllPoints()
	if anchor then
		widget:SetAttribute('nodepriority', nil)
		widget:SetPoint('TOP', anchor, 'BOTTOM', 0, -FIXED_OFFSET)
	else
		widget:SetAttribute('nodepriority', 1)
		widget:SetPoint('TOP', 0, -FIXED_OFFSET)
	end
	widget:Show()
	widget:SetText(L(name))
	widget.reference = ref;
	self.lastWidget = widget;
	return widget;
end

---------------------------------------------------------------
-- Options
---------------------------------------------------------------
local Options = CreateFromMixins(CPFocusPoolMixin)
env.SettingListMixin = Options;

function Options:CreateHeader(group, anchor)
	local header = self.headerPool:Acquire()
	header:SetScript('OnEnter', nop)
	header:SetText(L(group))
	header:Show()
	if anchor then
		header:SetPoint('TOP', anchor, 'BOTTOM', 0, -FIXED_OFFSET * 2)
	else
		header:SetPoint('TOP', 0, -FIXED_OFFSET)
	end
	return header, self.Shortcuts:Create(group, header);
end

function Options:DrawOptions()
	self.headerPool:ReleaseAll()
	self.Shortcuts:OnHide()

	-- sort settings by group
	local sorted = {};
	local showAdvanced = db('showAdvancedSettings')

	foreach(db('Variables'), function(var, data)
		local group = data.head or MISCELLANEOUS;

		if data.hide or not showAdvanced and data.advd then
			local widget = self:GetObjectByIndex(group..':'..data.name)
			return widget and widget:Hide()
		end

		if not sorted[group] then
			sorted[group] = {};
		end

		sorted[group][data.name] = {
			varID = var;
			field = data;
		};
	end)

	-- sort groups by display order first, key second
	local function displaysort(t, a, b)
		local iA, iB = t[a].field.sort, t[b].field.sort;
		if iA and not iB then
			return true;
		elseif iB and not iA then
			return false;
		elseif iA and iB then
			return iA < iB;
		else
			return a < b;
		end
	end

	local prev;
	for group, set in db.table.spairs(sorted) do
		-- render the header
		prev = self:CreateHeader(group, prev)

		-- render the options
		for name, data in db.table.spairs(set, displaysort) do
			local widget, newObj = self:TryAcquireRegistered(group..':'..name)
			if newObj then
				widget.Label:ClearAllPoints()
				widget.Label:SetPoint('LEFT', 16, 0)
				widget.Label:SetJustifyH('LEFT')
				widget.Label:SetTextColor(1, 1, 1)
				widget:SetDrawOutline(true)
				widget:OnLoad()
			end
			widget:Construct(name, data.varID, data.field, newObj, db)
			widget:SetPoint('TOP', prev, 'BOTTOM', 0, -FIXED_OFFSET)
			prev = widget;
		end
	end
	self.Child:SetHeight(nil)
	self.Shortcuts.Child:SetHeight(nil)
end

function Options:OnShow()
	self:DrawOptions()
end

function Options:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	env.OpaqueMixin.OnLoad(self)
	self.headerPool = CreateFramePool('Frame', self.Child, 'CPConfigHeaderTemplate')
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingHeaderTemplate', Setting, nil, self.Child)
	Mixin(self.Child, env.ScaleToContentMixin)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self, self.Child, GENERAL_WIDTH, FIXED_OFFSET * 2)

	db:RegisterCallback('Settings/showAdvancedSettings', self.DrawOptions, self)
	db:RegisterCallback('OnToggleCharacterSettings', self.DrawOptions, self)
	db:RegisterCallback('OnDependencyChanged', self.DrawOptions, self)
	db:RegisterCallback('OnVariablesChanged', self.DrawOptions, self)
end

---------------------------------------------------------------
-- Panel
---------------------------------------------------------------
function PanelMixin:OnFirstShow()
	local Carpenter = LibStub('Carpenter')
	local metaVars = {
		ShowAdvanced = {
			_Type  = 'IndexButton';
			_Setup = 'CPIndexButtonBindingHeaderTemplate';
			_Point = {'TOP', 0, -FIXED_OFFSET*5};
			meta = 'showAdvancedSettings';
		};
		CharacterSettings = {
			_Type  = 'IndexButton';
			_Setup = 'CPIndexButtonBindingHeaderTemplate';
			_Point = {'TOP', '$parent.ShowAdvanced', 'BOTTOM', 0, -FIXED_OFFSET};
			meta = 'useCharacterSettings';
			call = 'OnToggleCharacterSettings';
			pred = function() return ConsolePortCharacterSettings ~= nil end;
		};
	};

	local varContainer = Carpenter:BuildFrame(self, {
		MetaVars = {
			_Type  = 'Frame';
			_Setup = 'BackdropTemplate';
			_Level = 2;
			_Width = SHORTCUT_WIDTH + 1;
			_Points = {
				{'TOPLEFT', 0, 0};
				{'BOTTOMLEFT', '$parent', 'TOPLEFT', 0, -(((50 + FIXED_OFFSET)*2) + 25)};
			};
			metaVars;
		};
		LeftBackground = {
			_Type  = 'Frame';
			_Setup = 'BackdropTemplate';
			_Mixin = env.OpaqueMixin;
			_Backdrop = CPAPI.Backdrops.Opaque;
			_Width = SHORTCUT_WIDTH + 1;
			_Level = 1;
			_Points = {
				{'TOPLEFT', 0, 0};
				{'BOTTOMLEFT', 0, 0};
			};
		};
	}, false, true).MetaVars;

	local headerCategories = Carpenter:BuildFrame(varContainer, {
		HeaderSettings = {
			_Type  = 'Frame';
			_Setup = 'CPAnimatedLootHeaderTemplate';
			_Width = SHORTCUT_WIDTH;
			_Point = {'TOP', FIXED_OFFSET * 3, -FIXED_OFFSET};
			_Text  = ADVANCED_LABEL;
		};
		HeaderCategories = {
			_Type  = 'Frame';
			_Setup = 'CPAnimatedLootHeaderTemplate';
			_Width = SHORTCUT_WIDTH;
			_Point = {'BOTTOM', FIXED_OFFSET * 3, -FIXED_OFFSET*3};
			_Text  = CATEGORIES;
		};
	}, false, true).HeaderCategories;

	for child, data in db.table.spairs(metaVars) do
		local var = varContainer[child];
		local field = db('Variables/'.. var.meta)
		if var.pred then
			field[1]:Set(var.pred())
		end
		env.db.table.mixin(var, Setting)
		Setting.OnLoad(var)
		Shortcut.OnLoad(var)
		var:SetWidth(SHORTCUT_WIDTH - FIXED_OFFSET * 2)
		var:Construct(field.name, var.meta, field, true, db, var.call)
	end

	local shortcuts = self:CreateScrollableColumn('Shortcuts', {
		_Mixin = Shortcuts;
		_Width = SHORTCUT_WIDTH;
		_Level = 2;
		_Setup = {'CPSmoothScrollTemplate'};
		_Points = {
			{'TOPLEFT', '$parent.MetaVars', 'BOTTOMLEFT', 0, -FIXED_OFFSET *3};
			{'BOTTOMLEFT', 0, 1};
		};
	})
	local options = self:CreateScrollableColumn('Options', {
		_Mixin = Options;
		_Width = GENERAL_WIDTH;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', '$parent.LeftBackground', 'TOPRIGHT', 0, 0};
			{'BOTTOMLEFT', '$parent.LeftBackground', 'BOTTOMRIGHT', 0, 0};
		};
	})


	db:RegisterCallback('Settings/showAdvancedSettings', function(self)
		self:Play()
		options:SetVerticalScroll(0)
		db.Alpha.FadeIn(shortcuts, 1, 0, 1)
		db.Alpha.FadeIn(options, 1.5, 0, 1)
	end, headerCategories)

	options.Shortcuts = shortcuts;
	shortcuts.List = options;
end

env.Options = ConsolePortConfig:CreatePanel({
	name  = INTERFACE_LABEL;
	mixin = PanelMixin;
	scaleToParent = true;
	forbidRecursiveScale = true;
})