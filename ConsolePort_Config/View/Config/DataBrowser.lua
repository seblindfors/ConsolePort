local Tabular, env = LibStub('Tabular'), CPAPI.GetEnv(...);

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local BROWSER_HEIGHT        = 500;
local BROWSER_CONTENT_WIDTH = 500;
local BROWSER_FRAME_WIDTH   = 560;

---------------------------------------------------------------
local Container = {};
---------------------------------------------------------------

function Container:AdjustSize(owner)
	CPAPI.Next(function(container, browser, popup)
		local offset = -popup:GetBottom()
		if offset < 0 then
			container:SetHeight(BROWSER_HEIGHT)
			return browser:SetHeight(BROWSER_HEIGHT)
		end
		container:SetHeight(BROWSER_HEIGHT - offset)
		browser:SetHeight(BROWSER_HEIGHT - offset)
		popup:SetHeight(popup:GetHeight() - offset)
	end, self, self.Browser, owner)
end

function Container:Popup(popupName, popupData, binData)
	self:Show()
	return CPAPI.Popup(popupName, popupData, nil, nil, binData, self)
end

function Container:SetData(...)
	return self.Browser:SetData(...);
end

function Container:Compile()
	return self.Browser:Compile();
end

---------------------------------------------------------------
local Browser = {};
---------------------------------------------------------------

function Browser:OnShow()
	self:SetVerticalScroll(0)
	self.LoadingSpinner:Show()
end

function Browser:OnEnter()
	self:Raise()
end

function Browser:OnHide()
	if self.release then
		self.release()
		self.compile, self.release = nil, nil;
	end
end

function Browser:SetData(args, data)
	self:OnHide()
	args.parent = self.ScrollChild;
	args.width  = BROWSER_CONTENT_WIDTH;
	args.state  = false;
	self.compile, self.release = Tabular(args, data)
	self.ScrollChild:Layout()
	self.LoadingSpinner:Hide()
	return self.compile, self.release;
end

function Browser:Compile()
	if self.compile then
		return self.compile()
	end
end

function env.CreateDataContainer()
	if not env.DataContainer then
		local container = CreateFrame('Frame', nil, nil, 'CPConfigDataContainer')
		container:SetSize(BROWSER_FRAME_WIDTH, BROWSER_HEIGHT)
		container.Browser:SetSize(container:GetSize())
		CPAPI.SpecializeOnce(container, Container)
		CPAPI.SpecializeOnce(container.Browser, Browser)
		env.DataContainer = container;
	end
	return env.DataContainer;
end