---------------------------------------------------------------
-- Scroll management
---------------------------------------------------------------
local Scroll, Node, Clamp =
	CreateFrame('Frame', '$parentUIScrollHandler', ConsolePort),
	LibStub('ConsolePortNode'),
	Clamp;

function Scroll:OnUpdate(elapsed)
	for super, target in pairs(self.Active) do
		local currHorz, currVert = super:GetHorizontalScroll(), super:GetVerticalScroll()
		local maxHorz, maxVert = super:GetHorizontalScrollRange(), super:GetVerticalScrollRange()
		-- close enough, stop scrolling and set to target
		if ( abs(currHorz - target.horz) < 2 ) and ( abs(currVert - target.vert) < 2 ) then
			super:SetVerticalScroll(target.vert)
			super:SetHorizontalScroll(target.horz)
			self.Active[super] = nil
			return
		end
		local deltaX, deltaY = ( currHorz > target.horz and -1 or 1 ), ( currVert > target.vert and -1 or 1 )
		local newX = ( currHorz + (deltaX * abs(currHorz - target.horz) / 16 * 4) )
		local newY = ( currVert + (deltaY * abs(currVert - target.vert) / 16 * 4) )

		super:SetVerticalScroll(Clamp(newY, 0, maxVert))
		super:SetHorizontalScroll(Clamp(newX, 0, maxHorz))
	end
	if not next(self.Active) then
		self:SetScript('OnUpdate', nil)
	end
end

function Scroll:To(node, super, prev, force)
	local nodeX, nodeY = Node.GetCenter(node)
	local scrollX, scrollY = super:GetCenter()
	if nodeY and scrollY then

		if self:IsValidScrollFrame(super) then
			local currHorz, currVert = super:GetHorizontalScroll(), super:GetVerticalScroll()
			local maxHorz, maxVert = super:GetHorizontalScrollRange(), super:GetVerticalScrollRange()

			local prevX, prevY = nodeX, nodeY;
			if prev then
				prevX, prevY = Node.GetCenter(prev)
			end

			if not self.Active then
				self.Active = {}
			end

			self.Active[super] = {
				vert = Clamp(self:GetScrollTarget(currVert, scrollY, nodeY, prevY, force), 0, maxVert),
				horz = Clamp(0, 0, maxHorz), -- TODO: solve horizontal scrolling
			}

			self:SetScript('OnUpdate', self.OnUpdate)
		end
	end
end

function Scroll:GetScrollTarget(curr, scrollPos, nodePos, prevPos, force)
	local new = curr + (scrollPos - nodePos)
	return force and new or (new > curr) == (nodePos > prevPos) and curr or new;
end

function Scroll:IsValidScrollFrame(super)
	-- HACK: make sure this isn't a hybrid scroll frame
	return super:IsObjectType('ScrollFrame') and
		super:GetScript('OnLoad') ~= HybridScrollFrame_OnLoad;
end
