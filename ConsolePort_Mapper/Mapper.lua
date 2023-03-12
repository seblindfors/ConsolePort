local _, localEnv = ...;
local env, db, L = unpack(localEnv)
----------------------------------------------------------------
local Data, Consts, Widgets = db.Data, env.MapperConsts, env.Widgets;

----------------------------------------------------------------
-- Helpers
----------------------------------------------------------------
local function Round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0);
	return math.floor(num * mult + 0.5) / mult;
end

local function SetValue(group, index, dataPoint, value)
	if ( value == Consts.Unassigned ) then
		value = nil;
	end
	return db.Mapper:SetValue(('%s/%s/%s'):format(group, index, dataPoint), value)
end

----------------------------------------------------------------
-- Config
----------------------------------------------------------------
local Carpenter, FieldSize, FieldMixin = LibStub('Carpenter'), {localEnv.FIELD_WIDTH - 32, 36}, {};

function FieldMixin:Get()
	return self.controller:Get()
end

function FieldMixin:OnLoad()
	self.Label:ClearAllPoints()
	self.Label:SetPoint('LEFT', 8, 0)
	self.Label:SetJustifyH('LEFT')
	self.Label:SetTextColor(1, 1, 1)
end

----------------------------------------------------------------
-- Base
----------------------------------------------------------------
local BaseMixin = CreateFromMixins(env.ScaleToContentMixin, {
	BaseBlueprint = {
		removeButton = {
			_Type = 'Button';
			_Size = {32, 32};
			_Point = {'TOPRIGHT', -2, -4};
			_SetNormalTexture = [[Interface\ChatFrame\UI-ChatIcon-Minimize-Up]];
			_SetPushedTexture = [[Interface\ChatFrame\UI-ChatIcon-Minimize-Down]];
			_SetHighlightTexture = [[Interface\Buttons\UI-Common-MouseHilight]];
			_OnClick = function(self)
				self:GetParent():Destroy()
			end;
		};
	};
})

function BaseMixin:OnLoad()
	self.Label:ClearAllPoints()
	self.Label:SetPoint('TOPLEFT', 8, 0)
	self.Label:SetJustifyH('LEFT')

	local blueprint = db.table.copy(self.Blueprint)
	for field, instructions in pairs(blueprint) do
		instructions._Type  = 'IndexButton';
		instructions._Size  = FieldSize;
		instructions._Setup = 'CPIndexButtonBindingHeaderTemplate';
		instructions._Point = instructions.point;
	end
	Carpenter:BuildFrame(self, self.BaseBlueprint, false, true)
	Carpenter:BuildFrame(self.Content, blueprint, false, true)

	for key, data in pairs(blueprint) do
		local widget = self.Content[key]
		local constructor = Widgets[data.field:GetType()]
		if constructor then
			Mixin(widget, FieldMixin)
			widget:SetText(data.text)
			widget:OnLoad()
			constructor(widget, widget.data, data, data.field, data.desc)
			widget.controller:SetCallback(function(...)
				widget:OnValueChanged(SetValue(self.group, self.index, data.data, ...))
				self:UpdateText(self.set)
			end)
		end
	end
	self:Hide()
	self:Show()
	self:SetMeasurementOrigin(self.Content, self.Content, localEnv.FIELD_WIDTH - 20, 50)
	self:HookScript('OnClick', self.OnClick)
	self:SetWidth(localEnv.FIELD_WIDTH - 20)
	self:SetDrawOutline(true)
end

function BaseMixin:OnClick(...)
	local expanded = self:GetChecked()
	self.Content:SetShown(expanded)
	self:SetHeight(not expanded and 40 or nil)
	self:SetHitRectInsets(0, 0, 0, expanded and self:GetHeight() - 40 or 0)
end

function BaseMixin:Update(data, i, group)
	self.index = i;
	self.group = group;
	self.set = data;
	self:UpdateFields(data)
end

