PowerLevelMixin = {}

function PowerLevelMixin:OnLoad()
	self:RegisterForDrag('LeftButton')
end

function PowerLevelMixin:OnEnter()
      GameTooltip_SetDefaultAnchor(GameTooltip, self)
      GameTooltip:AddLine('Hold Shift + Left Click to move.')
		GameTooltip:Show()
end

function PowerLevelMixin:OnLeave()
   if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function PowerLevelMixin:OnDragStart()
   if IsShiftKeyDown() then
      self:StartMoving()
   end
end

function PowerLevelMixin:OnDragStop()
   self:StopMovingOrSizing()
end