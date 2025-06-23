local env, db, _, L = CPAPI.GetEnv(...);
---------------------------------------------------------------

---------------------------------------------------------------
-- Guide Panel
---------------------------------------------------------------
local Guide = env:CreatePanel({
	name    = GUIDE;
	content = {};
})

function Guide:OnLoad()
	CPAPI.Start(self)
end

function Guide:OnShow()
	self:Render()
end

function Guide:InitCanvas(canvas)
end

function Guide:Render()
	local canvas, newObj = self:GetCanvas(true)
	if newObj then
		self:InitCanvas(canvas)
	end
	canvas:Show()
	self:AutoSelectContent(canvas)
end

function Guide:AutoSelectContent(canvas)
	for _, content in ipairs(self.content) do
		if content.predicate() then
			content.initializer(canvas)
			return true;
		end
	end
	return false;
end

function Guide:AddContent(predicate, initializer, resetter)
	tinsert(self.content, {
		initializer = initializer;
		predicate   = predicate;
		resetter    = resetter or nop;
	})
end