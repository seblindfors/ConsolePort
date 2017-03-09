do
	local _, L = ...
	local db = ConsolePort:GetData()
	local UI = ConsolePortUI
	local class = select(2, UnitClass("player"))
	local cc = RAID_CLASS_COLORS[class]
	local gBase = 0.3
	local gMulti = 1.1

	L.UI = UI
	L.db = db
	L.cc = cc
	L.Config = UI:CreateFrame('Frame', _, UIParent, 'SecureHandlerBaseTemplate', {
		Bar = {
			Type = 'Frame',
			Backdrop = db.Atlas.Backdrops.Border,
			Points = {
				{'TOPLEFT', UIParent, 'TOPLEFT', -16, 16},
				{'BOTTOMRIGHT', UIParent, 'TOPRIGHT', 16, -72},
			},
			{
				BG = { Type = 'Texture', Setup = {'BACKGROUND'},
					Texture = 'Interface\\AddOns\\ConsolePort\\Textures\\Window\\Gradient.blp',
					Points = {
						{'TOPLEFT', 16, -16},
						{'BOTTOMRIGHT', -16, 16},
					},
					SetGradientAlpha = {
						"HORIZONTAL",
						(cc.r + gBase) * gMulti, (cc.g + gBase) * gMulti, (cc.b + gBase) * gMulti, 1,
						1 - (cc.r - gBase) * gMulti, 1 - (cc.g - gBase) * gMulti, 1 - (cc.b - gBase) * gMulti, 1,
					},
				},
				TopLine = { Type = 'Texture', Setup = {'ARTWORK'}, SetColorTexture = {1, 1, 1},
					Points = {
						{'TOPLEFT', 16, -16},
						{'BOTTOMRIGHT', '$parent', 'TOPRIGHT', -16, -20},
					},
					SetGradientAlpha = {
						"HORIZONTAL",
						cc.r, cc.g, cc.b, 1,
						1, 1, 1, 0,
					},
				},
				BottomLine = { Type = 'Texture', Setup = {'ARTWORK'}, SetColorTexture = {0.15, 0.15, 0.15},
					Points = {
						{'BOTTOMLEFT', 0, 16},
						{'BOTTOMRIGHT', 0, 16},
					},
					Height = 1,
				},
				ScrollFrame = {
					Type = 'Frame',
					Mixin = 'AdjustToChildren',
					Point = {'CENTER', 0, 0},
					Size = {1, 1},
				},
				Headers = {},
			},
		},
		Container = {
			Type = 'Frame',
			Points = {
				{'TOPLEFT', UIParent, 'TOPLEFT', 0, -56},
				{'BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', 0, 0},
			},
			{
				BG = { Type = 'Frame',
					Level = 0,
					Fill = true,
					{
						Model = {
							Type = 'PlayerModel',
							Fill = true,
							Alpha = 0.15,
							SetDisplayInfo = 43022,
							SetCamDistanceScale = 20,
							SetLight = {true, false, 0, 0, 120, 1, cc.r, cc.g, cc.b, 100, cc.r, cc.g, cc.b},
						},
						Texture = { 
							Type = 'Texture', 
							Setup = {'BACKGROUND'},
							Texture = 'Interface\\AddOns\\ConsolePort\\Textures\\Window\\Gradient.blp',
							Fill = true,
							SetGradientAlpha = {
								"HORIZONTAL",
								(cc.r + gBase) * gMulti, (cc.g + gBase) * gMulti, (cc.b + gBase) * gMulti, 1,
								1 - (cc.r - gBase) * gMulti, 1 - (cc.g - gBase) * gMulti, 1 - (cc.b - gBase) * gMulti, 1,
							},
						},
					},
				},
				Frames = {},
			},
		},
	})
	local frame = L.Config
--	db.Atlas.GetArtOverlay(frame.Container.BG)
	t = frame.Container
	frame:SetFrameStrata('FULLSCREEN_DIALOG')
	frame.Tabs = {}
	frame:Hide()

	-- debug stuff
	cptest = CreateFrame('Button', 'cptest')
	cptest:SetScript('OnClick', function() frame:SetShown(not frame:IsShown()) end)
	SetOverrideBinding(UIParent, true, "K", "CLICK cptest:LeftButton")

end