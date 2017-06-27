local _, L = ...
local UI = ConsolePortUI
local Mixin = UI.Utils.Mixin

local frame = UI:CreateFrame('Frame', _, UIParent, 'SecureHandlerBaseTemplate, SecureHandlerShowHideTemplate, SecureHandlerStateTemplate', {
	Container = {
		Type = 'Frame',
		Width = 200,
		Point = {'LEFT', '$parent', 'RIGHT', 0, 0},
		{
			Header = {
				Type = 'Frame',
				Setup = {'CPUILootHeaderTemplate'},
				Point = {'BOTTOM', '$parent', 'TOP', 64, -4},
				OnLoad = function(self)
					self.Text:SetText(LOOT)
				end,
			},
		},
	},
})

do  -- loot frame setup
	-------------------------
	frame:Hide()
	frame:SetSize(1, 1)
	frame:SetPoint('CENTER', 100, 0)
	frame:SetFrameStrata('HIGH')

	Mixin(frame, L.LootFrameLogicMixin)

	frame:OnLoad()

	local container = frame.Container
	container:SetMovable(true)
	container.AdjustHeight = function(self, newHeight)
		self:SetScript('OnUpdate', function(self)
			local height = self:GetHeight()
			local diff = newHeight - height
			if abs(newHeight - height) < 0.5 then
				self:SetHeight(newHeight)
				self:SetScript('OnUpdate', nil)
			else
				self:SetHeight(height + ( diff / 10 ) )
			end
		end)
	end

	UI:RegisterFrame(frame, 'Loot', nil, true, true)
	UI:CreateProbe(frame, LootFrame, 'showhide')
	UI:HideFrame(LootFrame)
end