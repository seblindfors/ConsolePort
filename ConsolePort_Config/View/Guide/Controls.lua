local DP, env, db, _, L = 1, CPAPI.GetEnv(...);
local Guide = env:GetContextPanel();

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local CONTENT_WIDTH = 500;
local LAYOUT_FRAME_WIDTH = 325;
local Gamepad = db.Gamepad;

local function ResetOption(_, option)
	if option.OnRelease then
		option:OnRelease()
	end
	option:ClearAllPoints()
	option:Hide()
end

---------------------------------------------------------------
local SchemeButton = {};
---------------------------------------------------------------

function SchemeButton:OnLoad()
	self.InnerContent.Selected:SwapAtlas('glues-characterselect-card-glow')
	self.InnerContent.SelectedHighlight:SwapAtlas('glues-characterselect-card-glow')
end

function SchemeButton:OnShow()
	self:init()
	if self.subscribe then
		for _, event in ipairs(self.subscribe) do
			db:RegisterCallback(event, self.Update, self)
		end
	end
end

function SchemeButton:OnHide()
	if self.subscribe then
		for _, event in ipairs(self.subscribe) do
			db:UnregisterCallback(event, self)
		end
	end
	if self.textures then
		for texture in pairs(self.textures) do
			self.txPool:Release(texture);
		end
		self.textures = nil;
	end
end

function SchemeButton:OnClick()
	self:execute()
end

function SchemeButton:OnEnter()
	CPCardSmallMixin.OnEnter(self)
	env:TriggerEvent('Controls.ShowInformation', true, self.row, self.col)
end

function SchemeButton:OnLeave()
	CPCardSmallMixin.OnLeave(self)
	env:TriggerEvent('Controls.ShowInformation', false, self.row, self.col)
end

function SchemeButton:Update()
	self:SetChecked(self.predicate())
end

function SchemeButton:AcquireTexture()
	self.textures = self.textures or {};
	local texture = self.txPool:Acquire();
	self.textures[texture] = true;
	texture:SetParent(self)
	texture:SetDrawLayer('ARTWORK', 1)
	texture:SetDesaturated(false)
	texture:Show()
	return texture;
end

function SchemeButton:GetDevice()
	return Gamepad.Active;
end

---------------------------------------------------------------
local SchemeSelect = CreateFromMixins(SchemeButton);
---------------------------------------------------------------

function SchemeSelect:SetData(data, row, col)
	Mixin(self, data)
	self.row, self.col = row, col;
	self.init = self.init or nop;
	self.Text:SetText(data.text)
	self:OnShow()
	self:Update()
end

---------------------------------------------------------------
local Option = {};
---------------------------------------------------------------

function Option:PostMount()
	self:HookScript('OnEnter', self.LockHighlight)
	self:HookScript('OnLeave', self.UnlockHighlight)
	self:SetWidth(self:GetParent():GetWidth())
	self.Text:SetPoint('LEFT', 8, 0)
	if self.Input then
		self.Input:SetWidth(min(self.Input:GetWidth(), self:GetWidth() * 0.4))
	end

	local normalTexture = self:GetNormalTexture()
	normalTexture:SetPoint('TOPLEFT', -8, 0)
	normalTexture:SetPoint('BOTTOMRIGHT', 8, 0)
	local hiliteTexture = self:GetHighlightTexture()
	hiliteTexture:SetPoint('TOPLEFT', -8, 0)
	hiliteTexture:SetPoint('BOTTOMRIGHT', 8, 0)
end

---------------------------------------------------------------
local Cvar = CreateFromMixins(Option);
---------------------------------------------------------------

function Cvar:SetMountData(varID, data)
	self:Mount({
		name     = data.name;
		varID    = varID;
		field    = data;
		newObj   = true;
		owner    = env.Frame;
		registry = db;
		callbackID = varID;
		callbackFn = function(value)
			self:SetRaw(self.variableID, value, self.variableID)
			self:OnValueChanged(value)
			local device = db('Gamepad/Active')
			if device then
				device.Preset.Variables[self.variableID] = value;
				device:Activate()
			end
			db:TriggerEvent(self.variableID, value)
		end;
	})
	self:PostMount()
