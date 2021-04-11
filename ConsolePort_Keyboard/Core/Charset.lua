local Radial, _, env = ConsolePortRadial, ...;
local Key, Charset = {}, {}; env.CharsetMixin = Charset;

---------------------------------------------------------------
--
---------------------------------------------------------------

function Charset:OnLoad()
	self.BG:ClearAllPoints()
	self.BG:SetPoint('TOPLEFT', -10, 10)
	self.BG:SetPoint('BOTTOMRIGHT', 10, -10)
	self.Arrow:SetSize(50*0.52, 400*0.52)
	self.Background:SetVertexColor(0, 0, 0, .25)
	self:CreateFramePool('ConsolePortKeyboardChar', Key)
end

function Charset:SetData(data)
	self.numSets = #data;
	self:ReleaseAll()
	for i, set in ipairs(data) do
		local widget, newObj = self:Acquire(i)
		if newObj then
			widget:OnLoad()
		end
		widget:SetData(set)
		widget:SetPoint('CENTER', Radial:GetPointForIndex(i, self.numSets, 40))
		widget:Show()
	end
end

function Charset:OnStickChanged(x, y, len, valid)
	self:ReflectStickPosition(x, y, len, valid)

	local oldFocusKey = self.focusKey;
	self.focusKey = valid and self.Registry[Radial:GetIndexForStickPosition(x, y, len, self.numSets)]
	if oldFocusKey and oldFocusKey ~= self.focusKey then
		oldFocusKey:SetFocus(false)
	end
	if self.focusKey then
		self.focusKey:SetFocus(true)
	end
end

function Charset:SetState(state)
	for widget in self:EnumerateActive() do
		widget:SetState(state)
	end
end

---------------------------------------------------------------
--
---------------------------------------------------------------

function Key:OnLoad()
	self.Background:SetVertexColor(0, 0, 0, 0.5)
end

function Key:SetData(data)
	self.data = data;
end

function Key:GetText()
	return self.Text:GetText()
end

function Key:SetState(state)
	self.Text:SetText(self.data[state])
end

function Key:SetFocus(enabled)
	self.Background:SetVertexColor(0, enabled and 0.5 or 0, 0, 0.5)
end