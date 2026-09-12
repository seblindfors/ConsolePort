local env, db, _, L = CPAPI.GetEnv(...);
local InCombatLockdown = InCombatLockdown;
---------------------------------------------------------------
-- Input: stick pan/zoom, drill, snap, buttons
---------------------------------------------------------------
-- Mixed into every canvas. The cursor lives in normalized map space;
-- the view centres on it whenever the scroll clamp allows, so it
-- behaves as pan-under-crosshair, and at a map edge the crosshair
-- slides toward the corner instead.
local Input = CreateFromMixins(CPPropagationMixin); env.InputMixin = Input;

local Clamp = Clamp;
local UIHandle = db.UIHandle;

---------------------------------------------------------------
-- Settings
---------------------------------------------------------------
function Input:ReadSettings()
	local panStick  = db.Radial:GetStickStruct(db('mapPanStick'))
	local zoomStick = db.Radial:GetStickStruct(db('mapZoomStick'))
	self.panStick    = panStick and panStick[1] or 'Left';
	self.zoomStick   = zoomStick and zoomStick[1] or 'Right';
	self.cursorSpeed = db('mapCursorSpeed');
	self.zoomSpeed   = db('mapZoomSpeed');
	self.snapRadius  = db('mapSnapRadius');
	self.drillDwell  = db('mapDrillDwell');
	self.buttons = {
		[db('mapAcceptButton')]   = 'Accept';
		[db('mapCancelButton')]   = 'Cancel';
		[db('mapWaypointButton')] = 'Waypoint';
		[db('mapResetButton')]    = 'Reset';
		[db('mapQuestLogButton')] = 'QuestLog';
		[db('mapTrackButton')]    = 'Track';
		PADDUP    = 'Up';
		PADDDOWN  = 'Down';
		PADDLEFT  = 'Left';
		PADDRIGHT = 'Right';
	};
end

---------------------------------------------------------------
-- Cursor
---------------------------------------------------------------
function Input:GetCursor()
	return self.cursor.x, self.cursor.y;
end

function Input:SetCursor(x, y)
	self.cursor.x, self.cursor.y = Clamp(x, 0, 1), Clamp(y, 0, 1);
end

local function GetHalfViewport(sc, scale)
	local halfW, _, halfH = sc:CalculateScrollExtentsAtScale(scale)
	return halfW, halfH;
end

local function ClampPan(tx, ty, halfW, halfH)
	tx = halfW >= 0.5 and 0.5 or Clamp(tx, halfW, 1 - halfW)
	ty = halfH >= 0.5 and 0.5 or Clamp(ty, halfH, 1 - halfH)
	return tx, ty;
end

function Input:UpdateCrosshair()
	local crosshair = self.Crosshair;
	if not crosshair then return end
	local sc = self.ScrollContainer;
	if not sc.zoomLevels then return end
	local scale = sc:GetCanvasScale()
	local viewX, viewY = sc:GetNormalizedHorizontalScroll(), sc:GetNormalizedVerticalScroll()
	local w, h = sc.Child:GetWidth() * scale, sc.Child:GetHeight() * scale;
	crosshair:SetPoint('CENTER', sc, 'CENTER', (self.cursor.x - viewX) * w, (viewY - self.cursor.y) * h)
end

---------------------------------------------------------------
-- Focus
---------------------------------------------------------------
function Input:SetFocusPin(pin)
	local old = self.focusPin;
	if old == pin then return end
	if old then
		env.Adapters:HideTooltip()
	end
	self.focusPin = pin;
	if pin then
		env.Adapters:ShowTooltip(pin, self.Crosshair)
		if pin.UpdateTooltip ~= pin.cpUpdateTooltip then
			pin.UpdateTooltip = pin.cpUpdateTooltip;
		end
	end
	self:UpdateHints()
end

