local db = select(2, ...)
---------------------------------------------------------------
-- Indexed widget pool
---------------------------------------------------------------
CPIndexPoolMixin = {};

function CPIndexPoolMixin:OnLoad()
	self.Registry = {};
end

function CPIndexPoolMixin:CreateFramePool(type, template, mixin, resetterFunc, parent)
	assert(not self.FramePool, 'Frame pool already exists.')
	self.FramePool = CreateFramePool(type, parent or self, template, resetterFunc)
	self.FramePoolMixin = mixin;
	return self.FramePool;
end

function CPIndexPoolMixin:Acquire(index)
	local widget, newObj = self.FramePool:Acquire()
	if newObj then
		Mixin(widget, self.FramePoolMixin)
	end
	self.Registry[index] = widget;
	return widget, newObj;
end

function CPIndexPoolMixin:TryAcquireRegistered(index)
	local widget = self.Registry[index];
	if widget then
		local pool = self.FramePool;
		local inactiveIndex = tIndexOf(pool.inactiveObjects, widget)
		if inactiveIndex then
			pool.activeObjects[tremove(pool.inactiveObjects, inactiveIndex)] = true;
			pool.numActiveObjects = pool.numActiveObjects + 1;
		end
		return widget;
	end
	return self:Acquire(index)
end

function CPIndexPoolMixin:GetObjectByIndex(index)
	return self.Registry[index];
end

function CPIndexPoolMixin:EnumerateActive()
	return self.FramePool:EnumerateActive()
end

function CPIndexPoolMixin:GetNumActive()
	return self.FramePool:GetNumActive()
end

function CPIndexPoolMixin:ReleaseAll()
	self.FramePool:ReleaseAll()
end

---------------------------------------------------------------
-- Trackable widget pool
---------------------------------------------------------------
CPFocusPoolMixin = CreateFromMixins(CPIndexPoolMixin);

function CPFocusPoolMixin:OnPostHide()
	self.focusIndex = nil;
end

function CPFocusPoolMixin:GetFocusIndex()
	return self.focusIndex
end

function CPFocusPoolMixin:GetFocusWidget()
	return self.focusIndex and self.Registry[self.focusIndex]
end

function CPFocusPoolMixin:SetFocusByIndex(index)
	local old = self.focusIndex ~= index and self.focusIndex;
	self.focusIndex = index;

	local oldObj = old and self.Registry[old];
	local newObj = self.Registry[index];
	return newObj, oldObj;
end

function CPFocusPoolMixin:SetFocusByWidget(widget)
	return self:SetFocusByIndex(tIndexOf(self.Registry, widget))
end


---------------------------------------------------------------
-- Gradient mixin
---------------------------------------------------------------
CPGradientMixin = {};

function CPGradientMixin:OnLoad()
	self.VertexColor  = CPAPI.GetClassColorObject()
	self.VertexValid  = CreateColor(1, .81, 0, 1)
	self.VertexOrient = 'VERTICAL';
end

function CPGradientMixin:SetGradientDirection(direction)
	assert(direction == 'VERTICAL' or direction == 'HORIZONTAL', 'Valid: VERTICAL, HORIZONTAL')
	self.VertexOrient = direction;
end

function CPGradientMixin:GetClassColor()
	return self.VertexColor:GetRGB()
end

function CPGradientMixin:GetValidColor()
	return self.VertexColor:GetRGB()
end

function CPGradientMixin:GetMixGradient(...)
	return CPAPI.GetReverseMixColorGradient(self.VertexOrient, ...)
end

function CPGradientMixin:GetReverseMixGradient(...)
	return CPAPI.GetMixColorGradient(self.VertexOrient, ...)
end

function CPGradientMixin:GetFadeGradient(...)
	return self.VertexOrient, 1, 1, 1, 0, ...;
end


---------------------------------------------------------------
-- Frame background
---------------------------------------------------------------
CPBackgroundMixin = CreateFromMixins(BackdropTemplateMixin);

