local db, _, env, L = ConsolePort:DB(), ...; L = db('Locale');
local ConfigMixin, Widgets = {}, env.Widgets;

---------------------------------------------------------------
-- General settings
---------------------------------------------------------------
local GENERAL_FIXED_WIDTH, SETTING_FIXED_OFFSET = 900, 8;
local General, Field = CreateFromMixins(CPFocusPoolMixin), CreateFromMixins(CPIndexButtonMixin, env.ScaleToContentMixin)

function Field:OnLoad()
	self:SetWidth(GENERAL_FIXED_WIDTH - 32)
	self:SetMeasurementOrigin(self, self.Content, self:GetWidth(), 40)
	self:SetScript('OnEnter', CPIndexButtonMixin.OnIndexButtonEnter)
	self:SetScript('OnLeave', CPIndexButtonMixin.OnIndexButtonLeave)
end

function Field:Construct(name, varID, field, newObj)
	if newObj then
		self:SetText(L(name))
		local constructor = Widgets[varID] or Widgets[field[1]:GetType()];
		if constructor then
			constructor(self, varID, field)
		end
	end
	self:Hide()
	self:Show()
end

function General:DrawOptions(showAdvanced)
	self.headerPool:ReleaseAll()

	-- sort settings by group
	local sorted = {};
	foreach(db('Variables'), function(var, data)
		local group = data.head or OTHER;
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
		local header = self.headerPool:Acquire()
		header:SetText(L(group))
		header:Show()
		if prev then
			header:SetPoint('TOP', prev, 'BOTTOM', 0, -SETTING_FIXED_OFFSET * 2)
		else
			header:SetPoint('TOP', 0, -SETTING_FIXED_OFFSET)
		end
		prev = header;

		-- render the options
		for name, data in db.table.spairs(set, displaysort) do
			local widget, newObj = self:TryAcquireRegistered(name)
			if newObj then
				widget.Label:ClearAllPoints()
				widget.Label:SetPoint('LEFT', 16, 0)
				widget.Label:SetJustifyH('LEFT')
				widget.Label:SetTextColor(1, 1, 1)
				widget:SetDrawOutline(true)
				widget:OnLoad()
			end
			widget:Construct(name, data.varID, data.field, newObj)
			widget:SetPoint('TOP', prev, 'BOTTOM', 0, -SETTING_FIXED_OFFSET)
			prev = widget;
		end
	end
	self.Child:SetHeight(nil)
end

function General:OnShow()
	self:DrawOptions()
end

function General:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	env.OpaqueMixin.OnLoad(self)
	self.headerPool = CreateFramePool('Frame', self.Child, 'CPConfigHeaderTemplate')
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingHeaderTemplate', Field, nil, self.Child)
	Mixin(self.Child, env.ScaleToContentMixin)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self, self.Child, GENERAL_FIXED_WIDTH, SETTING_FIXED_OFFSET)
end

---------------------------------------------------------------
-- Panel
---------------------------------------------------------------
function ConfigMixin:OnFirstShow()
	local general = self:CreateScrollableColumn('General', {
		_Mixin = General;
		_Width = GENERAL_FIXED_WIDTH;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOP', 0, 1};
			{'BOTTOM', 0, -1};
		};
	})
end

env.General = ConsolePortConfig:CreatePanel({
	name  = SETTINGS;
	mixin = ConfigMixin;
	scaleToParent = true;
	forbidRecursiveScale = true;
})