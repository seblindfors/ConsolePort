local Carpenter, _, env = LibStub:GetLibrary('Carpenter'), ...;
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

	Widgets[name] = function(self, ...)
		env.db.table.mixin(self, widget)
		self:OnLoad(...)
		return self;
	end;

	return widget;
end

Widgets.CreateWidget = CreateWidget;

---------------------------------------------------------------
-- Base widget object
---------------------------------------------------------------
local Widget = {};

function Widget:OnLoad(varID, metaData, controller, desc, note)
	self.metaData = metaData;
	self.variableID = varID;
	self.controller = controller;
	self.tooltipText = desc;
	self.tooltipNote = note;

	if self.blueprint then
		Carpenter:BuildFrame(self, self.blueprint, false, true)
	end
end

function Widget:GetMetadata()
	return self.metaData;
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
		GameTooltip:SetText(self:GetText())
		GameTooltip:AddLine(self.tooltipText, 1, 1, 1, 1)
		if self.tooltipNote then
			GameTooltip:AddLine('\n'..NOTE_COLON)
			GameTooltip:AddLine(self.tooltipNote, 1, 1, 1, 1)
		end
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

function Widget:OnValueChanged(...)
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
			self:EnableMouseWheel(false)
		end;
		_OnEnter = function(self)
			self:GetParent():OnEnter()
		end;
		_OnTextChanged = function(self, byInput)
			self:SetBackdropColor(COLOR_NORMAL:GetRGBA())
			local widget = self:GetParent()
			if byInput then
				self:GetParent():PreformatText(self:GetText())
			end
		end;
		_OnEnterPressed = function(self)
			self:ClearFocus()
			self:GetParent():FormatText(self:GetText())
		end;
		_OnEscapePressed = function(self)
			self:ClearFocus()
			self:GetParent():Set(self:GetParent():Get())
		end;
		_OnEditFocusGained = function(self)
			self:EnableMouseWheel(true)
		end;
		_OnEditFocusLost = function(self)
			self:EnableMouseWheel(false)
		end;
		_OnMouseWheel = function(self, delta)
			self:GetParent():Delta(delta)
			self:SetFocus()
		end;
	};
})

function Number:PreformatText(text)
	local text, reps = text:gsub('%-', '')
	if (reps > 0) then
		text = '-' .. text;
		self.Input:SetText(text)
	end
	if (text == '') or tonumber(text) then
		return;
	end -- set redish background to indicate failure
	self.Input:SetBackdropColor(1, 0, 0, 0.35)
end

function Number:FormatText(text)
	local value = tonumber(text)
	if not value or (not self:GetSigned() and value < 0) then
		self.Input:SetText(self:Get())
	elseif self.Input:HasFocus() then
		self.Input:SetText(value)
	else
		self:Set(value)
	end
end

function Number:Delta(delta)
	self:Set(self:Get() + (delta * self:GetStep()))
end

function Number:GetSigned()
	return self.controller:GetSigned()
end

function Number:GetStep()
	return self.controller:GetStep()
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
		_Point = {'RIGHT', -40, -6};
		_IgnoreNode = true;
		_SetObeyStepOnDrag = true;
		_OnLoad = function(self)
			local widget = self:GetParent()
			self:SetValueStep(widget:GetStep());
			self:SetMinMaxValues(widget.controller:GetMinMax());
		end;
		_OnMouseDown = function(self, button)
			self.isDraggingThumb = self:IsDraggingThumb();
		end;
		_OnMouseUp = function(self, button)
			if self.isDraggingThumb then
				self.isDraggingThumb = self:IsDraggingThumb();
				if not self.isDraggingThumb then
					self:GetParent():Set(self:GetValue())
				end
			end
		end;
		_OnValueChanged = function(self, value, byInput)
			if byInput then
				if self.isDraggingThumb then
					self:GetParent():OnValueChanged(value)
				else 
					self:GetParent():Set(value)
				end
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
		_Point = {'RIGHT', -40, -6};
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

---------------------------------------------------------------
-- Button
---------------------------------------------------------------
local Button = CreateWidget('Button', Widget, {
	Input = {
		_Type  = 'Button';
		_Setup = 'BackdropTemplate';
		_Point = {'RIGHT', -8, 0};
		_Size  = {200, 26};
		_IgnoreNode = true;
		_Backdrop = CPAPI.Backdrops.Opaque;
		_OnLoad = function(self)
			self:SetFontString(self.Label)
			self:SetBackdropColor(COLOR_NORMAL:GetRGBA());
			self:SetBackdropBorderColor(0.15, 0.15, 0.15, 1);
		end;
		{
			Label = {
				_Type  = 'FontString';
				_Setup = {'ARTWORK'};
				_OnLoad = function(self)
					self:SetFont(ChatFontNormal:GetFont())
				end;
				_Points = {
					{'TOPLEFT', 8, 0};
					{'BOTTOMRIGHT', -8, 0};
				};
			};
		};
	};
})

function Button:OnLoad(...)
	Widget.OnLoad(self, ...)
	self:EnableGamePadButton(false)
	self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
end

function Button:IsModifierAllowed()
	return self.controller:IsModifierAllowed()
end

function Button:OnGamePadButtonDown(button)
	if self:IsModifierAllowed() and env:GetActiveModifier(button) then
		return
	end
	self:Set(button)
	Widget.OnClick(self)
	env.Config:SetDefaultClosures()