end

---------------------------------------------------------------
local Setting = CreateFromMixins(Option);
---------------------------------------------------------------

function Setting:SetMountData(varID, data)
	self:Mount({
		name     = data.name;
		varID    = varID;
		field    = data;
		newObj   = true;
		owner    = env.Frame;
		registry = db;
	})
	self:PostMount()
end


---------------------------------------------------------------
local InfoContainer = {};
---------------------------------------------------------------

function InfoContainer:OnLoad()
	self.Title = Guide.CreateHeader(self, LAYOUT_FRAME_WIDTH);
	self.Label = Guide.CreateText(self, LAYOUT_FRAME_WIDTH);
	self.Title.layoutIndex = 1;
	self.Label.layoutIndex = 2;
end

function InfoContainer:SetTexts(title, label)
	self.Title:SetText(Guide.CreateInfoMarkup(title))
	self.Label:SetText(CPAPI.FormatLongText(label))
end

function InfoContainer:SetData(data, ref)
	self:SetTexts(data and INFO or CONTROLS_LABEL, data and data.desc or L.CONTROLS_GENERAL_INFO)
	self:UpdatePosition(ref)
end

function InfoContainer:UpdatePosition(ref)
	self:ClearAllPoints()
	self:SetPoint(self.pntAnchor, ref, self.relAnchor, self.xOffset, self.yOffset)
	self:Layout()
end

---------------------------------------------------------------
local OptionsContainer = CreateFromMixins(InfoContainer);
---------------------------------------------------------------

function OptionsContainer:OnLoad()
	InfoContainer.OnLoad(self)

	self.cvarPool    = CreateFramePoolCollection()
	self.settingPool = CreateFramePoolCollection()
end

function OptionsContainer:SetData(data, ref, shouldShow)
	-- This means we triggered the OnLeave when moving from the
	-- scheme button to the list of options, so we want to noop.
	if not shouldShow and self.variableRef then return end;

	self:Reset()
	self:SetShown(not not data)
	if not self:IsShown() then return end;

	local desc = data.desc;
	if data.recommend then
		desc = ('%s\n\n%s'):format(desc, Guide.CreateRecommendMarkup(RECOMMENDED))
	elseif data.advanced then
		desc = ('%s\n\n%s'):format(desc, Guide.CreateAdvancedMarkup(ADVANCED_LABEL))
	end

	self.Label:Show()
	self:SetTexts(data.text, desc)
	self:UpdatePosition(ref)
end

function OptionsContainer:SetVariables(variables, ref)
	self:Show()
	self:Reset()
	self:UpdatePosition(ref)
	self.Label:Hide()

	self.variableRef = ref;
	local layoutIndex = 2;
	for i, variable in ipairs(variables) do
		if variable.cvar then
			self:InsertCvar(variable, layoutIndex + i)
		else
			self:InsertSetting(variable, layoutIndex + i)
		end
	end
	self:Layout()
end

function OptionsContainer:GetOrCreatePool(poolCollection, type)
	return poolCollection:GetOrCreatePool(
		'CheckButton', self, 'CPPopupButtonBaseTemplate', ResetOption, nil, type);
end

function OptionsContainer:InsertCvar(variable, layoutIndex)
	local pool = self:GetOrCreatePool(self.cvarPool, variable.type():GetType())
	local widget, newObj = pool:Acquire();
	if newObj then
		Mixin(widget, env.Elements.Cvar, Cvar)
	end
	widget:OnAcquire(newObj)
	widget:SetMountData(variable.cvar, variable)
	widget:Show()
	widget.layoutIndex = layoutIndex;
end

