local _, env = ...; local db = env.db;
---------------------------------------------------------------
-- Mover
---------------------------------------------------------------
local Mover = {};
env.Movers = CreateFramePool('Frame', env.bar);

local function FadeConfig(func, time, toAlpha)
	local config = env.config and env.config.Config;
	if config then
		func(config, time, config:GetAlpha(), toAlpha)
	end
end

function Mover:OnDragStart()
	local button = self.button;
	button:SetClampedToScreen(true)
	button:SetMovable(true)
	button:StartMoving()
	FadeConfig(env.db.Alpha.FadeOut, 0.25, 0)
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	self:SetScript('OnEvent', self.OnDragStop)
end

function Mover:OnDragStop()
	local button = self.button;
	button:StopMovingOrSizing()
	button:SetMovable(false)
	button:SetClampedToScreen(false)
	FadeConfig(env.db.Alpha.FadeIn, 0.25, 1)
	self:UnregisterAllEvents()
	self:SetScript('OnEvent', nil)

	local layout = env:Get('layout')
	local barX, barY = env.bar:GetCenter()
	local point, x, y = 'CENTER', button:GetCenter()

	layout[button.plainID].point = {point, floor(x - barX), floor(y - barY)};
	env:Set('layout', layout)
end

function Mover:OnUpdate()
	if not self.cluster then return end;
	for modifier, button in pairs(self.cluster) do
		local texture = self[modifier] or self:CreateTexture(nil, 'OVERLAY')
		local hilite = button:GetHighlightTexture();
		texture:SetAllPoints(hilite)
		texture:SetTexture(hilite:GetTexture())
		texture:SetRotation(hilite:GetRotation())
		texture:SetTexCoord(hilite:GetTexCoord())

		self[modifier] = texture;
	end
end

function Mover:SetCluster(target)
	local button = target[''];
	self.cluster = target;
	self.button  = button;
	self:SetAllPoints(button)
	self:SetFrameLevel(button:GetFrameLevel() + 1)
end

function Mover:OnLoad()
	self:RegisterForDrag('LeftButton')
	self:EnableMouse(true)
	self:SetIgnoreParentAlpha(true)
end

---------------------------------------------------------------
-- API
---------------------------------------------------------------
function env:ShowMovers()
	self.Movers:ReleaseAll()
	local mixer = self.db.table.mixin;
	for i, cluster in ipairs(self.bar.Buttons) do
		local mover, newObj = self.Movers:Acquire()
		if newObj then
			mixer(mover, Mover)
			mover:OnLoad()
		end
		mover:Show()
		mover:SetCluster(cluster)
	end
end

function env:HideMovers()
	self.Movers:ReleaseAll()
end

db:RegisterCallback('EditMode.Enter', env.ShowMovers, env)
db:RegisterCallback('EditMode.Exit', env.HideMovers, env)