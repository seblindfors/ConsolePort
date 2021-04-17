local Radial, Fader, _, env = ConsolePortRadial, ConsolePort:DB('Alpha/Fader'), ...;
local Key, Charset = {}, {}; env.CharsetMixin = Charset;

---------------------------------------------------------------
--
---------------------------------------------------------------

function Charset:OnLoad()
	self.BG:ClearAllPoints()
	self.BG:SetPoint('TOPLEFT', -10, 10)
	self.BG:SetPoint('BOTTOMRIGHT', 10, -10)
	self.Arrow:SetSize(50*0.52, 400*0.52)
	self.Arrow:SetDrawLayer('ARTWORK')
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
	self.focusKey = valid and self.Registry[Radial:GetIndexForStickPosition(x, y, .5, self.numSets)]
	if oldFocusKey and oldFocusKey ~= self.focusKey then
		oldFocusKey:SetFocus(false)
	end
	if self.focusKey then
		self.focusKey:SetFocus(len)
	end
end

function Charset:SetState(state)
	for widget in self:EnumerateActive() do
		widget:SetState(state)
	end
end

function Charset:SetHighlight(enabled)
	Fader.Toggle(self.Ring, .05, enabled)
end

---------------------------------------------------------------
--
---------------------------------------------------------------

function Key:OnLoad()
	self.Background:SetVertexColor(0, 0, 0, 0.75)
end

function Key:SetData(data)
	self.data = data;
end

function Key:GetText()
	return self.content;
end

function Key:SetState(state)
	self.content = self.data[state];
	self.Text:SetText(env:GetText(self.content))
end

function Key:SetFocus(enabled)
	self.Background:SetVertexColor(0, enabled or 0, 0, 0.75)
end

function Key:Flash()
	Fader.Out(self.Ring, .35, 1, 0)
end