function OptionsContainer:InsertSetting(variable, layoutIndex)
	local pool = self:GetOrCreatePool(self.settingPool, variable[DP]:GetType())
	local widget, newObj = pool:Acquire();
	if newObj then
		Mixin(widget, env.Elements.Setting, Setting)
	end
	widget:SetMountData(variable.varID, variable)
	widget:Show()
	widget.layoutIndex = layoutIndex;
end

function OptionsContainer:Reset()
	self.cvarPool:ReleaseAll()
	self.settingPool:ReleaseAll()
	self.variableRef = nil;
end

---------------------------------------------------------------
local SchemeContent = {}; do
---------------------------------------------------------------
	local function HasCVars(cvars, cmp)
		for i, cvar in ipairs(cvars) do
			if db:GetCVar(cvar, cmp[i]) ~= cmp[i] then
				return false;
			end
		end
		return true;
	end

	local function SetCVars(cvars, values)
		for i, cvar in ipairs(cvars) do
			db:SetCVar(cvar, values[i]);
		end
	end

	local function AddIconTexture(delta, size, offX, offY, self)
		local texture = self:AcquireTexture();
		texture:SetPoint('CENTER', delta * offX, offY)
		texture:SetSize(size, size)
		return texture;
	end

	local AddLeftIcon  = GenerateClosure(AddIconTexture, -1, 40, 24, 8);
	local AddRightIcon = GenerateClosure(AddIconTexture,  1, 40, 24, 8);

	local function GetModifierCVars()
		return { 'GamePadEmulateShift', 'GamePadEmulateCtrl', 'GamePadEmulateAlt', 'GamePadEmulateTapWindowMs' };
	end

	local HasModifiers = GenerateClosure(HasCVars, GetModifierCVars());
	local SetModifiers = GenerateClosure(SetCVars, GetModifierCVars());

	local LeftHandModifiers = { 'PADLSHOULDER', 'PADLTRIGGER', 'none', 350 };
	local TriggerModifiers  = { 'PADLTRIGGER',  'PADRTRIGGER', 'none', 350 };

	tinsert(SchemeContent, {
		-- Row 1: Modifiers
		text = L'Modifiers';
		desc = L.CONTROLS_MODIFIERS_DESC;
		type = SchemeSelect;
		{ -- 1.1 Left handed modifiers
			text      = L'Left';
			desc      = L.CONTROLS_MODIFIERS_LEFT;
			recommend = true;
			subscribe = GetModifierCVars();
			predicate = GenerateClosure(HasModifiers, LeftHandModifiers);
			execute   = GenerateClosure(SetModifiers, LeftHandModifiers);
			init = function(self)
				Gamepad.SetIconToTexture(AddLeftIcon(self),  'PADLSHOULDER');
				Gamepad.SetIconToTexture(AddRightIcon(self), 'PADLTRIGGER');
			end;
		};
		{ -- 1.2 Trigger modifiers
			text      = L'Triggers';
			desc      = L.CONTROLS_MODIFIERS_TRIGGERS;
			subscribe = GetModifierCVars();
			predicate = GenerateClosure(HasModifiers, TriggerModifiers);
			execute   = GenerateClosure(SetModifiers, TriggerModifiers);
			init = function(self)
				local LT = AddLeftIcon(self);
				Gamepad.SetIconToTexture(LT, 'PADLTRIGGER');

				local RT = AddRightIcon(self);
				Gamepad.SetIconToTexture(RT, 'PADRTRIGGER');
			end;
		};
		{ -- 1.3 Custom modifiers
			text      = CUSTOM;
			desc      = L.CONTROLS_MODIFIERS_CUSTOM;
			advanced  = true;
			subscribe = GetModifierCVars();
			predicate = function()
				return  not HasModifiers(LeftHandModifiers)
					and not HasModifiers(TriggerModifiers);
			end;
			execute = function(self)
				self:SetChecked(self.predicate())
				local variables = GetModifierCVars()
				for i, cvar in ipairs(variables) do
					variables[i] = db.Console:GetMetadata(cvar);
				end
				env:TriggerEvent('Controls.ShowVariables', variables, self.row);
			end;
			init = function(self)
				Gamepad.SetIconToTexture(AddLeftIcon(self),  'PADLTRIGGER');
				Gamepad.SetIconToTexture(AddRightIcon(self), 'PADRTRIGGER');

				local LB = self:AcquireTexture();
				LB:SetPoint('CENTER', 0, 20)
				LB:SetSize(40, 40)
				LB:SetDrawLayer('ARTWORK', -1)
				Gamepad.SetIconToTexture(LB, 'PADLSHOULDER');

				local PC = self:AcquireTexture();
				PC:SetPoint('CENTER', 0, -4)
				PC:SetSize(60, 30)
				PC:SetDrawLayer('ARTWORK', 2)
				PC:SetDesaturated(true)
				PC:SetTexture([[Interface\AddOns\ConsolePort_Config\Assets\master]])
			end;
		}
	});

	local function GetMouseButtonCVars()
		return { 'GamePadCursorLeftClick', 'GamePadCursorRightClick' };
	end

	local HasMouseButtons = GenerateClosure(HasCVars, GetMouseButtonCVars());
	local SetMouseButtons = GenerateClosure(SetCVars, GetMouseButtonCVars());

	local RegularMouseSetup  = { 'PADLSTICK', 'PADRSTICK' };
	local InvertedMouseSetup = { 'PADRSTICK', 'PADLSTICK' };

	tinsert(SchemeContent, {
		-- Row 2: Mouse buttons
		text = MOUSE_LABEL;
		desc = L.CONTROLS_MOUSE_BUTTONS_DESC;
		type = SchemeSelect;
		{ -- 2.1 Inverted mouse setup
			text      = L'Inverted';
			desc      = L.CONTROLS_MOUSE_INVERTED;
			subscribe = GetMouseButtonCVars();
			predicate = GenerateClosure(HasMouseButtons, InvertedMouseSetup);
			execute   = GenerateClosure(SetMouseButtons, InvertedMouseSetup);
			init = function(self)
				Gamepad.SetIconToTexture(AddLeftIcon(self),  'PADRSTICK');
				Gamepad.SetIconToTexture(AddRightIcon(self), 'PADLSTICK');
			end;
		};
		{ -- 2.2 Regular mouse setup
			text      = L'Regular';
			desc      = L.CONTROLS_MOUSE_REGULAR;
			subscribe = GetMouseButtonCVars();
			predicate = GenerateClosure(HasMouseButtons, RegularMouseSetup);
			execute   = GenerateClosure(SetMouseButtons, RegularMouseSetup);
			recommend = true;
			init = function(self)
				Gamepad.SetIconToTexture(AddLeftIcon(self),  'PADLSTICK');
				Gamepad.SetIconToTexture(AddRightIcon(self), 'PADRSTICK');
			end;
		};
		{ -- 2.3 Custom mouse setup
			text      = CUSTOM;
			desc      = L.CONTROLS_MOUSE_CUSTOM;
			advanced  = true;
			subscribe = GetMouseButtonCVars();
			predicate = function()
				return  not HasMouseButtons(RegularMouseSetup)
					and not HasMouseButtons(InvertedMouseSetup);
			end;
			execute = function(self)
				self:SetChecked(self.predicate())
				local variables = GetMouseButtonCVars()
				for i, cvar in ipairs(variables) do
					variables[i] = db.Console:GetMetadata(cvar);
				end
				env:TriggerEvent('Controls.ShowVariables', variables, self.row);
			end;
			init = function(self)
				local M1 = AddLeftIcon(self)
				M1:SetTexture([[Interface\AddOns\ConsolePort_Bar\Assets\Textures\Icons\LMB]])

				local M2 = AddRightIcon(self)
				M2:SetTexture([[Interface\AddOns\ConsolePort_Bar\Assets\Textures\Icons\RMB]])

				local PC = self:AcquireTexture();
				PC:SetPoint('CENTER', 0, -4)
				PC:SetSize(60, 30)
				PC:SetDrawLayer('ARTWORK', 2)
				PC:SetDesaturated(true)
				PC:SetTexture([[Interface\AddOns\ConsolePort_Config\Assets\master]])
			end;
		};
	})
