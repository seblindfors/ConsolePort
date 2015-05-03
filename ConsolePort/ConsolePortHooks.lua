local _, G = ...;
local KEY = G.KEY;
local function UIDefaultButtonExtend(Button, Anchor)
	Button:SetPoint(Anchor, Button:GetParent(), "BOTTOM", 0);
end

local function CinematicControllerInput(key, state)
	local keybind = GetBindingFromClick(key), button;
	if 		keybind == "CLICK CP_R_RIGHT_NOMOD:LeftButton" 	then button = KEY.CIRCLE;
	elseif 	keybind == "CLICK CP_R_LEFT_NOMOD:LeftButton" 	then button = KEY.SQUARE; end;
	if button then ConsolePort:Misc(button, state); end;
end

-- Recursively compare two tables 
local function CompareTables(t1, t2)
	if t1 == t2 then
		return true;
	end
	if type(t1) ~= "table" then
		return false;
	end
	local mt1, mt2 = getmetatable(t1), getmetatable(t2);
	if not CompareTables(mt1,mt2) then
		return false;
	end
	for k1, v1 in pairs(t1) do
		local v2 = t2[k1];
		if not CompareTables(v1,v2) then
			return false;
		end
	end
	for k2, v2 in pairs(t2) do
		local v1 = t1[k2];
		if not CompareTables(v1,v2) then
			return false;
		end
	end
	return true;
end

local function ExportCharacterSettings()
	local index = GetUnitName("player").."-"..GetRealmName();
	if 	not CompareTables(ConsolePortBindingSet, ConsolePort:GetDefaultBindingSet()) or
		not CompareTables(ConsolePortBindingButtons, ConsolePort:GetDefaultBindingButtons()) then
		if not ConsolePortCharacterSettings then
			ConsolePortCharacterSettings = {};
		end
		if not ConsolePortCharacterSettings[index] then
			ConsolePortCharacterSettings[index] = {};
		end
		ConsolePortCharacterSettings[index] = {
			BindingSet = ConsolePortBindingSet;
			BindingBtn = ConsolePortBindingButtons,
			MouseEvent = ConsolePortMouseSettings
		}
	elseif ConsolePortCharacterSettings then
		ConsolePortCharacterSettings[index] = nil;
	end
end

-- Hacky replacement for the very broken event PLAYER_LOGOUT
local _Quit = Quit;
local _Logout = Logout;
local _ReloadUI = ReloadUI;
local _ConsoleExec = ConsoleExec;
function Quit()
	ExportCharacterSettings();
	return _Quit();
end
function Logout()
	ExportCharacterSettings();
	return _Logout();
end
function ReloadUI()
	ExportCharacterSettings();
	return _ReloadUI();
end
function ConsoleExec(msg)
	if msg == "reloadui" then
		ExportCharacterSettings();
	end
	return _ConsoleExec(msg);
end

