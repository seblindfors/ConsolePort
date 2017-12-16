local NPE = ConsolePortUI:CreateScriptFrame('Frame')
local __display, __tobject, __pobject, __desired
-- ------------------------------------------------------------------------------------------------------------
-- Content hook management:
function NPE:SetContent(_, content)
	content = content or __desired
	if type(content) == 'string' then
		local contentID = self:GetContentID(content)
		if type(self[contentID]) == 'function' then
			self:SetText(self[contentID](self, content))
		elseif type(self[contentID]) == 'string' then
			self:SetText(self[contentID])
		end
	end
end

function NPE:SetDesiredContent()
	__desired = __tobject.DesiredContent
end

function NPE:SetNewPointer(_, content, _, parent)
	local contentID = self:GetContentID(content)
	local pointer = parent.currentNPEPointer
	if pointer then
		if not self[contentID] then
			pointer:Hide() -- get rid of most of these.
		elseif type(self[contentID]) == 'function' then
			self:SetPointerText(pointer, self[contentID](self, content))
		elseif type(self[contentID]) == 'string' then
			self:SetPointerText(pointer, self[contentID])
		end
	end
end

function NPE:FormatNPEString(str)
	local new = (string.gsub(str, '{Atlas|([%w_]+):?(%d*)}', function(atlasName, size)
		size = tonumber(size) or 0

		local filename, width, height, txLeft, txRight, txTop, txBottom = GetAtlasInfo(atlasName)

		if (not filename) then return end

		local atlasWidth = width / (txRight - txLeft)
		local atlasHeight = height / (txBottom - txTop)

		local pxLeft	= atlasWidth	* txLeft
		local pxRight	= atlasWidth	* txRight
		local pxTop		= atlasHeight	* txTop
		local pxBottom	= atlasHeight	* txBottom

		return string.format('|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t', filename, size, size, atlasWidth, atlasHeight, pxLeft, pxRight, pxTop, pxBottom)
	end))
	return (string.gsub(new, '{%$(%d+)}', function(spellID)
		local name, _, icon = GetSpellInfo(spellID);
		return string.format('|cFF00FFFF%s|r |T%s:16|t', name or spellID, icon or spellID);
	end))
end

function NPE:SetText(content)
	__display:SetText(self:FormatNPEString(content))
end

function NPE:SetPointerText(pointer, content, reAnchor)
	if pointer then
		pointer.Content.Text:SetText(self:FormatNPEString(content))
		pointer.Content:SetHeight(pointer.Content.Text:GetHeight() + 40)
	end
end

