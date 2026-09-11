local env, db, _, L = CPAPI.GetEnv(...);
local InCombatLockdown = InCombatLockdown;
---------------------------------------------------------------
-- Map window
---------------------------------------------------------------
-- Owns the two canvases (world, flight), the crosshair, the quest log
-- panel and the hint bar focus. Canvases are created on first use,
-- after the Blizzard map addons have been loaded on demand.
local Map = CPAPI.EventHandler(ConsolePortMap, {
	'PLAYER_REGEN_DISABLED';
	'PLAYER_REGEN_ENABLED';
}); env.Map = Map;

local UIHandle = db.UIHandle;

---------------------------------------------------------------
-- Canvases
---------------------------------------------------------------
function Map:GetCanvas(kind)
	local key = kind..'Canvas';
	if self[key] then return self[key] end
	if not env:LoadBlizzardMap() then return end
	if kind == 'Flight' then
		local loaded = CPAPI.LoadAddOn('Blizzard_FlightMap')
		if not loaded then return end
	end
	local canvas = env:CreateCanvas('ConsolePortMap'..kind..'Canvas', self.CanvasArea, env.Providers[kind], env.InputMixin)
	canvas:InitInput(self.Crosshair)
	canvas.kind = kind;
	canvas.OnClose = function() self:CloseCanvas(canvas) end;
	self[key] = canvas;
	return canvas;
end

function Map:GetActiveCanvas()
	return self.activeCanvas;
end

function Map:ShowCanvas(canvas)
	if self.activeCanvas and self.activeCanvas ~= canvas then
		self.activeCanvas:Hide()
	end
	self.activeCanvas = canvas;
	return canvas;
end

function Map:CloseCanvas(canvas)
	if canvas.kind == 'Flight' and CloseTaxiMap then
		CloseTaxiMap()
	end
	self:Hide()
end

---------------------------------------------------------------
-- Opening
---------------------------------------------------------------
function Map:Open(kind, mapID, centerOnPlayer)
	local canvas = self:GetCanvas(kind or 'World')
	if not canvas then return false end
	self:ShowCanvas(canvas)
	self:Show()
	if not canvas:OpenOnMap(mapID, centerOnPlayer) then
		self:Hide()
		return false;
	end
	self:SetTitle(mapID)
	return true;
end

function Map:OpenPlayerMap()
	local mapID = MapUtil.GetDisplayableMapForPlayer()
	return self:Open('World', mapID, true)
end

function Map:Toggle()
	if self:IsShown() then
		self:Hide()
	else
		self:OpenPlayerMap()
	end
end

function Map:SetTitle(mapID)
	local info = mapID and C_Map.GetMapInfo(mapID)
	self.Title:SetText(info and info.name or WORLD_MAP)
end

---------------------------------------------------------------
-- Quest log focus
---------------------------------------------------------------
function Map:SetQuestLogFocus(hasFocus)
	local canvas = self.activeCanvas;
	if not canvas then return end
	if not db('mapShowQuestLog') or canvas.kind ~= 'World' then
		hasFocus = false;
	end
	self.questLogFocus = hasFocus;
	self.QuestLog:SetFocus(hasFocus)
	if hasFocus then
		UIHandle:ClearHintsForFrame(self)
		canvas:SetButtonSink(function(button)
			if button == db('mapCancelButton') then
				self:SetQuestLogFocus(false)
				return true;
			end
			return self.QuestLog:HandleButton(button)
		end)
		self.QuestLog:UpdateHints()
	else
		canvas:SetButtonSink(nil)
		UIHandle:ClearHintsForFrame(self)
		canvas:UpdateHints()
	end
	self.Crosshair:SetAlpha(hasFocus and 0.4 or 1)
end

function Map:ToggleQuestLogFocus()
	self:SetQuestLogFocus(not self.questLogFocus)
end

function Map:UpdateQuestLogVisibility()
	local show = db('mapShowQuestLog') and self.activeCanvas and self.activeCanvas.kind == 'World';
	self.QuestLog:SetShown(show)
	if not show then
		self:SetQuestLogFocus(false)
	end
end

---------------------------------------------------------------
-- Scripts
---------------------------------------------------------------
function Map:OnShow()
	UIHandle:SetHintFocus(self)
	self:UpdateQuestLogVisibility()
	self:UpdateStatus()
	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN)
end

function Map:OnHide()
	if self.activeCanvas then
		self.activeCanvas:Hide()
		if self.activeCanvas.kind == 'Flight' and CloseTaxiMap then
			CloseTaxiMap()
		end
	end
	self:SetQuestLogFocus(false)
	if UIHandle:IsHintFocus(self) then
		UIHandle:HideHintBar()
	end
	UIHandle:ClearHintsForFrame(self)
	PlaySound(SOUNDKIT.IG_QUEST_LOG_CLOSE)
end

function Map:UpdateStatus()
	if InCombatLockdown() then
		self.Status:SetText(L'Map data is frozen while in combat.')
	else
		self.Status:SetText('')
	end
end

function Map:PLAYER_REGEN_DISABLED() self:UpdateStatus() end
function Map:PLAYER_REGEN_ENABLED()  self:UpdateStatus() end

function Map:OnMapChanged(mapID)
	self:SetTitle(mapID)
end

function Map:OnDataLoaded()
	self:SetScale(db('mapScale'))
	self:SetSize(env.Const.Width, env.Const.Height)
	self.QuestLog:SetWidth(env.Const.QuestLogWidth)
	db:RegisterCallback('Settings/mapScale', function(_, value) self:SetScale(value) end, self)
	db:RegisterCallback('Settings/mapShowQuestLog', self.UpdateQuestLogVisibility, self)
	env:RegisterCallback('OnToggleQuestLogFocus', self.ToggleQuestLogFocus, self)
	env:RegisterCallback('OnMapChanged', self.OnMapChanged, self)
	return CPAPI.BurnAfterReading;
end

Mixin(Map.QuestLog, env.QuestLogPanelMixin)
Map.QuestLog:OnLoad()
Map.QuestLog:SetScript('OnShow', Map.QuestLog.OnShow)
Map:SetScript('OnShow', Map.OnShow)
Map:SetScript('OnHide', Map.OnHide)

ConsolePortMapToggle:SetScript('OnClick', function(_, _, down)
	if down then Map:Toggle() end
end)
ConsolePortMapToggle:RegisterForClicks('AnyUp', 'AnyDown')