function BaseMixin:UpdateFields(data)
	data = data or self.set;
	for varID, value in pairs(data) do
		local field = self.Content[varID]
		if field then
			field:Set(type(value) == 'number' and Round(value, 5) or value)
		end
	end
end

function BaseMixin:Set(data, i, group)
	self:UpdateText(data, i)
	self:Update(data, i, group)
end

function BaseMixin:Destroy()
	local group = self.group;
	db.Mapper:SetValue(('%s/%s'):format(group, self.index), nil)
	db:TriggerEvent('OnMapperGroupChanged', group, db('Mapper/config/'..group))
end

----------------------------------------------------------------
-- AxisMap
----------------------------------------------------------------
--   int      rawIndex
--   axis     axis
--   [string] comment

local AxisMap = CreateFromMixins(BaseMixin, {
	Blueprint = {
		rawIndex = {
			point  = {'TOP', 0, -4};
			data   = 'rawIndex';
			text   = 'Raw Index';
			desc   = 'Raw axis index to map to named axis input.';
			field  = Data.Number(0, 1, false);
		};
		comment = {
			point  = {'TOP', '$parent.rawIndex', 'BOTTOM', 0, -4};
			data   = 'comment';
			text   = 'Comment';
			desc   = 'Optional comment about this axis.';
			field  = Data.String(nil);
		};
		axis = {
			point  = {'TOP', '$parent.comment', 'BOTTOM', 0, -4};
			data   = 'axis';
			text   = 'Axis';
			desc   = 'Axis to map to.';
			field  = Data.Select(Consts.Unassigned, unpack(Consts.Axes));
		};
	};
})

function AxisMap:UpdateText(data)
	local rawIndex, axis, comment = rawget(data, 'rawIndex'), rawget(data, 'axis'), rawget(data, 'comment')
	self:SetText(('Raw Axis %s: |cffffffff%s|r'):format(
		rawIndex or Consts.Unassigned,
		axis or comment or Consts.Unassigned
	))
end

----------------------------------------------------------------
-- ButtonMap
----------------------------------------------------------------
--   int      rawIndex
--   [button] button
--   [axis]   axis (must be set along with axisValue)
--   [float]  axisValue
--   [string] comment

local ButtonMap = CreateFromMixins(BaseMixin, {
	Blueprint = {
		rawIndex = {
			point  = {'TOP', 0, -4};
			data   = 'rawIndex';
			text   = 'Raw Index';
			desc   = 'Raw button index to map to named button input.';
			field  = Data.Number(0, 1, false);
		};
		comment = {
			point  = {'TOP', '$parent.rawIndex', 'BOTTOM', 0, -4};
			data   = 'comment';
			text   = 'Comment';
			desc   = 'Optional comment about this axis.';
			field  = Data.String(nil);
		};
		button = {
			point  = {'TOP', '$parent.comment', 'BOTTOM', 0, -4};
			data   = 'button';
			text   = 'Button';
			desc   = 'Optional button to map raw index to.';
			field  = Data.Select(Consts.Unassigned, unpack(Consts.Buttons));
		};
		axis = {
			point  = {'TOP', '$parent.button', 'BOTTOM', 0, -4};
			data   = 'axis';
			text   = 'Axis';
			desc   = 'Optional axis to map raw index to (requires axis value).';
			field  = Data.Select(Consts.Unassigned, unpack(Consts.Axes));
		};
		axisValue = {
			point  = {'TOP', '$parent.axis', 'BOTTOM', 0, -4};
			data   = 'axis';
			text   = 'Axis Value';
			desc   = 'Optional axis value to control trigger point for selected axis.';
			field  = Data.Number(0.25, 0.1);
		};
	};
})

function ButtonMap:UpdateText(data)
	local rawIndex, button, axis = rawget(data, 'rawIndex'), rawget(data, 'button'), rawget(data, 'axis')
	self:SetText(('Raw Button %s: |cffffffff%s|r'):format(
		rawIndex or Consts.Unassigned,
		button or axis or Consts.Unassigned
	))
