local _, UI, MEDIA = ...
local _, class = UnitClass("player")
local cc = RAID_CLASS_COLORS[class]
local PT = [[Interface\AddOns\ConsolePortUI\Media\]]
----------------------------------
MEDIA = {
----------------------------------
	TEXTURES = {
		BG_MAGE 		= {a = "Artifacts-MageArcane-BG"},
		BG_PALADIN 		= {a = "Artifacts-Paladin-BG"},
		BG_WARRIOR 		= {a = "Artifacts-Warrior-BG"},
		BG_DRUID 		= {a = "Artifacts-Druid-BG"},
		BG_DEATHKNIGHT 	= {a = "Artifacts-DeathKnightFrost-BG"},
		BG_HUNTER 		= {a = "Artifacts-Hunter-BG"},
		BG_PRIEST 		= {a = "Artifacts-Priest-BG"},
		BG_ROGUE 		= {a = "Artifacts-Rogue-BG"},
		BG_SHAMAN 		= {a = "Artifacts-Shaman-BG"},
		BG_WARLOCK 		= {a = "Artifacts-Warlock-BG"},
		BG_MONK 		= {a = "Artifacts-Monk-BG"},
		BG_DEMONHUNTER	= {a = "Artifacts-DemonHunter-BG"},	
	----------------------------------
		CB_MAGE 		= {a = "Artifacts-MageArcane-ClassBadge"},
		CB_PALADIN 		= {a = "Artifacts-Paladin-ClassBadge"},
		CB_WARRIOR 		= {a = "Artifacts-Warrior-ClassBadge"},
		CB_DRUID 		= {a = "Artifacts-Druid-ClassBadge"},
		CB_DEATHKNIGHT 	= {a = "Artifacts-DeathKnightFrost-ClassBadge"},
		CB_HUNTER 		= {a = "Artifacts-Hunter-ClassBadge"},
		CB_PRIEST 		= {a = "Artifacts-Priest-ClassBadge"},
		CB_ROGUE 		= {a = "Artifacts-Rogue-ClassBadge"},
		CB_SHAMAN 		= {a = "Artifacts-Shaman-ClassBadge"},
		CB_WARLOCK 		= {a = "Artifacts-Warlock-ClassBadge"},
		CB_MONK 		= {a = "Artifacts-Monk-ClassBadge"},
		CB_DEMONHUNTER	= {a = "Artifacts-DemonHunter-ClassBadge"},
	----------------------------------
		Menu_BG = {
			t = PT..[[Textures\Window\Menu-BG.blp]]},
		Gradient = {
			c = {0, 1, 0, 1},
			t = [[Interface\AddOns\ConsolePort\Textures\Window\Gradient]]},
	},
----------------------------------
	BACKDROPS = {
		GOSSIP_BG = {
			bgFile = PT..[[Textures\Button\Backdrop_Gossip.blp]],
			edgeFile = PT..[[Textures\Button\Edge_Gossip_BG.blp]],
			edgeSize = 8,
			insets = {left = 2, right = 2, top = 8, bottom = 8}
		},
		GOSSIP_NORMAL = {
			edgeFile = PT..[[Textures\Button\Edge_Gossip_Normal.blp]],
			edgeSize = 8,
			insets = {left = 5, right = 5, top = -10, bottom = 7}
		},
		GOSSIP_HILITE = {
			edgeFile = PT..[[Textures\Button\Edge_Gossip_Hilite.blp]],
			edgeSize = 8,
			insets = {left = 5, right = 5, top = 5, bottom = 6}
		},
		TALKBOX = {
			bgFile = PT..[[Textures\Button\Backdrop_Talkbox.blp]],
			edgeFile = PT..[[Textures\Button\Edge_Talkbox_BG.blp]],
			edgeSize = 32,
			insets = { left = 32, right = 32, top = 32, bottom = 32 }
		},
		SCROLLBG = {
			bgFile = PT..[[Textures\Button\Backdrop_Talkbox.blp]],
			edgeFile = PT..[[Textures\Button\Edge_Talkbox_BG.blp]],
			edgeSize = 16,
			insets = { left = 16, right = 16, top = 16, bottom = 16 }
		},
		TOOLTIP_BG = {
			bgFile = PT..[[Textures\Button\Backdrop_Talkbox.blp]],
			edgeFile = PT..[[Textures\Button\Edge_Talkbox_BG.blp]],
			edgeSize = 8,
			insets = { left = 8, right = 8, top = 8, bottom = 8 }
		},
	},
----------------------------------
}
----------------------------------

UI.Media = {
	CC = cc,
	GetBackdrop = function(_, ID) return MEDIA.BACKDROPS[ID] end,
	GetTextureStruct = function(_, ID) return MEDIA.TEXTURES[ID] end,
	GetTexCoord = function(_, ID) return MEDIA.TEXTURES[ID] and MEDIA.TEXTURES[ID].c end,
	GetTexture = function(_, ID) return MEDIA.TEXTURES[ID] and MEDIA.TEXTURES[ID].t end,
	SetBackdrop = function(_, region, ID) region:SetBackdrop(MEDIA.BACKDROPS[ID]) end,
	SetTexture = function(_, region, ID)
		local m = MEDIA.TEXTURES[ID]
		if m then
			if m.a then region:SetAtlas(m.a) end
			if m.c then region:SetTexCoord(unpack(m.c)) end
			if m.t then region:SetTexture(m.t) end
			if m.v then region:SetVertexColor(unpack(m.v)) end
		end
	end,
}