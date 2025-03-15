local env = CPAPI.GetEnv(...);
---------------------------------------------------------------
local Search = {}; env.Search = Search;
---------------------------------------------------------------

function Search:OnLoad()
	self.registry = env;
	self:SetScript('OnTextChanged', Search.OnTextChanged)
	self:SetScript('OnEnterPressed', Search.OnEnterPressed)
end

function Search:Debounce()
	self:Cancel()
	self.timer = C_Timer.NewTimer(0.5, function()
		local text = self:GetText()
		if text:len() >= MIN_CHARACTER_SEARCH then
			self.registry:TriggerEvent('OnSearch', text)
		end
	end)
end

function Search:Cancel(dispatch)
	if self.timer then
		self.timer:Cancel()
		self.timer = nil;
		if dispatch then
			self.registry:TriggerEvent('OnSearch', nil)
		end
	end
end

function Search:OnEnterPressed()
	self:ClearFocus()
	if self.timer then
		self.timer:Invoke()
		self.timer:Cancel()
		self.timer = nil;
	end
end

function Search:OnTextChanged(userInput)
	SearchBoxTemplate_OnTextChanged(self)
	local text = self:GetText()
	if not userInput or text:len() < MIN_CHARACTER_SEARCH then
		return self:Cancel(true)
	end
	self:Debounce()
end