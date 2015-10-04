local _, db = ...
local KEY = db.KEY

-- Recursively compare two tables 
local function CompareTables(t1, t2)
	if t1 == t2 then
		return true
	end
	if type(t1) ~= "table" then
		return false
	end
	local mt1, mt2 = getmetatable(t1), getmetatable(t2)
	if not CompareTables(mt1,mt2) then
		return false
	end
	for k1, v1 in pairs(t1) do
		local v2 = t2[k1]
		if not CompareTables(v1,v2) then
			return false
		end
	end
	for k2, v2 in pairs(t2) do
		local v1 = t1[k2]
		if not CompareTables(v1,v2) then
			return false
		end
	end
	return true
end

local function ExportCharacterSettings()
	local index = GetUnitName("player").."-"..GetRealmName()
	if 	not CompareTables(ConsolePortBindingSet, ConsolePort:GetDefaultBindingSet()) or
		not CompareTables(ConsolePortBindingButtons, ConsolePort:GetDefaultBindingButtons()) then
		if not ConsolePortCharacterSettings then
			ConsolePortCharacterSettings = {}
		end
		if not ConsolePortCharacterSettings[index] then
			ConsolePortCharacterSettings[index] = {}
		end
		ConsolePortCharacterSettings[index] = {
			BindingSet = ConsolePortBindingSet,
			BindingBtn = ConsolePortBindingButtons,
			MouseEvent = ConsolePortMouse.Events,
		}
	elseif ConsolePortCharacterSettings then
		ConsolePortCharacterSettings[index] = nil
	end
end

-- Hacky replacement for the very broken event PLAYER_LOGOUT
local _Quit = Quit
local _Logout = Logout
local _ReloadUI = ReloadUI
local _ConsoleExec = ConsoleExec
function Quit()
	ExportCharacterSettings()
	return _Quit()
end
function Logout()
	ExportCharacterSettings()
	return _Logout()
end
function ReloadUI()
	ExportCharacterSettings()
	return _ReloadUI()
end
function ConsoleExec(msg)
	if msg == "reloadui" then
		ExportCharacterSettings()
	end
	return _ConsoleExec(msg)
end

function ConsolePort:LoadHookScripts()
	InterfaceOptionsFrame:SetMovable(true)
	InterfaceOptionsFrame:RegisterForDrag("LeftButton")
	InterfaceOptionsFrame:HookScript("OnDragStart", InterfaceOptionsFrame.StartMoving)
	InterfaceOptionsFrame:HookScript("OnDragStop", InterfaceOptionsFrame.StopMovingOrSizing)
	-- Add guides to tooltips
	-- Pending removal for cleaner solution
	GameTooltip:HookScript("OnTooltipSetItem", function(self)
		local owner = self:GetOwner()
		if owner == ConsolePortExtraButton then
			return
		end
		local item = self:GetItem()
		if 	not InCombatLockdown() then
			local 	CLICK_STRING
			if		owner:GetParent():GetName() and
					string.find(owner:GetParent():GetName(), "MerchantItem") ~= nil then
					CLICK_STRING = db.CLICK.BUY
					if GetMerchantItemMaxStack(owner:GetID()) > 1 then 
						self:AddLine(db.CLICK.STACK_BUY, 1,1,1)
					end
			elseif	owner:GetParent() == LootFrame then
					self:AddLine(db.CLICK_LOOT, 1,1,1)
			elseif 	GetItemSpell(item) 	 		then CLICK_STRING = db.CLICK.USE
			end
			if 	GetItemCount(item, false) ~= 0 or
				MerchantFrame:IsVisible() then
				if 	EquipmentFlyoutFrame:IsVisible() then
					self:AddLine(db.CLICK_CANCEL, 1,1,1)
				end
				self:AddLine(CLICK_STRING, 1,1,1)
				if CLICK_STRING == db.CLICK.USE then
					self:AddLine(db.CLICK.ADD_TO_EXTRA, 1,1,1)
				end
				if not owner:GetParent() == LootFrame then
					self:AddLine(db.CLICK.PICKUP, 1,1,1)
				end
				self:Show()
			end
		end
	end)
	GameTooltip:HookScript("OnTooltipSetSpell", function(self)
		if not InCombatLockdown() then
			if 	self:GetOwner():GetParent() == SpellBookSpellIconsFrame and not
				self:GetOwner().isPassive then
				if not self:GetOwner().UnlearnedFrame:IsVisible() then
					self:AddLine(db.CLICK.USE_NOCOMBAT, 1,1,1)
					self:AddLine(db.CLICK.PICKUP, 1,1,1)
				end
				self:Show()
			end
		end
	end)
	-- Map hooks
	WorldMapButton:HookScript("OnUpdate", ConsolePort.MapHighlight)
	-- Disable keyboard input (will obstruct controller input)
	StackSplitFrame:EnableKeyboard(false)
	-- Get rid of mouselook when trying to interact with mouse
	hooksecurefunc("InteractUnit", self.StopMouse)
	--
	StaticPopupDialogs.DELETE_GOOD_ITEM = StaticPopupDialogs.DELETE_ITEM
end