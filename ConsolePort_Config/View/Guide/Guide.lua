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

function Guide:OnHide()
	self:ClearContent()
end

function Guide:InitCanvas(canvas)
	self.canvas = canvas;
end

function Guide:Render()
	local canvas, newObj = self:GetCanvas(true)
	if newObj then
		self:InitCanvas(canvas)
	end
	canvas:Show()
	self:AutoSelectContent()
end

function Guide:AutoSelectContent()
	for _, content in ipairs(self.content) do
		if content.predicate() then
			return self:SetContent(content)
		end
	end
	return false;
end

function Guide:SetContent(content)
	self.resetter = content.resetter;
	content.initializer(self.canvas)
	return true;
end

function Guide:ClearContent()
	if self.resetter then
		self.resetter(self.canvas);
		self.resetter = nil;
	end
end

function Guide:AddContent(predicate, initializer, resetter)
	tinsert(self.content, {
		initializer = initializer;
		predicate   = predicate;
		resetter    = resetter or nop;
	})
end