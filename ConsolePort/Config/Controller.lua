---------------------------------------------------------------
-- <<<>>>
---------------------------------------------------------------
local _, db = ...
---------------------------------------------------------------
		-- Locale, WindowMixin
local 	L, W, B,
		-- Texture paths, grid layout
		PATH, POINTS, BASE_Y, BASE_INSET, CUSTOM_DESC =
		-------------------------------------
		db.TUTORIAL.SETUP, {}, {}
---------------------------------------------------------------
-- Button
function B:SetPosition(settings, indexModifier)
	local 	position, textPoint, hitRects = 
			settings.position, settings.textPoint, settings.hitRects

	local anchor, xOffset, yOffset = unpack(position)
	yOffset = ( ( indexModifier - 1 ) * BASE_Y ) + BASE_INSET
	self:SetPoint(anchor, xOffset, yOffset)

	self:SetHitRectInsets(unpack(hitRects or {0, 0, 0, 0}))

	if textPoint then
		local point, relativePoint, xOffset, yOffset = unpack(textPoint)
		self.Text:SetPoint(point, self, relativePoint, xOffset, yOffset)
	end
end

function B:SetButton(controller, id)
	self.Icon:SetTexture(ICON_PATH:format(controller, id))
	self.isTrigger = ( id:match('CP_T%a%d') or id:match('CP_._GRIP') ) and true
	self.id = id
	local custom = CUSTOM_DESC[id]
	if custom then
		self.Text:SetText(custom)
		self.ignore = true
	else
		self.ignore = false
		local key = db.Settings.calibration and db.Settings.calibration[id]
		if key then
			self.Text:SetText(GetBindingText(key))
		end
	end
end


-- Window
function W:SetController(controller)
	self.Controller.Texture:SetTexture(CTRL_PATH:format(controller, 'Front'))
	self.Overlay.Lines:SetTexture(CTRL_PATH:format(controller, 'Overlay'))
	self.layout = db.table.copy(db.Controllers[controller].Layout)

	self.Active = 0
	for _, button in pairs(self.Overlay.Buttons) do
		button:ClearAllPoints()
		button:Hide()
	end

	if self.layout then
		for id, info in pairs(self.layout) do
			local button = self:GetButtonFromPool()
			button:SetPosition(POINTS[info.anchor], info.index)
			button:SetButton(controller, id)
		end
	else
		-- special case when there is no layout ?
	end
end

function W:GetButtonFromPool()
	self.Active = self.Active + 1
	local button = self.Overlay.Buttons[self.Active]
	if not button then
		button = CreateFrame('Button', nil, self.Overlay)
		button:SetSize(38, 38)
		
		button.Rim 	= button:CreateTexture(nil, 'BACKGROUND', nil, -1)
		button.Icon = button:CreateTexture(nil, 'BACKGROUND', nil, 0)

		button.Icon:SetSize(38, 38)
		button.Icon:SetPoint('CENTER')
		button.Text = button:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')

		button:SetPushedTexture("Interface\\AddOns\\ConsolePort\\Textures\\IconMask")

		button.Rim:SetSize(46, 46)
		button.Rim:SetPoint('CENTER', 0, 0)
		button.Rim:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\IconMask64")

		db.table.mixin(button, B)

		self.Overlay.Buttons[self.Active] = button
	end
	button:ClearAllPoints()
	button:Show()
	return button
end

function W:OnShow()
	local cType = self.cType or db.Settings.type
	self:SetController(cType)
end

db.PANELS[#db.PANELS + 1] = {
	name = 'Calib', 
	header  = 'Calibration', 
	mixin = W,
	noDefault = true,
	onFirstShow = function(self, core)
		local settings = db.Settings
		local cc = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

		self.Active = 0

		self.Controller = CreateFrame("Frame", "$parentController", self)
		self.Controller:SetPoint("CENTER", 0, 0)
		self.Controller:SetSize(512, 512)

		self.Controller.Texture = self.Controller:CreateTexture("$parentTexture", "ARTWORK")
		self.Controller.Texture:SetAllPoints(self.Controller)

		self.Overlay = CreateFrame("Frame", "$parentOverlay", self.Controller)
		self.Overlay:SetPoint("CENTER", 0, 0)
		self.Overlay:SetSize(1024, 512)
		self.Overlay.Lines = self.Overlay:CreateTexture("$parentLines", "OVERLAY", nil, 7)
		self.Overlay.Lines:SetAllPoints(self.Overlay)
		self.Overlay.Lines:SetVertexColor(cc.r * 1.25, cc.g * 1.25, cc.b * 1.25, 0.75)

		self.Overlay.Buttons = {}


		---------------------------------------------------------------
		BASE_Y = -48
		BASE_INSET = -80

		-- Format string for controller path
		CTRL_PATH = [[Interface\AddOns\ConsolePort\Controllers\%s\%s]]
		ICON_PATH = [[Interface\AddOns\ConsolePort\Controllers\%s\Icons64\%s]]

		-- Controller layout setup
		POINTS = {
			LEFT = {
				position = {'TOP', -420, 0},
				textPoint = {'LEFT', 'LEFT', 50, 0},
				hitRects = {0, -190,  0, 0},
			},
			RIGHT = {
				position = {'TOP', 420, 0},
				textPoint = {'RIGHT', 'RIGHT', -50, 0},
				hitRects = {-190, 0, 0, 0},
			},
			CENTER = {
				position = {'CENTER', 0, 0},
				textPoint = {'TOP', 'BOTTOM', 0, -8},
				hitRects = {-90, -90, 0, -40},
			},
		}	

		-- Custom descriptions for L3/R3
		CUSTOM_DESC = {
			CP_T_L3 = db.TUTORIAL.BIND.LEFTCLICK,
			CP_T_R3 = db.TUTORIAL.BIND.RIGHTCLICK,
			CP_M1 = db.TUTORIAL.BIND.SHIFT,
			CP_M2 = db.TUTORIAL.BIND.CTRL,
		}
		---------------------------------------------------------------
	end
}