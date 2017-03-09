local _, L = ...
local UI, db = L.UI, L.db
local Config = L.Config
local Mixin = db.table.mixin
local Frames = Config.Container.Frames
local Headers = Config.Bar.Headers

function Config:GetHeader()
	local header = UI:CreateFrame('Button', nil, self.Bar.ScrollFrame, nil, {
		NormalTexture = { Type = 'Texture', Fill = true, Coords = {257/512, 1, 0, 1},
			Setup = {'BACKGROUND'}, Texture = 'Interface\\AddOns\\'.._..'\\Textures\\Header'},
		PushedTexture = { Type = 'Texture', Fill = true, Coords = {0, 256/512, 0, 1},
			Setup = {'BACKGROUND'}, Texture = 'Interface\\AddOns\\'.._..'\\Textures\\Header'},
	})

	header.Siblings = Headers
	header.Parent = self.Bar.ScrollFrame
	header.ContainerFrames = Frames

	Mixin(header, L.Header)
	header:OnLoad()

	if Headers[#Headers] then
		header:SetPoint('LEFT', Headers[#Headers], 'RIGHT', 0, 0)
	else
		header:SetPoint('LEFT', 0, 0)
	end

	Headers[#Headers + 1] = header

	self.Bar.ScrollFrame:AdjustToChildren()
	return header
end

function Config:AddPanel(info)
	if info and type(info) == 'table' then
		local 	name, header, bannerAtlas, mixin, onLoad, onFirstShow = 
			info.name, info.header, info.bannerAtlas,
			info.mixin, info.onLoad, info.onFirstShow
		local frame = info.frame or CreateFrame('Frame', '$parent'..name, self.Container)
		local header = self:GetHeader()

		local id = #self.Container.Frames + 1--Category:AddNew(header, bannerAtlas)
		self.Container.Frames[id] = frame

		if mixin then
			Mixin(frame, mixin)
		end

		frame.IDtag = name
		frame:SetID(id)
		frame:SetParent(self.Container)
		frame:SetAllPoints(self.Container)
		if onLoad then
			onLoad(frame, ConsolePort)
		end
		if onFirstShow then
			frame:SetScript('OnShow', function(self)
				self:onFirstShow(ConsolePort)
				self.onFirstShow = nil
				self:Hide()
				self:SetScript('OnShow', self.OnShow)
				self:Show()
			end)
			frame.onFirstShow = onFirstShow
		end
	--	db[name] = frame
		return frame
	end
end