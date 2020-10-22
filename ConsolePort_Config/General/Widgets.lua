local db, Carpenter, _, env = ConsolePort:DB(), LibStub:GetLibrary('Carpenter'), ...;
local Widgets = {}; env.Widgets = Widgets;

---------------------------------------------------------------
-- Consts
---------------------------------------------------------------
local COLOR_CHECKED = CPIndexButtonMixin.IndexColors.Checked;
local COLOR_HILITE  = CPIndexButtonMixin.IndexColors.Hilite;
local COLOR_NORMAL  = CPIndexButtonMixin.IndexColors.Normal;

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

---------------------------------------------------------------
-- Boolean switch
---------------------------------------------------------------
local Bool = CreateFromMixins(Widget);

function Bool:OnLoad(varID, data)
	Widget.OnLoad(self, varID, data)
	Carpenter:BuildFrame(self, {
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
	}, false, true)
end

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
	self:SetChecked(false)
	self:OnChecked(false)
	self:Set(not self:Get())
end

function Widgets.Bool(self, varID, data)
	db.table.mixin(self, Bool)
	self:OnLoad(varID, data)
end

---------------------------------------------------------------
-- Number
---------------------------------------------------------------
local Number = CreateFromMixins(Widget);

function Number:OnLoad(varID, data)
	Widget.OnLoad(self, varID, data)
	Carpenter:BuildFrame(self, {
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
			_OnTextChanged = function(input, byInput)
				if byInput then
					local value = tonumber(input:GetText())
					if not value or (not self:GetSigned() and value < 0) then
						input:SetText(self:Get())
					else
						self:Set(value)
					end
				end
			end;
		};
	})
end

--function Number:Set(value)
--	Widget.Set(self, self:GetSigned() and value or abs(value))
--end

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

function Number:OnEnter()
	Widget.OnEnter(self)
	self.CatchLeft  = env.Config:CatchButton('PADDLEFT', self.OnLeftButton, self)
	self.CatchRight = env.Config:CatchButton('PADDRIGHT', self.OnRightButton, self)
end

function Number:OnLeave()
	Widget.OnLeave(self)
	env.Config:FreeButton('PADDLEFT', self.CatchLeft)
	env.Config:FreeButton('PADDRIGHT', self.CatchRight)
	self.CatchLeft, self.CatchRight = nil, nil;
end

function Number:OnValueChanged(value)
	self.Input:SetText(value)
end

function Widgets.Number(self, varID, data)
	db.table.mixin(self, Number)
	self:OnLoad(varID, data)
end

---------------------------------------------------------------
-- Range
---------------------------------------------------------------
local Range = CreateFromMixins(Number);

function Range:OnLoad(varID, data)
	Widget.OnLoad(self, varID, data)
	Carpenter:BuildFrame(self, {
		Input = {
			_Type  = 'Slider';
			_Setup = 'CPConfigSliderTemplate';
			_Point = {'RIGHT', -44, -6};
			_IgnoreNode = true;
			_SetObeyStepOnDrag = true;
			_SetValueStep = {self:GetStep()};
			_SetMinMaxValues = {self.controller:GetMinMax()};
			_OnValueChanged = function(input, value, byInput)
				if byInput then
					self:Set(value)
				end
			end;
		};
	})
end

function Range:OnValueChanged(value)
	local step = self.controller:GetStep()
	self.Input:SetValue(value)
	self.Input.Text:SetText(Round(value / step) * step)
end

function Widgets.Range(self, varID, data)
	db.table.mixin(self, Range)
	self:OnLoad(varID, data)
end

---------------------------------------------------------------
-- Delta
---------------------------------------------------------------
local Delta = CreateFromMixins(Range);

function Delta:OnLoad(varID, data)
	Widget.OnLoad(self, varID, data)
	Carpenter:BuildFrame(self, {
		Input = {
			_Type  = 'Slider';
			_Setup = 'CPConfigSliderTemplate';
			_Point = {'RIGHT', -44, -6};
			_IgnoreNode = true;
			_SetObeyStepOnDrag = true;
			_SetValueStep = 2;
			_SetMinMaxValues = {-1, 1};
			_OnValueChanged = function(input, value, byInput)
				if byInput and self.controller:IsOption(value) then
					self:Set(value)
				end
			end;
		};
	})
end

function Delta:GetStep()
	return 2;
end

function Delta:OnValueChanged(value)
	self.Input:SetValue(value)
	self.Input.Text:SetText(value == 1 and '+' or value == -1 and '-')
end

function Widgets.Delta(self, varID, data)
	db.table.mixin(self, Delta)
	self:OnLoad(varID, data)
end