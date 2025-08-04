local env, db, _, L = CPAPI.GetEnv(...);
local Guide = env:GetContextPanel();

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local WHITE_FONT_COLOR = WHITE_FONT_COLOR or CreateColor(1, 1, 1)
local ALT_MATCH        = 'ALT%-';
local ANI_DURATION     = 0.15;
local LINE_ALPHA       = 0.25;
local ButtonLayout = {
	LEFT = {
		textPoint   = {'LEFT', 'LEFT', 40, 0};
		notePoint   = {'BOTTOM', 'TOPLEFT', 0, 1};
		buttonPoint = {'LEFT', 0, 0};
		startAnchor = {'BOTTOMRIGHT', 0, 0};
		endAnchor   = {'BOTTOMLEFT', -160, 0};
		lineCoords  = db.SplineLine.lineBaseCoord.LEFT;
	};
	RIGHT = {
		textPoint   = {'RIGHT', 'RIGHT', -40, 0};
		notePoint   = {'BOTTOM', 'TOPRIGHT', 0, 1};
		buttonPoint = {'RIGHT', 0, 0};
		startAnchor = {'BOTTOMLEFT', 0, 0};
		endAnchor   = {'BOTTOMRIGHT', 160, 0};
		lineCoords  = db.SplineLine.lineBaseCoord.RIGHT;
	};
};

local function SetCvarTooltip(tooltip, cvarData, showNote)
	-- Anchor/show separately
	tooltip:SetText(cvarData.name)
	tooltip:AddLine(cvarData.desc, 1, 1, 1, 1)
	if showNote and cvarData.note then
		tooltip:AddLine('\n'..NOTE_COLON)
		tooltip:AddLine(cvarData.note, 1, 1, 1, 1)
	end
end

---------------------------------------------------------------
local Binding = CreateFromMixins(env.BindingInfoMixin);
---------------------------------------------------------------
function Binding:GetChordBinding(mod)
	return GetBindingAction(mod..self.baseBinding)
end

function Binding:GetBinding()
	return GetBindingAction(self:GetKeyChord());
end

function Binding:SetBinding(bindingID)
	return env:SetBinding(self:GetKeyChord(), bindingID)
end

function Binding:GetModifier()
	return self.mod or '';
end

function Binding:GetKeyChord()
	return self:GetModifier() .. self:GetBaseBinding();
end

function Binding:GetBaseBinding()
	return self.baseBinding;
end

function Binding:SetBaseBinding(binding)
	self.baseBinding = binding;
end

function Binding:SetModifier(modifier)
	self.mod = modifier or '';
end

function Binding:GetModifierSlug(modifier)
	return db.Gamepad.Index.Modifier.Active[modifier or self.mod];
end

function Binding:GetButtonSequence()
	local slug = self:GetModifierSlug()
	local combo = { self:GetBaseBinding() };
	if type(slug) == 'string' then
		tinsert(combo, 1, slug)
	end
	return table.concat(combo, '-'), self:GetModifier()
end

function Binding:SetReserved(reservedData)
	self.reservedData = reservedData;
end

function Binding:IsClickReserved(override)
	local reserved = override or self.reservedData;
	return reserved and reserved.cvar:match('Cursor');
end

---------------------------------------------------------------
local Button = CreateFromMixins(Binding)
---------------------------------------------------------------
function Button:OnLoad()
	self:SetFontString(self.Label)
end

function Button:SetupRegions(anchor)
	local set = ButtonLayout[anchor];

	local point, relativePoint, xOffset, yOffset = unpack(set.textPoint);
	self.Label:SetJustifyH(anchor)
	self.Label:ClearAllPoints()
	self.Label:SetPoint(point, self, relativePoint, xOffset, yOffset)

	point, xOffset, yOffset = unpack(set.buttonPoint)
	self.Icon:ClearAllPoints()
	self.Icon:SetPoint(point, xOffset, yOffset)

	self.Bottom:SetStartPoint(unpack(set.startAnchor))
	self.Bottom:SetEndPoint(unpack(set.endAnchor))
	self.Bottom:SetTexCoord(unpack(set.lineCoords))

	self.lineCoords = set.lineCoords;
end

function Button:SetBaseBinding(binding)
	local data = env:GetHotkeyData(binding, '', 64, 32)
	Binding.SetBaseBinding(self, binding)
	CPAPI.SetTextureOrAtlas(self.Icon, data.button)
end

