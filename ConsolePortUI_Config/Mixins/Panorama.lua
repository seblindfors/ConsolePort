local _, L = ...
local Mixin = L.db.table.mixin


L.GetPanoramaFrame = function(name, parent, templates, frame)
	local self = frame or CreateFrame('FRAME', name, parent, templates)
	self.ScrollContainer = CreateFrame('ScrollFrame', '$parentCanvas', self)
	self.ScrollContainer:SetAllPoints()

	self.ScrollContainer.Child = CreateFrame('Frame', '$parentChild', self.ScrollContainer)
	self.ScrollContainer:SetScrollChild(self.ScrollContainer.Child)

	Mixin(self.ScrollContainer, L.CanvasMixin)
	self.ScrollContainer:OnLoad()
	self.ScrollContainer:SetCanvasSize(2000, 700)

	Mixin(self, L.ProviderMixin)
	self:OnLoad()
	self:ZoomOut()

	return self, self.ScrollContainer, self.ScrollContainer.Child
end