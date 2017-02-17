local _, L = ...
local db = L.db
local Config = L.Config
local Mixin = db.table.mixin

function Config:AddPanel(info)
	if info and type(info) == 'table' then
		local 	name, header, bannerAtlas, mixin, onLoad, onFirstShow = 
			info.name, info.header, info.bannerAtlas,
			info.mixin, info.onLoad, info.onFirstShow
		local frame = info.frame or CreateFrame('Frame', '$parent'..name, self.Container)

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