function Button:UpdateState(currentModifier)
	self:SetModifier(currentModifier)

	local reserved = env:GetCombinationBlockerInfo(self:GetKeyChord())
		          or env:GetEmulationForCursor(self:GetBaseBinding())
	self:SetReserved(reserved)

	local isClickOverride = (self:IsClickReserved(reserved) and currentModifier ~= '')
	if not isClickOverride and reserved then
		return self:SetText(WHITE_FONT_COLOR:WrapTextInColorCode(L(reserved.name)))
	end

	self:SetText(self:GetBindingInfo(self:GetBinding()))
end

---------------------------------------------------------------
local Chord, ChordHitRects = CreateFromMixins(Binding, CPAPI.EventMixin)
---------------------------------------------------------------

function Chord:OnLoad()
	self:SetMovable(true)
	self:RegisterForDrag('LeftButton')
	self:SetScript('OnDragStop', self.OnDragStop)
end

function Chord:OnShow()
	env:RegisterCallback('Overview.OnDragBinding', self.OnDragBinding, self)
	env:RegisterCallback('OnBindingChanged', self.OnBindingChanged, self)
	db:RegisterCallback('OnBindingIconChanged', self.OnIconChanged, self)
end

function Chord:OnHide()
	env:UnregisterCallback('Overview.OnDragBinding', self)
	env:UnregisterCallback('OnBindingChanged', self)
	db:UnregisterCallback('OnBindingIconChanged', self)
	self:CommitHitRect()
end

function Chord:OnEnter()
	self.isMouseOver = true;
	env:TriggerEvent('Overview.HighlightButtons', self:GetButtonSequence())

	GameTooltip_SetDefaultAnchor(GameTooltip, self)

	local name, _, actionID, bindingID = self:GetBindingInfo(self:GetBinding(), true)
	local reserved = env:GetCombinationBlockerInfo(self:GetKeyChord())
	local lineColor = (function(font)
		local r, g, b = font:GetTextColor()
		return { r, g, b, 1, 1, 1 };
	end)(GameFontGreen)

	local function AddDoubleLine(name, value)
		GameTooltip:AddDoubleLine(name, value, unpack(lineColor))
	end

	if reserved then
		SetCvarTooltip(GameTooltip, reserved, true)
	elseif ( actionID and GameTooltip:SetAction(actionID) ) then
		local binding, header = ('\n'):split(name)
		GameTooltip:AddLine('\n')
		AddDoubleLine(NAME, binding:trim())
		if header then
			AddDoubleLine(CATEGORY, header:gsub('75', 'ff'):trim())
		end
	else
		-- SetAction failed, so re-anchoring is required.
		if actionID then
			GameTooltip_SetDefaultAnchor(GameTooltip, self)
		end
		GameTooltip:SetText(name)
	end

	local desc, image = db.Bindings:GetDescriptionForBinding(bindingID, true, 50)
	if desc then
		GameTooltip:AddLine('\n'..desc, 1, 1, 1)
	end
	if image then
		GameTooltip:AddLine('\n'..image)
	end

	if actionID then
		local barID, buttonID = db.Actionbar:GetFormattedIDs(actionID, true)
		AddDoubleLine(BINDING_NAME_ACTIONBUTTON1:gsub('%d', ''):trim(), ('%s | %s'):format(buttonID, barID))
	end

	local slug = not reserved and db.Hotkeys:GetButtonSlugForChord(self:GetKeyChord(), false, true)
	if slug then
		GameTooltip:AddLine('\n')
		AddDoubleLine(KEY_BINDING, slug)
	end
	GameTooltip:Show()
end

function Chord:OnLeave()
	self.isMouseOver = false;
	env:TriggerEvent('Overview.HighlightButtons', nil)
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function Chord:OnClick()
	if self.cvar then return end;

	local readOnlyText = db.Bindings:IsReadOnlyBinding(self.bindingID)
	if readOnlyText then
		return UIErrorsFrame:AddMessage(readOnlyText:trim(), 1.0, 0.1, 0.1, 1.0);
	end

	if GetCursorInfo() and self.actionID then
		return PlaceAction(self.actionID);
	end

	env:TriggerEvent('Overview.OnChordClick', self)
end

function Chord:OnReceiveDrag()
	if not self.actionID or not GetCursorInfo() then
		return;
	end
	PlaceAction(self.actionID)
	self:UpdateCurrentInfo()
end

