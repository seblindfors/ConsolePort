local env = CPAPI.GetEnv(...); env.Mixin = {};

---------------------------------------------------------------
local ScrollBoxHelper = {};
---------------------------------------------------------------
env.Mixin.ScrollBoxHelper = ScrollBoxHelper;

function ScrollBoxHelper:FindFirstOfType(type, scrollView)
	return (scrollView or self:GetScrollView()):FindElementDataByPredicate(function(elementData)
		return elementData:GetData().xml == type.xml;
	end)
end

function ScrollBoxHelper:FindFirstFrameOfType(type, scrollView)
	scrollView = scrollView or self:GetScrollView()
	local elementData = self:FindFirstOfType(type, scrollView)
	if not elementData then return end;
	return scrollView:FindFrame(elementData)
end

---------------------------------------------------------------
local Background = CreateFromMixins(BackdropTemplateMixin);
---------------------------------------------------------------
env.Mixin.Background = Background;

function Background:OnLoad()
	local r, g, b = CPAPI.GetWebColor(CPAPI.GetClassFile()):GetRGB()
	self:HookScript('OnSizeChanged', self.OnBackdropSizeChanged)
	self.Background = self:CreateTexture(nil, 'BACKGROUND', nil, 2)
	self.Rollover   = self:CreateTexture(nil, 'BACKGROUND', nil, 3)
	self.Rollover:SetAllPoints(self.Background)
	self.Rollover:SetTexture(CPAPI.GetAsset([[Textures\Frame\Backdrop_Vertex_White]]))
	CPAPI.SetGradient(self.Rollover, 'VERTICAL',
		{r = r*0.5, g = g*0.5, b = b*0.5, a = 1},
		{r = r*0.5, g = g*0.5, b = b*0.5, a = 0}
	)
	self:SetOriginTop(true)
	self:CreateBackground(2048, 2048, 2048, 2048, CPAPI.GetAsset([[Art\Background\%s]]):format(CPAPI.GetClassFile()))
end

function Background:GetBGOffset(point, size)
	return ((point / 2) / size)
end

function Background:GetBGFraction(point, size)
	return (point / size)
end

function Background:SetBackgroundDimensions(w, h, x, y)
	assert(self.Background, 'Frame is missing background.')
	self.Background.maxWidth = w;
	self.Background.maxHeight = h;
	self.Background.sizeX = x;
	self.Background.sizeY = y;
end

function Background:SetOriginTop(enabled)
	self.originTop = enabled;
end

function Background:OnAspectRatioChanged()
	local maxWidth, maxHeight = self.Background.maxWidth, self.Background.maxHeight;
	local sizeX, sizeY = self.Background.sizeX, self.Background.sizeY;
	local width, height = self:GetSize()

	local maxCoordX, maxCoordY, centerCoordX, centerCoordY =
		self:GetBGFraction(maxWidth, sizeX),
		self:GetBGFraction(maxHeight, sizeY),
		self:GetBGOffset(maxWidth, sizeX),
		self:GetBGOffset(maxHeight, sizeY);

	local top, bottom, left, right = 0, 1, 0, 1;
	if width > height then
		local newHeight = self:GetBGFraction(height, width) * maxWidth;
		if self.originTop then
			top, left, right = 0, 0, maxCoordX;
			bottom = self:GetBGFraction(newHeight, sizeY)
		else
			local offset = self:GetBGOffset(newHeight, sizeY)
			left, right = 0, maxCoordX;
			top = centerCoordY - offset;
			bottom = centerCoordY + offset;
		end
	end
	if height > width or (top < 0 or bottom < 0) then
		local newWidth = self:GetBGFraction(width, height) * maxHeight;
		local offset = self:GetBGOffset(newWidth, sizeX)
		top, bottom = 0, maxCoordY;
		left = centerCoordX - offset;
		right = centerCoordX + offset;
	end
	self.Background:SetTexCoord(left, right, top, bottom)
end

function Background:SetBackgroundInsets(tlX, tlY, brX, brY)
	self.Background:ClearAllPoints()
	if tlX then
		tlX = tonumber(tlX) or 8;
		tlY = tonumber(tlY) or -tlX;
		brX = tonumber(brX) or -tlX;
		brY = tonumber(brY) or  tlX;
		self.Background:SetPoint('TOPLEFT', tlX, tlY)
		self.Background:SetPoint('BOTTOMRIGHT', brX, brY)
	else
		self.Background:SetAllPoints()
	end
end

function Background:CreateBackground(w, h, x, y, texture)
	self.Background:SetTexture(texture)
	self:SetBackgroundDimensions(w, h, x, y)
	self:OnAspectRatioChanged()
	self:HookScript('OnShow', self.OnAspectRatioChanged)
	self:HookScript('OnSizeChanged', self.OnAspectRatioChanged)
end

function Background:SetBackgroundVertexColor(...)
	self.Background:SetVertexColor(...)
end

function Background:SetBackgroundAlpha(alpha)
	self.Background:SetAlpha(alpha)
	self.Rollover:SetAlpha(alpha)
end

function Background:AddBackgroundMaskTexture(mask)
	self.Background:AddMaskTexture(mask)
	self.Rollover:AddMaskTexture(mask)
end

