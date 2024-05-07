---------------------------------------------------------------
-- Tabular
---------------------------------------------------------------
-- 
-- Author:  Sebastian Lindfors (Munk / MunkDev)
-- Website: https://github.com/seblindfors
-- Licence: GPL version 2 (General Public License)
--
-- Description:
--  Renders tabular data in WoW in a self-contained browser,
--  which can then be changed and compiled into a new table.
--  Supports pattern matching for key, value, path and tooltip,
--  to provide user-friendly display texts for the different
--  datapoints in a given table. Paths are generated from keys,
--  e.g. {example = {data = {inner = 1}}} -> example/data/inner
--
-- Usage:
--
--  @param  args {      -> table, options for the browser
--    @param parent     -> frame, where to draw the browser
--    @param [width]    -> number, width of browser, default match parent
--    @param [offset]   -> number, offset from top of parent, default 0
--    @param [state]    -> bool, initial state, default false
--    @param [readOnly] -> bool, lock inline value changes, default false
--    @param [inline]   -> bool, use original data to populate, default false
--    @param [callback] -> function, signature ( path, key, value, state )
--    @param [alias] {  -> dicts of patterns and gsub functions/texts
--      @param key       { [@param pattern] = @param replace, ... }
--      @param path      { [@param pattern] = @param replace, ... }
--      @param value     { [@param pattern] = @param replace, ... }
--      @param tooltip   { [@param pattern] = @param tooltipText, ... }
--    }
--  }
--  @param  data        -> table, the data to browse
--  @return compile     -> function, compiles and returns the data
--  @return release     -> function, releases the browser
--  @return objects     -> table, root-level frames in browser
--
---------------------------------------------------------------

local Tabular = LibStub:NewLibrary('Tabular', 2)
if not Tabular then return end

---------------------------------------------------------------
-- Consts
---------------------------------------------------------------
local ROW_HEIGHT, ROW_PADDING = 30, 4;

local COLOR_TYPES = setmetatable({
	number  = CreateColor(0.53, 1.00, 0.73);
	string  = CreateColor(1.00, 1.00, 0.47);
	table   = CreateColor(1.00, 0.82, 0.00);
	boolean = CreateColor(0.98, 0.15, 0.45);
}, {__index = function() return WHITE_FONT_COLOR end})

local EXPANDER_TEXTURES = {
	[false] = {
		SetNormalTexture = [[Interface\Buttons\UI-Panel-ExpandButton-Up]];
		SetPushedTexture = [[Interface\Buttons\UI-Panel-ExpandButton-Down]];
	};
	[true] = {
		SetNormalTexture = [[Interface\Buttons\UI-Panel-CollapseButton-Up]];
		SetPushedTexture = [[Interface\Buttons\UI-Panel-CollapseButton-Down]];
	};
}

local COMPILE_FUNC_TEXT  = [[return %s]];
local COMPILE_ERROR_TEXT = 'Failed to compile %s. Error:\n%s';
local EMPTY_ALIAS; -- Use a proxy when no alias handler is provided

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local function CreateObject(constructor)
	return setmetatable({}, {__call = function(self, ...)
		local obj = Mixin(constructor(...), self)
		for k, v in pairs(obj) do
			if obj.HasScript and obj:HasScript(k) then
				if obj:GetScript(k) then
					obj:HookScript(k, v)
				else
					obj:SetScript(k, v)
				end
			end
		end
		obj:OnLoad()
		return obj;
	end})
end

local function ksort(k1, k2)
	if tonumber(k1) and tonumber(k2) then
		return k1 < k2;
	end
	return tostring(k1) < tostring(k2)
end