---------------------------------------------------------------
-- Drag and drop types
---------------------------------------------------------------
function Chord:OnDragBinding(isDragging, action, data)
	if action == self then return end;
	if isDragging then
		if self.cvar then return end;
		self:EnableDragTarget(action, data)
	else
		local isMouseOver, targetChord, targetData = self:CommitDragTarget()
		if not isMouseOver then return end;
		local targetBinding = targetChord:GetBinding()
		targetChord:SetBinding(self:GetBinding())
		targetChord:UpdateCurrentInfo()
		self:SetBinding(targetBinding)
		self:UpdateCurrentInfo()
	end
end

---------------------------------------------------------------
-- Drag and drop tracking
---------------------------------------------------------------
local function ChordUpdateMouseOver(chord, hitRect)
	local isMouseOver = hitRect:IsMouseOver();
	local isUpdated = chord.isDragOverRect == isMouseOver;
	chord.isDragOverRect = isMouseOver;
	chord:UpdateDragAction(isMouseOver, isUpdated)
end

function Chord:OnDragStart()
	if self.cvar then return end; -- Do not allow dragging if this is a reserved action.
	if self.actionID and IsShiftKeyDown() then
		self.nullifyDrag = true;
		return PickupAction(self.actionID);
	end

	local data = self:GetData()
	data.origin = self:AcquireOrigin()

	self:StartMoving()
	self:SetFrameLevel(self:GetFrameLevel() + 10)
	env:TriggerEvent('Overview.OnDragBinding', true, self, data)
end

function Chord:OnDragStop()
	if self.nullifyDrag then
		self.nullifyDrag = nil;
		return;
	end

	local data = self:GetData()
	data.origin = self:ReleaseOrigin()

	self:StopMovingOrSizing()
	self:SetFrameLevel(self:GetFrameLevel() - 10)
	env:TriggerEvent('Overview.OnDragBinding', false, self, data)
end

function Chord:UpdateDragAction(isMouseOver, isUpdated)
	if not isUpdated then return end;
	self:ClearAllPoints()
	self:SetPoint(unpack(isMouseOver and self:GetTargetOrigin() or self:AcquireOrigin()))
end

function Chord:EnableDragTarget(action, data)
	self.targetAction, self.targetData = action, data;
	self:AcquireOrigin()
	self:AcquireHitRect()
end

function Chord:CommitDragTarget()
	local isMouseOver = self:CommitHitRect()
	local targetAction, targetData = self.targetAction, self.targetData;
	self:ReleaseOrigin()
	self.targetAction, self.targetData = nil, nil;
	return isMouseOver, targetAction, targetData;
end

function Chord:GetTargetOrigin()
	return self.targetData and self.targetData.origin or nil;
end

function Chord:AcquireHitRect()
	if self.hitRect then
		return self.hitRect;
	end
	if not ChordHitRects then
		ChordHitRects = CreateFramePool('Frame', nil, nil, function(_, hitRect)
			hitRect:Hide()
			hitRect:ClearAllPoints()
			if hitRect.ticker then
				hitRect.ticker:Cancel()
				hitRect.ticker = nil;
			end
		end)
	end
	local hitRect, newObj = ChordHitRects:Acquire()
	if newObj then
		hitRect:SetSize(self:GetSize())
		hitRect:SetFrameLevel(self:GetFrameLevel() + 1)
	end
	hitRect:SetParent(self)
	hitRect:SetPoint(self:GetPoint())
	hitRect:Show()
	hitRect.ticker = C_Timer.NewTicker(0.1, GenerateClosure(ChordUpdateMouseOver, self, hitRect))
	self.hitRect = hitRect;
	return hitRect;
end

function Chord:CommitHitRect()
	if not self.hitRect then return end;
	local isDragOverRect = self.isDragOverRect;
	ChordHitRects:Release(self.hitRect)
	self.hitRect, self.isDragOverRect = nil, nil;
	return isDragOverRect;
end

function Chord:AcquireOrigin()
	if not self.origin then
		self.origin = { self:GetPoint() };
	end
	return self.origin;
end

function Chord:ReleaseOrigin()
	local origin = self.origin;
	if origin then
		self:ClearAllPoints()
		self:SetPoint(unpack(origin))
		self.origin = nil;
	end
	return origin;
end

---------------------------------------------------------------
-- Chord information
---------------------------------------------------------------
function Chord:DetermineIcon(texture, actionID, bindingID)
	return texture
		or actionID and CPAPI.GetAsset([[Textures\Button\EmptyIcon]])
		or bindingID and [[Interface\MacroFrame\MacroFrame-Icon]]
		or CPAPI.GetAsset([[Textures\Button\NotBound]])
end

