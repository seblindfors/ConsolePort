local _, env, db = ...; db = env.db;
---------------------------------------------------------------
CPActionBar = Mixin({
---------------------------------------------------------------
	FadeIn = db.Alpha.FadeIn;
	Env = {
		_onshow = [[
			self::OnAcquire()
		]];
		_onhide = [[
			self::OnRelease()
		]];
		OnAcquire = [[
			manager:SetAttribute(self:GetAttribute('signature'), self::IsOverrideApplicable())
			manager::RefreshBindings(self:GetName())
		]];
		OnRelease = [[
			manager:SetAttribute(self:GetAttribute('signature'), self::IsOverrideApplicable())
			manager::RefreshBindings(nil)
		]];
		IsOverrideApplicable = [[
			local override = self:GetAttribute('override')
			if ( override == 'shown' ) then
				return self:IsVisible()
			elseif ( override == 'hidden' ) then
				return not self:IsVisible()
			end
			return ( override == 'true' );
		]];
		OnLoad = [[
			manager = self:GetFrameRef('Manager')
			cursor  = manager:GetFrameRef('Cursor')
			pager   = manager:GetFrameRef('Pager')
		]];
	};
	-----------------------------------------------------------
}, CPAPI.AdvancedSecureMixin, env.CommonWidgetMixin, env.DynamicWidgetMixin);
---------------------------------------------------------------

function CPActionBar:OnLoad()
	db.Pager:RegisterHeader(self)
	self:SetFrameRef('Manager', env.Manager)
	self:Run(self.Env.OnLoad)
	self:EnableMouse(false)
end

function CPActionBar:RegisterDriver(type, driver, body, current)
	driver = env.ConvertDriver(driver)
	body   = CPAPI.ConvertSecureBody(body)

	RegisterStateDriver(self, type, driver)
	self:SetAttribute(type, current or SecureCmdOptionParse(driver))
	self:SetAttribute(env.Attributes.Driver(type), driver)
	self:SetAttribute(env.Attributes.State(type), body)
	self:Run([[local newstate = self:GetAttribute(%q) %s]], type, body)
end

function CPActionBar:RunDriver(type) self:Run([[
	local newstate = SecureCmdOptionParse(%q); %s
]], self:GetAttribute(env.Attributes.Driver(type)), self:GetAttribute(env.Attributes.State(type))) end

function CPActionBar:RunAttribute(attribute, ...) self:Run([[
	self::%s(%q)
]], attribute, ...) end

function CPActionBar:RegisterModifierDriver(driver, body, current)
	self:RegisterDriver('modifier', driver, body, current)
end

function CPActionBar:RegisterVisibilityDriver(driver, current)
	driver = env.ConvertDriver(driver)
	RegisterStateDriver(self, env.Attributes.Visible, driver)
	self:SetAttribute(env.Attributes.Visible, current or SecureCmdOptionParse(driver))
end

function CPActionBar:UnregisterVisibilityDriver()
	UnregisterStateDriver(self, env.Attributes.Visible)
end

function CPActionBar:RegisterPageResponse(body)
	self:SetAttribute(env.Attributes.OnPage, body)
end

function CPActionBar:SetPoint(point, relFrame, relPoint, x, y)
	self:SetAttribute('x', x)
	self:SetAttribute('y', y)
	getmetatable(self).__index.SetPoint(self, point, relFrame, relPoint, x, y)
end

function CPActionBar:OnDriverChanged()
	-- Driver: visibility
	self:RegisterVisibilityDriver(self.props.visibility)

	-- Driver: rescale
	self:RegisterDriver('rescale', env.ConvertDriver(self.props.rescale), [[
		newstate = (tonumber(newstate) or 100) * 0.01;
		if newstate > 0 then
			if self:GetAttribute('offsetscale') then
				local relScale = 1 / newstate;
				local point, relFrame, relPoint = self:GetPoint()
				self:SetPoint(point, relFrame, relPoint, self:GetAttribute('x') * relScale, self:GetAttribute('y') * relScale)
			end
			self:SetScale(newstate)
		end
	]])

	-- Driver: opacity
	self:RegisterDriver('opacity', env.ConvertDriver(self.props.opacity), [[
		newstate = (tonumber(newstate) or 100) * 0.01;
		if newstate < 0 then newstate = 0 end;
		if newstate > 1 then newstate = 1 end;
		self:CallMethod('FadeIn', 0.05, ALPHA or 0, newstate)
		ALPHA = newstate;
	]])

	-- Driver: override
	self:RegisterDriver('override', env.ConvertDriver(self.props.override), [[
		self:SetAttribute('override', newstate)
		if self:IsVisible() then
			return self::OnAcquire()
		end
		self::OnRelease()
	]])
end

function CPActionBar:OnHierarchyChanged()
	db.Raid:CacheActionBar(self)
end

function CPActionBar:OnRelease()
	self:UnregisterVisibilityDriver()
end