function Input:FindNearbyPin()
	local sc, cur = self.ScrollContainer, self.cursor;
	local scale = sc:GetCanvasScale()
	local w, h = sc.Child:GetWidth() * scale, sc.Child:GetHeight() * scale;
	local best, bestDist = nil, self.snapRadius;
	for pin in self:EnumeratePins() do
		if self:IsPinFocusable(pin) then
			local dx, dy = (pin.normalizedX - cur.x) * w, (pin.normalizedY - cur.y) * h;
			local dist = math.sqrt(dx * dx + dy * dy)
			if dist < bestDist then
				best, bestDist = pin, dist;
			end
		end
	end
	return best;
end

function Input:SnapToPin(dx, dy)
	local cx, cy = self:GetCursor()
	local best, bestScore;
	for pin in self:EnumeratePins() do
		if self:IsPinFocusable(pin) and pin ~= self.focusPin then
			local px, py = pin.normalizedX - cx, cy - pin.normalizedY;
			local dist = math.sqrt(px * px + py * py)
			if dist > 0.0005 then
				local dot = (px * dx + py * dy) / dist;
				if dot > 0.5 then
					local score = dist / dot;
					if not bestScore or score < bestScore then
						best, bestScore = pin, score;
					end
				end
			end
		end
	end
	if best then
		self:SetCursor(best.normalizedX, best.normalizedY)
		self:SetFocusPin(best)
		return true;
	end
	return false;
end

---------------------------------------------------------------
-- Navigation
---------------------------------------------------------------
local function GetLayerWidth(mapID)
	local layers = C_Map.GetMapArtLayers(mapID)
	return layers and layers[1] and layers[1].layerWidth;
end

function Input:SetContinuousView(scale, x, y)
	local sc = self.ScrollContainer;
	self:SetCursor(x, y)
	sc:InstantPanAndZoom(Clamp(scale, sc:GetScaleForMinZoom(), sc:GetScaleForMaxZoom()), x, y, true)
end

function Input:NavigateTo(mapID)
	if not C_Map.GetMapArtLayers(mapID) then return false end
	self:SetFocusPin(nil)
	self:SetMapID(mapID)
	self:SetCursor(0.5, 0.5)
	self.ScrollContainer:SetPanTarget(0.5, 0.5)
	env:TriggerEvent('OnMapChanged', mapID)
	return true;
end

function Input:DrillIn()
	local parentID = self:GetMapID()
	local x, y = self:GetCursor()
	local info = C_Map.GetMapInfoAtPosition(parentID, x, y)
	if not info or info.mapID == parentID then return false end
	local childID = info.mapID;
	local parentWidth, childWidth = GetLayerWidth(parentID), GetLayerWidth(childID)
	if not childWidth then return false end

	local sc = self.ScrollContainer;
	local scale = sc:GetCanvasScale()
	local minX, maxX, minY, maxY = C_Map.GetMapRectOnMap(childID, parentID)
	self:SetFocusPin(nil)
	self:SetMapID(childID)
	if minX and maxX > minX and maxY > minY then
		self:SetContinuousView(scale * parentWidth * (maxX - minX) / childWidth,
			(x - minX) / (maxX - minX), (y - minY) / (maxY - minY))
	end
	env:TriggerEvent('OnMapChanged', childID)
	return true;
end

function Input:DrillOut()
	local childID = self:GetMapID()
	local info = C_Map.GetMapInfo(childID)
	local parentID = info and info.parentMapID;
	if not parentID or parentID <= 0 then return false end
	local parentWidth, childWidth = GetLayerWidth(parentID), GetLayerWidth(childID)
	if not parentWidth then return false end

	local sc = self.ScrollContainer;
	local scale = sc:GetCanvasScale()
	local x, y = self:GetCursor()
	local minX, maxX, minY, maxY = C_Map.GetMapRectOnMap(childID, parentID)
	self:SetFocusPin(nil)
	self:SetMapID(parentID)
	if minX and maxX > minX and maxY > minY then
		self:SetContinuousView(scale * childWidth / (parentWidth * (maxX - minX)),
			minX + x * (maxX - minX), minY + y * (maxY - minY))
	end
	env:TriggerEvent('OnMapChanged', parentID)
	return true;
end