function Chord:UpdateInfo(name, texture, actionID, bindingID)
	self.name = name or '';
	self.cvar = nil;

	self.actionID  = actionID;
	self.bindingID = bindingID;

	if ( not texture and not actionID and not bindingID ) then
		local blocker = env:GetBlockedCombination(self:GetKeyChord())
		if blocker then
			texture = db.Bindings.CustomIcons[blocker];
			self.cvar = db.Gamepad.Index.Modifier.Cvars[blocker];
		end
	end

	CPAPI.ToggleEvent(self, 'UPDATE_BONUS_ACTIONBAR', actionID)
	CPAPI.ToggleEvent(self, 'ACTIONBAR_SLOT_CHANGED', actionID)

	local c = (texture or (not actionID and bindingID)) and 1 or 0.5;
	local a = (texture or actionID or bindingID) and 1 or 0.25;
	self.Border:SetAlpha(a * 0.5)
	self.Icon:SetVertexColor(c, c, c, a);
	self.Icon:SetTexture(self:DetermineIcon(texture, actionID, bindingID));
end

function Chord:SetChord(modifierID, buttonID, isAlt)
	if isAlt then
		self.altModifier = modifierID;
		return;
	end
	self.baseModifier = modifierID;
	self:SetBaseBinding(buttonID)
	self:UpdateModifier(modifierID)
end

function Chord:UpdateModifier(modifier)
	self:SetModifier(modifier)
	self:UpdateCurrentInfo()
end

function Chord:UpdateCurrentInfo()
	self:UpdateInfo(self:GetBindingInfo(self:GetBinding()))
end

function Chord:SetCurrentModifier(modifier, isAlt)
	local modifierID = isAlt and self.altModifier or self.baseModifier;
	self.isActive = modifier == modifierID;
	if ( self.mod ~= modifierID ) then
		self:UpdateModifier(modifierID)
		if self.isMouseOver then
			self:OnEnter()
		end
	end
	self.Border:SetShown(self.isActive);
end

function Chord:IsActive()
	return self.isActive;
end

function Chord:GetData()
	local name, texture, actionID, bindingID = self:GetBindingInfo(self:GetBinding())
	return {
		name      = name;
		texture   = self:DetermineIcon(texture, actionID, bindingID);
		actionID  = actionID;
		bindingID = bindingID;
		cvar      = self.cvar;
		chord     = self:GetKeyChord();
		modifier  = self:GetModifier();
		button    = self:GetBaseBinding();
	};
end

function Chord:RefreshActionSlot()
	local parent = self:GetParent()
	self:UpdateCurrentInfo()
	parent:UpdateState(parent:GetModifier())
end

function Chord:UPDATE_BONUS_ACTIONBAR()
	self:RefreshActionSlot()
end

function Chord:ACTIONBAR_SLOT_CHANGED(actionID)
	if actionID == self.actionID then
		self:RefreshActionSlot()
	end
end

function Chord:OnIconChanged(bindingID)
	if bindingID == self.bindingID then
		self:UpdateCurrentInfo()
	end
end

function Chord:OnBindingChanged(keyChord)
	if keyChord == self:GetKeyChord() then
		self:UpdateCurrentInfo()
		if self.isMouseOver then
			self:OnEnter()
		end
	end
end

---------------------------------------------------------------
local ComboButton = CreateFromMixins(Button, db.SplineLine, ColorMixin)
---------------------------------------------------------------

function ComboButton:OnLoad()
	Button.OnLoad(self)
	db.SplineLine.OnLoad(self)
	self:SetLineOrigin('CENTER', self.Container)

	-- Actions based on the active modifiers.
	self.actions = CreateFramePool('Button', self, 'CPOverviewActionDisplay')
	self.lineState = {};

	-- Proxy object to update both lines at once.
	self.Bottom = CPAPI.Proxy({
		FadeIn = function(_, ...)
			db.Alpha.FadeIn(self.Bottom1, ...)
			db.Alpha.FadeIn(self.Bottom2, ...)
		end;
	}, function(_, key)
		return function(_, ...)
			self.Bottom2[key](self.Bottom2, ...)
			return self.Bottom1[key](self.Bottom1, ...)
		end
	end)
end

function ComboButton:AcquireChord(anchor)
	local button, newObj = self.actions:Acquire()
	if newObj then
		CPAPI.Specialize(button, Chord)
	end
	local set = ButtonLayout[anchor];
	local point, relativePoint, xOffset, yOffset = unpack(set.notePoint);
	button.BorderHilite:SetVertexColor(self:GetRGB())
	button.Note:SetJustifyH(anchor)
	button.Note:ClearAllPoints()
	button.Note:SetPoint(point, button, relativePoint, xOffset, yOffset)
	return button;
