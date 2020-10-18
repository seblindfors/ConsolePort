local db, _, env = ConsolePort:DB(), ...;
local ConfigMixin = {};
local General, Field = CreateFromMixins(CPFocusPoolMixin), CreateFromMixins(CPIndexButtonMixin, env.ScaleToContentMixin)

local GENERAL_FIXED_WIDTH, SETTING_FIXED_OFFSET = 900, 8;

function Field:OnLoad()
	self:SetMeasurementOrigin(self, self.Content, self:GetWidth(), 20)
	self:SetScript('OnEnter', CPIndexButtonMixin.OnIndexButtonEnter)
	self:SetScript('OnLeave', CPIndexButtonMixin.OnIndexButtonLeave)
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
			key = var;
			val = data;
		};
	end)

	local prev;
	for group, set in db.table.spairs(sorted) do
		-- render the header
		local header = self.headerPool:Acquire()
		header.Text:SetText(group)
		header:Show()
		if prev then
			header:SetPoint('TOP', prev, 'BOTTOM', 0, -SETTING_FIXED_OFFSET * 2)
		else
			header:SetPoint('TOP', 0, -SETTING_FIXED_OFFSET)
		end
		prev = header;

		-- render the options
		for name, data in db.table.spairs(set) do
			local widget, newObj = self:TryAcquireRegistered(name)
			if newObj then
				widget.Label:ClearAllPoints()
				widget.Label:SetPoint('LEFT', 16, 0)
				widget.Label:SetJustifyH('LEFT')
				widget.Label:SetTextColor(1, 1, 1)
				widget:SetDrawOutline(true)
				widget:OnLoad()
			end
			widget:SetText(name)
			widget:SetWidth(GENERAL_FIXED_WIDTH - 32)
			widget:Show()
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

function ConfigMixin:OnFirstShow()
	local general = self:CreateScrollableColumn('General', {
		_Mixin = General;
		_Width = GENERAL_FIXED_WIDTH;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOP', 0, 0};
			{'BOTTOM', 0, 0};
		};
	})
end

env.General = ConsolePortConfig:CreatePanel({
	name  = SETTINGS;
	mixin = ConfigMixin;
	scaleToParent = true;
	forbidRecursiveScale = true;
})