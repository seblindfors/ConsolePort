do
local _, L = ...
local UI = ConsolePortUI

local frame = UI:CreateFrame('Frame', _, LootFrame, 'SecureHandlerBaseTemplate, SecureHandlerShowHideTemplate, SecureHandlerStateTemplate', {
	Size = {1, 1},
	Strata = 'HIGH',
	Point = {'CENTER', UIParent, 'CENTER', 100, 0},
	Mixin = L.LootFrameLogicMixin,
	{
		Container = {
			Type = 'Frame',
			Width = 200,
			Point = {'LEFT', '$parent', 'RIGHT', 0, 0},
			SetMovable = true,
			AdjustHeight = function(self, newHeight)
				self:SetScript('OnUpdate', function(self)
					local height = self:GetHeight()
					local diff = newHeight - height
					if abs(newHeight - height) < 0.5 then
						self:SetHeight(newHeight)
						self:SetScript('OnUpdate', nil)
					else
						self:SetHeight(height + ( diff / 5 ) )
					end
				end)
			end,
			{
				Header = {
					Type = 'Frame',
					Setup = {'CPUILootHeaderTemplate'},
					Point = {'BOTTOM', '$parent', 'TOP', 64, -4},
					OnLoad = function(self)
						self.Text:SetText(LOOT)
						self:SetDurationMultiplier(.5)
					end,
				},
			},
		},
	},
})

UI:RegisterFrame(frame, 'Loot', nil, true, true)
UI:HideFrame(LootFrame, true)
end