end

----------------------------------------------------------------
-- AxisConfig
----------------------------------------------------------------
--   axis     axis
--   [string] comment
--   [button] buttonPos
--   [button] buttonNeg
--   [float]  shift (Value shift when mapping from a raw axis)
--   [float]  scale (Value scale when mapping from a raw axis)
--   [float]  deadzone (deadzone applied when mapping from a raw axis)
--   [float]  buttonThreshold (Must be set if setting buttonPos or buttonNeg)

local AxisConfig = CreateFromMixins(BaseMixin, {
	Blueprint = {
		comment = {
			point  = {'TOP', 0, -4};
			data   = 'comment';
			text   = 'Comment';
			desc   = 'Optional comment about this axis.';
			field  = Data.String(nil);
		};
		axis = {
			point  = {'TOP', '$parent.comment', 'BOTTOM', 0, -4};
			data   = 'axis';
			text   = 'Axis';
			desc   = 'Axis to configure.';
			field  = Data.Select(Consts.Unassigned, unpack(Consts.Axes));
		};
		buttonPos = {
			point  = {'TOP', '$parent.axis', 'BOTTOM', 0, -4};
			data   = 'buttonPos';
			text   = 'Button Positive';
			desc   = 'Button to press at positive value above threshold.';
			field  = Data.Select(Consts.Unassigned, unpack(Consts.Buttons));
		};
		buttonNeg = {
			point  = {'TOP', '$parent.buttonPos', 'BOTTOM', 0, -4};
			data   = 'buttonNeg';
			text   = 'Button Negative';
			desc   = 'Button to press at negative value above threshold.';
			field  = Data.Select(Consts.Unassigned, unpack(Consts.Buttons));
		};
		shift = {
			point  = {'TOP', '$parent.buttonNeg', 'BOTTOM', 0, -4};
			data   = 'shift';
			text   = 'Shift';
			desc   = 'Shifts the axis value by a constant to mapped range.';
			field  = Data.Number(0, 0.1);
		};
		scale = {
			point  = {'TOP', '$parent.shift', 'BOTTOM', 0, -4};
			data   = 'scale';
			text   = 'Scale';
			desc   = 'Scales the axis value to work in mapped range.';
			field  = Data.Number(0, 0.1);
		};
		deadzone = {
			point  = {'TOP', '$parent.scale', 'BOTTOM', 0, -4};
			data   = 'deadzone';
			text   = 'Deadzone';
			desc   = 'Deadzone applied to ignore axis input from raw state.';
			field  = Data.Number(0.25, 0.1);
		};
		buttonThreshold = {
			point  = {'TOP', '$parent.deadzone', 'BOTTOM', 0, -4};
			data   = 'buttonThreshold';
			text   = 'Button Threshold';
			desc   = 'Threshold for button input, range from 0-1.';
			field  = Data.Number(0.5, 0.1);
		};
	};
});

function AxisConfig:UpdateText(axis, i, group)
	local comment, name = rawget(axis, 'comment'), rawget(axis, 'axis')
	self:SetText(comment or name or L('Mapped Axis %d', tostring(i)))
end

----------------------------------------------------------------
-- StickConfig
----------------------------------------------------------------
--   stick    stick
--   axis     axisX
--   axis     axisY
--	 [float]  deadzone (2D deadzone applied when normalizing the stick input length)
--	 [float]  deadzoneX (X axis deadzone applied when mapping to stick)
--	 [float]  deadzoneY (Y axis deadzone applied when mapping to stick)
--   [string] comment