function CPBackgroundMixin:OnLoad()
	local r, g, b = CPAPI.GetWebColor(CPAPI.GetClassFile()):GetRGB()
	self:HookScript('OnSizeChanged', self.OnBackdropSizeChanged)
	self.Background = self:CreateTexture(nil, 'BACKGROUND', nil, 2)
	self.Rollover   = self:CreateTexture(nil, 'BACKGROUND', nil, 3)
	self.Rollover:SetAllPoints(self.Background)
	self.Rollover:SetTexture(CPAPI.GetAsset([[Textures\Frame\Backdrop_Vertex_White]]))
	self.Rollover:SetGradientAlpha('VERTICAL', r*0.5, g*0.5, b*0.5, 1, r*0.5, g*0.5, b*0.5, 0)
	self:SetOriginTop(true)
	self:CreateBackground(2048, 2048, 2048, 2048, CPAPI.GetAsset([[Art\Background\%s]]):format(CPAPI.GetClassFile()))
end

function CPBackgroundMixin:GetBGOffset(point, size)
	return ((point / 2) / size)
end

function CPBackgroundMixin:GetBGFraction(point, size)
	return (point / size)
end

function CPBackgroundMixin:SetBackgroundDimensions(w, h, x, y)
	assert(self.Background, 'Frame is missing background.')
	self.Background.maxWidth = w;
	self.Background.maxHeight = h;
	self.Background.sizeX = x;
	self.Background.sizeY = y;
end

function CPBackgroundMixin:SetOriginTop(enabled)
	self.originTop = enabled;
end

function CPBackgroundMixin:OnAspectRatioChanged()
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

function CPBackgroundMixin:SetBackgroundInsets(enabled, value)
	self.Background:ClearAllPoints()
	if enabled then
		local inset = value or 8;
		self.Background:SetPoint('TOPLEFT', inset, -inset)
		self.Background:SetPoint('BOTTOMRIGHT', -inset, inset)
	else
		self.Background:SetAllPoints()
	end
end

function CPBackgroundMixin:CreateBackground(w, h, x, y, texture)
	self.Background:SetTexture(texture)
	self:SetBackgroundDimensions(w, h, x, y)
	self:OnAspectRatioChanged()
	self:HookScript('OnShow', self.OnAspectRatioChanged)
	self:HookScript('OnSizeChanged', self.OnAspectRatioChanged)
end

function CPBackgroundMixin:SetBackgroundVertexColor(...)
	self.Background:SetVertexColor(...)
end


---------------------------------------------------------------
-- Ambience mixin
---------------------------------------------------------------
CPAmbienceMixin = {
	soundKitOnShow = SOUNDKIT.UI_ADVENTURES_ADVENTURER_LEVEL_UP;
	soundVars = {
		Sound_EnableSFX = false;
		Sound_EnableMusic = false;
		Sound_EnableDialog = false;
		Sound_EnableAmbience = false;
		-----------------------------
		Sound_MasterVolume = false;
		Sound_AmbienceVolume = false;
	};
	soundKits = {
		WARRIOR     = SOUNDKIT.AMB_GLUESCREEN_BATTLE_FOR_AZEROTH;
		HUNTER      = SOUNDKIT.AMB_GLUESCREEN_NIGHTELF;
		MAGE        = SOUNDKIT.AMB_GLUESCREEN_VOIDELF;
		ROGUE       = SOUNDKIT.AMB_GLUESCREEN_DARKIRONDWARF;
		PRIEST      = SOUNDKIT.AMB_GLUESCREEN_DWARF;
		WARLOCK     = SOUNDKIT.AMB_GLUESCREEN_LEGION;
		PALADIN     = SOUNDKIT.AMB_GLUESCREEN_LIGHTFORGEDDRAENEI;
		DRUID       = SOUNDKIT.AMB_GLUESCREEN_WARLORDS_OF_DRAENOR;
		SHAMAN      = SOUNDKIT.AMB_GLUESCREEN_DRAENEI;
		MONK        = SOUNDKIT.AMB_GLUESCREEN_PANDAREN;
		DEMONHUNTER = SOUNDKIT.AMB_GLUESCREEN_DEMONHUNTER;
		DEATHKNIGHT = SOUNDKIT.AMB_GLUESCREEN_DEATHKNIGHT;
	};
}

function CPAmbienceMixin:OnLoad()
	self:HookScript('OnShow', self.PlayAmbience)
	self:HookScript('OnHide', self.StopAmbience)
end

