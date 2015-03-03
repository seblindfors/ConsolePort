local _
local _, G = ...;
local iterator = 1;
local Enter = MerchantItemButton_OnEnter;
local Leave = MerchantItem1ItemButton:GetScript("OnLeave");

function ConsolePort:Shop(key, state)
	local items = {};
	local currentTab = MerchantFrame.selectedTab;
	local count = GetMerchantNumItems();
	local page = MerchantFrame.page;
	for i=1, 9, 2 do
		table.insert(items, _G["MerchantItem"..i.."ItemButton"]);
	end
	for i=2, 10, 2 do
		table.insert(items, _G["MerchantItem"..i.."ItemButton"]);
	end
	local slot = items[iterator];
	local index = iterator+((page*10)-10);
	if key == G.PREPARE then iterator = 1;
	elseif 		state == G.STATE_DOWN then
		local 	old = iterator;
		if 		key == G.UP 	then iterator = iterator - 1;
		elseif	key == G.DOWN 	then iterator = iterator + 1;
		elseif 	key == G.RIGHT 	then iterator = iterator + 5;
		elseif 	key == G.LEFT 	then iterator = iterator - 5; end;
		if iterator > 10 and MerchantNextPageButton:IsEnabled() and MerchantNextPageButton:IsVisible() then
			MerchantNextPageButton:Click();
			iterator = old - 5;
		elseif iterator < 1 and MerchantPrevPageButton:IsEnabled() and MerchantPrevPageButton:IsVisible() then
			MerchantPrevPageButton:Click();
			iterator = old + 5;
		elseif iterator < 1 or iterator > 10 then
			iterator = old;
		end
		if not items[iterator].hasItem then
			iterator = 1;
		end
		slot = items[iterator];
		index = iterator+((page*10)-10);
		ConsolePort:Highlight(iterator, items);
		Enter(slot);
		if 	key == G.CIRCLE then
			slot:Click("RightButton");
		elseif key == G.SQUARE then
			MouselookStop();
			PickupMerchantItem(index);
		end
	elseif key == G.TRIANGLE then
		local maxStack = GetMerchantItemMaxStack(slot:GetID());
		local _, _, price, stackCount, _, _, extendedCost = GetMerchantItemInfo(slot:GetID());
		if stackCount > 1 and extendedCost then
			slot:Click();
			return;
		end
		local canAfford;
		if 	price and price > 0 then
			canAfford = floor(GetMoney() / (price / stackCount));
		else
			canAfford = maxStack;
		end
		if	maxStack > 1 then
			local maxPurchasable = min(maxStack, canAfford);
			Leave(slot);
			OpenStackSplitFrame(maxPurchasable, slot, "BOTTOMLEFT", "TOPLEFT");
		end
	end
end

