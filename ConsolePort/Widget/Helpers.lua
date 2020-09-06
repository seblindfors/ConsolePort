CPFocusPoolMixin = {};

function CPFocusPoolMixin:OnPreLoad()
	self.Registry = {};
end

function CPFocusPoolMixin:OnPostHide()
	self.focusIndex = nil;
end

function CPFocusPoolMixin:CreateFramePool(type, template, mixin, resetterFunc)
	assert(not self.FramePool, 'Frame pool already exists.')
	self.FramePool = CreateFramePool(type, self, template, resetterFunc)
	self.FramePoolMixin = mixin;
	return self.FramePool;
end

function CPFocusPoolMixin:Acquire(index)
	local widget, newObj = self.FramePool:Acquire()
	if newObj then
		Mixin(widget, self.FramePoolMixin)
	end
	self.Registry[index] = widget;
	return widget, newObj;
end

function CPFocusPoolMixin:GetNumActive()
	return self.FramePool:GetNumActive()
end

function CPFocusPoolMixin:ReleaseAll()
	self.FramePool:ReleaseAll()
end

function CPFocusPoolMixin:SetFocusByIndex(index)
	local old = self.focusIndex ~= index and self.focusIndex;
	self.focusIndex = index;

	local oldObj = old and self.Registry[old];
	local newObj = self.Registry[index];
	return newObj, oldObj;
end

function CPFocusPoolMixin:SetFocusByWidget(widget)
	return self:SetFocusByIndex(tIndexOf(self.Registry, widget))
end