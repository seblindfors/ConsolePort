local _, L = ...
local Mixin = L.db.table.mixin
local db = L.db
local cc = L.cc

--[[
		local 	name, header, bannerAtlas, mixin, onLoad, onFirstShow = 
			info.name, info.header, info.bannerAtlas,
			info.mixin, info.onLoad, info.onFirstShow
]]
local 	TUTORIAL, BIND, TEXTURE, ICONS,
		-- Fade wrappers
		FadeIn, FadeOut,
		-- Table functions
		Mixin, spairs, compare, copy,
		-- Mixins
		BindingMixin, ButtonMixin, CatcherMixin, 
		HeaderMixin, LayoutMixin, RebindMixin,
		ShortcutMixin, SwapperMixin, WindowMixin,
		-- Reference variables
		window, rebindFrame, newBindingSet = 
		-------------------------------------
		db.TUTORIAL.BIND, 'BINDING_NAME_', db.TEXTURE, db.ICONS,
		db.UIFrameFadeIn, db.UIFrameFadeOut,
		db.table.mixin, db.table.spairs, db.table.compare, db.table.copy,
		{}, {}, {}, {}, {}, {}, {}, {}, {}

local config = {
	-- Custom descriptions for L3/R3
	customDescription = {
		['CP_T_L3'] = TUTORIAL.LEFTCLICK,
		['CP_T_R3'] = TUTORIAL.RIGHTCLICK,
	},
	-- Button templates
	listButton = {
		iconPoint = {'LEFT', 'RIGHT', -40, 0},
		textPoint = {'LEFT', 'LEFT', 8, 0},
		width = 200,
	},
	configButton = {
		width = 50,
		height = 50,
		iconPoint = {'LEFT', 'RIGHT', 190, 0},
		textPoint = {'LEFT', 'LEFT', 46, 0},
		buttonPoint = {'CENTER', 0, 0},
		hitRects = {0, -230,  0, 0},
		anchor = {'TOPLEFT', 'CENTER', 100, -16},
		useButton = true,
		textWidth = 200,
	},
	-- Controller layout setup
	layOut = {
		LEFT = {
			position = {'TOP', -480, 0},
			iconPoint = {'RIGHT', 'LEFT', -4, 0},
			textPoint = {'LEFT', 'LEFT', 56, 0},
			buttonPoint = {'CENTER', 0, 0},
			hitRects = {0, -190,  0, 0},
		},
		RIGHT = {
			position = {'TOP', 480, 0},
			iconPoint = {'LEFT', 'RIGHT', 4, 0},
			textPoint = {'RIGHT', 'RIGHT', -56, 0},
			buttonPoint = {'CENTER', 0, 0},
			hitRects = {-190, 0, 0, 0},
		},
		CENTER = {
			position = {'CENTER', 0, 0},
			iconPoint = {'BOTTOM', 'TOP', 0, 4},
			textPoint = {'TOP', 'BOTTOM', 0, -8},
			buttonPoint = {'CENTER', 0, 0},
			hitRects = {-90, -90, 0, -40},
		},
	},
	-- Modifier functions
	configButtonModifier = {
		['SHIFT-'] = function(self)
			local icon = self:CreateTexture('$parent_M1', 'OVERLAY', nil, 7)
			icon:SetSize(24, 24)
			icon:SetPoint('TOPRIGHT', self, 'TOP', 0, 4)
			icon:SetTexture(db.ICONS.CP_M1)
		end,
		['CTRL-'] = function(self)
			local icon = self:CreateTexture('$parent_M2', 'OVERLAY', nil, 7)
			icon:SetSize(24, 24)
			icon:SetPoint('TOPRIGHT', self, 'TOP', 0, 4)
			icon:SetTexture(db.ICONS.CP_M2)
		end,
		['CTRL-SHIFT-'] = function(self)
			local icon1 = self:CreateTexture('$parent_M1', 'OVERLAY', nil, 7)
			local icon2 = self:CreateTexture('$parent_M2', 'OVERLAY', nil, 7)
			icon1:SetSize(24, 24)
			icon1:SetPoint('TOPRIGHT', self, 'TOP', 0, 4)
			icon1:SetTexture(db.ICONS.CP_M1)		
			icon2:SetSize(24, 24)
			icon2:SetPoint('LEFT', icon1, 'CENTER')
			icon2:SetTexture(db.ICONS.CP_M2)
		end,
	},
	-- Override mouse bindings
	mouseBindings = {
		['CP_T_L3'] = 'BUTTON1',
		['CP_T_R3'] = 'BUTTON2',
	},
	mouseDefault = {
		['BUTTON1'] = 'CAMERAORSELECTORMOVE',
		['BUTTON2'] = 'TURNORACTION',
	},
	-- Hard-coded movement bindings
	movement = {
		MOVEFORWARD 	= {'W', 'UP'},
		MOVEBACKWARD 	= {'S', 'DOWN'},
		STRAFELEFT 		= {'A', 'LEFT'},
		STRAFERIGHT 	= {'D', 'RIGHT'},
	},
	-- Display button texture setup
	displayButton = {
		LeftNormal = 	{1, {0.1064, 0.2080, 0.3886, 0.4462}, 	{83.2, 47.2}, {'LEFT', 0, 0}},
		RightNormal = 	{2, {0.2080, 0.1064, 0.3886, 0.4462},	{83.2, 47.2}, {'RIGHT', 0, 0}},
		LeftEnabled = 	{1, {0.0009, 0.0937, 0.3896, 0.4365},	{76, 38.4},	 {'LEFT', 3.2, 3.2}},
		RightEnabled = 	{2, {0.0937, 0.0009, 0.3896, 0.4365},	{76, 38.4},  {'RIGHT', -3.2, 3.2}},
		Controller = 	{3, {0, 0.0498, 0.4423, 0.4707},		{40.8, 23.2}},
		Grid = 			{3, {0.0517, 0.0761, 0.4453, 0.4628}, 	{20, 14.4}},
	},
}
do
	local Panel, Container, Canvas = L.GetPanoramaFrame('ConsolePortBindingFrame', L.Config) 
	local test = L.Config:AddPanel({
		name = 'Bindings',
		header = 'Bindings',
		mixin = {},
		frame = Panel,
		onLoad = function(self, core)

			local settings = db.Settings

			Container:SetCanvasSize(4000, 2000)

			Canvas:SetPoint('CENTER')

			Canvas.Overlay = CreateFrame('Frame', nil, Canvas)
			Canvas.Overlay:SetSize(1024, 512)
			Canvas.Overlay:SetPoint('CENTER')

			local Overlay = Canvas.Overlay
			do
				local resizeFactor = 1.15
				Overlay.Controller = Overlay:CreateTexture(nil, 'ARTWORK')
				Overlay.Controller:SetTexture('Interface\\AddOns\\ConsolePort\\Controllers\\'..settings.type..'\\Front')
				Overlay.Controller:SetPoint('CENTER', 0, 20)
				Overlay.Controller:SetSize(512, 512)

				Overlay.Lines = Overlay:CreateTexture('$parentLines', 'OVERLAY', nil, 7)
				Overlay.Lines:SetTexture('Interface\\AddOns\\ConsolePort\\Controllers\\'..settings.type..'\\Overlay')
				Overlay.Lines:SetPoint('CENTER', 0, 20)
				Overlay.Lines:SetSize(1024 * resizeFactor, 512 * resizeFactor)
				Overlay.Lines:SetVertexColor(cc.r * 1.25, cc.g * 1.25, cc.b * 1.25, 0.75)
			end


			---------------------------------------------------------------

			Canvas.Buttons = {}
			self.Buttons = {}


			local customDescription = config.customDescription
			customDescription[settings.CP_M2] = TUTORIAL.CTRL
			customDescription[settings.CP_M1] = TUTORIAL.SHIFT

			local triggers = {
				[settings.CP_T1 or 'CP_TR1'] 	= 'CP_T1',
				[settings.CP_T2 or 'CP_TR2'] 	= 'CP_T2',
				[settings.CP_T3 or 'CP_L_GRIP'] = 'CP_T3',
				[settings.CP_T4 or 'CP_R_GRIP'] = 'CP_T4',
			}

			local iconPath = 'Interface\\AddOns\\ConsolePort\\Controllers\\'..settings.type..'\\Icons64\\'
			local sharedPath = 'Interface\\AddOns\\ConsolePort\\Controllers\\Shared\\Icons64\\'
			local shared = db.Controller and db.Controller.Shared
			if db.Layout then
				local layout = config.layOut
				if settings.skipGuideBtn then
					db.Layout.CP_X_CENTER = nil
				end
				for buttonName, info in pairs(db.Layout) do
					local texture = ( shared and shared[buttonName] and sharedPath..buttonName ) or ( iconPath..buttonName )
					local settings = layout[info.anchor]
					local 	position, iconPoint, textPoint, buttonPoint, hitRects = 
							settings.position, settings.iconPoint, settings.textPoint, settings.buttonPoint, settings.hitRects

					position[3] = (info.index - 1) * -56 - 36

					local custom = customDescription[buttonName]
					local name = triggers[buttonName] or buttonName

					local button = L.GetBindingMetaButton(name..'_BINDING_NEW', Overlay, {
						width = 30,
						height = 30,
						justifyH = info.anchor,
						textWidth = 200,
						iconPoint = iconPoint,
						textPoint = textPoint,
						buttonPoint = buttonPoint,
						buttonTexture = texture,
						useButton = true,
						hitRects = hitRects,
						default = custom,
					})

					button.ButtonTexture:SetSize(46, 46)

					button.anchor = info.anchor
					button.icon = '|T%s:32:32:0:0|t'
					button.texture = format(button.icon, texture)

					button:SetPoint(unpack(position))

					if not custom or config.mouseBindings[buttonName] then
						button.name = triggers[buttonName] or buttonName
					--	Mixin(button, LayoutMixin)
						Canvas.Buttons[#Canvas.Buttons + 1] = button
					end
				end
				config.layOut = nil
			end

		---------------------------------------------------------------
		end,
	})
end