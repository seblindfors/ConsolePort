local Carpenter, env, db = LibStub:GetLibrary('Carpenter'), CPAPI.GetEnv(...);
local Settings = {}; env.Settings = Settings;
---------------------------------------------------------------
-- Settings
---------------------------------------------------------------
-- Convert to or inherit a data handler widget design to work
-- with the data interface. Calling a widget will construct the
-- necessary frames and handlers to handle a given datapoint.
-- Arguments to a widget:
-- @param owner frame on which the widget should be implemented
-- @param varID identifier for the variable the widget changes
-- @param meta  metadata, see Model\Data\Data.lua:Field
-- @param ctrl  controller, which contains data and callback
-- @param desc  description for tooltips
-- @param note  notes for tooltips
-- @return owner

---------------------------------------------------------------
-- Consts
---------------------------------------------------------------
local COLOR_CHECKED = CPIndexButtonMixin.IndexColors.Checked;
local COLOR_HILITE  = CPIndexButtonMixin.IndexColors.Hilite;
local COLOR_NORMAL  = CPIndexButtonMixin.IndexColors.Normal;
local NONE          = 'none';

---------------------------------------------------------------
-- Create new widget
---------------------------------------------------------------
local function CreateWidget(name, inherit, blueprint)
	local widget = CreateFromMixins(inherit)
	widget.blueprint = blueprint;

	Settings[name] = function(self, ...)
		if not Settings.Registry[self] then
			db.table.mixin(self, widget)
		end
		self:OnLoad(...)
		return self;
	end;

	return widget;
end

Settings.CreateWidget = CreateWidget;
Settings.Registry     = {};

---------------------------------------------------------------
-- Base widget object
---------------------------------------------------------------
local Widget = {}; Settings.Base = Widget;

function Widget:OnLoad(varID, metaData, controller, desc, note, owner)
	self.metaData    = metaData;
	self.variableID  = varID;
	self.controller  = controller;
	self.tooltipText = desc;
	self.tooltipNote = note;
	self.owner       = owner or env.Config;

	if self.blueprint and not Settings.Registry[self] then
		Settings.Registry[Carpenter:BuildFrame(self, self.blueprint, false, true)] = true;
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

function Widget:SetDefault()
	self.userInput = true;
	self.controller:SetDefault()
	self.userInput = false;
end

function Widget:SetDataCallback(callback)
	self.controller:SetCallback(callback)
end

function Widget:IsUserInput()
	return self.userInput;
end

function Widget:OnEnter()
	self.isTooltipOwned = true;
	self:UpdateTooltip()
end

function Widget:OnLeave()
	self.isTooltipOwned = nil;
	if self.extraTooltip then
		self.extraTooltip:Hide()
		self.extraTooltip = nil;
	end
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function Widget:OnShow()
	local value = {self:Get()}
	local valueExists = next(value) ~= nil;
	self:SetAlpha(valueExists and 1 or .5)
	self:SetEnabled(valueExists)
	if valueExists then
		tinsert(value, valueExists)
		self:OnValueChanged(unpack(value))
	else
		self:OnValueChanged(nil, false)
	end
	if self.Input then
		self.Input:EnableMouse(valueExists)
	end
end

function Widget:OnHide()
	if self.closures then
		for button, closure in pairs(self.closures) do
			self.owner:FreeButton(button, closure)
		end
		self.closures = nil;
	end
end

function Widget:ToggleClosure(button, enabled, callback, ...)
    if not button then
        self.closures = nil;
        return enabled and self.owner:CatchAll(callback, ...) or self.owner:SetDefaultClosures()
    end

    if enabled then
        self.closures = self.closures or {};
        self.closures[button] = self.owner:CatchButton(button, callback, ...)
    elseif self.closures and self.closures[button] then
        self.owner:FreeButton(button, self.closures[button])
        self.closures[button] = nil;
        if not next(self.closures) then
            self.closures = nil;
        end
    end
end

function Widget:SetTooltipHints(arg1, arg2)
	if type(arg1) == 'table' then
		self.tooltipHints = arg1;
		return;
	end
	self.tooltipHints   = nil;
	self.leftClickHint  = arg1;
	self.rightClickHint = arg2;
end

function Widget:OnValueChanged(...)
	-- replace callback in mixin
end

-- default to just ignoring checked state
Widget.OnClick = CPIndexButtonMixin.Uncheck;

