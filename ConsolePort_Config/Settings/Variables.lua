local _, env, db, L = ...; db, L = env.db, env.L;
local PanelMixin, Widgets = {}, env.Widgets;

---------------------------------------------------------------
-- Addon settings
---------------------------------------------------------------
local SHORTCUT_WIDTH, GENERAL_WIDTH, FIXED_OFFSET, OPTION_HEIGHT = 284, 700, 8, 40;
local Setting = CreateFromMixins(CPIndexButtonMixin, env.ScaleToContentMixin)

function Setting:OnLoad()
	self:SetWidth(GENERAL_WIDTH - 32)
	self:SetMeasurementOrigin(self, self.Content, self:GetWidth(), 100)
	self:SetScript('OnEnter', CPIndexButtonMixin.OnIndexButtonEnter)
	self:SetScript('OnLeave', CPIndexButtonMixin.OnIndexButtonLeave)
end

function Setting:Construct(name, varID, field, newObj)
	if newObj then
		self:SetText(L(name))
		local constructor = Widgets[varID] or Widgets[field[1]:GetType()];
		if constructor then
			constructor(self, varID, field, field[1], field.desc, field.note)
			self.controller:SetCallback(function(...) db('Settings/'..varID, ...) end)
			db:RegisterCallback('Settings/'..varID, self.OnValueChanged, self)
		end
	end
	self:Hide()
	self:Show()
end

function Setting:Get()
	return db(self.variableID)
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
	if db.Cursor:IsCurrentNode(self) then
		return db.Cursor:SetCurrentNode(self.reference)
	end
	self.List:ScrollToElement(self.reference, -FIXED_OFFSET)
end

function Shortcuts:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	env.OpaqueMixin.OnLoad(self)
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

function Shortcuts:Create(name, ref, count)
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
	self.Shortcuts:Create(group, header)
	return header;
end

function Options:DrawOptions(showAdvanced)
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
			widget:Construct(name, data.varID, data.field, newObj)
			widget:SetPoint('TOP', prev, 'BOTTOM', 0, -FIXED_OFFSET)
			prev = widget;
		end
	end
	self.Child:SetHeight(nil)
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
	self.Child:SetMeasurementOrigin(self, self.Child, GENERAL_WIDTH, FIXED_OFFSET)

	db:RegisterCallback('Settings/showAdvancedSettings', self.DrawOptions, self)
	db:RegisterCallback('OnVariablesChanged', self.DrawOptions, self)
end

---------------------------------------------------------------
-- Panel
---------------------------------------------------------------
function PanelMixin:OnFirstShow()
	local metaVars = {
		ShowAdvanced = {
			_Type  = 'IndexButton';
			_Setup = 'CPIndexButtonBindingHeaderTemplate';
			_Point = {'TOP', 0, -FIXED_OFFSET};
			meta = 'showAdvancedSettings';
		};
	};

	local varContainer = LibStub('Carpenter'):BuildFrame(self, {
		MetaVars = {
			_Type  = 'Frame';
			_Setup = 'BackdropTemplate';
			_Backdrop = CPAPI.Backdrops.Opaque; 
			_Width = SHORTCUT_WIDTH + 1;
			_Points = {
				{'TOPLEFT', '$parent', 'BOTTOMLEFT', -1, 50 + FIXED_OFFSET};
				{'BOTTOMLEFT', -1, -1};
			};
			metaVars;
		};
	}, false, true).MetaVars;

	env.OpaqueMixin.OnLoad(varContainer)

	for child, data in db.table.spairs(metaVars) do
		local var = varContainer[child];
		local field = db('Variables/'.. var.meta)
		env.db.table.mixin(var, Setting)
		Setting.OnLoad(var)
		Shortcut.OnLoad(var)
		var:SetWidth(SHORTCUT_WIDTH - FIXED_OFFSET - 1)
		var:Construct(field.name, var.meta, field, true)
	end

	local shortcuts = self:CreateScrollableColumn('Shortcuts', {
		_Mixin = Shortcuts;
		_Width = SHORTCUT_WIDTH;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', 0, 1};
			{'BOTTOMLEFT', '$parent.MetaVars', 'TOPLEFT', 0, 0};
		};
	})
	local options = self:CreateScrollableColumn('Options', {
		_Mixin = Options;
		_Width = GENERAL_WIDTH;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', '$parent.Shortcuts', 'TOPRIGHT', 0, 0};
			{'BOTTOMLEFT', '$parent.MetaVars', 'BOTTOMRIGHT', -1, 0};
		};
	})
	options.Shortcuts = shortcuts;
	shortcuts.List = options;
end

env.Options = ConsolePortConfig:CreatePanel({
	name  = UIOPTIONS_MENU;
	mixin = PanelMixin;
	scaleToParent = true;
	forbidRecursiveScale = true;
})