function CPAmbienceMixin:PlayAmbience()
	PlaySound(self.soundKitOnShow, 'Master', true)
	if db('disableAmbientFrames') then return end;
	local playFileID = self.soundKits[CPAPI.GetClassFile()]
	if playFileID and GetCVarBool('Sound_EnableAmbience') then
		local willPlay, handle = PlaySound(playFileID, 'Master', true)
		if willPlay then
			local volume = GetCVar('Sound_AmbienceVolume')
			self.isPlayingAmbience = handle;
			for var in pairs(self.soundVars) do
				self.soundVars[var] = GetCVar(var)
				SetCVar(var, 0)
			end
			SetCVar('Sound_MasterVolume', volume)
		end
	end
end

function CPAmbienceMixin:StopAmbience()
	if self.isPlayingAmbience then
		StopSound(self.isPlayingAmbience, 1000)
		self.isPlayingAmbience = nil;
		for var, val in pairs(self.soundVars) do
			SetCVar(var, val)
		end
	end
end


---------------------------------------------------------------
-- Smooth scroll
---------------------------------------------------------------
do local Scroller = CreateFrame('Frame'); Scroller.Frames = {};

	function Scroller:OnUpdate(elapsed)
		local current, delta
		for frame, data in pairs(self.Frames) do
			current = frame:GetScroll()
			if abs(current - data.targetPos) < 1 then
				frame:SetScroll(data.targetPos)
				self:RemoveFrame(frame)
			else
				delta = current > data.targetPos and -1 or 1;
				frame:SetScroll(current +
					(delta * abs(current - data.targetPos) / data.stepSize * 8));
			end
		end
	end

	function Scroller:AddFrame(frame, targetPos, stepSize)
		self.Frames[frame] = {
			targetPos = targetPos;
			stepSize  = stepSize;
		};
		self:SetScript('OnUpdate', self.OnUpdate)
	end

	function Scroller:RemoveFrame(frame)
		self.Frames[frame] = nil;
		if not next(self.Frames) then
			self:SetScript('OnUpdate', nil)
		end
		return frame.OnScrollFinished and frame:OnScrollFinished()
	end

	-----------------------------------------------------------
	-- Mixin
	-----------------------------------------------------------
	CPSmoothScrollMixin = {
		MouseWheelDelta = 100;
		Horizontal = {
			GetRange  = 'GetHorizontalScrollRange';
			GetScroll = 'GetHorizontalScroll';
			SetScroll = 'SetHorizontalScroll';
		};
		Vertical = {
			GetRange  = 'GetVerticalScrollRange';
			GetScroll = 'GetVerticalScroll';
			SetScroll = 'SetVerticalScroll';
		};
	}

	function CPSmoothScrollMixin:SetScrollOrientation(orient)
		assert(self[orient], 'Orientation must be either Horizontal or Vertical.')
		self.ScrollOrientationSet = true;
		for alias, metaname in pairs(self[orient]) do
			self[alias] = self[metaname]
		end
	end

	function CPSmoothScrollMixin:SetDelta(delta)
		self.MouseWheelDelta = delta;
	end

	function CPSmoothScrollMixin:OnScrollMouseWheel(delta)
		local range = self:GetRange()
		local current = self.targetPos or self:GetScroll()
		local new = current - delta * self.MouseWheelDelta;

		Scroller:AddFrame(self, Clamp(new, 0, range), self.MouseWheelDelta)
	end

	function CPSmoothScrollMixin:ScrollTo(frac, steps)
		local range = self:GetRange()
		local step = range / steps;
		local new = frac <= 0 and 0 or frac >= steps and range or step * (frac - 1);
		local target = Clamp(new, 0, range)

		Scroller:AddFrame(self, target, step)
		if range > 0 then
			return target / range;
		end
	end

	function CPSmoothScrollMixin:GetElementPosition(element)
		local wrapper = self:GetScrollChild();
		return ClampedPercentageBetween(select(2, element:GetCenter()), wrapper:GetTop(), wrapper:GetBottom())
	end

	function CPSmoothScrollMixin:ScrollToOffset(offset)
		Scroller:AddFrame(self, offset * self:GetRange(), self.MouseWheelDelta)
	end

	function CPSmoothScrollMixin:OnScrollSizeChanged(...)
		if not self.ScrollOrientationSet then return end;
		if (self:GetScroll() > self:GetRange()) then
			self:SetScroll(self:GetRange())
		end
	end
end