---------------------------------------------------------------
-- Widget:UpdateTooltip
-- Updates the tooltip for the widget, displaying various information.
-- Arguments:
--   text  : (string) Main tooltip text, shown at the top.
--   note  : (string) Additional note, shown below the main text.
--   hints : (table)  List of hint strings, typically usage instructions or keybinds.
--   dbls  : (table)  List of double-line entries, each as a table {left, right}.
-- Key value pairs:
--   self.tooltipText             : Default text if 'text' not provided.
--   self.tooltipNote             : Default note if 'note' not provided.
--   self.tooltipDoubles          : Default double-line hints if 'dbls' not provided.
--   self.tooltipHints            : Default hints if 'hints' not provided.
--   self.leftClickHint           : Custom left click hint text.
--   self.rightClickHint          : Custom right click hint text.
--   self.tooltipImage            : If set, shows an image in a secondary tooltip.
--   self.tooltipAnchor           : Custom anchor for tooltip.
--   self.disableTooltipInit      : If set, omits default tooltip handling.
--   self.disableTooltipHints     : If true, disables automatic hint generation.
--   self.useDefaultTooltipAnchor : If true, uses default anchor for tooltip.
---------------------------------------------------------------
function Widget:UpdateTooltip(text, note, hints, dbls)
	if not self.isTooltipOwned then return end;
	text = text or self.tooltipText;
	note = note or self.tooltipNote;
	dbls = dbls or self.tooltipDoubles;
	hints = hints or self.tooltipHints;
	if not hints and not self.disableTooltipHints then
		local useMouseHints = not ConsolePort:IsCursorNode(self);
		hints = {
			env:GetTooltipPromptForClick('LeftClick',  self.leftClickHint or EDIT, useMouseHints);
			env:GetTooltipPromptForClick('RightClick', self.rightClickHint or DEFAULT, useMouseHints);
		};
	end
	local hasTextToDisplay = text or note or hints;
	if hasTextToDisplay then
		if not self.disableTooltipInit then
			local setOwner = self.useDefaultTooltipAnchor and GameTooltip_SetDefaultAnchor or GameTooltip.SetOwner;
			setOwner(GameTooltip, self, self.tooltipAnchor or 'ANCHOR_TOP');
			GameTooltip:SetText(self:GetText())
		end
		if text then
			GameTooltip:AddLine(text, 1, 1, 1, 1)
		end
		if note then
			if text then
				GameTooltip:AddLine('\n'..NOTE_COLON)
			end
			GameTooltip:AddLine(note, 1, 1, 1, 1)
		end
		if dbls then
			for _, line in ipairs(dbls) do
				GameTooltip:AddDoubleLine(unpack(line))
			end
		end
		if hints then
			if text or note or dbls then
				GameTooltip:AddLine('\n')
			end
			for _, line in ipairs(hints) do
				GameTooltip:AddLine(line)
			end
		end
		GameTooltip:Show()
	end
	local image = self.tooltipImage;
	if image then
		local owner  = hasTextToDisplay and GameTooltip or self;
		local anchor = hasTextToDisplay and 'ANCHOR_NONE' or 'ANCHOR_TOP';
		local frame  = hasTextToDisplay and GameTooltip.shoppingTooltips[1] or GameTooltip;
		if frame then
			frame:SetOwner(owner, anchor)
			if hasTextToDisplay then
				frame:SetPoint('LEFT', GameTooltip, 'RIGHT', 0, 0)
			end
			frame:SetText(image)
			frame:Show()
			self.extraTooltip = frame;
		end
	end
end

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

function Bool:OnLoad(...)
	Widget.OnLoad(self, ...)
	self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
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

function Bool:OnClick(button)
	Widget.OnClick(self)
	if (button == 'RightButton') then
		return self:SetDefault()
	end
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
		_SetJustifyH = 'RIGHT';
		_Backdrop = CPAPI.Backdrops.Opaque;
		_OnLoad = function(self)
			self:SetBackdropColor(COLOR_NORMAL:GetRGBA());
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

function Number:OnLoad(...)
	Widget.OnLoad(self, ...)
	self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
end

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

function Number:GetControllerButtons()
	if self.metaData and self.metaData.vert then
		return 'PADDDOWN', 'PADDUP', 'PADDLEFT', 'PADDRIGHT';
	end
	return 'PADDLEFT', 'PADDRIGHT', 'PADDDOWN', 'PADDUP';
end