local function spairs(t)
	local i, keys = 0, {};
	for k in pairs(t) do
		keys[#keys+1] = k;
	end
	table.sort(keys, ksort)
	return function()
		i = i + 1;
		if keys[i] then
			return keys[i], t[keys[i]];
		end
	end
end

---------------------------------------------------------------
-- Alias handling
---------------------------------------------------------------
local AliasHandler, AliasHandlerMT = {};
local Alias = CreateObject(function()
	return setmetatable({
		key = {};
		path = {};
		value = {};
		tooltip = {};
	}, AliasHandlerMT)
end)

function AliasHandler:Wipe()
	for key in pairs(self) do
		wipe(self[key])
	end
end

function AliasHandler:Evaluate(set, value)
	local res, count, total = tostring(value), 0, 0;
	for pattern, evaluator in spairs(set) do
		res, count = res:gsub(pattern, evaluator)
		total = total + count;
	end
	return res, total > 0, total;
end

function AliasHandler:SetPatterns(index, patterns)
	assert(self[index], ('Invalid alias dict index: %s'):format(tostring(index)))
	for pattern, evaluator in pairs(patterns) do
		self[index][pattern] = evaluator;
	end
end

AliasHandlerMT = {
	__index = AliasHandler;
	__call  = AliasHandler.Evaluate;
};

AliasHandler.OnLoad = nop; EMPTY_ALIAS = Alias();

---------------------------------------------------------------
-- Line
---------------------------------------------------------------
local Line = CreateObject(function(self, start, stop)
	local obj = self:CreateLine()
	obj:SetStartPoint(start, 0, 0)
	obj:SetEndPoint(stop, 0, 0)
	return obj;
end)

function Line:OnLoad()
	self:SetThickness(1)
end

---------------------------------------------------------------
-- Box
---------------------------------------------------------------
local Box = CreateObject(function(type, parent)
	return CreateFrame(type, nil, parent)
end)

function Box:OnLoad()
	self.BG = self:CreateTexture(nil, 'BACKGROUND')
	self.BG:SetAllPoints()
	self.Lines = {
		Line(self, 'TOPLEFT',    'BOTTOMLEFT'),
		Line(self, 'TOPLEFT',    'TOPRIGHT'),
		Line(self, 'TOPRIGHT',   'BOTTOMRIGHT'),
		Line(self, 'BOTTOMLEFT', 'BOTTOMRIGHT'),
	}
	self:OnLeave()
end

function Box:OnEnter()
	self.Lines[1]:SetColorTexture(1, 0.82, 0, 1)
	self.BG:SetColorTexture(0.15, 0.15, 0.15, 0.75)
end

function Box:OnLeave()
	for _, line in ipairs(self.Lines) do
		line:SetColorTexture(0.25, 0.25, 0.25, 1)
	end
	self.BG:SetColorTexture(0.1, 0.1, 0.1, 0.75)
end


---------------------------------------------------------------
-- Expander
---------------------------------------------------------------
local Expander = CreateObject(function(parent)
	return CreateFrame('CheckButton', nil, parent)
end)

function Expander:OnLoad()
	self:Hide()
	self:SetSize(28, 28)
	self:SetPoint('TOPRIGHT', 0, -2)
	self:SetHighlightTexture([[Interface\Buttons\UI-PlusButton-Hilight]])
	self:Update()
end

function Expander:OnClick()
	self:GetParent():OnExpandCollapse(self:GetChecked())
	self:Update()
end

function Expander:Update()
	for func, file in pairs(EXPANDER_TEXTURES[self:GetChecked()]) do
		self[func](self, file)
	end
end


---------------------------------------------------------------
-- Check
---------------------------------------------------------------
local Check = CreateObject(function(parent)
	return CreateFrame('CheckButton', nil, parent, 'UICheckButtonTemplate')
end)

function Check:OnLoad()
	self.Text = self.Text or self.text;
	local font, _, flags = self.Text:GetFont()
	self.Text:SetFont(font, 12, flags)
	self.Text:SetPoint('LEFT', self, 'RIGHT', 0, 0)
	self.Text:SetPoint('RIGHT', self:GetParent(), 'CENTER', 0, 0)
	self.Text:SetJustifyH('LEFT')
	self.Text:SetMaxLines(2)
	self:SetSize(24, 24)
	self:SetPoint('TOPLEFT', 2, -4)
end

function Check:OnClick()
	self:GetParent():SetChecked(self:GetChecked())
end


---------------------------------------------------------------
-- Input
---------------------------------------------------------------
local Input = CreateObject(function(parent)
	return CreateFrame('EditBox', nil, parent, 'InputBoxTemplate')
end)

function Input:OnLoad()
	local font, _, flags = self:GetFont()
	self:SetFont(font, 13, flags)
	self:SetJustifyH('LEFT')
	self:SetAutoFocus(false)
	self:SetPoint('RIGHT', -4, 0)
	self:SetPoint('LEFT', self:GetParent(), 'CENTER', 4, 0)
	self:SetHeight(28)
	self:Hide()
	self.Left:SetAlpha(0.15)
	self.Right:SetAlpha(0.15)
	self.Middle:SetAlpha(0.15)
end

function Input:SetValue(value, skipFormat)
	local alias, valueType = self:GetParent().alias, type(value);

	if ( not skipFormat and valueType == 'string' ) then
		value = ('%q'):format(value)
	end

	self.cacheValue = tostring(value)
	self:SetTextColor(COLOR_TYPES[valueType]:GetRGB())
	self:SetText(alias(alias.value, self.cacheValue))
end

function Input:OnEditFocusGained()
	self:SetText(self.cacheValue)
end

function Input:OnEditFocusLost()
	self:SetValue(self.cacheValue, true)
end

function Input:OnEnterPressed()
	local newText = self:GetText()
	local func, loadError = loadstring(COMPILE_FUNC_TEXT:format(newText))
	if func then
		local callOK, result = pcall(func)
		if callOK then
			self:SetValue(result)
			self:Propagate(result)
		else
			self:ThrowError(newText, result)
		end
	else
		self:ThrowError(newText, loadError)
	end
	self:ClearFocus()
end

function Input:ThrowError(input, error)
	local valueType = type(self:GetParent().value)
	print(COMPILE_ERROR_TEXT:format(
		COLOR_TYPES[valueType]:WrapTextInColorCode(tostring(input)),
		error:gsub('%b[]:%d+: ', '')
	));
	self:SetText(self.cacheValue)
end

function Input:Propagate(value)
	local parent = self:GetParent()
	parent:ReleaseChildren()
	parent:SetData(parent.key, value, parent.path)
end

---------------------------------------------------------------
-- DataRow
---------------------------------------------------------------
local DataRow = CreateObject(function(parent)
	return Box('Button', parent)
end)

function DataRow:OnLoad()
	self.Input = Input(self)
	self.Check = Check(self)
	self.Expander = Expander(self)

	self:SetHeight(ROW_HEIGHT)
	self:SetFontString(self.Check.Text)
	self.Label = self.Check.Text;
	self.Children = {};
end

function DataRow:OnClick()
	if self:IsExpandible() then
		self.Expander:Click()
	else
		self:SetChecked(not self:GetChecked())
	end
end

function DataRow:OnHide()
	if self:IsExpanded() then
		self.Expander:Click()
	end
end

function DataRow:OnEnter()
	local tooltipText, hasChanged = self.alias(self.alias.tooltip, self.path)
	if ( hasChanged ) then
		GameTooltip:SetOwner(self, 'ANCHOR_BOTTOM')
		GameTooltip:SetText(tooltipText, WHITE_FONT_COLOR:GetRGB())
	end
end

function DataRow:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function DataRow:GetChecked()
	return self.Check:GetChecked()
end

function DataRow:GetParentState()
	for i, child in ipairs(self.Children) do
		if not child:GetChecked() then
			return false;
		end
	end
	return true;
end

function DataRow:SetChecked(state)
	self:SetState(state)
	self:UpdateChildren(state)
	self:UpdateParents(state, true)
	self:SetPartiallyChecked(not state)
end

function DataRow:SetState(state)
	self.Check:SetChecked(state)
	self.callback(self.path, self.key, self.value, state)
end

function DataRow:SetPartiallyChecked(enabled)
	self.Check:GetCheckedTexture():SetDesaturated(enabled)
end

function DataRow:UpdateChildren(state)
	for i, child in ipairs(self.Children) do
		child:SetChecked(state)
	end
end

function DataRow:UpdateParents(state, isFullyChecked)
	local parent = self:GetParent()
	if ( not parent or not parent.UpdateParents ) then
		return
	end
	if state then
		parent:SetState(state)
	end
	if isFullyChecked then
		isFullyChecked = parent:GetParentState()
	end
	parent:SetPartiallyChecked(not isFullyChecked)
	return parent:UpdateParents(state, isFullyChecked)
end

function DataRow:SetParentChecked(state)
	local parent = self:GetParent()
	if parent.SetParentChecked then
		parent.Check:SetChecked(state)
		parent:SetParentChecked(state)
	end
end

function DataRow:SetTextColor(...)
	self.Label:SetTextColor(...)
end

function DataRow:SetExpandible(enabled)
	self.Expander:SetShown(enabled)
end

function DataRow:SetCallback(callback)
	self.callback = callback;
end

function DataRow:SetAliasHandler(handler)
	self.alias = handler or EMPTY_ALIAS;
end

function DataRow:SetValue(value, isEditableValue)
	self.Input:SetShown(isEditableValue)
	if isEditableValue then
		self.Input:SetValue(value)
	end
end

function DataRow:SetKeyText(text)
	local altText, hasChanged = self.alias(self.alias.path, self.path)
	self:SetText(hasChanged and altText or self.alias(self.alias.key, text))
end

function DataRow:SetData(key, value, path)
	self.key, self.value, self.path = key, value, path;

	local valueType = type(value)
	local isTableData = valueType == 'table';

	self:SetTextColor(COLOR_TYPES[valueType]:GetRGB())
	self:SetExpandible(isTableData)
	self:SetValue(value, not isTableData)
	self:SetKeyText(key)

	self.callback(key, value, path, self:GetChecked())
end

function DataRow:SetReadOnly(isReadOnly)
	self.Input:SetEnabled(not isReadOnly)
	for i, child in ipairs(self.Children) do
		child:SetReadOnly(not isReadOnly)
	end
end

function DataRow:IsExpandible()
	return self.Expander:IsShown()
end

function DataRow:IsExpanded()
	return self.Expander:GetChecked()
end

function DataRow:ShowChildren()
	if not next(self.Children) then
		local width, prev = self:GetWidth() - ROW_PADDING;
		for key, value in spairs(self.value) do
			local obj = self:Acquire()
			obj.Check:SetChecked(self:GetChecked())
			obj.Input:SetEnabled(self.Input:IsEnabled())
			obj:SetAliasHandler(self.alias)
			obj:SetData(key, value, ('%s/%s'):format(self.path, key))
			obj:SetCallback(self.callback)
			if prev then
				obj:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', 0, 0)
				obj:SetPoint('TOPRIGHT', prev, 'BOTTOMRIGHT', 0, 0)
			else
				obj:SetPoint('TOPLEFT', self, 'TOPLEFT', ROW_PADDING, -ROW_HEIGHT)
				obj:SetPoint('TOPRIGHT', self, 'TOPRIGHT', 0, -ROW_HEIGHT)
			end
			prev = obj;
		end
	end
	for i, child in ipairs(self.Children) do
		child:Show()
	end
end

function DataRow:HideChildren()
	for i, child in ipairs(self.Children) do
		child:Hide()
	end
	self:SetHeight(ROW_HEIGHT)
end

function DataRow:Acquire()
	local obj = self.Registry:Acquire()
	obj:SetParent(self)
	obj:Show()
	tinsert(self.Children, obj)
	return obj;
end

function DataRow:ReleaseChildren()
	for i, child in ipairs(self.Children) do
		self.Registry:Release(child)
	end
	wipe(self.Children)
end

function DataRow:UpdateHeight()
	local height, children, parent = ROW_HEIGHT, self.Children, self:GetParent();
	for i, child in ipairs(children) do
		if child:IsShown() then
			height = height + child:GetHeight();
		end
	end
	if #children > 0 then
		height = height + ROW_PADDING;
	end
	self:SetHeight(height)
	self:SetHitRectInsets(0, 0, 0, height - ROW_HEIGHT)
	if parent and parent.UpdateHeight then
		parent:UpdateHeight()
	end
end

function DataRow:OnExpandCollapse(expanded)
	if expanded then
		self:ShowChildren()
	else
		self:HideChildren()
	end
	self:UpdateHeight()
end

function DataRow:Compile()
	if not self:GetChecked() then
		return nil, nil;
	end
	if self:IsExpandible() and next(self.Children) then
		local result = {};
		for i, child in ipairs(self.Children) do
			local key, value = child:Compile()
			if ( key ~= nil and value ~= nil ) then
				result[key] = value;
			end
		end
		return self.key, result;
	end
	return self.key, self.value;
end

DataRow.Registry = CreateObjectPool(
	function(registry)
		return DataRow()
	end,
	function(registry, self)
		self:ReleaseChildren()
		self:SetAliasHandler(EMPTY_ALIAS)
		self:SetCallback(nop)
		self:SetData(nil, nil, nil)
		self:SetHeight(ROW_HEIGHT)
		self:SetParent(nil)
		self:SetPartiallyChecked(false)
		self:ClearAllPoints()
		self:Hide()
	end
)

---------------------------------------------------------------
-- API
---------------------------------------------------------------
local function Release(objects)
	for obj in pairs(objects) do
		DataRow.Registry:Release(obj)
	end
end

local function Compile(objects)
	local result = {};
	for obj in pairs(objects) do
		local key, value = obj:Compile()
		if ( key ~= nil and value ~= nil ) then
			result[key] = value;
		end
	end
	return result;
end

setmetatable(Tabular, {
	__call = function(self, args, data)
		assert(type(args) == 'table', 'Bad argument #1 to `Tabular` (table expected)')
		assert(type(data) == 'table', 'Bad argument #2 to `Tabular` (table expected)')

		-- Arguments
		local parent   = assert(args.parent, 'Argument missing: parent')
		local width    = args.width or parent:GetWidth() - ROW_PADDING;
		local offset   = args.offset or 0;
		local callback = args.callback or nop; -- signature: path, key, value, state
		local alias    = (type(args.alias) == 'table') and Alias();
		local state    = not not args.state;
		local readOnly = not not args.readOnly;
		local inline   = not not args.inline;

		if alias then
			for set, patterns in pairs(args.alias) do
				alias:SetPatterns(set, patterns)
			end
		end

		if not inline then
			data = CopyTable(data)
		end

		local objects, prev = {};
		for key, set in spairs(data) do
			local obj = DataRow.Registry:Acquire()
			obj:Show()
			obj:SetWidth(width)
			obj:SetParent(parent)
			obj:SetAliasHandler(alias)
			obj:SetData(key, set, key)
			obj:SetChecked(state)
			obj:SetCallback(callback)
			obj:SetReadOnly(readOnly)
			if prev then
				obj:SetPoint('TOP', prev, 'BOTTOM', 0, 0)
			else
				obj:SetPoint('TOP', 0, offset)
			end
			prev = obj;
			objects[obj] = true;
		end

		return GenerateClosure(Compile, objects), GenerateClosure(Release, objects), objects;
	end;
})

RegisterNewSlashCommand(function(message)
	local retOK, data = pcall(loadstring, 'return ' .. message);
	if not retOK then print('Loadstring failed: ' .. data) return end;
	retOK, data = pcall(data)
	if not retOK then print('Failed to load data: ' .. data) return end;
	Tabular({parent = UIParent, width = 600, inline = true}, data)
end, 'tabular', 'tbl')