end

function ComboButton:ClearActions()
	self.actions:ReleaseAll()
end

function ComboButton:EnumerateActions()
	return self.actions:EnumerateActive()
end

function ComboButton:GetActiveChord()
	for chord in self:EnumerateActions() do
		if chord:IsActive() then
			return chord;
		end
	end
	return nil;
end

function ComboButton:ReleaseAll()
	self:ClearActions()
	self:ClearLinePoints()
end

function ComboButton:OnEnter()
	self.isMouseOver = true;
	local active = self:GetActiveChord()
	if active then
		active:OnEnter()
	end
end

function ComboButton:OnLeave()
	self.isMouseOver = false;
	local active = self:GetActiveChord()
	if active then
		active:OnLeave()
	end
end

function ComboButton:OnHide()
	self:ReleaseAll()
end

function ComboButton:OnClick(...)
	local active = self:GetActiveChord()
	if active then
		return active:OnClick(...)
	end
end

function ComboButton:SetLineAlpha(alpha, reverse, duration) duration = duration or ANI_DURATION;
	local delta    = alpha or LINE_ALPHA;
	local isOpaque = alpha and alpha >= 1.0;
	local bitAlpha = isOpaque and 1.0 or nil;
	local cutoff   = self:GetLineSegments();
	if not self:IsLineUpdateRequired(delta, isOpaque, bitAlpha, cutoff) then
		return; -- No need to update the line.
	end
	self:UpdateLineState(delta, isOpaque, bitAlpha, cutoff, duration)
	self:PlayLineEffect(duration, function(bit, i)
		bit:SetAlpha(Saturate(bitAlpha or delta * bit.finalAlpha))
		if i == cutoff then
			self.Bottom:FadeIn(duration, self.Bottom:GetAlpha(), Saturate(delta * 1.0))
		end
	end, reverse)
end

function ComboButton:IsLineUpdateRequired(d, o, b, c, t)
	local s = self.lineState;
	if s[1] ~= d or s[2] ~= o or s[3] ~= b or s[4] ~= c or s[5] ~= t then
		return true;
	end
	return false;
end

function ComboButton:UpdateLineState(d, o, b, c, t)
	local s = self.lineState;
	s[1] = d; -- delta
	s[2] = o; -- isOpaque
	s[3] = b; -- bitAlpha
	s[4] = c; -- cutoff
	s[5] = t; -- duration
end

function ComboButton:SetData(index, numButtons, data, isLeft, activeMods)
	self.index = index;
	self.data  = data;
	self:ReleaseAll()
	self:RenderChords(data, isLeft, activeMods)
	self:RenderPositionAndLines(numButtons, isLeft)
	self:SetBaseBinding(data.button)
end

function ComboButton:SetColor(r, g, b)
	self:SetRGB(r, g, b)
	self.Bottom:SetVertexColor(r, g, b)
	self.h, self.s, self.v = CPAPI.RGB2HSV(r, g, b)
end

function ComboButton:GetHSV()
	return self.h, self.s, self.v;
end

function ComboButton:RenderChords(data, isLeft, activeMods)
	local baseButton, index = data.button, 1;
	local anchor    = isLeft and 'RIGHT' or 'LEFT';
	local relAnchor = isLeft and 'LEFT' or 'RIGHT';
	local delta     = isLeft and -1 or 1;

	local active = {};
	for mod in db.table.mpairs(activeMods) do
		local isAlt  = mod:match(ALT_MATCH);
		local base   = mod:gsub(ALT_MATCH, '');
		local chord = active[base] or self:AcquireChord(relAnchor)
		chord:SetChord(mod, baseButton, isAlt)
		if not isAlt then
			chord:SetPoint(anchor, self, relAnchor, ((index - 1) * 40 * delta) + (delta * 12), 0)
			chord:Show()
			active[mod] = chord;
			index = index + 1;
		end
	end
end