function Number:GetListeners()
	return self.OnDecrement, self.OnIncrement, nop, nop;
end

function Number:OnDecrement()
	self:Set(self:Get() - self:GetStep())
end

function Number:OnIncrement()
	self:Set(self:Get() + self:GetStep())
end

function Number:OnClick(button)
	if (button == 'RightButton') then
		Widget.OnClick(self)
		return self:SetDefault()
	end
	local listeners = { self:GetListeners() };
	local controls = { self:GetControllerButtons() };
	local decrement, increment = unpack(controls);
	if self:GetChecked() then
		for i, control in ipairs(controls) do
			local listener = listeners[i];
			self:ToggleClosure(control, true, listener, self)
		end
		self:SetTooltipHints({
			env:GetTooltipPromptForClick('LeftClick', APPLY);
			env:GetTooltipPrompt(decrement, env.L'Decrease');
			env:GetTooltipPrompt(increment, env.L'Increase');
		});
	else
		for _, control in ipairs(controls) do
			self:ToggleClosure(control, false)
		end
		self:SetTooltipHints(nil)
	end
end

function Number:OnValueChanged(value)
	value = tonumber(value)
	if value then
		self.Input:SetText(value)
	end
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
			self:EnableMouseWheel(false)
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
		_OnMouseWheel = function(self, delta)
			self:GetParent():Set(Clamp(self:GetValue() + delta, self:GetMinMaxValues()))
		end;
		_OnValueChanged = function(self, value, byInput)
			if byInput and self.cacheValue ~= value then
				self.cacheValue = value;
				if self.isDraggingThumb then
					self:GetParent():OnValueChanged(value)
				else
					self:GetParent():Set(value)
				end
			end
		end;
	};
})

function Range:OnLoad(...)
	Number.OnLoad(self, ...)
	self.Input:SetValueStep(self:GetStep())
	self.Input:SetMinMaxValues(self:GetMinMax())
	self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
end

function Range:EnableMouseWheel(enabled)
	self.Input:EnableMouseWheel(enabled)
end

function Range:GetMinMax()
	return self.controller:GetMinMax()
end

function Range:SetMinMax(min, max, value)
	self.Input:SetMinMaxValues(min, max)
	self.Input:SetValue(Clamp(value or self.Input:GetValue(), min, max))
end

function Range:OnValueChanged(value, valueExists)
	value = tonumber(value)
	local step = self.controller:GetStep()
	if ( valueExists ~= false ) then
		self.Input:SetValue(value)
		self.Input.Text:SetText(Round(value / step) * step)
	end
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
		_OnValueChanged = function(self, value, byInput)
			local widget = self:GetParent()
			if byInput and self.cacheValue ~= value and widget.controller:IsOption(value) then
				widget:Set(value)
				self.cacheValue = value;
			end
		end;
	};
})

function Delta:GetStep()
	return 2;
end

function Delta:GetMinMax()
	return -1, 1;
end

function Delta:OnValueChanged(value, valueExists)
	if ( valueExists ~= false ) then
		self.Input:SetValue(value)
		self.Input.Text:SetText(value == 1 and '+' or value == -1 and '-')
	end
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
			self:SetBackdropColor(0.15, 0.15, 0.15, 1);
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
			self:SetWidth(200)
		end;
		_OnEditFocusGained = function(self)
			self:SetWidth(300)
		end;
	};
})

function String:OnLoad(...)
	Widget.OnLoad(self, ...)
	self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
end

function String:OnClick(button)
	Widget.OnClick(self)
	if (button == 'RightButton') then
		Widget.OnClick(self)
		self.Input:ClearFocus()
		return self:SetDefault()
	end
	local input = self.Input;
	if input:HasFocus() then
		self.Input:ClearFocus()
	else
		self.Input:SetFocus()
	end
end