local StickConfig = CreateFromMixins(BaseMixin, {
	Blueprint = {
		comment = {
			point  = {'TOP', 0, -4};
			data   = 'comment';
			text   = 'Comment';
			desc   = 'Optional comment about this stick.';
			field  = Data.String(nil);
		};
		stick = {
			point  = {'TOP', '$parent.comment', 'BOTTOM', 0, -4};
			data   = 'stick';
			text   = 'Stick';
			desc   = 'Stick to configure.';
			field  = Data.Select(Consts.Unassigned, unpack(Consts.Sticks));
		};
		axisX = {
			point  = {'TOP', '$parent.stick', 'BOTTOM', 0, -4};
			data   = 'axisX';
			text   = 'Axis X';
			desc   = 'Which axis to use as horizontal value for the stick input.';
			field  = Data.Select(Consts.Unassigned, unpack(Consts.Axes));
		};
		axisY = {
			point  = {'TOP', '$parent.axisX', 'BOTTOM', 0, -4};
			data   = 'axisY';
			text   = 'Axis Y';
			desc   = 'Which axis to use as vertical value for the stick input.';
			field  = Data.Select(Consts.Unassigned, unpack(Consts.Axes));
		};
		deadzone = {
			point  = {'TOP', '$parent.axisY', 'BOTTOM', 0, -4};
			data   = 'deadzone';
			text   = 'Deadzone';
			desc   = '2D Deadzone applied when normalizing the stick input length.';
			field  = Data.Number(0.25, 0.05);
		};
		deadzoneX = {
			point  = {'TOP', '$parent.deadzone', 'BOTTOM', 0, -4};
			data   = 'deadzoneX';
			text   = 'Deadzone X';
			desc   = 'Deadzone applied to Axis X when mapping to the stick.';
			field  = Data.Number(0.05, 0.05);
		};
		deadzoneY = {
			point  = {'TOP', '$parent.deadzoneX', 'BOTTOM', 0, -4};
			data   = 'deadzoneY';
			text   = 'Deadzone Y';
			desc   = 'Deadzone applied to Axis Y when mapping to the stick.';
			field  = Data.Number(0.05, 0.05);
		};
	};
})

function StickConfig:UpdateText(stick, i)
	local comment, name = rawget(stick, 'comment'), rawget(stick, 'stick')
	self:SetText(comment or name or L('Stick %d', tostring(i)))
end

----------------------------------------------------------------
-- Add field button
----------------------------------------------------------------
local AddFieldButton = {};

function AddFieldButton:OnLoad()
	self:SetNormalTexture([[Interface\PaperDollInfoFrame\Character-Plus]])
	self:SetPushedTexture([[Interface\PaperDollInfoFrame\Character-Plus]])
	self:SetDrawOutline(true)
	self:SetWidth(localEnv.FIELD_WIDTH - 20)
	self:SetText(ADD)

	self.Label:ClearAllPoints()
	self.Label:SetPoint('TOPLEFT', 8, 0)
	self.Label:SetJustifyH('LEFT')

	local normal = self:GetNormalTexture()
	local pushed = self:GetPushedTexture()

	normal:ClearAllPoints()
	pushed:ClearAllPoints()
	normal:SetPoint('RIGHT', -8, 0)
	pushed:SetPoint('RIGHT', -10, -2)
	normal:SetSize(20, 20)
	pushed:SetSize(20, 20)
end