function Input:OpenOnMap(mapID, centerOnPlayer)
	if not mapID or not C_Map.GetMapArtLayers(mapID) then return false end
	self:SetFocusPin(nil)
	self:SetMapID(mapID)
	self:Show()
	local x, y = 0.5, 0.5;
	local pos = centerOnPlayer and C_Map.GetPlayerMapPosition(mapID, 'player')
	if pos then x, y = pos:GetXY() end
	self:SetCursor(x, y)
	self.ScrollContainer:SetPanTarget(x, y)
	env:TriggerEvent('OnMapChanged', mapID)
	return true;
end

function Input:PanToPosition(x, y)
	self:SetCursor(x, y)
	self.ScrollContainer:SetPanTarget(x, y)
end

function Input:ResetView()
	self.ScrollContainer:ResetZoom()
	local pos = C_Map.GetPlayerMapPosition(self:GetMapID(), 'player')
	if pos then
		self:PanToPosition(pos:GetXY())
	else
		self:PanToPosition(0.5, 0.5)
	end
	self:SetFocusPin(nil)
end

---------------------------------------------------------------
-- Waypoints
---------------------------------------------------------------
function Input:ToggleWaypoint()
	if not C_Map.SetUserWaypoint then return false end
	local mapID = self:GetMapID()
	local pin = self.focusPin;
	if pin and pin.pinTemplate == 'WaypointLocationPinTemplate' then
		C_Map.ClearUserWaypoint()
		return true;
	end
	if C_Map.CanSetUserWaypointOnMap(mapID) then
		local x, y = self:GetCursor()
		C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(mapID, x, y))
		if C_SuperTrack then
			C_SuperTrack.SetSuperTrackedUserWaypoint(true)
		end
		return true;
	end
	return false;
end

---------------------------------------------------------------
-- Per-frame stick handling
---------------------------------------------------------------
function Input:OnInputUpdate(elapsed)
	local sc, sticks, cur = self.ScrollContainer, self.sticks, self.cursor;
	if not sc.zoomLevels then return end

	local scale = sc.targetScale or sc:GetCanvasScale()
	local halfW, halfH = GetHalfViewport(sc, scale)

	local pan = sticks[self.panStick];
	local moving = pan and (pan.x * pan.x + pan.y * pan.y) > (env.Const.Deadzone ^ 2);
	if moving then
		self:SetCursor(
			cur.x + pan.x * self.cursorSpeed * 2 * halfW * elapsed,
			cur.y - pan.y * self.cursorSpeed * 2 * halfH * elapsed)
		if self.focusPin then self:SetFocusPin(nil) end
	elseif self.wasMoving then
		local pin = self:FindNearbyPin()
		if pin then
			self:SetCursor(pin.normalizedX, pin.normalizedY)
			self:SetFocusPin(pin)
		end
	end
	self.wasMoving = moving;

	local zoom = sticks[self.zoomStick];
	local ry = zoom and zoom.y or 0;
	if math.abs(ry) > env.Const.Deadzone then
		local newScale = Clamp(scale * (1 + ry * self.zoomSpeed * elapsed), sc:GetScaleForMinZoom(), sc:GetScaleForMaxZoom())
		sc:SetZoomTarget(newScale)
		scale = newScale;
		halfW, halfH = GetHalfViewport(sc, scale)

		local atMax = scale >= sc:GetScaleForMaxZoom() - 1e-6;
		local atMin = scale <= sc:GetScaleForMinZoom() + 1e-6;
		if (ry > env.Const.DrillTrigger and atMax) or (ry < -env.Const.DrillTrigger and atMin) then
			self.dwell = self.dwell + elapsed;
			if self.dwell >= self.drillDwell then
				self.dwell = -math.huge;
				if ry > 0 then self:DrillIn() else self:DrillOut() end
				return
			end
		else
			self.dwell = 0;
		end
	else
		self.dwell = 0;
	end

	sc:SetPanTarget(ClampPan(cur.x, cur.y, halfW, halfH))
	self:UpdateCrosshair()
end

function Input:OnGamePadStick(stick, x, y, len)
	local state = self.sticks[stick];
	if state then
		state.x, state.y = x, y;
	end
	self:SetPropagation(false)
