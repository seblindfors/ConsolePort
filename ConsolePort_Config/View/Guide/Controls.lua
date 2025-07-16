local env, db, _, L = CPAPI.GetEnv(...);
local Guide = env:GetContextPanel();

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local CONTENT_WIDTH = 500;
local Gamepad = db.Gamepad;

local function CreateHeader(parent)
	local header = CreateFrame('Frame', nil, parent, 'CPPopupHeaderTemplate')
	header.Text:SetTextColor(NORMAL_FONT_COLOR:GetRGBA())
	header:SetWidth(CONTENT_WIDTH)
	return header;
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

function SchemeSelect:SetData(data)
	Mixin(self, data)
	self.init = self.init or nop;
	self.Text:SetText(data.text)
	self:OnShow()
	self:Update()
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
		type = SchemeSelect;
		{ -- 1.1 Left handed modifiers
			text      = L'Left';
			tooltip   = L'Use left handed modifiers to keep movement and binding sets on the left side of the controller.';
			subscribe = GetModifierCVars();
			predicate = GenerateClosure(HasModifiers, LeftHandModifiers);
			execute   = GenerateClosure(SetModifiers, LeftHandModifiers);
			recommend = true;
			init = function(self)
				Gamepad.SetIconToTexture(AddLeftIcon(self),  'PADLSHOULDER');
				Gamepad.SetIconToTexture(AddRightIcon(self), 'PADLTRIGGER');
			end;
		};
		{ -- 1.2 Trigger modifiers
			text      = L'Triggers';
			tooltip   = L'Use triggers as modifiers.';
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
			text      = L'Custom';
			tooltip   = L'Use custom modifiers to set your own modifier combinations.';
			subscribe = GetModifierCVars();
			predicate = function()
				return  not HasModifiers(LeftHandModifiers)
					and not HasModifiers(TriggerModifiers);
			end;
			execute   = function()
				-- open side bar
			end;
			init = function(self)
				Gamepad.SetIconToTexture(AddLeftIcon(self),  'PADLTRIGGER');
				Gamepad.SetIconToTexture(AddRightIcon(self), 'PADRTRIGGER');

				local LB = self:AcquireTexture();
				LB:SetPoint('CENTER', 0, 20)
				LB:SetSize(40, 40)
				LB:SetDrawLayer('ARTWORK', -1)
				Gamepad.SetIconToTexture(LB, 'PADLSHOULDER');

				local masterRace = self:AcquireTexture();
				masterRace:SetPoint('CENTER', 0, -4)
				masterRace:SetSize(60, 30)
				masterRace:SetDrawLayer('ARTWORK', 2)
				masterRace:SetDesaturated(true)
				masterRace:SetTexture([[Interface\AddOns\ConsolePort_Config\Assets\master]])
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
		text = L'Mouse Buttons';
		type = SchemeSelect;
		{ -- 2.1 Inverted mouse setup
			text      = L'Inverted';
			tooltip   = L'Use inverted mouse button bindings.';
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
			tooltip   = L'Use regular mouse button bindings.';
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
			text      = L'Custom';
			tooltip   = L'Use custom mouse button bindings.';
			subscribe = GetMouseButtonCVars();
			predicate = function()
				return  not HasMouseButtons(RegularMouseSetup)
					and not HasMouseButtons(InvertedMouseSetup);
			end;
			execute   = function()
				-- open side bar
			end;
			init = function(self)
				local M1 = AddLeftIcon(self)
				M1:SetTexture([[Interface\AddOns\ConsolePort_Bar\Assets\Textures\Icons\LMB]])

				local M2 = AddRightIcon(self)
				M2:SetTexture([[Interface\AddOns\ConsolePort_Bar\Assets\Textures\Icons\RMB]])

				local masterRace = self:AcquireTexture();
				masterRace:SetPoint('CENTER', 0, -4)
				masterRace:SetSize(60, 30)
				masterRace:SetDrawLayer('ARTWORK', 2)
				masterRace:SetDesaturated(true)
				masterRace:SetTexture([[Interface\AddOns\ConsolePort_Config\Assets\master]])
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
	self.buttonPool = CreateFramePool('CheckButton', scrollChild, 'CPControlSchemeButton')
	self.txPool = CreateTexturePool(scrollChild, 'ARTWORK')

	local function CalculateButtonOffset(col, numColumns)
		return (col - 1) * (CONTENT_WIDTH / numColumns)
			- (CONTENT_WIDTH / 2)
			+ (CONTENT_WIDTH / (2 * numColumns));
	end

	local topOffset = -20;
	for row, dataRows in ipairs(SchemeContent) do
		local header = CreateHeader(scrollChild)
		header.Text:SetText(dataRows.text)
		header:SetPoint('TOP', 0, topOffset)

		local numColumns = #dataRows;
		for col, data in ipairs(dataRows) do
			local button, newObj = self.buttonPool:Acquire();
			if newObj then
				CPAPI.Specialize(button, dataRows.type)
				button.txPool = self.txPool;
			end
			button:SetData(data);
			button:SetPoint('TOP', header, 'BOTTOM', CalculateButtonOffset(col, numColumns), -10)
			button:Show()
			-- setup the buttons
		end
		topOffset = topOffset - 170;
	end
	RunNextFrame(function()
		scrollChild:SetMinimumWidth(self.Browser:GetWidth())
		scrollChild:Layout()
	end)

	SchemeContent = nil;
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