function AddFieldButton:OnClick()
	local group, data = self.group, self.data;
	self:Uncheck()
	db.Mapper:SetValue(('%s/%s'):format(group, #data+1), {})
	db:TriggerEvent('OnMapperGroupChanged', group, data)
end

function AddFieldButton:Set(group, data)
	self.group = group;
	self.data = data;
end

----------------------------------------------------------------
-- Config content
----------------------------------------------------------------
local Config = CreateFromMixins(localEnv.Wrapper, env.ScaleToContentMixin);
localEnv.Config = Config;

function Config:OnLoad()
	localEnv.Wrapper.OnLoad(self)
	self:SetHeight(40)
	self:SetMeasurementOrigin(self.Content, self.Content, localEnv.PANEL_WIDTH - 32, 0)
end

local function PlaceWidgetInGrid(i, widget, prev1, prev2)
	if ((i-1) % 2 == 0) then -- odd
		if not prev1 then
			widget:SetPoint('TOPLEFT', 16, -24)
		else
			widget:SetPoint('TOP', prev1, 'BOTTOM', 0, -8)
		end
		prev1 = widget;
	else -- even
		if not prev2 then
			widget:SetPoint('TOPRIGHT', -16, -24)
		else
			widget:SetPoint('TOP', prev2, 'BOTTOM', 0, -8)
		end
		prev2 = widget;
	end
	return prev1, prev2;
end

function Config:LayoutData(group, set, pool, mixin, sort)
	local prev1, prev2;
	if sort then
		table.sort(set, sort)
	end
	for i, data in ipairs(set) do
		local widget, newObj = pool:Acquire()
		if newObj then
			Mixin(widget, mixin)
			widget:OnLoad()
		end
		widget:Set(data, i, group)
		widget:Show()

		prev1, prev2 = PlaceWidgetInGrid(i, widget, prev1, prev2)
	end

	pool.addNewButton:Set(group, set)
	pool.addNewButton:ClearAllPoints()
	PlaceWidgetInGrid(#set + 1, pool.addNewButton, prev1, prev2)

	pool.parent:SetHeight(ceil((#set +1)/2) * 40 + 40)
	pool.parent.forbidRecursiveScale = false;
end

function Config:OnConfigLoaded(config)
	self:SetData(config)
end

function Config:SetData(config)
	self:ReleaseAll()

	for i, group in ipairs(tInvert(db.Mapper.ConfigGroups)) do
		local layout = self.layouts[group];
		if layout then
			self:LayoutData(group, rawget(config, group), layout.pool, layout.mixin, layout.sort)
		end
	end
end

function Config:ReleaseAll()
	for _, pool in pairs(self.pools) do
		pool:ReleaseAll()
	end
end

function Config:RefreshGroup(group, data)
	local layout = self.layouts[group];
	if layout then
		layout.pool:ReleaseAll()
		self:LayoutData(group, data, layout.pool, layout.mixin, layout.sort)
	end
end

function Config:Construct()
	local function CreatePool(type, parent, template)
		local pool = CreateFramePool(type, parent, template)
		pool.addNewButton = CreateFrame(type, nil, parent, 'CPIndexButtonBindingHeaderTemplate')
		db.table.mixin(pool.addNewButton, AddFieldButton):OnLoad()
		return pool;
	end

	self.pools = {
		axisMap     = CreatePool('IndexButton', self.Content.RawAxisBlock, 'CPIndexButtonBindingHeaderTemplate');
		buttonMap   = CreatePool('IndexButton', self.Content.RawButtonBlock, 'CPIndexButtonBindingHeaderTemplate');
		axisConfig  = CreatePool('IndexButton', self.Content.MappedAxisBlock, 'CPIndexButtonBindingHeaderTemplate');
		stickConfig = CreatePool('IndexButton', self.Content.StickBlock, 'CPIndexButtonBindingHeaderTemplate');
	};

	local function rawIndexSort(a, b)
		return (a and a.rawIndex or 0) < (b and b.rawIndex or 0)
	end

	self.layouts = {
		rawAxisMappings   = { pool = self.pools.axisMap,     mixin = AxisMap,    sort = rawIndexSort };
		rawButtonMappings = { pool = self.pools.buttonMap,   mixin = ButtonMap,  sort = rawIndexSort };
		axisConfigs       = { pool = self.pools.axisConfig,  mixin = AxisConfig  };
		stickConfigs      = { pool = self.pools.stickConfig, mixin = StickConfig };
	};

	localEnv.Wrapper.OnLoad(self)
	db:RegisterCallback('OnMapperConfigLoaded', self.OnConfigLoaded, self)
	db:RegisterCallback('OnMapperGroupChanged', self.RefreshGroup, self)
end