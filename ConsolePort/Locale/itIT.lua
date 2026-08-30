local L = select(2, ...).Locale;
---------------------------------------------------------------
-- itIT Italiano Italian
---------------------------------------------------------------
---------------------------------------------------------------
-- Short / curated keys
---------------------------------------------------------------
L.ACTIONBAR_FORM_ACTIVE_DESC  = 'Questa forma è attualmente attiva, e la tua barra delle azioni principale sta mostrando le abilità ad essa associate.'; -- en:b400a632
L.DESC_CAMERAZOOMIN           = 'Avvicina la telecamera. Tieni premuto per zoom continuo.'; -- en:55f9b91f
L.DESC_CAMERAZOOMOUT          = 'Allontana la telecamera. Tieni premuto per zoom continuo.'; -- en:a6b9d796
L.DESC_OPENALLBAGS            = 'Apre e chiude tutte le borse.'; -- en:4a74797f
L.DESC_RING_TARGET            = "Mostra il tuo pool unità in un menù radiale, permettendoti di bersagliare un'unità con lo stick radiale."; -- en:294b636e
L.DESC_TOGGLEWORLDMAP_CLASSIC = 'Alterna la mappa del mondo.'; -- en:00548e70
L.DESC_TOGGLEWORLDMAP_RETAIL  = 'Alterna la mappa del mondo e il diario delle missioni combinati.'; -- en:621a94e8
L.FORMAT_HOLD_BINDING         = '%s (tieni premuto)'; -- en:c3ecd1b3
L.FORMAT_RING_NUMERICAL       = 'Menù radiale |cFF00FFFF%s|r'; -- en:68d18518
L.NAME_EASY_MOTION            = 'Bersaglia riquadri unità (tieni premuto)'; -- en:e6f0c131
L.NAME_QUICK_MENU             = 'Menù rapido'; -- en:ed9a0668
L.NAME_RAID_CURSOR_FOCUS      = 'Cursore incursione (focus)'; -- en:d350d370
L.NAME_RAID_CURSOR_TARGET     = 'Cursore incursione (bersaglio)'; -- en:8182d5d5
L.NAME_RAID_CURSOR_TOGGLE     = 'Alterna cursore incursione'; -- en:79fb9d46
L.NAME_RING_MENU              = 'Menù radiale'; -- en:8d7e5939
L.NAME_RING_PET               = 'Menù radiale compagno'; -- en:8dab5a0e
L.NAME_RING_TARGET            = 'Menù radiale bersaglio (tieni premuto)'; -- en:59e8a9cb
L.NAME_RING_UTILITY           = 'Menù radiale strumenti'; -- en:96bc880d
L.NAME_UI_CURSOR_TOGGLE       = 'Alterna cursore di interfaccia'; -- en:2d6091b5
L.RING_EMPTY_DESC             = 'Non hai ancora abilità in questo menù radiale.'; -- en:044cf09a
---------------------------------------------------------------
-- Long / curated block entries
---------------------------------------------------------------
L.ACTIONBAR_FORM_DESC = [[Attivare questa forma cambierà automaticamente la tua barra delle azioni principale per mostrare le abilità associate a questa forma.

La forma condivide le scorciatoie con la tua barra delle azioni principale, permettendoti di usare i tuoi combo abituali per accedere alle abilità in questa forma.

Quando esci da questa forma, la tua barra delle azioni principale tornerà allo stato precedente, mostrando le tue abilità abituali.]]; -- en:a751197a
L.ACTIONBAR_MAIN_DESC = [[La barra delle azioni principale è la tua posizione principale per le abilità di rotazione e altre azioni usate di frequente.

Questa barra è dinamica e può cambiare automaticamente pagina a seconda della situazione corrente.

Ad esempio, la barra delle azioni principale passerà a un set speciale di abilità quando entri in un veicolo, partecipi a una battaglia di compagni, ti trasformi in un'altra forma, entri in una posa di combattimento o prendi il controllo di un'altra unità.

Questo ti permette di accedere ad abilità specifiche del contesto senza dover cambiare manualmente la configurazione della barra delle azioni.

Quando torni al tuo stato normale, le tue abilità abituali riappariranno sulla barra.]]; -- en:8e47cecd
L.ACTIONBAR_PAGE_MISMATCH_DESC = [[Il numero di pagina effettivo di una barra delle azioni non corrisponde sempre al nome visualizzato, a causa di come il sistema delle barre delle azioni è stato originariamente progettato.

Questa discrepanza può essere ignorata se non stai usando una soluzione di pagina azione personalizzata. Entrambi sono mostrati come riferimento.]]; -- en:9fd917fd
L.ADD_NEW_RING_TEXT = [[|cFFFFFF00Crea nuovo menù radiale|r
Per favore, scegli un nome per il tuo nuovo menù radiale:]]; -- en:00af872a
L.CLEAR_RING_TEXT = [[|cFFFFFF00Svuota %s|r
Sei sicuro di voler svuotare il menù radiale?]]; -- en:ebc807d8
L.CONTROLS_GAMEPAD_TESTER_ACTION = [[
	I test scadranno automaticamente dopo pochi secondi se non viene rilevato alcun input.
]]; -- en:0f591dc7
L.CONTROLS_GAMEPAD_TESTER_DESC = [[
	Usa lo strumento di test per verificare che il tuo gamepad funzioni correttamente.

	Il test ti chiederà di premere i pulsanti e muovere gli assi del gamepad,
	per assicurare che tutti i pulsanti e i sensori funzionino come previsto.

	Risoluzione dei problemi:

	- Assicurati che il gamepad sia connesso e riconosciuto dal sistema operativo.

	- Controlla se c'è software in conflitto che potrebbe interferire con il dispositivo,
	come Steam in esecuzione in background su Windows.

	- Se usi un computer portatile, assicurati che il dispositivo sia in modalità gioco
	nel centro di controllo. La modalità desktop non funzionerà correttamente.

	- Aggiorna i driver e installa qualsiasi software necessario per il gamepad.
]]; -- en:fd1ed2f5
L.CONTROLS_GENERAL_INFO = [[
	Seleziona il tuo schema di controllo preferito.
]]; -- en:3f779845
L.CONTROLS_MODIFIERS_CUSTOM = [[
	Usa impostazioni di modificatore personalizzate.

	È consigliato impostare i modificatori sui dorsali o sui grilletti, in quanto sono i pulsanti più accessibili del gamepad.
]]; -- en:964cdf45
L.CONTROLS_MODIFIERS_DESC = [[
	I modificatori alternano tra set di scorciatoie ed emulano anche i tasti di controllo della tastiera (Maiusc, Ctrl, Alt).

	Tenere premuto un modificatore alternerà temporaneamente le scorciatoie a un set alternativo, espandendo le azioni disponibili.

	I modificatori possono essere premuti — pressati e rilasciati rapidamente — per eseguire le scorciatoie normali.

	Possono anche essere combinati tra loro; usare due modificatori ti dà un totale di quattro set di scorciatoie,
	e tre modificatori ti danno otto set.

	Due modificatori sono sufficienti per la maggior parte dei giocatori per avere un set confortevole di scorciatoie,
	senza aggiungere troppa complessità.
]]; -- en:b083ec08
L.CONTROLS_MODIFIERS_LEFT = [[
	Usa modificatori per mancini per mantenere il movimento e il cambio di set di scorciatoie sul lato sinistro del gamepad.

	Avere ruoli separati per la mano sinistra e quella destra può aiutare con ergonomia e coordinazione.
]]; -- en:507e5d94
L.CONTROLS_MODIFIERS_TRIGGERS = [[
	Usa entrambi i grilletti come modificatori per dividere le scorciatoie tra il lato sinistro e quello destro.

	Può essere utile se stai passando da FFXIV, o se preferisci il modello mentale della crossbar.
]]; -- en:70401fbd
L.CONTROLS_MOUSE_BUTTONS_DESC = [[
	I pulsanti del mouse possono essere emulati per fornire funzionalità simili a un mouse.

	Queste scorciatoie sono vitali in alcuni casi, come confermare il posizionamento di incantesimi a terra,
	selezionare con precisione in una folla e azioni di interfaccia specifiche.

	Possono essere combinati con i modificatori per replicare ulteriormente la funzionalità di un mouse.

	Questi pulsanti vengono anche usati per alternare il cursore, che può avere tre stati:

	- Libero; puoi usare il tuo gamepad per muovere il cursore sullo schermo.

	- Centrato; il cursore è fisso al centro dello schermo, per puntare a oggetti e personaggi
	e per posizionare incantesimi a terra.

	- Nascosto; il cursore è ancora centrato, ma non è visibile sullo schermo. La sua posizione è indicata da un mirino.
]]; -- en:e088d19f
L.CONTROLS_MOUSE_CUSTOM = [[
	Usa impostazioni dei pulsanti del mouse personalizzate.

	World of Warcraft tratta i pulsanti del mouse in due modi separati, principalmente nascosti.

	- Quando clicchi sull'interfaccia di gioco (come pulsanti o menù), l'interfaccia reagisce
	solo ai click del mouse, che possono essere emulati da un gamepad.

	- Quando clicchi su cose nel mondo di gioco (come selezione di bersagli o interazione), vengono usate le scorciatoie normali.

	È altamente raccomandato tenere queste azioni insieme per ricoprire lo stesso ruolo di un mouse.
]]; -- en:3e862670
L.CONTROLS_MOUSE_INVERTED = [[
	Usa scorciatoie dei pulsanti del mouse invertite.

	Usa lo stick sinistro per alternare tra le modalità cursore centrato e nascosto, e per il click destro.

	Usa lo stick destro per alternare la modalità cursore libero e per il click sinistro.
]]; -- en:16d3d6d2
L.CONTROLS_MOUSE_REGULAR = [[
	Usa scorciatoie dei pulsanti del mouse normali.

	Usa lo stick sinistro per alternare la modalità cursore libero e per il click sinistro.

	Usa lo stick destro per alternare tra le modalità cursore centrato e nascosto, e per il click destro.
]]; -- en:75e9f21b
L.CONTROLS_MOVEMENT_BALANCED_DESC = [[
	Il movimento bilanciato è un compromesso tra il movimento tank e quello a seguire.

	Sia in combattimento che in viaggio, questa configurazione effettua il passo laterale fino a 115 gradi in ogni direzione,
	cioè continui a guardare in avanti mentre ti muovi lateralmente.

	Se muovi lo stick ulteriormente verso il basso, il tuo personaggio passerà a seguire la direzione di movimento.
	Guarda la testa del tuo personaggio per vedere in che direzione sta guardando.

	115 gradi è il punto ottimale per offrire la massima copertura senza perdere velocità di movimento.
]]; -- en:3355743a
L.CONTROLS_MOVEMENT_DESC = [[
	I controlli di movimento possono essere personalizzati in base al tuo stile di gioco.

	I gamepad usano il movimento analogico, quindi puoi correre in qualsiasi direzione,
	e camminare variando la pressione applicata sullo stick.

	Il gioco fa molto affidamento sul passo laterale come meccanica,
	dove ti muovi lateralmente mentre guardi in una direzione diversa.

	Puoi personalizzare quando il tuo personaggio passa tra
	il passo laterale e il girarsi verso la direzione di movimento.

	Evidenzia una delle configurazioni e muovi lo stick sinistro
	per provarla.
]]; -- en:9d22c4f0
L.CONTROLS_MOVEMENT_FOLLOW_DESC = [[
	Il movimento «a seguire» si concentra sul seguire la direzione in cui ti stai muovendo.

	Sia in combattimento che in viaggio, questa configurazione non effettua mai il passo laterale
	e non cammina mai all'indietro.

	Può essere utile per giocatori che giocano spesso o sempre con una configurazione a un solo stick.
]]; -- en:45773d56
L.CONTROLS_MOVEMENT_TANK_DESC = [[
	Il movimento tank si concentra sul mantenere una posizione rivolta in avanti durante il combattimento.

	In combattimento, questa configurazione eseguirà sempre il passo laterale e camminerà all'indietro per restare rivolto in avanti.

	Durante il viaggio, questa configurazione seguirà sempre la direzione di movimento.
]]; -- en:9fcbcaaf
L.DEFAULTS_BINDINGS_EMPTY_DESC = [[
	Inizia da zero.

	Questa azione cancellerà tutte le tue scorciatoie attuali del gamepad, compresi i predefiniti di Blizzard,
	per permetterti di configurare le scorciatoie da zero.

	Questa azione non sovrascrive né interferisce con le scorciatoie da tastiera esistenti,
	ma tieni presente che le barre delle azioni sono condivise tra le due.

	Se intendi alternare tra tastiera e gamepad, è consigliato modificare le tue
	scorciatoie del gamepad anziché spostare le abilità sulle barre delle azioni.
]]; -- en:51053386
L.DEFAULTS_BINDINGS_PRESET_DESC = [[
	Applica le scorciatoie raccomandate.

	Queste scorciatoie sono basate sulle tue scelte precedenti e dovrebbero darti un buon punto di partenza
	per la configurazione del gamepad. Puoi sempre modificarle in seguito.

	Questa azione non sovrascrive né interferisce con le scorciatoie da tastiera esistenti,
	ma tieni presente che le barre delle azioni sono condivise tra le due.

	Se intendi alternare tra tastiera e gamepad, è consigliato modificare le tue
	scorciatoie del gamepad anziché spostare le abilità sulle barre delle azioni.
]]; -- en:6ac789b1
L.DEFAULTS_GENERAL_INFO = [[
	Completa la configurazione applicando impostazioni e scorciatoie raccomandate per il tuo gamepad.
]]; -- en:c436023e
L.DEFAULTS_SETTINGS_APPLIED = [[
	Le impostazioni raccomandate per il tuo tipo di gamepad (%s) sono state applicate.
]]; -- en:16be45b5
L.DEFAULTS_SETTINGS_DESC = [[
	Applica le impostazioni raccomandate per il tuo tipo di gamepad (%s):
]]; -- en:15a4050f
L.DEFAULTS_SETTINGS_NOTWEAK = [[
	Il tuo tipo di gamepad (%s) non ha alcuna impostazione raccomandata da applicare.
]]; -- en:067a8a20
L.DESC_EASY_MOTION = [[
	Genera scorciatoie per le unità nei tuoi riquadri unità sullo schermo,
	permettendoti di passare rapidamente tra bersagli amici.

	Per usarlo, tieni premuta la scorciatoia, poi premi i
	tasti indicati sul bersaglio scelto, quindi rilascia
	la scorciatoia per cambiare bersaglio.

	Questa scorciatoia è altamente raccomandata per i guaritori in contenuti
	a 5 giocatori, in quanto fornisce un metodo estremamente rapido di
	selezione del bersaglio in gruppi piccoli.

	Nelle incursioni, la complessità dell'input necessario
	per individuare il bersaglio preferito può essere scoraggiante.
	Vedi «Alterna cursore incursione» per un'alternativa.
]]; -- en:0f9384b6
L.DESC_EXTRAACTIONBUTTON1 = [[
	Il pulsante azione aggiuntiva ospita un'abilità temporanea usata in
	diverse missioni, scenari e incontri con boss.

	Quando questa scorciatoia non è impostata, il pulsante azione aggiuntiva è sempre
	disponibile nel menù radiale degli strumenti.

	Questo pulsante appare sulla tua barra delle azioni del gamepad come un normale
	pulsante azione, ma non puoi cambiarne il contenuto.
]]; -- en:6dd42998
L.DESC_INTERACTTARGET = [[
	Ti permette di interagire con PNG e oggetti del mondo di gioco.

	Ha la stessa capacità del cursore centrale, ma non richiede di
	puntare il cursore o il mirino direttamente sul bersaglio.

	Gli oggetti interattivi vengono evidenziati quando sono nel raggio.
]]; -- en:b1478add
L.DESC_JUMP = [[
	Può anche essere usato per nuotare verso l'alto sott'acqua, salire con
	cavalcature volanti e decollare o battere le ali in volo a dorso di drago.

	Saltare è utile per colmare lacune nel movimento mentre esegui un'
	azione con la mano sinistra che richiede il pollice.

	In una configurazione normale, lo stick sinistro controlla il movimento.
	Se devi premere una combinazione del pad direzionale in movimento,
	saltare può servire a mantenere lo slancio in avanti, mentre
	togli brevemente il pollice dallo stick.
]]; -- en:4c032315
L.DESC_KEY_BUTTON1 = [[
	Usato per alternare il cursore libero, permettendoti di usare lo stick della telecamera come un puntatore del mouse.
]]; -- en:fd3d111a
L.DESC_KEY_BUTTON2 = [[
	Usato per alternare il cursore centrato, permettendoti di interagire con oggetti e personaggi
	del mondo di gioco, in una posizione fissa al centro del mouse.
]]; -- en:2f5c87e4
L.DESC_QUICK_MENU = [[
	Un menù ad accesso rapido che raccoglie le azioni comuni eseguite
	durante il gioco, come tirare il dado per il bottino di gruppo, annullare
	benefici o usare un oggetto dalle borse.
]]; -- en:0365846b
L.DESC_RAID_CURSOR = [[
	Alterna un cursore che si aggancia ai tuoi
	riquadri unità sullo schermo, permettendoti di curare giocatori amici
	mentre mantieni un altro bersaglio.

	Il cursore incursione può anche essere impostato per puntare direttamente,
	dove muovere il cursore cambierà il tuo bersaglio attuale.

	Durante l'uso, il cursore incursione occupa un set di
	combinazioni del pad direzionale per controllare la posizione del cursore.

	In modalità reindirizzamento, il cursore non reindirizza macro o
	incantesimi ambigui, come la Penitenza di un sacerdote.

	Vedi «Bersaglia riquadri unità» per un'alternativa.
]]; -- en:cacdf9c0
L.DESC_RING_CUSTOM = [[
	Un menù radiale dove puoi aggiungere oggetti, incantesimi, macro e
	cavalcature per cui non vuoi sacrificare spazio sulla barra delle azioni.

	Per usarlo, tieni premuta la scorciatoia, inclina lo stick nella direzione
	dell'oggetto che vuoi selezionare, poi rilascia la scorciatoia.

	Per rimuovere oggetti, segui l'invito del tooltip quando hai
	l'oggetto in questione a fuoco.
]]; -- en:159abd06
L.DESC_RING_MENU = [[
	Un menù radiale che raccoglie pannelli comuni e azioni frequenti
	in un solo posto per un accesso rapido.

	Il menù è accessibile anche dal menù di gioco senza una
	scorciatoia separata, cambiando pagina.
]]; -- en:7ee244a1
L.DESC_RING_PET = [[
	Un menù radiale che ti permette di controllare il tuo compagno attuale.
]]; -- en:b1c4b5d3
L.DESC_RING_UTILITY = [[
	Un menù radiale dove puoi aggiungere oggetti, incantesimi, macro e
	cavalcature per cui non vuoi sacrificare spazio sulla barra delle azioni.

	Per usarlo, tieni premuta la scorciatoia, inclina lo stick nella direzione
	dell'oggetto che vuoi selezionare, poi rilascia la scorciatoia.

	Per aggiungere oggetti al menù, segui l'invito del cursore di interfaccia,
	oppure raccogli qualcosa con il cursore del mouse e premi la scorciatoia
	per rilasciarlo nel menù.

	Per rimuovere oggetti, segui l'invito del tooltip quando hai
	l'oggetto in questione a fuoco.

	Il menù radiale degli strumenti aggiunge automaticamente oggetti della missione e
	abilità temporanee non posizionate sulla tua barra delle azioni.
]]; -- en:de107e96
L.DESC_TARGETNEARESTENEMY = [[
	Alterna tra i bersagli nemici più vicini davanti a te.
	Senza un bersaglio corrente, verrà selezionato il nemico più centrale.
	Altrimenti scorrerà tra i bersagli più vicini.

	Tieni premuto per evidenziare bersagli prima di decidere
	di cambiare bersaglio.

	Raccomandato come scorciatoia secondaria di selezione del bersaglio,
	o come scorciatoia principale nel gioco casual o se
	la scansione del bersaglio richiede troppa precisione per essere comoda.

	Non raccomandato per spedizioni o altri scenari ad alta precisione.
]]; -- en:981bc29c
L.DESC_TARGETSCANENEMY = [[
	Scansiona nemici in un cono stretto davanti a te.
	Tieni premuto per evidenziare bersagli prima di decidere
	di cambiare bersaglio.

	Particolarmente utile per cambiare rapidamente bersagli
	in combattimento con alta precisione.

	La priorità del bersaglio è basata sulla mira, cioè il
	bersaglio più vicino al centro del cono verrà
	selezionato per primo. Questo può portare a dare priorità
	a un bersaglio distante rispetto a uno più vicino, se il bersaglio distante
	è più vicino al centro del cono.

	Raccomandata come scorciatoia principale di selezione del bersaglio per la maggior parte dei giocatori.
]]; -- en:2de05bb9
L.DESC_TOGGLEAUTORUN = [[
	La corsa automatica fa sì che il tuo personaggio continui a muoversi
	nella direzione in cui sta guardando senza alcun input da parte tua.

	La corsa automatica è utile per alleviare l'affaticamento del pollice durante
	lunghe fasi di movimento, o per liberare il pollice mentre ti muovi.
]]; -- en:9e97af4b
L.DESC_TOGGLEGAMEMENU = [[
	La scorciatoia menù gestisce tutte le funzionalità che si attivano premendo
	il tasto Esc su una tastiera. Gestisce azioni diverse in base allo
	stato attuale del gioco.

	Se ci sono azioni in corso relative a incantesimi o selezione del bersaglio,
	verranno annullate. Premere la scorciatoia con un bersaglio attivo
	lo cancellerà. Premere la scorciatoia durante il lancio di un incantesimo
	interromperà il lancio.

	La scorciatoia gestisce anche vari altri casi in base a ciò
	che è attualmente visualizzato sullo schermo. Ad esempio, se un pannello
	è aperto, come il libro degli incantesimi, la scorciatoia eseguirà
	l'azione necessaria per chiuderlo o nasconderlo.

	Se nessuno dei casi sopra si applica, il menù di gioco si aprirà o
	si chiuderà quando premuto.
]]; -- en:adfccfe4
L.DEVICE_DESC_PLAYSTATION4 = [[
	Il controller PlayStation 4, noto anche come DualShock 4, è il gamepad della precedente generazione di Sony.

	È un gamepad ricco di funzionalità con touchpad, controlli di movimento e supporto per tutti i suoi pulsanti nel gioco.

	Per sfruttare tutte le funzionalità, potresti dover installare PlayStation Accessories (Windows).
]]; -- en:7bea4ad9
L.DEVICE_DESC_PLAYSTATION5 = [[
	Il controller PlayStation 5, noto anche come DualSense, è attualmente il miglior gamepad per World of Warcraft.

	È il gamepad più completo disponibile, con controlli di movimento, touchpad e, nel caso della variante Edge, palette posteriori native.
	Tutti i pulsanti del gamepad possono essere usati nel gioco.

	Per sfruttare tutte le funzionalità, potresti dover installare PlayStation Accessories (Windows).
]]; -- en:c5f15091
L.DEVICE_DESC_STEAMDECK = [[
	Le Steam Deck di solito eseguono World of Warcraft tramite Proton attraverso il client Steam.

	Quando giochi tramite Steam, il dispositivo dovrebbe usare un profilo di gioco che copra almeno un layout Xbox standard.

	Gamepad con touchpad mouse fornisce una buona base.

	Le Steam Deck non possono usare nativamente le loro palette in World of Warcraft.
	Le palette possono essere mappate tramite emulazione, o con tasti della tastiera nelle impostazioni di Steam Input.

	Il preset Steam Deck nel gioco può anche andare bene per altri computer portatili, grazie al layout di controllo simile.
]]; -- en:2a5e4173
L.DEVICE_DESC_SWITCHPRO = [[
	Il controller Nintendo Switch Pro ha un layout simile al controller Xbox, ma con etichette dei pulsanti invertite.

	Il controller Pro ha quattro pulsanti centrali, dandogli un leggero vantaggio rispetto a un controller Xbox standard.

	Il controller Nintendo Switch 2 Pro non può usare nativamente le sue palette o il pulsante C nel gioco.
	Con software esterno, come Steam o reWASD, possono essere mappati a tasti della tastiera, consentendone l'uso nel gioco.
]]; -- en:79260874
L.DEVICE_DESC_XBOX = [[
	Le varianti Xbox sono i gamepad più comuni e sono ben supportate da World of Warcraft.

	Il controller Xbox Elite non può usare nativamente le sue palette nel gioco, ma possono essere usate per simulare altri pulsanti del gamepad,
	tramite l'app Xbox Accessories (Windows).

	Con software esterno, come Steam o reWASD, le palette possono essere mappate a tasti della tastiera, consentendone l'uso nel gioco.

	Il pulsante centrale è riservato alla Xbox Guide e non può essere usato nel gioco.

	Consigliato anche per Steam Input, coerentemente con il controller Xbox 360 che emula.
]]; -- en:654501d3
L.DISC_KEY_BUTTON1 = [[
	Mentre uno dei tuoi pulsanti emula il click sinistro, questa scorciatoia non può essere modificata.
]]; -- en:e811ebc6
L.DISC_KEY_BUTTON2 = [[
	Mentre uno dei tuoi pulsanti emula il click destro, questa scorciatoia non può essere modificata.
]]; -- en:b85c78b2
L.EXPORT_DATA_TEXT = [[

|cFFFFFF00Esporta|r

Seleziona quali dati vuoi esportare. Una stringa verrà generata di seguito, che potrai incollare in un altro client o condividere con altri.

Usa %s per copiare la stringa.
]]; -- en:1741e6a6
L.GFX_GENERAL_INFO = [[
	Seleziona la grafica del gamepad più simile all'aspetto del tuo gamepad.

	Scegliere la grafica non cambia il modo in cui funziona il gamepad, cambia solo l'aspetto dell'interfaccia.

	La grafica viene usata per mostrarti quali pulsanti sono attualmente associati a quali azioni e per fornire un riferimento visivo del layout del gamepad.

	Alcune raccomandazioni opzionali di impostazioni vengono fornite in base alla tua scelta.
]]; -- en:54457360
L.IMPORT_DATA_TEXT = [[

|cFFFFFF00Importa|r

Incolla una stringa esportata di seguito, poi carica e seleziona i dati che vuoi importare. I dati importati sovrascriveranno i tuoi dati attuali quando applicabile.

Usa %s per copiare la stringa dalla fonte e %s per incollarla di seguito.
]]; -- en:145f78fb
L.IMPORT_FAILED_TEXT = [[

|cFFFFFF00Importa|r

Importazione fallita:
]]; -- en:a7555666
L.LINK_COPY = [[
	Collegamento a %s.

	Ctrl+A per selezionare e Ctrl+C per copiare.

	Incolla (Ctrl+V) il collegamento nel tuo browser web.
]]; -- en:3f396345
L.LINK_DISCORD_TEXT = [[
	La comunità dove puoi trovare supporto, discutere di gameplay, condividere idee e trovare giocatori affini.

	Clicca qui per unirti al server.
]]; -- en:e2f9740c
L.LINK_PATREON_TEXT = [[
	Lo sviluppo e la manutenzione di questo addon richiedono molto tempo e impegno,
	ma ConsolePort sarà sempre completamente gratuito.

	Diventa un sostenitore su Patreon per sbloccare il tuo badge Discord e, in cambio, sostenere il futuro del progetto.

	Clicca qui per diventare un patrono.
]]; -- en:3cc9532e
L.LINK_PAYPAL_TEXT = [[
	Le donazioni vengono reinvestite direttamente nello sviluppo e nella manutenzione dell'addon.

	Ogni contributo, grande o piccolo, è molto apprezzato.

	Clicca qui per donare tramite PayPal.
]]; -- en:28c6265a
L.REMOVE_RING_TEXT = [[|cFFFFFF00Rimuovi %s|r
Sei sicuro di voler rimuovere il menù radiale?]]; -- en:1a461a1a
L.RING_MENU_DESC = [[Crea i tuoi menù radiali dove puoi aggiungere i tuoi oggetti, incantesimi, macro e cavalcature per cui non vuoi sacrificare spazio sulla barra delle azioni.

Per usarlo, tieni premuta la scorciatoia selezionata, inclina lo stick nella direzione dell'oggetto che vuoi selezionare e rilascia la scorciatoia.

Il menù radiale predefinito, il |CFF00FF00Menù radiale degli strumenti|r, ha proprietà speciali per facilitare le missioni e l'interazione con il mondo, e non è statico. Aggiungerà e rimuoverà automaticamente oggetti secondo necessità.

Se vuoi creare un menù radiale da usare nella tua rotazione e non solo per gli strumenti, è altamente consigliato usare un menù radiale personalizzato per questo scopo.]]; -- en:39d4577b
L.SELECTED_RING_TEXT = [[Questo è il tuo menù radiale attualmente selezionato.
Quando premi e tieni la scorciatoia, tutte le tue abilità selezionate appariranno in un menù radiale sullo schermo.

Inclina il tuo stick radiale nella direzione dell'abilità o oggetto che vuoi usare, poi rilascia la scorciatoia per confermare.]]; -- en:2cdfa5d3
L.SET_RING_BINDING_TEXT = [[
|cFFFFFF00Imposta scorciatoia|r

Premi una combinazione di pulsanti per selezionare una nuova scorciatoia per questo menù radiale.

]]; -- en:1c0e03f4
L.SLOT_NO_BINDING = [[
|cFFFFFF00Imposta scorciatoia|r

%s in %s non ha una scorciatoia assegnata.

Premi una combinazione di pulsanti per selezionare una nuova scorciatoia per questo slot.

]]; -- en:74326275
L.SLOT_SET_BINDING = [[
|cFFFFFF00Imposta scorciatoia|r

Premi una combinazione di pulsanti per selezionare una nuova scorciatoia per %s.

]]; -- en:d1933130
---------------------------------------------------------------
-- Literals
---------------------------------------------------------------
L['%s will be disabled the next time the interface is reloaded.'] = '%s verrà disattivato al prossimo ricaricamento dell\'interfaccia.';
L['2D deadzone for camera that takes into account pitch and yaw movement together.'] = "Zona morta 2D per la telecamera che tiene conto sia del beccheggio che dell'imbardata insieme.";
L['2D deadzone for movement that takes into account X and Y movement together.'] = 'Zona morta 2D per il movimento che tiene conto del movimento X e Y insieme.';
L['A button cluster for all modifiers of a single button.'] = 'Un cluster di pulsanti per tutti i modificatori di un singolo pulsante.';
L['A cluster bar with a toolbar below it, laid out horizontally.'] = 'Una barra cluster con una barra degli strumenti sotto, disposta orizzontalmente.';
L['A cluster bar with a toolbar below it.'] = 'Una barra cluster con una barra degli strumenti sotto.';
L['A divider to separate elements.'] = 'Un divisore per separare elementi.';
L['A friendly soft target can be acquired while having an enemy hard target.'] = 'Un bersaglio flessibile amico può essere acquisito mentre si ha un bersaglio fisso nemico.';
L['A regular action bar.'] = 'Una normale barra delle azioni.';
L['A ring of buttons for pet commands.'] = 'Un menù radiale di pulsanti per i comandi del compagno.';
L['A toolbar with XP indicators, shortcuts, class specific bars, and miscellaneous information.'] = 'Una barra degli strumenti con indicatori XP, scorciatoie, barre specifiche per classe e informazioni varie.';
L['About'] = 'Informazioni';
L['Acceleration of cursor per second as it continues to move.'] = 'Accelerazione del cursore al secondo mentre continua a muoversi.';
L['Accent Color'] = 'Colore di accento';
L['Accept Button'] = 'Pulsante Accetta';
L['Action Bar'] = 'Barra delle azioni';
L['Action Bar Configuration'] = 'Configurazione barra delle azioni';
L['Action bar is scaled separately.'] = 'La barra delle azioni viene ridimensionata separatamente.';
L['Action Bar Loadout'] = 'Loadout barra delle azioni';
L['Action Bar Loadout (Deprecated)'] = 'Loadout barra delle azioni (obsoleto)';
L['Action Bar Presets'] = 'Preset barra delle azioni';
L['Action Bar Setup'] = 'Configurazione barra delle azioni';
L['Action Button'] = 'Pulsante azione';
L['Action Button Group'] = 'Gruppo pulsanti azione';
L['Action Page'] = 'Pagina azione';
L['Action Page Condition'] = 'Condizione pagina azione';
L['Action Page Response'] = 'Risposta pagina azione';
L['Activate targeting components only while their bindings are in use.'] = 'Attiva i componenti di selezione solo mentre le loro scorciatoie sono in uso.';
L['Active Color'] = 'Colore attivo';
L['Active Device'] = 'Dispositivo attivo';
L['Add a new element to your loadout.'] = 'Aggiungi un nuovo elemento al tuo loadout.';
L['Add to %s'] = 'Aggiungi a %s';
L['Add, remove or reset a frame from cursor stack.'] = 'Aggiungi, rimuovi o ripristina un riquadro dalla pila del cursore.';
L['Affects both mouse and gamepad.'] = 'Influenza sia mouse che gamepad.';
L['Alignment'] = 'Allineamento';
L['Alignment of the counter text on buttons.'] = 'Allineamento del testo del contatore sui pulsanti.';
L['Alignment of the hotkey text on buttons.'] = 'Allineamento del testo della scorciatoia sui pulsanti.';
L['Alignment of the macro text on buttons.'] = 'Allineamento del testo della macro sui pulsanti.';
L['All combines all connected devices into one.'] = '«Tutti» combina tutti i dispositivi connessi in uno.';
L['Allow binding discrete radial stick inputs.'] = "Consenti l'assegnazione di input radiali discreti dello stick.";
L['Allow binding multiple combos to the same binding.'] = "Consenti l'assegnazione di più combo alla stessa scorciatoia.";
L['Allow Binding Overlap'] = 'Consenti sovrapposizione scorciatoie';
L['Allow casting on mouseover targets, when enabled in the game options.'] = 'Consente di lanciare incantesimi sul bersaglio sotto il cursore, se attivato nelle opzioni di gioco.';
L['Allow cursor to interact with and show preference for group loot frames.'] = 'Consenti al cursore di interagire e dare priorità ai riquadri del bottino di gruppo.';
L['Allow cursor to interact with and show preference for popups and static dialogs.'] = 'Consenti al cursore di interagire e dare priorità a popup e finestre di dialogo statiche.';
L['Allow cursor to interact with the entire interface, not only panels.'] = "Consenti al cursore di interagire con l'intera interfaccia, non solo con i pannelli.";
L['Allow Radial Bindings'] = 'Consenti scorciatoie radiali';
L['Allows the use of the touchpad to control cursor movement.'] = "Consente l'uso del touchpad per controllare il movimento del cursore.";
L['Alphabet to use for dictionary suggestions and word processing.'] = 'Alfabeto da usare per suggerimenti del dizionario ed elaborazione delle parole.';
L['Always keep cursor centered and visible when controlling camera.'] = 'Mantieni sempre il cursore centrato e visibile quando controlli la telecamera.';
L['Always Show All Buttons'] = 'Mostra sempre tutti i pulsanti';
L['Always Show Mouse Cursor'] = 'Mostra sempre il cursore del mouse';
L['Always show nameplate for soft enemy target.'] = 'Mostra sempre la targhetta per il bersaglio flessibile nemico.';
L['Always show nameplate for soft friendly target.'] = 'Mostra sempre la targhetta per il bersaglio flessibile amico.';
L['Always show tooltip for an automatically acquired target, as long as it exists.'] = 'Mostra sempre il tooltip per un bersaglio acquisito automaticamente, finché esiste.';
L['An action button in a group.'] = 'Un pulsante azione in un gruppo.';
L['Analog Movement'] = 'Movimento analogico';
L['Anchor'] = 'Ancoraggio';
L['Anchor point of parent to pair with.'] = 'Punto di ancoraggio del genitore con cui accoppiarsi.';
L['Anchor point of the counter text on buttons.'] = 'Punto di ancoraggio del testo del contatore sui pulsanti.';
L['Anchor point of the hotkey icon on group buttons.'] = "Punto di ancoraggio dell'icona della scorciatoia sui pulsanti del gruppo.";
L['Anchor point of the hotkey text on buttons.'] = 'Punto di ancoraggio del testo della scorciatoia sui pulsanti.';
L['Anchor point of the macro text on buttons.'] = 'Punto di ancoraggio del testo della macro sui pulsanti.';
L['Anchor point to attach.'] = 'Punto di ancoraggio a cui agganciare.';
L['Apply default settings to the current category or all settings.'] = 'Applica le impostazioni predefinite alla categoria corrente o a tutte le impostazioni.';
L['Arc Allowance'] = 'Tolleranza arco';
L['Are you sure you want to delete %s from %s?'] = 'Sei sicuro di voler eliminare %s da %s?';
L['Are you sure you want to overwrite %s with %s?'] = 'Sei sicuro di voler sovrascrivere %s con %s?';
L['Are you sure you want to regenerate the keyboard dictionary? You will lose all custom phrases.'] = 'Sei sicuro di voler rigenerare il dizionario della tastiera? Perderai tutte le frasi personalizzate.';
L['Are you sure you want to reset all device profiles?'] = 'Sei sicuro di voler ripristinare tutti i profili dei dispositivi?';
L['Are you sure you want to reset the keyboard layout?'] = 'Sei sicuro di voler ripristinare il layout della tastiera?';
L['Are you sure you want to reset your device profile?'] = 'Sei sicuro di voler ripristinare il tuo profilo del dispositivo?';
L['Are you sure you want to wipe the keyboard dictionary? It currently contains %d words.'] = 'Sei sicuro di voler cancellare il dizionario della tastiera? Attualmente contiene %d parole.';
L['Area where the interact key can find a suitable target.'] = 'Area in cui il tasto di interazione può trovare un bersaglio adatto.';
L['Artwork flavor.'] = "Variante dell'artwork.";
L['Artwork for the interface.'] = "Artwork per l'interfaccia.";
L['Artwork style.'] = "Stile dell'artwork.";
L['Assign or clear bindings for this set.'] = 'Assegna o cancella scorciatoie per questo set.';
L['Assist Mode'] = 'Modalità assistenza';
L['Auto-adjusts your camera, allowing you to control movement with a single stick.'] = 'Regola automaticamente la tua telecamera, permettendoti di controllare il movimento con un solo stick.';
L['Auto-Sell Gear Level Limit'] = 'Limite livello equipaggiamento per vendita automatica';
L['Auto-Sell Junk'] = 'Vendi automaticamente la spazzatura';
L['Auto-set target to match soft target.'] = 'Imposta automaticamente il bersaglio per corrispondere al bersaglio flessibile.';
L['Automatic Binding Backups'] = 'Backup automatici delle scorciatoie';
L['Automatic Cursor Timeout'] = 'Timeout automatico del cursore';
L['Automatic Tooltip Duration'] = 'Durata automatica del tooltip';
L['Automatically add tracked quest items and extra spells to main utility ring.'] = 'Aggiungi automaticamente oggetti di missione tracciati e incantesimi extra al menù radiale degli strumenti principale.';
L['Automatically backup your bindings when you change them, for import and export.'] = 'Esegui il backup automatico delle scorciatoie quando le modifichi, per importare ed esportare.';
L['Automatically Bind Extra Items'] = 'Associa automaticamente oggetti extra';
L['Automatically Control Cursor Pickups'] = 'Controlla automaticamente le prese del cursore';
L['Automatically control cursor when picking up items.'] = 'Controlla automaticamente il cursore quando raccogli oggetti.';
L['Automatically disabled if an inactive component is clicked from a macro.'] = 'Disabilitato automaticamente se un componente inattivo viene cliccato da una macro.';
L['Automatically sell junk when interacting with a merchant.'] = 'Vendi automaticamente la spazzatura quando interagisci con un mercante.';
L['Axis Interpretation'] = 'Interpretazione asse';
L['Battery Level'] = 'Livello batteria';
L['Binding Catch Timeframe'] = 'Finestra di cattura scorciatoia';
L['Blend Mode'] = 'Modalità di fusione';
L['Blend mode of the artwork.'] = "Modalità di fusione dell'artwork.";
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
L['Border Vertex Color'] = 'Colore vertice del bordo';
L['Breadth'] = 'Larghezza';
L['Breadth of the divider.'] = 'Larghezza del divisore.';
L['Button %d'] = 'Pulsante %d';
L['Button Set'] = 'Set di pulsanti';
L['Button that emulates '] = 'Pulsante che emula ';
L['Button that emulates the '] = 'Pulsante che emula il ';
L['Button to cancel or exit the quick menu.'] = 'Pulsante per annullare o uscire dal menù rapido.';
L['Button to handle cancel actions, such as exiting menus.'] = 'Pulsante per gestire azioni di annullamento, come uscire dai menù.';
L['Button to handle contextual actions, such as adding items to the utility ring or passing on loot.'] = 'Pulsante per gestire azioni contestuali, come aggiungere oggetti al menù radiale degli strumenti o passare sul bottino.';
L['Button to handle contextual actions, such as adding items to the utility ring.'] = 'Pulsante per gestire azioni contestuali, come aggiungere oggetti al menù radiale degli strumenti.';
L['Button to insert suggested word.'] = 'Pulsante per inserire la parola suggerita.';
L['Button to move the cursor down.'] = 'Pulsante per muovere il cursore in basso.';
L['Button to move the cursor left.'] = 'Pulsante per muovere il cursore a sinistra.';
L['Button to move the cursor right.'] = 'Pulsante per muovere il cursore a destra.';
L['Button to move the cursor up.'] = 'Pulsante per muovere il cursore in alto.';
L['Button to replicate left click. This is the primary interface action.'] = "Pulsante per replicare il click sinistro. Questa è l'azione principale dell'interfaccia.";
L['Button to replicate right click. This is the secondary interface action.'] = "Pulsante per replicare il click destro. Questa è l'azione secondaria dell'interfaccia.";
L['Button to select next suggested word.'] = 'Pulsante per selezionare la parola suggerita successiva.';
L['Button to select previous suggested word.'] = 'Pulsante per selezionare la parola suggerita precedente.';
L['Button to use for combo hotkey 1.'] = 'Pulsante da usare per la combo scorciatoia 1.';
L['Button to use for combo hotkey 2.'] = 'Pulsante da usare per la combo scorciatoia 2.';
L['Button to use for combo hotkey 3.'] = 'Pulsante da usare per la combo scorciatoia 3.';
L['Button to use for combo hotkey 4.'] = 'Pulsante da usare per la combo scorciatoia 4.';
L['Button to use for combo hotkey 5.'] = 'Pulsante da usare per la combo scorciatoia 5.';
L['Button to use for combo hotkey 6.'] = 'Pulsante da usare per la combo scorciatoia 6.';
L['Button to use for combo hotkey 7.'] = 'Pulsante da usare per la combo scorciatoia 7.';
L['Button to use for combo hotkey 8.'] = 'Pulsante da usare per la combo scorciatoia 8.';
L['Button to use to erase characters.'] = 'Pulsante da usare per cancellare caratteri.';
L['Button to use to move the cursor leftwards.'] = 'Pulsante da usare per muovere il cursore verso sinistra.';
L['Button to use to move the cursor rightwards.'] = 'Pulsante da usare per muovere il cursore verso destra.';
L['Button to use to trigger the enter command.'] = 'Pulsante da usare per attivare il comando Invio.';
L['Button to use to trigger the escape command.'] = 'Pulsante da usare per attivare il comando Esc.';
L['Button to use to trigger the space command.'] = 'Pulsante da usare per attivare il comando Spazio.';
L['Button used to confirm a selected item from a ring.'] = 'Pulsante usato per confermare un oggetto selezionato da un menù radiale.';
L['Button used to remove a selected item from an editable ring.'] = 'Pulsante usato per rimuovere un oggetto selezionato da un menù radiale modificabile.';
L['Button |cFF00FFFF%s|r'] = 'Pulsante |cFF00FFFF%s|r';
L['Buttons'] = 'Pulsanti';
L['Buttons emulating modifiers will instead trigger bindings when pressed and released within the time span.'] = 'I pulsanti che emulano modificatori attiveranno invece scorciatoie quando premuti e rilasciati entro il tempo previsto.';
L['Buttons in the cluster bar.'] = 'Pulsanti nella barra cluster.';
L['Buttons in the group.'] = 'Pulsanti nel gruppo.';
L['By default, shows modifiers on mouseover and on cooldown.'] = 'Per impostazione predefinita, mostra i modificatori al passaggio del mouse e durante il tempo di recupero.';
L['Camera 2D Deadzone'] = 'Zona morta 2D telecamera';
L['Camera Look'] = 'Sguardo telecamera';
L['Camera Look is a temporary turn of the camera based on the current analog input.'] = "Lo sguardo telecamera è una rotazione temporanea della telecamera basata sull'input analogico corrente.";
L['Camera Pitch Axis'] = 'Asse beccheggio telecamera';
L['Camera Pitch Speed'] = 'Velocità beccheggio telecamera';
L['Camera Pitch-Only Deadzone'] = 'Zona morta solo-beccheggio telecamera';
L['Camera speed for pitch - moving up/down.'] = 'Velocità telecamera per il beccheggio — muovere su/giù.';
L['Camera speed for yaw - turning left/right.'] = "Velocità telecamera per l'imbardata — ruotare sinistra/destra.";
L['Camera Yaw Axis'] = 'Asse imbardata telecamera';
L['Camera Yaw Speed'] = 'Velocità imbardata telecamera';
L['Camera Yaw-Only Deadzone'] = 'Zona morta solo-imbardata telecamera';
L['Cancel and clear cursor'] = 'Annulla e cancella cursore';
L['Cancel Button'] = 'Pulsante Annulla';
L['Cannot open configuration menu in combat.'] = 'Impossibile aprire il menù di configurazione in combattimento.';
L['Casting Bar'] = 'Barra di lancio';
L['Casting this spell without an assistable target opens the ring to pick the target.'] = 'Lanciare questo incantesimo senza un bersaglio assistibile apre il menù radiale per scegliere il bersaglio.';
L['Center Gap'] = 'Spazio centrale';
L['Center gap, as fraction of overall crosshair size.'] = 'Spazio centrale, come frazione della dimensione totale del mirino.';
L['Change before touchpad moves the cursor.'] = 'Soglia prima che il touchpad muova il cursore.';
L['Change bluetooth state for active device.'] = 'Cambia lo stato Bluetooth per il dispositivo attivo.';
L['Change or print a value from the active device configuration.'] = 'Cambia o stampa un valore dalla configurazione del dispositivo attivo.';
L['Character Specific'] = 'Specifico per il personaggio';
L['Choose a negative value to invert the axis.'] = "Scegli un valore negativo per invertire l'asse.";
L['Class Bar'] = 'Barra di classe';
L['Class Colored Health'] = 'Salute colorata per classe';
L['Clear all items from this set.'] = 'Svuota tutti gli oggetti da questo set.';
L['Clear Binding'] = 'Cancella scorciatoia';
L['Clear configured gamepad bindings and reload interface.'] = "Cancella le scorciatoie del gamepad configurate e ricarica l'interfaccia.";
L['Clear Focus Deadzone'] = 'Zona morta per cancellare il focus';
L['Clear Focus Mode'] = 'Modalità di cancellazione focus';
L['Clear Focus Time'] = 'Tempo di cancellazione focus';
L['Clear Slot'] = 'Svuota slot';
L['Clear slot or binding'] = 'Svuota slot o scorciatoia';
L['Click here to reset your device profile.'] = 'Clicca qui per ripristinare il tuo profilo del dispositivo.';
L['Click on Down'] = 'Click alla pressione';
L['Click Override Button'] = 'Pulsante sostituzione click';
L['Click Override Condition'] = 'Condizione sostituzione click';
L['Cluster Action Bar'] = 'Barra delle azioni cluster';
L['Cluster Handle'] = 'Maniglia cluster';
L['Cluster Modifier Toggle'] = 'Alterna modificatore cluster';
L['Clusters'] = 'Cluster';
L['Color accent of radial menu items.'] = 'Accento colore degli elementi del menù radiale.';
L['Color of a partially selected slice.'] = 'Colore di una fetta parzialmente selezionata.';
L['Color of the active slice.'] = 'Colore della fetta attiva.';
L['Color of the cooldown swipe effect on buttons.'] = "Colore dell'effetto di scorrimento del tempo di recupero sui pulsanti.";
L['Color of the counter text on buttons.'] = 'Colore del testo del contatore sui pulsanti.';
L['Color of the crosshair.'] = 'Colore del mirino.';
L['Color of the divider.'] = 'Colore del divisore.';
L['Color of the hotkey text on buttons.'] = 'Colore del testo della scorciatoia sui pulsanti.';
L['Color of the macro text on buttons.'] = 'Colore del testo della macro sui pulsanti.';
L['Color of the main XP bar.'] = 'Colore della barra XP principale.';
L['Color of the mana indicator on buttons.'] = "Colore dell'indicatore di mana sui pulsanti.";
L['Color of the range indicator on buttons.'] = "Colore dell'indicatore di portata sui pulsanti.";
L['Color of the sticky selection slice.'] = 'Colore della fetta di selezione fissa.';
L['Color of the vertices on the border of buttons.'] = 'Colore dei vertici sul bordo dei pulsanti.';
L['Color the health bars in the target ring by class.'] = 'Colora le barre della salute nel menù radiale bersaglio in base alla classe.';
L['Color tint for combo hotkey 1.'] = 'Tinta colore per la combo scorciatoia 1.';
L['Color tint for combo hotkey 2.'] = 'Tinta colore per la combo scorciatoia 2.';
L['Color tint for combo hotkey 3.'] = 'Tinta colore per la combo scorciatoia 3.';
L['Color tint for combo hotkey 4.'] = 'Tinta colore per la combo scorciatoia 4.';
L['Color tint for combo hotkey 5.'] = 'Tinta colore per la combo scorciatoia 5.';
L['Color tint for combo hotkey 6.'] = 'Tinta colore per la combo scorciatoia 6.';
L['Color tint for combo hotkey 7.'] = 'Tinta colore per la combo scorciatoia 7.';
L['Color tint for combo hotkey 8.'] = 'Tinta colore per la combo scorciatoia 8.';
L['Combine with '] = 'Combina con ';
L['Combine with use on demand for full cursor control.'] = 'Combina con «usa su richiesta» per il pieno controllo del cursore.';
L['Combined Input Overlap Time'] = 'Tempo di sovrapposizione input combinato';
L['Combo Button 1'] = 'Pulsante combo 1';
L['Combo Button 2'] = 'Pulsante combo 2';
L['Combo Button 3'] = 'Pulsante combo 3';
L['Combo Button 4'] = 'Pulsante combo 4';
L['Combo Button 5'] = 'Pulsante combo 5';
L['Combo Button 6'] = 'Pulsante combo 6';
L['Combo Button 7'] = 'Pulsante combo 7';
L['Combo Button 8'] = 'Pulsante combo 8';
L['Combo Color 1'] = 'Colore combo 1';
L['Combo Color 2'] = 'Colore combo 2';
L['Combo Color 3'] = 'Colore combo 3';
L['Combo Color 4'] = 'Colore combo 4';
L['Combo Color 5'] = 'Colore combo 5';
L['Combo Color 6'] = 'Colore combo 6';
L['Combo Color 7'] = 'Colore combo 7';
L['Combo Color 8'] = 'Colore combo 8';
L['Command Modifier'] = 'Modificatore di comando';
L['Configure the casting bar.'] = 'Configura la barra di lancio.';
L['Configure the class related bar.'] = 'Configura la barra correlata alla classe.';
L['Connect your controller.'] = 'Connetti il tuo controller.';
L['Connected device(s):'] = 'Dispositivo/i connesso/i:';
L['ConsolePort'] = 'ConsolePort';
L['Context Button'] = 'Pulsante contesto';
L['Controls the cutoff range where an interactable target or object can be found.'] = "Controlla l'intervallo di taglio in cui può essere trovato un bersaglio od oggetto interagibile.";
L['Controls when your character starts running. Expressed as a fraction of your total movement stick radius.'] = 'Controlla quando il tuo personaggio inizia a correre. Espresso come frazione del raggio totale dello stick di movimento.';
L['Copy %s from %s:'] = 'Copia %s da %s:';
L['Copy this element to a new name.'] = 'Copia questo elemento con un nuovo nome.';
L['Correlation between stick position and pie selection.'] = 'Correlazione tra posizione dello stick e selezione nella ruota.';
L['Create Binding Preset'] = 'Crea preset scorciatoie';
L['Critical, Low, Medium, High, Wired/Charging, or Unknown/Disconnected.'] = 'Critico, Basso, Medio, Alto, Cablato/In carica, o Sconosciuto/Disconnesso.';
L['Crossbar: Minimal'] = 'Crossbar: Minimale';
L['Crossbar: Triggers'] = 'Crossbar: Grilletti';
L['Crossbar: Triple'] = 'Crossbar: Triplo';
L['Crosshair'] = 'Mirino';
L['Cursor Acceleration'] = 'Accelerazione cursore';
L['Cursor acceleration for touchpad control.'] = 'Accelerazione cursore per controllo touchpad.';
L['Cursor appears on demand, instead of in response to a panel showing up.'] = 'Il cursore appare su richiesta, invece che in risposta alla comparsa di un pannello.';
L['Cursor Center Position'] = 'Posizione centrale cursore';
L['Cursor hides when you start moving, if free of obstacles.'] = 'Il cursore si nasconde quando inizi a muoverti, se non ci sono ostacoli.';
L['Cursor Max Speed'] = 'Velocità massima cursore';
L['Cursor Move Threshold'] = 'Soglia movimento cursore';
L['Cursor Reticle Targeting'] = 'Targeting cursore tramite mirino';
L['Cursor Speed'] = 'Velocità cursore';
L['Cursor speed for touchpad control.'] = 'Velocità cursore per controllo touchpad.';
L['Cursor Start Speed'] = 'Velocità iniziale cursore';
L['Custom color to use for the touchpad LED.'] = 'Colore personalizzato da usare per il LED del touchpad.';
L['Cyan'] = 'Ciano';
L['Deadzone for simple point-to-select rings.'] = 'Zona morta per menù radiali punta-e-seleziona semplici.';
L['Deadzone to clear focus after intercepting stick input.'] = "Zona morta per cancellare il focus dopo aver intercettato l'input dello stick.";
L['Decrease'] = 'Diminuisci';
L['Decrease lightness'] = 'Diminuisci luminosità';
L['Decrease opacity'] = 'Diminuisci opacità';
L['Default to '] = 'Predefinito su ';
L['Delay before reactivating interface cursor after leaving combat, in seconds.'] = 'Ritardo prima di riattivare il cursore di interfaccia dopo aver lasciato il combattimento, in secondi.';
L['Delay before starting to adjust angle when camera control is idle, in seconds.'] = "Ritardo prima di iniziare a regolare l'angolo quando il controllo della telecamera è inattivo, in secondi.";
L['Delay is doubled if you are dead.'] = 'Il ritardo viene raddoppiato se sei morto.';
L['Delay until a movement is repeated, when holding down a direction, in seconds.'] = 'Ritardo finché un movimento viene ripetuto, quando si tiene una direzione, in secondi.';
L['Delay until the first movement is repeated, when holding down a direction, in seconds.'] = 'Ritardo finché il primo movimento viene ripetuto, quando si tiene una direzione, in secondi.';
L['Delete this element.'] = 'Elimina questo elemento.';
L['Depth'] = 'Profondità';
L['Depth of the divider.'] = 'Profondità del divisore.';
L['Detected %d out of 8 possible sensors.'] = 'Rilevati %d sensori su 8 possibili.';
L['Detected %d valid button(s).'] = 'Rilevati %d pulsanti validi.';
L['Device Information'] = 'Informazioni dispositivo';
L['Device Mappings'] = 'Mappature dispositivo';
L['Device Profiles'] = 'Profili dispositivo';
L['Device Selection'] = 'Selezione dispositivo';
L['Device Settings'] = 'Impostazioni dispositivo';
L['Diamond Grid'] = 'Griglia a diamante';
L['Dictionary Match Alphabet'] = 'Alfabeto di corrispondenza dizionario';
L['Dictionary Match Pattern'] = 'Pattern di corrispondenza dizionario';
L['Direction for flyout buttons, such as portals, poisons, and pet utilities.'] = 'Direzione per pulsanti flyout, come portali, veleni e strumenti del compagno.';
L['Direction of the button cluster.'] = 'Direzione del cluster di pulsanti.';
L['Disable Drag and Drop'] = 'Disabilita trascina e rilascia';
L['Disable dragging and dropping abilities on action bars.'] = 'Disabilita trascina e rilascia delle abilità sulle barre delle azioni.';
L['Disable free-roaming mouse cursor when you jump.'] = 'Disabilita il cursore del mouse libero quando salti.';
L['Disable free-roaming mouse cursor when you use your sticks.'] = 'Disabilita il cursore del mouse libero quando usi gli stick.';
L['Disable Hotkey Rendering'] = 'Disabilita rendering scorciatoie';
L['Disable if your mouse cursor is invisible.'] = 'Disabilita se il cursore del mouse è invisibile.';
L['Disable repeated cursor movements - each click will only move the cursor once.'] = 'Disabilita movimenti ripetuti del cursore: ogni click muoverà il cursore solo una volta.';
L['Disable Repeated Movement'] = 'Disabilita movimento ripetuto';
L['Disable to use discrete legacy movement controls.'] = 'Disabilita per usare i controlli di movimento legacy discreti.';
L['Disable Wrapping'] = 'Disabilita avvolgimento';
L['Disables customization to hotkeys on regular action bars.'] = 'Disabilita la personalizzazione delle scorciatoie sulle barre delle azioni normali.';
L['Disabling this may cause worse performance with many panels open.'] = 'Disabilitare questo potrebbe causare prestazioni peggiori con molti pannelli aperti.';
L['Disconnected'] = 'Disconnesso';
L['Discord'] = 'Discord';
L['Display icon next to the power level for the current active gamepad.'] = "Mostra l'icona accanto al livello di batteria per il gamepad attivo corrente.";
L['Display power level for the current active gamepad.'] = 'Mostra il livello di batteria per il gamepad attivo corrente.';
L['Display power level status text for the current active gamepad.'] = 'Mostra il testo dello stato del livello di batteria per il gamepad attivo corrente.';
L['Display the action bar grid when picking up a spell on the cursor.'] = 'Mostra la griglia della barra delle azioni quando raccogli un incantesimo sul cursore.';
L['Displays a briefing for newly acquired abilities.'] = 'Mostra un riepilogo per le abilità appena acquisite.';
L['Divider'] = 'Divisore';
L['Do you want to load settings for %s?'] = 'Vuoi caricare le impostazioni per %s?';
L['Does not affect actual ability to interact with the target, which may have a different range.'] = 'Non influisce sulla capacità effettiva di interagire con il bersaglio, che può avere una portata diversa.';
L['Donate via PayPal'] = 'Dona tramite PayPal';
L['Double Tap Modifier'] = 'Modificatore doppio tap';
L['Double Tap Timeframe'] = 'Finestra temporale doppio tap';
L['Duration after using gamepad and mouse at the same time before switching to just one or the other, in milliseconds.'] = "Durata dopo aver usato gamepad e mouse contemporaneamente prima di passare a solo uno o l'altro, in millisecondi.";
L['Duration under which a tooltip is displayed for an acquired target or interactable, in milliseconds.'] = 'Durata per cui viene mostrato un tooltip per un bersaglio acquisito o oggetto interagibile, in millisecondi.';
L['Dynamic Pitch'] = 'Beccheggio dinamico';
L['Dynamic will use the button set that does not conflict with your '] = '«Dinamico» userà il set di pulsanti che non entra in conflitto con la tua ';
L['E.g. '] = 'Es. ';
L['Edit Binding'] = 'Modifica scorciatoia';
L['Edit Slot'] = 'Modifica slot';
L['Emulate P1 '] = 'Emula P1 ';
L['Emulate P2 '] = 'Emula P2 ';
L['Emulate P3 '] = 'Emula P3 ';
L['Emulate P4 '] = 'Emula P4 ';
L['Emulate Pad 5'] = 'Emula Pad 5';
L['Emulate Pad 6'] = 'Emula Pad 6';
L['Emulate Pad Back'] = 'Emula Indietro';
L['Emulate Pad Forward'] = 'Emula Avanti';
L['Emulate Pad Social'] = 'Emula Sociale';
L['Emulate Pad System'] = 'Emula Sistema';
L['Enable all modifier states for the cluster, including unmapped modifiers.'] = 'Abilita tutti gli stati del modificatore per il cluster, inclusi i modificatori non mappati.';
L['Enable Animation'] = 'Abilita animazione';
L['Enable casting bar ownership.'] = 'Abilita proprietà della barra di lancio.';
L['Enable class bar ownership.'] = 'Abilita proprietà della barra di classe.';
L['Enable Cooldown Numbers'] = 'Abilita numeri tempo di recupero';
L['Enable Group Loot'] = 'Abilita bottino di gruppo';
L['Enable interact key to interact with objects and creatures in the game world.'] = 'Abilita il tasto di interazione per interagire con oggetti e creature nel mondo di gioco.';
L['Enable interface cursor. Disable to use mouse-based interface interaction.'] = "Abilita il cursore di interfaccia. Disabilita per usare l'interazione con l'interfaccia basata sul mouse.";
L['Enable Lazy Loading'] = 'Abilita caricamento differito';
L['Enable Mouse Handling'] = 'Abilita gestione mouse';
L['Enable Player Interact'] = 'Abilita interazione con giocatore';
L['Enable Popups'] = 'Abilita popup';
L['Enable separate strafe angle threshold for when your character is in the air.'] = 'Abilita una soglia separata di angolo passo laterale quando il tuo personaggio è in aria.';
L['Enable Strafe Angle (Jump)'] = 'Abilita angolo passo laterale (salto)';
L['Enable Tint'] = 'Abilita tinta';
L['Enable touch tap to press touchpad buttons.'] = 'Abilita il tap tattile per premere i pulsanti del touchpad.';
L['Enable Touchpad Cursor'] = 'Abilita cursore touchpad';
L['Enable Vehicle'] = 'Abilita veicolo';
L['Enable Watch Bars'] = 'Abilita barre di monitoraggio';
L['Enables a crosshair to reveal your hidden center cursor position at all times.'] = 'Abilita un mirino per rivelare in ogni momento la posizione del tuo cursore centrato nascosto.';
L['Enables a radial on-screen keyboard that can be used to type messages.'] = 'Abilita una tastiera radiale a schermo che può essere usata per digitare messaggi.';
L['Enemy Soft Targeting'] = 'Targeting flessibile nemici';
L['Erase'] = 'Cancella';
L['Exit the vehicle you are currently controlling.'] = 'Esci dal veicolo che stai attualmente controllando.';
L['Export'] = 'Esporta';
L['Export %s to a string:'] = 'Esporta %s in una stringa:';
L['Export action page logic'] = 'Esporta logica pagina azione';
L['Export All'] = 'Esporta tutto';
L['Export all your custom presets to a string that can be shared with others.'] = 'Esporta tutti i tuoi preset personalizzati in una stringa che può essere condivisa con altri.';
L['Export current options'] = 'Esporta opzioni correnti';
L['Export serialized settings for sharing or backup.'] = 'Esporta impostazioni serializzate per condivisione o backup.';
L['Export this preset to a string that can be shared with others.'] = 'Esporta questo preset in una stringa che può essere condivisa con altri.';
L['Expressed in milliseconds. Pressing any combination of modifier and button will cancel the effect.'] = "Espresso in millisecondi. Premere qualsiasi combinazione di modificatore e pulsante annullerà l'effetto.";
L['Fade Buttons'] = 'Sfuma pulsanti';
L['Fade out the pet ring when not moused over.'] = 'Sfuma il menù radiale del compagno quando non ci passa sopra il mouse.';
L['Fade out the watch bars when not mousing over the toolbar.'] = 'Sfuma le barre di monitoraggio quando il mouse non è sulla barra degli strumenti.';
L['Fade Watch Bars'] = 'Sfuma barre di monitoraggio';
L['Features'] = 'Funzionalità';
L['Filter Condition'] = 'Condizione filtro';
L['Filter condition to find raid cursor frames, as a boolean expression in Lua.'] = 'Condizione filtro per trovare i riquadri del cursore incursione, come espressione booleana in Lua.';
L['Flavor'] = 'Variante';
L['Flyout Direction'] = 'Direzione flyout';
L['FOAS Adjust Delay'] = 'Ritardo regolazione FOAS';
L['FOAS Adjust Ease In'] = 'Avvio graduale FOAS';
L['Follow On A Stick (FOAS)'] = 'Follow On A Stick (FOAS)';
L['Font Flags'] = 'Flag font';
L['Font flags of the counter text on buttons.'] = 'Flag font del testo del contatore sui pulsanti.';
L['Font flags of the hotkey text on buttons.'] = 'Flag font del testo della scorciatoia sui pulsanti.';
L['Font flags of the macro text on buttons.'] = 'Flag font del testo della macro sui pulsanti.';
L['Font size of the counter text on buttons.'] = 'Dimensione font del testo del contatore sui pulsanti.';
L['Font size of the hotkey text on buttons.'] = 'Dimensione font del testo della scorciatoia sui pulsanti.';
L['Font size of the macro text on buttons.'] = 'Dimensione font del testo della macro sui pulsanti.';
L['Font size of the ring slice buttons.'] = 'Dimensione font dei pulsanti delle fette del menù radiale.';
L['Force Hard Target'] = 'Forza bersaglio fisso';
L['Frame level of the element.'] = "Livello riquadro dell'elemento.";
L['Frame Level Offset'] = 'Offset livello riquadro';
L['Frame level offset of the hotkey prompt, relative to the unit frame.'] = 'Offset del livello del riquadro del prompt di scorciatoia, relativo al riquadro unità.';
L['Frame strata of the element.'] = "Strato del riquadro dell'elemento.";
L['Free Cursor Timein'] = 'Apparizione cursore libero';
L['Frees your mouse cursor when used, if the cursor is currently center-fixed or hidden.'] = 'Libera il tuo cursore del mouse quando usato, se il cursore è attualmente fisso al centro o nascosto.';
L['Friend Soft Targeting'] = 'Targeting flessibile amici';
L['Full State Modifier'] = 'Modificatore stato completo';
L['Game Menu'] = 'Menu di gioco';
L['Global color of the tint effect on the toolbar and dividers.'] = "Colore globale dell'effetto tinta sulla barra degli strumenti e sui divisori.";
L['Global Scale'] = 'Scala globale';
L['Global Visibility'] = 'Visibilità globale';
L['Green'] = 'Verde';
L['Grid'] = 'Griglia';
L['Group buttons by modifier in a diamond layout.'] = 'Raggruppa i pulsanti per modificatore in un layout a diamante.';
L['Group buttons by modifier in a grid layout.'] = 'Raggruppa i pulsanti per modificatore in un layout a griglia.';
L['Group buttons for left and right triggers, with modifier swapping.'] = 'Raggruppa i pulsanti per i grilletti sinistro e destro, con scambio di modificatore.';
L['Group buttons in a single crossbar layout, with modifier swapping.'] = 'Raggruppa i pulsanti in un singolo layout crossbar, con scambio di modificatore.';
L['Group buttons in three layouts, with modifier swapping.'] = 'Raggruppa i pulsanti in tre layout, con scambio di modificatore.';
L['Height of the artwork.'] = "Altezza dell'artwork.";
L['Height of the cluster bar.'] = 'Altezza della barra cluster.';
L['Height of the crosshair, in scaled pixel units.'] = 'Altezza del mirino, in unità pixel scalate.';
L['Height of the group.'] = 'Altezza del gruppo.';
L['Hide Cursor on Jump'] = 'Nascondi cursore al salto';
L['Hide Cursor On Movement'] = 'Nascondi cursore durante il movimento';
L['Hide Cursor on Stick Input'] = 'Nascondi cursore con input stick';
L['Hide Flyout Buttons'] = 'Nascondi pulsanti flyout';
L['Hide Macro Text'] = 'Nascondi testo macro';
L['Hide the class bar.'] = 'Nascondi la barra di classe.';
L['Hide the macro text on buttons.'] = 'Nascondi il testo della macro sui pulsanti.';
L['Higher is slower.'] = 'Più alto è più lento.';
L['Higher values appear on top of lower values. Valid range 0-10000.'] = 'Valori più alti appaiono sopra valori più bassi. Intervallo valido 0-10000.';
L['Highlight Color'] = 'Colore evidenziatura';
L['Horizontal Offset'] = 'Offset orizzontale';
L['Horizontal offset from anchor point.'] = 'Offset orizzontale dal punto di ancoraggio.';
L['Horizontal offset of the counter text on buttons.'] = 'Offset orizzontale del testo del contatore sui pulsanti.';
L['Horizontal offset of the hotkey icon on group buttons.'] = "Offset orizzontale dell'icona della scorciatoia sui pulsanti del gruppo.";
L['Horizontal offset of the hotkey prompt position, in pixels.'] = 'Offset orizzontale della posizione del prompt di scorciatoia, in pixel.';
L['Horizontal offset of the hotkey text on buttons.'] = 'Offset orizzontale del testo della scorciatoia sui pulsanti.';
L['Horizontal offset of the macro text on buttons.'] = 'Offset orizzontale del testo della macro sui pulsanti.';
L['Horizontal Padding'] = 'Spaziatura orizzontale';
L['Hotkey Anchor'] = 'Ancoraggio scorciatoia';
L['Hotkey Offset X'] = 'Offset X scorciatoia';
L['Hotkey Offset Y'] = 'Offset Y scorciatoia';
L['Hotkey prompts appear on applicable name plates.'] = 'I prompt di scorciatoia appaiono sulle targhette applicabili.';
L['Hotkey prompts linger on unit frames after targeting.'] = 'I prompt di scorciatoia rimangono sui riquadri unità dopo la selezione del bersaglio.';
L['Hotkey Relative Anchor'] = 'Ancoraggio relativo scorciatoia';
L['Hotkey Size'] = 'Dimensione scorciatoia';
L['Hotkeys activate their target immediately.'] = 'Le scorciatoie attivano il loro bersaglio immediatamente.';
L['Hotkeys always target the same unit.'] = 'Le scorciatoie puntano sempre alla stessa unità.';
L['Hotkeys control your focus target instead of your current target.'] = 'Le scorciatoie controllano il tuo bersaglio focus invece del tuo bersaglio corrente.';
L['Hotkeys use '] = 'Le scorciatoie usano ';
L['How long the cursor should take to transition from one node to another.'] = 'Quanto tempo deve impiegare il cursore per passare da un nodo a un altro.';
L['How to clear focus after intercepting stick input.'] = "Come cancellare il focus dopo aver intercettato l'input dello stick.";
L['Import serialized preset(s) from an external source.'] = 'Importa preset serializzati da una sorgente esterna.';
L['Import serialized preset(s):'] = 'Importa preset serializzati:';
L['Import serialized settings from an external source.'] = 'Importa impostazioni serializzate da una sorgente esterna.';
L['Inactive Opacity'] = 'Opacità inattiva';
L['Include the current action page logic in the preset data.'] = 'Includi la logica della pagina azione corrente nei dati del preset.';
L['Include the current options from the %s tab in the preset data.'] = 'Includi le opzioni correnti dalla scheda %s nei dati del preset.';
L['Increase'] = 'Aumenta';
L['Increase lightness'] = 'Aumenta luminosità';
L['Increase opacity'] = 'Aumenta opacità';
L['Insert Suggestion'] = 'Inserisci suggerimento';
L['Intensity'] = 'Intensità';
L['Intensity of the gradient.'] = 'Intensità del gradiente.';
L['Interface Cursor'] = 'Cursore di interfaccia';
L['Interference'] = 'Interferenza';
L['Inverted'] = 'Invertito';
L['Join Discord'] = 'Unisciti a Discord';
L['Keeps your character centered to reduce motion sickness.'] = 'Mantiene il tuo personaggio centrato per ridurre il mal di mossa.';
L['Key %d'] = 'Tasto %d';
L['Keyboard button to emulate the back button.'] = 'Tasto della tastiera per emulare il pulsante indietro.';
L['Keyboard button to emulate the forward button.'] = 'Tasto della tastiera per emulare il pulsante avanti.';
L['Keyboard button to emulate the pad 5 button.'] = 'Tasto della tastiera per emulare il pulsante pad 5.';
L['Keyboard button to emulate the pad 6 button.'] = 'Tasto della tastiera per emulare il pulsante pad 6.';
L['Keyboard button to emulate the social button.'] = 'Tasto della tastiera per emulare il pulsante sociale.';
L['Keyboard button to emulate the system button.'] = 'Tasto della tastiera per emulare il pulsante di sistema.';
L['Keyboard'] = 'Tastiera';
L['Keyboard button to emulate the paddle 1 button.'] = 'Tasto della tastiera per emulare il pulsante paletta 1.';
L['Keyboard button to emulate the paddle 2 button.'] = 'Tasto della tastiera per emulare il pulsante paletta 2.';
L['Keyboard button to emulate the paddle 3 button.'] = 'Tasto della tastiera per emulare il pulsante paletta 3.';
L['Keyboard button to emulate the paddle 4 button.'] = 'Tasto della tastiera per emulare il pulsante paletta 4.';
L['Keyboard Layout Editor'] = 'Editor layout tastiera';
L['Larger value for easier taps.'] = 'Valore più grande per tap più facili.';
L['Layout'] = 'Layout';
L['Lazy loading has been disabled to activate the raid cursor.'] = 'Il caricamento differito è stato disabilitato per attivare il cursore incursione.';
L['Lazy loading has been disabled to activate the target ring.'] = 'Il caricamento differito è stato disabilitato per attivare il menù radiale bersaglio.';
L['Lazy loading has been disabled to activate unit hotkeys.'] = 'Il caricamento differito è stato disabilitato per attivare le scorciatoie unità.';
L['LED Color Type'] = 'Tipo colore LED';
L['LED Custom Color'] = 'Colore personalizzato LED';
L['Load'] = 'Carica';
L['Loaded binding preset %s.'] = 'Preset scorciatoie %s caricato.';
L['Loadout'] = 'Loadout';
L['Lock Automatic Tooltip'] = 'Blocca tooltip automatico';
L['Looks like a regular action bar, but shows the button combination rather than the action slot.'] = 'Sembra una normale barra delle azioni, ma mostra la combinazione di pulsanti invece dello slot azione.';
L['Lua pattern to match words for dictionary lookups.'] = 'Pattern Lua per corrispondere alle parole per le ricerche del dizionario.';
L['Macro condition to automatically load a binding preset by name when the condition applies.'] = 'Condizione macro per caricare automaticamente un preset scorciatoie in base al nome quando la condizione si applica.';
L['Macro condition to evaluate action bar page.'] = 'Condizione macro per valutare la pagina della barra delle azioni.';
L['Macro condition to override the strafe angle threshold for combat.'] = "Condizione macro per sovrascrivere la soglia dell'angolo di passo laterale per il combattimento.";
L['Macro condition to override the strafe angle threshold for travel.'] = "Condizione macro per sovrascrivere la soglia dell'angolo di passo laterale per il viaggio.";
L['Macro Text'] = 'Testo macro';
L['Main Button Border Style'] = 'Stile bordo pulsante principale';
L['Maintain offset relative to scale.'] = 'Mantieni offset relativo alla scala.';
L['Make sure your choice does not conflict with your bindings.'] = 'Assicurati che la tua scelta non entri in conflitto con le tue scorciatoie.';
L['Make this preset the default layout for all new characters.'] = 'Rendi questo preset il layout predefinito per tutti i nuovi personaggi.';
L['Match appropriate soft target to locked target.'] = 'Abbina il bersaglio flessibile appropriato al bersaglio fisso.';
L['Max Pitch'] = 'Beccheggio max';
L['Max time for a touch to register a tap/click, in milliseconds.'] = 'Tempo massimo perché un tocco registri un tap/click, in millisecondi.';
L['Max Yaw'] = 'Imbardata max';
L['Maximum Pitch adjust for the camera "look" feature.'] = 'Regolazione massima del beccheggio per la funzione «sguardo» della telecamera.';
L['Maximum Yaw adjust for the camera "look" feature.'] = "Regolazione massima dell'imbardata per la funzione «sguardo» della telecamera.";
L['Menu buttons to display on the toolbar.'] = 'Pulsanti del menù da mostrare sulla barra degli strumenti.';
L['Micro Menu'] = 'Micromenù';
L['Minimal Interact Nameplate Tooltip'] = 'Tooltip minimo di interazione su targhetta';
L['Modifications'] = 'Modifiche';
L['Modifier'] = 'Modificatore';
L['Modifier 1: Shift'] = 'Modificatore 1: Maiusc';
L['Modifier 2: Ctrl'] = 'Modificatore 2: Ctrl';
L['Modifier 3: Alt'] = 'Modificatore 3: Alt';
L['Modifier Tap Window'] = 'Finestra tap modificatore';
L['Modifiers'] = 'Modificatori';
L['Modules'] = 'Moduli';
L['Mouseover Cast'] = 'Lancio su mouseover';
L['Move Left'] = 'Muovi a sinistra';
L['Move one of the sticks.'] = 'Muovi uno degli stick.';
L['Move Right'] = 'Muovi a destra';
L['Move the frame with the sticks or the mouse. Confirm to save, cancel to restore.'] = 'Sposta il riquadro con gli stick o il mouse. Conferma per salvare, annulla per ripristinare.';
L['Movement Deadzone'] = 'Zona morta movimento';
L['Movement is analog, translated from your movement stick angle.'] = "Il movimento è analogico, tradotto dall'angolo del tuo stick di movimento.";
L['Movement X Axis'] = 'Asse X movimento';
L['Movement Y Axis'] = 'Asse Y movimento';
L['Navigate the interface with the gamepad using a virtual cursor.'] = 'Naviga nell\'interfaccia con il gamepad tramite un cursore virtuale.';
L['Needs to be long enough to press and release the button.'] = 'Deve essere abbastanza lungo da premere e rilasciare il pulsante.';
L['Nested Rings'] = 'Menù radiali nidificati';
L['Next Word'] = 'Parola successiva';
L['No axis input detected yet.'] = "Nessun input dell'asse rilevato ancora.";
L['No binding preset named %s exists.'] = 'Non esiste alcun preset scorciatoie chiamato %s.';
L['No button input detected yet.'] = 'Nessun input dei pulsanti rilevato ancora.';
L['No buttons were detected during the test.'] = 'Non sono stati rilevati pulsanti durante il test.';
L['No sensors were detected.'] = 'Non sono stati rilevati sensori.';
L['Normal background color of pie slices.'] = 'Colore di sfondo normale delle fette della torta.';
L['Normal Color'] = 'Colore normale';
L['Nudge Modifier'] = 'Modificatore spinta';
L['Number of buttons in the page.'] = 'Numero di pulsanti nella pagina.';
L['Number of buttons per row or column.'] = 'Numero di pulsanti per riga o colonna.';
L['Offset'] = 'Offset';
L['Offset of pointer arrow, from the selected node center, in pixels.'] = 'Offset della freccia puntatore, dal centro del nodo selezionato, in pixel.';
L['Offset X'] = 'Offset X';
L['Offset Y'] = 'Offset Y';
L['Offsets the camera horizontally from your character, for a more cinematic view.'] = 'Sposta la telecamera orizzontalmente rispetto al tuo personaggio, per una vista più cinematografica.';
L['Only recommended for super users.'] = 'Consigliato solo per utenti esperti.';
L['Only use taps for cursor clicks, do not use tap presses.'] = 'Usa solo i tap per i click del cursore, non usare pressioni con tap.';
L['Opacity of inactive hotkey prompts on unit frames after targeting.'] = 'Opacità dei prompt di scorciatoia inattivi sui riquadri unità dopo la selezione del bersaglio.';
L['Open Designer'] = 'Apri Designer';
L['Open Main Config'] = 'Apri Configurazione principale';
L['Open the configuration menu for the action bar.'] = 'Apri il menù di configurazione per la barra delle azioni.';
L['Open the main configuration window.'] = 'Apri la finestra di configurazione principale.';
L['Open the main edit mode window.'] = 'Apri la finestra principale della modalità modifica.';
L['Open the unit menu for the target unit.'] = "Apri il menù dell'unità per l'unità bersaglio.";
L['Open unit menu when interacting with other players.'] = "Apri il menù dell'unità quando interagisci con altri giocatori.";
L['Optimize Algorithm'] = 'Ottimizza algoritmo';
L['or'] = 'o';
L['Orientation of the page.'] = 'Orientamento della pagina.';
L['Orthodox'] = 'Ortodosso';
L['Out of Mana Color'] = 'Colore mana esaurito';
L['Out of Range Color'] = 'Colore fuori portata';
L['Outcome'] = 'Risultato';
L['Over Shoulder'] = 'Oltre la spalla';
L['Override'] = 'Sostituisci';
L['Override Class File'] = 'File classe sostitutivo';
L['Override class theme for interface styling.'] = "Sostituisci il tema classe per lo stile dell'interfaccia.";
L['Padding between buttons horizontally.'] = 'Spaziatura tra i pulsanti orizzontalmente.';
L['Padding between buttons vertically.'] = 'Spaziatura tra i pulsanti verticalmente.';
L['Page'] = 'Pagina';
L['Page Condition'] = 'Condizione pagina';
L['Page Hotkeys'] = 'Scorciatoie pagina';
L['Page Response'] = 'Risposta pagina';
L['Page |cFF00FFFF%s|r'] = 'Pagina |cFF00FFFF%s|r';
L['Patreon'] = 'Patreon';
L['PayPal'] = 'PayPal';
L['Performs an action and closes the menu.'] = "Esegue un'azione e chiude il menù.";
L['Performs an action without closing the menu.'] = "Esegue un'azione senza chiudere il menù.";
L['Pet Ring'] = 'Menù radiale compagno';
L['Pet Ring Position'] = 'Posizione del menù radiale famiglio';
L['Pet Ring Stick'] = 'Stick del menù radiale famiglio';
L['Pick up'] = 'Raccogli';
L['Pickup'] = 'Raccolta';
L['Pitch Axis'] = 'Asse beccheggio';
L['Pitch-only deadzone for camera, applied before the 2D deadzone.'] = 'Zona morta solo beccheggio per la telecamera, applicata prima della zona morta 2D.';
L['Pitches the camera upwards as you zoom out.'] = "Inclina la telecamera verso l'alto quando fai zoom out.";
L['Place in slot'] = 'Metti nello slot';
L['Place on action bar'] = 'Metti sulla barra delle azioni';
L['Play a sound when the pointer arrow reaches its destination.'] = 'Riproduci un suono quando la freccia puntatore raggiunge la sua destinazione.';
L['Please provide a unique name for a new %s in %s:'] = 'Per favore, fornisci un nome unico per un nuovo %s in %s:';
L['Plural Button'] = 'Pulsante plurale';
L['Pointer arrow rotates in the direction of travel.'] = 'La freccia puntatore ruota nella direzione di movimento.';
L['Pointer Offset'] = 'Offset puntatore';
L['Pointer Size'] = 'Dimensione puntatore';
L['Position'] = 'Posizione';
L['Position of the artwork.'] = "Posizione dell'artwork.";
L['Position of the button cluster.'] = 'Posizione del cluster di pulsanti.';
L['Position of the button.'] = 'Posizione del pulsante.';
L['Position of the class bar.'] = 'Posizione della barra di classe.';
L['Position of the cluster bar.'] = 'Posizione della barra cluster.';
L['Position of the divider.'] = 'Posizione del divisore.';
L['Position of the element.'] = "Posizione dell'elemento.";
L['Position of the group.'] = 'Posizione del gruppo.';
L['Position of the page.'] = 'Posizione della pagina.';
L['Position of the pet ring.'] = 'Posizione del menù radiale del compagno.';
L['Position of the toolbar.'] = 'Posizione della barra degli strumenti.';
L['Power Level'] = 'Livello batteria';
L['Preferred size of radial menus, in pixels.'] = 'Dimensione preferita dei menù radiali, in pixel.';
L['Preset Load Condition'] = 'Condizione di caricamento preset';
L['Presets'] = 'Preset';
L['Press and Hold'] = 'Premi e tieni';
L['Press your gamepad buttons to test them.'] = 'Premi i pulsanti del tuo gamepad per testarli.';
L['Prevent the cursor from wrapping when navigating.'] = 'Impedisci al cursore di avvolgersi durante la navigazione.';
L['Previous Word'] = 'Parola precedente';
L['Primary accept button, to use or confirm a quick menu action.'] = "Pulsante di accettazione primario, per usare o confermare un'azione del menù rapido.";
L['Primary Button'] = 'Pulsante primario';
L['Primary Stick'] = 'Stick primario';
L['Prioritize raid cursor bindings over other override bindings.'] = 'Dai priorità alle scorciatoie del cursore incursione sulle altre scorciatoie di sostituzione.';
L['Priority Override'] = 'Sostituzione priorità';
L['Purple'] = 'Viola';
L['Quick Menu'] = 'Menù rapido';
L['Radial Menus'] = 'Menù radiali';
L['Radial on-screen keyboard for typing with the gamepad.'] = 'Tastiera radiale su schermo per scrivere con il gamepad.';
L['Raid Cursor'] = 'Cursore incursione';
L['Re-apply config for the active device.'] = 'Riapplica configurazione per il dispositivo attivo.';
L['Reactivation Delay'] = 'Ritardo riattivazione';
L['Realm'] = 'Reame';
L['Recharge'] = 'Ricarica';
L['Recommended as first choice modifier.'] = 'Raccomandato come prima scelta di modificatore.';
L['Recommended as second choice modifier.'] = 'Raccomandato come seconda scelta di modificatore.';
L['Reduces unexpected camera movement to reduce motion sickness.'] = 'Riduce il movimento inaspettato della telecamera per ridurre il mal di mossa.';
L['Regenerate Dictionary'] = 'Rigenera dizionario';
L['Regular'] = 'Normale';
L['Relative Anchor'] = 'Ancoraggio relativo';
L['Relative anchor point of the counter text on buttons.'] = 'Punto di ancoraggio relativo del testo del contatore sui pulsanti.';
L['Relative anchor point of the hotkey icon on group buttons.'] = "Punto di ancoraggio relativo dell'icona della scorciatoia sui pulsanti del gruppo.";
L['Relative anchor point of the hotkey text on buttons.'] = 'Punto di ancoraggio relativo del testo della scorciatoia sui pulsanti.';
L['Relative anchor point of the macro text on buttons.'] = 'Punto di ancoraggio relativo del testo della macro sui pulsanti.';
L['Relative Rescale'] = 'Riscalatura relativa';
L['Reload'] = 'Ricarica';
L['Remove all saved settings and bindings, disable addon, and reload interface.'] = "Rimuovi tutte le impostazioni e scorciatoie salvate, disabilita addon e ricarica l'interfaccia.";
L['Remove all saved settings and reload interface.'] = "Rimuovi tutte le impostazioni salvate e ricarica l'interfaccia.";
L['Remove Button'] = 'Pulsante Rimuovi';
L['Remove from %s'] = 'Rimuovi da %s';
L['Remove this set. This action cannot be undone.'] = 'Rimuovi questo set. Questa azione non può essere annullata.';
L['Removes the tooltip background for a minimalistic look.'] = 'Rimuove lo sfondo del tooltip per un aspetto minimalista.';
L['Repeated Movement Delay'] = 'Ritardo movimento ripetuto';
L['Repeated Movement First Delay'] = 'Primo ritardo movimento ripetuto';
L['Replaces the default action bars with a layout designed for gamepad play.'] = 'Sostituisce le barre delle azioni predefinite con un layout pensato per il gamepad.';
L['Replaces the game menu with a controller-friendly menu and a quick access ring.'] = 'Sostituisce il menu di gioco con un menu adatto al controller e un anello di accesso rapido.';
L['Request early landing from the taxi you are currently riding.'] = 'Richiedi atterraggio anticipato dal taxi che stai attualmente cavalcando.';
L['Requires /reload to fully unhook when disabled.'] = 'Richiede /reload per scollegarsi completamente quando disabilitato.';
L['Requires a touchpad with LED support.'] = 'Richiede un touchpad con supporto LED.';
L['Requires reload.'] = 'Richiede ricarica.';
L['Requires Settings > Hide Cursor on Stick Input set to None.'] = 'Richiede Impostazioni > Nascondi cursore con input stick impostato su Nessuno.';
L['Requires the mouseover cast option in the game combat settings.'] = "Richiede l'opzione di lancio su mouseover nelle impostazioni di combattimento del gioco.";
L['Requires Toggle Interface Cursor binding to use the cursor.'] = 'Richiede la scorciatoia Alterna cursore di interfaccia per usare il cursore.';
L['Reset all mapping configurations and reload. (will not affect bindings)'] = 'Ripristina tutte le configurazioni di mappatura e ricarica. (non influirà sulle scorciatoie)';
L['Response to condition for custom processing.'] = 'Risposta alla condizione per elaborazione personalizzata.';
L['Reticle targeting means anything you place on the ground.'] = 'Il targeting tramite mirino significa qualsiasi cosa tu posizioni sul terreno.';
L['Reticle targeting uses free cursor instead of staying center-fixed.'] = 'Il targeting tramite mirino usa il cursore libero invece di rimanere fisso al centro.';
L['Return Button'] = 'Pulsante Indietro';
L['Returns to the previous menu.'] = 'Torna al menù precedente.';
L['Reverse Mouse Handling'] = 'Inverti gestione mouse';
L['Reverse Order'] = 'Inverti ordine';
L['Reverse the order of the buttons.'] = "Inverti l'ordine dei pulsanti.";
L['Ring Manager'] = 'Gestore menù radiali';
L['Ring Scale'] = 'Scala menù radiale';
L['Ring Size'] = 'Dimensione menù radiale';
L['Rings'] = 'Menù radiali';
L['Rings (Account)'] = 'Menù radiali (account)';
L['Rings (Character)'] = 'Menù radiali (personaggio)';
L['Rotation'] = 'Rotazione';
L['Rotation of the divider.'] = 'Rotazione del divisore.';
L['Run / Walk Threshold'] = 'Soglia corsa / camminata';
L['Run Tests'] = 'Esegui test';
L['Save as default'] = 'Salva come predefinito';
L['Save preset from %s:'] = 'Salva preset da %s:';
L['Save your current loadout to the preset list.'] = 'Salva il tuo loadout corrente nella lista dei preset.';
L['Scale of all radial menus, relative to UI scale.'] = "Scala di tutti i menù radiali, relativa alla scala dell'interfaccia.";
L['Scale of most ConsolePort frames, relative to UI scale.'] = "Scala della maggior parte dei riquadri ConsolePort, relativa alla scala dell'interfaccia.";
L['Scale of the cursor.'] = 'Scala del cursore.';
L['Scale of the game menu and radial companion.'] = 'Scala del menù di gioco e del compagno radiale.';
L['Scale of the keyboard.'] = 'Scala della tastiera.';
L['Scale of the pet ring.'] = 'Scala del menù radiale del compagno.';
L['Screen position of the ring.'] = 'Posizione del menù radiale sullo schermo.';
L['Secondary accept button, to use or confirm a quick menu action.'] = "Pulsante di accettazione secondario, per usare o confermare un'azione del menù rapido.";
L['Select a device from the list to continue.'] = 'Seleziona un dispositivo dalla lista per continuare.';
L['Select a slot to bind %s and place this spell.'] = 'Seleziona uno slot per assegnare %s e posizionare questo incantesimo.';
L['Select a slot to place this spell.'] = 'Seleziona uno slot per posizionare questo incantesimo.';
L['Select the device you want to configure.'] = 'Seleziona il dispositivo che vuoi configurare.';
L['Select the device you want to use.'] = 'Seleziona il dispositivo che vuoi usare.';
L['Selecting an item on a ring will stick until another item is chosen.'] = 'Selezionare un oggetto su un menù radiale rimarrà fisso finché non viene scelto un altro oggetto.';
L['Sensors'] = 'Sensori';
L['Set %d |cFF757575(%s)|r'] = 'Set %d |cFF757575(%s)|r';
L['Set binding'] = 'Imposta scorciatoia';
L['Sets if range should be a hard cutoff, even for something you can interact with.'] = 'Imposta se la portata deve essere un taglio fisso, anche per qualcosa con cui puoi interagire.';
L['Shift-click to Edit Binding'] = 'Maiusc+click per modificare scorciatoia';
L['Shift-right-click to Clear Binding'] = 'Maiusc+click destro per cancellare scorciatoia';
L['Show a color tint on the toolbar.'] = 'Mostra una tinta colorata sulla barra degli strumenti.';
L['Show Ability Briefings'] = 'Mostra riepiloghi abilità';
L['Show Action Bar Grid on Spell Pickup'] = 'Mostra griglia barra azioni alla raccolta incantesimi';
L['Show active buffs in the quick menu.'] = 'Mostra benefici attivi nel menù rapido.';
L['Show active debuffs in the quick menu.'] = 'Mostra penalità attive nel menù rapido.';
L['Show All Action Bars'] = 'Mostra tutte le barre delle azioni';
L['Show all enabled combinations in the cluster at all times.'] = 'Mostra sempre tutte le combinazioni abilitate nel cluster.';
L['Show bonus bar configuration for characters without stances.'] = 'Mostra la configurazione della barra bonus per personaggi senza pose.';
L['Show Centered Cursor Tooltip'] = 'Mostra tooltip cursore centrato';
L['Show connected devices.'] = 'Mostra dispositivi connessi.';
L['Show Default Button'] = 'Mostra pulsante predefinito';
L['Show Enemy Nameplate'] = 'Mostra targhetta nemico';
L['Show Enemy Target Icon'] = 'Mostra icona bersaglio nemico';
L['Show Enemy Tooltip'] = 'Mostra tooltip nemico';
L['Show Flyout Buttons'] = 'Mostra pulsanti flyout';
L['Show Flyouts'] = 'Mostra flyout';
L['Show Friendly Nameplate'] = 'Mostra targhetta amico';
L['Show Friendly Target Icon'] = 'Mostra icona bersaglio amico';
L['Show Friendly Tooltip'] = 'Mostra tooltip amico';
L['Show Gauge'] = 'Mostra indicatore';
L['Show help for command(s).'] = 'Mostra aiuto per i comandi.';
L['Show Hotkeys'] = 'Mostra scorciatoie';
L['Show icon above the current enemy soft target.'] = 'Mostra icona sopra il bersaglio flessibile nemico corrente.';
L['Show icon above the current friendly soft target.'] = 'Mostra icona sopra il bersaglio flessibile amico corrente.';
L['Show icon above the current interactable object.'] = "Mostra icona sopra l'oggetto interagibile corrente.";
L['Show icon above the current interactable target.'] = 'Mostra icona sopra il bersaglio interagibile corrente.';
L['Show interact binding hint on interactables.'] = 'Mostra suggerimento scorciatoia interazione sugli oggetti interagibili.';
L['Show Interact Hint'] = 'Mostra suggerimento interazione';
L['Show interact tooltip on nameplates, when applicable.'] = 'Mostra tooltip interazione sulle targhette, quando applicabile.';
L['Show item type in the quick menu.'] = 'Mostra tipo oggetto nel menù rapido.';
L['Show Main Icons'] = 'Mostra icone principali';
L['Show Modifier Icons'] = 'Mostra icone modificatore';
L['Show numerical cooldown text on buttons.'] = 'Mostra testo numerico tempo di recupero sui pulsanti.';
L['Show Object Icon'] = 'Mostra icona oggetto';
L['Show on Name Plates'] = 'Mostra sulle targhette';
L['Show pet action bar in the quick menu.'] = 'Mostra barra delle azioni del compagno nel menù rapido.';
L['Show ping commands in the quick menu.'] = 'Mostra comandi ping nel menù rapido.';
L['Show Portrait'] = 'Mostra ritratto';
L['Show portrait for the current unit, with health percentage and applicable spell casts.'] = "Mostra ritratto per l'unità corrente, con percentuale di salute e lanci di incantesimo applicabili.";
L['Show Status Text'] = 'Mostra testo stato';
L['Show Target Icon'] = 'Mostra icona bersaglio';
L['Show the default mouse action button.'] = 'Mostra il pulsante azione del mouse predefinito.';
L['Show the empty buttons in the page.'] = 'Mostra i pulsanti vuoti nella pagina.';
L['Show the flyout of small buttons for the button cluster.'] = 'Mostra il flyout dei piccoli pulsanti per il cluster di pulsanti.';
L['Show the hotkeys on the buttons.'] = 'Mostra le scorciatoie sui pulsanti.';
L['Show the icons for main buttons.'] = 'Mostra le icone per i pulsanti principali.';
L['Show the icons for modifier buttons.'] = 'Mostra le icone per i pulsanti modificatori.';
L['Show the pet power and health status.'] = 'Mostra lo stato di potenza e salute del compagno.';
L['Show the pet ring when in a vehicle.'] = 'Mostra il menù radiale del compagno quando sei in un veicolo.';
L['Show the watch bars at the bottom of the toolbar.'] = 'Mostra le barre di monitoraggio in fondo alla barra degli strumenti.';
L['Show Tooltip'] = 'Mostra tooltip';
L['Show tooltip for enemy target.'] = 'Mostra tooltip per bersaglio nemico.';
L['Show tooltip for friendly target.'] = 'Mostra tooltip per bersaglio amico.';
L['Show tooltip for interactables.'] = 'Mostra tooltip per oggetti interagibili.';
L['Show tooltip for mouseover targets when cursor is centered.'] = 'Mostra tooltip per bersagli al passaggio del mouse quando il cursore è centrato.';
L['Show tooltips on buttons when moused over.'] = 'Mostra tooltip sui pulsanti al passaggio del mouse.';
L['Show Type Icon'] = 'Mostra icona tipo';
L['Size of pointer arrow, in pixels.'] = 'Dimensione della freccia puntatore, in pixel.';
L['Size of the button cluster.'] = 'Dimensione del cluster di pulsanti.';
L['Size of the hotkey icon on group buttons.'] = "Dimensione dell'icona della scorciatoia sui pulsanti del gruppo.";
L['Size of unit hotkeys, in pixels.'] = 'Dimensione delle scorciatoie unità, in pixel.';
L['Space'] = 'Spazio';
L['Speed of cursor when it starts moving.'] = 'Velocità del cursore quando inizia a muoversi.';
L['Split stack'] = 'Dividi pila';
L['Start moving the configuration window.'] = 'Inizia a muovere la finestra di configurazione.';
L['Starting point of the page.'] = 'Punto di partenza della pagina.';
L['Status Bar'] = 'Barra stato';
L['Stick to use for main radial actions.'] = 'Stick da usare per le azioni radiali principali.';
L['Stick to use for the pet ring. Default follows the radial menu primary stick.'] = 'Stick da usare per il menù radiale del famiglio. Predefinito: segue lo stick principale dei menù radiali.';
L['Stick to use for this ring. Default follows the radial menu primary stick.'] = 'Stick da usare per questo menù radiale. Predefinito: segue lo stick principale dei menù radiali.';
L['Sticky Color'] = 'Colore fisso';
L['Sticky Selection'] = 'Selezione fissa';
L['Strafe Angle (Combat)'] = 'Angolo passo laterale (combattimento)';
L['Strafe Angle (Jump)'] = 'Angolo passo laterale (salto)';
L['Strafe Angle (Travel)'] = 'Angolo passo laterale (viaggio)';
L['Strafe Angle Macro Condition (Combat)'] = 'Condizione macro angolo passo laterale (combattimento)';
L['Strafe Angle Macro Condition (Travel)'] = 'Condizione macro angolo passo laterale (viaggio)';
L['Strata'] = 'Strato';
L['Stride'] = 'Passo';
L['Style of the border around main buttons.'] = 'Stile del bordo attorno ai pulsanti principali.';
L['Support on Patreon'] = 'Supporta su Patreon';
L['Swap to a specified action bar layout.'] = 'Cambia a un layout di barra delle azioni specificato.';
L['Swipe Color'] = 'Colore scorrimento';
L['Switch Button'] = 'Pulsante cambio';
L['Switch the action bar layout to %s? Your current layout will be replaced.'] = 'Passare il layout della barra delle azioni a %s? Il layout attuale verrà sostituito.';
L['Switches between the main menu and the radial companion.'] = 'Cambia tra il menù principale e il compagno radiale.';
L['Synchronize Bindings'] = 'Sincronizza scorciatoie';
L['Synchronize Config'] = 'Sincronizza configurazione';
L['Take ownership of, and move the micro menu buttons to the toolbar.'] = 'Prendi possesso e sposta i pulsanti del micromenù sulla barra degli strumenti.';
L['Takes the format of...\n|cFF3FC7EB[condition] Preset Name; nil|r\n\nAuto-saved presets are named "Character (Specialization) Realm", using class instead of specialization on Classic.\n\nThe preset loads outside of combat when the condition applies. Character presets take precedence over device presets.'] = [[Prende il formato di…
|cFF3FC7EB[condizione] Nome del preset; nil|r

I preset salvati automaticamente sono denominati "Personaggio (Specializzazione) Regno", con la classe al posto della specializzazione su Classic.

Il preset viene caricato fuori dal combattimento quando la condizione si applica. I preset del personaggio hanno la precedenza sui preset del dispositivo.]];
L['Taps for cursor clicks are right clicks instead of left.'] = 'I tap per i click del cursore sono click destri invece di sinistri.';
L['Target'] = 'Bersaglio';
L['Target enemies automatically by looking at them.'] = 'Bersaglia i nemici automaticamente guardandoli.';
L['Target friends automatically by looking at them.'] = 'Bersaglia gli amici automaticamente guardandoli.';
L['Target Match Lock'] = 'Blocco corrispondenza bersaglio';
L['Target Range'] = 'Portata bersaglio';
L['Target Range Hard Cutoff'] = 'Taglio fisso portata bersaglio';
L['Target Ring'] = 'Menù radiale bersaglio';
L['Targeting Mode'] = 'Modalità targeting';
L['Targeting tools: raid cursor, unit hotkeys and the target ring.'] = 'Strumenti di puntamento: cursore per incursioni, tasti rapidi delle unità e anello dei bersagli.';
L['Test Device'] = 'Testa dispositivo';
L['The analog input for forward/back movement.'] = "L'input analogico per il movimento avanti/indietro.";
L['The analog input for left/right Camera Yaw "look" feature.'] = "L'input analogico per la funzione «sguardo» di imbardata sinistra/destra della telecamera.";
L['The analog input for left/right Camera Yaw.'] = "L'input analogico per l'imbardata sinistra/destra della telecamera.";
L['The analog input for left/right movement.'] = "L'input analogico per il movimento sinistra/destra.";
L['The analog input for up/down Camera Pitch "look" feature.'] = "L'input analogico per la funzione «sguardo» di beccheggio su/giù della telecamera.";
L['The analog input for up/down Camera Pitch.'] = "L'input analogico per il beccheggio su/giù della telecamera.";
L['The configuration is accessible by the chat command %s or from the game menu.'] = 'La configurazione è accessibile tramite il comando di chat %s o dal menù di gioco.';
L['The modifier can be used to nudge the cursor position with the directional pad.'] = 'Il modificatore può essere usato per spostare la posizione del cursore con il pad direzionale.';
L['The modifier can be used to scroll together with the directional pad.'] = 'Il modificatore può essere usato per scorrere insieme al pad direzionale.';
L['The quick menu binding can be used to close the menu as well.'] = 'La scorciatoia del menù rapido può essere usata anche per chiudere il menù.';
L['The time it takes to transition from idle camera control to auto-adjustment (FOAS).'] = 'Il tempo necessario per passare dal controllo telecamera inattivo alla regolazione automatica (FOAS).';
L['Thickness'] = 'Spessore';
L['Thickness in scaled pixel units.'] = 'Spessore in unità pixel scalate.';
L['Thickness of the divider.'] = 'Spessore del divisore.';
L['This button is necessary to use or sell an item directly from your bags.'] = 'Questo pulsante è necessario per usare o vendere un oggetto direttamente dalle tue borse.';
L['This feature is only available in Classic.'] = 'Questa funzione è disponibile solo in Classic.';
L['This only affects gamepad bindings.'] = 'Questo influisce solo sulle scorciatoie del gamepad.';
L['This will not affect your bindings, interface settings or system-wide settings.'] = "Questo non influirà sulle tue scorciatoie, impostazioni dell'interfaccia o impostazioni di sistema.";
L['This will not work with Xbox controllers connected via bluetooth. The Xbox Adapter is required.'] = "Questo non funzionerà con i controller Xbox connessi via Bluetooth. È richiesto l'adattatore Xbox.";
L['Time in milliseconds for the opacity to change from one state to another.'] = "Tempo in millisecondi per il cambio dell'opacità da uno stato all'altro.";
L['Time in seconds to automatically hide centered cursor.'] = 'Tempo in secondi per nascondere automaticamente il cursore centrato.';
L['Time in seconds to enable free cursor.'] = 'Tempo in secondi per abilitare il cursore libero.';
L['Time to clear focus after intercepting stick input, in seconds.'] = "Tempo per cancellare il focus dopo aver intercettato l'input dello stick, in secondi.";
L['Timeframe to catch a binding in the configuration, in seconds.'] = 'Finestra temporale per catturare una scorciatoia nella configurazione, in secondi.';
L['Timeframe to toggle the mouse cursor when double-tapping a selected modifier.'] = 'Finestra temporale per alternare il cursore del mouse quando si fa doppio tap su un modificatore selezionato.';
L['Tint Color'] = 'Colore tinta';
L['Toggle visibility of all modifier flyouts for cluster action bars.'] = 'Alterna la visibilità di tutti i flyout modificatore per le barre delle azioni cluster.';
L['Toggle visibility of all modifier flyouts.'] = 'Alterna la visibilità di tutti i flyout modificatore.';
L['Toolbar'] = 'Barra strumenti';
L['Tooltip'] = 'Tooltip';
L['Top speed of cursor movement.'] = 'Velocità massima del movimento del cursore.';
L['Touch Tap Buttons'] = 'Pulsanti tap tattile';
L['Touch Tap Exclusive Click'] = 'Click esclusivo tap tattile';
L['Touch Tap Max Time'] = 'Tempo massimo tap tattile';
L['Touch Tap Right Click'] = 'Click destro tap tattile';
L['Touchpad'] = 'Touchpad';
L['Transition'] = 'Transizione';
L['Transition time for opacity changes.'] = 'Tempo di transizione per i cambi di opacità.';
L['Travel Time'] = 'Tempo di viaggio';
L['Trigger button actions on press instead of release.'] = 'Attiva le azioni dei pulsanti alla pressione invece che al rilascio.';
L['Triggers'] = 'Grilletti';
L['Turn Character With Camera'] = 'Ruota personaggio con telecamera';
L['Turn your character facing when you turn your camera angle.'] = "Ruota la direzione in cui guarda il tuo personaggio quando ruoti l'angolo della telecamera.";
L['Type of LED color to use for the touchpad.'] = 'Tipo di colore LED da usare per il touchpad.';
L['Types are PlayStation, Xbox, or Generic.'] = 'I tipi sono PlayStation, Xbox o Generico.';
L['Unit Hotkeys'] = 'Scorciatoie unità';
L['Unit Pool'] = 'Pool unità';
L['Units to watch, as lists of unit tokens selected by macro conditions. Use [] for the unconditional fallback.'] = 'Unità da osservare, come elenchi di token selezionati da condizioni macro. Usa [] come alternativa incondizionata.';
L['Unknown device selected.'] = 'Dispositivo sconosciuto selezionato.';
L['Unlimited Navigation'] = 'Navigazione illimitata';
L['Unmapped keyboard key(s) detected:'] = 'Tasto/i della tastiera non mappato/i rilevato/i:';
L['Use a targeting binding to turn a soft target into a hard target.'] = 'Usa una scorciatoia di selezione per trasformare un bersaglio flessibile in un bersaglio fisso.';
L['Use character specific addon settings for this character.'] = 'Usa impostazioni addon specifiche per questo personaggio.';
L['Use Custom Button Set'] = 'Usa set di pulsanti personalizzato';
L['Use Custom Loot Frame'] = 'Usa riquadro bottino personalizzato';
L['Use Default Hotkey Icons'] = 'Usa icone scorciatoia predefinite';
L['Use Focus Mode'] = 'Usa modalità focus';
L['Use Global Loot Tooltip'] = 'Usa tooltip bottino globale';
L['Use Hardware Mouse Cursor'] = 'Usa cursore del mouse hardware';
L['Use Instant Mode'] = 'Usa modalità istantanea';
L['Use Interact Nameplate Tooltip'] = 'Usa tooltip interazione su targhetta';
L['Use On Demand'] = 'Usa su richiesta';
L['Use optimized pathfinding algorithm for cursor movement.'] = 'Usa un algoritmo di ricerca percorsi ottimizzato per il movimento del cursore.';
L['Use press and hold to navigate and use rings. Press, point, release.'] = 'Usa premi e tieni per navigare e usare i menù radiali. Premi, punta, rilascia.';
L['Use Static Mode'] = 'Usa modalità statica';
L['Use the hardware cursor provided by the operating system.'] = 'Usa il cursore hardware fornito dal sistema operativo.';
L['Use together with [@cursor] macros to place reticle spells in a single click.'] = 'Usa insieme alle macro [@cursor] per posizionare incantesimi con mirino in un singolo click.';
L['Used for interacting with the world, at a center-fixed position.'] = 'Usato per interagire con il mondo, in una posizione fissa centrale.';
L['Uses global tint color when transparent.'] = 'Usa il colore tinta globale quando trasparente.';
L['Uses the default hotkey icons instead of the custom icons provided by ConsolePort.'] = 'Usa le icone scorciatoia predefinite invece delle icone personalizzate fornite da ConsolePort.';
L['Utility rings for spells, items and macros, selected with the radial stick.'] = 'Anelli di utilità per incantesimi, oggetti e macro, selezionati con la levetta radiale.';
L['Valid Action Deadzone'] = 'Zona morta azione valida';
L['Value below two may appear interlaced or not at all.'] = 'Un valore inferiore a due può apparire interlacciato o non apparire affatto.';
L['Vertical Offset'] = 'Offset verticale';
L['Vertical offset from anchor point.'] = 'Offset verticale dal punto di ancoraggio.';
L['Vertical offset of the counter text on buttons.'] = 'Offset verticale del testo del contatore sui pulsanti.';
L['Vertical offset of the hotkey icon on group buttons.'] = "Offset verticale dell'icona della scorciatoia sui pulsanti del gruppo.";
L['Vertical offset of the hotkey prompt position, in pixels.'] = 'Offset verticale della posizione del prompt di scorciatoia, in pixel.';
L['Vertical offset of the hotkey text on buttons.'] = 'Offset verticale del testo della scorciatoia sui pulsanti.';
L['Vertical offset of the macro text on buttons.'] = 'Offset verticale del testo della macro sui pulsanti.';
L['Vertical Padding'] = 'Spaziatura verticale';
L['Vertical position of centered cursor & targeting, as fraction of screen height.'] = "Posizione verticale del cursore centrato e del targeting, come frazione dell'altezza dello schermo.";
L['Visibility Condition'] = 'Condizione visibilità';
L['Watch bars include XP, reputation, honor, artifact power, and azerite.'] = 'Le barre di monitoraggio includono XP, reputazione, onore, potere artefatto e azerite.';
L['When disabled, a button press will also act as a cursor click.'] = 'Quando disabilitato, una pressione del pulsante agirà anche come click del cursore.';
L['When disabled, you will need to press the accept button to confirm a selection.'] = 'Quando disabilitato, dovrai premere il pulsante di accettazione per confermare una selezione.';
L['When enabled, a tap will act as a button press.'] = 'Quando abilitato, un tap agirà come una pressione del pulsante.';
L['When set to both sticks, cursor only disables when both sticks are used together.'] = 'Quando impostato su entrambi gli stick, il cursore si disabilita solo quando entrambi gli stick vengono usati insieme.';
L['Whether client keybindings should be saved to the server.'] = 'Se le scorciatoie da tastiera del client devono essere salvate sul server.';
L['Whether the keyboard should always be shown or only when a gamepad is active.'] = 'Se la tastiera deve essere sempre mostrata o solo quando un gamepad è attivo.';
L['Whether to save character- and account-scoped variables to the server.'] = 'Se salvare le variabili di personaggio e account sul server.';
L['Which button set to use for unit hotkeys.'] = 'Quale set di pulsanti usare per le scorciatoie unità.';
L['Which modifier to use for modified commands.'] = 'Quale modificatore usare per i comandi modificati.';
L['Which modifier to use for nudging the cursor.'] = 'Quale modificatore usare per spostare il cursore.';
L['Which modifier to use to toggle the mouse cursor when double-tapped.'] = 'Quale modificatore usare per alternare il cursore del mouse al doppio tap.';
L['Which modifier to use with the movement buttons to move the cursor.'] = 'Quale modificatore usare con i pulsanti di movimento per muovere il cursore.';
L['While held down, can simulate dragging by clicking on the directional pad.'] = 'Mentre è tenuto premuto, può simulare il trascinamento cliccando sul pad direzionale.';
L['Width of the artwork.'] = "Larghezza dell'artwork.";
L['Width of the cluster bar.'] = 'Larghezza della barra cluster.';
L['Width of the crosshair, in scaled pixel units.'] = 'Larghezza del mirino, in unità pixel scalate.';
L['Width of the group.'] = 'Larghezza del gruppo.';
L['Width of the toolbar.'] = 'Larghezza della barra degli strumenti.';
L['Wipe Dictionary'] = 'Cancella dizionario';
L['Wired'] = 'Cablato';
L['Works like a regular action bar, which displays the action slots of a specified action page.'] = 'Funziona come una normale barra delle azioni, che mostra gli slot azione di una pagina azione specificata.';
L['World'] = 'Mondo';
L['World interaction helpers: quick menu, loot frame and temporary ability prompts.'] = 'Aiuti per l\'interazione con il mondo: menu rapido, finestra del bottino e avvisi per abilità temporanee.';
L['X Offset'] = 'Offset X';
L['XP Bar Color'] = 'Colore barra XP';
L['Y Offset'] = 'Offset Y';
L['Yaw Axis'] = 'Asse imbardata';
L['Yaw-only deadzone for camera, applied before the 2D deadzone.'] = 'Zona morta solo-imbardata per la telecamera, applicata prima della zona morta 2D.';
L['your current loadout'] = 'il tuo loadout attuale';
---------------------------------------------------------------
-- Literal block entries
---------------------------------------------------------------
L['%s is already bound to\n%s\n\nDo you want to change it to\n%s?'] = [[%s è già assegnato a
%s

Vuoi cambiarlo in
%s?]];
L['+ Normal\n- Inverted'] = [[+ Normale
- Invertito]];
L['Basic redirect cannot route macros or ambiguous spells. Use target mode or focus mode with [@focus] macros to control behavior.'] = [[Il reindirizzamento di base non può instradare macro o incantesimi ambigui. Usa la modalità bersaglio o la modalità focus con macro [@focus] per controllare il comportamento.]];
L['Button or combination used to click when a given condition applies, but act as a normal binding otherwise.'] = [[Pulsante o combinazione usato per cliccare quando una determinata condizione si applica, ma agisce come una normale scorciatoia altrimenti.]];
L['Change how the raid cursor acquires a target. Redirect and focus modes will reroute appropriate spells without changing your target.'] = [[Cambia come il cursore incursione acquisisce un bersaglio. Le modalità di reindirizzamento e focus reinstraderanno gli incantesimi appropriati senza cambiare il tuo bersaglio.]];
L['Controls when your character transitions from strafing to facing your movement stick direction while in combat. Expressed in degrees, from looking straight forward.'] = [[Controlla quando il tuo personaggio passa dal passo laterale al rivolgersi nella direzione dello stick di movimento durante il combattimento. Espresso in gradi, dal guardare dritto davanti.]];
L['Controls when your character transitions from strafing to facing your movement stick direction while in the air. Expressed in degrees, from looking straight forward.'] = [[Controlla quando il tuo personaggio passa dal passo laterale al rivolgersi nella direzione dello stick di movimento mentre è in aria. Espresso in gradi, dal guardare dritto davanti.]];
L['Controls when your character transitions from strafing to facing your movement stick direction. Expressed in degrees, from looking straight forward.'] = [[Controlla quando il tuo personaggio passa dal passo laterale al rivolgersi nella direzione dello stick di movimento. Espresso in gradi, dal guardare dritto davanti.]];
L['Enable custom mouse handling, automating cursor toggling and timeout while using left and right mouse button emulation.'] = [[Abilita la gestione personalizzata del mouse, automatizzando la commutazione del cursore e il timeout durante l'uso dell'emulazione dei pulsanti sinistro e destro del mouse.]];
L['Equippable items of poor quality will not be sold while your character is below this level.'] = [[Gli oggetti equipaggiabili di qualità scarsa non verranno venduti finché il tuo personaggio è al di sotto di questo livello.]];
L['Explicit only matches hard locked targets through using a targeting binding, while implicit matches targets you attack.'] = [[Esplicito corrisponde solo a bersagli fissi tramite l'uso di una scorciatoia di selezione, mentre implicito corrisponde a bersagli che attacchi.]];
L['Groups button combinations in circular clusters which switch between different actions when modifiers are used.'] = [[Raggruppa le combinazioni di pulsanti in cluster circolari che si alternano tra diverse azioni quando vengono usati i modificatori.]];
L['Left mouse button emulation toggles center-fixed mode instead of free-roaming mode. Right mouse button emulation toggles free-roaming mode instead of center-fixed mode.'] = [[L'emulazione del pulsante sinistro del mouse alterna la modalità fissa al centro invece della modalità libera. L'emulazione del pulsante destro del mouse alterna la modalità libera invece della modalità fissa al centro.]];
L['Macro condition to enable the click override button. The default condition clicks right mouse button when there is no enemy target.'] = [[Condizione macro per abilitare il pulsante di sostituzione click. La condizione predefinita clicca il pulsante destro del mouse quando non c'è un bersaglio nemico.]];
L['Modifiers should be in descending order. M2M1, for example, is the Ctrl and Shift modifiers held at the same time.'] = [[I modificatori dovrebbero essere in ordine decrescente. M2M1, ad esempio, sono i modificatori Ctrl e Maiusc tenuti contemporaneamente.]];
L['Opacity is expressed in percentage, where 100 is fully visible and 0 is fully transparent. Values outside of the 0-100 range will be clamped.'] = [[L'opacità è espressa in percentuale, dove 100 è completamente visibile e 0 è completamente trasparente. I valori al di fuori dell'intervallo 0-100 saranno limitati.]];
L['Pointer arrow rotates in the direction of travel, and portraits scale up and down on movement.'] = [[La freccia puntatore ruota nella direzione di movimento, e i ritratti si ingrandiscono e rimpiccioliscono durante il movimento.]];
L['Replaces the default loot frame with a custom version optimized for controller navigation.'] = [[Sostituisce il riquadro bottino predefinito con una versione personalizzata ottimizzata per la navigazione con controller.]];
L['Show group loot rolls in the quick menu, allowing you to roll on items using gamepad buttons while in combat.'] = [[Mostra i tiri di bottino di gruppo nel menù rapido, permettendoti di tirare per gli oggetti usando i pulsanti del gamepad in combattimento.]];
L['Takes the format of...\n'] = [[Prende il formato di…
]];
L['The bindings underlying the button combinations will be unavailable while the cursor is in use.\n\nModifier can also be configured on a per button basis.'] = [[Le scorciatoie sottostanti alle combinazioni di pulsanti non saranno disponibili mentre il cursore è in uso.

Il modificatore può anche essere configurato per ogni pulsante.]];
L['Timeout clears focus after a set time, deadzone clears focus when stick input is neutral.'] = [[Il timeout cancella il focus dopo un tempo impostato, la zona morta cancella il focus quando l'input dello stick è neutrale.]];
L['Use a custom set of buttons for the game menu, otherwise the button set will be dynamically determined.'] = [[Usa un set personalizzato di pulsanti per il menù di gioco, altrimenti il set di pulsanti sarà determinato dinamicamente.]];
L['Use a shoulder button combined with crosshair for smooth and precise interactions. The click is performed at crosshair or cursor location.'] = [[Usa un pulsante dorsale combinato con il mirino per interazioni fluide e precise. Il click viene eseguito nella posizione del mirino o del cursore.]];
L['Use global game tooltip for loot information, allowing other addons to add information to lootable items.'] = [[Usa il tooltip di gioco globale per le informazioni sul bottino, permettendo ad altri addon di aggiungere informazioni agli oggetti saccheggiabili.]];
L['When set to zero, always face your movement stick direction.\nWhen set to max, never face your movement stick direction.'] = [[Quando impostato a zero, guarda sempre la direzione del tuo stick di movimento.
Quando impostato al massimo, non guardare mai la direzione del tuo stick di movimento.]];
L['While disabled, cursor timeout, and toggling between free-roaming and center-fixed cursor are also disabled.'] = [[Mentre è disabilitato, sono disabilitati anche il timeout del cursore e l'alternanza tra cursore libero e fisso al centro.]];
L['Your %s device has separate handling for Bluetooth and wired connection.\nWhich one are you using?'] = [[Il tuo dispositivo %s ha gestione separata per le connessioni Bluetooth e cablate.
Quale stai usando?]];