end -- SchemeContent

---------------------------------------------------------------
local Controls = {};
---------------------------------------------------------------

function Controls:OnLoad()
	local canvas = self:GetCanvas();
	self:SetAllPoints(canvas)

	local scrollChild = self.Browser.ScrollChild;
	self.RowInfo    = scrollChild.RowInfo;
	self.ColInfo    = scrollChild.ColInfo;
	self.buttonPool = CreateFramePool('CheckButton', scrollChild, 'CPControlSchemeButton')
	self.txPool     = CreateTexturePool(scrollChild, 'ARTWORK')

	CPAPI.Specialize(self.RowInfo, InfoContainer)
	CPAPI.Specialize(self.ColInfo, OptionsContainer)

	-- Position scheme buttons
	local function CalculateButtonOffset(col, numColumns)
		return (col - 1) * (CONTENT_WIDTH / numColumns)
			- (CONTENT_WIDTH / 2)
			+ (CONTENT_WIDTH / (2 * numColumns));
	end

	-- Set up scheme content
	self.headers = {};
	local topOffset = -80;
	for row, dataRows in ipairs(SchemeContent) do
		local header = Guide.CreateHeader(scrollChild, CONTENT_WIDTH)
		header.Text:SetText(dataRows.text)
		header:SetPoint('TOP', 0, topOffset)
		self.headers[row] = header;

		local numColumns = #dataRows;
		for col, data in ipairs(dataRows) do
			local button, newObj = self.buttonPool:Acquire();
			if newObj then
				CPAPI.Specialize(button, dataRows.type)
				button.txPool = self.txPool;
			end
			button:SetData(data, row, col)
			button:SetPoint('TOP', header, 'BOTTOM', CalculateButtonOffset(col, numColumns), -10)
			button:Show()
			-- setup the buttons
		end
		topOffset = topOffset - 200;
	end
	RunNextFrame(function()
		scrollChild:SetMinimumWidth(self.Browser:GetWidth())
		scrollChild:SetHeightPadding(100)
		scrollChild:Layout()
	end)