end

function Button:OnClick(button)
	if (button == 'RightButton') then
		Widget.OnClick(self)
		self:Set('none', true)
	elseif self:GetChecked() then
		return env.Config:CatchAll(self.OnGamePadButtonDown, self)
	end
	env.Config:SetDefaultClosures()
end

function Button:OnValueChanged(value)
	local display = GetBindingText(value, 'KEY_ABBR_')
	if (display == 'none') then
		display = env.BindingInfo.NotBoundColor:format(NOT_BOUND)
	end
	self.Input:SetText(display)
end

---------------------------------------------------------------
-- Select
---------------------------------------------------------------
local Select = CreateWidget('Select', Widget, {
	Popout = {
		_Type  = 'Frame';
		_Setup = 'CPSelectionPopoutWithButtonsAndLabelTemplate';
		_Point = {'RIGHT', 0, 0};
	};
})

function Select:OnLoad(...)
	Widget.OnLoad(self, ...)
	self.Popout.OnEntryClick = function(_, entryData)
		self.Popout:HidePopout()
		self:Set(entryData.value)
	end
	self.Popout.OnPopoutShown = function(self)
		self.moveCursorOnClose = true;
	end;
	self.Popout.HidePopout = function(self)
		CPSelectionPopoutWithButtonsAndLabelMixin.HidePopout(self)
		if self.moveCursorOnClose then
			env.db.Cursor:SetCurrentNode(self.SelectionPopoutButton, true)
			self.moveCursorOnClose = nil;
		end
	end;
	self.Popout.OnEnterHook = function(self)
		local parent = self:GetParent()
		parent:GetScript('OnEnter')(parent)
	end;
	self.Popout.OnLeaveHook = function(self)
		local parent = self:GetParent()
		parent:GetScript('OnLeave')(parent)
	end;
	for _, obj in pairs({
		self.Popout,
		self.Popout.SelectionPopoutButton,
		self.Popout.IncrementButton,
		self.Popout.DecrementButton,
	}) do
		obj:HookScript('OnEnter', self.Popout.OnEnterHook)
		obj:HookScript('OnLeave', self.Popout.OnLeaveHook)
	end
end

function Select:OnValueChanged(value)
	local opts = self.controller:GetOptions()
	local inOrder, selected = {};
	value = tonumber(value) or value;
	for opt, val in env.db.table.spairs(opts) do
		inOrder[#inOrder + 1] = {
			name  = env.L(type(val) == 'string' and val or opt);
			value = opt;
		};
		if (value == opt) then
			selected = #inOrder;
		end
	end
	self.Popout:SetupSelections(inOrder, selected or 1)
end

---------------------------------------------------------------
-- Color
---------------------------------------------------------------
local Color = CreateWidget('Color', Widget, {
	Border = {
		_Type  = 'Texture';
		_Setup = {'BACKGROUND'};
		_Point = {'RIGHT', -8, 0};
		_Size  = {24, 24};
		_SetColorTexture = {0.25, 0.25, 0.25, 1}
	};
	Checker = {
		_Type  = 'Texture';
		_Setup = {'ARTWORK'};
		_Point = {'CENTER', '$parent.Border', 'CENTER', 0, 0};
		_Size  = {20, 20};
		_Texture = CPAPI.GetAsset('Textures\\Frame\\Backdrop_Vertex_Checker');
	};
	Color = {
		_Type  = 'Texture';
		_Setup = {'OVERLAY'};
		_Point = {'CENTER', '$parent.Border', 'CENTER', 0, 0};
		_Size  = {20, 20};
	};
})

function Color:OnClick(button)
	self:Uncheck()
	if (button == 'LeftButton') then
		local color, swatch, opacity = ColorPickerFrame, ColorSwatch, OpacitySliderFrame;

		local function OnColorChanged()
			if (color.owner == self) then
				local r, g, b = color:GetColorRGB()
				local a = opacity:GetValue()
				self:Set(r, g, b, 1 - a)
				self:OnValueChanged(self:Get())
			end
		end

		local function OnColorCancel(oldColor)
			if (color.owner == self) then
				self:Set(unpack(oldColor))
				self:OnValueChanged(self:Get())
			end
		end

		local r, g, b, a = self:GetRGBA(self:Get())
		color:Hide()
		color:SetColorRGB(r, g, b, a)
		color.hasOpacity = true;
		color.opacity = 1 - (a or 0);
		color.previousValues = {r, g, b, a};
		color.func = OnColorChanged;
		color.cancelFunc = OnColorCancel;
		color.opacityFunc = OnColorChanged;
		color.owner = self;
		color:Show()
		swatch:SetColorTexture(r, g, b)
	end
end

function Color:Set(r, g, b, a)
	if self:IsHex() then
		Widget.Set(self, ('%.2x%.2x%.2x%.2x'):format(a * 255, r * 255, g * 255, b * 255))
	else
		Widget.Set(self, r, g, b, a)
	end
end

function Color:GetRGBA(...)
	return self.controller:ConvertToRGBA(...):GetRGBA()
end

function Color:IsHex()
	return self.controller:IsHex()
end

function Color:OnValueChanged(...)
	self.Color:SetColorTexture(self:GetRGBA(...))
end

ColorPickerFrame:HookScript('OnHide', function(self) self.owner = nil; end)