local function __decodestring(str)
	local ret = {}
	for word in str:gmatch('%a+') do
		ret[#ret + 1] = word
	end
	return ret
end

-- attempt to identify which string is sent to the tutorial frame,
-- return its global ID and use content replacer below to swap out the string.
function NPE:GetContentID(content)
	local contentID = self.DecodeIndex[content]
	if contentID then
		return contentID
	end
	-- attempt to identify the string.
	local base = __decodestring(content)
	local countMatch, matchID = 0
	for k, v in pairs(self.DecodeIndex) do
		local innerCount = 0
		for i=1, #base do
			if k:match(base[i]) then
				innerCount = innerCount + 1
			end
		end
		if innerCount > countMatch then
			countMatch = innerCount
			matchID = v
		end
	end
	-- at least 75% of words should be the same in order to elicit a match.
	return countMatch >= (#base * .75) and matchID
end

function NPE:Initialize()
	__display = NPE_TutorialMainFrame.Frame.Text
	__tobject = NPE_TutorialMainFrame
	__pobject = NPE_TutorialPointerFrame
	self:HookObject(__tobject, '_SetContent', self.SetContent)
	self:HookObject(__tobject, '_SetDesiredContent', self.SetDesiredContent)
	self:HookObject(__pobject, 'Show', self.SetNewPointer)
	self:SetContent(nil, __display:GetText())

	----------------------------------------------------
	-- KBM Frame (replace textures and binding hints)
	----------------------------------------------------
	local db = ConsolePort:GetData()
	local KBM = NPE_TutorialKeyboardMouseFrame_Frame
	KBM:SetPoint('BOTTOM', 0, 200)
	KBM.ActionBarHitFrame:Hide()

	-- hacky removal of fontstrings and background since they are unreferenced.
	for _, r in ipairs({KBM:GetRegions()}) do
		if r:IsObjectType('FontString') and r ~= KBM.TitleText then
			r:Hide()
		elseif r:IsObjectType('Texture') and r:GetAtlas() == 'NPE_keyboard' then
			r:SetTexture(ConsolePort:GetControllerTexture());
			r:SetTexCoord(0, 1, 0.2, 0.6)
			r:SetDrawLayer('BACKGROUND', 7)
			r:SetAlpha(.05)
		end
	end

	local kbmFont = {GameFontNormalLarge:GetFont()}
	ConsolePortUI:BuildFrame(KBM, {
		Bg = {Type = 'Existing'; Setup = KBM.Bg; Texture = [[Interface\AddOns\ConsolePort\Textures\Window\Gradient]]};
		----------------------------------------------------
		LStick = {Type = 'Texture'; Texture = [[Interface\AddOns\ConsolePortHelp\Textures\LStick]]; Size = {100, 100}; Point = {'BOTTOMLEFT', 22, 0}};
		RStick = {Type = 'Texture'; Texture = [[Interface\AddOns\ConsolePortHelp\Textures\RStick]]; Size = {100, 100}; Point = {'BOTTOMRIGHT', -20, 0}};
		LStickText = {Type = 'FontString'; Font = kbmFont; Point = {'LEFT', '$parent.LStick', 'RIGHT', 10, 2}; AlignH='LEFT'};
		RStickText = {Type = 'FontString'; Font = kbmFont; Point = {'RIGHT', '$parent.RStick', 'LEFT', -10, 2}; AlignH='RIGHT'};
		----------------------------------------------------
		Jump 	= {Type = 'FontString'; Font = kbmFont; AlignH = 'RIGHT'; Point = {'BOTTOMRIGHT', -36, 90}};
		Target 	= {Type = 'FontString'; Font = kbmFont; AlignH = 'RIGHT'; Point = {'BOTTOMRIGHT', -36, 140}};
		Ring 	= {Type = 'FontString'; Font = kbmFont; AlignH = 'RIGHT'; Point = {'BOTTOMRIGHT', -36, 190}};
		----------------------------------------------------
		Map 	= {Type = 'FontString'; Font = kbmFont; AlignH = 'LEFT'; Point = {'BOTTOMLEFT', 36, 90}};
		Bags 	= {Type = 'FontString'; Font = kbmFont; AlignH = 'LEFT'; Point = {'BOTTOMLEFT', 36, 140}};
		Menu 	= {Type = 'FontString'; Font = kbmFont; AlignH = 'LEFT'; Point = {'BOTTOMLEFT', 36, 190}};
	})

	KBM.LStickText:SetText(NPE_MOVE .. '\n' .. KEY_BUTTON1 .. '\n' .. NPE_SELECTTARGET .. ' (' .. MOUSE_LABEL .. ')')
	KBM.RStickText:SetText(NPE_TURN .. '\n' .. KEY_BUTTON2 .. '\n' .. UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_INTERACT)

	local function SetBindingText(fontString, text, ...)
		local binding
		for i=1, select('#', ...) do
			binding = ConsolePort:GetFormattedBindingOwner(select(i, ...), nil, 32, true)
			if binding then
				break
			end
		end
		if not binding then
			binding = [[|TInterface\AddOns\ConsolePort\Textures\IconMask64:32:32|t]]
		end
		local direction = fontString:GetJustifyH()
		fontString:SetText((direction == 'RIGHT') and (text .. '  ' .. binding) or (binding .. '  ' .. text))
	end

	KBM:SetScript('OnShow', function(self)
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
		self.TitleText:SetText(NPE_CONTROLS)
		self.portrait:SetTexture([[Interface\AddOns\ConsolePort\Textures\Logos\CP]])
		self.portrait:SetDrawLayer('OVERLAY', 7)
		self.portrait:SetSize(80, 80)
		self.portrait:SetPoint('TOPLEFT', -16, 16)
		----------------------------------------------------
		SetBindingText(self.Jump, BINDING_NAME_JUMP, 'JUMP')
		SetBindingText(self.Target, NPE_SELECTTARGET, 'TARGETSCANENEMY', 'TARGETNEARESTENEMY')
		SetBindingText(self.Ring, db.CUSTOMBINDS.CP_UTILITYBELT, 'CLICK ConsolePortUtilityToggle:LeftButton')
		----------------------------------------------------
		SetBindingText(self.Map, OBJECTIVES_SHOW_QUEST_MAP, 'TOGGLEWORLDMAP', 'TOGGLEQUESTLOG')
		SetBindingText(self.Bags, BINDING_NAME_OPENALLBAGS, 'OPENALLBAGS')
		SetBindingText(self.Menu, BINDING_NAME_TOGGLEGAMEMENU, 'TOGGLEGAMEMENU')
		----------------------------------------------------
	end)

	ConsolePort:AddFrame(KBM)
end

function NPE:ADDON_LOADED()
	if IsAddOnLoaded('Blizzard_Tutorial') then
		if NPE_TutorialMainFrame then
			self.ADDON_LOADED = nil
			self.pollIsTutorialAvailable = nil
			self:SetScript('OnUpdate', nil)
			self:UnregisterEvent('ADDON_LOADED')
		elseif not self.pollIsTutorialAvailable then
			self.pollIsTutorialAvailable = true
			self:SetScript('OnUpdate', function(self)
				self:ADDON_LOADED()
			end)
		end
	end
	if not self.ADDON_LOADED and not self.SPELLS_CHANGED and self.Initialize then
		self:Initialize()
		self.Initialize = nil
	end
end

function NPE:SPELLS_CHANGED()
	self:CreateDecodeIndex()
	self.CreateDecodeIndex = nil
	self.SPELLS_CHANGED = nil
	self:UnregisterEvent('SPELLS_CHANGED')
	if not self.ADDON_LOADED and not self.SPELLS_CHANGED and self.Initialize then
		self:Initialize()
		self.Initialize = nil
	end
end

-- Create a string decode index, to allow lookups on escape-translated strings. (loc-agnostic)
function NPE:CreateDecodeIndex()
	self.DecodeIndex = {}
	for k, v in pairs(_G) do
		if type(k) == 'string' and k:match('^NPE_') and type(v) == 'string' then
			self.DecodeIndex[self:FormatNPEString(v)] = k
		end
	end
end

-- Hack: force the function if spell data is already available.
-- No need to wait until SPELLS_CHANGED fires again to complete initialization.
if (GetNumSpellTabs() ~= 0) then
	NPE:SPELLS_CHANGED()
end

-- ------------------------------------------------------------------------------------------------------------
-- Content replacement: 
setfenv(1, setmetatable({}, {
	__index = _G;
	__newindex = function(t, k, v)
		NPE[k] = v;
	end;
}))
local db = ConsolePort:GetData()
-- ------------------------------------------------------------------------------------------------------------

local function GetBindingString(binding) return ConsolePort:GetFormattedBindingOwner(binding, nil, 20, true) end
local function BreakUpString(str) local b1, b2 = str:find('|c'), str:find('|r') return str:sub(0, b1-1), str:sub(b2) end
local function ReplaceEscape(str, esc) if not esc then return str end local f, s = BreakUpString(str) return f .. esc .. s end
local function GetClickIcon(requiresMouse, isUI, uiMouseButton)
	local interactKey = 
		isUI and (db.Mouse and db.Mouse.Cursor and db.Mouse.Cursor[uiMouseButton]) or
		not isUI and (db.Settings.interactWith or (not requiresMouse and db.Settings.lootWith))
	return  interactKey and db.TEXTURE[interactKey] or db.TEXTURE.CP_T_R3 or ' '
end
local function ReplaceInteract(str, requiresMouse, noAtlas)
	local icon = GetClickIcon(requiresMouse)
	local new = ReplaceEscape(str, noAtlas and (USE..' ' .. '|T' .. icon .. ':20:20|t') or USE)
	return new:gsub('{Atlas|NPE_RightClick:16}', '|T' .. icon .. ':20:20|t')
end
local function ReplaceUIClick(str, mouseButton)
	local icon = GetClickIcon(false, true, mouseButton)
	local new = ReplaceEscape(str, '')
	return new:gsub('{Atlas|NPE_RightClick:16}', '|T' .. icon .. ':20:20|t')
end
local function ReplaceUtilityRing(str)
	local new = GetBindingString('CLICK ConsolePortUtilityToggle:LeftButton')
	local autoExtra = db.Settings and db.Settings.autoExtra
	return ((new and autoExtra) and (USE_ITEM .. ':  ' .. new)) or str
end


-- ------------------------------------------------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 				Mainframe strings to be replaced with controller-related tips (loc agnostic):
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- ------------------------------------------------------------------------------------------------------------


-- You have a new item! Press |cFF00FFFF%s|r to open your bag.
NPE_OPENBAG = function(self) return ReplaceEscape(NPE_OPENBAG, GetBindingString('OPENALLBAGS')) end
-- Open the map by pressing |cFF00FFFF%s|r.
NPE_OPENMAP = function(self) return ReplaceEscape(NPE_OPENMAP, GetBindingString('TOGGLEWORLDMAP')) end
-- Press |cFF00FFFF%s|r to open your map and find your corpse.
NPE_FINDCORPSE = function(self) return ReplaceEscape(NPE_FINDCORPSE, GetBindingString('TOGGLEWORLDMAP')) end
-- Quest Complete! Press |cFF00FFFF%s|r to open the map.
NPE_QUESTCOMPLETE = function(self) return ReplaceEscape(NPE_QUESTCOMPLETE, GetBindingString('TOGGLEWORLDMAP')) end
-- Press |cFF00FFFF%s|r to open the map.
NPE_QUESTCOMPLETEBREADCRUMB = function(self) return ReplaceEscape(NPE_QUESTCOMPLETEBREADCRUMB, GetBindingString('TOGGLEWORLDMAP')) end
-- Press |cFF00FFFF%s|r to view your equipped items.
NPE_OPENCHARACTERSHEET = function(self) return ReplaceEscape(NPE_OPENCHARACTERSHEET, GetBindingString('TOGGLECHARACTER0')) end
-- ------------------------------------------------------------------------------------------------------------
-- |cFF00FFFFRight-Click|r {Atlas|NPE_RightClick:16} on the {Atlas|NPE_ExclamationPoint:16} to get your first quest.
NPE_QUESTGIVER = function(self) return ReplaceInteract(NPE_QUESTGIVER) end
-- |cFF00FFFFRight-Click|r {Atlas|NPE_RightClick:16} to loot glowing quest objects.
NPE_OBJECTLOOT = function(self) return ReplaceInteract(NPE_OBJECTLOOT, true) end
-- |cFF00FFFFRight-Click|r to interact with glowing quest objects.
NPE_QUESTOBJECT = function(self) return ReplaceInteract(NPE_QUESTOBJECT, true, true) end
-- |cFF00FFFFRight-click|r {Atlas|NPE_RightClick:16} on sparkling corpses to loot them.
NPE_LOOTCORPSE = function(self) return ReplaceInteract(NPE_LOOTCORPSE) end
-- |cFF00FFFFRight-click|r {Atlas|NPE_RightClick:16} on sparkling corpses to loot quest items.
NPE_LOOTCORPSEQUEST = function(self) return ReplaceInteract(NPE_LOOTCORPSEQUEST) end
-- |cFF00FFFFRight-Click|r {Atlas|NPE_RightClick:16} to interact with characters required by your quest.
NPE_NPCINTERACT = function(self) return ReplaceInteract(NPE_NPCINTERACT) end
-- Items marked with a {Atlas|NPE_ExclamationPoint:16} offer quests.  |cFF00FFFFRight-Click|r {Atlas|NPE_RightClick:16} here to start the quest.
NPE_ITEMQUESTGIVER = function(self) return ReplaceInteract(NPE_ITEMQUESTGIVER, true) end
-- ------------------------------------------------------------------------------------------------------------
-- |cFF00FFFFLeft-Click|r a creature to select it. 
NPE_TARGETFIRSTMOB = function(self, original)
	local binding = GetBindingString('TARGETSCANENEMY') or GetBindingString('TARGETNEARESTENEMY')
	if not binding then return original end
	return NPE_SELECTTARGET .. '   ' .. binding
end
-- ------------------------------------------------------------------------------------------------------------
-- |cFF00FFFFRight-Click|r {Atlas|NPE_RightClick:16} the Hearthstone |TInterface\\Icons\\inv_misc_rune_01:16|t in your bag to teleport back to your home location.
NPE_USEHEARTHSTONE = function(self) return ReplaceUIClick(NPE_USEHEARTHSTONE, 'Right') end


-- ------------------------------------------------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- 						Pointer frame tooltips (loc agnostic): (set true to show original)
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- ------------------------------------------------------------------------------------------------------------


-- |cFF00FFFFLeft-Click|r here to show mouse and keyboard controls.
NPE_SHOWINTERFACEHELP = NPE_CONTROLS
-- |TInterface\\WorldMap\\WorldMapArrow:28:28|t marks your location.|n|n
NPE_MAPCALLOUTBASE = true
-- Go to the {Atlas|NPE_TurnIn} to turn in the quest.
NPE_QUESTCOMPELTELOCATION = true -- (compelte?)
-- |cFF00FFFFRight-Click|r {Atlas|NPE_RightClick:16} to equip this item.
NPE_EQUIPITEM = function(self) return ReplaceUIClick(NPE_EQUIPITEM, 'Right') end
-- |cFF00FFFFLeft-Click|r here to use this item on your quest targets.
NPE_USEQUESTITEM = function(self) return ReplaceUtilityRing(NPE_USEQUESTITEM) end



-- ------------------------------------------------------------------------------------------------------------
--[[ ////////////////////////////////////////// 	OMIT:		\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- ------------------------------------------------------------------------------------------------------------
NPE_ABILITIES = "Abilities";
NPE_ABILITYINITIAL = "|cFF00FFFFLeft-Click|r on |cFF00FFFF%s|r |T%s:16|t to attack the creature.";
NPE_ABILITYINITIAL_WARRIOR = "|cFF00FFFFLeft-Click|r on {$88163} to start attacking.";
NPE_ABILITYLEVEL3_DRUID = "Left-Click {$8921} to deal damage over time.";
NPE_ABILITYLEVEL3_HUNTER = "Left-Click {$883} to summon your pet.";
NPE_ABILITYLEVEL3_MAGE = "Left-Click {$108853} to deal instant damage.";
NPE_ABILITYLEVEL3_MONK = "Left-Click {$100780} to generate Chi.\n\nThen use {$100784} to spend Chi.";
NPE_ABILITYLEVEL3_PALADIN = "Left-Click {$20271} to deal instant damage and make you make your enemy vulnerable.";
NPE_ABILITYLEVEL3_PRIEST = "Left-Click {$589} to curse the enemy, dealing damage over time.";
NPE_ABILITYLEVEL3_ROGUE = "Left-Click {$1752} to generate Combo Points.\n\nThen use {$196819} to spend Combo Points.";
NPE_ABILITYLEVEL3_SHAMAN = "Left-Click {$188389} to deal damage over time.";
NPE_ABILITYLEVEL3_WARLOCK = "Left-Click {$172} to deal damage over time.";
NPE_ABILITYLEVEL3_WARRIOR = "Left-Click {$100} from a distance to rush towards your target.";
NPE_ABILITYREMINDER = "Don't forget to use |cFF00FFFF%s|r |T%s:16|t when attacking.";
NPE_ABILITYREMINDER_WARRIOR = "Use |cFF00FFFF%s|r |T%s:16|t while attacking when you have enough rage.";
NPE_ABILITYSECOND_WARRIOR = "|cFF00FFFFLeft-Click|r on {$1464} to hit your target for heavy damage.";
NPE_ABILITYTRAININGDUMMY = "|cFF00FFFFLeft-Click|r here to use your new ability.";
NPE_ABILITYTRAININGDUMMY_DRUID = "Left-Click {$8921} to deal damage over time.\"";
NPE_ABILITYTRAININGDUMMY_HUNTER = "Left-Click {$56641} when you don't have enough focus for {$3044}.";
NPE_ABILITYTRAININGDUMMY_MAGE = "Left-Click {$122} to stop creatures close to you from moving.";
NPE_ABILITYTRAININGDUMMY_MONK = "Left-Click {$100780} to generate Chi.\n\nThen use {$100787} to spend Chi.";
NPE_ABILITYTRAININGDUMMY_PALADIN = "Left-Click {$105361} to activate your paladin seal and increase your damage.";
NPE_ABILITYTRAININGDUMMY_PRIEST = "Left-Click {$589} to curse the enemy, dealing damage over time.";
NPE_ABILITYTRAININGDUMMY_ROGUE = "Left-Click {$1752} to generate Combo Points.\n\nThen use {$2098} to spend Combo Points.";
NPE_ABILITYTRAININGDUMMY_SHAMAN = "Left-Click {$73899} to deal instant damage.";
NPE_ABILITYTRAININGDUMMY_WARLOCK = "Left-Click {$172} to deal damage over time.";
NPE_ABILITYTRAININGDUMMY_WARRIOR = "Left-Click {$100} from a distance to rush towards your target.";

NPE_SHAPESHIFT_DRUID = "|cFF00FFFFLeft-Click|r on {$768} to shapeshift into cat form.";
NPE_BLOODELFARCANETORRENT = "Use {$129597} on a Mana Wyrm.";
NPE_DRAENEIGIFTOFTHENARARU = "Use {$59542} on the Draenei Survivors.";

NPE_ACCEPTQUEST = "|cFF00FFFFLeft-Click|r here to accept the quest.";
NPE_ACTIONBARCALLOUT = "This is your Action Bar.\n\n|cFF00FFFFLeft-Click|r on the buttons to use your character's abilities.";
NPE_BINDPOINTER = "|cFF00FFFFLeft-Click|r here to make this your home location.";
NPE_CLOSECHARACTERSHEET = "|cFF00FFFFLeft-Click|r here to close.";
NPE_GOSSIPQUESTACTIVE = "|cFF00FFFFLeft-Click|r here to turn in the quest.";
NPE_HEALTHBAR = "These bars show you your |cFF00FFFFHealth|r and |cFF00FFFF%s|r.";
NPE_NPCGOSSIP = "|cFF00FFFFLeft-Click|r here to continue the conversation.";
NPE_GOSSIPQUESTAVAILABLE = "|cFF00FFFFLeft-Click|r here to accept the quest.";
NPE_RELEASESPIRIT = "You died.  |cFF00FFFFLeft-Click|r on Release Spirit to continue.";
NPE_QUESTREWARDCHOICE = "|cFF00FFFFLeft-Click|r on the item you want to receive.";
NPE_RESURRECT = "|cFF00FFFFLeft-Click|r this button to resurrect.";
NPE_TURNINQUEST = "|cFF00FFFFLeft-Click|r here to turn in this quest."; 
NPE_TURNINNOTONMAP = "|cFF00FFFFLeft-Click|r here to see quest locations on the map.";

NPE_QUESTCUSTOM14071A = "|cFF00FFFFLeft-Click|r here to start your Hot Rod.";
NPE_QUESTCUSTOM14098 = "|cFF00FFFFRight-click|r {Atlas|NPE_RightClick:16} on doors to evacuate Frightened Citizens.";
NPE_QUESTCUSTOM14153 = "|cFF00FFFFLeft-Click|r on these abilities to while targeting a Kezan Partygoer to entertain them.";
NPE_QUESTCUSTOM14212A = "|cFF00FFFFRight-click|r {Atlas|NPE_RightClick:16} on Crowley's Horse to mount it.";
NPE_QUESTCUSTOM14212B = "|cFF00FFFFLeft-Click|r here to throw a torch at the Worgen and round them up.";
NPE_QUESTCUSTOM14218 = "|cFF00FFFFRight-Click|r {Atlas|NPE_RightClick:16} to man the Rebel Cannon.";
NPE_QUESTCUSTOM29661 = "|cFF00FFFFRight-click|r {Atlas|NPE_RightClick:16} on the Balance Poles to jump on them.";
]]--
-- ------------------------------------------------------------------------------------------------------------
-- Run init func in case tutorial is already loaded.
NPE:ADDON_LOADED()
-- ------------------------------------------------------------------------------------------------------------
