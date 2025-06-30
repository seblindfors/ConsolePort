local env, db, _, L = CPAPI.GetEnv(...);
local Guide = env:GetContextPanel();

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local WHITE_FONT_COLOR = WHITE_FONT_COLOR or CreateColor(1, 1, 1)
local ALT_MATCH = 'ALT%-';
local ANI_DURATION = 0.15;
local ButtonLayout = {
	LEFT = {
		iconPoint   = {'RIGHT', 'LEFT', -4, 0};
		textPoint   = {'LEFT', 'LEFT', 40, 0};
		buttonPoint = {'LEFT', 0, 0};
		startAnchor = {'BOTTOMRIGHT', 0, 0};
		endAnchor   = {'BOTTOMLEFT', -160, 0};
		lineCoords  = CPSplineLineMixin.lineBaseCoord.LEFT;
	};
	RIGHT = {
		iconPoint   = {'LEFT', 'RIGHT', 4, 0};
		textPoint   = {'RIGHT', 'RIGHT', -40, 0};
		buttonPoint = {'RIGHT', 0, 0};
		startAnchor = {'BOTTOMLEFT', 0, 0};
		endAnchor   = {'BOTTOMRIGHT', 160, 0};
		lineCoords  = CPSplineLineMixin.lineBaseCoord.RIGHT;
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
	return SetBinding(self:GetKeyChord(), bindingID, GetCurrentBindingSet())
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

function Button:OnEnter()
--[[	local tooltip = GameTooltip;
	local override = self.reservedData;
	local isClickOverride = self:IsClickReserved(override)
	tooltip:SetOwner(self, 'ANCHOR_NONE')
	tooltip:SetPoint('BOTTOM', self.Container, 'BOTTOM', 0, 0)

	if override then
		SetCvarTooltip(tooltip, override, true)
		if isClickOverride then
			tooltip:AddLine('\n'..KEY_BINDINGS_MAC)
		end
	else
		tooltip:SetText(('|cFFFFFFFF%s|r'):format(KEY_BINDINGS_MAC))
	end

	local base = self:GetBaseBinding()
	local mods = env:GetActiveModifiers()

	for mod, keys in db.table.mpairs(mods) do
		if (not override or (isClickOverride and mod ~= '')) then
			local name, texture, actionID = self:GetBindingInfo(self:GetChordBinding(mod))
			local slug = env:GetButtonSlug(base, mod)
			if actionID then
				texture = texture or 'Interface\\Buttons\\ButtonHilight-Square'
				name = name:gsub('\n', '\n|T:12:32:0:0|t ') -- offset 2nd line
				tooltip:AddDoubleLine(('|T%s:32:32:0:-12|t %s\n '):format(texture, name), slug)
			else
				tooltip:AddDoubleLine(('%s\n '):format(name), slug)
			end
		end
	end
	tooltip:Show()]]
end

function Button:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
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

	if self.ActionIcon then
		point, relativePoint, xOffset, yOffset = unpack(set.iconPoint)
		self.ActionIcon:ClearAllPoints()
		self.ActionIcon:SetPoint(point, self, relativePoint, xOffset, yOffset)
	end
end

function Button:SetBaseBinding(binding)
	local data = env:GetHotkeyData(binding, '', 64, 32)
	Binding.SetBaseBinding(self, binding)
	CPAPI.SetTextureOrAtlas(self.Icon, data.button)
end

function Button:UpdateInfo(name, texture, actionID)
	self:SetText(name)
	if not self.ActionIcon then return end;
	self.ActionIcon:SetTexture(texture)
	self.ActionIcon:SetShown(texture)
	self.ActionIcon:SetAlpha(texture and 1 or 0)
	self.Mask:SetShown(texture)
	self.Mask:SetAlpha(texture and 1 or 0)
end

function Button:UpdateState(currentModifier)
	self:SetModifier(currentModifier)

	local reserved = env:GetCombinationBlockerInfo(self:GetKeyChord())
		          or env:GetEmulationForCursor(self:GetBaseBinding())
	self:SetReserved(reserved)

	local isClickOverride = (self:IsClickReserved(reserved) and currentModifier ~= '')
	if not isClickOverride and reserved then
		return self:UpdateInfo(WHITE_FONT_COLOR:WrapTextInColorCode(L(reserved.name)))
	end

	self:UpdateInfo(self:GetBindingInfo(self:GetBinding()))
end

---------------------------------------------------------------
local Action, ActionHitRectPool = CreateFromMixins(Binding)
---------------------------------------------------------------

function Action:OnLoad()
	self:SetMovable(true)
	self:RegisterForDrag('LeftButton')
	self:SetScript('OnDragStop', self.OnDragStop)
end

function Action:OnShow()
	env:RegisterCallback('Overview.OnDragBinding', self.OnDragBinding, self)
end

function Action:OnHide()
	env:UnregisterCallback('Overview.OnDragBinding', self)
	self:CommitHitRect()
end

function Action:OnEnter()
	self.isMouseOver = true;
	env:TriggerEvent('Overview.OnHighlightButtons', self:GetButtonSequence())

	GameTooltip_SetDefaultAnchor(GameTooltip, self)

	local name, _, actionID = self:GetBindingInfo(self:GetBinding(), true)
	local reserved = env:GetCombinationBlockerInfo(self:GetKeyChord())
	if reserved then
		SetCvarTooltip(GameTooltip, reserved, true)
	elseif ( actionID and GameTooltip:SetAction(actionID) ) then
		GameTooltip:AddLine('\n'..name)
	else
		-- SetAction failed, so re-anchoring is required.
		if actionID then
			GameTooltip_SetDefaultAnchor(GameTooltip, self)
		end
		GameTooltip:SetText(name)
	end

	local slug = not reserved and db.Hotkeys:GetButtonSlugForChord(self:GetKeyChord())
	if slug then
		GameTooltip:AddLine(('%s: %s'):format(KEY_BINDING, slug), GameFontGreen:GetTextColor())
	end
	GameTooltip:Show()
end

function Action:OnLeave()
	self.isMouseOver = false;
	env:TriggerEvent('Overview.OnHighlightButtons', nil)
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

---------------------------------------------------------------
-- Drag and drop types
---------------------------------------------------------------
function Action:OnDragBinding(isDragging, action, data)
	if action == self then return end;
	if isDragging then
		self:EnableDragTarget(action, data)
	else
		local isMouseOver, targetAction, targetData = self:CommitDragTarget()
		if not isMouseOver then return end;
		local targetBinding = targetAction:GetBinding()
		targetAction:SetBinding(self:GetBinding())
		targetAction:UpdateCurrentInfo()
		self:SetBinding(targetBinding)
		self:UpdateCurrentInfo()
	end
end

---------------------------------------------------------------
-- Drag and drop tracking
---------------------------------------------------------------
local function ActionUpdateMouseOver(action, hitRect)
	local isMouseOver = hitRect:IsMouseOver();
	local isUpdated = action.isDragOverRect == isMouseOver;
	action.isDragOverRect = isMouseOver;
	action:UpdateDragAction(isMouseOver, isUpdated)
end

function Action:OnDragStart()
	local data = self:GetData()
	data.origin = self:AcquireOrigin()

	self:StartMoving()
	self:SetFrameLevel(self:GetFrameLevel() + 10)
	env:TriggerEvent('Overview.OnDragBinding', true, self, data)
end

function Action:OnDragStop()
	local data = self:GetData()
	data.origin = self:ReleaseOrigin()

	self:StopMovingOrSizing()
	self:SetFrameLevel(self:GetFrameLevel() - 10)
	env:TriggerEvent('Overview.OnDragBinding', false, self, data)
end

function Action:UpdateDragAction(isMouseOver, isUpdated)
	if not isUpdated then return end;
	self:ClearAllPoints()
	self:SetPoint(unpack(isMouseOver and self:GetTargetOrigin() or self:AcquireOrigin()))
end

function Action:EnableDragTarget(action, data)
	self.targetAction, self.targetData = action, data;
	self:AcquireOrigin()
	self:AcquireHitRect()
end

function Action:CommitDragTarget()
	local isMouseOver = self:CommitHitRect()
	local targetAction, targetData = self.targetAction, self.targetData;
	self:ReleaseOrigin()
	self.targetAction, self.targetData = nil, nil;
	return isMouseOver, targetAction, targetData;
end

function Action:GetTargetOrigin()
	return self.targetData and self.targetData.origin or nil;
end

function Action:AcquireHitRect()
	if self.hitRect then
		return self.hitRect;
	end
	if not ActionHitRectPool then
		ActionHitRectPool = CreateFramePool('Frame', nil, nil, function(_, hitRect)
			hitRect:Hide()
			hitRect:ClearAllPoints()
			if hitRect.ticker then
				hitRect.ticker:Cancel()
				hitRect.ticker = nil;
			end
		end)
	end
	local hitRect, newObj = ActionHitRectPool:Acquire()
	if newObj then
		hitRect:SetSize(self:GetSize())
		hitRect:SetFrameLevel(self:GetFrameLevel() + 1)
	end
	hitRect:SetParent(self)
	hitRect:SetPoint(self:GetPoint())
	hitRect:Show()
	hitRect.ticker = C_Timer.NewTicker(0.1, GenerateClosure(ActionUpdateMouseOver, self, hitRect))
	self.hitRect = hitRect;
	return hitRect;
end

function Action:CommitHitRect()
	if not self.hitRect then return end;
	local isDragOverRect = self.isDragOverRect;
	ActionHitRectPool:Release(self.hitRect)
	self.hitRect, self.isDragOverRect = nil, nil;
	return isDragOverRect;
end

function Action:AcquireOrigin()
	if not self.origin then
		self.origin = { self:GetPoint() };
	end
	return self.origin;
end

function Action:ReleaseOrigin()
	local origin = self.origin;
	if origin then
		self:ClearAllPoints()
		self:SetPoint(unpack(origin))
		self.origin = nil;
	end
	return origin;
end

---------------------------------------------------------------
-- Action information
---------------------------------------------------------------
function Action:UpdateInfo(name, texture, actionID, bindingID)
	--print('Action:UpdateInfo', name, texture, actionID, bindingID)
	self.name = name or '';
	self.cvar = nil;

	if ( not texture and not actionID and not bindingID ) then
		local blocker = env:GetBlockedCombination(self:GetKeyChord())
		if blocker then
			texture = db.Bindings.CustomIcons[blocker];
			self.cvar = db.Gamepad.Index.Modifier.Cvars[blocker];
		end
	end

	local c = (texture or (not actionID and bindingID)) and 1 or 0.5;
	local a = (texture or actionID or bindingID) and 1 or 0.25;
	self.Border:SetAlpha(a * 0.5)
	self.Icon:SetVertexColor(c, c, c, a);
	self.Icon:SetTexture(texture
		or actionID and CPAPI.GetAsset([[Textures\Button\EmptyIcon]])
		or bindingID and [[Interface\MacroFrame\MacroFrame-Icon]]
		or CPAPI.GetAsset([[Textures\Button\NotBound]])
	);
end

function Action:SetChord(modifierID, buttonID, isAlt)
	if isAlt then
		self.altModifier = modifierID;
		return;
	end
	self.baseModifier = modifierID;
	self:SetBaseBinding(buttonID)
	self:UpdateModifier(modifierID)
end

function Action:UpdateModifier(modifier)
	self:SetModifier(modifier)
	self:UpdateCurrentInfo()
end

function Action:UpdateCurrentInfo()
	self:UpdateInfo(self:GetBindingInfo(self:GetBinding()))
end

function Action:SetCurrentModifier(modifier, isAlt)
	local modifierID = isAlt and self.altModifier or self.baseModifier;
	local isActive = modifier == modifierID;
	if ( self.mod ~= modifierID ) then
		self:UpdateModifier(modifierID)
		if self.isMouseOver then
			self:OnEnter()
		end
	end
	self.Border:SetShown(isActive);
end

function Action:GetData()
	local name, texture, actionID, bindingID = self:GetBindingInfo(self:GetBinding())
	return {
		name      = name;
		texture   = texture;
		actionID  = actionID;
		bindingID = bindingID;
		cvar      = self.cvar;
		chord     = self:GetKeyChord();
		modifier  = self:GetModifier();
		button    = self:GetBaseBinding();
	};
end

---------------------------------------------------------------
local ComboButton = CreateFromMixins(Button, CPSplineLineMixin, ColorMixin)
---------------------------------------------------------------

function ComboButton:OnLoad()
	Button.OnLoad(self)
	CPSplineLineMixin.OnLoad(self)
	self:SetLineOrigin('CENTER', self.Container)

	-- Actions based on the active modifiers.
	self.actions = CreateFramePool('Button', self, 'CPOverviewActionDisplay')

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

function ComboButton:AcquireAction()
	local button, newObj = self.actions:Acquire()
	if newObj then
		FrameUtil.SpecializeFrameWithMixins(button, Action)
	end
	button.BorderHilite:SetVertexColor(self:GetRGB())
	return button;
end

function ComboButton:ClearActions()
	self.actions:ReleaseAll()
end

function ComboButton:EnumerateActions()
	return self.actions:EnumerateActive()
end

function ComboButton:ReleaseAll()
	self:ClearActions()
	self:ClearLinePoints()
end

function ComboButton:OnEnter()
	self.isMouseOver = true;
	Button.OnEnter(self)
	env:TriggerEvent('Overview.OnHighlightButtons', (self:GetButtonSequence()))
end

function ComboButton:OnLeave()
	self.isMouseOver = false;
	Button.OnLeave(self)
	env:TriggerEvent('Overview.OnHighlightButtons', nil)
end

function ComboButton:SetLineAlpha(alpha, reverse, duration) duration = duration or ANI_DURATION;
	local delta    = alpha or 1.0;
	local isOpaque = alpha and alpha >= 1.0;
	local bitAlpha = isOpaque and 1.0 or nil;
	local cutoff   = self:GetLineSegments();
	self:PlayLineEffect(duration, function(bit, i)
		 -- Hide the last bit so that alpha merges correctly with the bottom lines.
		if ( not isOpaque and i >= cutoff ) then
			bit:SetAlpha(0)
		else
			bit:SetAlpha(Saturate(bitAlpha or delta * bit.finalAlpha))
		end
		if i == cutoff then
			self.Bottom:FadeIn(duration, self.Bottom:GetAlpha(), Saturate(delta * 1.0))
		end
	end, reverse)
end

function ComboButton:SetData(index, numButtons, data, isLeft, activeMods)
	self.index = index;
	self.data  = data;
	self:ReleaseAll()
	self:RenderActions(data, isLeft, activeMods)
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

function ComboButton:RenderActions(data, isLeft, activeMods)
	local baseButton, index = data.button, 1;
	local anchor    = isLeft and 'RIGHT' or 'LEFT';
	local relAnchor = isLeft and 'LEFT' or 'RIGHT';
	local delta     = isLeft and -1 or 1;

	local active = {};
	for mod in db.table.mpairs(activeMods) do
		local isAlt  = mod:match(ALT_MATCH);
		local base   = mod:gsub(ALT_MATCH, '');
		local action = active[base] or self:AcquireAction()
		action:SetChord(mod, baseButton, isAlt)
		if not isAlt then
			action:SetPoint(anchor, self, relAnchor, ((index - 1) * 40 * delta) + (delta * 12), 0)
			action:Show()
			active[mod] = action;
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
    local x = PixelUtil.ConvertPixelsToUIForRegion(isLeft and -w * 0.28 or w * 0.28, self)

	w, h = self:GetSize()
	self:SetPoint('CENTER', x, y)

	-- Calculate the connecting points for the spline line.
	local lastX = x + (isLeft and w / 2 or -w / 2) + (isLeft and -3 or 3);
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
	self.Bottom:SetAlpha(1.0)

	local e = (h + 180) % 360;
	self:DrawLine(function(bit, section)
		local hue = Lerp(e, h, section);
		bit.finalAlpha = EasingUtil.InCubic(Lerp(0, 1.0, section));
		bit:SetVertexColor(CPAPI.HSV2RGB(hue, s, v))
		bit:SetAlpha(bit.finalAlpha)
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

---------------------------------------------------------------
local ModifierTrayButton = {};
---------------------------------------------------------------

function ModifierTrayButton:Init(buttonID, modID, controlCallback)
	Mixin(self, ModifierTrayButton)
	local data = env:GetHotkeyData(buttonID, '', 64, 32)
	self:ToggleInversion(true)
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

---------------------------------------------------------------
local Overview = {};
---------------------------------------------------------------
function Overview:OnLoad()
	local canvas = self:GetCanvas()
	self:SetSize(canvas:GetSize())
	self:SetPoint('CENTER', 0, 0)

	self.Splash = self:CreateTexture(nil, 'ARTWORK')
	self.Splash:SetSize(450, 450)
	self.Splash:SetPoint('CENTER', 0, 0)

	self.ModifierTray = CreateFrame('Frame', nil, self, 'CPOverviewModifierTray')
	self.ModifierTray:SetPoint('TOP', 0, 0)
	self.ModifierTray.ReleaseAll = GenerateClosure(self.ModifierTray.buttonPool.ReleaseAll, self.ModifierTray.buttonPool)
	self.ModifierTray:SetButtonSetup(ModifierTrayButton.Init)

	self.buttonPool = CreateFramePool('Button', self, 'CPOverviewBindingSplashDisplay')

	env:RegisterCallback('Overview.OnHighlightButtons', self.OnHighlightButtons, self)

	-- TODO: handle tap bindings since we want to toggle modifiers without
	-- triggering the tap binding.
end

function Overview:AcquireComboButton()
	local button, newObj = self.buttonPool:Acquire()
	if newObj then
		button.Container = self;
		FrameUtil.SpecializeFrameWithMixins(button, ComboButton)
	end
	return button, newObj;
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
	self:ReindexModifiers()
	self:SetDevice(env:GetActiveDeviceAndMap())
	self:RegisterEvent('MODIFIER_STATE_CHANGED')
	self:ToggleAndUpdateModifier('')
end

function Overview:OnHide()
	self:UnregisterEvent('MODIFIER_STATE_CHANGED')
	self.buttonPool:ReleaseAll()
	self.Splash:SetTexture(nil)
	self.Device = nil;
	self.baseColor = nil;
	self.currentMods = nil;
end

function Overview:OnEvent(_, modifier, state)
	if (state ~= 0) then return end; -- isUp
	self:UpdateModifier(self:ToggleModifier(modifier))
end

function Overview:OnHighlightButtons(sequence, overrideModifiers)
	if self.updateStateTimer then
		self.updateStateTimer:Cancel()
		self.updateStateTimer = nil;
	end
	self.updateStateTimer = C_Timer.NewTimer(ANI_DURATION, function()
		if not sequence then
			for button in self.buttonPool:EnumerateActive() do
				button:SetLineAlpha(nil, false, 1.0)
				button:ForceUpdateState(self.mod)
			end
			return;
		end

		sequence = { ('-'):split(sequence) };
		local numButtons, matches = #sequence, {};
		for i, buttonID in ipairs(sequence) do
			for button in self.buttonPool:EnumerateActive() do
				if not matches[button] then
					if button:GetBaseBinding() == buttonID then
						button:SetLineAlpha(1.0, true, ANI_DURATION * (numButtons - i + 1))
						button:ForceUpdateState(overrideModifiers or self.mod)
						matches[button] = true;
					else
						matches[button] = false;
					end
				end
			end
		end
		for button, isMatched in pairs(matches) do
			if not isMatched then
				button:ForceUpdateState(self.mod)
				button:SetLineAlpha(0.1, false, ANI_DURATION)
			end
		end
	end)
end

---------------------------------------------------------------
-- Device and modifiers
---------------------------------------------------------------
function Overview:ReindexModifiers()
	self.currentMods = {};
	self.ModifierTray:ReleaseAll()
	for modID, buttonID in db:For('Gamepad/Index/Modifier/Key', true) do
		self.currentMods[modID] = false; -- Initialize active modifiers to false
		self.ModifierTray:AddControl(buttonID, modID, GenerateClosure(self.ToggleAndUpdateModifier, self, modID));
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
	local asset  = device.Name and db('Gamepad/Index/Splash/'..device.Name)
	self.Splash:SetTexture(CPAPI.GetAsset('Splash\\Gamepad\\'..asset))
	self.Device = device;
	self.buttonPool:ReleaseAll()

	if not device.Theme or not device.Theme.Layout then
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

	for button, position in pairs(device.Theme.Layout) do
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
-- Add overview to guide content
---------------------------------------------------------------
Guide:AddContent(CPAPI.Static(true), function(canvas)
	if not canvas.Overview then
		canvas.Overview = CreateFrame('Frame', nil, canvas);
		canvas.Overview.GetCanvas = CPAPI.Static(canvas);
		FrameUtil.SpecializeFrameWithMixins(canvas.Overview, Overview)
	end
	canvas.Overview:Show()
end, function(canvas)
	if not canvas.Overview then return end;
	canvas.Overview:Hide()
end)