local L = select(2, ...).Locale;
---------------------------------------------------------------
-- deDE Deutsch German
---------------------------------------------------------------
---------------------------------------------------------------
-- Short / curated keys
---------------------------------------------------------------
L.ACTIONBAR_FORM_ACTIVE_DESC  = 'Diese Form ist derzeit aktiv und deine Hauptaktionsleiste zeigt die zugehörigen Fähigkeiten an.'; -- en:b400a632
L.DESC_CAMERAZOOMIN           = 'Zoomt die Kamera heran. Halten für stufenloses Zoomen.'; -- en:55f9b91f
L.DESC_CAMERAZOOMOUT          = 'Zoomt die Kamera heraus. Halten für stufenloses Zoomen.'; -- en:a6b9d796
L.DESC_OPENALLBAGS            = 'Öffnet und schließt alle Taschen.'; -- en:4a74797f
L.DESC_TOGGLEWORLDMAP_CLASSIC = 'Schaltet die Weltkarte an oder aus.'; -- en:00548e70
L.DESC_TOGGLEWORLDMAP_RETAIL  = 'Schaltet die kombinierte Weltkarte und das Questlog an oder aus.'; -- en:621a94e8
L.FORMAT_HOLD_BINDING         = '%s (Halten)'; -- en:c3ecd1b3
L.FORMAT_RING_NUMERICAL       = 'Ring |cFF00FFFF%s|r'; -- en:68d18518
L.NAME_EASY_MOTION            = 'Einheitenfenster anvisieren (Halten)'; -- en:e6f0c131
L.NAME_QUICK_MENU             = 'Schnellmenü'; -- en:ed9a0668
L.NAME_RAID_CURSOR_FOCUS      = 'Schlachtzugscursor (Fokus)'; -- en:d350d370
L.NAME_RAID_CURSOR_TARGET     = 'Schlachtzugscursor (Ziel)'; -- en:8182d5d5
L.NAME_RAID_CURSOR_TOGGLE     = 'Schlachtzugscursor umschalten'; -- en:79fb9d46
L.NAME_RING_MENU              = 'Menü-Ring'; -- en:8d7e5939
L.NAME_RING_PET               = 'Begleiter-Ring'; -- en:8dab5a0e
L.NAME_RING_UTILITY           = 'Werkzeug-Ring'; -- en:96bc880d
L.NAME_UI_CURSOR_TOGGLE       = 'Interface-Cursor umschalten'; -- en:2d6091b5
L.RING_EMPTY_DESC             = 'Du hast noch keine Fähigkeiten in diesem Ring.'; -- en:044cf09a
---------------------------------------------------------------
-- Long / curated block entries
---------------------------------------------------------------
L.ACTIONBAR_FORM_DESC = [[Das Aktivieren dieser Form schaltet deine Hauptaktionsleiste automatisch auf die zugehörigen Fähigkeiten um.

Die Form teilt sich Belegungen mit deiner Hauptaktionsleiste, sodass du mit deinen gewohnten Kombinationen auf die Fähigkeiten dieser Form zugreifen kannst.

Wenn du diese Form verlässt, kehrt deine Hauptaktionsleiste in ihren vorherigen Zustand zurück und zeigt deine üblichen Fähigkeiten an.]]; -- en:a751197a
L.ACTIONBAR_MAIN_DESC = [[Die Hauptaktionsleiste ist dein primärer Platz für Rotationsfähigkeiten und andere häufig genutzte Aktionen.

Diese Leiste ist dynamisch und kann je nach Situation automatisch zu verschiedenen Seiten wechseln.

Zum Beispiel wechselt die Hauptaktionsleiste zu einem speziellen Satz Fähigkeiten, wenn du in ein Fahrzeug einsteigst, an einem Haustierkampf teilnimmst, dich in eine andere Form verwandelst, eine Kampfhaltung einnimmst oder die Kontrolle über eine andere Einheit übernimmst.

So kannst du auf kontextspezifische Fähigkeiten zugreifen, ohne deine Aktionsleisten manuell ändern zu müssen.

Kehrst du in den Normalzustand zurück, erscheinen deine üblichen Fähigkeiten wieder auf der Leiste.]]; -- en:8e47cecd
L.ACTIONBAR_PAGE_MISMATCH_DESC = [[Die tatsächliche Seitenzahl einer Aktionsleiste stimmt nicht immer mit dem angezeigten Namen überein – ein Erbe des ursprünglichen Designs des Aktionsleistensystems.

Diese Abweichung kann ignoriert werden, wenn du keine eigene Aktionsseiten-Lösung verwendest. Beide werden zur Referenz angezeigt.]]; -- en:9fd917fd
L.ADD_NEW_RING_TEXT = [[|cFFFFFF00Neuen Ring erstellen|r
Bitte wähle einen Namen für deinen neuen Ring:]]; -- en:00af872a
L.CLEAR_RING_TEXT = [[|cFFFFFF00%s leeren|r
Bist du sicher, dass du den Ring leeren möchtest?]]; -- en:ebc807d8
L.CONTROLS_GAMEPAD_TESTER_ACTION = [[
	Die Tests laufen nach wenigen Sekunden ab, wenn keine Eingabe erkannt wird.
]]; -- en:0f591dc7
L.CONTROLS_GAMEPAD_TESTER_DESC = [[
	Nutze das Test-Werkzeug, um zu prüfen, ob dein Gamepad korrekt funktioniert.

	Der Test fordert dich auf, Tasten zu drücken und Achsen an deinem Gamepad zu bewegen,
	um sicherzustellen, dass alle Tasten und Sensoren wie erwartet funktionieren.

	Fehlerbehebung:

	- Stelle sicher, dass dein Gamepad angeschlossen und vom Betriebssystem erkannt ist.

	- Prüfe, ob andere Software stört, die mit deinem Gerät interagiert,
	z. B. Steam, das unter Windows im Hintergrund läuft.

	- Bei Handheld-PCs stelle sicher, dass das Gerät im Spielmodus läuft
	(im Kontrollzentrum). Der Desktop-Modus funktioniert nicht korrekt.

	- Aktualisiere Treiber und installiere alle nötigen Programme für dein Gamepad.
]]; -- en:fd1ed2f5
L.CONTROLS_GENERAL_INFO = [[
	Wähle dein bevorzugtes Steuerungsschema.
]]; -- en:3f779845
L.CONTROLS_MODIFIERS_CUSTOM = [[
	Verwende benutzerdefinierte Modifikator-Einstellungen.

	Es empfiehlt sich, Modifikatoren auf die Schultertasten oder Trigger zu legen, da diese am leichtesten erreichbar sind.
]]; -- en:964cdf45
L.CONTROLS_MODIFIERS_DESC = [[
	Modifikatoren wechseln zwischen Belegungssätzen und emulieren außerdem die Steuertasten der Tastatur (Umschalt, Strg, Alt).

	Das Halten eines Modifikators tauscht deine Belegungen vorübergehend gegen einen alternativen Satz aus und erweitert deine verfügbaren Aktionen.

	Modifikatoren können angetippt werden – kurz gedrückt und losgelassen – um reguläre Belegungen auszuführen.

	Sie können auch miteinander kombiniert werden; zwei Modifikatoren ergeben insgesamt vier Belegungssätze,
	und drei Modifikatoren ergeben acht Belegungssätze.

	Zwei Modifikatoren reichen den meisten Spielern für einen komfortablen Belegungsumfang,
	ohne zu viel Komplexität.
]]; -- en:b083ec08
L.CONTROLS_MODIFIERS_LEFT = [[
	Verwende linkshändige Modifikatoren, um Bewegung und Belegungssatzwechsel auf der linken Gamepad-Seite zu halten.

	Separate Rollen für linke und rechte Hand können bei Ergonomie und Koordination helfen.
]]; -- en:507e5d94
L.CONTROLS_MODIFIERS_TRIGGERS = [[
	Verwende beide Trigger als Modifikatoren, um deine Belegungen zwischen linker und rechter Seite aufzuteilen.

	Dies kann hilfreich sein, wenn du von FFXIV umsteigst oder das Crossbar-Konzept bevorzugst.
]]; -- en:70401fbd
L.CONTROLS_MOUSE_BUTTONS_DESC = [[
	Maustasten können emuliert werden, um mausähnliche Funktionen bereitzustellen.

	Diese Belegungen sind in einigen Fällen entscheidend, z. B. zum Bestätigen von Zauberplatzierungen am Boden,
	präzises Zielen in Menschenmengen und Nischenaktionen im Interface.

	Sie können mit Modifikatoren kombiniert werden, um die Funktion einer Maus weiter zu replizieren.

	Diese Tasten werden auch zum Umschalten des Cursors verwendet, der drei verschiedene Zustände haben kann:

	- Frei; du kannst dein Gamepad zum Bewegen des Cursors auf dem Bildschirm verwenden.

	- Zentriert; der Cursor ist mittig fixiert, um auf Objekte und Charaktere zu zielen
	und Zauber am Boden zu platzieren.

	- Versteckt; der Cursor ist weiterhin zentriert, aber nicht sichtbar. Seine Position wird durch ein Fadenkreuz angezeigt.
]]; -- en:e088d19f
L.CONTROLS_MOUSE_CUSTOM = [[
	Verwende benutzerdefinierte Maustasten-Einstellungen.

	World of Warcraft behandelt Maustasten in zwei separaten, größtenteils verborgenen Wegen.

	- Wenn du auf das Spiel-Interface (wie Tasten oder Menüs) klickst, reagiert das Interface nur
	auf Mausklicks, die ein Gamepad emulieren kann.

	- Wenn du auf Dinge in der Spielwelt klickst (z. B. Zielen oder Interagieren), werden reguläre Belegungen verwendet.

	Es wird dringend empfohlen, diese Aktionen zusammen zu halten, damit sie dieselbe Rolle wie eine Maus erfüllen.
]]; -- en:3e862670
L.CONTROLS_MOUSE_INVERTED = [[
	Verwende invertierte Maustasten-Belegungen.

	Nutze den linken Stick, um zwischen zentriertem und verstecktem Cursor-Modus zu wechseln und für Rechtsklick.

	Nutze den rechten Stick, um den freien Cursor-Modus umzuschalten und für Linksklick.
]]; -- en:16d3d6d2
L.CONTROLS_MOUSE_REGULAR = [[
	Verwende reguläre Maustasten-Belegungen.

	Nutze den linken Stick, um den freien Cursor-Modus umzuschalten und für Linksklick.

	Nutze den rechten Stick, um zwischen zentriertem und verstecktem Cursor-Modus zu wechseln und für Rechtsklick.
]]; -- en:75e9f21b
L.CONTROLS_MOVEMENT_BALANCED_DESC = [[
	Die ausgewogene Bewegung ist ein Kompromiss zwischen Tank- und Folge-Bewegung.

	Sowohl im Kampf als auch unterwegs strafft diese Konfiguration bis zu 115 Grad in jede Richtung,
	d. h. du blickst noch nach vorne, während du dich seitwärts bewegst.

	Bewegst du den Stick weiter nach unten, wechselt dein Charakter dazu, deiner Bewegungsrichtung zu folgen.
	Schau auf den Kopf deines Charakters, um die Blickrichtung zu erkennen.

	115 Grad sind der ideale Mittelweg für maximale Abdeckung ohne Bewegungstempoverlust.
]]; -- en:3355743a
L.CONTROLS_MOVEMENT_DESC = [[
	Die Bewegungssteuerung lässt sich an deinen Spielstil anpassen.

	Gamepads nutzen analoge Bewegung, du kannst also in jede Richtung laufen
	und durch Variieren des Stick-Drucks gehen.

	Das Spiel setzt stark auf Strafing als Mechanik,
	bei dem du dich seitwärts bewegst, während du in eine andere Richtung blickst.

	Du kannst anpassen, wann dein Charakter zwischen
	Strafing und Drehen in die Bewegungsrichtung wechselt.

	Wähle eine der Konfigurationen aus und bewege deinen linken Stick,
	um sie auszuprobieren.
]]; -- en:9d22c4f0
L.CONTROLS_MOVEMENT_FOLLOW_DESC = [[
	Die Folge-Bewegung konzentriert sich darauf, der Richtung zu folgen, in die du dich bewegst.

	Sowohl im Kampf als auch unterwegs strafft diese Konfiguration nie
	und läuft nie rückwärts.

	Dies kann für Spieler nützlich sein, die oft oder immer mit einer Single-Stick-Konfiguration spielen.
]]; -- en:45773d56
L.CONTROLS_MOVEMENT_TANK_DESC = [[
	Die Tank-Bewegung konzentriert sich darauf, eine vorwärtsgerichtete Position im Kampf zu halten.

	Im Kampf wird diese Konfiguration immer straffen und rückwärts laufen, um die Front zu halten.

	Unterwegs folgt diese Konfiguration immer der Bewegungsrichtung.
]]; -- en:9fcbcaaf
L.DEFAULTS_BINDINGS_EMPTY_DESC = [[
	Fange bei null an.

	Diese Aktion löscht alle deine aktuellen Gamepad-Belegungen, einschließlich der Blizzard-Standards,
	damit du deine Belegungen von Grund auf einrichten kannst.

	Diese Aktion überschreibt oder beeinflusst keine vorhandenen Tastaturbelegungen,
	beachte aber, dass Aktionsleisten zwischen beiden geteilt werden.

	Wenn du zwischen Tastatur und Gamepad wechseln möchtest, ist es empfehlenswert, deine
	Gamepad-Belegungen zu ändern, statt Fähigkeiten auf den Aktionsleisten zu verschieben.
]]; -- en:51053386
L.DEFAULTS_BINDINGS_PRESET_DESC = [[
	Wende empfohlene Belegungen an.

	Diese Belegungen basieren auf deinen vorherigen Entscheidungen und sollten dir einen guten Ausgangspunkt
	für deine Gamepad-Einrichtung bieten. Du kannst sie jederzeit ändern.

	Diese Aktion überschreibt oder beeinflusst keine vorhandenen Tastaturbelegungen,
	beachte aber, dass Aktionsleisten zwischen beiden geteilt werden.

	Wenn du zwischen Tastatur und Gamepad wechseln möchtest, ist es empfehlenswert, deine
	Gamepad-Belegungen zu ändern, statt Fähigkeiten auf den Aktionsleisten zu verschieben.
]]; -- en:6ac789b1
L.DEFAULTS_GENERAL_INFO = [[
	Schließe die Einrichtung ab, indem du empfohlene Einstellungen und Belegungen für dein Gamepad anwendest.
]]; -- en:c436023e
L.DEFAULTS_SETTINGS_APPLIED = [[
	Empfohlene Einstellungen für deinen Gamepad-Typ (%s) wurden angewendet.
]]; -- en:16be45b5
L.DEFAULTS_SETTINGS_DESC = [[
	Wende empfohlene Einstellungen für deinen Gamepad-Typ (%s) an:
]]; -- en:15a4050f
L.DEFAULTS_SETTINGS_NOTWEAK = [[
	Für deinen Gamepad-Typ (%s) gibt es keine empfohlenen Einstellungen.
]]; -- en:067a8a20
L.DESC_EASY_MOTION = [[
	Erzeugt Einheiten-Hotkeys für deine sichtbaren Einheitenfenster,
	sodass du schnell zwischen freundlichen Zielen wechseln kannst.

	Halte zur Verwendung die Belegung gedrückt, tippe dann die
	angezeigten Tasten am gewünschten Ziel und lasse die Belegung
	los, um das Ziel zu wechseln.

	Diese Belegung ist besonders für Heiler in 5-Spieler-Inhalten
	empfehlenswert, da sie eine extrem schnelle Methode zum
	Zielen in kleineren Gruppen bietet.

	In Schlachtzügen kann die nötige Eingabekomplexität,
	um dein bevorzugtes Ziel auszuwählen, herausfordernd sein.
	Siehe „Schlachtzugscursor umschalten“ für eine Alternative.
]]; -- en:0f9384b6
L.DESC_EXTRAACTIONBUTTON1 = [[
	Die Zusatzaktionstaste enthält eine temporäre Fähigkeit, die in
	verschiedenen Quests, Szenarien und Bossbegegnungen verwendet wird.

	Ist diese Belegung nicht gesetzt, ist die Zusatzaktionstaste immer
	über den Werkzeugring verfügbar.

	Diese Taste erscheint auf deiner Gamepad-Aktionsleiste als normale
	Aktionstaste, doch ihr Inhalt lässt sich nicht ändern.
]]; -- en:6dd42998
L.DESC_INTERACTTARGET = [[
	Ermöglicht es dir, mit NPCs und Objekten in der Spielwelt zu interagieren.

	Bietet die gleiche Funktion wie der zentrierte Cursor, erfordert aber nicht,
	den Cursor oder das Fadenkreuz direkt auf das Ziel zu richten.

	Interaktionsobjekte werden hervorgehoben, wenn sie in Reichweite sind.
]]; -- en:b1478add
L.DESC_JUMP = [[
	Kann auch zum Auftauchen unter Wasser, Aufsteigen mit
	Flugmounts und Abheben oder Flügelschlagen beim Drachenreiten verwendet werden.

	Springen ist nützlich, um Bewegungslücken zu überbrücken, während du eine
	linkshändige Aktion ausführst, die deinen Daumen beansprucht.

	In einer normalen Belegung steuert der linke Stick deine Bewegung.
	Wenn du eine Steuerkreuz-Kombination in Bewegung drücken musst,
	kann Springen dazu dienen, deinen Vorwärtsschwung zu erhalten,
	während du kurz den Daumen vom Stick nimmst.
]]; -- en:4c032315
L.DESC_KEY_BUTTON1 = [[
	Wird verwendet, um den freien Cursor umzuschalten, mit dem du deinen Kamera-Stick als Mauszeiger benutzen kannst.
]]; -- en:fd3d111a
L.DESC_KEY_BUTTON2 = [[
	Wird verwendet, um den zentrierten Cursor umzuschalten, mit dem du an einer festen Mittelposition mit Objekten und Charakteren in der Spielwelt interagieren kannst.
]]; -- en:2f5c87e4
L.DESC_QUICK_MENU = [[
	Ein Schnellzugriffsmenü, das gängige Aktionen während des Spiels
	zusammenfasst, wie z. B. das Würfeln auf Gruppenbeute, das Abbrechen
	von Stärkungszaubern oder das Verwenden eines Gegenstands aus den Taschen.
]]; -- en:0365846b
L.DESC_RAID_CURSOR = [[
	Schaltet einen Cursor um, der an deinen sichtbaren
	Einheitenfenstern haftet und es dir ermöglicht, freundliche
	Spieler zu heilen, während du ein anderes Ziel behältst.

	Der Schlachtzugscursor kann auch direkt zielen,
	wobei das Bewegen des Cursors dein aktuelles Ziel wechselt.

	Während der Verwendung belegt der Schlachtzugscursor einen Satz
	von Steuerkreuz-Kombinationen, um die Cursorposition zu steuern.

	Im Routing-Modus leitet der Cursor keine Makros oder mehrdeutigen
	Zauber um, wie z. B. die Buße eines Priesters.

	Siehe „Einheitenfenster anvisieren“ für eine Alternative.
]]; -- en:cacdf9c0
L.DESC_RING_CUSTOM = [[
	Ein Ringmenü, in das du Gegenstände, Zauber, Makros und Reittiere
	legen kannst, für die du keinen Platz auf der Aktionsleiste opfern willst.

	Halte zur Verwendung die Belegung gedrückt, neige deinen Stick in Richtung
	des gewünschten Eintrags und lasse die Belegung los.

	Um Einträge zu entfernen, folge der Tooltip-Aufforderung am fokussierten Eintrag.
]]; -- en:159abd06
L.DESC_RING_MENU = [[
	Ein Ringmenü, das gängige Fenster und häufige Aktionen
	an einem Ort zum schnellen Zugriff zusammenfasst.

	Der Ring lässt sich ohne separate Belegung auch über das
	Spielmenü öffnen, indem du die Seite wechselst.
]]; -- en:7ee244a1
L.DESC_RING_PET = [[
	Ein Ringmenü, mit dem du deinen aktuellen Begleiter steuern kannst.
]]; -- en:b1c4b5d3
L.DESC_RING_UTILITY = [[
	Ein Ringmenü, in das du Gegenstände, Zauber, Makros und Reittiere
	legen kannst, für die du keinen Platz auf der Aktionsleiste opfern willst.

	Halte zur Verwendung die Belegung gedrückt, neige deinen Stick in Richtung
	des gewünschten Eintrags und lasse die Belegung los.

	Um Einträge dem Ring hinzuzufügen, folge der Aufforderung des Interface-Cursors,
	oder hebe alternativ etwas mit dem Mauscursor auf und drücke die Belegung,
	um es in den Ring zu legen.

	Um Einträge zu entfernen, folge der Tooltip-Aufforderung am fokussierten Eintrag.

	Der Werkzeugring fügt automatisch Questgegenstände und temporäre
	Fähigkeiten hinzu, die du nicht auf deiner Aktionsleiste platziert hast.
]]; -- en:de107e96
L.DESC_TARGETNEARESTENEMY = [[
	Wechselt zwischen den nächsten feindlichen Zielen vor dir.
	Ohne aktuelles Ziel wird das mittigste Ziel ausgewählt.
	Andernfalls wird zwischen den nächstgelegenen Zielen gewechselt.

	Halte gedrückt, um Ziele hervorzuheben, bevor du entscheidest,
	das Ziel zu wechseln.

	Empfohlen als sekundäre Ziel-Belegung
	oder als primäre Ziel-Belegung im entspannten Spiel
	oder wenn der Ziel-Scan zu viel Präzision erfordert.

	Nicht empfohlen für Dungeons oder andere präzise Szenarien.
]]; -- en:981bc29c
L.DESC_TARGETSCANENEMY = [[
	Sucht in einem schmalen Kegel vor dir nach Gegnern.
	Halte gedrückt, um Ziele hervorzuheben, bevor du entscheidest,
	das Ziel zu wechseln.

	Besonders nützlich, um Ziele im Kampf
	mit hoher Präzision schnell zu wechseln.

	Die Zielpriorität ist visiergebunden, d. h. das Ziel
	näher am Mittelpunkt des Kegels wird zuerst
	ausgewählt. Dies kann dazu führen, dass ein entferntes
	Ziel einem näheren vorgezogen wird, wenn das entfernte
	Ziel näher am Mittelpunkt des Kegels liegt.

	Empfohlen als primäre Ziel-Belegung für die meisten Spieler.
]]; -- en:2de05bb9
L.DESC_TOGGLEAUTORUN = [[
	Autolauf führt dazu, dass dein Charakter sich weiterhin
	in die Richtung bewegt, in die er schaut, ohne weitere Eingaben.

	Autolauf entlastet den Daumen bei langen Bewegungsphasen
	oder befreit ihn, um andere Dinge zu tun, während du unterwegs bist.
]]; -- en:9e97af4b
L.DESC_TOGGLEGAMEMENU = [[
	Die Menü-Belegung übernimmt alle Funktionen, die durch Drücken
	der Escape-Taste auf einer Tastatur ausgelöst werden. Sie führt unterschiedliche
	Aktionen je nach aktuellem Spielzustand aus.

	Laufende Aktionen im Zusammenhang mit Zaubern oder Zielen
	werden abgebrochen. Bei aktivem Ziel wird das Ziel zurückgesetzt.
	Beim Wirken eines Zaubers wird das Zaubern unterbrochen.

	Die Belegung übernimmt auch verschiedene andere Fälle, abhängig
	davon, was gerade auf dem Bildschirm angezeigt wird. Ist z. B.
	ein Fenster wie das Zauberbuch geöffnet, wird die Belegung die
	notwendige Aktion ausführen, um es zu schließen oder zu verbergen.

	Trifft nichts davon zu, wird das Spielmenü beim Drücken
	geöffnet oder geschlossen.
]]; -- en:adfccfe4
L.DEVICE_DESC_PLAYSTATION4 = [[
	Der PlayStation-4-Controller, auch bekannt als DualShock 4, ist das Gamepad der vorherigen Generation von Sony.

	Es ist ein funktionsreiches Gamepad mit Touchpad, Bewegungssteuerung und Unterstützung für alle seine Tasten im Spiel.

	Um alle Funktionen nutzen zu können, musst du eventuell „PlayStation Accessories“ (Windows) installieren.
]]; -- en:7bea4ad9
L.DEVICE_DESC_PLAYSTATION5 = [[
	Der PlayStation-5-Controller, auch bekannt als DualSense, ist derzeit das beste Gamepad für World of Warcraft.

	Es ist das funktionsreichste verfügbare Gamepad mit Bewegungssteuerung, Touchpad und – im Falle der Edge-Variante – nativen Rückseiten-Paddles.
	Alle Tasten am Gamepad können im Spiel verwendet werden.

	Um alle Funktionen nutzen zu können, musst du eventuell „PlayStation Accessories“ (Windows) installieren.
]]; -- en:c5f15091
L.DEVICE_DESC_STEAMDECK = [[
	Steam Decks führen World of Warcraft typischerweise über Proton via Steam-Client aus.

	Beim Spielen über Steam sollte das Gerät ein Spielprofil verwenden, das mindestens ein Standard-Xbox-Layout abdeckt.

	Gamepad mit Maus-Trackpad bietet eine solide Grundlage.

	Steam Decks können ihre Paddles in World of Warcraft nicht nativ nutzen.
	Die Paddles lassen sich per Emulation belegen oder über Tastatur-Tasten in den Steam-Input-Einstellungen.

	Die spielinterne Steam-Deck-Voreinstellung kann sich aufgrund des ähnlichen Steuerungslayouts auch für andere Handheld-PCs eignen.
]]; -- en:2a5e4173
L.DEVICE_DESC_SWITCHPRO = [[
	Der Nintendo-Switch-Pro-Controller hat ein ähnliches Layout wie der Xbox-Controller, aber mit vertauschten Tastenbeschriftungen.

	Der Pro-Controller hat vier zentrale Tasten und damit einen kleinen Vorteil gegenüber einem Standard-Xbox-Controller.

	Der Nintendo-Switch-2-Pro-Controller kann seine Paddles oder die C-Taste im Spiel nicht nativ nutzen.
	Mit externer Software wie Steam oder reWASD lassen sie sich auf Tastatur-Tasten legen und im Spiel verwenden.
]]; -- en:79260874
L.DEVICE_DESC_XBOX = [[
	Xbox-Varianten sind die häufigsten Gamepads und werden von World of Warcraft gut unterstützt.

	Der Xbox-Elite-Controller kann seine Paddles im Spiel nicht nativ nutzen, sie lassen sich aber als Simulation anderer Gamepad-Tasten verwenden,
	mit Hilfe der Xbox-Accessories-App (Windows).

	Mit externer Software wie Steam oder reWASD lassen sich die Paddles auf Tastatur-Tasten legen und im Spiel verwenden.

	Die mittlere Taste ist für den Xbox-Guide reserviert und kann im Spiel nicht verwendet werden.

	Auch für Steam Input empfohlen, da konsistent mit dem Xbox-360-Controller, den es emuliert.
]]; -- en:654501d3
L.DISC_KEY_BUTTON1 = [[
	Solange eine deiner Tasten Linksklick emuliert, kann diese Belegung nicht geändert werden.
]]; -- en:e811ebc6
L.DISC_KEY_BUTTON2 = [[
	Solange eine deiner Tasten Rechtsklick emuliert, kann diese Belegung nicht geändert werden.
]]; -- en:b85c78b2
L.EXPORT_DATA_TEXT = [[

|cFFFFFF00Exportieren|r

Wähle die Daten aus, die du exportieren möchtest. Unten wird eine Zeichenkette erzeugt, die du in einem anderen Client einfügen oder mit anderen teilen kannst.

Verwende %s, um die Zeichenkette zu kopieren.
]]; -- en:1741e6a6
L.GFX_GENERAL_INFO = [[
	Wähle die Gamepad-Grafik, die deinem Gamepad am ähnlichsten sieht.

	Die Wahl der Grafik ändert nicht, wie dein Gamepad funktioniert, sondern nur das Erscheinungsbild des Interface.

	Grafiken zeigen dir, welche Tasten aktuell mit welchen Aktionen belegt sind, und dienen als visuelle Referenz für das Layout deines Gamepads.

	Basierend auf deiner Wahl werden einige optionale Einstellungsempfehlungen angeboten.
]]; -- en:54457360
L.IMPORT_DATA_TEXT = [[

|cFFFFFF00Importieren|r

Füge unten eine exportierte Zeichenkette ein, lade und wähle dann die zu importierenden Daten aus. Importierte Daten überschreiben deine aktuellen Daten, sofern zutreffend.

Verwende %s, um die Zeichenkette aus der Quelle zu kopieren, und %s, um sie unten einzufügen.
]]; -- en:145f78fb
L.IMPORT_FAILED_TEXT = [[

|cFFFFFF00Importieren|r

Import fehlgeschlagen:
]]; -- en:a7555666
L.LINK_COPY = [[
	Link zu %s.

	Strg+A zum Auswählen und Strg+C zum Kopieren.

	Füge (Strg+V) den Link in deinem Webbrowser ein.
]]; -- en:3f396345
L.LINK_DISCORD_TEXT = [[
	Die Community, in der du Hilfe findest, über Gameplay diskutierst, Ideen teilst und Gleichgesinnte triffst.

	Klicke hier, um dem Server beizutreten.
]]; -- en:e2f9740c
L.LINK_PATREON_TEXT = [[
	Die Entwicklung und Pflege dieses Addons kosten viel Zeit und Mühe,
	aber ConsolePort wird immer komplett kostenlos nutzbar bleiben.

	Werde Patreon-Unterstützer, um deinen Discord-Status freizuschalten und im Gegenzug die Zukunft des Projekts zu fördern.

	Klicke hier, um Patreon-Unterstützer zu werden.
]]; -- en:3cc9532e
L.LINK_PAYPAL_TEXT = [[
	Spenden fließen direkt in die Entwicklung und Pflege des Addons zurück.

	Jeder Beitrag, ob groß oder klein, wird sehr geschätzt.

	Klicke hier, um per PayPal zu spenden.
]]; -- en:28c6265a
L.REMOVE_RING_TEXT = [[|cFFFFFF00%s entfernen|r
Bist du sicher, dass du den Ring entfernen möchtest?]]; -- en:1a461a1a
L.RING_MENU_DESC = [[Erstelle eigene Ringmenüs, in die du Gegenstände, Zauber, Makros und Reittiere legen kannst, für die du keinen Platz auf der Aktionsleiste opfern willst.

Halte zur Verwendung die ausgewählte Belegung gedrückt, neige deinen Stick in Richtung des gewünschten Eintrags und lasse die Belegung los.

Der Standardring – der |CFF00FF00Werkzeugring|r – hat besondere Eigenschaften, die Questen und Welt-Interaktion erleichtern, und ist nicht statisch. Er fügt Einträge automatisch hinzu und entfernt sie wieder, wenn nötig.

Wenn du einen Ring für deine Rotation und nicht nur für Hilfsmittel erstellen willst, ist ein eigener Ring dafür sehr zu empfehlen.]]; -- en:39d4577b
L.SELECTED_RING_TEXT = [[Dies ist dein derzeit ausgewählter Ring.
Wenn du die Belegung gedrückt hältst, erscheinen alle ausgewählten Fähigkeiten als Ring auf dem Bildschirm.

Neige deinen Stick in Richtung der Fähigkeit oder des Gegenstands, den du verwenden möchtest, und lasse die Belegung los, um zu bestätigen.]]; -- en:2cdfa5d3
L.SET_RING_BINDING_TEXT = [[
|cFFFFFF00Belegung festlegen|r

Drücke eine Tastenkombination, um eine neue Belegung für diesen Ring auszuwählen.

]]; -- en:1c0e03f4
L.SLOT_NO_BINDING = [[
|cFFFFFF00Belegung festlegen|r

%s in %s hat keine zugewiesene Belegung.

Drücke eine Tastenkombination, um eine neue Belegung für diesen Platz auszuwählen.

]]; -- en:74326275
L.SLOT_SET_BINDING = [[
|cFFFFFF00Belegung festlegen|r

Drücke eine Tastenkombination, um eine neue Belegung für %s auszuwählen.

]]; -- en:d1933130
---------------------------------------------------------------
-- Literals
---------------------------------------------------------------
L['2D deadzone for camera that takes into account pitch and yaw movement together.'] = '2D-Deadzone für die Kamera, die Pitch- und Yaw-Bewegungen gemeinsam berücksichtigt.';
L['2D deadzone for movement that takes into account X and Y movement together.'] = '2D-Deadzone für Bewegung, die X- und Y-Bewegung gemeinsam berücksichtigt.';
L['A button cluster for all modifiers of a single button.'] = 'Ein Tasten-Cluster für alle Modifikatoren einer einzelnen Taste.';
L['A cluster bar with a toolbar below it, laid out horizontally.'] = 'Eine Cluster-Leiste mit darunter horizontal angeordneter Werkzeugleiste.';
L['A cluster bar with a toolbar below it.'] = 'Eine Cluster-Leiste mit darunter angeordneter Werkzeugleiste.';
L['A divider to separate elements.'] = 'Ein Trenner zum Aufteilen von Elementen.';
L['A friendly soft target can be acquired while having an enemy hard target.'] = 'Ein freundliches Soft-Ziel kann erfasst werden, während ein feindliches Hard-Ziel aktiv ist.';
L['A regular action bar.'] = 'Eine reguläre Aktionsleiste.';
L['A ring of buttons for pet commands.'] = 'Ein Ring aus Tasten für Begleiterbefehle.';
L['A toolbar with XP indicators, shortcuts, class specific bars, and miscellaneous information.'] = 'Eine Werkzeugleiste mit XP-Anzeigen, Kurzbefehlen, klassenspezifischen Leisten und sonstigen Informationen.';
L['About'] = 'Über';
L['Acceleration of cursor per second as it continues to move.'] = 'Beschleunigung des Cursors pro Sekunde, während er sich weiter bewegt.';
L['Accent Color'] = 'Akzentfarbe';
L['Accept Button'] = 'Bestätigen-Taste';
L['Action Bar Configuration'] = 'Aktionsleisten-Konfiguration';
L['Action bar is scaled separately.'] = 'Die Aktionsleiste wird separat skaliert.';
L['Action Bar Loadout'] = 'Aktionsleisten-Belegung';
L['Action Bar Loadout (Deprecated)'] = 'Aktionsleisten-Belegung (Veraltet)';
L['Action Bar Presets'] = 'Aktionsleisten-Voreinstellungen';
L['Action Bar Setup'] = 'Aktionsleisten-Einrichtung';
L['Action Button'] = 'Aktionstaste';
L['Action Button Group'] = 'Aktionstasten-Gruppe';
L['Action Page'] = 'Aktionsseite';
L['Action Page Condition'] = 'Aktionsseiten-Bedingung';
L['Action Page Response'] = 'Aktionsseiten-Antwort';
L['Activate targeting components only while their bindings are in use.'] = 'Anvisier-Komponenten nur aktivieren, solange ihre Belegungen verwendet werden.';
L['Active Color'] = 'Aktive Farbe';
L['Active Device'] = 'Aktives Gerät';
L['Add a new element to your loadout.'] = 'Füge deiner Belegung ein neues Element hinzu.';
L['Add to %s'] = 'Zu %s hinzufügen';
L['Add, remove or reset a frame from cursor stack.'] = 'Ein Fenster vom Cursor-Stapel hinzufügen, entfernen oder zurücksetzen.';
L['Affects both mouse and gamepad.'] = 'Wirkt sich auf Maus und Gamepad aus.';
L['Alignment'] = 'Ausrichtung';
L['Alignment of the counter text on buttons.'] = 'Ausrichtung des Zählertextes auf den Tasten.';
L['Alignment of the hotkey text on buttons.'] = 'Ausrichtung des Hotkey-Textes auf den Tasten.';
L['Alignment of the macro text on buttons.'] = 'Ausrichtung des Makrotextes auf den Tasten.';
L['All combines all connected devices into one.'] = '„Alle“ fasst alle verbundenen Geräte zu einem zusammen.';
L['Allow binding discrete radial stick inputs.'] = 'Erlaubt das Binden diskreter radialer Stick-Eingaben.';
L['Allow binding multiple combos to the same binding.'] = 'Erlaubt das Binden mehrerer Kombinationen an dieselbe Belegung.';
L['Allow Binding Overlap'] = 'Belegungsüberlappung erlauben';
L['Allow cursor to interact with and show preference for group loot frames.'] = 'Erlaubt dem Cursor, mit Gruppenbeute-Fenstern zu interagieren und ihnen Vorrang zu geben.';
L['Allow cursor to interact with and show preference for popups and static dialogs.'] = 'Erlaubt dem Cursor, mit Pop-ups und statischen Dialogen zu interagieren und ihnen Vorrang zu geben.';
L['Allow cursor to interact with the entire interface, not only panels.'] = 'Erlaubt dem Cursor, mit dem gesamten Interface zu interagieren, nicht nur mit Fenstern.';
L['Allow Radial Bindings'] = 'Radiale Belegungen erlauben';
L['Allows the use of the touchpad to control cursor movement.'] = 'Erlaubt die Verwendung des Touchpads zur Steuerung der Cursorbewegung.';
L['Alphabet to use for dictionary suggestions and word processing.'] = 'Alphabet für Wörterbuchvorschläge und Wortverarbeitung.';
L['Always keep cursor centered and visible when controlling camera.'] = 'Cursor immer zentriert und sichtbar halten, wenn die Kamera gesteuert wird.';
L['Always Show All Buttons'] = 'Immer alle Tasten anzeigen';
L['Always Show Mouse Cursor'] = 'Mauscursor immer anzeigen';
L['Always show nameplate for soft enemy target.'] = 'Namensplakette für feindliches Soft-Ziel immer anzeigen.';
L['Always show nameplate for soft friendly target.'] = 'Namensplakette für freundliches Soft-Ziel immer anzeigen.';
L['Always show tooltip for an automatically acquired target, as long as it exists.'] = 'Tooltip für ein automatisch erfasstes Ziel immer anzeigen, solange es existiert.';
L['An action button in a group.'] = 'Eine Aktionstaste in einer Gruppe.';
L['Analog Movement'] = 'Analoge Bewegung';
L['Anchor'] = 'Anker';
L['Anchor point of parent to pair with.'] = 'Ankerpunkt des Elterns, mit dem gekoppelt wird.';
L['Anchor point of the counter text on buttons.'] = 'Ankerpunkt des Zählertextes auf den Tasten.';
L['Anchor point of the hotkey icon on group buttons.'] = 'Ankerpunkt des Hotkey-Symbols auf Gruppentasten.';
L['Anchor point of the hotkey text on buttons.'] = 'Ankerpunkt des Hotkey-Textes auf den Tasten.';
L['Anchor point of the macro text on buttons.'] = 'Ankerpunkt des Makrotextes auf den Tasten.';
L['Anchor point to attach.'] = 'Ankerpunkt zum Anhängen.';
L['Apply default settings to the current category or all settings.'] = 'Standardeinstellungen auf die aktuelle Kategorie oder alle Einstellungen anwenden.';
L['Arc Allowance'] = 'Bogentoleranz';
L['Are you sure you want to delete %s from %s?'] = 'Bist du sicher, dass du %s aus %s löschen möchtest?';
L['Are you sure you want to overwrite %s with %s?'] = 'Bist du sicher, dass du %s mit %s überschreiben möchtest?';
L['Are you sure you want to regenerate the keyboard dictionary? You will lose all custom phrases.'] = 'Bist du sicher, dass du das Tastatur-Wörterbuch neu erzeugen möchtest? Du verlierst alle benutzerdefinierten Phrasen.';
L['Are you sure you want to reset all device profiles?'] = 'Bist du sicher, dass du alle Geräteprofile zurücksetzen möchtest?';
L['Are you sure you want to reset the keyboard layout?'] = 'Bist du sicher, dass du das Tastaturlayout zurücksetzen möchtest?';
L['Are you sure you want to reset your device profile?'] = 'Bist du sicher, dass du dein Geräteprofil zurücksetzen möchtest?';
L['Are you sure you want to wipe the keyboard dictionary? It currently contains %d words.'] = 'Bist du sicher, dass du das Tastatur-Wörterbuch leeren möchtest? Es enthält derzeit %d Wörter.';
L['Area where the interact key can find a suitable target.'] = 'Bereich, in dem die Interaktionstaste ein passendes Ziel finden kann.';
L['Artwork flavor.'] = 'Artwork-Variante.';
L['Artwork for the interface.'] = 'Artwork für das Interface.';
L['Artwork style.'] = 'Artwork-Stil.';
L['Assign or clear bindings for this set.'] = 'Belegungen für dieses Set zuweisen oder löschen.';
L['Auto-adjusts your camera, allowing you to control movement with a single stick.'] = 'Passt deine Kamera automatisch an, sodass du die Bewegung mit einem einzigen Stick steuern kannst.';
L['Auto-Sell Gear Level Limit'] = 'Automatisches Verkaufen: Ausrüstungs-Levellimit';
L['Auto-Sell Junk'] = 'Müll automatisch verkaufen';
L['Auto-set target to match soft target.'] = 'Ziel automatisch passend zum Soft-Ziel setzen.';
L['Automatic Binding Backups'] = 'Automatische Belegungs-Backups';
L['Automatic Cursor Timeout'] = 'Automatisches Cursor-Timeout';
L['Automatic Tooltip Duration'] = 'Automatische Tooltip-Dauer';
L['Automatically add tracked quest items and extra spells to main utility ring.'] = 'Verfolgte Quest-Gegenstände und zusätzliche Zauber automatisch zum Haupt-Werkzeugring hinzufügen.';
L['Automatically backup your bindings when you change them, for import and export.'] = 'Belegungen beim Ändern automatisch sichern, für Import und Export.';
L['Automatically Bind Extra Items'] = 'Zusatzgegenstände automatisch binden';
L['Automatically Control Cursor Pickups'] = 'Cursor bei Aufnehmen automatisch steuern';
L['Automatically control cursor when picking up items.'] = 'Cursor automatisch steuern, wenn Gegenstände aufgenommen werden.';
L['Automatically disabled if an inactive component is clicked from a macro.'] = 'Wird automatisch deaktiviert, wenn eine inaktive Komponente aus einem Makro geklickt wird.';
L['Automatically sell junk when interacting with a merchant.'] = 'Beim Interagieren mit einem Händler automatisch Müll verkaufen.';
L['Axis Interpretation'] = 'Achseninterpretation';
L['Battery Level'] = 'Akkustand';
L['Binding Catch Timeframe'] = 'Belegungs-Erfassungsfenster';
L['Blend Mode'] = 'Mischmodus';
L['Blend mode of the artwork.'] = 'Mischmodus des Artworks.';
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
L['Border Vertex Color'] = 'Rand-Vertexfarbe';
L['Breadth'] = 'Breite';
L['Breadth of the divider.'] = 'Breite des Trenners.';
L['Button %d'] = 'Taste %d';
L['Button or combination used to click when a given condition applies, but act as a normal binding otherwise.'] = 'Taste oder Kombination zum Klicken, wenn eine bestimmte Bedingung zutrifft, ansonsten wie eine normale Belegung.';
L['Button Set'] = 'Tastensatz';
L['Button that emulates '] = 'Taste, die ';
L['Button that emulates the '] = 'Taste, die die ';
L['Button to cancel or exit the quick menu.'] = 'Taste, um das Schnellmenü abzubrechen oder zu verlassen.';
L['Button to handle cancel actions, such as exiting menus.'] = 'Taste für Abbrechen-Aktionen, z. B. zum Verlassen von Menüs.';
L['Button to handle contextual actions, such as adding items to the utility ring or passing on loot.'] = 'Taste für kontextuelle Aktionen, z. B. Gegenstände zum Werkzeugring hinzufügen oder Beute passen.';
L['Button to handle contextual actions, such as adding items to the utility ring.'] = 'Taste für kontextuelle Aktionen, z. B. Gegenstände zum Werkzeugring hinzufügen.';
L['Button to insert suggested word.'] = 'Taste zum Einfügen eines vorgeschlagenen Wortes.';
L['Button to move the cursor down.'] = 'Taste, um den Cursor nach unten zu bewegen.';
L['Button to move the cursor left.'] = 'Taste, um den Cursor nach links zu bewegen.';
L['Button to move the cursor right.'] = 'Taste, um den Cursor nach rechts zu bewegen.';
L['Button to move the cursor up.'] = 'Taste, um den Cursor nach oben zu bewegen.';
L['Button to replicate left click. This is the primary interface action.'] = 'Taste zum Replizieren des Linksklicks. Dies ist die primäre Interface-Aktion.';
L['Button to replicate right click. This is the secondary interface action.'] = 'Taste zum Replizieren des Rechtsklicks. Dies ist die sekundäre Interface-Aktion.';
L['Button to select next suggested word.'] = 'Taste zum Auswählen des nächsten vorgeschlagenen Wortes.';
L['Button to select previous suggested word.'] = 'Taste zum Auswählen des vorherigen vorgeschlagenen Wortes.';
L['Button to use for combo hotkey 1.'] = 'Taste für Kombo-Hotkey 1.';
L['Button to use for combo hotkey 2.'] = 'Taste für Kombo-Hotkey 2.';
L['Button to use for combo hotkey 3.'] = 'Taste für Kombo-Hotkey 3.';
L['Button to use for combo hotkey 4.'] = 'Taste für Kombo-Hotkey 4.';
L['Button to use for combo hotkey 5.'] = 'Taste für Kombo-Hotkey 5.';
L['Button to use for combo hotkey 6.'] = 'Taste für Kombo-Hotkey 6.';
L['Button to use for combo hotkey 7.'] = 'Taste für Kombo-Hotkey 7.';
L['Button to use for combo hotkey 8.'] = 'Taste für Kombo-Hotkey 8.';
L['Button to use to erase characters.'] = 'Taste zum Löschen von Zeichen.';
L['Button to use to move the cursor leftwards.'] = 'Taste, um den Cursor nach links zu bewegen.';
L['Button to use to move the cursor rightwards.'] = 'Taste, um den Cursor nach rechts zu bewegen.';
L['Button to use to trigger the enter command.'] = 'Taste zum Auslösen des Enter-Befehls.';
L['Button to use to trigger the escape command.'] = 'Taste zum Auslösen des Escape-Befehls.';
L['Button to use to trigger the space command.'] = 'Taste zum Auslösen des Leerzeichen-Befehls.';
L['Button used to confirm a selected item from a ring.'] = 'Taste zum Bestätigen eines aus einem Ring ausgewählten Eintrags.';
L['Button used to remove a selected item from an editable ring.'] = 'Taste zum Entfernen eines ausgewählten Eintrags aus einem editierbaren Ring.';
L['Button |cFF00FFFF%s|r'] = 'Taste |cFF00FFFF%s|r';
L['Buttons'] = 'Tasten';
L['Buttons in the cluster bar.'] = 'Tasten in der Cluster-Leiste.';
L['Buttons in the group.'] = 'Tasten in der Gruppe.';
L['By default, shows modifiers on mouseover and on cooldown.'] = 'Zeigt Modifikatoren standardmäßig beim Mouseover und bei Abklingzeiten.';
L['Camera 2D Deadzone'] = 'Kamera 2D-Deadzone';
L['Camera Look'] = 'Kamera-Blick';
L['Camera Look is a temporary turn of the camera based on the current analog input.'] = 'Kamera-Blick ist eine temporäre Kameradrehung basierend auf der aktuellen analogen Eingabe.';
L['Camera Pitch Axis'] = 'Kamera-Pitch-Achse';
L['Camera Pitch Speed'] = 'Kamera-Pitch-Geschwindigkeit';
L['Camera Pitch-Only Deadzone'] = 'Kamera-Pitch-Only-Deadzone';
L['Camera speed for pitch - moving up/down.'] = 'Kamerageschwindigkeit für Pitch – nach oben/unten bewegen.';
L['Camera speed for yaw - turning left/right.'] = 'Kamerageschwindigkeit für Yaw – nach links/rechts drehen.';
L['Camera Yaw Axis'] = 'Kamera-Yaw-Achse';
L['Camera Yaw Speed'] = 'Kamera-Yaw-Geschwindigkeit';
L['Camera Yaw-Only Deadzone'] = 'Kamera-Yaw-Only-Deadzone';
L['Cancel and clear cursor'] = 'Abbrechen und Cursor zurücksetzen';
L['Cancel Button'] = 'Abbrechen-Taste';
L['Cannot open configuration menu in combat.'] = 'Konfigurationsmenü kann nicht im Kampf geöffnet werden.';
L['Casting Bar'] = 'Zauberleiste';
L['Center Gap'] = 'Mittel-Abstand';
L['Center gap, as fraction of overall crosshair size.'] = 'Mittel-Abstand als Bruchteil der gesamten Fadenkreuzgröße.';
L['Change before touchpad moves the cursor.'] = 'Schwelle, bevor das Touchpad den Cursor bewegt.';
L['Change bluetooth state for active device.'] = 'Bluetooth-Status für aktives Gerät ändern.';
L['Change or print a value from the active device configuration.'] = 'Wert aus der aktiven Gerätekonfiguration ändern oder ausgeben.';
L['Character Specific'] = 'Charakterspezifisch';
L['Choose a negative value to invert the axis.'] = 'Wähle einen negativen Wert, um die Achse zu invertieren.';
L['Class Bar'] = 'Klassenleiste';
L['Clear all items from this set.'] = 'Alle Einträge aus diesem Set löschen.';
L['Clear Binding'] = 'Belegung löschen';
L['Clear configured gamepad bindings and reload interface.'] = 'Konfigurierte Gamepad-Belegungen löschen und Interface neu laden.';
L['Clear Focus Deadzone'] = 'Fokus-Deadzone löschen';
L['Clear Focus Mode'] = 'Fokus-Modus löschen';
L['Clear Focus Time'] = 'Fokus-Löschzeit';
L['Clear Slot'] = 'Platz leeren';
L['Clear slot or binding'] = 'Platz oder Belegung löschen';
L['Click here to reset your device profile.'] = 'Klicke hier, um dein Geräteprofil zurückzusetzen.';
L['Click on Down'] = 'Klick bei Drücken';
L['Click Override Button'] = 'Klick-Override-Taste';
L['Click Override Condition'] = 'Klick-Override-Bedingung';
L['Cluster Action Bar'] = 'Cluster-Aktionsleiste';
L['Cluster Handle'] = 'Cluster-Griff';
L['Cluster Modifier Toggle'] = 'Cluster-Modifikator-Umschalter';
L['Clusters'] = 'Cluster';
L['Color accent of radial menu items.'] = 'Farbakzent radialer Menüeinträge.';
L['Color of a partially selected slice.'] = 'Farbe eines teilweise ausgewählten Segments.';
L['Color of the active slice.'] = 'Farbe des aktiven Segments.';
L['Color of the cooldown swipe effect on buttons.'] = 'Farbe des Abklingzeit-Wischeffekts auf den Tasten.';
L['Color of the counter text on buttons.'] = 'Farbe des Zählertextes auf den Tasten.';
L['Color of the crosshair.'] = 'Farbe des Fadenkreuzes.';
L['Color of the divider.'] = 'Farbe des Trenners.';
L['Color of the hotkey text on buttons.'] = 'Farbe des Hotkey-Textes auf den Tasten.';
L['Color of the macro text on buttons.'] = 'Farbe des Makrotextes auf den Tasten.';
L['Color of the main XP bar.'] = 'Farbe der Haupt-XP-Leiste.';
L['Color of the mana indicator on buttons.'] = 'Farbe der Mana-Anzeige auf den Tasten.';
L['Color of the range indicator on buttons.'] = 'Farbe der Reichweiten-Anzeige auf den Tasten.';
L['Color of the sticky selection slice.'] = 'Farbe des Sticky-Auswahl-Segments.';
L['Color of the vertices on the border of buttons.'] = 'Farbe der Vertices am Rand der Tasten.';
L['Color tint for combo hotkey 1.'] = 'Farbton für Kombo-Hotkey 1.';
L['Color tint for combo hotkey 2.'] = 'Farbton für Kombo-Hotkey 2.';
L['Color tint for combo hotkey 3.'] = 'Farbton für Kombo-Hotkey 3.';
L['Color tint for combo hotkey 4.'] = 'Farbton für Kombo-Hotkey 4.';
L['Color tint for combo hotkey 5.'] = 'Farbton für Kombo-Hotkey 5.';
L['Color tint for combo hotkey 6.'] = 'Farbton für Kombo-Hotkey 6.';
L['Color tint for combo hotkey 7.'] = 'Farbton für Kombo-Hotkey 7.';
L['Color tint for combo hotkey 8.'] = 'Farbton für Kombo-Hotkey 8.';
L['Combine with '] = 'Kombiniere mit ';
L['Combine with use on demand for full cursor control.'] = 'Kombiniere mit „Bei Bedarf“ für volle Cursor-Kontrolle.';
L['Combined Input Overlap Time'] = 'Kombi-Eingabe-Überlappungszeit';
L['Combo Button 1'] = 'Kombo-Taste 1';
L['Combo Button 2'] = 'Kombo-Taste 2';
L['Combo Button 3'] = 'Kombo-Taste 3';
L['Combo Button 4'] = 'Kombo-Taste 4';
L['Combo Button 5'] = 'Kombo-Taste 5';
L['Combo Button 6'] = 'Kombo-Taste 6';
L['Combo Button 7'] = 'Kombo-Taste 7';
L['Combo Button 8'] = 'Kombo-Taste 8';
L['Combo Color 1'] = 'Kombo-Farbe 1';
L['Combo Color 2'] = 'Kombo-Farbe 2';
L['Combo Color 3'] = 'Kombo-Farbe 3';
L['Combo Color 4'] = 'Kombo-Farbe 4';
L['Combo Color 5'] = 'Kombo-Farbe 5';
L['Combo Color 6'] = 'Kombo-Farbe 6';
L['Combo Color 7'] = 'Kombo-Farbe 7';
L['Combo Color 8'] = 'Kombo-Farbe 8';
L['Command Modifier'] = 'Befehls-Modifikator';
L['Configure the casting bar.'] = 'Konfiguriere die Zauberleiste.';
L['Configure the class related bar.'] = 'Konfiguriere die klassenbezogene Leiste.';
L['Connect your controller.'] = 'Verbinde deinen Controller.';
L['Connected device(s):'] = 'Verbundene(s) Gerät(e):';
L['ConsolePort'] = 'ConsolePort';
L['Context Button'] = 'Kontext-Taste';
L['Controls the cutoff range where an interactable target or object can be found.'] = 'Steuert die Grenzreichweite, bei der ein interagierbares Ziel oder Objekt gefunden werden kann.';
L['Controls when your character starts running. Expressed as a fraction of your total movement stick radius.'] = 'Steuert, wann dein Charakter zu rennen beginnt. Als Bruchteil deines gesamten Bewegungs-Stick-Radius.';
L['Copy %s from %s:'] = '%s von %s kopieren:';
L['Copy this element to a new name.'] = 'Dieses Element unter neuem Namen kopieren.';
L['Correlation between stick position and pie selection.'] = 'Korrelation zwischen Stick-Position und Tortenauswahl.';
L['Create Binding Preset'] = 'Belegungs-Voreinstellung erstellen';
L['Critical, Low, Medium, High, Wired/Charging, or Unknown/Disconnected.'] = 'Kritisch, Niedrig, Mittel, Hoch, Verkabelt/Lädt oder Unbekannt/Getrennt.';
L['Crossbar: Minimal'] = 'Crossbar: Minimal';
L['Crossbar: Triggers'] = 'Crossbar: Trigger';
L['Crossbar: Triple'] = 'Crossbar: Dreifach';
L['Crosshair'] = 'Fadenkreuz';
L['Cursor Acceleration'] = 'Cursor-Beschleunigung';
L['Cursor acceleration for touchpad control.'] = 'Cursor-Beschleunigung für Touchpad-Steuerung.';
L['Cursor appears on demand, instead of in response to a panel showing up.'] = 'Cursor erscheint bei Bedarf, statt als Reaktion auf ein erscheinendes Fenster.';
L['Cursor Center Position'] = 'Cursor-Mittelposition';
L['Cursor hides when you start moving, if free of obstacles.'] = 'Cursor versteckt sich beim Bewegen, sofern frei von Hindernissen.';
L['Cursor Max Speed'] = 'Cursor-Höchstgeschwindigkeit';
L['Cursor Move Threshold'] = 'Cursor-Bewegungsschwelle';
L['Cursor Reticle Targeting'] = 'Cursor-Visier-Zielsystem';
L['Cursor Speed'] = 'Cursor-Geschwindigkeit';
L['Cursor speed for touchpad control.'] = 'Cursor-Geschwindigkeit für Touchpad-Steuerung.';
L['Cursor Start Speed'] = 'Cursor-Startgeschwindigkeit';
L['Custom color to use for the touchpad LED.'] = 'Benutzerdefinierte Farbe für die Touchpad-LED.';
L['Cyan'] = 'Cyan';
L['Deadzone for simple point-to-select rings.'] = 'Deadzone für einfache Point-to-Select-Ringe.';
L['Deadzone to clear focus after intercepting stick input.'] = 'Deadzone zum Löschen des Fokus nach Stick-Eingabe.';
L['Decrease'] = 'Verringern';
L['Decrease lightness'] = 'Helligkeit verringern';
L['Decrease opacity'] = 'Deckkraft verringern';
L['Default to '] = 'Standardmäßig ';
L['Delay before reactivating interface cursor after leaving combat, in seconds.'] = 'Verzögerung, bevor der Interface-Cursor nach Verlassen des Kampfes reaktiviert wird, in Sekunden.';
L['Delay before starting to adjust angle when camera control is idle, in seconds.'] = 'Verzögerung vor dem Justieren des Winkels bei inaktiver Kamerasteuerung, in Sekunden.';
L['Delay is doubled if you are dead.'] = 'Verzögerung verdoppelt sich, wenn du tot bist.';
L['Delay until a movement is repeated, when holding down a direction, in seconds.'] = 'Verzögerung, bis eine Bewegung beim Halten einer Richtung wiederholt wird, in Sekunden.';
L['Delay until the first movement is repeated, when holding down a direction, in seconds.'] = 'Verzögerung, bis die erste Bewegung beim Halten einer Richtung wiederholt wird, in Sekunden.';
L['Delete this element.'] = 'Dieses Element löschen.';
L['Depth'] = 'Tiefe';
L['Depth of the divider.'] = 'Tiefe des Trenners.';
L['Detected %d out of 8 possible sensors.'] = '%d von 8 möglichen Sensoren erkannt.';
L['Detected %d valid button(s).'] = '%d gültige Taste(n) erkannt.';
L['Device Information'] = 'Geräteinformationen';
L['Device Mappings'] = 'Gerätezuordnungen';
L['Device Profiles'] = 'Geräteprofile';
L['Device Selection'] = 'Geräteauswahl';
L['Device Settings'] = 'Geräteeinstellungen';
L['Diamond Grid'] = 'Rautengitter';
L['Dictionary Match Alphabet'] = 'Wörterbuch-Match-Alphabet';
L['Dictionary Match Pattern'] = 'Wörterbuch-Match-Muster';
L['Direction for flyout buttons, such as portals, poisons, and pet utilities.'] = 'Richtung für Flyout-Tasten, z. B. Portale, Gifte und Begleiter-Werkzeuge.';
L['Direction of the button cluster.'] = 'Richtung des Tasten-Clusters.';
L['Disable Drag and Drop'] = 'Ziehen und Ablegen deaktivieren';
L['Disable dragging and dropping abilities on action bars.'] = 'Ziehen und Ablegen von Fähigkeiten auf Aktionsleisten deaktivieren.';
L['Disable free-roaming mouse cursor when you jump.'] = 'Freien Mauscursor beim Springen deaktivieren.';
L['Disable free-roaming mouse cursor when you use your sticks.'] = 'Freien Mauscursor bei Stick-Verwendung deaktivieren.';
L['Disable Hotkey Rendering'] = 'Hotkey-Darstellung deaktivieren';
L['Disable if your mouse cursor is invisible.'] = 'Deaktiviere, wenn dein Mauscursor unsichtbar ist.';
L['Disable repeated cursor movements - each click will only move the cursor once.'] = 'Wiederholte Cursor-Bewegungen deaktivieren – jeder Klick bewegt den Cursor nur einmal.';
L['Disable Repeated Movement'] = 'Wiederholte Bewegung deaktivieren';
L['Disable to use discrete legacy movement controls.'] = 'Deaktiviere, um diskrete Legacy-Bewegungssteuerung zu verwenden.';
L['Disable Wrapping'] = 'Umlauf deaktivieren';
L['Disables customization to hotkeys on regular action bars.'] = 'Deaktiviert die Anpassung von Hotkeys auf regulären Aktionsleisten.';
L['Disabling this may cause worse performance with many panels open.'] = 'Deaktivieren kann bei vielen geöffneten Fenstern zu schlechterer Performance führen.';
L['Disconnected'] = 'Getrennt';
L['Discord'] = 'Discord';
L['Display icon next to the power level for the current active gamepad.'] = 'Symbol neben dem Akkustand für das aktuell aktive Gamepad anzeigen.';
L['Display power level for the current active gamepad.'] = 'Akkustand für das aktuell aktive Gamepad anzeigen.';
L['Display power level status text for the current active gamepad.'] = 'Akkustand-Statustext für das aktuell aktive Gamepad anzeigen.';
L['Display the action bar grid when picking up a spell on the cursor.'] = 'Aktionsleisten-Raster beim Aufnehmen eines Zaubers auf den Cursor anzeigen.';
L['Displays a briefing for newly acquired abilities.'] = 'Zeigt einen Briefing-Text für neu erworbene Fähigkeiten an.';
L['Divider'] = 'Trenner';
L['Do you want to load settings for %s?'] = 'Möchtest du Einstellungen für %s laden?';
L['Does not affect actual ability to interact with the target, which may have a different range.'] = 'Beeinflusst nicht die tatsächliche Fähigkeit, mit dem Ziel zu interagieren, die eine andere Reichweite haben kann.';
L['Donate via PayPal'] = 'Via PayPal spenden';
L['Double Tap Modifier'] = 'Doppeltipp-Modifikator';
L['Double Tap Timeframe'] = 'Doppeltipp-Zeitfenster';
L['Duration under which a tooltip is displayed for an acquired target or interactable, in milliseconds.'] = 'Dauer, für die ein Tooltip für ein erfasstes Ziel oder Interagierbares angezeigt wird, in Millisekunden.';
L['Dynamic Pitch'] = 'Dynamischer Pitch';
L['Dynamic will use the button set that does not conflict with your '] = '„Dynamisch“ verwendet den Tastensatz, der nicht mit deinem ';
L['E.g. '] = 'z. B. ';
L['Edit Binding'] = 'Belegung bearbeiten';
L['Edit Slot'] = 'Platz bearbeiten';
L['Emulate P1 '] = 'P1 emulieren ';
L['Emulate P2 '] = 'P2 emulieren ';
L['Emulate P3 '] = 'P3 emulieren ';
L['Emulate P4 '] = 'P4 emulieren ';
L['Emulate Pad 5'] = 'Pad 5 emulieren';
L['Emulate Pad 6'] = 'Pad 6 emulieren';
L['Emulate Pad Back'] = 'Zurück emulieren';
L['Emulate Pad Forward'] = 'Vorwärts emulieren';
L['Emulate Pad Social'] = 'Sozial emulieren';
L['Emulate Pad System'] = 'System emulieren';
L['Enable all modifier states for the cluster, including unmapped modifiers.'] = 'Alle Modifikator-Zustände für den Cluster aktivieren, einschließlich nicht zugeordneter Modifikatoren.';
L['Enable Animation'] = 'Animation aktivieren';
L['Enable casting bar ownership.'] = 'Besitz der Zauberleiste aktivieren.';
L['Enable class bar ownership.'] = 'Besitz der Klassenleiste aktivieren.';
L['Enable Cooldown Numbers'] = 'Abklingzeit-Zahlen aktivieren';
L['Enable Group Loot'] = 'Gruppenbeute aktivieren';
L['Enable interact key to interact with objects and creatures in the game world.'] = 'Interaktionstaste aktivieren, um mit Objekten und Kreaturen in der Spielwelt zu interagieren.';
L['Enable interface cursor. Disable to use mouse-based interface interaction.'] = 'Interface-Cursor aktivieren. Deaktivieren, um maus-basierte Interface-Interaktion zu nutzen.';
L['Enable Lazy Loading'] = 'Verzögertes Laden aktivieren';
L['Enable Mouse Handling'] = 'Maus-Steuerung aktivieren';
L['Enable Player Interact'] = 'Spieler-Interaktion aktivieren';
L['Enable Popups'] = 'Popups aktivieren';
L['Enable separate strafe angle threshold for when your character is in the air.'] = 'Separate Strafe-Winkel-Schwelle aktivieren, wenn dein Charakter in der Luft ist.';
L['Enable Strafe Angle (Jump)'] = 'Strafe-Winkel aktivieren (Sprung)';
L['Enable Tint'] = 'Tönung aktivieren';
L['Enable touch tap to press touchpad buttons.'] = 'Berührungs-Tippen zum Drücken von Touchpad-Tasten aktivieren.';
L['Enable Touchpad Cursor'] = 'Touchpad-Cursor aktivieren';
L['Enable Vehicle'] = 'Fahrzeug aktivieren';
L['Enable Watch Bars'] = 'Beobachtungsleisten aktivieren';
L['Enables a crosshair to reveal your hidden center cursor position at all times.'] = 'Aktiviert ein Fadenkreuz, um die Position deines verborgenen mittigen Cursors jederzeit anzuzeigen.';
L['Enables a radial on-screen keyboard that can be used to type messages.'] = 'Aktiviert eine radiale Bildschirmtastatur, mit der Nachrichten getippt werden können.';
L['Enemy Soft Targeting'] = 'Feindliches Soft-Zielsystem';
L['Equippable items of poor quality will not be sold while your character is below this level.'] = 'Anlegbare Gegenstände schlechter Qualität werden nicht verkauft, solange dein Charakter unter diesem Level ist.';
L['Erase'] = 'Löschen';
L['Exit the vehicle you are currently controlling.'] = 'Verlasse das Fahrzeug, das du gerade steuerst.';
L['Explicit only matches hard locked targets through using a targeting binding, while implicit matches targets you attack.'] = 'Explizit passt nur hart gelockte Ziele über eine Zielbelegung, während implizit Ziele passt, die du angreifst.';
L['Export'] = 'Exportieren';
L['Export %s to a string:'] = '%s zu einer Zeichenkette exportieren:';
L['Export action page logic'] = 'Aktionsseiten-Logik exportieren';
L['Export All'] = 'Alle exportieren';
L['Export all your custom presets to a string that can be shared with others.'] = 'Alle deine benutzerdefinierten Voreinstellungen zu einer teilbaren Zeichenkette exportieren.';
L['Export current options'] = 'Aktuelle Optionen exportieren';
L['Export serialized settings for sharing or backup.'] = 'Serialisierte Einstellungen zum Teilen oder Sichern exportieren.';
L['Export this preset to a string that can be shared with others.'] = 'Diese Voreinstellung zu einer teilbaren Zeichenkette exportieren.';
L['Expressed in milliseconds. Pressing any combination of modifier and button will cancel the effect.'] = 'In Millisekunden. Drücken einer beliebigen Kombination aus Modifikator und Taste bricht den Effekt ab.';
L['Fade Buttons'] = 'Tasten ausblenden';
L['Fade out the pet ring when not moused over.'] = 'Begleiterring ausblenden, wenn nicht über ihn gefahren wird.';
L['Fade out the watch bars when not mousing over the toolbar.'] = 'Beobachtungsleisten ausblenden, wenn nicht über die Werkzeugleiste gefahren wird.';
L['Fade Watch Bars'] = 'Beobachtungsleisten ausblenden';
L['Filter Condition'] = 'Filter-Bedingung';
L['Filter condition to find raid cursor frames, as a boolean expression in Lua.'] = 'Filter-Bedingung zum Finden von Schlachtzugscursor-Fenstern, als boolescher Ausdruck in Lua.';
L['Flavor'] = 'Variante';
L['Flyout Direction'] = 'Flyout-Richtung';
L['FOAS Adjust Delay'] = 'FOAS-Anpassungsverzögerung';
L['FOAS Adjust Ease In'] = 'FOAS-Einblendung';
L['Follow On A Stick (FOAS)'] = 'Follow On A Stick (FOAS)';
L['Font Flags'] = 'Schrift-Flags';
L['Font flags of the counter text on buttons.'] = 'Schrift-Flags des Zählertextes auf den Tasten.';
L['Font flags of the hotkey text on buttons.'] = 'Schrift-Flags des Hotkey-Textes auf den Tasten.';
L['Font flags of the macro text on buttons.'] = 'Schrift-Flags des Makrotextes auf den Tasten.';
L['Font size of the counter text on buttons.'] = 'Schriftgröße des Zählertextes auf den Tasten.';
L['Font size of the hotkey text on buttons.'] = 'Schriftgröße des Hotkey-Textes auf den Tasten.';
L['Font size of the macro text on buttons.'] = 'Schriftgröße des Makrotextes auf den Tasten.';
L['Font size of the ring slice buttons.'] = 'Schriftgröße der Ringsegment-Tasten.';
L['Force Hard Target'] = 'Hartes Ziel erzwingen';
L['Frame level of the element.'] = 'Fenster-Level des Elements.';
L['Frame Level Offset'] = 'Fenster-Level-Offset';
L['Frame level offset of the hotkey prompt, relative to the unit frame.'] = 'Fenster-Level-Offset des Hotkey-Prompts relativ zum Einheitenfenster.';
L['Frame strata of the element.'] = 'Fenster-Strata des Elements.';
L['Free Cursor Timein'] = 'Freier Cursor-Einblendung';
L['Frees your mouse cursor when used, if the cursor is currently center-fixed or hidden.'] = 'Befreit deinen Mauscursor, wenn der Cursor derzeit mittig fixiert oder versteckt ist.';
L['Friend Soft Targeting'] = 'Freundliches Soft-Zielsystem';
L['Full State Modifier'] = 'Voll-Status-Modifikator';
L['Global color of the tint effect on the toolbar and dividers.'] = 'Globale Farbe des Tint-Effekts auf Werkzeugleiste und Trennern.';
L['Global Scale'] = 'Globale Skalierung';
L['Global Visibility'] = 'Globale Sichtbarkeit';
L['Green'] = 'Grün';
L['Grid'] = 'Gitter';
L['Group buttons by modifier in a diamond layout.'] = 'Tasten nach Modifikator in einem Rautenlayout gruppieren.';
L['Group buttons by modifier in a grid layout.'] = 'Tasten nach Modifikator in einem Gitterlayout gruppieren.';
L['Group buttons for left and right triggers, with modifier swapping.'] = 'Tasten für linken und rechten Trigger mit Modifikator-Tausch gruppieren.';
L['Group buttons in a single crossbar layout, with modifier swapping.'] = 'Tasten in einem einzelnen Crossbar-Layout mit Modifikator-Tausch gruppieren.';
L['Group buttons in three layouts, with modifier swapping.'] = 'Tasten in drei Layouts mit Modifikator-Tausch gruppieren.';
L['Height of the artwork.'] = 'Höhe des Artworks.';
L['Height of the cluster bar.'] = 'Höhe der Cluster-Leiste.';
L['Height of the crosshair, in scaled pixel units.'] = 'Höhe des Fadenkreuzes in skalierten Pixeleinheiten.';
L['Height of the group.'] = 'Höhe der Gruppe.';
L['Hide Cursor on Jump'] = 'Cursor beim Springen ausblenden';
L['Hide Cursor On Movement'] = 'Cursor bei Bewegung ausblenden';
L['Hide Cursor on Stick Input'] = 'Cursor bei Stick-Eingabe ausblenden';
L['Hide Flyout Buttons'] = 'Flyout-Tasten ausblenden';
L['Hide Macro Text'] = 'Makrotext ausblenden';
L['Hide the class bar.'] = 'Klassenleiste ausblenden.';
L['Hide the macro text on buttons.'] = 'Makrotext auf den Tasten ausblenden.';
L['Higher is slower.'] = 'Höher ist langsamer.';
L['Higher values appear on top of lower values. Valid range 0-10000.'] = 'Höhere Werte erscheinen über niedrigeren. Gültiger Bereich 0–10000.';
L['Highlight Color'] = 'Hervorhebungs-Farbe';
L['Horizontal Offset'] = 'Horizontaler Offset';
L['Horizontal offset from anchor point.'] = 'Horizontaler Offset vom Ankerpunkt.';
L['Horizontal offset of the counter text on buttons.'] = 'Horizontaler Offset des Zählertextes auf den Tasten.';
L['Horizontal offset of the hotkey icon on group buttons.'] = 'Horizontaler Offset des Hotkey-Symbols auf Gruppentasten.';
L['Horizontal offset of the hotkey prompt position, in pixels.'] = 'Horizontaler Offset der Hotkey-Prompt-Position in Pixeln.';
L['Horizontal offset of the hotkey text on buttons.'] = 'Horizontaler Offset des Hotkey-Textes auf den Tasten.';
L['Horizontal offset of the macro text on buttons.'] = 'Horizontaler Offset des Makrotextes auf den Tasten.';
L['Horizontal Padding'] = 'Horizontale Polsterung';
L['Hotkey Anchor'] = 'Hotkey-Anker';
L['Hotkey Offset X'] = 'Hotkey-Offset X';
L['Hotkey Offset Y'] = 'Hotkey-Offset Y';
L['Hotkey prompts appear on applicable name plates.'] = 'Hotkey-Prompts erscheinen auf zutreffenden Namensplaketten.';
L['Hotkey prompts linger on unit frames after targeting.'] = 'Hotkey-Prompts bleiben nach dem Anvisieren auf den Einheitenfenstern.';
L['Hotkey Relative Anchor'] = 'Hotkey relativer Anker';
L['Hotkey Size'] = 'Hotkey-Größe';
L['Hotkeys activate their target immediately.'] = 'Hotkeys aktivieren ihr Ziel sofort.';
L['Hotkeys always target the same unit.'] = 'Hotkeys zielen immer auf dieselbe Einheit.';
L['Hotkeys control your focus target instead of your current target.'] = 'Hotkeys steuern dein Fokus-Ziel statt deines aktuellen Ziels.';
L['Hotkeys use '] = 'Hotkeys verwenden ';
L['How long the cursor should take to transition from one node to another.'] = 'Wie lange der Cursor zum Übergang von einem Knoten zum nächsten brauchen soll.';
L['How to clear focus after intercepting stick input.'] = 'Wie der Fokus nach Stick-Eingabe gelöscht wird.';
L['Import serialized preset(s) from an external source.'] = 'Serialisierte Voreinstellung(en) aus externer Quelle importieren.';
L['Import serialized preset(s):'] = 'Serialisierte Voreinstellung(en) importieren:';
L['Import serialized settings from an external source.'] = 'Serialisierte Einstellungen aus externer Quelle importieren.';
L['Inactive Opacity'] = 'Inaktive Deckkraft';
L['Include the current action page logic in the preset data.'] = 'Aktuelle Aktionsseiten-Logik in die Voreinstellungsdaten einschließen.';
L['Include the current options from the %s tab in the preset data.'] = 'Aktuelle Optionen aus dem %s-Reiter in die Voreinstellungsdaten einschließen.';
L['Increase'] = 'Erhöhen';
L['Increase lightness'] = 'Helligkeit erhöhen';
L['Increase opacity'] = 'Deckkraft erhöhen';
L['Insert Suggestion'] = 'Vorschlag einfügen';
L['Intensity'] = 'Intensität';
L['Intensity of the gradient.'] = 'Intensität des Verlaufs.';
L['Interface Cursor'] = 'Interface-Cursor';
L['Interference'] = 'Störung';
L['Inverted'] = 'Invertiert';
L['Join Discord'] = 'Discord beitreten';
L['Keeps your character centered to reduce motion sickness.'] = 'Hält deinen Charakter zentriert, um Übelkeit zu reduzieren.';
L['Key %d'] = 'Taste %d';
L['Keyboard button to emulate the back button.'] = 'Tastaturtaste zur Emulation der Zurück-Taste.';
L['Keyboard button to emulate the forward button.'] = 'Tastaturtaste zur Emulation der Vorwärts-Taste.';
L['Keyboard button to emulate the pad 5 button.'] = 'Tastaturtaste zur Emulation der Pad-5-Taste.';
L['Keyboard button to emulate the pad 6 button.'] = 'Tastaturtaste zur Emulation der Pad-6-Taste.';
L['Keyboard button to emulate the social button.'] = 'Tastaturtaste zur Emulation der Sozial-Taste.';
L['Keyboard button to emulate the system button.'] = 'Tastaturtaste zur Emulation der System-Taste.';
L['Keyboard'] = 'Tastatur';
L['Keyboard button to emulate the paddle 1 button.'] = 'Tastaturtaste zur Emulation der Paddle-1-Taste.';
L['Keyboard button to emulate the paddle 2 button.'] = 'Tastaturtaste zur Emulation der Paddle-2-Taste.';
L['Keyboard button to emulate the paddle 3 button.'] = 'Tastaturtaste zur Emulation der Paddle-3-Taste.';
L['Keyboard button to emulate the paddle 4 button.'] = 'Tastaturtaste zur Emulation der Paddle-4-Taste.';
L['Keyboard Layout Editor'] = 'Tastatur-Layout-Editor';
L['Larger value for easier taps.'] = 'Größerer Wert für leichteres Tippen.';
L['Layout'] = 'Layout';
L['Lazy loading has been disabled to activate the raid cursor.'] = 'Verzögertes Laden wurde deaktiviert, um den Schlachtzugscursor zu aktivieren.';
L['Lazy loading has been disabled to activate unit hotkeys.'] = 'Verzögertes Laden wurde deaktiviert, um Einheiten-Hotkeys zu aktivieren.';
L['LED Color Type'] = 'LED-Farbtyp';
L['LED Custom Color'] = 'Benutzerdefinierte LED-Farbe';
L['Load'] = 'Laden';
L['Loaded binding preset %s.'] = 'Belegungs-Voreinstellung %s wurde geladen.';
L['Loadout'] = 'Belegung';
L['Lock Automatic Tooltip'] = 'Automatischen Tooltip sperren';
L['Looks like a regular action bar, but shows the button combination rather than the action slot.'] = 'Sieht aus wie eine reguläre Aktionsleiste, zeigt aber die Tastenkombination statt des Aktionsslots an.';
L['Lua pattern to match words for dictionary lookups.'] = 'Lua-Muster zum Abgleichen von Wörtern für Wörterbuch-Suchen.';
L['Macro condition to automatically load a binding preset by name when the condition applies.'] = 'Makro-Bedingung, um automatisch eine Belegungs-Voreinstellung anhand ihres Namens zu laden, wenn die Bedingung zutrifft.';
L['Macro condition to evaluate action bar page.'] = 'Makro-Bedingung zur Auswertung der Aktionsseite.';
L['Macro condition to override the strafe angle threshold for combat.'] = 'Makro-Bedingung zum Überschreiben der Strafe-Winkel-Schwelle für den Kampf.';
L['Macro condition to override the strafe angle threshold for travel.'] = 'Makro-Bedingung zum Überschreiben der Strafe-Winkel-Schwelle für Reisen.';
L['Macro Text'] = 'Makrotext';
L['Main Button Border Style'] = 'Haupttasten-Rahmenstil';
L['Maintain offset relative to scale.'] = 'Offset relativ zur Skalierung beibehalten.';
L['Make sure your choice does not conflict with your bindings.'] = 'Stelle sicher, dass deine Wahl nicht mit deinen Belegungen kollidiert.';
L['Make this preset the default layout for all new characters.'] = 'Diese Voreinstellung zum Standard-Layout für alle neuen Charaktere machen.';
L['Match appropriate soft target to locked target.'] = 'Passendes Soft-Ziel zum gelockten Ziel zuordnen.';
L['Match criteria for unit pool, each type separated by semicolon.'] = 'Match-Kriterien für Einheiten-Pool, jeder Typ durch Semikolon getrennt.';
L['Max Pitch'] = 'Max. Pitch';
L['Max time for a touch to register a tap/click, in milliseconds.'] = 'Maximale Zeit für eine Berührung, um als Tipp/Klick registriert zu werden, in Millisekunden.';
L['Max Yaw'] = 'Max. Yaw';
L['Maximum Pitch adjust for the camera "look" feature.'] = 'Maximale Pitch-Anpassung für die Kamera-„Blick“-Funktion.';
L['Maximum Yaw adjust for the camera "look" feature.'] = 'Maximale Yaw-Anpassung für die Kamera-„Blick“-Funktion.';
L['Menu buttons to display on the toolbar.'] = 'Menüknöpfe für die Werkzeugleiste.';
L['Micro Menu'] = 'Mikromenü';
L['Minimal Interact Nameplate Tooltip'] = 'Minimaler Interagieren-Namensplaketten-Tooltip';
L['Modifications'] = 'Modifikationen';
L['Modifier'] = 'Modifikator';
L['Modifier 1: Shift'] = 'Modifikator 1: Umschalt';
L['Modifier 2: Ctrl'] = 'Modifikator 2: Strg';
L['Modifier 3: Alt'] = 'Modifikator 3: Alt';
L['Modifier Tap Window'] = 'Modifikator-Tipp-Fenster';
L['Modifiers'] = 'Modifikatoren';
L['Move Left'] = 'Nach links bewegen';
L['Move one of the sticks.'] = 'Einen der Sticks bewegen.';
L['Move Right'] = 'Nach rechts bewegen';
L['Movement Deadzone'] = 'Bewegungs-Deadzone';
L['Movement is analog, translated from your movement stick angle.'] = 'Bewegung ist analog, übersetzt aus dem Winkel deines Bewegungs-Sticks.';
L['Movement X Axis'] = 'Bewegungs-X-Achse';
L['Movement Y Axis'] = 'Bewegungs-Y-Achse';
L['Needs to be long enough to press and release the button.'] = 'Muss lang genug sein, um die Taste zu drücken und loszulassen.';
L['Nested Rings'] = 'Verschachtelte Ringe';
L['Next Word'] = 'Nächstes Wort';
L['No axis input detected yet.'] = 'Noch keine Achsen-Eingabe erkannt.';
L['No binding preset named %s exists.'] = 'Es gibt keine Belegungs-Voreinstellung namens %s.';
L['No button input detected yet.'] = 'Noch keine Tasten-Eingabe erkannt.';
L['No buttons were detected during the test.'] = 'Während des Tests wurden keine Tasten erkannt.';
L['No sensors were detected.'] = 'Keine Sensoren erkannt.';
L['Normal background color of pie slices.'] = 'Normale Hintergrundfarbe der Tortensegmente.';
L['Normal Color'] = 'Normalfarbe';
L['Nudge Modifier'] = 'Anstoß-Modifikator';
L['Number of buttons in the page.'] = 'Anzahl der Tasten auf der Seite.';
L['Number of buttons per row or column.'] = 'Anzahl der Tasten pro Zeile oder Spalte.';
L['Offset'] = 'Offset';
L['Offset of pointer arrow, from the selected node center, in pixels.'] = 'Offset des Zeigerpfeils vom Knotenmittelpunkt, in Pixeln.';
L['Offset X'] = 'Offset X';
L['Offset Y'] = 'Offset Y';
L['Offsets the camera horizontally from your character, for a more cinematic view.'] = 'Versetzt die Kamera horizontal von deinem Charakter, für eine filmischere Sicht.';
L['Only recommended for super users.'] = 'Nur für fortgeschrittene Benutzer empfohlen.';
L['Only use taps for cursor clicks, do not use tap presses.'] = 'Verwende nur Tipps für Cursor-Klicks, keine Tipp-Drücke.';
L['Opacity of inactive hotkey prompts on unit frames after targeting.'] = 'Deckkraft inaktiver Hotkey-Prompts auf Einheitenfenstern nach dem Anvisieren.';
L['Open Designer'] = 'Designer öffnen';
L['Open Main Config'] = 'Hauptkonfiguration öffnen';
L['Open the configuration menu for the action bar.'] = 'Konfigurationsmenü für die Aktionsleiste öffnen.';
L['Open the main configuration window.'] = 'Hauptkonfigurationsfenster öffnen.';
L['Open the main edit mode window.'] = 'Haupt-Bearbeitungsmodus-Fenster öffnen.';
L['Open the unit menu for the target unit.'] = 'Einheitenmenü für das Ziel-Einheit öffnen.';
L['Open unit menu when interacting with other players.'] = 'Einheitenmenü beim Interagieren mit anderen Spielern öffnen.';
L['Optimize Algorithm'] = 'Algorithmus optimieren';
L['or'] = 'oder';
L['Orientation of the page.'] = 'Ausrichtung der Seite.';
L['Orthodox'] = 'Orthodox';
L['Out of Mana Color'] = 'Mana-Mangel-Farbe';
L['Out of Range Color'] = 'Außer-Reichweite-Farbe';
L['Outcome'] = 'Ergebnis';
L['Over Shoulder'] = 'Über der Schulter';
L['Override'] = 'Überschreibung';
L['Override Class File'] = 'Klassendatei überschreiben';
L['Override class theme for interface styling.'] = 'Klassen-Theme für Interface-Styling überschreiben.';
L['Padding between buttons horizontally.'] = 'Abstand zwischen Tasten horizontal.';
L['Padding between buttons vertically.'] = 'Abstand zwischen Tasten vertikal.';
L['Page'] = 'Seite';
L['Page Condition'] = 'Seiten-Bedingung';
L['Page Hotkeys'] = 'Seiten-Hotkeys';
L['Page Response'] = 'Seiten-Antwort';
L['Page |cFF00FFFF%s|r'] = 'Seite |cFF00FFFF%s|r';
L['Patreon'] = 'Patreon';
L['PayPal'] = 'PayPal';
L['Performs an action and closes the menu.'] = 'Führt eine Aktion aus und schließt das Menü.';
L['Performs an action without closing the menu.'] = 'Führt eine Aktion aus, ohne das Menü zu schließen.';
L['Pet Ring'] = 'Begleiterring';
L['Pick up'] = 'Aufnehmen';
L['Pickup'] = 'Aufnahme';
L['Pitch Axis'] = 'Pitch-Achse';
L['Pitch-only deadzone for camera, applied before the 2D deadzone.'] = 'Pitch-Only-Deadzone für die Kamera, vor der 2D-Deadzone angewendet.';
L['Pitches the camera upwards as you zoom out.'] = 'Neigt die Kamera nach oben, wenn du herauszoomst.';
L['Place in slot'] = 'In Platz einfügen';
L['Place on action bar'] = 'Auf Aktionsleiste platzieren';
L['Play a sound when the pointer arrow reaches its destination.'] = 'Sound abspielen, wenn der Zeigerpfeil sein Ziel erreicht.';
L['Please provide a unique name for a new %s in %s:'] = 'Bitte gib einen eindeutigen Namen für ein neues %s in %s an:';
L['Plural Button'] = 'Plural-Taste';
L['Pointer arrow rotates in the direction of travel, and portraits scale up and down on movement.'] = 'Zeigerpfeil rotiert in Bewegungsrichtung, und Porträts skalieren bei Bewegung hoch und runter.';
L['Pointer arrow rotates in the direction of travel.'] = 'Zeigerpfeil rotiert in Bewegungsrichtung.';
L['Pointer Offset'] = 'Zeiger-Offset';
L['Pointer Size'] = 'Zeiger-Größe';
L['Position'] = 'Position';
L['Position of the artwork.'] = 'Position des Artworks.';
L['Position of the button cluster.'] = 'Position des Tasten-Clusters.';
L['Position of the button.'] = 'Position der Taste.';
L['Position of the class bar.'] = 'Position der Klassenleiste.';
L['Position of the cluster bar.'] = 'Position der Cluster-Leiste.';
L['Position of the divider.'] = 'Position des Trenners.';
L['Position of the element.'] = 'Position des Elements.';
L['Position of the group.'] = 'Position der Gruppe.';
L['Position of the page.'] = 'Position der Seite.';
L['Position of the pet ring.'] = 'Position des Begleiterrings.';
L['Position of the toolbar.'] = 'Position der Werkzeugleiste.';
L['Power Level'] = 'Akkustand';
L['Preferred size of radial menus, in pixels.'] = 'Bevorzugte Größe radialer Menüs, in Pixeln.';
L['Preset Load Condition'] = 'Voreinstellungs-Ladebedingung';
L['Presets'] = 'Voreinstellungen';
L['Press and Hold'] = 'Drücken und Halten';
L['Press your gamepad buttons to test them.'] = 'Drücke deine Gamepad-Tasten, um sie zu testen.';
L['Prevent the cursor from wrapping when navigating.'] = 'Verhindert, dass der Cursor beim Navigieren umläuft.';
L['Previous Word'] = 'Vorheriges Wort';
L['Primary accept button, to use or confirm a quick menu action.'] = 'Primäre Bestätigen-Taste, um eine Schnellmenü-Aktion zu verwenden oder zu bestätigen.';
L['Primary Button'] = 'Primäre Taste';
L['Primary Stick'] = 'Primärer Stick';
L['Prioritize raid cursor bindings over other override bindings.'] = 'Schlachtzugscursor-Belegungen vor anderen Override-Belegungen priorisieren.';
L['Priority Override'] = 'Prioritäts-Override';
L['Purple'] = 'Lila';
L['Quick Menu'] = 'Schnellmenü';
L['Radial Menus'] = 'Radiale Menüs';
L['Raid Cursor'] = 'Schlachtzugscursor';
L['Re-apply config for the active device.'] = 'Konfiguration für das aktive Gerät erneut anwenden.';
L['Reactivation Delay'] = 'Reaktivierungs-Verzögerung';
L['Realm'] = 'Realm';
L['Recharge'] = 'Aufladung';
L['Recommended as first choice modifier.'] = 'Als erste Wahl als Modifikator empfohlen.';
L['Recommended as second choice modifier.'] = 'Als zweite Wahl als Modifikator empfohlen.';
L['Reduces unexpected camera movement to reduce motion sickness.'] = 'Reduziert unerwartete Kamerabewegungen, um Übelkeit zu vermindern.';
L['Regenerate Dictionary'] = 'Wörterbuch neu erzeugen';
L['Regular'] = 'Regulär';
L['Relative Anchor'] = 'Relativer Anker';
L['Relative anchor point of the counter text on buttons.'] = 'Relativer Ankerpunkt des Zählertextes auf den Tasten.';
L['Relative anchor point of the hotkey icon on group buttons.'] = 'Relativer Ankerpunkt des Hotkey-Symbols auf Gruppentasten.';
L['Relative anchor point of the hotkey text on buttons.'] = 'Relativer Ankerpunkt des Hotkey-Textes auf den Tasten.';
L['Relative anchor point of the macro text on buttons.'] = 'Relativer Ankerpunkt des Makrotextes auf den Tasten.';
L['Relative Rescale'] = 'Relative Reskalierung';
L['Reload'] = 'Neu laden';
L['Remove all saved settings and bindings, disable addon, and reload interface.'] = 'Alle gespeicherten Einstellungen und Belegungen entfernen, Addon deaktivieren und Interface neu laden.';
L['Remove all saved settings and reload interface.'] = 'Alle gespeicherten Einstellungen entfernen und Interface neu laden.';
L['Remove Button'] = 'Entfernen-Taste';
L['Remove from %s'] = 'Aus %s entfernen';
L['Remove this set. This action cannot be undone.'] = 'Dieses Set entfernen. Diese Aktion kann nicht rückgängig gemacht werden.';
L['Removes the tooltip background for a minimalistic look.'] = 'Entfernt den Tooltip-Hintergrund für einen minimalistischen Look.';
L['Repeated Movement Delay'] = 'Wiederholte Bewegungs-Verzögerung';
L['Repeated Movement First Delay'] = 'Wiederholte Bewegungs-Erstverzögerung';
L['Replaces the default loot frame with a custom version optimized for controller navigation.'] = 'Ersetzt das Standard-Beute-Fenster durch eine für Controller-Navigation optimierte Version.';
L['Request early landing from the taxi you are currently riding.'] = 'Frühe Landung vom Taxi anfordern, das du gerade reitest.';
L['Requires /reload to fully unhook when disabled.'] = 'Benötigt /reload, um beim Deaktivieren vollständig entkoppelt zu werden.';
L['Requires a touchpad with LED support.'] = 'Benötigt ein Touchpad mit LED-Unterstützung.';
L['Requires reload.'] = 'Benötigt Neuladen.';
L['Requires Settings > Hide Cursor on Stick Input set to None.'] = 'Benötigt Einstellungen > „Cursor bei Stick-Eingabe ausblenden“ auf Keine gesetzt.';
L['Requires Toggle Interface Cursor binding to use the cursor.'] = 'Benötigt die Belegung „Interface-Cursor umschalten“, um den Cursor zu nutzen.';
L['Reset all mapping configurations and reload. (will not affect bindings)'] = 'Alle Mapping-Konfigurationen zurücksetzen und neu laden. (Belegungen nicht betroffen)';
L['Response to condition for custom processing.'] = 'Antwort auf Bedingung für benutzerdefinierte Verarbeitung.';
L['Reticle targeting means anything you place on the ground.'] = 'Visier-Zielsystem bedeutet alles, was du am Boden platzierst.';
L['Reticle targeting uses free cursor instead of staying center-fixed.'] = 'Visier-Zielsystem nutzt freien Cursor statt mittig-fixiert zu bleiben.';
L['Return Button'] = 'Zurück-Taste';
L['Returns to the previous menu.'] = 'Kehrt zum vorherigen Menü zurück.';
L['Reverse Mouse Handling'] = 'Maus-Steuerung umkehren';
L['Reverse Order'] = 'Reihenfolge umkehren';
L['Reverse the order of the buttons.'] = 'Reihenfolge der Tasten umkehren.';
L['Ring Manager'] = 'Ring-Manager';
L['Ring Scale'] = 'Ring-Skalierung';
L['Ring Size'] = 'Ringgröße';
L['Rings'] = 'Ringe';
L['Rings (Account)'] = 'Ringe (Account)';
L['Rings (Character)'] = 'Ringe (Charakter)';
L['Rotation'] = 'Rotation';
L['Rotation of the divider.'] = 'Rotation des Trenners.';
L['Run / Walk Threshold'] = 'Rennen-/Gehen-Schwelle';
L['Run Tests'] = 'Tests ausführen';
L['Save as default'] = 'Als Standard speichern';
L['Save preset from %s:'] = 'Voreinstellung von %s speichern:';
L['Save your current loadout to the preset list.'] = 'Aktuelle Belegung in die Voreinstellungs-Liste speichern.';
L['Scale of all radial menus, relative to UI scale.'] = 'Skalierung aller radialen Menüs, relativ zur UI-Skalierung.';
L['Scale of most ConsolePort frames, relative to UI scale.'] = 'Skalierung der meisten ConsolePort-Fenster, relativ zur UI-Skalierung.';
L['Scale of the cursor.'] = 'Skalierung des Cursors.';
L['Scale of the game menu and radial companion.'] = 'Skalierung des Spielmenüs und der radialen Begleitung.';
L['Scale of the keyboard.'] = 'Skalierung der Tastatur.';
L['Scale of the pet ring.'] = 'Skalierung des Begleiterrings.';
L['Secondary accept button, to use or confirm a quick menu action.'] = 'Sekundäre Bestätigen-Taste, um eine Schnellmenü-Aktion zu verwenden oder zu bestätigen.';
L['Select a device from the list to continue.'] = 'Wähle ein Gerät aus der Liste, um fortzufahren.';
L['Select a slot to bind %s and place this spell.'] = 'Wähle einen Platz, um %s zu binden und diesen Zauber zu platzieren.';
L['Select a slot to place this spell.'] = 'Wähle einen Platz, um diesen Zauber zu platzieren.';
L['Select the device you want to configure.'] = 'Wähle das Gerät, das du konfigurieren möchtest.';
L['Select the device you want to use.'] = 'Wähle das Gerät, das du verwenden möchtest.';
L['Selecting an item on a ring will stick until another item is chosen.'] = 'Die Auswahl eines Eintrags auf einem Ring bleibt haften, bis ein anderer Eintrag gewählt wird.';
L['Sensors'] = 'Sensoren';
L['Set %d |cFF757575(%s)|r'] = 'Set %d |cFF757575(%s)|r';
L['Set binding'] = 'Belegung setzen';
L['Sets if range should be a hard cutoff, even for something you can interact with.'] = 'Legt fest, ob die Reichweite eine harte Grenze sein soll, selbst für etwas, mit dem du interagieren kannst.';
L['Shift-click to Edit Binding'] = 'Umschalt-Klick zum Bearbeiten der Belegung';
L['Shift-right-click to Clear Binding'] = 'Umschalt-Rechtsklick zum Löschen der Belegung';
L['Show a color tint on the toolbar.'] = 'Farbtönung auf der Werkzeugleiste anzeigen.';
L['Show Ability Briefings'] = 'Fähigkeits-Briefings anzeigen';
L['Show Action Bar Grid on Spell Pickup'] = 'Aktionsleisten-Raster beim Aufnehmen eines Zaubers anzeigen';
L['Show active buffs in the quick menu.'] = 'Aktive Buffs im Schnellmenü anzeigen.';
L['Show active debuffs in the quick menu.'] = 'Aktive Debuffs im Schnellmenü anzeigen.';
L['Show All Action Bars'] = 'Alle Aktionsleisten anzeigen';
L['Show all enabled combinations in the cluster at all times.'] = 'Alle aktivierten Kombinationen im Cluster jederzeit anzeigen.';
L['Show bonus bar configuration for characters without stances.'] = 'Bonusleisten-Konfiguration für Charaktere ohne Haltungen anzeigen.';
L['Show Centered Cursor Tooltip'] = 'Tooltip für zentrierten Cursor anzeigen';
L['Show connected devices.'] = 'Verbundene Geräte anzeigen.';
L['Show Default Button'] = 'Standard-Taste anzeigen';
L['Show Enemy Nameplate'] = 'Feindliche Namensplakette anzeigen';
L['Show Enemy Target Icon'] = 'Feindliches Ziel-Symbol anzeigen';
L['Show Enemy Tooltip'] = 'Feindlichen Tooltip anzeigen';
L['Show Flyout Buttons'] = 'Flyout-Tasten anzeigen';
L['Show Flyouts'] = 'Flyouts anzeigen';
L['Show Friendly Nameplate'] = 'Freundliche Namensplakette anzeigen';
L['Show Friendly Target Icon'] = 'Freundliches Ziel-Symbol anzeigen';
L['Show Friendly Tooltip'] = 'Freundlichen Tooltip anzeigen';
L['Show Gauge'] = 'Anzeige anzeigen';
L['Show group loot rolls in the quick menu, allowing you to roll on items using gamepad buttons while in combat.'] = 'Gruppenbeute-Würfe im Schnellmenü anzeigen, damit du im Kampf mit Gamepad-Tasten würfeln kannst.';
L['Show help for command(s).'] = 'Hilfe für Befehl(e) anzeigen.';
L['Show Hotkeys'] = 'Hotkeys anzeigen';
L['Show icon above the current enemy soft target.'] = 'Symbol über dem aktuellen feindlichen Soft-Ziel anzeigen.';
L['Show icon above the current friendly soft target.'] = 'Symbol über dem aktuellen freundlichen Soft-Ziel anzeigen.';
L['Show icon above the current interactable object.'] = 'Symbol über dem aktuellen interagierbaren Objekt anzeigen.';
L['Show icon above the current interactable target.'] = 'Symbol über dem aktuellen interagierbaren Ziel anzeigen.';
L['Show interact binding hint on interactables.'] = 'Interaktions-Belegungshinweis auf Interagierbaren anzeigen.';
L['Show Interact Hint'] = 'Interaktions-Hinweis anzeigen';
L['Show interact tooltip on nameplates, when applicable.'] = 'Interaktions-Tooltip auf Namensplaketten anzeigen, wenn zutreffend.';
L['Show item type in the quick menu.'] = 'Gegenstandstyp im Schnellmenü anzeigen.';
L['Show Main Icons'] = 'Haupt-Symbole anzeigen';
L['Show Modifier Icons'] = 'Modifikator-Symbole anzeigen';
L['Show numerical cooldown text on buttons.'] = 'Numerischen Abklingzeit-Text auf den Tasten anzeigen.';
L['Show Object Icon'] = 'Objekt-Symbol anzeigen';
L['Show on Name Plates'] = 'Auf Namensplaketten anzeigen';
L['Show pet action bar in the quick menu.'] = 'Begleiter-Aktionsleiste im Schnellmenü anzeigen.';
L['Show ping commands in the quick menu.'] = 'Ping-Befehle im Schnellmenü anzeigen.';
L['Show Portrait'] = 'Porträt anzeigen';
L['Show portrait for the current unit, with health percentage and applicable spell casts.'] = 'Porträt für die aktuelle Einheit anzeigen, mit Lebenspunkten in Prozent und zutreffenden Zauberwirkungen.';
L['Show Status Text'] = 'Statustext anzeigen';
L['Show Target Icon'] = 'Ziel-Symbol anzeigen';
L['Show the default mouse action button.'] = 'Standard-Maus-Aktionstaste anzeigen.';
L['Show the empty buttons in the page.'] = 'Leere Tasten auf der Seite anzeigen.';
L['Show the flyout of small buttons for the button cluster.'] = 'Flyout der kleinen Tasten für den Tasten-Cluster anzeigen.';
L['Show the hotkeys on the buttons.'] = 'Hotkeys auf den Tasten anzeigen.';
L['Show the icons for main buttons.'] = 'Symbole für Haupttasten anzeigen.';
L['Show the icons for modifier buttons.'] = 'Symbole für Modifikator-Tasten anzeigen.';
L['Show the pet power and health status.'] = 'Begleiter-Macht- und Lebensstatus anzeigen.';
L['Show the pet ring when in a vehicle.'] = 'Begleiterring anzeigen, wenn du in einem Fahrzeug bist.';
L['Show the watch bars at the bottom of the toolbar.'] = 'Beobachtungsleisten am unteren Rand der Werkzeugleiste anzeigen.';
L['Show Tooltip'] = 'Tooltip anzeigen';
L['Show tooltip for enemy target.'] = 'Tooltip für feindliches Ziel anzeigen.';
L['Show tooltip for friendly target.'] = 'Tooltip für freundliches Ziel anzeigen.';
L['Show tooltip for interactables.'] = 'Tooltip für Interagierbare anzeigen.';
L['Show tooltip for mouseover targets when cursor is centered.'] = 'Tooltip für Mouseover-Ziele anzeigen, wenn der Cursor zentriert ist.';
L['Show tooltips on buttons when moused over.'] = 'Tooltips auf den Tasten anzeigen, wenn darüber gefahren wird.';
L['Show Type Icon'] = 'Typ-Symbol anzeigen';
L['Size of pointer arrow, in pixels.'] = 'Größe des Zeigerpfeils, in Pixeln.';
L['Size of the button cluster.'] = 'Größe des Tasten-Clusters.';
L['Size of the hotkey icon on group buttons.'] = 'Größe des Hotkey-Symbols auf Gruppentasten.';
L['Size of unit hotkeys, in pixels.'] = 'Größe der Einheiten-Hotkeys, in Pixeln.';
L['Space'] = 'Leertaste';
L['Speed of cursor when it starts moving.'] = 'Geschwindigkeit des Cursors, wenn er beginnt sich zu bewegen.';
L['Split stack'] = 'Stapel teilen';
L['Start moving the configuration window.'] = 'Beginne, das Konfigurationsfenster zu bewegen.';
L['Starting point of the page.'] = 'Anfangspunkt der Seite.';
L['Status Bar'] = 'Status-Leiste';
L['Stick to use for main radial actions.'] = 'Stick für radiale Hauptaktionen.';
L['Sticky Color'] = 'Sticky-Farbe';
L['Sticky Selection'] = 'Sticky-Auswahl';
L['Strafe Angle (Combat)'] = 'Strafe-Winkel (Kampf)';
L['Strafe Angle (Jump)'] = 'Strafe-Winkel (Sprung)';
L['Strafe Angle (Travel)'] = 'Strafe-Winkel (Reisen)';
L['Strafe Angle Macro Condition (Combat)'] = 'Strafe-Winkel-Makro-Bedingung (Kampf)';
L['Strafe Angle Macro Condition (Travel)'] = 'Strafe-Winkel-Makro-Bedingung (Reisen)';
L['Strata'] = 'Strata';
L['Stride'] = 'Schrittweite';
L['Style of the border around main buttons.'] = 'Stil des Rahmens um die Haupttasten.';
L['Support on Patreon'] = 'Auf Patreon unterstützen';
L['Swap to a specified action bar layout.'] = 'Zu einem bestimmten Aktionsleisten-Layout wechseln.';
L['Swipe Color'] = 'Wisch-Farbe';
L['Switch Button'] = 'Wechseln-Taste';
L['Switches between the main menu and the radial companion.'] = 'Wechselt zwischen dem Hauptmenü und der radialen Begleitung.';
L['Synchronize Bindings'] = 'Belegungen synchronisieren';
L['Synchronize Config'] = 'Konfiguration synchronisieren';
L['Take ownership of, and move the micro menu buttons to the toolbar.'] = 'Mikromenü-Tasten übernehmen und in die Werkzeugleiste verschieben.';
L['Takes the format of...\n|cFF3FC7EB[condition] Preset Name; nil|r\n\nAuto-saved presets are named "Character (Specialization) Realm", using class instead of specialization on Classic.\n\nThe preset loads outside of combat when the condition applies. Character presets take precedence over device presets.'] = [[Hat das Format von…
|cFF3FC7EB[Bedingung] Name der Voreinstellung; nil|r

Automatisch gespeicherte Voreinstellungen heißen "Charakter (Spezialisierung) Realm", auf Classic mit Klasse statt Spezialisierung.

Die Voreinstellung wird außerhalb des Kampfes geladen, wenn die Bedingung zutrifft. Charakter-Voreinstellungen haben Vorrang vor Geräte-Voreinstellungen.]];
L['Taps for cursor clicks are right clicks instead of left.'] = 'Tipps für Cursor-Klicks sind Rechtsklicks statt Linksklicks.';
L['Target enemies automatically by looking at them.'] = 'Gegner automatisch anvisieren, indem du sie anschaust.';
L['Target friends automatically by looking at them.'] = 'Freunde automatisch anvisieren, indem du sie anschaust.';
L['Target Match Lock'] = 'Ziel-Match-Sperre';
L['Target Range'] = 'Ziel-Reichweite';
L['Target Range Hard Cutoff'] = 'Ziel-Reichweite harte Grenze';
L['Targeting Mode'] = 'Ziel-Modus';
L['Test Device'] = 'Gerät testen';
L['The analog input for forward/back movement.'] = 'Die analoge Eingabe für Vorwärts-/Rückwärtsbewegung.';
L['The analog input for left/right Camera Yaw "look" feature.'] = 'Die analoge Eingabe für die Links-/Rechts-Yaw-„Blick“-Funktion.';
L['The analog input for left/right Camera Yaw.'] = 'Die analoge Eingabe für Links-/Rechts-Yaw.';
L['The analog input for left/right movement.'] = 'Die analoge Eingabe für Links-/Rechtsbewegung.';
L['The analog input for up/down Camera Pitch "look" feature.'] = 'Die analoge Eingabe für die Auf-/Ab-Pitch-„Blick“-Funktion.';
L['The analog input for up/down Camera Pitch.'] = 'Die analoge Eingabe für Auf-/Ab-Pitch.';
L['The configuration is accessible by the chat command %s or from the game menu.'] = 'Die Konfiguration ist über den Chat-Befehl %s oder das Spielmenü erreichbar.';
L['The modifier can be used to nudge the cursor position with the directional pad.'] = 'Der Modifikator kann verwendet werden, um die Cursor-Position mit dem Steuerkreuz anzustoßen.';
L['The modifier can be used to scroll together with the directional pad.'] = 'Der Modifikator kann verwendet werden, um zusammen mit dem Steuerkreuz zu scrollen.';
L['The quick menu binding can be used to close the menu as well.'] = 'Die Schnellmenü-Belegung kann auch zum Schließen des Menüs verwendet werden.';
L['The time it takes to transition from idle camera control to auto-adjustment (FOAS).'] = 'Die Zeit, die vom Leerlauf der Kamerasteuerung bis zur automatischen Anpassung (FOAS) vergeht.';
L['Thickness'] = 'Dicke';
L['Thickness in scaled pixel units.'] = 'Dicke in skalierten Pixeleinheiten.';
L['Thickness of the divider.'] = 'Dicke des Trenners.';
L['This button is necessary to use or sell an item directly from your bags.'] = 'Diese Taste ist notwendig, um einen Gegenstand direkt aus deinen Taschen zu verwenden oder zu verkaufen.';
L['This feature is only available in Classic.'] = 'Diese Funktion ist nur in Classic verfügbar.';
L['This only affects gamepad bindings.'] = 'Dies betrifft nur Gamepad-Belegungen.';
L['This will not affect your bindings, interface settings or system-wide settings.'] = 'Dies betrifft nicht deine Belegungen, Interface-Einstellungen oder systemweiten Einstellungen.';
L['This will not work with Xbox controllers connected via bluetooth. The Xbox Adapter is required.'] = 'Dies funktioniert nicht mit Xbox-Controllern, die via Bluetooth verbunden sind. Der Xbox-Adapter ist erforderlich.';
L['Time in milliseconds for the opacity to change from one state to another.'] = 'Zeit in Millisekunden für die Deckkraft-Änderung von einem Zustand in den anderen.';
L['Time in seconds to automatically hide centered cursor.'] = 'Zeit in Sekunden, um den zentrierten Cursor automatisch zu verbergen.';
L['Time in seconds to enable free cursor.'] = 'Zeit in Sekunden, um den freien Cursor zu aktivieren.';
L['Time to clear focus after intercepting stick input, in seconds.'] = 'Zeit zum Löschen des Fokus nach Stick-Eingabe, in Sekunden.';
L['Timeframe to catch a binding in the configuration, in seconds.'] = 'Zeitfenster zum Erfassen einer Belegung in der Konfiguration, in Sekunden.';
L['Timeframe to toggle the mouse cursor when double-tapping a selected modifier.'] = 'Zeitfenster zum Umschalten des Mauscursors beim Doppeltippen eines ausgewählten Modifikators.';
L['Timeout clears focus after a set time, deadzone clears focus when stick input is neutral.'] = 'Timeout löscht den Fokus nach einer festgelegten Zeit, Deadzone löscht den Fokus, wenn die Stick-Eingabe neutral ist.';
L['Tint Color'] = 'Tönungs-Farbe';
L['Toggle visibility of all modifier flyouts for cluster action bars.'] = 'Sichtbarkeit aller Modifikator-Flyouts für Cluster-Aktionsleisten umschalten.';
L['Toggle visibility of all modifier flyouts.'] = 'Sichtbarkeit aller Modifikator-Flyouts umschalten.';
L['Toolbar'] = 'Werkzeugleiste';
L['Tooltip'] = 'Tooltip';
L['Top speed of cursor movement.'] = 'Höchstgeschwindigkeit der Cursor-Bewegung.';
L['Touch Tap Buttons'] = 'Berührungs-Tipp-Tasten';
L['Touch Tap Exclusive Click'] = 'Berührungs-Tipp Exklusiver Klick';
L['Touch Tap Max Time'] = 'Max. Berührungs-Tipp-Zeit';
L['Touch Tap Right Click'] = 'Berührungs-Tipp Rechtsklick';
L['Touchpad'] = 'Touchpad';
L['Transition'] = 'Übergang';
L['Transition time for opacity changes.'] = 'Übergangszeit für Deckkraft-Änderungen.';
L['Travel Time'] = 'Reisezeit';
L['Trigger button actions on press instead of release.'] = 'Tasten-Aktionen beim Drücken statt beim Loslassen auslösen.';
L['Triggers'] = 'Trigger';
L['Turn Character With Camera'] = 'Charakter mit Kamera drehen';
L['Turn your character facing when you turn your camera angle.'] = 'Dreht die Blickrichtung deines Charakters, wenn du den Kamerawinkel änderst.';
L['Type of LED color to use for the touchpad.'] = 'Typ der LED-Farbe für das Touchpad.';
L['Types are PlayStation, Xbox, or Generic.'] = 'Typen sind PlayStation, Xbox oder Generisch.';
L['Unit Hotkeys'] = 'Einheiten-Hotkeys';
L['Unit Pool'] = 'Einheiten-Pool';
L['Unknown device selected.'] = 'Unbekanntes Gerät ausgewählt.';
L['Unlimited Navigation'] = 'Unbegrenzte Navigation';
L['Unmapped keyboard key(s) detected:'] = 'Nicht zugeordnete Tastatur-Taste(n) erkannt:';
L['Use a custom set of buttons for the game menu, otherwise the button set will be dynamically determined.'] = 'Einen benutzerdefinierten Tastensatz für das Spielmenü verwenden, ansonsten wird der Tastensatz dynamisch bestimmt.';
L['Use a targeting binding to turn a soft target into a hard target.'] = 'Verwende eine Zielbelegung, um ein Soft-Ziel in ein Hard-Ziel zu verwandeln.';
L['Use character specific addon settings for this character.'] = 'Charakterspezifische Addon-Einstellungen für diesen Charakter verwenden.';
L['Use Custom Button Set'] = 'Benutzerdefinierten Tastensatz verwenden';
L['Use Custom Loot Frame'] = 'Benutzerdefiniertes Beute-Fenster verwenden';
L['Use Default Hotkey Icons'] = 'Standard-Hotkey-Symbole verwenden';
L['Use Focus Mode'] = 'Fokus-Modus verwenden';
L['Use Global Loot Tooltip'] = 'Globalen Beute-Tooltip verwenden';
L['Use Hardware Mouse Cursor'] = 'Hardware-Mauscursor verwenden';
L['Use Instant Mode'] = 'Instant-Modus verwenden';
L['Use Interact Nameplate Tooltip'] = 'Interaktions-Namensplaketten-Tooltip verwenden';
L['Use On Demand'] = 'Bei Bedarf verwenden';
L['Use optimized pathfinding algorithm for cursor movement.'] = 'Optimierten Pfadfindungs-Algorithmus für die Cursor-Bewegung verwenden.';
L['Use press and hold to navigate and use rings. Press, point, release.'] = '„Drücken und Halten“ zum Navigieren und Verwenden von Ringen nutzen. Drücken, zeigen, loslassen.';
L['Use Static Mode'] = 'Statischen Modus verwenden';
L['Use the hardware cursor provided by the operating system.'] = 'Den vom Betriebssystem bereitgestellten Hardware-Cursor verwenden.';
L['Use together with [@cursor] macros to place reticle spells in a single click.'] = 'Zusammen mit [@cursor]-Makros verwenden, um Visier-Zauber mit einem Klick zu platzieren.';
L['Used for interacting with the world, at a center-fixed position.'] = 'Zur Interaktion mit der Welt verwendet, an einer mittig-fixierten Position.';
L['Uses global tint color when transparent.'] = 'Verwendet die globale Tönungsfarbe bei Transparenz.';
L['Uses the default hotkey icons instead of the custom icons provided by ConsolePort.'] = 'Verwendet die Standard-Hotkey-Symbole statt der von ConsolePort bereitgestellten benutzerdefinierten Symbole.';
L['Valid Action Deadzone'] = 'Gültige-Aktion-Deadzone';
L['Value below two may appear interlaced or not at all.'] = 'Werte unter zwei können verzahnt oder gar nicht erscheinen.';
L['Vertical Offset'] = 'Vertikaler Offset';
L['Vertical offset from anchor point.'] = 'Vertikaler Offset vom Ankerpunkt.';
L['Vertical offset of the counter text on buttons.'] = 'Vertikaler Offset des Zählertextes auf den Tasten.';
L['Vertical offset of the hotkey icon on group buttons.'] = 'Vertikaler Offset des Hotkey-Symbols auf Gruppentasten.';
L['Vertical offset of the hotkey prompt position, in pixels.'] = 'Vertikaler Offset der Hotkey-Prompt-Position in Pixeln.';
L['Vertical offset of the hotkey text on buttons.'] = 'Vertikaler Offset des Hotkey-Textes auf den Tasten.';
L['Vertical offset of the macro text on buttons.'] = 'Vertikaler Offset des Makrotextes auf den Tasten.';
L['Vertical Padding'] = 'Vertikale Polsterung';
L['Vertical position of centered cursor & targeting, as fraction of screen height.'] = 'Vertikale Position des zentrierten Cursors und Zielsystems, als Bruchteil der Bildschirmhöhe.';
L['Visibility Condition'] = 'Sichtbarkeits-Bedingung';
L['Watch bars include XP, reputation, honor, artifact power, and azerite.'] = 'Beobachtungsleisten umfassen XP, Ruf, Ehre, Artefaktmacht und Azerit.';
L['When disabled, a button press will also act as a cursor click.'] = 'Wenn deaktiviert, agiert ein Tastendruck auch als Cursor-Klick.';
L['When disabled, you will need to press the accept button to confirm a selection.'] = 'Wenn deaktiviert, musst du die Bestätigen-Taste drücken, um eine Auswahl zu bestätigen.';
L['When enabled, a tap will act as a button press.'] = 'Wenn aktiviert, agiert ein Tipp als Tastendruck.';
L['When set to both sticks, cursor only disables when both sticks are used together.'] = 'Wenn auf beide Sticks gesetzt, wird der Cursor nur deaktiviert, wenn beide Sticks gleichzeitig verwendet werden.';
L['Whether client keybindings should be saved to the server.'] = 'Ob Client-Tastenbelegungen auf dem Server gespeichert werden sollen.';
L['Whether the keyboard should always be shown or only when a gamepad is active.'] = 'Ob die Tastatur immer angezeigt werden soll oder nur, wenn ein Gamepad aktiv ist.';
L['Whether to save character- and account-scoped variables to the server.'] = 'Ob Charakter- und Account-Variablen auf dem Server gespeichert werden sollen.';
L['Which button set to use for unit hotkeys.'] = 'Welcher Tastensatz für Einheiten-Hotkeys verwendet wird.';
L['Which modifier to use for modified commands.'] = 'Welcher Modifikator für modifizierte Befehle verwendet wird.';
L['Which modifier to use for nudging the cursor.'] = 'Welcher Modifikator zum Anstoßen des Cursors verwendet wird.';
L['Which modifier to use to toggle the mouse cursor when double-tapped.'] = 'Welcher Modifikator zum Umschalten des Mauscursors beim Doppeltippen verwendet wird.';
L['Which modifier to use with the movement buttons to move the cursor.'] = 'Welcher Modifikator mit den Bewegungstasten verwendet wird, um den Cursor zu bewegen.';
L['While disabled, cursor timeout, and toggling between free-roaming and center-fixed cursor are also disabled.'] = 'Wenn deaktiviert, sind auch Cursor-Timeout und Umschalten zwischen freiem und mittig-fixiertem Cursor deaktiviert.';
L['While held down, can simulate dragging by clicking on the directional pad.'] = 'Solange gehalten, kann das Ziehen durch Klicken auf das Steuerkreuz simuliert werden.';
L['Width of the artwork.'] = 'Breite des Artworks.';
L['Width of the cluster bar.'] = 'Breite der Cluster-Leiste.';
L['Width of the crosshair, in scaled pixel units.'] = 'Breite des Fadenkreuzes in skalierten Pixeleinheiten.';
L['Width of the group.'] = 'Breite der Gruppe.';
L['Width of the toolbar.'] = 'Breite der Werkzeugleiste.';
L['Wipe Dictionary'] = 'Wörterbuch leeren';
L['Wired'] = 'Verkabelt';
L['Works like a regular action bar, which displays the action slots of a specified action page.'] = 'Funktioniert wie eine reguläre Aktionsleiste, die die Aktions-Slots einer angegebenen Aktionsseite anzeigt.';
L['X Offset'] = 'X-Offset';
L['XP Bar Color'] = 'XP-Leisten-Farbe';
L['Y Offset'] = 'Y-Offset';
L['Yaw Axis'] = 'Yaw-Achse';
L['Yaw-only deadzone for camera, applied before the 2D deadzone.'] = 'Yaw-Only-Deadzone für die Kamera, vor der 2D-Deadzone angewendet.';
L['your current loadout'] = 'deine aktuelle Belegung';
---------------------------------------------------------------
-- Literal block entries
---------------------------------------------------------------
L['%s is already bound to\n%s\n\nDo you want to change it to\n%s?'] = [[%s ist bereits belegt mit
%s

Möchtest du es ändern zu
%s?]];
L['+ Normal\n- Inverted'] = [[+ Normal
- Invertiert]];
L['Basic redirect cannot route macros or ambiguous spells. Use target mode or focus mode with [@focus] macros to control behavior.'] = [[Einfache Umleitung kann keine Makros oder mehrdeutigen Zauber leiten. Verwende Ziel-Modus oder Fokus-Modus mit [@focus]-Makros, um das Verhalten zu steuern.]];
L['Buttons emulating modifiers will instead trigger bindings when pressed and released within the time span.'] = [[Tasten, die Modifikatoren emulieren, lösen stattdessen Belegungen aus, wenn sie innerhalb des Zeitfensters gedrückt und losgelassen werden.]];
L['Change how the raid cursor acquires a target. Redirect and focus modes will reroute appropriate spells without changing your target.'] = [[Ändert, wie der Schlachtzugscursor ein Ziel erfasst. Umleitungs- und Fokusmodi leiten passende Zauber um, ohne dein Ziel zu wechseln.]];
L['Controls when your character transitions from strafing to facing your movement stick direction while in combat. Expressed in degrees, from looking straight forward.'] = [[Steuert, wann dein Charakter im Kampf vom Strafing zum Drehen in Bewegungsrichtung wechselt. Ausgedrückt in Grad, von gerade vorwärts gemessen.]];
L['Controls when your character transitions from strafing to facing your movement stick direction while in the air. Expressed in degrees, from looking straight forward.'] = [[Steuert, wann dein Charakter in der Luft vom Strafing zum Drehen in Bewegungsrichtung wechselt. Ausgedrückt in Grad, von gerade vorwärts gemessen.]];
L['Controls when your character transitions from strafing to facing your movement stick direction. Expressed in degrees, from looking straight forward.'] = [[Steuert, wann dein Charakter vom Strafing zum Drehen in Bewegungsrichtung wechselt. Ausgedrückt in Grad, von gerade vorwärts gemessen.]];
L['Duration after using gamepad and mouse at the same time before switching to just one or the other, in milliseconds.'] = [[Dauer nach gleichzeitiger Nutzung von Gamepad und Maus, bevor auf nur eines der beiden umgeschaltet wird, in Millisekunden.]];
L['Enable custom mouse handling, automating cursor toggling and timeout while using left and right mouse button emulation.'] = [[Benutzerdefinierte Maus-Steuerung aktivieren, automatisiert Cursor-Umschaltung und Timeout bei Verwendung der Links-/Rechts-Maus-Emulation.]];
L['Groups button combinations in circular clusters which switch between different actions when modifiers are used.'] = [[Gruppiert Tastenkombinationen in kreisförmigen Clustern, die zwischen verschiedenen Aktionen wechseln, wenn Modifikatoren verwendet werden.]];
L['Left mouse button emulation toggles center-fixed mode instead of free-roaming mode. Right mouse button emulation toggles free-roaming mode instead of center-fixed mode.'] = [[Linke Maustasten-Emulation schaltet zwischen mittig-fixiertem Modus statt freiem Modus um. Rechte Maustasten-Emulation schaltet zwischen freiem Modus statt mittig-fixiertem Modus um.]];
L['Macro condition to enable the click override button. The default condition clicks right mouse button when there is no enemy target.'] = [[Makro-Bedingung zur Aktivierung der Klick-Override-Taste. Die Standardbedingung klickt die rechte Maustaste, wenn es kein feindliches Ziel gibt.]];
L['Modifiers should be in descending order. M2M1, for example, is the Ctrl and Shift modifiers held at the same time.'] = [[Modifikatoren sollten in absteigender Reihenfolge sein. M2M1 z. B. sind Strg- und Umschalt-Modifikatoren gleichzeitig gehalten.]];
L['Opacity is expressed in percentage, where 100 is fully visible and 0 is fully transparent. Values outside of the 0-100 range will be clamped.'] = [[Deckkraft in Prozent, wobei 100 vollständig sichtbar und 0 vollständig transparent ist. Werte außerhalb von 0–100 werden begrenzt.]];
L['Takes the format of...\n'] = [[Hat das Format von…
]];
L['The bindings underlying the button combinations will be unavailable while the cursor is in use.\n\nModifier can also be configured on a per button basis.'] = [[Die Belegungen, die den Tastenkombinationen zugrunde liegen, sind während der Cursor-Verwendung nicht verfügbar.

Modifikator kann auch pro Taste konfiguriert werden.]];
L['Use a shoulder button combined with crosshair for smooth and precise interactions. The click is performed at crosshair or cursor location.'] = [[Verwende eine Schultertaste in Kombination mit dem Fadenkreuz für sanfte und präzise Interaktionen. Der Klick erfolgt an der Fadenkreuz- oder Cursor-Position.]];
L['Use global game tooltip for loot information, allowing other addons to add information to lootable items.'] = [[Globalen Spiel-Tooltip für Beute-Informationen verwenden, damit andere Addons Informationen zu plünderbaren Gegenständen hinzufügen können.]];
L['When set to zero, always face your movement stick direction.\nWhen set to max, never face your movement stick direction.'] = [[Auf null gesetzt, drehst du dich immer in deine Bewegungs-Stick-Richtung.
Auf Max gesetzt, drehst du dich nie in deine Bewegungs-Stick-Richtung.]];
L['Your %s device has separate handling for Bluetooth and wired connection.\nWhich one are you using?'] = [[Dein %s-Gerät hat separate Behandlung für Bluetooth und kabelgebundene Verbindung.
Welche verwendest du?]];
