local _, db = ...
---------------------------------------------------------------
ConsolePortMenuSelectMixin = {}
---------------------------------------------------------------
-- NOTE: requires using ConsolePortMenuSelectMixin:SetItemPool.

function ConsolePortMenuSelectMixin:OnLoad()
	self.idx = 1
	if self.OnLoadHook then
		self:OnLoadHook()
	end
end

function ConsolePortMenuSelectMixin:SetItemPool(container, template, mixin, resetterFunc)
	self.itemPool = ConsolePortUI:CreateFramePool('Button', container, template, mixin, resetterFunc)
end

function ConsolePortMenuSelectMixin:OnHide()
	self.idx = 1
	self:ClearFocus()
	if self.OnHideHook then
		self:OnHideHook()
	end
end

function ConsolePortMenuSelectMixin:ClearFocus()
	local button = self.currentFocusButton
	if button and button.OnLeave then
		button:OnLeave()
	end
	self.currentFocusButton = nil
end

function ConsolePortMenuSelectMixin:OnInput(key, down)
	key = tonumber(key)
	if down then
		if ( key == db('KEY/UP') or key == db('KEY/LEFT') ) then
			return self:UpdateFocus(self.idx, -1)
		elseif ( key == db('KEY/DOWN') or key == db('KEY/RIGHT') ) then
			return self:UpdateFocus(self.idx, 1)
		elseif ( key == db('KEY/CROSS') and self.currentFocusButton ) then
			return self.currentFocusButton:Click()
		end
		return self:OnInputPropagate(key)
	end
end

function ConsolePortMenuSelectMixin:OnInputPropagate(key)
	-- override 
end

function ConsolePortMenuSelectMixin:UpdateFocus(index, delta)
	index = (delta and index + delta) or index
	local numActive = self.itemPool.numActiveObjects
	self.idx = index > numActive and numActive or index < 1 and 1 or index
	self:SetFocus(self.idx)
end

function ConsolePortMenuSelectMixin:SetFocus(index)
	self:ClearFocus()
	local button = self.itemPool:GetObjectByIndex(index)
	if button then
		self.currentFocusButton = button
		if button.OnEnter then
			button:OnEnter()
		end
	end
end