function ComboButton:RenderPositionAndLines(numButtons, isLeft)
    -- Calculate position and constraints
    local w, h = self.Container:GetSize()
    local entryHeight = 54; -- Height required for each entry
    local totalHeight = entryHeight * numButtons;
    local startY = -totalHeight / 2 + entryHeight / 2;

    local y = PixelUtil.ConvertPixelsToUIForRegion(startY + (self.index - 1) * entryHeight, self)
    local x = PixelUtil.ConvertPixelsToUIForRegion(isLeft and -w * 0.36 or w * 0.36, self)

	w, h = self:GetSize()
	self:SetPoint(isLeft and 'LEFT' or 'RIGHT', self.Container, 'CENTER', x, y)

	-- Calculate the connecting points for the spline line.
	local lastX = x + (isLeft and w or -w) + (isLeft and -3 or 3);
	local lastY = y - (h / 2);

	-- Add points, join the spline points with the edge of the button.
	for _, point in ipairs(self.data.points) do
		self:AddLinePoint(unpack(point))
	end
	self:AddLinePoint(lastX, lastY)

	self:SetLineDrawLayer('ARTWORK', self.data.level)
	self:SetupRegions(isLeft and 'LEFT' or 'RIGHT')
	self:UpdateLines()
end

function ComboButton:UpdateLines()
	local h, s, v = self:GetHSV()
	local alpha = LINE_ALPHA;
	self.Bottom:SetAlpha(alpha)
	local e = (h + 180) % 360;
	self:DrawLine(function(bit, section, i, numSegments)
		local hue = Lerp(e, h, section);
		 -- Hide the last bit so that alpha merges correctly with the bottom lines.
		bit.finalAlpha = i == numSegments and 0.0 or EasingUtil.InCubic(Lerp(0, 1.0, section));
		bit:SetVertexColor(CPAPI.HSV2RGB(hue, s, v))
		bit:SetAlpha(bit.finalAlpha * alpha)
	end)

	-- Connect the bottom lines to the spline line, with perfect overlap.
	local numSegments, relTo, point = self:GetLineSegments(), self:GetLineOrigin();
	self.Bottom1:SetStartPoint(point, relTo, self:CalculatePoint((numSegments - 1) / numSegments))
	self.Bottom2:SetStartPoint(point, relTo, self:CalculatePoint((numSegments - 2) / numSegments))
end

function ComboButton:UpdateState(currentModifier)
	local isAlt = currentModifier:match(ALT_MATCH);
	Button.UpdateState(self, currentModifier)
	for action in self:EnumerateActions() do
		action:SetCurrentModifier(currentModifier, isAlt)
	end
	if self.isMouseOver then
		self:OnEnter()
	end
end

function ComboButton:ForceUpdateState(currentModifier)
	local wasMouseOver = self.isMouseOver;
	self.isMouseOver = nil;
	self:UpdateState(currentModifier)
	self.isMouseOver = wasMouseOver;
end

function ComboButton:SetGuidesVisible(visible)
	self:SetWidth(visible and 200 or 32)
	self.Bottom:SetShown(visible)
	self.Label:SetShown(visible)
	if not visible then
		if self:IsLineDrawn() then
			self:UpdateLineState(nil)
			self:ReleaseLine()
		end
	else
		if not self:IsLineDrawn() and self:IsVisible() then
			self:UpdateLines()
		end
	end
end

---------------------------------------------------------------
local ModifierTrayButton = {};
---------------------------------------------------------------

function ModifierTrayButton:Init(buttonID, modID, controlCallback)
	Mixin(self, ModifierTrayButton)
	local data = env:GetHotkeyData(buttonID, '', 64, 32)
	self:ToggleInversion(false)
	self:SetSelected(false)
	self:SetAttribute('nodeignore', true)
	self:SetScript('OnClick', controlCallback)
	self:SetScript('OnEnter', self.OnEnter)
	self:SetScript('OnLeave', self.OnLeave)
	self.buttonID = buttonID;
	self.modID = modID;
	CPAPI.SetTextureOrAtlas(self.Icon, data.button)
end

function ModifierTrayButton:SetSelected(selected)
	self:SetHeight(selected and 50 or 40)
end

function ModifierTrayButton:OnEnter()
	local cvarData = env:GetEmulationForModifier(env:GetActiveModifier(self.buttonID))
	if not cvarData then return end;
	local tooltip = GameTooltip;
	tooltip:SetOwner(self, 'ANCHOR_BOTTOM', 0, -10)
	SetCvarTooltip(tooltip, cvarData, false)
	tooltip:Show()
end

function ModifierTrayButton:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function ModifierTrayButton:SetPoint(point, ...)
	-- Workaround for a typo in LayoutFrame.lua:410.
	if point == 'BOTTOMRIGH' then
		point = 'BOTTOMRIGHT';
	end
	return CPAPI.Index(self).SetPoint(self, point, ...);
end

