local env, db = CPAPI.GetEnv(...);
local Key, Set = {}, CreateFromMixins(CPFocusPoolMixin, db.Radial.CalcMixin);
env.CharsetMixin = Set;

---------------------------------------------------------------
-- Sets of keys
---------------------------------------------------------------

function Set:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	if self.Arrow then self.Arrow:Hide() end;
	if self.BG then self.BG:Hide() end;
	self:CreateFramePool('CheckButton', 'CPKeyboardChar', Key)
end

function Set:SetData(data)
	self.numSets = #data;
	self:ReleaseAll()
	for i, set in ipairs(data) do
		local widget, newObj = self:Acquire(i)
		if newObj then
			widget:OnLoad()
		end
		local x, y  = self:GetCoordsForIndex(i, self.numSets, 24)
		local angle = self:GetNormalizedAngle(x, y)
		local rot   = -rad(angle - 45) -- offset the texture 45 degrees.
		widget:SetData(set)
		widget:SetPoint('CENTER', x, y)
		widget.Background:SetRotation(rot)
		widget.Ring:SetRotation(rot)
		widget.RingMask:SetRotation(rot)
		widget:Show()
	end
end

function Set:OnStickChanged(x, y, len, valid)
	self:ReflectStickPosition(x, y, len, valid)

	local oldFocusKey = self.focusKey;
	self.focusKey = valid and self.Registry[self:GetIndexForPos(x, y, .5, self.numSets)]
	if oldFocusKey and oldFocusKey ~= self.focusKey then
		oldFocusKey:SetFocus(false, true)
	end
	if self.focusKey then
		self.focusKey:SetFocus(len, true)
	end
end

function Set:SetState(state)
	for widget in self:EnumerateActive() do
		widget:SetState(state)
	end
end

function Set:SetHighlight(enabled)
	for widget in self:EnumerateActive() do
		widget.Ring:SetShown(enabled)
	end
end

function Set:GetKeyByIndex(index)
	return self.Registry[index];
end

---------------------------------------------------------------
-- Individual flyout keys
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

function Key:SetFocus(factor, cancelFlash)
	if cancelFlash then
		self:SetScript('OnUpdate', nil)
	end
	self.Background:SetVertexColor(0, factor or 0, 0, 0.75)
	self:SetScale(1 + (factor or 0) * 0.05)
end

function Key:Flash()
	local factor, focus = 1, 1;
	self:SetScript('OnUpdate', function(self, elapsed)
		factor = Clamp(factor - elapsed, 0, 1)
		focus  = EasingUtil.InCubic(factor)
		self:SetFocus(focus, false)
		if focus <= 0 then
			self:SetFocus(false, true)
		end
	end)
end