---------------------------------------------------------------
local UpdateStateTimer = {};
---------------------------------------------------------------
env.Mixin.UpdateStateTimer = UpdateStateTimer;

function UpdateStateTimer:SetUpdateStateTimer(timer)
	self:CancelUpdateStateTimer()
	self.updateStateTimer = C_Timer.NewTimer(self.updateStateDuration, timer)
end

function UpdateStateTimer:CancelUpdateStateTimer()
	if self.updateStateTimer then
		self.updateStateTimer:Cancel()
		self.updateStateTimer = nil;
	end
end

function UpdateStateTimer:SetUpdateStateDuration(duration)
    self.updateStateDuration = duration or 0;
end

---------------------------------------------------------------
local BindingCatcher = CreateFromMixins(CPPopupBindingCatchButtonMixin)
---------------------------------------------------------------
env.Mixin.BindingCatcher = BindingCatcher;

-- A claimed tap chord composes the layer and keeps the catcher open.
-- Unclaimed, the button binds like any other.
-- @return sequence : whether the press was taken as composition
function BindingCatcher:TryComposeLayer(button)
	local modifier = env.db.Gamepad.Index.Modifier.Owner[button];
	if ( not modifier or not env.db.Layers:UsesTapGestures() ) then
		return false;
	end
	self.sequence = self.sequence or {};
	self.sequence[#self.sequence + 1] = modifier;
	self:ResetCancelTimer()
	return true;
end

BindingCatcher.PendingText = 'Waiting for input...';

-- Icon at the glyph's rendered size, so the line keeps its height.
function BindingCatcher:GetPendingLine()
	return ('%s %s'):format(
		env.db.Hotkeys.Format[64]:format(CPAPI.GetAsset([[Textures\Button\EmptyIcon]])),
		env.L(self.PendingText)
	);
end

BindingCatcher.Reasons = {
	doubled   = 'Tapping the same modifier twice needs the Doubled Bar option enabled.';
	exclusive = 'A doubled modifier is a bar of its own and cannot be combined with others.';
	unknown   = 'Those modifiers do not form a layer that can be bound.';
};

function BindingCatcher:GetKeyChord(button)
	if not self.sequence then
		return CPAPI.CreateKeyChord(button);
	end
	local layer, reason = env.db.Layers:ComposeLayer(self.sequence);
	if not layer then
		return nil, reason;
	end
	return layer..button;
end

function BindingCatcher:ResetComposition()
	self.sequence, self.baseText, self.shownFeedback, self.feedbackKey = nil, nil, nil, nil;
end

function BindingCatcher:OnShow()
	self:ResetComposition()
	CPPopupBindingCatchButtonMixin.OnShow(self)
end

function BindingCatcher:OnHide()
	self:ResetComposition()
	CPPopupBindingCatchButtonMixin.OnHide(self)
end

-- Rebuilt only when the state moves; this runs every frame.
function BindingCatcher:GetModifierFeedback()
	local chord = env.db.Layers:GetActiveChord();
	local key   = ('%s#%d'):format(chord, self.sequence and #self.sequence or 0);
	if ( key ~= self.feedbackKey ) then
		self.feedbackKey  = key;
		self.feedbackText = env:GetModifierGlyphs(chord, self.sequence);
	end
	return self.feedbackText;
end

-- Reserves the last line, so the dialog is laid out once.
function BindingCatcher:GetPromptText()
	return ('%s\n%s'):format(self.promptText, self:GetPendingLine())
end

-- The modifiers that will be part of the binding, held and tapped.
function BindingCatcher:OnUpdate(elapsed)
	CPPopupBindingCatchButtonMixin.OnUpdate(self, elapsed)
	local text = self:GetDialogText();
	if not text then return end;

	self.baseText = self.baseText or text:GetText();
	local feedback = self:GetModifierFeedback() or self:GetPendingLine();
	if ( feedback ~= self.shownFeedback ) then
		self.shownFeedback = feedback;
		text:SetText((self.baseText:gsub('[^\n]*$', feedback, 1)))
	end
end

function BindingCatcher:OnBindingCaught(button, data)
	if not CPAPI.IsButtonValidForBinding(button) then return end;
	if self:TryComposeLayer(button) then return end;

	local bindingID = data.bindingID;
	local context   = CPAPI.GetBindingContextForAction(bindingID)
	local keyChord, reason = self:GetKeyChord(button)
	if not keyChord then
		CPAPI.Log(BindingCatcher.Reasons[reason] or BindingCatcher.Reasons.unknown)
		return true;
	end

	-- A claimed chord answers with the gesture holding it, not with the
	-- binding it shadows, which would read as an ordinary conflict.
	local claim = env.db.Layers:GetChordClaim(keyChord);
	if claim then
		CPAPI.Log('That button is reserved for %s.', claim)
		return true;
	end

	local curAction = CPAPI.GetBindingAction(keyChord, nil, context)

	if ( curAction ~= '' and curAction ~= bindingID ) then
		CPAPI.Next(env.TriggerEvent, env, 'OnBindingConflict', keyChord, bindingID, curAction)
		return true; -- return true anyway to close the catcher.
	end

	return env:SetBinding(keyChord, bindingID)
end

function BindingCatcher:ClearBindingsForID(bindingID)
	env:ClearBindingsForID(bindingID, true)
end