local env, db, _, L = CPAPI.GetEnv(...);
---------------------------------------------------------------

---------------------------------------------------------------
-- Guide Panel
---------------------------------------------------------------
local Guide = env:CreatePanel({
	name = GUIDE;
})

function Guide:OnLoad()
	CPAPI.Start(self)
end

function Guide:OnShow()
	self:Render()
end

function Guide:InitCanvas(canvas)
	local t = canvas:CreateTexture(nil, 'BACKGROUND')
	t:SetAllPoints()
	t:SetColorTexture(0, 1, 0, 0.5)
end

function Guide:Render()
	local canvas, newObj = self:GetCanvas(true)
	if newObj then
		self:InitCanvas(canvas)
	end
	canvas:Show()
end