---------------------------------------------------------------
local Overview = CreateFromMixins(env.Mixin.UpdateStateTimer)
---------------------------------------------------------------
function Overview:OnLoad()
	local canvas = self:GetCanvas()
	self:SetSize(canvas:GetSize())
	self:SetPoint('CENTER', 0, 0)
	self:SetUpdateStateDuration(ANI_DURATION)

	self.Splash = self:CreateTexture(nil, 'ARTWORK')
	self.Splash:SetSize(450, 450)
	self.Splash:SetPoint('CENTER', 0, 0)

	self.ModifierTray = CreateFrame('Frame', nil, self, 'CPOverviewModifierTray')
	self.ModifierTray:SetPoint('BOTTOM', 0, 0)
	self.ModifierTray:SetFrameLevel(self:GetFrameLevel() + 2)
	self.ModifierTray.ReleaseAll = GenerateClosure(self.ModifierTray.buttonPool.ReleaseAll, self.ModifierTray.buttonPool)
	self.ModifierTray:SetButtonSetup(ModifierTrayButton.Init)

	self.buttonPool = CreateFramePool('Button', self, 'CPOverviewBindingSplashDisplay')

	env:RegisterCallback('Overview.HighlightButtons', self.HighlightButtons, self)
	env:RegisterCallback('Overview.OnChordClick', self.OnChordClick, self)
	env:RegisterCallback('Overview.EditorClosed', self.OnEditorClosed, self)
end

function Overview:AcquireComboButton()
	local button, newObj = self.buttonPool:Acquire()
	if newObj then
		button.Container = self;
		CPAPI.Specialize(button, ComboButton)
	end
	return button, newObj;
end

function Overview:EnumerateComboButtons()
	return self.buttonPool:EnumerateActive()
end

function Overview:GetColor()
	if not self.baseColor then
		self.baseColor = CPAPI.GetClassColorObject()
	end
	return self.baseColor:GetRGB()
end

---------------------------------------------------------------
-- Handlers
---------------------------------------------------------------
function Overview:OnShow()
	env:RegisterCallback('Settings.OnCharacterBindingsChanged', self.OnCharacterBindingsChanged, self)
	self:ReindexModifiers()
	self:SetDevice(env:GetActiveDeviceAndMap())
	self:ToggleAndUpdateModifier('')
	ConsolePort:SetCursorNodeIfActive(Guide.MenuFlyout)
end

function Overview:OnHide()
	env:UnregisterCallback('Settings.OnCharacterBindingsChanged', self)
	self.buttonPool:ReleaseAll()
	self.Splash:SetTexture(nil)
	self.Device = nil;
	self.baseColor = nil;
	self.currentMods = nil;
	if self.modClosures then
		for buttonID, closure in pairs(self.modClosures) do
			env.Frame:FreeButton(buttonID, closure)
		end
		self.modClosures = nil;
	end
	env:TriggerEvent('Overview.OnHide')
end

function Overview:HighlightButtons(sequence, overrideModifiers)
	self:SetUpdateStateTimer(function()
		if self.splashHidden then return end;

		if not sequence then
			for button in self:EnumerateComboButtons() do
				button:SetGuidesVisible(not self.splashHidden)
				button:ForceUpdateState(self.mod)
				button:SetLineAlpha(nil, false, 1.0)
			end
			return self.Splash:SetShown(not self.splashHidden)
		end

		sequence = { ('-'):split(sequence) };
		local numButtons, matches = #sequence, {};
		for i, buttonID in ipairs(sequence) do
			for button in self:EnumerateComboButtons() do
				if not matches[button] then
					if button:GetBaseBinding() == buttonID then
						button:SetGuidesVisible(true)
						button:ForceUpdateState(overrideModifiers or self.mod)
						button:SetLineAlpha(1.0, true, ANI_DURATION * (numButtons - i + 1))
						matches[button] = true;
					else
						matches[button] = false;
					end
				end
			end
		end
		for button, isMatched in pairs(matches) do
			if not isMatched then
				button:SetGuidesVisible(true)
				button:ForceUpdateState(self.mod)
				button:SetLineAlpha(0.1, false, ANI_DURATION)
			end
		end
		self.Splash:Show()
	end)
end

function Overview:SetSplashHidden(hidden)
	self.splashHidden = hidden;
	self.Splash:SetShown(not hidden)
	for button in self:EnumerateComboButtons() do
		button:SetGuidesVisible(not hidden)
	end
end

function Overview:OnChordClick(chord)
	self:SetSplashHidden(true)
	env:TriggerEvent('Overview.EditInput', chord, self)
end

function Overview:OnEditorClosed()
	self:SetSplashHidden(false)
