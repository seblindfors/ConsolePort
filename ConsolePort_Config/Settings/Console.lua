local _, env, db, L = ...; db, L = env.db, env.L;
local PanelMixin, Widgets = {}, env.Widgets;
local SHORTCUT_WIDTH, GENERAL_WIDTH, FIXED_OFFSET = 284, 700, 8;

---------------------------------------------------------------
-- Console variable fields
---------------------------------------------------------------
local Setting = CreateFromMixins(env.CvarMixin)

function Setting:OnLoad()
	env.CvarMixin.OnLoad(self)
	self:SetWidth(GENERAL_WIDTH)
end

---------------------------------------------------------------
-- Console
---------------------------------------------------------------
local Console = CreateFromMixins(env.SettingListMixin)

function Console:OnVariableChanged(variable, value)
	-- dealing with emulation button overlap (don't trust the user)
	if variable:match('Emulate') and not self.isMutexLocked then
		self.isMutexLocked = true;
		for cvar in self:EnumerateActive() do
			if (cvar:Get() == value) and (cvar.variableID ~= variable) then
				cvar:Set('none', true)
			end
		end
		self.isMutexLocked = false;
	end
end

function Console:DrawOptions(showAdvanced)
	self.headerPool:ReleaseAll()

	local prev;
	for group, set in db.table.spairs(db.Console) do
		-- render the header
		prev = self:CreateHeader(group, prev)

		-- render the options
		for i, data in ipairs(set) do
			local widget, newObj = self:TryAcquireRegistered(group..':'..data.cvar)
			if newObj then
				widget.Label:ClearAllPoints()
				widget.Label:SetPoint('LEFT', 16, 0)
				widget.Label:SetJustifyH('LEFT')
				widget.Label:SetTextColor(1, 1, 1)
				widget:SetDrawOutline(true)
				widget:OnLoad()
			end
			widget:Construct(data, newObj, self)
			widget:SetPoint('TOP', prev, 'BOTTOM', 0, -FIXED_OFFSET)
			prev = widget;
		end
	end
	self.Child:SetHeight(nil)
end

function Console:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	env.OpaqueMixin.OnLoad(self)
	self.headerPool = CreateFramePool('Frame', self.Child, 'CPConfigHeaderTemplate')
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingHeaderTemplate', Setting, nil, self.Child)
	Mixin(self.Child, env.ScaleToContentMixin)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self, self.Child, GENERAL_WIDTH, FIXED_OFFSET)
end


---------------------------------------------------------------
-- Panel
---------------------------------------------------------------
function PanelMixin:OnFirstShow()
	local shortcuts = self:CreateScrollableColumn('Shortcuts', {
		_Mixin = env.SettingShortcutsMixin;
		_Width = SHORTCUT_WIDTH;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', 0, 1};
			{'BOTTOMLEFT', 0, -1};
		};
	})
	local cvars = self:CreateScrollableColumn('Console', {
		_Mixin = Console;
		_Width = GENERAL_WIDTH;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', '$parent.Shortcuts', 'TOPRIGHT', 0, 0};
			{'BOTTOMLEFT', '$parent.Shortcuts', 'BOTTOMRIGHT', 0, 0};
		};
	})
	cvars.Shortcuts = shortcuts;
	shortcuts.List = cvars;
end

env.Console = ConsolePortConfig:CreatePanel({
	name  = SETTINGS;
	mixin = PanelMixin;
	scaleToParent = true;
	forbidRecursiveScale = true;
})