function ConsolePort:LoadHookScripts()
	-- Game Menu frame
	local Controller = GameMenuFrame:CreateTexture("GameMenuTextureController", "ARTWORK");
	Controller:SetTexture("Interface\\AddOns\\ConsolePort\\Graphic\\Splash"..ConsolePortSettings.type);
	Controller:SetPoint("CENTER", GameMenuFrame, "CENTER");
	--
	InterfaceOptionsFrame:SetMovable(true);
	InterfaceOptionsFrame:RegisterForDrag("LeftButton");
	InterfaceOptionsFrame:HookScript("OnDragStart", InterfaceOptionsFrame.StartMoving);
	InterfaceOptionsFrame:HookScript("OnDragStop", InterfaceOptionsFrame.StopMovingOrSizing);
	-- Add guides to tooltips
	-- Pending removal for cleaner solution
	GameTooltip:HookScript("OnTooltipSetItem", function(self)
		local owner = self:GetOwner();
		if owner == ConsolePortExtraButton then
			return;
		end
		local item = self:GetItem();
		if 	not InCombatLockdown() then
			local 	CLICK_STRING;
			if		owner:GetParent():GetName() and
					string.find(owner:GetParent():GetName(), "MerchantItem") ~= nil then
					CLICK_STRING = G.CLICK.BUY;
					local maxStack = GetMerchantItemMaxStack(owner:GetID());
					if maxStack > 1 then 
						self:AddLine(G.CLICK.STACK_BUY, 1,1,1);
					end
			elseif	owner:GetParent() == LootFrame then
					self:AddLine(G.CLICK_LOOT, 1,1,1);
			elseif 	MerchantFrame:IsVisible()	then CLICK_STRING = G.CLICK.SELL;
			elseif 	IsEquippedItem(item)		then CLICK_STRING = G.CLICK.REPLACE;
			elseif 	IsEquippableItem(item) 		then CLICK_STRING = G.CLICK.EQUIP;
			elseif 	GetItemSpell(item) 	 		then CLICK_STRING = G.CLICK.USE;
			end
			if 	GetItemCount(item, false) ~= 0 or
				MerchantFrame:IsVisible() then
				if 	EquipmentFlyoutFrame:IsVisible() then
					self:AddLine(G.CLICK_CANCEL, 1,1,1);
				end
				self:AddLine(CLICK_STRING, 1,1,1);
				if CLICK_STRING == G.CLICK.USE then
					self:AddLine(G.CLICK.ADD_TO_EXTRA, 1,1,1);
				end
				if not owner:GetParent() == LootFrame then
					self:AddLine(G.CLICK.PICKUP, 1,1,1);
				end
				self:Show();
			end
		end
	end);
	GameTooltip:HookScript("OnTooltipSetSpell", function(self)
		if not InCombatLockdown() then
			if 	self:GetOwner():GetParent() == SpellBookSpellIconsFrame and not
				self:GetOwner().isPassive then
				if not self:GetOwner().UnlearnedFrame:IsVisible() then
					self:AddLine(G.CLICK.USE_NOCOMBAT, 1,1,1);
				end
				self:AddLine(G.CLICK.PICKUP, 1,1,1);
				self:Show();
			end
		end
	end);
	GameTooltip:HookScript("OnShow", function(self)
		if 	self:GetOwner() and
			self:GetOwner().questID then
			self:AddLine(G.CLICK.QUEST_DETAILS, 1,1,1);
			self:AddLine(G.CLICK.QUEST_TRACKER, 1,1,1);
		end
 	end);
	-- Map hooks
	WorldMapButton:HookScript("OnUpdate", ConsolePort.MapHighlight);
	WorldMapFrame:HookScript("OnShow", function(self)
		if QuestScrollFrame:GetAlpha() ~= 1 then 
			WorldMapFrameTutorialButton:GetChildren():Hide();
		end
	end);
	-- This might be pointless
	WorldMapFrame:HookScript("OnHide", function(self)
		if 	GameTooltip:GetOwner() and
			GameTooltip:GetOwner().questID then
			GameTooltip:GetOwner():GetScript("OnLeave")(GameTooltip:GetOwner());
		end
	end);
	QuestMapDetailsScrollFrame:HookScript("OnShow", function(self)
		WorldMapFrame.UIElementsFrame.CloseQuestPanelButton:Hide();
		WorldMapFrame.UIElementsFrame.TrackingOptionsButton:Hide();
	end);
	QuestMapDetailsScrollFrame:HookScript("OnHide", function(self)
		WorldMapFrame.UIElementsFrame.CloseQuestPanelButton:Show();
		WorldMapFrame.UIElementsFrame.TrackingOptionsButton:Show();
	end);
	-- Hide guides not currently in use
	QuestMapFrame.DetailsFrame.CompleteQuestFrame.CompleteButton:HookScript("OnShow", function(self)
		QuestMapFrame.DetailsFrame.TrackButton:GetChildren():Hide();
	end);
	QuestMapFrame.DetailsFrame.CompleteQuestFrame.CompleteButton:HookScript("OnHide", function(self)
		QuestMapFrame.DetailsFrame.TrackButton:GetChildren():Show();
	end);
	-- Disable keyboard input (will obstruct controller input)
	StackSplitFrame:EnableKeyboard(false);
	-- Modify default UI points, just aestethic
	UIDefaultButtonExtend(GossipFrameGreetingGoodbyeButton,	"LEFT"	);
	UIDefaultButtonExtend(QuestFrameAcceptButton, 			"RIGHT"	);
	UIDefaultButtonExtend(QuestFrameDeclineButton, 			"LEFT"	);
	UIDefaultButtonExtend(QuestFrameCompleteQuestButton,	"RIGHT" );
	UIDefaultButtonExtend(QuestFrameCompleteButton,			"RIGHT"	);
	UIDefaultButtonExtend(QuestFrameGoodbyeButton,			"LEFT"	);
	UIDefaultButtonExtend(PetitionFrameSignButton, 			"RIGHT" );
	UIDefaultButtonExtend(PetitionFrameCancelButton,		"LEFT"	);
	-- Add inputs to cinematic frame, behaves oddly after first dialog closing
	CinematicFrame:HookScript("OnKeyDown", function(self, key)
		CinematicControllerInput(key, KEY.STATE_DOWN);
	end);
	CinematicFrame:HookScript("OnKeyUp", function(self, key)
		CinematicControllerInput(key, KEY.STATE_UP);
	end);
end

function ConsolePort:LoadEvents()
	-- Default events
	local Events = {
		["PLAYER_STARTED_MOVING"] 	= false,
		["PLAYER_REGEN_DISABLED"] 	= false,
		["PLAYER_REGEN_ENABLED"] 	= false,
		["ADDON_LOADED"] 			= false,
		["UPDATE_BINDINGS"] 		= false,
		["CURSOR_UPDATE"] 			= false,
		["QUEST_AUTOCOMPLETE"] 		= false,
		["QUEST_LOG_UPDATE"] 		= false,
		["WORLD_MAP_UPDATE"] 		= false,
		["UNIT_ENTERING_VEHICLE"] 	= false
	}
	-- Mouse look events
	for event, val in pairs(ConsolePortMouseSettings) do
		Events[event] = val;
	end
	self:UnregisterAllEvents();
	for event, _ in pairs(Events) do
		self:RegisterEvent(event);
	end
	return Events;
end