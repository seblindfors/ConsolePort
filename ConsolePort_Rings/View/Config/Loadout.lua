local env, db, Container, L = CPAPI.GetEnv(...); Container, L = env.Frame, env.L;
---------------------------------------------------------------
local Loadout = CreateFromMixins(db.LoadoutMixin); env.SharedConfig.Loadout = Loadout;
---------------------------------------------------------------

function Loadout:OnLoad()
	local scrollView = self:GetScrollView()
	scrollView:SetElementExtentCalculator(function(_, elementData)
		local info = elementData:GetData()
		return info.extent;
	end)
	scrollView:SetElementFactory(function(factory, elementData)
		local info = elementData:GetData()
		factory(info.template, info.factory)
	end)

	env:RegisterCallback('OnSelectSet', self.OnSelectSet, self)
end

function Loadout:OnSelectSet(elementData, setID, isSelected)
	self.currentSetID = isSelected and setID or nil;
end


function Loadout:OnShow()
	local Header = env.SharedConfig.Header;
	local dataProvider = self:GetDataProvider();
	local collections = self:GetCollections();

	dataProvider:Flush()

	for i, data in ipairs(collections) do
		local collection = dataProvider:Insert(Header.New(data.name));
	end
end