end

---------------------------------------------------------------
-- Buttons
---------------------------------------------------------------
local Commands = {};

function Commands.Accept(self)
	local pin = self.focusPin;
	if pin and env.Adapters:Get(pin).Primary(pin, self) then
		return
	end
	self:DrillIn()
end

function Commands.Cancel(self)
	if not self:DrillOut() then
		if self.OnClose then self:OnClose() else self:Hide() end
	end
end

function Commands.Waypoint(self)
	self:ToggleWaypoint()
end

function Commands.Reset(self)
	self:ResetView()
end

function Commands.QuestLog(self)
	env:TriggerEvent('OnToggleQuestLogFocus')
end

function Commands.Track(self)
	local pin = self.focusPin;
	if pin then
		env.Adapters:Get(pin).Secondary(pin, self)
	end
end

function Commands.Up(self)    self:SnapToPin( 0,  1) end
function Commands.Down(self)  self:SnapToPin( 0, -1) end
function Commands.Left(self)  self:SnapToPin(-1,  0) end
function Commands.Right(self) self:SnapToPin( 1,  0) end

function Input:OnGamePadButtonDown(button)
	if db.Input:IsOverrideActive(CPAPI.CreateKeyChord(button)) then
		return self:SetPropagation(true)
	end
	self:SetPropagation(false)
	if self.buttonSink and self.buttonSink(button) then
		return
	end
	local command = self.buttons[button];
	if command and Commands[command] then
		Commands[command](self)
	end
end

function Input:SetButtonSink(sink)
	self.buttonSink = sink;
end

---------------------------------------------------------------
-- Hints
---------------------------------------------------------------
function Input:UpdateHints()
	if not UIHandle:IsHintFocus(env.Map) or self.buttonSink then return end
	local pin = self.focusPin;
	local adapter = pin and env.Adapters:Get(pin)
	local acceptLabel = adapter and adapter.Label(pin) or L'Zoom In';
	UIHandle:AddHint(db('mapAcceptButton'), acceptLabel)
	UIHandle:AddHint(db('mapCancelButton'), self:CanDrillOut() and L'Zoom Out' or CLOSE)
	UIHandle:AddHint(db('mapWaypointButton'), L'Waypoint')
	if self.kind == 'World' and db('mapShowQuestLog') then
		UIHandle:AddHint(db('mapQuestLogButton'), QUEST_LOG)
	end
	if pin and pin.questID then
		UIHandle:AddHint(db('mapTrackButton'), L'Track')
	else
		UIHandle:RemoveHint(db('mapTrackButton'))
	end
end

function Input:CanDrillOut()
	local info = C_Map.GetMapInfo(self:GetMapID() or 0)
	return info and info.parentMapID and info.parentMapID > 0 and C_Map.GetMapArtLayers(info.parentMapID) ~= nil;
end

---------------------------------------------------------------
-- Lifecycle hooks (called from CanvasMixin)
---------------------------------------------------------------
function Input:OnInputShow()
	self:ReadSettings()
	self:EnableGamePadStick(true)
	self:EnableGamePadButton(true)
	self:SetPropagation(false)
	self.dwell = 0;
	self.wasMoving = false;
	self:UpdateHints()
end

function Input:OnInputHide()
	self:EnableGamePadStick(false)
	self:EnableGamePadButton(false)
	for _, state in pairs(self.sticks) do
		state.x, state.y = 0, 0;
	end
	self:SetFocusPin(nil)
end

function Input:InitInput(crosshair)
	self.cursor = { x = 0.5, y = 0.5 };
	self.sticks = {
		Left  = { x = 0, y = 0 };
		Right = { x = 0, y = 0 };
		Gyro  = { x = 0, y = 0 };
	};
	self.dwell = 0;
	self.Crosshair = crosshair;
	self:ReadSettings()
	self:SetScript('OnGamePadStick', self.OnGamePadStick)
	self:SetScript('OnGamePadButtonDown', self.OnGamePadButtonDown)
end