end

function Controls:OnShow()
	env:RegisterCallback('Controls.ShowInformation', self.ShowInformation, self)
	env:RegisterCallback('Controls.ShowVariables', self.ShowVariables, self)
end

function Controls:OnHide()
	env:UnregisterCallback('Controls.ShowInformation', self)
	env:UnregisterCallback('Controls.ShowVariables', self)
end

function Controls:ShowInformation(shouldShow, row, col)
	local rowInfo = SchemeContent[row];
	local colInfo = rowInfo and rowInfo[col];
	row = row or 1;

	local ref = self.headers[row];
	self.RowInfo:SetData(rowInfo, ref, shouldShow)
	self.ColInfo:SetData(colInfo, ref, shouldShow)
end

function Controls:ShowVariables(variables, row)
	self.ColInfo:SetVariables(variables, self.headers[row])
end

---------------------------------------------------------------
-- Add controls to guide content
---------------------------------------------------------------
do local TutorialIncomplete, HasActiveDevice = env.TutorialPredicate('ControlScheme'), env.HasActiveDevice();

	local function ShowControlsPredicate()
		return not HasActiveDevice() or TutorialIncomplete();
	end

	Guide:AddContent('Controls', ShowControlsPredicate,
	function(canvas, GetCanvas)
		if not canvas.Controls then
			canvas.Controls = CreateFrame('Frame', nil, canvas, 'CPControlsPanel')
			canvas.Controls.GetCanvas = GetCanvas;
			CPAPI.SpecializeOnce(canvas.Controls, Controls)
		end
		canvas.Controls:Show()
	end, function(canvas)
		if not canvas.Controls then return end;
		canvas.Controls:Hide()
	end, env.HasActiveDevice())
end