end

function Overview:OnCharacterBindingsChanged()
	for button in self:EnumerateComboButtons() do
		Button.UpdateState(button, button:GetModifier())
		for action in button:EnumerateActions() do
			action:UpdateCurrentInfo()
		end
	end
end

---------------------------------------------------------------
-- Device and modifiers
---------------------------------------------------------------
function Overview:ReindexModifiers()
	self.currentMods = {};
	self.modClosures = {};
	self.ModifierTray:ReleaseAll()
	for modID, buttonID in db:For('Gamepad/Index/Modifier/Key', true) do
		self.currentMods[modID] = false; -- Initialize active modifiers to false
		self.ModifierTray:AddControl(buttonID, modID, GenerateClosure(self.ToggleAndUpdateModifier, self, modID));
		self.modClosures[buttonID] = env.Frame:CatchButton(buttonID, self.ToggleAndUpdateModifier, self, modID);
	end
end

function Overview:ToggleAndUpdateModifier(modifier)
	self:UpdateModifier(self:ToggleModifier(modifier))
end

function Overview:ToggleModifier(modifier)
	for tracked in pairs(self.currentMods) do
		if modifier:match(tracked) then
			self.currentMods[tracked] = not self.currentMods[tracked];
			break;
		end
	end
	self.mod = '';
	for mod, isDown in db.table.spairs(self.currentMods) do
		if isDown then
			self.mod = self.mod .. mod .. '-';
		end
	end
	return self.mod;
end

function Overview:UpdateModifier(currentModifier)
	for button in self.buttonPool:EnumerateActive() do
		button:UpdateState(currentModifier)
	end
	for button in self.ModifierTray:EnumerateControls() do
		button:SetSelected(self.currentMods[button.modID])
	end
end

function Overview:SetDevice(device)
	self.Splash:SetTexture(env:GetSplashTexture(device))
	self.Device = device;
	self.buttonPool:ReleaseAll()

	if not device.Layout then
		return error('Device theme or layout not found for: ' .. (device.Name or 'Unknown Device'))
	end

	-- Position format:
	-- delta (-1 or 1), drawLayer, x1, y1, ..., xN, yN
	local left, right = {}, {};

	local function ExtractTargetAndLevel(position)
		return position[1] < 0 and left or right, position[2];
	end

	local function ExtractPoints(position)
		local delta, points = position[1], {};
		for i = 3, #position, 2 do
			tinsert(points, { delta * position[i], position[i + 1] });
		end
		return points;
	end

	local function SortEntriesByLastY(a, b)
		return a.points[#a.points][2] < b.points[#b.points][2];
	end

	for button, position in pairs(device.Layout) do
		assert(#position % 2 == 0, 'Invalid position format for button: ' .. button)
		local target, level = ExtractTargetAndLevel(position)
		tinsert(target, {
			button   = button;
			level    = level;
			points   = ExtractPoints(position);
		})
	end

	table.sort(left, SortEntriesByLastY)
	table.sort(right, SortEntriesByLastY)

	local activeModifiers = env:GetActiveModifiers()
	self:DrawButtons(left, true, activeModifiers)
	self:DrawButtons(right, false, activeModifiers)
end

function Overview:DrawButtons(buttons, isLeft, activeMods)
	local numButtons = #buttons;
	for i, data in ipairs(buttons) do
		local button = self:AcquireComboButton(data.button)
		button:SetColor(self:GetColor())
		button:SetData(i, numButtons, data, isLeft, activeMods)
		button:Show()
	end
end

---------------------------------------------------------------
do -- Add overview to guide content
---------------------------------------------------------------
	local function Initialize(canvas, GetCanvas)
		if not canvas.Overview then
			canvas.Overview = CreateFrame('Frame', nil, canvas)
			canvas.Overview.GetCanvas = GetCanvas;
			CPAPI.SpecializeOnce(canvas.Overview, Overview)
		end
		canvas.Overview:Show()
	end

	local function Reset(canvas)
		if not canvas.Overview then return end;
		canvas.Overview:Hide()
	end

	local function OnDefaults()
		local activeDevice = env:GetActiveDeviceAndMap()
		if not activeDevice then return end;
		for combination, binding in pairs(activeDevice:GetPresetBindings()) do
			env:SetBinding(combination, binding)
		end
		CPAPI.Log('Preset %s has been applied.', activeDevice.Name)
	end

	local Predicate = env.HasActiveDevice();

	Guide:AddContent('Overview',
		Predicate, Initialize, Reset, Predicate, OnDefaults)
end