function String:OnValueChanged(value, valueExists)
	-- subvert default widget behavior for strings
	if not valueExists then
		self:SetAlpha(1)
		self:SetEnabled(true)
		self.Input:EnableMouse(true)
	end
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
			Clear = {
				_Type  = 'Button';
				_Size  = {16, 16};
				_Point = {'RIGHT', -8, 0};
				_OnClick = function(self)
					self:GetParent():GetParent():OnClick('RightButton')
				end;
				_OnEnter = function(self)
					self.Icon:SetAlpha(1)
				end;
				_OnLeave = function(self)
					self.Icon:SetAlpha(0.5)
				end;
				{
					Icon = {
						_Type  = 'Texture';
						_Setup = {'ARTWORK'};
						_Point = {'CENTER', 0, 0};
						_Size  = {16, 16};
						_Alpha = 0.5;
						_Atlas = 'common-search-clearbutton';
					};
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
	self.owner:SetDefaultClosures()
end

function Button:OnClick(button)
	if (button == 'RightButton') then
		Widget.OnClick(self)
		if ( self:Get() == NONE ) then
			self:SetDefault()
		else
			self:Set(NONE, true)
		end
	elseif self:GetChecked() then
		self:SetTooltipHints({
			YELLOW_FONT_COLOR:WrapTextInColorCode(BIND_KEY_TO_COMMAND:format(BLUE_FONT_COLOR:WrapTextInColorCode(self:GetText())));
		});
		self:UpdateTooltip()
		return self:ToggleClosure(nil, true, self.OnGamePadButtonDown, self)
	end
	self:ToggleClosure()
end

function Button:OnValueChanged(value)
	local display = GetBindingText(value, 'KEY_ABBR_')
	local isNotBound = display == NONE;
	self.widgetText = nil;
	if (isNotBound) then
		display = env.BindingInfo.NotBoundColor:format(NOT_BOUND)
	end
	self.Input.Clear:SetShown(not isNotBound)
	self.Input:SetText(display)

	self:SetTooltipHints(CHOOSE, isNotBound and DEFAULT or REMOVE)
end

---------------------------------------------------------------
-- Pseudokey
---------------------------------------------------------------
local Pseudokey = CreateWidget('Pseudokey', Widget, {
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
			Clear = {
				_Type  = 'Button';
				_Size  = {16, 16};
				_Point = {'RIGHT', -8, 0};
				_OnClick = function(self)
					self:GetParent():GetParent():OnClick('RightButton')
				end;
				_OnEnter = function(self)
					self.Icon:SetAlpha(1)
				end;
				_OnLeave = function(self)
					self.Icon:SetAlpha(0.5)
				end;
				{
					Icon = {
						_Type  = 'Texture';
						_Setup = {'ARTWORK'};
						_Point = {'CENTER', 0, 0};
						_Size  = {16, 16};
						_Alpha = 0.5;
						_Atlas = 'common-search-clearbutton';
					};
				};
			};
		};
	};
})

function Pseudokey:OnLoad(...)
	Widget.OnLoad(self, ...)
	self:EnableKeyboard(false)
	self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
end

function Pseudokey:OnHide()
	self:Uncheck()
	self:EnableKeyboard(false)
end

function Pseudokey:IsModifierAllowed()
	return self.controller:IsModifierAllowed()
end

function Pseudokey:OnKeyDown(button)
	if not self:IsModifierAllowed() then
		for i, modifier in ipairs(db.Gamepad.Modsims) do
			if button:match(modifier) then
				return
			end
		end
	end
	self:Set(button)
	Widget.OnClick(self)
	self:EnableKeyboard(false)
end

function Pseudokey:OnClick(button)
	if (button == 'RightButton') then
		Widget.OnClick(self)
		if ( self:Get() == NONE ) then
			self:SetDefault()
		else
			self:Set(NONE, true)
		end
	elseif self:GetChecked() then
		self:SetTooltipHints({
			YELLOW_FONT_COLOR:WrapTextInColorCode(BIND_KEY_TO_COMMAND:format(BLUE_FONT_COLOR:WrapTextInColorCode(self:GetText())));
		});
		return self:EnableKeyboard(true)
	end

	self:SetTooltipHints(CHOOSE, REMOVE)

	self:UpdateTooltip()
	self:EnableKeyboard(false)
end

function Pseudokey:OnValueChanged(value)
	local display = GetBindingText(value, 'KEY_ABBR_')
	local isNotBound = display == NONE;
	if (isNotBound) then
		display = env.BindingInfo.NotBoundColor:format(NOT_BOUND)
	end
	self:SetTooltipHints(CHOOSE, isNotBound and DEFAULT or REMOVE)
	self.Input.Clear:SetShown(not isNotBound)
	self.Input:SetText(display)
end

---------------------------------------------------------------
-- Select
---------------------------------------------------------------
local Select = CreateWidget('Select', Widget, {
	Popout = {
		_Type  = 'Frame';
		_Setup = 'CPSelectionPopoutWithButtonsAndLabelTemplate';
		_Point = {'RIGHT', -2, 0};
	};
})

