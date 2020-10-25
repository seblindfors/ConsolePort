local db, Carpenter, _, env = ConsolePort:DB(), LibStub:GetLibrary('Carpenter'), ...;
local Widgets = {}; env.Widgets = Widgets;

---------------------------------------------------------------
-- Consts
---------------------------------------------------------------
local COLOR_CHECKED = CPIndexButtonMixin.IndexColors.Checked;
local COLOR_HILITE  = CPIndexButtonMixin.IndexColors.Hilite;
local COLOR_NORMAL  = CPIndexButtonMixin.IndexColors.Normal;

---------------------------------------------------------------
-- Create new widget
---------------------------------------------------------------
local function CreateWidget(name, inherit, blueprint)
	local widget = CreateFromMixins(inherit)
	widget.blueprint = blueprint;

	Widgets[name] = function(self, varID, data)
		db.table.mixin(self, widget)
		self:OnLoad(varID, data)
	end;

	return widget;
end

Widgets.CreateWidget = CreateWidget;

---------------------------------------------------------------
-- Base widget object
---------------------------------------------------------------
local Widget = {};

function Widget:OnLoad(varID, data)
	self.metaData = data;
	self.variableID = varID;
	self.controller = data[1];
	self.tooltipText = data.desc;
	self.controller:SetCallback(function(value) db('Settings/'..varID, value) end)
	db:RegisterCallback('Settings/'..varID, self.OnValueChanged, self)

	if self.blueprint then
		Carpenter:BuildFrame(self, self.blueprint, false, true)
	end
end

function Widget:Get()
	return db(self.variableID)
end

function Widget:Set(...)
	self.userInput = true;
	self.controller:Set(...)
	self.userInput = false;
end

function Widget:SetCallback(callback)
	self.controller:SetCallback(callback)
end

function Widget:IsUserInput()
	return self.userInput;
end

function Widget:OnEnter()
	if self.tooltipText then
		GameTooltip:SetOwner(self, 'ANCHOR_TOP')
		GameTooltip:SetText(self.tooltipText)
		GameTooltip:Show()
	end
end

function Widget:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function Widget:OnShow()
	self:OnValueChanged(self:Get())
end

function Widget:OnValueChanged(newValue)
	-- replace callback in mixin
end

-- default to just ignoring checked state
Widget.OnClick = CPIndexButtonMixin.Uncheck;

---------------------------------------------------------------
-- Boolean switch
---------------------------------------------------------------
local Bool = CreateWidget('Bool', Widget, {
	CheckBorder = {
		_Type  = 'Texture';
		_Setup = {'BACKGROUND'};
		_Point = {'RIGHT', -8, 0};
		_Size  = {24, 24};
	};
	CheckFill = {
		_Type  = 'Texture';
		_Setup = {'BORDER'};
		_Point = {'CENTER', '$parent.CheckBorder', 'CENTER', 0, 0};
		_Size  = {20, 20};
		_SetColorTexture = {0, 0, 0, 1};
	};
	CheckedTexture = {
		_Type  = 'Texture';
		_Hide  = true;
		_Setup = {'ARTWORK'};
		_Point = {'CENTER', '$parent.CheckBorder', 'CENTER', 0, 0};
		_Size  = {12, 12};
		_SetColorTexture = {COLOR_CHECKED:GetRGBA()};
	};
	CheckedHilite = {
		_Type  = 'Texture';
		_Setup = {'HIGHLIGHT'};
		_Point = {'CENTER', '$parent.CheckBorder', 'CENTER', 0, 0};
		_Size  = {12, 12};
		_Texture = CPAPI.GetAsset('Textures\\Frame\\Backdrop_Vertex_White');
		_Vertex = {COLOR_HILITE:GetRGBA()};
	};
})

function Bool:OnValueChanged(state)
	self.CheckedTexture:SetShown(state)
	self.CheckedHilite:SetShown(not state)
	if state then
		self.CheckBorder:SetColorTexture(COLOR_CHECKED:GetRGBA())
	else
		self.CheckBorder:SetColorTexture(0.25, 0.25, 0.25, 1)
	end
end

function Bool:OnClick()
	Widget.OnClick(self)
	self:Set(not self:Get())
end

