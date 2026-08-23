local L = select(2, ...).Locale;
---------------------------------------------------------------
-- frFR Français French
---------------------------------------------------------------
---------------------------------------------------------------
-- Short / curated keys
---------------------------------------------------------------
L.ACTIONBAR_FORM_ACTIVE_DESC  = "Cette forme est actuellement active, et ta barre d'action principale affiche les capacités qui lui sont associées."; -- en:b400a632
L.DESC_CAMERAZOOMIN           = 'Zoome la caméra. Maintiens pour un zoom continu.'; -- en:55f9b91f
L.DESC_CAMERAZOOMOUT          = 'Dézoome la caméra. Maintiens pour un zoom continu.'; -- en:a6b9d796
L.DESC_OPENALLBAGS            = 'Ouvre et ferme tous les sacs.'; -- en:4a74797f
L.DESC_TOGGLEWORLDMAP_CLASSIC = 'Bascule la carte du monde.'; -- en:00548e70
L.DESC_TOGGLEWORLDMAP_RETAIL  = 'Bascule la carte du monde combinée et le journal de quêtes.'; -- en:621a94e8
L.FORMAT_HOLD_BINDING         = '%s (maintenir)'; -- en:c3ecd1b3
L.FORMAT_RING_NUMERICAL       = 'Menu radial |cFF00FFFF%s|r'; -- en:68d18518
L.NAME_EASY_MOTION            = "Cibler les cadres d'unité (maintenir)"; -- en:e6f0c131
L.NAME_QUICK_MENU             = 'Menu rapide'; -- en:ed9a0668
L.NAME_RAID_CURSOR_FOCUS      = 'Curseur de raid (focus)'; -- en:d350d370
L.NAME_RAID_CURSOR_TARGET     = 'Curseur de raid (cible)'; -- en:8182d5d5
L.NAME_RAID_CURSOR_TOGGLE     = 'Basculer le curseur de raid'; -- en:79fb9d46
L.NAME_RING_MENU              = 'Menu radial principal'; -- en:8d7e5939
L.NAME_RING_PET               = 'Menu radial du familier'; -- en:8dab5a0e
L.NAME_RING_UTILITY           = 'Menu radial utilitaire'; -- en:96bc880d
L.NAME_UI_CURSOR_TOGGLE       = "Basculer le curseur d'interface"; -- en:2d6091b5
L.RING_EMPTY_DESC             = "Tu n'as encore aucune capacité dans ce menu radial."; -- en:044cf09a
---------------------------------------------------------------
-- Long / curated block entries
---------------------------------------------------------------
L.ACTIONBAR_FORM_DESC = [[Activer cette forme basculera automatiquement ta barre d'action principale pour afficher les capacités associées à cette forme.

La forme partage les raccourcis avec ta barre d'action principale, te permettant d'utiliser tes combos habituels pour accéder aux capacités dans cette forme.

Quand tu quittes cette forme, ta barre d'action principale reviendra à son état précédent, affichant tes capacités habituelles.]]; -- en:a751197a
L.ACTIONBAR_MAIN_DESC = [[La barre d'action principale est ton emplacement principal pour les capacités de rotation et autres actions fréquemment utilisées.

Cette barre est dynamique et peut automatiquement changer de page selon la situation actuelle.

Par exemple, la barre d'action principale basculera vers un ensemble spécial de capacités quand tu entres dans un véhicule, participes à un combat de mascottes, te métamorphoses en une autre forme, entres dans une posture de combat ou prends le contrôle d'une autre unité.

Cela te permet d'accéder à des capacités spécifiques au contexte sans avoir à changer manuellement la configuration de ta barre d'action.

Quand tu retournes à ton état normal, tes capacités habituelles réapparaîtront sur la barre.]]; -- en:8e47cecd
L.ACTIONBAR_PAGE_MISMATCH_DESC = [[Le numéro de page réel d'une barre d'action ne correspond pas toujours au nom affiché, en raison de la conception originale du système de barre d'action.

Cet écart peut être ignoré si tu n'utilises pas de solution de page d'action personnalisée. Les deux sont affichés pour référence.]]; -- en:9fd917fd
L.ADD_NEW_RING_TEXT = [[|cFFFFFF00Créer un nouveau menu radial|r
Choisis un nom pour ton nouveau menu radial :]]; -- en:00af872a
L.CLEAR_RING_TEXT = [[|cFFFFFF00Effacer %s|r
Es-tu sûr de vouloir effacer le menu radial ?]]; -- en:ebc807d8
L.CONTROLS_GAMEPAD_TESTER_ACTION = [[
	Les tests expireront automatiquement après quelques secondes si aucune entrée n'est détectée.
]]; -- en:0f591dc7
L.CONTROLS_GAMEPAD_TESTER_DESC = [[
	Utilise l'outil de test pour vérifier que ta manette fonctionne correctement.

	Le test te demandera d'appuyer sur les boutons et de bouger les axes de ta manette,
	afin de s'assurer que tous les boutons et capteurs fonctionnent comme prévu.

	Dépannage :

	- Assure-toi que ta manette est connectée et reconnue par le système d'exploitation.

	- Vérifie s'il n'y a pas de logiciel conflictuel qui pourrait interférer avec ton appareil,
	tel que Steam fonctionnant en arrière-plan sous Windows.

	- Si tu utilises un ordinateur portable, assure-toi que l'appareil est en mode jeu
	dans le centre de contrôle. Le mode bureau ne fonctionnera pas correctement.

	- Mets à jour les pilotes et installe tout logiciel nécessaire pour ta manette.
]]; -- en:fd1ed2f5
L.CONTROLS_GENERAL_INFO = [[
	Sélectionne ton schéma de contrôle préféré.
]]; -- en:3f779845
L.CONTROLS_MODIFIERS_CUSTOM = [[
	Utilise des paramètres de modificateur personnalisés.

	Il est recommandé d'affecter les modificateurs aux gâchettes ou aux boutons d'épaule, car ce sont les boutons les plus accessibles de la manette.
]]; -- en:964cdf45
L.CONTROLS_MODIFIERS_DESC = [[
	Les modificateurs basculent entre les jeux de raccourcis et émulent aussi les touches de contrôle du clavier (Maj, Ctrl, Alt).

	Maintenir un modificateur basculera temporairement tes raccourcis vers un jeu alternatif, étendant les actions disponibles.

	Les modificateurs peuvent être tapés - pressés et relâchés rapidement - pour exécuter des raccourcis normaux.

	Ils peuvent aussi être combinés entre eux ; utiliser deux modificateurs te donne un total de quatre jeux de raccourcis,
	et trois modificateurs te donnent huit jeux de raccourcis.

	Deux modificateurs suffisent à la plupart des joueurs pour avoir un ensemble confortable de raccourcis,
	sans ajouter trop de complexité.
]]; -- en:b083ec08
L.CONTROLS_MODIFIERS_LEFT = [[
	Utilise des modificateurs gauchers pour garder le déplacement et le changement de jeu de raccourcis sur le côté gauche de la manette.

	Avoir des rôles séparés pour les mains gauche et droite peut aider à l'ergonomie et à la coordination.
]]; -- en:507e5d94
L.CONTROLS_MODIFIERS_TRIGGERS = [[
	Utilise les deux gâchettes comme modificateurs pour diviser tes raccourcis entre le côté gauche et le côté droit.

	Cela peut être bénéfique si tu fais la transition depuis FFXIV, ou si tu préfères le modèle mental crossbar.
]]; -- en:70401fbd
L.CONTROLS_MOUSE_BUTTONS_DESC = [[
	Les boutons de souris peuvent être émulés pour fournir des fonctionnalités similaires à celles d'une souris.

	Ces raccourcis sont vitaux dans certains cas, comme confirmer le placement d'un sort au sol,
	cibler avec précision dans une foule, et les actions d'interface spécifiques.

	Ils peuvent être combinés avec des modificateurs pour reproduire davantage les fonctionnalités d'une souris.

	Ces boutons sont aussi utilisés pour basculer le curseur, qui peut avoir trois états différents :

	- Libre ; tu peux utiliser ta manette pour déplacer le curseur sur l'écran.

	- Centré ; le curseur est fixé au centre de l'écran, pour viser des objets et des personnages
	et pour placer des sorts au sol.

	- Caché ; le curseur reste centré, mais n'est pas visible à l'écran. Sa position est indiquée par un réticule.
]]; -- en:e088d19f
L.CONTROLS_MOUSE_CUSTOM = [[
	Utilise des paramètres de boutons de souris personnalisés.

	World of Warcraft traite les boutons de souris de deux manières distinctes, généralement cachées.

	- Quand tu cliques sur l'interface du jeu (comme les boutons ou les menus), l'interface ne réagit
	qu'aux clics de souris, qui peuvent être émulés par une manette.

	- Quand tu cliques sur des choses dans le monde du jeu (comme le ciblage ou l'interaction), il utilise les raccourcis normaux.

	Il est fortement recommandé de garder ces actions ensemble pour remplir le même rôle qu'une souris.
]]; -- en:3e862670
L.CONTROLS_MOUSE_INVERTED = [[
	Utilise des raccourcis de boutons de souris inversés.

	Utilise le stick gauche pour basculer entre les modes curseur centré et caché, et pour cliquer droit.

	Utilise le stick droit pour basculer le mode curseur libre, et pour cliquer gauche.
]]; -- en:16d3d6d2
L.CONTROLS_MOUSE_REGULAR = [[
	Utilise des raccourcis de boutons de souris normaux.

	Utilise le stick gauche pour basculer le mode curseur libre, et pour cliquer gauche.

	Utilise le stick droit pour basculer entre les modes curseur centré et caché, et pour cliquer droit.
]]; -- en:75e9f21b
L.CONTROLS_MOVEMENT_BALANCED_DESC = [[
	Le déplacement équilibré est un compromis entre les déplacements tank et suivi.

	En combat comme en déplacement, cette configuration effectue un pas chassé jusqu'à 115 degrés dans chaque direction,
	ce qui veut dire que tu fais toujours face à l'avant pendant que tu te déplaces latéralement.

	Si tu déplaces le stick encore plus bas, ton personnage passera à suivre ta direction de déplacement.
	Regarde la tête de ton personnage pour voir dans quelle direction il fait face.

	115 degrés est le réglage idéal pour offrir une couverture maximale sans perte de vitesse de déplacement.
]]; -- en:3355743a
L.CONTROLS_MOVEMENT_DESC = [[
	Les commandes de déplacement peuvent être personnalisées selon ton style de jeu.

	Les manettes utilisent le déplacement analogique, ce qui veut dire que tu peux courir dans n'importe quelle direction,
	et marcher en variant la pression appliquée sur le stick.

	Le jeu s'appuie beaucoup sur le pas chassé comme mécanique,
	où tu te déplaces latéralement tout en faisant face à une direction différente.

	Tu peux personnaliser quand ton personnage passe entre
	le pas chassé et le fait de se tourner pour faire face à ta direction de déplacement.

	Mets en surbrillance une des configurations et bouge ton stick gauche
	pour la tester.
]]; -- en:9d22c4f0
L.CONTROLS_MOVEMENT_FOLLOW_DESC = [[
	Le déplacement « suivi » se concentre sur le suivi de la direction dans laquelle tu te déplaces.

	En combat comme en déplacement, cette configuration n'effectue jamais de pas chassé,
	et ne marche jamais à reculons.

	Cela peut être utile pour les joueurs qui jouent souvent ou toujours avec une configuration à un seul stick.
]]; -- en:45773d56
L.CONTROLS_MOVEMENT_TANK_DESC = [[
	Le déplacement tank se concentre sur le maintien d'une position face à l'avant en combat.

	En combat, cette configuration effectuera toujours un pas chassé, et marchera à reculons pour rester face à l'avant.

	En déplacement, cette configuration suivra toujours la direction de déplacement.
]]; -- en:9fcbcaaf
L.DEFAULTS_BINDINGS_EMPTY_DESC = [[
	Commence à zéro.

	Cette action effacera tous tes raccourcis manette actuels, y compris les défauts de Blizzard,
	pour te permettre de configurer tes raccourcis à partir de zéro.

	Cette action n'écrase pas et n'interfère pas avec les raccourcis clavier existants,
	mais garde à l'esprit que les barres d'action sont partagées entre les deux.

	Si tu prévois de basculer entre le clavier et la manette, il est recommandé de modifier tes
	raccourcis manette plutôt que de déplacer les capacités sur tes barres d'action.
]]; -- en:51053386
L.DEFAULTS_BINDINGS_PRESET_DESC = [[
	Applique les raccourcis recommandés.

	Ces raccourcis sont basés sur tes choix précédents et devraient te donner un bon point de départ
	pour la configuration de ta manette. Tu peux toujours les modifier plus tard.

	Cette action n'écrase pas et n'interfère pas avec les raccourcis clavier existants,
	mais garde à l'esprit que les barres d'action sont partagées entre les deux.

	Si tu prévois de basculer entre le clavier et la manette, il est recommandé de modifier tes
	raccourcis manette plutôt que de déplacer les capacités sur tes barres d'action.
]]; -- en:6ac789b1
L.DEFAULTS_GENERAL_INFO = [[
	Finalise la configuration en appliquant les paramètres et raccourcis recommandés pour ta manette.
]]; -- en:c436023e
L.DEFAULTS_SETTINGS_APPLIED = [[
	Les paramètres recommandés pour ton type de manette (%s) ont été appliqués.
]]; -- en:16be45b5
L.DEFAULTS_SETTINGS_DESC = [[
	Applique les paramètres recommandés pour ton type de manette (%s) :
]]; -- en:15a4050f
L.DEFAULTS_SETTINGS_NOTWEAK = [[
	Ton type de manette (%s) n'a aucun paramètre recommandé à appliquer.
]]; -- en:067a8a20
L.DESC_EASY_MOTION = [[
	Génère des raccourcis d'unité pour tes cadres d'unité affichés à l'écran,
	te permettant de basculer rapidement entre des cibles amicales.

	Pour l'utiliser, maintiens le raccourci, tape ensuite les
	touches indiquées sur ta cible choisie, puis relâche
	le raccourci pour changer de cible.

	Ce raccourci est fortement recommandé aux soigneurs dans le
	contenu à 5 joueurs, car il offre une méthode extrêmement rapide
	pour cibler en petits groupes.

	En raid, la complexité des entrées nécessaires
	pour isoler ta cible préférée peut être intimidante.
	Voir « Basculer le curseur de raid » pour une alternative.
]]; -- en:0f9384b6
L.DESC_EXTRAACTIONBUTTON1 = [[
	Le bouton d'action supplémentaire abrite une capacité temporaire utilisée dans
	diverses quêtes, scénarios et rencontres de boss.

	Quand ce raccourci n'est pas défini, le bouton d'action supplémentaire est toujours
	disponible sur le menu radial utilitaire.

	Ce bouton apparaît sur ta barre d'action manette comme un bouton d'action normal,
	mais tu ne peux pas changer son contenu.
]]; -- en:6dd42998
L.DESC_INTERACTTARGET = [[
	Te permet d'interagir avec les PNJ et les objets du monde du jeu.

	A la même capacité que le curseur centré, mais ne nécessite pas
	de viser le curseur ou le réticule directement sur la cible.

	Les objets interactifs sont mis en évidence quand ils sont à portée.
]]; -- en:b1478add
L.DESC_JUMP = [[
	Peut aussi être utilisé pour nager vers le haut sous l'eau, monter avec
	les montures volantes, et décoller ou battre des ailes vers le haut en montant à dos de dragon.

	Sauter est utile pour combler les lacunes de déplacement pendant une
	action à main gauche qui nécessite ton pouce.

	Dans une configuration normale, le stick gauche contrôle ton déplacement.
	Si tu dois appuyer sur une combinaison du pavé directionnel en déplacement,
	sauter peut servir à maintenir ton élan vers l'avant, tout en relâchant
	brièvement ton pouce du stick.
]]; -- en:4c032315
L.DESC_KEY_BUTTON1 = [[
	Utilisé pour basculer le curseur libre, te permettant d'utiliser ton stick caméra comme un pointeur de souris.
]]; -- en:fd3d111a
L.DESC_KEY_BUTTON2 = [[
	Utilisé pour basculer le curseur centré, te permettant d'interagir avec des objets et des personnages
	dans le monde du jeu, à une position fixe au centre.
]]; -- en:2f5c87e4
L.DESC_QUICK_MENU = [[
	Un menu d'accès rapide qui rassemble les actions courantes effectuées
	pendant le jeu, telles que jeter les dés sur le butin de groupe, annuler
	des améliorations ou utiliser un objet du sac.
]]; -- en:0365846b
L.DESC_RAID_CURSOR = [[
	Bascule un curseur qui s'accroche à tes
	cadres d'unité à l'écran, te permettant de soigner des joueurs amicaux
	tout en maintenant une autre cible.

	Le curseur de raid peut aussi être défini pour cibler directement,
	où déplacer le curseur changera ta cible actuelle.

	Pendant son utilisation, le curseur de raid occupe un ensemble de
	combinaisons du pavé directionnel pour contrôler la position du curseur.

	En mode routage, le curseur ne redirige pas les macros ou
	les sorts ambigus, comme la Pénitence d'un prêtre.

	Voir « Cibler les cadres d'unité » pour une alternative.
]]; -- en:cacdf9c0
L.DESC_RING_CUSTOM = [[
	Un menu radial où tu peux ajouter tes objets, sorts, macros et
	montures pour lesquels tu ne veux pas sacrifier de place sur ta barre d'action.

	Pour l'utiliser, maintiens le raccourci, incline le stick dans la direction
	de l'objet que tu veux sélectionner, puis relâche le raccourci.

	Pour retirer des objets, suis l'invite d'infobulle quand tu as
	l'objet en question en focus.
]]; -- en:159abd06
L.DESC_RING_MENU = [[
	Un menu radial qui regroupe les panneaux courants et les actions fréquentes
	en un seul endroit pour un accès rapide.

	Le menu radial est aussi accessible depuis le menu du jeu sans
	raccourci séparé, en changeant de page.
]]; -- en:7ee244a1
L.DESC_RING_PET = [[
	Un menu radial qui te permet de contrôler ton familier actuel.
]]; -- en:b1c4b5d3
L.DESC_RING_UTILITY = [[
	Un menu radial où tu peux ajouter tes objets, sorts, macros et
	montures pour lesquels tu ne veux pas sacrifier de place sur ta barre d'action.

	Pour l'utiliser, maintiens le raccourci, incline le stick dans la direction
	de l'objet que tu veux sélectionner, puis relâche le raccourci.

	Pour ajouter des objets, suis l'invite du curseur d'interface,
	ou ramasse quelque chose sur ton curseur de souris et appuie sur le raccourci
	pour le déposer dans le menu radial.

	Pour retirer des objets, suis l'invite d'infobulle quand tu as
	l'objet en question en focus.

	Le menu radial utilitaire ajoute automatiquement les objets de quête et les
	capacités temporaires que tu n'as pas placés sur ta barre d'action.
]]; -- en:de107e96
L.DESC_TARGETNEARESTENEMY = [[
	Bascule entre les cibles ennemies les plus proches devant toi.
	Sans cible actuelle, l'ennemi le plus central sera sélectionné.
	Sinon, il fera défiler entre les cibles les plus proches.

	Maintiens pour mettre en évidence les cibles avant de décider
	de changer de cible.

	Recommandé pour une utilisation comme raccourci de ciblage secondaire,
	ou comme raccourci de ciblage principal dans le jeu décontracté ou si
	le scan de cible nécessite trop de précision pour être confortable.

	Non recommandé pour les donjons ou autres scénarios à haute précision.
]]; -- en:981bc29c
L.DESC_TARGETSCANENEMY = [[
	Scanne les ennemis dans un cône étroit devant toi.
	Maintiens pour mettre en évidence les cibles avant de décider
	de changer de cible.

	Particulièrement utile pour changer rapidement de cibles
	en combat avec une grande précision.

	La priorité de cible est biaisée vers la visée, ce qui veut dire que la
	cible la plus proche du centre du cône sera
	sélectionnée en premier. Cela peut résulter en la priorité d'une
	cible éloignée par rapport à une plus proche, si la cible éloignée
	est plus près du centre du cône.

	Recommandé comme raccourci de ciblage principal pour la plupart des joueurs.
]]; -- en:2de05bb9
L.DESC_TOGGLEAUTORUN = [[
	La course automatique fait que ton personnage continue à se déplacer
	dans la direction où il regarde sans aucune entrée de ta part.

	La course automatique soulage le pouce lors de longues phases
	de déplacement, ou libère ton pouce pour faire autre chose pendant que tu te déplaces.
]]; -- en:9e97af4b
L.DESC_TOGGLEGAMEMENU = [[
	Le raccourci menu gère toutes les fonctionnalités qui se produisent en appuyant
	sur la touche Échap d'un clavier. Il gère différentes actions selon
	l'état actuel du jeu.

	Si des actions sont en cours concernant des sorts ou des cibles,
	elles seront annulées. Appuyer sur le raccourci avec une cible active
	l'effacera. Appuyer sur le raccourci pendant l'incantation d'un sort
	interrompra l'incantation.

	Le raccourci gère aussi divers autres cas selon ce qui
	est actuellement affiché à l'écran. Par exemple, si un panneau
	est ouvert, comme le grimoire, le raccourci effectuera
	l'action nécessaire pour le fermer ou le masquer.

	Si aucun des cas ci-dessus ne s'applique, le menu du jeu s'ouvrira ou
	se fermera lorsqu'il est pressé.
]]; -- en:adfccfe4
L.DEVICE_DESC_PLAYSTATION4 = [[
	La manette PlayStation 4, aussi connue sous le nom de DualShock 4, est la manette de génération précédente de Sony.

	C'est une manette riche en fonctionnalités avec un pavé tactile, des contrôles de mouvement, et un support de tous ses boutons dans le jeu.

	Pour profiter de toutes les fonctionnalités, il se peut que tu doives installer PlayStation Accessories (Windows).
]]; -- en:7bea4ad9
L.DEVICE_DESC_PLAYSTATION5 = [[
	La manette PlayStation 5, aussi connue sous le nom de DualSense, est actuellement la meilleure manette pour World of Warcraft.

	C'est la manette la plus complète disponible, avec des contrôles de mouvement, un pavé tactile, et dans le cas de la variante Edge, des palettes arrière natives.
	Tous les boutons de la manette peuvent être utilisés dans le jeu.

	Pour profiter de toutes les fonctionnalités, il se peut que tu doives installer PlayStation Accessories (Windows).
]]; -- en:c5f15091
L.DEVICE_DESC_STEAMDECK = [[
	Les Steam Decks exécutent généralement World of Warcraft via Proton à travers le client Steam.

	En jouant via Steam, l'appareil doit utiliser un profil de jeu qui couvre au moins une disposition Xbox standard.

	Manette avec pavé tactile de souris fournit une base solide.

	Les Steam Decks ne peuvent pas utiliser nativement leurs palettes dans World of Warcraft.
	Les palettes peuvent être mappées via l'émulation, ou avec des touches clavier dans les paramètres Steam Input.

	Le préréglage Steam Deck intégré au jeu peut aussi convenir à d'autres ordinateurs portatifs, en raison de la disposition de contrôle similaire.
]]; -- en:2a5e4173
L.DEVICE_DESC_SWITCHPRO = [[
	La manette Nintendo Switch Pro a une disposition similaire à la manette Xbox, mais avec des étiquettes de boutons inversées.

	La manette Pro a quatre boutons centraux, ce qui lui donne un léger avantage sur une manette Xbox standard.

	La manette Nintendo Switch 2 Pro ne peut pas utiliser nativement ses palettes ou son bouton C dans le jeu.
	Avec un logiciel externe, tel que Steam ou reWASD, ils peuvent être mappés à des touches clavier, permettant leur utilisation en jeu.
]]; -- en:79260874
L.DEVICE_DESC_XBOX = [[
	Les variantes Xbox sont les manettes les plus communes, et sont bien supportées par World of Warcraft.

	La manette Xbox Elite ne peut pas utiliser nativement ses palettes dans le jeu, mais elles peuvent être utilisées pour simuler d'autres boutons de manette,
	à l'aide de l'application Xbox Accessories (Windows).

	Avec un logiciel externe, tel que Steam ou reWASD, les palettes peuvent être mappées à des touches clavier, permettant leur utilisation en jeu.

	Le bouton central est réservé au Xbox Guide, et ne peut pas être utilisé dans le jeu.

	Aussi recommandé pour Steam Input, en cohérence avec la manette Xbox 360 qu'il émule.
]]; -- en:654501d3
L.DISC_KEY_BUTTON1 = [[
	Tant qu'un de tes boutons émule le clic gauche, ce raccourci ne peut pas être modifié.
]]; -- en:e811ebc6
L.DISC_KEY_BUTTON2 = [[
	Tant qu'un de tes boutons émule le clic droit, ce raccourci ne peut pas être modifié.
]]; -- en:b85c78b2
L.EXPORT_DATA_TEXT = [[

|cFFFFFF00Exporter|r

Sélectionne quelles données tu veux exporter. Une chaîne sera générée ci-dessous, que tu peux ensuite coller dans un autre client, ou partager avec d'autres.

Utilise %s pour copier la chaîne.
]]; -- en:1741e6a6
L.GFX_GENERAL_INFO = [[
	Sélectionne les graphismes de manette qui ressemblent le plus à l'apparence de ta manette.

	Le choix des graphismes ne change pas le fonctionnement de ta manette, il change seulement l'apparence de l'interface.

	Les graphismes sont utilisés pour te montrer quels boutons sont actuellement attribués à quelles actions, et pour fournir une référence visuelle de la disposition de ta manette.

	Des recommandations optionnelles de paramètres sont fournies en fonction de ton choix.
]]; -- en:54457360
L.IMPORT_DATA_TEXT = [[

|cFFFFFF00Importer|r

Colle une chaîne exportée ci-dessous, puis charge et sélectionne les données que tu veux importer. Les données importées écraseront tes données actuelles le cas échéant.

Utilise %s pour copier la chaîne depuis la source, et %s pour coller la chaîne ci-dessous.
]]; -- en:145f78fb
L.IMPORT_FAILED_TEXT = [[

|cFFFFFF00Importer|r

Échec de l'importation :
]]; -- en:a7555666
L.LINK_COPY = [[
	Lien vers %s.

	Ctrl+A pour sélectionner et Ctrl+C pour copier.

	Colle (Ctrl+V) le lien dans ton navigateur web.
]]; -- en:3f396345
L.LINK_DISCORD_TEXT = [[
	La communauté où tu peux trouver du soutien, discuter du gameplay, partager des idées et trouver des joueurs partageant les mêmes idées.

	Clique ici pour rejoindre le serveur.
]]; -- en:e2f9740c
L.LINK_PATREON_TEXT = [[
	Le développement et la maintenance de cet addon prennent beaucoup de temps et d'efforts,
	mais ConsolePort restera toujours entièrement gratuit.

	Deviens supporter sur Patreon pour débloquer ton badge Discord, et en retour soutenir l'avenir du projet.

	Clique ici pour devenir un patron.
]]; -- en:3cc9532e
L.LINK_PAYPAL_TEXT = [[
	Les dons sont directement réinvestis dans le développement et la maintenance de l'addon.

	Toute contribution, petite ou grande, est très appréciée.

	Clique ici pour faire un don via PayPal.
]]; -- en:28c6265a
L.REMOVE_RING_TEXT = [[|cFFFFFF00Supprimer %s|r
Es-tu sûr de vouloir supprimer le menu radial ?]]; -- en:1a461a1a
L.RING_MENU_DESC = [[Crée tes propres menus radiaux où tu peux ajouter tes objets, sorts, macros et montures pour lesquels tu ne veux pas sacrifier de place sur ta barre d'action.

Pour l'utiliser, maintiens le raccourci sélectionné, incline le stick dans la direction de l'objet que tu veux sélectionner, puis relâche le raccourci.

Le menu radial par défaut, le |CFF00FF00Menu radial utilitaire|r, a des propriétés spéciales pour faciliter les quêtes et l'interaction avec le monde, et n'est pas statique. Il ajoutera et retirera automatiquement des objets selon les besoins.

Si tu veux créer un menu radial à utiliser dans ta rotation et non simplement pour l'utilitaire, il est fortement recommandé d'utiliser un menu radial personnalisé à cette fin.]]; -- en:39d4577b
L.SELECTED_RING_TEXT = [[C'est ton menu radial actuellement sélectionné.
Quand tu appuies et maintiens le raccourci, toutes tes capacités sélectionnées apparaîtront en menu radial à l'écran.

Incline ton stick radial dans la direction de la capacité ou de l'objet que tu veux utiliser, puis relâche le raccourci pour valider.]]; -- en:2cdfa5d3
L.SET_RING_BINDING_TEXT = [[
|cFFFFFF00Définir le raccourci|r

Appuie sur une combinaison de boutons pour sélectionner un nouveau raccourci pour ce menu radial.

]]; -- en:1c0e03f4
L.SLOT_NO_BINDING = [[
|cFFFFFF00Définir le raccourci|r

%s dans %s, n'a pas de raccourci attribué.

Appuie sur une combinaison de boutons pour sélectionner un nouveau raccourci pour cet emplacement.

]]; -- en:74326275
L.SLOT_SET_BINDING = [[
|cFFFFFF00Définir le raccourci|r

Appuie sur une combinaison de boutons pour sélectionner un nouveau raccourci pour %s.

]]; -- en:d1933130
---------------------------------------------------------------
-- Literals
---------------------------------------------------------------
L['2D deadzone for camera that takes into account pitch and yaw movement together.'] = 'Zone morte 2D pour la caméra prenant en compte les mouvements de tangage et de lacet ensemble.';
L['2D deadzone for movement that takes into account X and Y movement together.'] = 'Zone morte 2D pour le déplacement prenant en compte les mouvements X et Y ensemble.';
L['A button cluster for all modifiers of a single button.'] = "Un cluster de boutons pour tous les modificateurs d'un seul bouton.";
L['A cluster bar with a toolbar below it, laid out horizontally.'] = "Une barre cluster avec une barre d'outils en dessous, disposée horizontalement.";
L['A cluster bar with a toolbar below it.'] = "Une barre cluster avec une barre d'outils en dessous.";
L['A divider to separate elements.'] = 'Un séparateur pour séparer les éléments.';
L['A friendly soft target can be acquired while having an enemy hard target.'] = 'Une cible souple amicale peut être acquise tout en ayant une cible dure ennemie.';
L['A regular action bar.'] = "Une barre d'action régulière.";
L['A ring of buttons for pet commands.'] = 'Un menu radial de boutons pour les commandes du familier.';
L['A toolbar with XP indicators, shortcuts, class specific bars, and miscellaneous information.'] = "Une barre d'outils avec indicateurs d'XP, raccourcis, barres spécifiques à la classe et informations diverses.";
L['About'] = 'À propos';
L['Acceleration of cursor per second as it continues to move.'] = "Accélération du curseur par seconde pendant qu'il continue de se déplacer.";
L['Accent Color'] = "Couleur d'accent";
L['Accept Button'] = 'Bouton Accepter';
L['Action Bar Configuration'] = "Configuration de la barre d'action";
L['Action bar is scaled separately.'] = "La barre d'action est mise à l'échelle séparément.";
L['Action Bar Loadout'] = "Configuration de la barre d'action";
L['Action Bar Loadout (Deprecated)'] = "Configuration de la barre d'action (Obsolète)";
L['Action Bar Presets'] = "Préréglages de barre d'action";
L['Action Bar Setup'] = "Configuration de barre d'action";
L['Action Button'] = "Bouton d'action";
L['Action Button Group'] = "Groupe de boutons d'action";
L['Action Page'] = "Page d'action";
L['Action Page Condition'] = "Condition de page d'action";
L['Action Page Response'] = "Réponse de page d'action";
L['Active Color'] = 'Couleur active';
L['Active Device'] = 'Appareil actif';
L['Add a new element to your loadout.'] = 'Ajoute un nouvel élément à ta configuration.';
L['Add to %s'] = 'Ajouter à %s';
L['Add, remove or reset a frame from cursor stack.'] = 'Ajoute, supprime ou réinitialise un cadre de la pile de curseur.';
L['Affects both mouse and gamepad.'] = 'Affecte à la fois la souris et la manette.';
L['Alignment'] = 'Alignement';
L['Alignment of the counter text on buttons.'] = 'Alignement du texte de compteur sur les boutons.';
L['Alignment of the hotkey text on buttons.'] = 'Alignement du texte de raccourci sur les boutons.';
L['Alignment of the macro text on buttons.'] = 'Alignement du texte de macro sur les boutons.';
L['All combines all connected devices into one.'] = '« Tous » combine tous les appareils connectés en un.';
L['Allow binding discrete radial stick inputs.'] = "Autoriser l'attribution d'entrées de stick radiales discrètes.";
L['Allow binding multiple combos to the same binding.'] = 'Autoriser plusieurs combos liés au même raccourci.';
L['Allow Binding Overlap'] = 'Autoriser le chevauchement de raccourcis';
L['Allow cursor to interact with and show preference for group loot frames.'] = 'Autoriser le curseur à interagir avec et donner la préférence aux cadres de butin de groupe.';
L['Allow cursor to interact with and show preference for popups and static dialogs.'] = 'Autoriser le curseur à interagir avec et donner la préférence aux popups et aux dialogues statiques.';
L['Allow cursor to interact with the entire interface, not only panels.'] = "Autoriser le curseur à interagir avec toute l'interface, pas seulement les panneaux.";
L['Allow Radial Bindings'] = 'Autoriser les raccourcis radiaux';
L['Allows the use of the touchpad to control cursor movement.'] = "Autorise l'utilisation du pavé tactile pour contrôler le déplacement du curseur.";
L['Alphabet to use for dictionary suggestions and word processing.'] = 'Alphabet à utiliser pour les suggestions de dictionnaire et le traitement des mots.';
L['Always keep cursor centered and visible when controlling camera.'] = 'Garder toujours le curseur centré et visible lors du contrôle de la caméra.';
L['Always Show All Buttons'] = 'Toujours afficher tous les boutons';
L['Always Show Mouse Cursor'] = 'Toujours afficher le curseur de souris';
L['Always show nameplate for soft enemy target.'] = 'Toujours afficher la plaque de nom pour la cible souple ennemie.';
L['Always show nameplate for soft friendly target.'] = 'Toujours afficher la plaque de nom pour la cible souple amicale.';
L['Always show tooltip for an automatically acquired target, as long as it exists.'] = "Toujours afficher l'infobulle pour une cible acquise automatiquement, tant qu'elle existe.";
L['An action button in a group.'] = "Un bouton d'action dans un groupe.";
L['Analog Movement'] = 'Déplacement analogique';
L['Anchor'] = 'Ancre';
L['Anchor point of parent to pair with.'] = "Point d'ancrage du parent à apparier.";
L['Anchor point of the counter text on buttons.'] = "Point d'ancrage du texte de compteur sur les boutons.";
L['Anchor point of the hotkey icon on group buttons.'] = "Point d'ancrage de l'icône de raccourci sur les boutons de groupe.";
L['Anchor point of the hotkey text on buttons.'] = "Point d'ancrage du texte de raccourci sur les boutons.";
L['Anchor point of the macro text on buttons.'] = "Point d'ancrage du texte de macro sur les boutons.";
L['Anchor point to attach.'] = "Point d'ancrage auquel s'attacher.";
L['Apply default settings to the current category or all settings.'] = 'Appliquer les paramètres par défaut à la catégorie actuelle ou à tous les paramètres.';
L['Arc Allowance'] = "Tolérance d'arc";
L['Are you sure you want to delete %s from %s?'] = 'Es-tu sûr de vouloir supprimer %s de %s ?';
L['Are you sure you want to overwrite %s with %s?'] = 'Es-tu sûr de vouloir écraser %s avec %s ?';
L['Are you sure you want to regenerate the keyboard dictionary? You will lose all custom phrases.'] = 'Es-tu sûr de vouloir régénérer le dictionnaire du clavier ? Tu perdras toutes les phrases personnalisées.';
L['Are you sure you want to reset all device profiles?'] = "Es-tu sûr de vouloir réinitialiser tous les profils d'appareil ?";
L['Are you sure you want to reset the keyboard layout?'] = 'Es-tu sûr de vouloir réinitialiser la disposition du clavier ?';
L['Are you sure you want to reset your device profile?'] = "Es-tu sûr de vouloir réinitialiser ton profil d'appareil ?";
L['Are you sure you want to wipe the keyboard dictionary? It currently contains %d words.'] = 'Es-tu sûr de vouloir effacer le dictionnaire du clavier ? Il contient actuellement %d mots.';
L['Area where the interact key can find a suitable target.'] = "Zone où la touche d'interaction peut trouver une cible appropriée.";
L['Artwork flavor.'] = "Saveur d'artwork.";
L['Artwork for the interface.'] = "Artwork pour l'interface.";
L['Artwork style.'] = "Style d'artwork.";
L['Assign or clear bindings for this set.'] = 'Attribuer ou effacer les raccourcis pour ce jeu.';
L['Auto-adjusts your camera, allowing you to control movement with a single stick.'] = 'Ajuste automatiquement ta caméra, te permettant de contrôler le déplacement avec un seul stick.';
L['Auto-Sell Gear Level Limit'] = "Limite de niveau d'équipement pour vente automatique";
L['Auto-Sell Junk'] = 'Vendre automatiquement la camelote';
L['Auto-set target to match soft target.'] = 'Définir automatiquement la cible pour correspondre à la cible souple.';
L['Automatic Binding Backups'] = 'Sauvegardes automatiques des raccourcis';
L['Automatic Cursor Timeout'] = 'Délai automatique du curseur';
L['Automatic Tooltip Duration'] = "Durée automatique de l'infobulle";
L['Automatically add tracked quest items and extra spells to main utility ring.'] = 'Ajouter automatiquement les objets de quête suivis et les sorts supplémentaires au menu radial utilitaire principal.';
L['Automatically backup your bindings when you change them, for import and export.'] = "Sauvegarder automatiquement tes raccourcis quand tu les modifies, pour l'importation et l'exportation.";
L['Automatically Bind Extra Items'] = 'Lier automatiquement les objets supplémentaires';
L['Automatically Control Cursor Pickups'] = 'Contrôler automatiquement les ramassages du curseur';
L['Automatically control cursor when picking up items.'] = "Contrôler automatiquement le curseur lors du ramassage d'objets.";
L['Automatically sell junk when interacting with a merchant.'] = "Vendre automatiquement la camelote lors de l'interaction avec un marchand.";
L['Axis Interpretation'] = "Interprétation d'axe";
L['Battery Level'] = 'Niveau de batterie';
L['Binding Catch Timeframe'] = 'Fenêtre de capture de raccourci';
L['Blend Mode'] = 'Mode de fusion';
L['Blend mode of the artwork.'] = "Mode de fusion de l'artwork.";
L['Blizzard_Collections'] = 'Blizzard_Collections';
L['Blizzard_DelvesCompanionConfiguration'] = 'Blizzard_DelvesCompanionConfiguration';
L['Blizzard_HelpPlate'] = 'Blizzard_HelpPlate';
L['Blizzard_HouseEditor'] = 'Blizzard_HouseEditor';
L['Blizzard_HousingTemplates'] = 'Blizzard_HousingTemplates';
L['Blizzard_MapCanvas'] = 'Blizzard_MapCanvas';
L['Blizzard_PlayerSpells'] = 'Blizzard_PlayerSpells';
L['Blizzard_PVPMatch'] = 'Blizzard_PVPMatch';
L['Blizzard_SharedMapDataProviders'] = 'Blizzard_SharedMapDataProviders';
L['Bluetooth'] = 'Bluetooth';
L['Border Vertex Color'] = 'Couleur de sommet de bordure';
L['Breadth'] = 'Largeur';
L['Breadth of the divider.'] = 'Largeur du séparateur.';
L['Button %d'] = 'Bouton %d';
L['Button Set'] = 'Jeu de boutons';
L['Button that emulates '] = 'Bouton qui émule ';
L['Button that emulates the '] = 'Bouton qui émule la ';
L['Button to cancel or exit the quick menu.'] = 'Bouton pour annuler ou quitter le menu rapide.';
L['Button to handle cancel actions, such as exiting menus.'] = "Bouton pour gérer les actions d'annulation, telles que quitter les menus.";
L['Button to handle contextual actions, such as adding items to the utility ring.'] = "Bouton pour gérer les actions contextuelles, telles qu'ajouter des objets au menu radial utilitaire.";
L['Button to insert suggested word.'] = 'Bouton pour insérer le mot suggéré.';
L['Button to move the cursor down.'] = 'Bouton pour déplacer le curseur vers le bas.';
L['Button to move the cursor left.'] = 'Bouton pour déplacer le curseur vers la gauche.';
L['Button to move the cursor right.'] = 'Bouton pour déplacer le curseur vers la droite.';
L['Button to move the cursor up.'] = 'Bouton pour déplacer le curseur vers le haut.';
L['Button to replicate left click. This is the primary interface action.'] = "Bouton pour répliquer le clic gauche. C'est l'action principale d'interface.";
L['Button to replicate right click. This is the secondary interface action.'] = "Bouton pour répliquer le clic droit. C'est l'action secondaire d'interface.";
L['Button to select next suggested word.'] = 'Bouton pour sélectionner le mot suggéré suivant.';
L['Button to select previous suggested word.'] = 'Bouton pour sélectionner le mot suggéré précédent.';
L['Button to use for combo hotkey 1.'] = 'Bouton à utiliser pour le combo raccourci 1.';
L['Button to use for combo hotkey 2.'] = 'Bouton à utiliser pour le combo raccourci 2.';
L['Button to use for combo hotkey 3.'] = 'Bouton à utiliser pour le combo raccourci 3.';
L['Button to use for combo hotkey 4.'] = 'Bouton à utiliser pour le combo raccourci 4.';
L['Button to use for combo hotkey 5.'] = 'Bouton à utiliser pour le combo raccourci 5.';
L['Button to use for combo hotkey 6.'] = 'Bouton à utiliser pour le combo raccourci 6.';
L['Button to use for combo hotkey 7.'] = 'Bouton à utiliser pour le combo raccourci 7.';
L['Button to use for combo hotkey 8.'] = 'Bouton à utiliser pour le combo raccourci 8.';
L['Button to use to erase characters.'] = 'Bouton à utiliser pour effacer des caractères.';
L['Button to use to move the cursor leftwards.'] = 'Bouton à utiliser pour déplacer le curseur vers la gauche.';
L['Button to use to move the cursor rightwards.'] = 'Bouton à utiliser pour déplacer le curseur vers la droite.';
L['Button to use to trigger the enter command.'] = 'Bouton à utiliser pour déclencher la commande Entrée.';
L['Button to use to trigger the escape command.'] = 'Bouton à utiliser pour déclencher la commande Échap.';
L['Button to use to trigger the space command.'] = 'Bouton à utiliser pour déclencher la commande Espace.';
L['Button used to confirm a selected item from a ring.'] = 'Bouton utilisé pour confirmer un objet sélectionné depuis un menu radial.';
L['Button used to remove a selected item from an editable ring.'] = "Bouton utilisé pour retirer un objet sélectionné d'un menu radial éditable.";
L['Button |cFF00FFFF%s|r'] = 'Bouton |cFF00FFFF%s|r';
L['Buttons'] = 'Boutons';
L['Buttons in the cluster bar.'] = 'Boutons dans la barre cluster.';
L['Buttons in the group.'] = 'Boutons dans le groupe.';
L['By default, shows modifiers on mouseover and on cooldown.'] = 'Par défaut, affiche les modificateurs au survol et en temps de recharge.';
L['Camera 2D Deadzone'] = 'Zone morte 2D de caméra';
L['Camera Look'] = 'Regard caméra';
L['Camera Look is a temporary turn of the camera based on the current analog input.'] = "Le regard caméra est une rotation temporaire de la caméra basée sur l'entrée analogique actuelle.";
L['Camera Pitch Axis'] = 'Axe de tangage caméra';
L['Camera Pitch Speed'] = 'Vitesse de tangage caméra';
L['Camera Pitch-Only Deadzone'] = 'Zone morte tangage uniquement caméra';
L['Camera speed for pitch - moving up/down.'] = 'Vitesse de caméra pour le tangage – haut/bas.';
L['Camera speed for yaw - turning left/right.'] = 'Vitesse de caméra pour le lacet – tourner gauche/droite.';
L['Camera Yaw Axis'] = 'Axe de lacet caméra';
L['Camera Yaw Speed'] = 'Vitesse de lacet caméra';
L['Camera Yaw-Only Deadzone'] = 'Zone morte lacet uniquement caméra';
L['Cancel and clear cursor'] = 'Annuler et effacer le curseur';
L['Cancel Button'] = 'Bouton Annuler';
L['Cannot open configuration menu in combat.'] = "Impossible d'ouvrir le menu de configuration en combat.";
L['Casting Bar'] = "Barre d'incantation";
L['Center Gap'] = 'Écart central';
L['Center gap, as fraction of overall crosshair size.'] = 'Écart central, en fraction de la taille globale du réticule.';
L['Change before touchpad moves the cursor.'] = 'Seuil avant que le pavé tactile ne déplace le curseur.';
L['Change bluetooth state for active device.'] = "Changer l'état Bluetooth pour l'appareil actif.";
L['Change or print a value from the active device configuration.'] = "Changer ou afficher une valeur depuis la configuration d'appareil active.";
L['Character Specific'] = 'Spécifique au personnage';
L['Choose a negative value to invert the axis.'] = "Choisis une valeur négative pour inverser l'axe.";
L['Class Bar'] = 'Barre de classe';
L['Clear all items from this set.'] = 'Effacer tous les objets de ce jeu.';
L['Clear Binding'] = 'Effacer le raccourci';
L['Clear configured gamepad bindings and reload interface.'] = "Effacer les raccourcis manette configurés et recharger l'interface.";
L['Clear Focus Deadzone'] = "Zone morte d'effacement de focus";
L['Clear Focus Mode'] = "Mode d'effacement de focus";
L['Clear Focus Time'] = "Temps d'effacement de focus";
L['Clear Slot'] = "Effacer l'emplacement";
L['Clear slot or binding'] = "Effacer l'emplacement ou le raccourci";
L['Click here to reset your device profile.'] = "Clique ici pour réinitialiser ton profil d'appareil.";
L['Click on Down'] = "Clic à l'appui";
L['Click Override Button'] = 'Bouton de remplacement de clic';
L['Click Override Condition'] = 'Condition de remplacement de clic';
L['Cluster Action Bar'] = "Barre d'action cluster";
L['Cluster Handle'] = 'Poignée cluster';
L['Cluster Modifier Toggle'] = 'Bascule de modificateur cluster';
L['Clusters'] = 'Clusters';
L['Color accent of radial menu items.'] = 'Accent de couleur des éléments de menu radial.';
L['Color of a partially selected slice.'] = "Couleur d'une tranche partiellement sélectionnée.";
L['Color of the active slice.'] = 'Couleur de la tranche active.';
L['Color of the cooldown swipe effect on buttons.'] = "Couleur de l'effet de balayage de temps de recharge sur les boutons.";
L['Color of the counter text on buttons.'] = 'Couleur du texte de compteur sur les boutons.';
L['Color of the crosshair.'] = 'Couleur du réticule.';
L['Color of the divider.'] = 'Couleur du séparateur.';
L['Color of the hotkey text on buttons.'] = 'Couleur du texte de raccourci sur les boutons.';
L['Color of the macro text on buttons.'] = 'Couleur du texte de macro sur les boutons.';
L['Color of the main XP bar.'] = "Couleur de la barre d'XP principale.";
L['Color of the mana indicator on buttons.'] = "Couleur de l'indicateur de mana sur les boutons.";
L['Color of the range indicator on buttons.'] = "Couleur de l'indicateur de portée sur les boutons.";
L['Color of the sticky selection slice.'] = 'Couleur de la tranche de sélection collante.';
L['Color of the vertices on the border of buttons.'] = 'Couleur des sommets sur la bordure des boutons.';
L['Color tint for combo hotkey 1.'] = 'Teinte de couleur pour le combo raccourci 1.';
L['Color tint for combo hotkey 2.'] = 'Teinte de couleur pour le combo raccourci 2.';
L['Color tint for combo hotkey 3.'] = 'Teinte de couleur pour le combo raccourci 3.';
L['Color tint for combo hotkey 4.'] = 'Teinte de couleur pour le combo raccourci 4.';
L['Color tint for combo hotkey 5.'] = 'Teinte de couleur pour le combo raccourci 5.';
L['Color tint for combo hotkey 6.'] = 'Teinte de couleur pour le combo raccourci 6.';
L['Color tint for combo hotkey 7.'] = 'Teinte de couleur pour le combo raccourci 7.';
L['Color tint for combo hotkey 8.'] = 'Teinte de couleur pour le combo raccourci 8.';
L['Combine with '] = 'Combiner avec ';
L['Combine with use on demand for full cursor control.'] = 'Combine avec « utilisation à la demande » pour un contrôle complet du curseur.';
L['Combined Input Overlap Time'] = "Temps de chevauchement d'entrée combinée";
L['Combo Button 1'] = 'Bouton combo 1';
L['Combo Button 2'] = 'Bouton combo 2';
L['Combo Button 3'] = 'Bouton combo 3';
L['Combo Button 4'] = 'Bouton combo 4';
L['Combo Button 5'] = 'Bouton combo 5';
L['Combo Button 6'] = 'Bouton combo 6';
L['Combo Button 7'] = 'Bouton combo 7';
L['Combo Button 8'] = 'Bouton combo 8';
L['Combo Color 1'] = 'Couleur combo 1';
L['Combo Color 2'] = 'Couleur combo 2';
L['Combo Color 3'] = 'Couleur combo 3';
L['Combo Color 4'] = 'Couleur combo 4';
L['Combo Color 5'] = 'Couleur combo 5';
L['Combo Color 6'] = 'Couleur combo 6';
L['Combo Color 7'] = 'Couleur combo 7';
L['Combo Color 8'] = 'Couleur combo 8';
L['Command Modifier'] = 'Modificateur de commande';
L['Configure the casting bar.'] = "Configurer la barre d'incantation.";
L['Configure the class related bar.'] = 'Configurer la barre liée à la classe.';
L['Connect your controller.'] = 'Connecte ta manette.';
L['Connected device(s):'] = 'Appareil(s) connecté(s) :';
L['ConsolePort'] = 'ConsolePort';
L['Context Button'] = 'Bouton contextuel';
L['Controls the cutoff range where an interactable target or object can be found.'] = 'Contrôle la portée limite où une cible ou un objet interactif peut être trouvé.';
L['Controls when your character starts running. Expressed as a fraction of your total movement stick radius.'] = 'Contrôle quand ton personnage commence à courir. Exprimé en fraction du rayon total de ton stick de déplacement.';
L['Copy %s from %s:'] = 'Copier %s depuis %s :';
L['Copy this element to a new name.'] = 'Copier cet élément sous un nouveau nom.';
L['Correlation between stick position and pie selection.'] = 'Corrélation entre la position du stick et la sélection en tarte.';
L['Create Binding Preset'] = 'Créer un préréglage de raccourci';
L['Critical, Low, Medium, High, Wired/Charging, or Unknown/Disconnected.'] = 'Critique, Faible, Moyen, Élevé, Filaire/En charge, ou Inconnu/Déconnecté.';
L['Crossbar: Minimal'] = 'Crossbar : Minimal';
L['Crossbar: Triggers'] = 'Crossbar : Gâchettes';
L['Crossbar: Triple'] = 'Crossbar : Triple';
L['Crosshair'] = 'Réticule';
L['Cursor Acceleration'] = 'Accélération du curseur';
L['Cursor acceleration for touchpad control.'] = 'Accélération du curseur pour le contrôle par pavé tactile.';
L['Cursor appears on demand, instead of in response to a panel showing up.'] = "Le curseur apparaît à la demande, au lieu de répondre à l'apparition d'un panneau.";
L['Cursor Center Position'] = 'Position centrale du curseur';
L['Cursor hides when you start moving, if free of obstacles.'] = "Le curseur se cache quand tu commences à te déplacer, s'il n'y a pas d'obstacles.";
L['Cursor Max Speed'] = 'Vitesse maximale du curseur';
L['Cursor Move Threshold'] = 'Seuil de déplacement du curseur';
L['Cursor Reticle Targeting'] = 'Ciblage par réticule de curseur';
L['Cursor Speed'] = 'Vitesse du curseur';
L['Cursor speed for touchpad control.'] = 'Vitesse du curseur pour le contrôle par pavé tactile.';
L['Cursor Start Speed'] = 'Vitesse de départ du curseur';
L['Custom color to use for the touchpad LED.'] = 'Couleur personnalisée à utiliser pour la LED du pavé tactile.';
L['Cyan'] = 'Cyan';
L['Deadzone for simple point-to-select rings.'] = 'Zone morte pour les menus radiaux simples point-à-sélectionner.';
L['Deadzone to clear focus after intercepting stick input.'] = "Zone morte pour effacer le focus après interception de l'entrée de stick.";
L['Decrease'] = 'Diminuer';
L['Decrease lightness'] = 'Diminuer la luminosité';
L['Decrease opacity'] = "Diminuer l'opacité";
L['Default to '] = 'Par défaut sur ';
L['Delay before reactivating interface cursor after leaving combat, in seconds.'] = "Délai avant la réactivation du curseur d'interface après être sorti de combat, en secondes.";
L['Delay before starting to adjust angle when camera control is idle, in seconds.'] = "Délai avant le début de l'ajustement de l'angle lorsque le contrôle de la caméra est inactif, en secondes.";
L['Delay is doubled if you are dead.'] = 'Le délai est doublé si tu es mort.';
L['Delay until a movement is repeated, when holding down a direction, in seconds.'] = "Délai avant qu'un mouvement ne soit répété, lors du maintien d'une direction, en secondes.";
L['Delay until the first movement is repeated, when holding down a direction, in seconds.'] = "Délai avant que le premier mouvement ne soit répété, lors du maintien d'une direction, en secondes.";
L['Delete this element.'] = 'Supprimer cet élément.';
L['Depth'] = 'Profondeur';
L['Depth of the divider.'] = 'Profondeur du séparateur.';
L['Detected %d out of 8 possible sensors.'] = '%d capteurs détectés sur 8 possibles.';
L['Detected %d valid button(s).'] = '%d bouton(s) valide(s) détecté(s).';
L['Device Information'] = "Informations sur l'appareil";
L['Device Mappings'] = "Mappages d'appareil";
L['Device Profiles'] = "Profils d'appareil";
L['Device Selection'] = "Sélection d'appareil";
L['Device Settings'] = "Paramètres d'appareil";
L['Diamond Grid'] = 'Grille en losange';
L['Dictionary Match Alphabet'] = 'Alphabet de correspondance de dictionnaire';
L['Dictionary Match Pattern'] = 'Motif de correspondance de dictionnaire';
L['Direction for flyout buttons, such as portals, poisons, and pet utilities.'] = "Direction pour les boutons d'évent, tels que les portails, les poisons et les utilitaires de familier.";
L['Direction of the button cluster.'] = 'Direction du cluster de boutons.';
L['Disable Drag and Drop'] = 'Désactiver le glisser-déposer';
L['Disable dragging and dropping abilities on action bars.'] = "Désactiver le glisser-déposer des capacités sur les barres d'action.";
L['Disable free-roaming mouse cursor when you jump.'] = 'Désactiver le curseur de souris en mouvement libre quand tu sautes.';
L['Disable free-roaming mouse cursor when you use your sticks.'] = 'Désactiver le curseur de souris en mouvement libre quand tu utilises tes sticks.';
L['Disable Hotkey Rendering'] = 'Désactiver le rendu des raccourcis';
L['Disable if your mouse cursor is invisible.'] = 'Désactive si ton curseur de souris est invisible.';
L['Disable repeated cursor movements - each click will only move the cursor once.'] = "Désactiver les déplacements répétés du curseur – chaque clic ne déplacera le curseur qu'une fois.";
L['Disable Repeated Movement'] = 'Désactiver le déplacement répété';
L['Disable to use discrete legacy movement controls.'] = 'Désactive pour utiliser les commandes de déplacement héritées discrètes.';
L['Disable Wrapping'] = 'Désactiver le bouclage';
L['Disables customization to hotkeys on regular action bars.'] = "Désactive la personnalisation des raccourcis sur les barres d'action régulières.";
L['Disabling this may cause worse performance with many panels open.'] = 'Désactiver ceci peut entraîner de moins bonnes performances avec de nombreux panneaux ouverts.';
L['Disconnected'] = 'Déconnecté';
L['Discord'] = 'Discord';
L['Display icon next to the power level for the current active gamepad.'] = "Afficher l'icône à côté du niveau de batterie pour la manette active actuelle.";
L['Display power level for the current active gamepad.'] = 'Afficher le niveau de batterie pour la manette active actuelle.';
L['Display power level status text for the current active gamepad.'] = "Afficher le texte d'état du niveau de batterie pour la manette active actuelle.";
L['Display the action bar grid when picking up a spell on the cursor.'] = "Afficher la grille de la barre d'action lors du ramassage d'un sort sur le curseur.";
L['Displays a briefing for newly acquired abilities.'] = 'Affiche un briefing pour les capacités nouvellement acquises.';
L['Divider'] = 'Séparateur';
L['Do you want to load settings for %s?'] = 'Veux-tu charger les paramètres pour %s ?';
L['Does not affect actual ability to interact with the target, which may have a different range.'] = "N'affecte pas la capacité réelle à interagir avec la cible, qui peut avoir une portée différente.";
L['Donate via PayPal'] = 'Faire un don via PayPal';
L['Double Tap Modifier'] = 'Modificateur de double-tap';
L['Double Tap Timeframe'] = 'Fenêtre de temps de double-tap';
L['Duration under which a tooltip is displayed for an acquired target or interactable, in milliseconds.'] = 'Durée pendant laquelle une infobulle est affichée pour une cible ou un objet interactif acquis, en millisecondes.';
L['Dynamic Pitch'] = 'Tangage dynamique';
L['Dynamic will use the button set that does not conflict with your '] = "« Dynamique » utilisera le jeu de boutons qui n'entre pas en conflit avec ton ";
L['E.g. '] = 'P. ex. ';
L['Edit Binding'] = 'Modifier le raccourci';
L['Edit Slot'] = "Modifier l'emplacement";
L['Emulate P1 '] = 'Émuler P1 ';
L['Emulate P2 '] = 'Émuler P2 ';
L['Emulate P3 '] = 'Émuler P3 ';
L['Emulate P4 '] = 'Émuler P4 ';
L['Enable all modifier states for the cluster, including unmapped modifiers.'] = 'Activer tous les états de modificateur pour le cluster, y compris les modificateurs non assignés.';
L['Enable Animation'] = "Activer l'animation";
L['Enable casting bar ownership.'] = "Activer la propriété de la barre d'incantation.";
L['Enable class bar ownership.'] = 'Activer la propriété de la barre de classe.';
L['Enable Cooldown Numbers'] = 'Activer les nombres de temps de recharge';
L['Enable Group Loot'] = 'Activer le butin de groupe';
L['Enable interact key to interact with objects and creatures in the game world.'] = "Activer la touche d'interaction pour interagir avec les objets et les créatures du monde du jeu.";
L['Enable interface cursor. Disable to use mouse-based interface interaction.'] = "Activer le curseur d'interface. Désactive pour utiliser l'interaction d'interface basée sur la souris.";
L['Enable Mouse Handling'] = 'Activer la gestion de la souris';
L['Enable Player Interact'] = "Activer l'interaction avec le joueur";
L['Enable Popups'] = 'Activer les popups';
L['Enable separate strafe angle threshold for when your character is in the air.'] = "Activer un seuil d'angle de pas chassé distinct quand ton personnage est dans les airs.";
L['Enable Strafe Angle (Jump)'] = "Activer l'angle de pas chassé (saut)";
L['Enable Tint'] = 'Activer la teinte';
L['Enable touch tap to press touchpad buttons.'] = 'Activer le tap tactile pour appuyer sur les boutons du pavé tactile.';
L['Enable Touchpad Cursor'] = 'Activer le curseur du pavé tactile';
L['Enable Vehicle'] = 'Activer le véhicule';
L['Enable Watch Bars'] = 'Activer les barres de surveillance';
L['Enables a crosshair to reveal your hidden center cursor position at all times.'] = 'Active un réticule pour révéler à tout moment la position de ton curseur centré caché.';
L['Enables a radial on-screen keyboard that can be used to type messages.'] = "Active un clavier radial à l'écran qui peut être utilisé pour taper des messages.";
L['Enemy Soft Targeting'] = 'Ciblage souple ennemi';
L['Equippable items of poor quality will not be sold while your character is below this level.'] = 'Les objets équipables de mauvaise qualité ne seront pas vendus tant que ton personnage est en dessous de ce niveau.';
L['Erase'] = 'Effacer';
L['Exit the vehicle you are currently controlling.'] = 'Quitter le véhicule que tu contrôles actuellement.';
L['Export'] = 'Exporter';
L['Export %s to a string:'] = 'Exporter %s vers une chaîne :';
L['Export action page logic'] = "Exporter la logique de page d'action";
L['Export All'] = 'Tout exporter';
L['Export all your custom presets to a string that can be shared with others.'] = "Exporter tous tes préréglages personnalisés vers une chaîne pouvant être partagée avec d'autres.";
L['Export current options'] = 'Exporter les options actuelles';
L['Export serialized settings for sharing or backup.'] = 'Exporter les paramètres sérialisés pour le partage ou la sauvegarde.';
L['Export this preset to a string that can be shared with others.'] = "Exporter ce préréglage vers une chaîne pouvant être partagée avec d'autres.";
L['Expressed in milliseconds. Pressing any combination of modifier and button will cancel the effect.'] = "Exprimé en millisecondes. Appuyer sur n'importe quelle combinaison de modificateur et de bouton annulera l'effet.";
L['Fade Buttons'] = 'Estomper les boutons';
L['Fade out the pet ring when not moused over.'] = "Estomper le menu radial du familier lorsqu'il n'est pas survolé.";
L['Fade out the watch bars when not mousing over the toolbar.'] = "Estomper les barres de surveillance lorsque la barre d'outils n'est pas survolée.";
L['Fade Watch Bars'] = 'Estomper les barres de surveillance';
L['Filter Condition'] = 'Condition de filtre';
L['Filter condition to find raid cursor frames, as a boolean expression in Lua.'] = "Condition de filtre pour trouver les cadres du curseur de raid, sous forme d'expression booléenne en Lua.";
L['Flavor'] = 'Saveur';
L['Flyout Direction'] = "Direction d'évent";
L['FOAS Adjust Delay'] = "Délai d'ajustement FOAS";
L['FOAS Adjust Ease In'] = 'Entrée progressive FOAS';
L['Follow On A Stick (FOAS)'] = 'Follow On A Stick (FOAS)';
L['Font Flags'] = 'Drapeaux de police';
L['Font flags of the counter text on buttons.'] = 'Drapeaux de police du texte de compteur sur les boutons.';
L['Font flags of the hotkey text on buttons.'] = 'Drapeaux de police du texte de raccourci sur les boutons.';
L['Font flags of the macro text on buttons.'] = 'Drapeaux de police du texte de macro sur les boutons.';
L['Font size of the counter text on buttons.'] = 'Taille de police du texte de compteur sur les boutons.';
L['Font size of the hotkey text on buttons.'] = 'Taille de police du texte de raccourci sur les boutons.';
L['Font size of the macro text on buttons.'] = 'Taille de police du texte de macro sur les boutons.';
L['Font size of the ring slice buttons.'] = 'Taille de police des boutons de tranche du menu radial.';
L['Force Hard Target'] = 'Forcer la cible dure';
L['Frame level of the element.'] = "Niveau de cadre de l'élément.";
L['Frame Level Offset'] = 'Décalage du niveau de cadre';
L['Frame level offset of the hotkey prompt, relative to the unit frame.'] = "Décalage du niveau de cadre de l'invite de raccourci, relatif au cadre d'unité.";
L['Frame strata of the element.'] = "Strate de cadre de l'élément.";
L['Free Cursor Timein'] = 'Apparition du curseur libre';
L['Frees your mouse cursor when used, if the cursor is currently center-fixed or hidden.'] = "Libère ton curseur de souris lorsqu'utilisé, si le curseur est actuellement fixé au centre ou caché.";
L['Friend Soft Targeting'] = 'Ciblage souple ami';
L['Full State Modifier'] = "Modificateur d'état complet";
L['Global color of the tint effect on the toolbar and dividers.'] = "Couleur globale de l'effet de teinte sur la barre d'outils et les séparateurs.";
L['Global Scale'] = 'Échelle globale';
L['Global Visibility'] = 'Visibilité globale';
L['Green'] = 'Vert';
L['Grid'] = 'Grille';
L['Group buttons by modifier in a diamond layout.'] = 'Grouper les boutons par modificateur en disposition en losange.';
L['Group buttons by modifier in a grid layout.'] = 'Grouper les boutons par modificateur en disposition en grille.';
L['Group buttons for left and right triggers, with modifier swapping.'] = 'Grouper les boutons pour les gâchettes gauche et droite, avec basculement de modificateur.';
L['Group buttons in a single crossbar layout, with modifier swapping.'] = 'Grouper les boutons dans une seule disposition crossbar, avec basculement de modificateur.';
L['Group buttons in three layouts, with modifier swapping.'] = 'Grouper les boutons en trois dispositions, avec basculement de modificateur.';
L['Height of the artwork.'] = "Hauteur de l'artwork.";
L['Height of the cluster bar.'] = 'Hauteur de la barre cluster.';
L['Height of the crosshair, in scaled pixel units.'] = "Hauteur du réticule, en unités de pixels mises à l'échelle.";
L['Height of the group.'] = 'Hauteur du groupe.';
L['Hide Cursor on Jump'] = 'Masquer le curseur au saut';
L['Hide Cursor On Movement'] = 'Masquer le curseur en mouvement';
L['Hide Cursor on Stick Input'] = "Masquer le curseur à l'entrée de stick";
L['Hide Flyout Buttons'] = "Masquer les boutons d'évent";
L['Hide Macro Text'] = 'Masquer le texte de macro';
L['Hide the class bar.'] = 'Masquer la barre de classe.';
L['Hide the macro text on buttons.'] = 'Masquer le texte de macro sur les boutons.';
L['Higher is slower.'] = "Plus c'est élevé, plus c'est lent.";
L['Higher values appear on top of lower values. Valid range 0-10000.'] = 'Les valeurs plus élevées apparaissent au-dessus des plus basses. Plage valide 0-10000.';
L['Highlight Color'] = 'Couleur de surbrillance';
L['Horizontal Offset'] = 'Décalage horizontal';
L['Horizontal offset from anchor point.'] = "Décalage horizontal du point d'ancrage.";
L['Horizontal offset of the counter text on buttons.'] = 'Décalage horizontal du texte de compteur sur les boutons.';
L['Horizontal offset of the hotkey icon on group buttons.'] = "Décalage horizontal de l'icône de raccourci sur les boutons de groupe.";
L['Horizontal offset of the hotkey prompt position, in pixels.'] = "Décalage horizontal de la position de l'invite de raccourci, en pixels.";
L['Horizontal offset of the hotkey text on buttons.'] = 'Décalage horizontal du texte de raccourci sur les boutons.';
L['Horizontal offset of the macro text on buttons.'] = 'Décalage horizontal du texte de macro sur les boutons.';
L['Horizontal Padding'] = 'Marge horizontale';
L['Hotkey Anchor'] = 'Ancre de raccourci';
L['Hotkey Offset X'] = 'Décalage X de raccourci';
L['Hotkey Offset Y'] = 'Décalage Y de raccourci';
L['Hotkey prompts appear on applicable name plates.'] = 'Les invites de raccourcis apparaissent sur les plaques de nom applicables.';
L['Hotkey prompts linger on unit frames after targeting.'] = "Les invites de raccourcis persistent sur les cadres d'unité après ciblage.";
L['Hotkey Relative Anchor'] = 'Ancre relative de raccourci';
L['Hotkey Size'] = 'Taille de raccourci';
L['Hotkeys activate their target immediately.'] = 'Les raccourcis activent leur cible immédiatement.';
L['Hotkeys always target the same unit.'] = 'Les raccourcis ciblent toujours la même unité.';
L['Hotkeys control your focus target instead of your current target.'] = 'Les raccourcis contrôlent ta cible de focus au lieu de ta cible actuelle.';
L['Hotkeys use '] = 'Les raccourcis utilisent ';
L['How long the cursor should take to transition from one node to another.'] = "Combien de temps le curseur doit prendre pour passer d'un nœud à un autre.";
L['How to clear focus after intercepting stick input.'] = "Comment effacer le focus après l'interception d'une entrée de stick.";
L['Import serialized preset(s) from an external source.'] = 'Importer des préréglages sérialisés depuis une source externe.';
L['Import serialized preset(s):'] = 'Importer des préréglages sérialisés :';
L['Import serialized settings from an external source.'] = 'Importer des paramètres sérialisés depuis une source externe.';
L['Inactive Opacity'] = 'Opacité inactive';
L['Include the current action page logic in the preset data.'] = "Inclure la logique de page d'action actuelle dans les données du préréglage.";
L['Include the current options from the %s tab in the preset data.'] = "Inclure les options actuelles de l'onglet %s dans les données du préréglage.";
L['Increase'] = 'Augmenter';
L['Increase lightness'] = 'Augmenter la luminosité';
L['Increase opacity'] = "Augmenter l'opacité";
L['Insert Suggestion'] = 'Insérer la suggestion';
L['Intensity'] = 'Intensité';
L['Intensity of the gradient.'] = 'Intensité du dégradé.';
L['Interface Cursor'] = "Curseur d'interface";
L['Interference'] = 'Interférence';
L['Inverted'] = 'Inversé';
L['Join Discord'] = 'Rejoindre Discord';
L['Keeps your character centered to reduce motion sickness.'] = 'Maintient ton personnage centré pour réduire le mal des transports.';
L['Key %d'] = 'Touche %d';
L['Keyboard'] = 'Clavier';
L['Keyboard button to emulate the paddle 1 button.'] = 'Touche clavier pour émuler le bouton palette 1.';
L['Keyboard button to emulate the paddle 2 button.'] = 'Touche clavier pour émuler le bouton palette 2.';
L['Keyboard button to emulate the paddle 3 button.'] = 'Touche clavier pour émuler le bouton palette 3.';
L['Keyboard button to emulate the paddle 4 button.'] = 'Touche clavier pour émuler le bouton palette 4.';
L['Keyboard Layout Editor'] = 'Éditeur de disposition de clavier';
L['Larger value for easier taps.'] = 'Valeur plus grande pour des taps plus faciles.';
L['Layout'] = 'Disposition';
L['LED Color Type'] = 'Type de couleur LED';
L['LED Custom Color'] = 'Couleur LED personnalisée';
L['Load'] = 'Charger';
L['Loaded binding preset %s.'] = 'Préréglage de raccourci %s chargé.';
L['Loadout'] = 'Configuration';
L['Lock Automatic Tooltip'] = "Verrouiller l'infobulle automatique";
L['Looks like a regular action bar, but shows the button combination rather than the action slot.'] = "Ressemble à une barre d'action régulière, mais affiche la combinaison de boutons plutôt que l'emplacement d'action.";
L['Lua pattern to match words for dictionary lookups.'] = 'Motif Lua pour correspondre aux mots pour les recherches de dictionnaire.';
L['Macro condition to automatically load a binding preset by name when the condition applies.'] = "Condition de macro pour charger automatiquement un préréglage de raccourci par son nom lorsque la condition s'applique.";
L['Macro condition to evaluate action bar page.'] = "Condition de macro pour évaluer la page de barre d'action.";
L['Macro condition to override the strafe angle threshold for combat.'] = "Condition de macro pour remplacer le seuil d'angle de pas chassé pour le combat.";
L['Macro condition to override the strafe angle threshold for travel.'] = "Condition de macro pour remplacer le seuil d'angle de pas chassé pour les déplacements.";
L['Macro Text'] = 'Texte de macro';
L['Main Button Border Style'] = 'Style de bordure de bouton principal';
L['Maintain offset relative to scale.'] = "Maintenir le décalage par rapport à l'échelle.";
L['Make sure your choice does not conflict with your bindings.'] = "Assure-toi que ton choix n'entre pas en conflit avec tes raccourcis.";
L['Make this preset the default layout for all new characters.'] = 'Faire de ce préréglage la disposition par défaut pour tous les nouveaux personnages.';
L['Match appropriate soft target to locked target.'] = 'Faire correspondre la cible souple appropriée à la cible verrouillée.';
L['Match criteria for unit pool, each type separated by semicolon.'] = "Critères de correspondance pour le pool d'unités, chaque type séparé par un point-virgule.";
L['Max Pitch'] = 'Tangage max';
L['Max time for a touch to register a tap/click, in milliseconds.'] = "Temps maximum pour qu'un toucher enregistre un tap/clic, en millisecondes.";
L['Max Yaw'] = 'Lacet max';
L['Maximum Pitch adjust for the camera "look" feature.'] = 'Ajustement de tangage maximum pour la fonction « regard » caméra.';
L['Maximum Yaw adjust for the camera "look" feature.'] = 'Ajustement de lacet maximum pour la fonction « regard » caméra.';
L['Menu buttons to display on the toolbar.'] = "Boutons de menu à afficher sur la barre d'outils.";
L['Micro Menu'] = 'Micro-menu';
L['Minimal Interact Nameplate Tooltip'] = "Infobulle minimale d'interaction sur plaque de nom";
L['Modifications'] = 'Modifications';
L['Modifier'] = 'Modificateur';
L['Modifier 1: Shift'] = 'Modificateur 1 : Maj';
L['Modifier 2: Ctrl'] = 'Modificateur 2 : Ctrl';
L['Modifier 3: Alt'] = 'Modificateur 3 : Alt';
L['Modifier Tap Window'] = 'Fenêtre de tap de modificateur';
L['Modifiers'] = 'Modificateurs';
L['Move Left'] = 'Déplacer à gauche';
L['Move one of the sticks.'] = 'Bouge un des sticks.';
L['Move Right'] = 'Déplacer à droite';
L['Movement Deadzone'] = 'Zone morte de déplacement';
L['Movement is analog, translated from your movement stick angle.'] = "Le déplacement est analogique, traduit de l'angle de ton stick de déplacement.";
L['Movement X Axis'] = 'Axe X de déplacement';
L['Movement Y Axis'] = 'Axe Y de déplacement';
L['Needs to be long enough to press and release the button.'] = 'Doit être suffisamment long pour appuyer et relâcher le bouton.';
L['Nested Rings'] = 'Menus radiaux imbriqués';
L['Next Word'] = 'Mot suivant';
L['No axis input detected yet.'] = "Aucune entrée d'axe détectée pour l'instant.";
L['No binding preset named %s exists.'] = "Aucun préréglage de raccourci nommé %s n'existe.";
L['No button input detected yet.'] = "Aucune entrée de bouton détectée pour l'instant.";
L['No buttons were detected during the test.'] = "Aucun bouton n'a été détecté pendant le test.";
L['No sensors were detected.'] = "Aucun capteur n'a été détecté.";
L['Normal background color of pie slices.'] = 'Couleur de fond normale des tranches de tarte.';
L['Normal Color'] = 'Couleur normale';
L['Nudge Modifier'] = 'Modificateur de coup de pouce';
L['Number of buttons in the page.'] = 'Nombre de boutons dans la page.';
L['Number of buttons per row or column.'] = 'Nombre de boutons par ligne ou colonne.';
L['Offset'] = 'Décalage';
L['Offset of pointer arrow, from the selected node center, in pixels.'] = 'Décalage de la flèche pointeur, depuis le centre du nœud sélectionné, en pixels.';
L['Offset X'] = 'Décalage X';
L['Offset Y'] = 'Décalage Y';
L['Offsets the camera horizontally from your character, for a more cinematic view.'] = 'Décale la caméra horizontalement par rapport à ton personnage, pour une vue plus cinématique.';
L['Only recommended for super users.'] = 'Recommandé uniquement pour les super-utilisateurs.';
L['Only use taps for cursor clicks, do not use tap presses.'] = "N'utiliser que des taps pour les clics de curseur, ne pas utiliser de pressions tap.";
L['Opacity of inactive hotkey prompts on unit frames after targeting.'] = "Opacité des invites de raccourcis inactives sur les cadres d'unité après ciblage.";
L['Open Designer'] = 'Ouvrir le concepteur';
L['Open Main Config'] = 'Ouvrir la configuration principale';
L['Open the configuration menu for the action bar.'] = "Ouvrir le menu de configuration de la barre d'action.";
L['Open the main configuration window.'] = 'Ouvrir la fenêtre de configuration principale.';
L['Open the main edit mode window.'] = 'Ouvrir la fenêtre principale du mode édition.';
L['Open the unit menu for the target unit.'] = "Ouvrir le menu d'unité pour l'unité cible.";
L['Open unit menu when interacting with other players.'] = "Ouvrir le menu d'unité lors de l'interaction avec d'autres joueurs.";
L['Optimize Algorithm'] = "Optimiser l'algorithme";
L['or'] = 'ou';
L['Orientation of the page.'] = 'Orientation de la page.';
L['Orthodox'] = 'Orthodoxe';
L['Out of Mana Color'] = 'Couleur en panne de mana';
L['Out of Range Color'] = 'Couleur hors de portée';
L['Outcome'] = 'Résultat';
L['Over Shoulder'] = "Par-dessus l'épaule";
L['Override'] = 'Remplacement';
L['Override Class File'] = 'Fichier de classe de remplacement';
L['Override class theme for interface styling.'] = "Remplacer le thème de classe pour le style d'interface.";
L['Padding between buttons horizontally.'] = 'Marge entre les boutons horizontalement.';
L['Padding between buttons vertically.'] = 'Marge entre les boutons verticalement.';
L['Page'] = 'Page';
L['Page Condition'] = 'Condition de page';
L['Page Hotkeys'] = 'Raccourcis de page';
L['Page Response'] = 'Réponse de page';
L['Page |cFF00FFFF%s|r'] = 'Page |cFF00FFFF%s|r';
L['Patreon'] = 'Patreon';
L['PayPal'] = 'PayPal';
L['Performs an action and closes the menu.'] = 'Effectue une action et ferme le menu.';
L['Performs an action without closing the menu.'] = 'Effectue une action sans fermer le menu.';
L['Pet Ring'] = 'Menu radial du familier';
L['Pick up'] = 'Ramasser';
L['Pickup'] = 'Ramassage';
L['Pitch Axis'] = 'Axe de tangage';
L['Pitch-only deadzone for camera, applied before the 2D deadzone.'] = 'Zone morte tangage uniquement pour la caméra, appliquée avant la zone morte 2D.';
L['Pitches the camera upwards as you zoom out.'] = 'Incline la caméra vers le haut quand tu fais un zoom arrière.';
L['Place in slot'] = "Placer dans l'emplacement";
L['Place on action bar'] = "Placer sur la barre d'action";
L['Play a sound when the pointer arrow reaches its destination.'] = 'Jouer un son quand la flèche du pointeur atteint sa destination.';
L['Please provide a unique name for a new %s in %s:'] = 'Fournis un nom unique pour un nouveau %s dans %s :';
L['Plural Button'] = 'Bouton pluriel';
L['Pointer arrow rotates in the direction of travel.'] = 'La flèche du pointeur tourne dans la direction du déplacement.';
L['Pointer Offset'] = 'Décalage du pointeur';
L['Pointer Size'] = 'Taille du pointeur';
L['Position'] = 'Position';
L['Position of the artwork.'] = "Position de l'artwork.";
L['Position of the button cluster.'] = 'Position du cluster de boutons.';
L['Position of the button.'] = 'Position du bouton.';
L['Position of the class bar.'] = 'Position de la barre de classe.';
L['Position of the cluster bar.'] = 'Position de la barre cluster.';
L['Position of the divider.'] = 'Position du séparateur.';
L['Position of the element.'] = "Position de l'élément.";
L['Position of the group.'] = 'Position du groupe.';
L['Position of the page.'] = 'Position de la page.';
L['Position of the pet ring.'] = 'Position du menu radial du familier.';
L['Position of the toolbar.'] = "Position de la barre d'outils.";
L['Power Level'] = 'Niveau de batterie';
L['Preferred size of radial menus, in pixels.'] = 'Taille préférée des menus radiaux, en pixels.';
L['Preset Load Condition'] = 'Condition de chargement de préréglage';
L['Presets'] = 'Préréglages';
L['Press and Hold'] = 'Appuyer et maintenir';
L['Press your gamepad buttons to test them.'] = 'Appuie sur les boutons de ta manette pour les tester.';
L['Prevent the cursor from wrapping when navigating.'] = 'Empêcher le curseur de boucler lors de la navigation.';
L['Previous Word'] = 'Mot précédent';
L['Primary accept button, to use or confirm a quick menu action.'] = "Bouton d'acceptation principal, pour utiliser ou confirmer une action de menu rapide.";
L['Primary Button'] = 'Bouton principal';
L['Primary Stick'] = 'Stick principal';
L['Prioritize raid cursor bindings over other override bindings.'] = 'Donner la priorité aux raccourcis du curseur de raid sur les autres raccourcis de remplacement.';
L['Priority Override'] = 'Remplacement de priorité';
L['Purple'] = 'Violet';
L['Quick Menu'] = 'Menu rapide';
L['Radial Menus'] = 'Menus radiaux';
L['Raid Cursor'] = 'Curseur de raid';
L['Re-apply config for the active device.'] = "Réappliquer la configuration pour l'appareil actif.";
L['Reactivation Delay'] = 'Délai de réactivation';
L['Recharge'] = 'Recharge';
L['Recommended as first choice modifier.'] = 'Recommandé comme premier choix de modificateur.';
L['Recommended as second choice modifier.'] = 'Recommandé comme deuxième choix de modificateur.';
L['Reduces unexpected camera movement to reduce motion sickness.'] = 'Réduit les mouvements de caméra inattendus pour réduire le mal des transports.';
L['Regenerate Dictionary'] = 'Régénérer le dictionnaire';
L['Regular'] = 'Régulier';
L['Relative Anchor'] = 'Ancre relative';
L['Relative anchor point of the counter text on buttons.'] = "Point d'ancrage relatif du texte de compteur sur les boutons.";
L['Relative anchor point of the hotkey icon on group buttons.'] = "Point d'ancrage relatif de l'icône de raccourci sur les boutons de groupe.";
L['Relative anchor point of the hotkey text on buttons.'] = "Point d'ancrage relatif du texte de raccourci sur les boutons.";
L['Relative anchor point of the macro text on buttons.'] = "Point d'ancrage relatif du texte de macro sur les boutons.";
L['Relative Rescale'] = "Remise à l'échelle relative";
L['Reload'] = 'Recharger';
L['Remove all saved settings and bindings, disable addon, and reload interface.'] = "Supprimer tous les paramètres et raccourcis enregistrés, désactiver l'addon et recharger l'interface.";
L['Remove all saved settings and reload interface.'] = "Supprimer tous les paramètres enregistrés et recharger l'interface.";
L['Remove Button'] = 'Bouton Supprimer';
L['Remove from %s'] = 'Retirer de %s';
L['Remove this set. This action cannot be undone.'] = 'Supprimer ce jeu. Cette action ne peut pas être annulée.';
L['Removes the tooltip background for a minimalistic look.'] = "Supprime le fond d'infobulle pour un look minimaliste.";
L['Repeated Movement Delay'] = 'Délai de déplacement répété';
L['Repeated Movement First Delay'] = 'Premier délai de déplacement répété';
L['Replaces the default loot frame with a custom version optimized for controller navigation.'] = 'Remplace le cadre de butin par défaut par une version personnalisée optimisée pour la navigation à la manette.';
L['Request early landing from the taxi you are currently riding.'] = 'Demander un atterrissage anticipé depuis le taxi que tu chevauches actuellement.';
L['Requires /reload to fully unhook when disabled.'] = 'Nécessite /reload pour se détacher complètement quand désactivé.';
L['Requires a touchpad with LED support.'] = 'Nécessite un pavé tactile avec support LED.';
L['Requires reload.'] = 'Nécessite un rechargement.';
L['Requires Settings > Hide Cursor on Stick Input set to None.'] = "Nécessite Paramètres > « Masquer le curseur à l'entrée de stick » défini sur Aucun.";
L['Requires Toggle Interface Cursor binding to use the cursor.'] = "Nécessite le raccourci « Basculer le curseur d'interface » pour utiliser le curseur.";
L['Reset all mapping configurations and reload. (will not affect bindings)'] = "Réinitialiser toutes les configurations de mappage et recharger. (n'affectera pas les raccourcis)";
L['Response to condition for custom processing.'] = 'Réponse à la condition pour le traitement personnalisé.';
L['Reticle targeting means anything you place on the ground.'] = 'Le ciblage par réticule signifie tout ce que tu places au sol.';
L['Reticle targeting uses free cursor instead of staying center-fixed.'] = 'Le ciblage par réticule utilise le curseur libre au lieu de rester fixé au centre.';
L['Return Button'] = 'Bouton Retour';
L['Returns to the previous menu.'] = 'Retourne au menu précédent.';
L['Reverse Mouse Handling'] = 'Inverser la gestion de la souris';
L['Reverse Order'] = "Inverser l'ordre";
L['Reverse the order of the buttons.'] = "Inverser l'ordre des boutons.";
L['Ring Manager'] = 'Gestionnaire de menus radiaux';
L['Ring Scale'] = 'Échelle du menu radial';
L['Ring Size'] = 'Taille du menu radial';
L['Rings'] = 'Menus radiaux';
L['Rings (Account)'] = 'Menus radiaux (compte)';
L['Rings (Character)'] = 'Menus radiaux (personnage)';
L['Rotation'] = 'Rotation';
L['Rotation of the divider.'] = 'Rotation du séparateur.';
L['Run / Walk Threshold'] = 'Seuil de course / marche';
L['Run Tests'] = 'Lancer les tests';
L['Save as default'] = 'Enregistrer comme défaut';
L['Save preset from %s:'] = 'Enregistrer le préréglage depuis %s :';
L['Save your current loadout to the preset list.'] = 'Enregistrer ta configuration actuelle dans la liste des préréglages.';
L['Scale of all radial menus, relative to UI scale.'] = "Échelle de tous les menus radiaux, relative à l'échelle de l'interface.";
L['Scale of most ConsolePort frames, relative to UI scale.'] = "Échelle de la plupart des cadres ConsolePort, relative à l'échelle de l'interface.";
L['Scale of the cursor.'] = 'Échelle du curseur.';
L['Scale of the game menu and radial companion.'] = 'Échelle du menu du jeu et du compagnon radial.';
L['Scale of the keyboard.'] = 'Échelle du clavier.';
L['Scale of the pet ring.'] = 'Échelle du menu radial du familier.';
L['Secondary accept button, to use or confirm a quick menu action.'] = "Bouton d'acceptation secondaire, pour utiliser ou confirmer une action de menu rapide.";
L['Select a device from the list to continue.'] = 'Sélectionne un appareil dans la liste pour continuer.';
L['Select a slot to bind %s and place this spell.'] = 'Sélectionne un emplacement pour lier %s et placer ce sort.';
L['Select a slot to place this spell.'] = 'Sélectionne un emplacement pour placer ce sort.';
L['Select the device you want to configure.'] = "Sélectionne l'appareil que tu veux configurer.";
L['Select the device you want to use.'] = "Sélectionne l'appareil que tu veux utiliser.";
L['Selecting an item on a ring will stick until another item is chosen.'] = "La sélection d'un objet sur un menu radial restera collée jusqu'à ce qu'un autre objet soit choisi.";
L['Sensors'] = 'Capteurs';
L['Set %d |cFF757575(%s)|r'] = 'Jeu %d |cFF757575(%s)|r';
L['Set binding'] = 'Définir le raccourci';
L['Sets if range should be a hard cutoff, even for something you can interact with.'] = 'Définit si la portée doit être une coupure dure, même pour quelque chose avec lequel tu peux interagir.';
L['Shift-click to Edit Binding'] = 'Maj+clic pour modifier le raccourci';
L['Shift-right-click to Clear Binding'] = 'Maj+clic droit pour effacer le raccourci';
L['Show a color tint on the toolbar.'] = "Afficher une teinte colorée sur la barre d'outils.";
L['Show Ability Briefings'] = 'Afficher les briefings de capacité';
L['Show Action Bar Grid on Spell Pickup'] = "Afficher la grille de barre d'action lors du ramassage d'un sort";
L['Show active buffs in the quick menu.'] = 'Afficher les buffs actifs dans le menu rapide.';
L['Show active debuffs in the quick menu.'] = 'Afficher les debuffs actifs dans le menu rapide.';
L['Show All Action Bars'] = "Afficher toutes les barres d'action";
L['Show all enabled combinations in the cluster at all times.'] = 'Afficher toutes les combinaisons activées dans le cluster en permanence.';
L['Show bonus bar configuration for characters without stances.'] = 'Afficher la configuration de la barre bonus pour les personnages sans postures.';
L['Show Centered Cursor Tooltip'] = "Afficher l'infobulle du curseur centré";
L['Show connected devices.'] = 'Afficher les appareils connectés.';
L['Show Default Button'] = 'Afficher le bouton par défaut';
L['Show Enemy Nameplate'] = 'Afficher la plaque de nom ennemie';
L['Show Enemy Target Icon'] = "Afficher l'icône de cible ennemie";
L['Show Enemy Tooltip'] = "Afficher l'infobulle ennemie";
L['Show Flyout Buttons'] = "Afficher les boutons d'évent";
L['Show Flyouts'] = 'Afficher les évents';
L['Show Friendly Nameplate'] = 'Afficher la plaque de nom amicale';
L['Show Friendly Target Icon'] = "Afficher l'icône de cible amicale";
L['Show Friendly Tooltip'] = "Afficher l'infobulle amicale";
L['Show Gauge'] = 'Afficher la jauge';
L['Show help for command(s).'] = "Afficher l'aide pour la/les commande(s).";
L['Show Hotkeys'] = 'Afficher les raccourcis';
L['Show icon above the current enemy soft target.'] = "Afficher l'icône au-dessus de la cible souple ennemie actuelle.";
L['Show icon above the current friendly soft target.'] = "Afficher l'icône au-dessus de la cible souple amicale actuelle.";
L['Show icon above the current interactable object.'] = "Afficher l'icône au-dessus de l'objet interactif actuel.";
L['Show icon above the current interactable target.'] = "Afficher l'icône au-dessus de la cible interactive actuelle.";
L['Show interact binding hint on interactables.'] = "Afficher l'indication de raccourci d'interaction sur les objets interactifs.";
L['Show Interact Hint'] = "Afficher l'indication d'interaction";
L['Show interact tooltip on nameplates, when applicable.'] = "Afficher l'infobulle d'interaction sur les plaques de nom, le cas échéant.";
L['Show item type in the quick menu.'] = "Afficher le type d'objet dans le menu rapide.";
L['Show Main Icons'] = 'Afficher les icônes principales';
L['Show Modifier Icons'] = 'Afficher les icônes de modificateur';
L['Show numerical cooldown text on buttons.'] = 'Afficher le texte numérique de temps de recharge sur les boutons.';
L['Show Object Icon'] = "Afficher l'icône d'objet";
L['Show on Name Plates'] = 'Afficher sur les plaques de nom';
L['Show pet action bar in the quick menu.'] = "Afficher la barre d'action du familier dans le menu rapide.";
L['Show ping commands in the quick menu.'] = 'Afficher les commandes de ping dans le menu rapide.';
L['Show Portrait'] = 'Afficher le portrait';
L['Show portrait for the current unit, with health percentage and applicable spell casts.'] = "Afficher le portrait pour l'unité actuelle, avec le pourcentage de santé et les incantations applicables.";
L['Show Status Text'] = "Afficher le texte d'état";
L['Show Target Icon'] = "Afficher l'icône de cible";
L['Show the default mouse action button.'] = "Afficher le bouton d'action de souris par défaut.";
L['Show the empty buttons in the page.'] = 'Afficher les boutons vides dans la page.';
L['Show the flyout of small buttons for the button cluster.'] = "Afficher l'évent des petits boutons pour le cluster de boutons.";
L['Show the hotkeys on the buttons.'] = 'Afficher les raccourcis sur les boutons.';
L['Show the icons for main buttons.'] = 'Afficher les icônes pour les boutons principaux.';
L['Show the icons for modifier buttons.'] = 'Afficher les icônes pour les boutons modificateurs.';
L['Show the pet power and health status.'] = "Afficher l'état de puissance et de santé du familier.";
L['Show the pet ring when in a vehicle.'] = 'Afficher le menu radial du familier quand tu es dans un véhicule.';
L['Show the watch bars at the bottom of the toolbar.'] = "Afficher les barres de surveillance en bas de la barre d'outils.";
L['Show Tooltip'] = "Afficher l'infobulle";
L['Show tooltip for enemy target.'] = "Afficher l'infobulle pour la cible ennemie.";
L['Show tooltip for friendly target.'] = "Afficher l'infobulle pour la cible amicale.";
L['Show tooltip for interactables.'] = "Afficher l'infobulle pour les objets interactifs.";
L['Show tooltip for mouseover targets when cursor is centered.'] = "Afficher l'infobulle pour les cibles survolées quand le curseur est centré.";
L['Show tooltips on buttons when moused over.'] = 'Afficher les infobulles sur les boutons au survol.';
L['Show Type Icon'] = "Afficher l'icône de type";
L['Size of pointer arrow, in pixels.'] = 'Taille de la flèche du pointeur, en pixels.';
L['Size of the button cluster.'] = 'Taille du cluster de boutons.';
L['Size of the hotkey icon on group buttons.'] = "Taille de l'icône de raccourci sur les boutons de groupe.";
L['Size of unit hotkeys, in pixels.'] = "Taille des raccourcis d'unité, en pixels.";
L['Space'] = 'Espace';
L['Speed of cursor when it starts moving.'] = 'Vitesse du curseur quand il commence à se déplacer.';
L['Split stack'] = 'Diviser la pile';
L['Start moving the configuration window.'] = 'Commencer à déplacer la fenêtre de configuration.';
L['Starting point of the page.'] = 'Point de départ de la page.';
L['Status Bar'] = "Barre d'état";
L['Stick to use for main radial actions.'] = 'Stick à utiliser pour les actions radiales principales.';
L['Sticky Color'] = 'Couleur collante';
L['Sticky Selection'] = 'Sélection collante';
L['Strafe Angle (Combat)'] = 'Angle de pas chassé (combat)';
L['Strafe Angle (Jump)'] = 'Angle de pas chassé (saut)';
L['Strafe Angle (Travel)'] = 'Angle de pas chassé (déplacement)';
L['Strafe Angle Macro Condition (Combat)'] = "Condition macro d'angle de pas chassé (combat)";
L['Strafe Angle Macro Condition (Travel)'] = "Condition macro d'angle de pas chassé (déplacement)";
L['Strata'] = 'Strate';
L['Stride'] = 'Foulée';
L['Style of the border around main buttons.'] = 'Style de la bordure autour des boutons principaux.';
L['Support on Patreon'] = 'Soutenir sur Patreon';
L['Swap to a specified action bar layout.'] = "Basculer vers une disposition de barre d'action spécifiée.";
L['Swipe Color'] = 'Couleur de balayage';
L['Switch Button'] = 'Bouton Basculer';
L['Switches between the main menu and the radial companion.'] = 'Bascule entre le menu principal et le compagnon radial.';
L['Synchronize Bindings'] = 'Synchroniser les raccourcis';
L['Synchronize Config'] = 'Synchroniser la configuration';
L['Take ownership of, and move the micro menu buttons to the toolbar.'] = "Prendre possession et déplacer les boutons du micro-menu vers la barre d'outils.";
L['Takes the format of...\n[condition] Preset Name; nil\n\nAuto-saved presets are named "Character (Specialization) Realm", using class instead of specialization on Classic.\n\nThe preset loads outside of combat when the condition applies. Character presets take precedence over device presets.'] = [[Prend le format de…
[condition] Nom du préréglage; nil

Les préréglages sauvegardés automatiquement sont nommés "Personnage (Spécialisation) Royaume", avec la classe au lieu de la spécialisation sur Classic.

Le préréglage se charge hors combat lorsque la condition s'applique. Les préréglages de personnage ont priorité sur les préréglages d'appareil.]];
L['Taps for cursor clicks are right clicks instead of left.'] = 'Les taps pour les clics de curseur sont des clics droits au lieu de gauches.';
L['Target enemies automatically by looking at them.'] = 'Cibler les ennemis automatiquement en les regardant.';
L['Target friends automatically by looking at them.'] = 'Cibler les amis automatiquement en les regardant.';
L['Target Match Lock'] = 'Verrou de correspondance de cible';
L['Target Range'] = 'Portée de cible';
L['Target Range Hard Cutoff'] = 'Coupure dure de portée de cible';
L['Targeting Mode'] = 'Mode de ciblage';
L['Test Device'] = "Tester l'appareil";
L['The analog input for forward/back movement.'] = "L'entrée analogique pour le déplacement avant/arrière.";
L['The analog input for left/right Camera Yaw "look" feature.'] = "L'entrée analogique pour la fonction « regard » lacet caméra gauche/droite.";
L['The analog input for left/right Camera Yaw.'] = "L'entrée analogique pour le lacet caméra gauche/droite.";
L['The analog input for left/right movement.'] = "L'entrée analogique pour le déplacement gauche/droite.";
L['The analog input for up/down Camera Pitch "look" feature.'] = "L'entrée analogique pour la fonction « regard » tangage caméra haut/bas.";
L['The analog input for up/down Camera Pitch.'] = "L'entrée analogique pour le tangage caméra haut/bas.";
L['The configuration is accessible by the chat command %s or from the game menu.'] = 'La configuration est accessible par la commande de chat %s ou depuis le menu du jeu.';
L['The modifier can be used to nudge the cursor position with the directional pad.'] = 'Le modificateur peut être utilisé pour donner un coup de pouce à la position du curseur avec le pavé directionnel.';
L['The modifier can be used to scroll together with the directional pad.'] = 'Le modificateur peut être utilisé pour faire défiler avec le pavé directionnel.';
L['The quick menu binding can be used to close the menu as well.'] = 'Le raccourci du menu rapide peut aussi être utilisé pour fermer le menu.';
L['The time it takes to transition from idle camera control to auto-adjustment (FOAS).'] = "Le temps qu'il faut pour passer du contrôle de caméra inactif à l'ajustement automatique (FOAS).";
L['Thickness'] = 'Épaisseur';
L['Thickness in scaled pixel units.'] = "Épaisseur en unités de pixels mises à l'échelle.";
L['Thickness of the divider.'] = 'Épaisseur du séparateur.';
L['This button is necessary to use or sell an item directly from your bags.'] = 'Ce bouton est nécessaire pour utiliser ou vendre un objet directement depuis tes sacs.';
L['This feature is only available in Classic.'] = "Cette fonctionnalité n'est disponible qu'en Classic.";
L['This only affects gamepad bindings.'] = "Cela n'affecte que les raccourcis de manette.";
L['This will not affect your bindings, interface settings or system-wide settings.'] = "Cela n'affectera pas tes raccourcis, paramètres d'interface ou paramètres système.";
L['This will not work with Xbox controllers connected via bluetooth. The Xbox Adapter is required.'] = "Cela ne fonctionnera pas avec les manettes Xbox connectées via Bluetooth. L'adaptateur Xbox est requis.";
L['Time in milliseconds for the opacity to change from one state to another.'] = "Temps en millisecondes pour que l'opacité passe d'un état à un autre.";
L['Time in seconds to automatically hide centered cursor.'] = 'Temps en secondes pour masquer automatiquement le curseur centré.';
L['Time in seconds to enable free cursor.'] = 'Temps en secondes pour activer le curseur libre.';
L['Time to clear focus after intercepting stick input, in seconds.'] = "Temps pour effacer le focus après l'interception d'une entrée de stick, en secondes.";
L['Timeframe to catch a binding in the configuration, in seconds.'] = 'Délai pour capturer un raccourci dans la configuration, en secondes.';
L['Timeframe to toggle the mouse cursor when double-tapping a selected modifier.'] = "Délai pour basculer le curseur de souris lors d'un double-tap d'un modificateur sélectionné.";
L['Timeout clears focus after a set time, deadzone clears focus when stick input is neutral.'] = "Le délai efface le focus après un temps défini, la zone morte efface le focus quand l'entrée de stick est neutre.";
L['Tint Color'] = 'Couleur de teinte';
L['Toggle visibility of all modifier flyouts for cluster action bars.'] = "Basculer la visibilité de tous les évents de modificateur pour les barres d'action cluster.";
L['Toggle visibility of all modifier flyouts.'] = 'Basculer la visibilité de tous les évents de modificateur.';
L['Toolbar'] = "Barre d'outils";
L['Tooltip'] = 'Infobulle';
L['Top speed of cursor movement.'] = 'Vitesse maximale de déplacement du curseur.';
L['Touch Tap Buttons'] = 'Boutons de tap tactile';
L['Touch Tap Exclusive Click'] = 'Clic exclusif au tap tactile';
L['Touch Tap Max Time'] = 'Temps max de tap tactile';
L['Touch Tap Right Click'] = 'Clic droit de tap tactile';
L['Touchpad'] = 'Pavé tactile';
L['Transition'] = 'Transition';
L['Transition time for opacity changes.'] = "Temps de transition pour les changements d'opacité.";
L['Travel Time'] = 'Temps de déplacement';
L['Trigger button actions on press instead of release.'] = "Déclencher les actions de bouton à l'appui plutôt qu'au relâchement.";
L['Triggers'] = 'Gâchettes';
L['Turn Character With Camera'] = 'Tourner le personnage avec la caméra';
L['Turn your character facing when you turn your camera angle.'] = 'Tourner la direction face de ton personnage quand tu tournes ton angle de caméra.';
L['Type of LED color to use for the touchpad.'] = 'Type de couleur LED à utiliser pour le pavé tactile.';
L['Types are PlayStation, Xbox, or Generic.'] = 'Les types sont PlayStation, Xbox ou Générique.';
L['Unit Hotkeys'] = "Raccourcis d'unité";
L['Unit Pool'] = "Pool d'unités";
L['Unknown device selected.'] = 'Appareil inconnu sélectionné.';
L['Unlimited Navigation'] = 'Navigation illimitée';
L['Unmapped keyboard key(s) detected:'] = 'Touche(s) de clavier non mappée(s) détectée(s) :';
L['Use a custom set of buttons for the game menu, otherwise the button set will be dynamically determined.'] = 'Utilise un jeu personnalisé de boutons pour le menu du jeu, sinon le jeu de boutons sera déterminé dynamiquement.';
L['Use a targeting binding to turn a soft target into a hard target.'] = 'Utiliser un raccourci de ciblage pour transformer une cible souple en cible dure.';
L['Use character specific addon settings for this character.'] = "Utiliser les paramètres d'addon spécifiques au personnage pour ce personnage.";
L['Use Custom Button Set'] = 'Utiliser un jeu de boutons personnalisé';
L['Use Custom Loot Frame'] = 'Utiliser un cadre de butin personnalisé';
L['Use Default Hotkey Icons'] = 'Utiliser les icônes de raccourcis par défaut';
L['Use Focus Mode'] = 'Utiliser le mode focus';
L['Use Global Loot Tooltip'] = "Utiliser l'infobulle de butin globale";
L['Use Hardware Mouse Cursor'] = 'Utiliser le curseur de souris matériel';
L['Use Instant Mode'] = 'Utiliser le mode instantané';
L['Use Interact Nameplate Tooltip'] = "Utiliser l'infobulle d'interaction sur plaque de nom";
L['Use On Demand'] = 'Utiliser à la demande';
L['Use optimized pathfinding algorithm for cursor movement.'] = 'Utiliser un algorithme optimisé de recherche de chemin pour le déplacement du curseur.';
L['Use press and hold to navigate and use rings. Press, point, release.'] = 'Utilise « appuyer et maintenir » pour naviguer et utiliser les menus radiaux. Appuie, pointe, relâche.';
L['Use Static Mode'] = 'Utiliser le mode statique';
L['Use the hardware cursor provided by the operating system.'] = "Utiliser le curseur matériel fourni par le système d'exploitation.";
L['Use together with [@cursor] macros to place reticle spells in a single click.'] = 'À utiliser avec les macros [@cursor] pour placer les sorts au réticule en un seul clic.';
L['Used for interacting with the world, at a center-fixed position.'] = 'Utilisé pour interagir avec le monde, à une position fixée au centre.';
L['Uses global tint color when transparent.'] = 'Utilise la couleur de teinte globale quand transparent.';
L['Uses the default hotkey icons instead of the custom icons provided by ConsolePort.'] = 'Utilise les icônes de raccourcis par défaut au lieu des icônes personnalisées fournies par ConsolePort.';
L['Valid Action Deadzone'] = "Zone morte d'action valide";
L['Value below two may appear interlaced or not at all.'] = 'Une valeur inférieure à deux peut apparaître entrelacée ou pas du tout.';
L['Vertical Offset'] = 'Décalage vertical';
L['Vertical offset from anchor point.'] = "Décalage vertical du point d'ancrage.";
L['Vertical offset of the counter text on buttons.'] = 'Décalage vertical du texte de compteur sur les boutons.';
L['Vertical offset of the hotkey icon on group buttons.'] = "Décalage vertical de l'icône de raccourci sur les boutons de groupe.";
L['Vertical offset of the hotkey prompt position, in pixels.'] = "Décalage vertical de la position de l'invite de raccourci, en pixels.";
L['Vertical offset of the hotkey text on buttons.'] = 'Décalage vertical du texte de raccourci sur les boutons.';
L['Vertical offset of the macro text on buttons.'] = 'Décalage vertical du texte de macro sur les boutons.';
L['Vertical Padding'] = 'Marge verticale';
L['Vertical position of centered cursor & targeting, as fraction of screen height.'] = "Position verticale du curseur centré et du ciblage, en fraction de la hauteur de l'écran.";
L['Visibility Condition'] = 'Condition de visibilité';
L['Watch bars include XP, reputation, honor, artifact power, and azerite.'] = "Les barres de surveillance incluent l'XP, la réputation, l'honneur, le pouvoir d'artefact et l'azérite.";
L['When disabled, a button press will also act as a cursor click.'] = 'Quand désactivé, un appui sur un bouton agira aussi comme un clic du curseur.';
L['When disabled, you will need to press the accept button to confirm a selection.'] = "Quand désactivé, tu devras appuyer sur le bouton d'acceptation pour confirmer une sélection.";
L['When enabled, a tap will act as a button press.'] = 'Quand activé, un tap agira comme un appui sur un bouton.';
L['When set to both sticks, cursor only disables when both sticks are used together.'] = 'Quand défini sur les deux sticks, le curseur ne se désactive que quand les deux sticks sont utilisés ensemble.';
L['Whether client keybindings should be saved to the server.'] = 'Si les raccourcis clavier du client doivent être enregistrés sur le serveur.';
L['Whether the keyboard should always be shown or only when a gamepad is active.'] = 'Si le clavier doit toujours être affiché ou seulement quand une manette est active.';
L['Whether to save character- and account-scoped variables to the server.'] = 'Si les variables au niveau du personnage et du compte doivent être enregistrées sur le serveur.';
L['Which button set to use for unit hotkeys.'] = "Quel jeu de boutons utiliser pour les raccourcis d'unité.";
L['Which modifier to use for modified commands.'] = 'Quel modificateur utiliser pour les commandes modifiées.';
L['Which modifier to use for nudging the cursor.'] = 'Quel modificateur utiliser pour donner un coup de pouce au curseur.';
L['Which modifier to use to toggle the mouse cursor when double-tapped.'] = "Quel modificateur utiliser pour basculer le curseur de souris lors d'un double-tap.";
L['Which modifier to use with the movement buttons to move the cursor.'] = 'Quel modificateur utiliser avec les boutons de déplacement pour déplacer le curseur.';
L['While disabled, cursor timeout, and toggling between free-roaming and center-fixed cursor are also disabled.'] = 'Quand désactivé, le délai du curseur et le basculement entre curseur libre et fixé au centre sont aussi désactivés.';
L['While held down, can simulate dragging by clicking on the directional pad.'] = 'Tant que maintenu, peut simuler le glisser en cliquant sur le pavé directionnel.';
L['Width of the artwork.'] = "Largeur de l'artwork.";
L['Width of the cluster bar.'] = 'Largeur de la barre cluster.';
L['Width of the crosshair, in scaled pixel units.'] = "Largeur du réticule, en unités de pixels mises à l'échelle.";
L['Width of the group.'] = 'Largeur du groupe.';
L['Width of the toolbar.'] = "Largeur de la barre d'outils.";
L['Wipe Dictionary'] = 'Effacer le dictionnaire';
L['Wired'] = 'Filaire';
L['Works like a regular action bar, which displays the action slots of a specified action page.'] = "Fonctionne comme une barre d'action régulière, qui affiche les emplacements d'action d'une page d'action spécifiée.";
L['X Offset'] = 'Décalage X';
L['XP Bar Color'] = "Couleur de la barre d'XP";
L['Y Offset'] = 'Décalage Y';
L['Yaw Axis'] = 'Axe de lacet';
L['Yaw-only deadzone for camera, applied before the 2D deadzone.'] = 'Zone morte lacet uniquement pour la caméra, appliquée avant la zone morte 2D.';
L['your current loadout'] = 'ta configuration actuelle';
---------------------------------------------------------------
-- Literal block entries
---------------------------------------------------------------
L['%s is already bound to\n%s\n\nDo you want to change it to\n%s?'] = [[%s est déjà attribué à
%s

Veux-tu le changer pour
%s ?]];
L['+ Normal\n- Inverted'] = [[+ Normal
- Inversé]];
L['Basic redirect cannot route macros or ambiguous spells. Use target mode or focus mode with [@focus] macros to control behavior.'] = [[La redirection basique ne peut pas router les macros ou les sorts ambigus. Utilise le mode cible ou le mode focus avec des macros [@focus] pour contrôler le comportement.]];
L['Button or combination used to click when a given condition applies, but act as a normal binding otherwise.'] = [[Bouton ou combinaison utilisé pour cliquer quand une condition donnée s'applique, mais agir comme un raccourci normal sinon.]];
L['Button to handle contextual actions, such as adding items to the utility ring or passing on loot.'] = [[Bouton pour gérer les actions contextuelles, telles qu'ajouter des objets au menu radial utilitaire ou passer sur le butin.]];
L['Buttons emulating modifiers will instead trigger bindings when pressed and released within the time span.'] = [[Les boutons émulant des modificateurs déclencheront plutôt des raccourcis quand pressés et relâchés dans le délai imparti.]];
L['Change how the raid cursor acquires a target. Redirect and focus modes will reroute appropriate spells without changing your target.'] = [[Change la façon dont le curseur de raid acquiert une cible. Les modes redirection et focus redirigeront les sorts appropriés sans changer ta cible.]];
L['Controls when your character transitions from strafing to facing your movement stick direction while in combat. Expressed in degrees, from looking straight forward.'] = [[Contrôle quand ton personnage passe du pas chassé au tournage vers la direction de ton stick de déplacement en combat. Exprimé en degrés, depuis le regard droit devant.]];
L['Controls when your character transitions from strafing to facing your movement stick direction while in the air. Expressed in degrees, from looking straight forward.'] = [[Contrôle quand ton personnage passe du pas chassé au tournage vers la direction de ton stick de déplacement en l'air. Exprimé en degrés, depuis le regard droit devant.]];
L['Controls when your character transitions from strafing to facing your movement stick direction. Expressed in degrees, from looking straight forward.'] = [[Contrôle quand ton personnage passe du pas chassé au tournage vers la direction de ton stick de déplacement. Exprimé en degrés, depuis le regard droit devant.]];
L['Duration after using gamepad and mouse at the same time before switching to just one or the other, in milliseconds.'] = [[Durée après l'utilisation simultanée de la manette et de la souris avant de basculer vers l'un ou l'autre, en millisecondes.]];
L['Enable custom mouse handling, automating cursor toggling and timeout while using left and right mouse button emulation.'] = [[Activer la gestion de souris personnalisée, automatisant le basculement et le délai du curseur lors de l'utilisation de l'émulation des boutons gauche et droit de la souris.]];
L['Explicit only matches hard locked targets through using a targeting binding, while implicit matches targets you attack.'] = [[Explicite ne correspond qu'aux cibles verrouillées en dur via l'utilisation d'un raccourci de ciblage, tandis qu'implicite correspond aux cibles que tu attaques.]];
L['Groups button combinations in circular clusters which switch between different actions when modifiers are used.'] = [[Groupe les combinaisons de boutons en clusters circulaires qui basculent entre différentes actions quand des modificateurs sont utilisés.]];
L['Left mouse button emulation toggles center-fixed mode instead of free-roaming mode. Right mouse button emulation toggles free-roaming mode instead of center-fixed mode.'] = [[L'émulation du bouton gauche de la souris bascule le mode fixé au centre au lieu du mode mouvement libre. L'émulation du bouton droit de la souris bascule le mode mouvement libre au lieu du mode fixé au centre.]];
L['Macro condition to enable the click override button. The default condition clicks right mouse button when there is no enemy target.'] = [[Condition de macro pour activer le bouton de remplacement de clic. La condition par défaut clique sur le bouton droit de la souris quand il n'y a pas de cible ennemie.]];
L['Modifiers should be in descending order. M2M1, for example, is the Ctrl and Shift modifiers held at the same time.'] = [[Les modificateurs doivent être dans l'ordre descendant. M2M1, par exemple, ce sont les modificateurs Ctrl et Maj maintenus en même temps.]];
L['Opacity is expressed in percentage, where 100 is fully visible and 0 is fully transparent. Values outside of the 0-100 range will be clamped.'] = [[L'opacité est exprimée en pourcentage, où 100 est entièrement visible et 0 entièrement transparent. Les valeurs hors de la plage 0-100 seront limitées.]];
L['Pointer arrow rotates in the direction of travel, and portraits scale up and down on movement.'] = [[La flèche du pointeur tourne dans la direction du déplacement, et les portraits agrandissent et rétrécissent en mouvement.]];
L['Show group loot rolls in the quick menu, allowing you to roll on items using gamepad buttons while in combat.'] = [[Afficher les jets de butin de groupe dans le menu rapide, te permettant de jeter les dés sur les objets avec les boutons de manette en combat.]];
L['Takes the format of...\n'] = [[Prend le format de…
]];
L['The bindings underlying the button combinations will be unavailable while the cursor is in use.\n\nModifier can also be configured on a per button basis.'] = [[Les raccourcis sous-jacents aux combinaisons de boutons seront indisponibles tant que le curseur est utilisé.

Le modificateur peut aussi être configuré bouton par bouton.]];
L['Use a shoulder button combined with crosshair for smooth and precise interactions. The click is performed at crosshair or cursor location.'] = [[Utilise un bouton d'épaule combiné au réticule pour des interactions fluides et précises. Le clic est effectué à l'emplacement du réticule ou du curseur.]];
L['Use global game tooltip for loot information, allowing other addons to add information to lootable items.'] = [[Utiliser l'infobulle de jeu globale pour les informations de butin, permettant à d'autres addons d'ajouter des informations aux objets pillables.]];
L['When set to zero, always face your movement stick direction.\nWhen set to max, never face your movement stick direction.'] = [[Quand défini à zéro, fais toujours face à ta direction de stick de déplacement.
Quand défini à max, ne fais jamais face à ta direction de stick de déplacement.]];
L['Your %s device has separate handling for Bluetooth and wired connection.\nWhich one are you using?'] = [[Ton appareil %s a une gestion séparée pour les connexions Bluetooth et filaire.
Laquelle utilises-tu ?]];