function Select:OnLoad(...)
	Widget.OnLoad(self, ...)
	if not self.popoutLoaded then
		self.popoutLoaded = true;
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
				ConsolePort:SetCursorNode(self.SelectionPopoutButton, true)
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
	self:EnableMouseWheelSelect(false)
	self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
end

function Select:OnValueChanged(value)
	local opts = self.controller:GetOptions()
	local inOrder, selected = {};
	value = tonumber(value) or value;
	for opt, val in db.table.spairs(opts) do
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

function Select:OnLeftButton()
	self.Popout.DecrementButton:Click()
end

function Select:OnRightButton()
	self.Popout.IncrementButton:Click()
end

function Select:EnableMouseWheelSelect(enabled)
	self.Popout.SelectionPopoutButton:EnableMouseWheel(enabled)
	self:EnableMouseWheel(enabled)
end

function Select:OnMouseWheel(delta)
	self.Popout.SelectionPopoutButton:OnMouseWheel(delta)
end

function Select:OnClick(button)
	if (button == 'RightButton') then
		Widget.OnClick(self)
		return self:SetDefault()
	end
	self:EnableMouseWheelSelect(self:GetChecked())
	if self:GetChecked() then
		self:ToggleClosure('PADDLEFT', true, self.OnLeftButton, self)
		self:ToggleClosure('PADDRIGHT', true, self.OnRightButton, self)
		self:SetTooltipHints({
			env:GetTooltipPromptForClick('LeftClick', APPLY);
			env:GetTooltipPrompt('PADDLEFT', PREVIOUS);
			env:GetTooltipPrompt('PADDRIGHT', NEXT);
		});
	else
		self:ToggleClosure('PADDLEFT', false)
		self:ToggleClosure('PADDRIGHT', false)
		self:SetTooltipHints(nil)
	end
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

function Color:OnLoad(...)
	Widget.OnLoad(self, ...)
	self:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
end

function Color:OnClick(button)
	self:Uncheck()
	if (button == 'LeftButton') then
		local picker, opacity = ColorPickerFrame, OpacitySliderFrame or OpacityFrameSlider;

		local function GetOpacity()
			if picker.GetColorAlpha then
				return 1 - picker:GetColorAlpha()
			end
			return opacity:GetValue()
		end

		local function UnpackOldColor(old)
			if #old > 0 then
				return unpack(old)
			end
			return old.r, old.g, old.b, old.a;
		end

		local function OnColorChanged()
			if (picker.extraInfo == self) then
				local r, g, b = picker:GetColorRGB()
				local a = GetOpacity()
				self:Set(r, g, b, 1 - a)
				self:OnValueChanged(self:Get())
			end
		end

		local function OnColorCancel(oldColor)
			if (picker.extraInfo == self) then
				self:Set(UnpackOldColor(oldColor))
				self:OnValueChanged(self:Get())
			end
		end

		local r, g, b, a = self:GetRGBA(self:Get())
		self:SetupColorPickerAndShow(picker, {
			r = r, g = g, b = b, a = a,
			opacity     = a or 0,
			hasOpacity  = true,
			swatchFunc  = OnColorChanged,
			opacityFunc = OnColorChanged,
			cancelFunc  = OnColorCancel,
			extraInfo   = self,
		}, ColorSwatch)
	elseif (button == 'RightButton') then
		self:SetDefault()
	end
end

function Color:SetupColorPickerAndShow(picker, info, swatch)
	if picker.SetupColorPickerAndShow then
		return picker:SetupColorPickerAndShow(info)
	end
	picker:Hide()
	picker:SetColorRGB(info.r, info.g, info.b, info.a)
	picker.hasOpacity     = info.hasOpacity;
	picker.opacity        = 1 - info.opacity;
	picker.previousValues = {info.r, info.g, info.b, info.a};
	picker.func           = info.swatchFunc;
	picker.cancelFunc     = info.cancelFunc;
	picker.opacityFunc    = info.swatchFunc;
	picker.extraInfo      = self;
	picker:Show()
	swatch:SetColorTexture(info.r, info.g, info.b)
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

function Color:OnValueChanged(value, valueExists)
	if ( valueExists ~= false ) then
		self.Color:SetColorTexture(self:GetRGBA(value))
	end
end

ColorPickerFrame:HookScript('OnHide', function(self) self.owner = nil; end)