---------------------------------------------------------------
-- Number
---------------------------------------------------------------
local Number = CreateWidget('Number', Widget, {
	Input = {
		_Type  = 'EditBox';
		_Setup = 'BackdropTemplate';
		_Point = {'RIGHT', -8, 0};
		_Size  = {60, 26};
		_IgnoreNode = true;
		_SetAutoFocus = false;
		_SetFontObject = ChatFontNormal;
		_SetTextInsets = {8, 8, 0, 0};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_OnLoad = function(self)
			self:SetBackdropColor(COLOR_NORMAL:GetRGBA());
			self:SetBackdropBorderColor(0.15, 0.15, 0.15, 1);
		end;
		_OnTextChanged = function(self, byInput)
			local widget = self:GetParent()
			if byInput then
				local value = tonumber(self:GetText())
				if not value or (not widget:GetSigned() and value < 0) then
					self:SetText(widget:Get())
				else
					widget:Set(value)
				end
			end
		end;
	};
})

function Number:GetSigned()
	return self.controller:GetSigned()
end

function Number:GetStep()
	return self.controller:GetStep()
end

function Number:OnShow()
	self:OnValueChanged(self:Get())
end

function Number:OnLeftButton()
	self:Set(self:Get() - self:GetStep())
end

function Number:OnRightButton()
	self:Set(self:Get() + self:GetStep())
end

function Number:OnClick()
	if self:GetChecked() then
		self.CatchLeft  = env.Config:CatchButton('PADDLEFT', self.OnLeftButton, self)
		self.CatchRight = env.Config:CatchButton('PADDRIGHT', self.OnRightButton, self)
	else
		env.Config:FreeButton('PADDLEFT', self.CatchLeft)
		env.Config:FreeButton('PADDRIGHT', self.CatchRight)
		self.CatchLeft, self.CatchRight = nil, nil;
	end
end

function Number:OnValueChanged(value)
	self.Input:SetText(value)
end

---------------------------------------------------------------
-- Range
---------------------------------------------------------------
local Range = CreateWidget('Range', Number, {
	Input = {
		_Type  = 'Slider';
		_Setup = 'CPConfigSliderTemplate';
		_Point = {'RIGHT', -44, -6};
		_IgnoreNode = true;
		_SetObeyStepOnDrag = true;
		_OnLoad = function(self)
			local widget = self:GetParent()
			self:SetValueStep(widget:GetStep());
			self:SetMinMaxValues(widget.controller:GetMinMax());
		end;
		_OnValueChanged = function(self, value, byInput)
			if byInput then
				self:GetParent():Set(value)
			end
		end;
	};
})

function Range:OnValueChanged(value)
	local step = self.controller:GetStep()
	self.Input:SetValue(value)
	self.Input.Text:SetText(Round(value / step) * step)
end

---------------------------------------------------------------
-- Delta
---------------------------------------------------------------
local Delta = CreateWidget('Delta', Range, {
	Input = {
		_Type  = 'Slider';
		_Setup = 'CPConfigSliderTemplate';
		_Point = {'RIGHT', -44, -6};
		_IgnoreNode = true;
		_SetObeyStepOnDrag = true;
		_SetValueStep = 2;
		_SetMinMaxValues = {-1, 1};
		_OnValueChanged = function(self, value, byInput)
			local widget = self:GetParent()
			if byInput and widget.controller:IsOption(value) then
				widget:Set(value)
			end
		end;
	};
})

function Delta:GetStep()
	return 2;
end

function Delta:OnValueChanged(value)
	self.Input:SetValue(value)
	self.Input.Text:SetText(value == 1 and '+' or value == -1 and '-')
end

---------------------------------------------------------------
-- String
---------------------------------------------------------------
local String = CreateWidget('String', Widget, {
	Input = {
		_Type  = 'EditBox';
		_Setup = 'BackdropTemplate';
		_Point = {'RIGHT', -8, 0};
		_Size  = {200, 26};
		_IgnoreNode = true;
		_SetAutoFocus = false;
		_SetFontObject = ChatFontNormal;
		_SetTextInsets = {8, 8, 0, 0};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_OnLoad = function(self)
			self:SetBackdropColor(COLOR_NORMAL:GetRGBA());
			self:SetBackdropBorderColor(0.15, 0.15, 0.15, 1);
		end;
		_OnEscapePressed = function(self)
			self:SetText(self:GetParent():Get() or '')
			self:ClearFocus()
		end;
		_OnEnterPressed = function(self)
			local text = self:GetText()
			self:GetParent():Set(text:len() > 0 and text or nil)
			self:ClearFocus()
		end;
		_OnEditFocusLost = function(self)
			self:GetParent():Uncheck()
		end;
		_OnEditFocusGained = function(self)
			self:GetParent():Check()
		end;
	};
})

function String:OnClick()
	local input = self.Input;
	if input:HasFocus() then
		self.Input:ClearFocus()
	else
		self.Input:SetFocus()
	end
end

function String:OnValueChanged(value)
	self.Input:SetText(value or '')
end