---------------------------------------------------------------
-- Specific button catcher with callbacks
---------------------------------------------------------------
do local ModListen = CreateFrame('Frame'); ModListen.Listeners = {};

	function ModListen:OnModifierStateChanged(_, key, down)
		if (down == 1) then
			for _, modifier in db:For('Gamepad/Modsims') do
				if key:match(modifier) then
					self:TriggerModifier(modifier)
				end
			end
		end
	end

	function ModListen:TriggerModifier(modifier)
		for signature, data in pairs(self.Listeners) do
			if (data.modifier == modifier) then
				data.frame:OnGamePadButtonDown(data.emulated)
			end
		end
	end

	function ModListen:GetSignature(frame, modifier)
		return tostring(frame) .. tostring(modifier);
	end

	function ModListen:TryIdle()
		if not next(self.Listeners) then
			self:UnregisterEvent('MODIFIER_STATE_CHANGED')
			self:SetScript('OnEvent', nil)
		end
	end

	function ModListen:RegisterClosure(frame, modifier)
		self.Listeners[self:GetSignature(frame, modifier)] = {
			frame = frame;
			modifier = modifier;
			emulated = GetCVar('GamepadEmulate'..modifier);
		};
		self:RegisterEvent('MODIFIER_STATE_CHANGED')
		self:SetScript('OnEvent', self.OnModifierStateChanged)
	end

	function ModListen:RemoveClosure(frame, modifier)
		self.Listeners[self:GetSignature(frame, modifier)] = nil;
		self:TryIdle()
	end

	function ModListen:RemoveFrame(frame)
		local partial = tostring(frame);
		local signature = next(self.Listeners)
		while signature do
			if signature:match(partial) then
				self.Listeners[signature] = nil;
				signature = nil;
			end
			signature = next(self.Listeners, signature)
		end
		self:TryIdle()
	end

	-----------------------------------------------------------
	-- Mixin
	-----------------------------------------------------------
	CPButtonCatcherMixin = {};

	function CPButtonCatcherMixin:OnLoad()
		self.ClosureRegistry = {};
	end

	function CPButtonCatcherMixin:OnGamePadButtonDown(button)
		if not self.catcherPaused then
			if self.catchAllCallback and self:IsButtonValid(button) then
				self.catchAllCallback(button)
				return self:SetPropagateKeyboardInput(false)
			elseif self.ClosureRegistry[button] then 
				self.ClosureRegistry[button](button)
				return self:SetPropagateKeyboardInput(false)
			end
		end
		self:SetPropagateKeyboardInput(true)
	end

	function CPButtonCatcherMixin:OnHide()
		self:ReleaseClosures()
	end

	function CPButtonCatcherMixin:CatchAll(callback, ...)
		self.catchAllCallback = GenerateClosure(callback, ...)
		for _, modifier in db:For('Gamepad/Modsims') do
			ModListen:RegisterClosure(self, modifier)
		end
	end

	function CPButtonCatcherMixin:CatchButton(button, callback, ...)
		local closure = GenerateClosure(callback, ...)
		self.ClosureRegistry[button] = closure;

		local modifier = db.Gamepad:GetActiveModifier(button)
		if modifier then
			ModListen:RegisterClosure(self, modifier)
		end
		self:EnableGamePadButton(true)
		return closure; -- return the event owner
	end

	function CPButtonCatcherMixin:FreeButton(button, ...)
		if select('#', ...) > 0 then
			local closure = ...;
			if closure and (self.ClosureRegistry[button] ~= closure) then
				return false; -- assert event owner if supplied
			end
		end
		if db.Gamepad:GetActiveModifier(button) then
			ModListen:RemoveClosure(self, button)
		end
		self.ClosureRegistry[button] = nil;
		if not next(self.ClosureRegistry) then
			self:EnableGamePadButton(false)
		end
		return true;
	end

	function CPButtonCatcherMixin:PauseCatcher()
		self.catcherPaused = true;
	end

	function CPButtonCatcherMixin:ResumeCatcher()
		self.catcherPaused = false;
	end

	function CPButtonCatcherMixin:ReleaseClosures()
		ModListen:RemoveFrame(self)
		self.catchAllCallback = nil;
		self:EnableGamePadButton(false)
		if self.ClosureRegistry then
			wipe(self.ClosureRegistry)
		end
	end

	function CPButtonCatcherMixin:IsButtonValid(button)
		return CPAPI.IsButtonValidForBinding(button)
	end
end