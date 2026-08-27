local L = select(2, ...).Locale;
---------------------------------------------------------------
-- esMX Español Latinoamericano
---------------------------------------------------------------
---------------------------------------------------------------
-- Short / curated keys
---------------------------------------------------------------
L.ACTIONBAR_FORM_ACTIVE_DESC  = 'Esta forma está actualmente activa, y tu barra de acción principal muestra las habilidades asociadas con ella.'; -- en:b400a632
L.DESC_CAMERAZOOMIN           = 'Acerca la cámara. Mantén pulsado para zoom continuo.'; -- en:55f9b91f
L.DESC_CAMERAZOOMOUT          = 'Aleja la cámara. Mantén pulsado para zoom continuo.'; -- en:a6b9d796
L.DESC_OPENALLBAGS            = 'Abre y cierra todas las bolsas.'; -- en:4a74797f
L.DESC_RING_TARGET            = 'Muestra tu grupo de unidades en un menú radial, permitiéndote fijar una unidad como objetivo con el stick radial.'; -- en:294b636e
L.DESC_TOGGLEWORLDMAP_CLASSIC = 'Alterna el mapa del mundo.'; -- en:00548e70
L.DESC_TOGGLEWORLDMAP_RETAIL  = 'Alterna el mapa del mundo y el registro de misiones combinados.'; -- en:621a94e8
L.FORMAT_HOLD_BINDING         = '%s (mantener)'; -- en:c3ecd1b3
L.FORMAT_RING_NUMERICAL       = 'Menú radial |cFF00FFFF%s|r'; -- en:68d18518
L.NAME_EASY_MOTION            = 'Marcos de unidad de objetivo (mantener)'; -- en:e6f0c131
L.NAME_QUICK_MENU             = 'Menú rápido'; -- en:ed9a0668
L.NAME_RAID_CURSOR_FOCUS      = 'Cursor de banda (Foco)'; -- en:d350d370
L.NAME_RAID_CURSOR_TARGET     = 'Cursor de banda (Objetivo)'; -- en:8182d5d5
L.NAME_RAID_CURSOR_TOGGLE     = 'Alternar cursor de banda'; -- en:79fb9d46
L.NAME_RING_MENU              = 'Menú radial'; -- en:8d7e5939
L.NAME_RING_PET               = 'Menú radial de mascota'; -- en:8dab5a0e
L.NAME_RING_TARGET            = 'Menú radial de objetivo (mantener)'; -- en:59e8a9cb
L.NAME_RING_UTILITY           = 'Menú radial de utilidad'; -- en:96bc880d
L.NAME_UI_CURSOR_TOGGLE       = 'Alternar cursor de interfaz'; -- en:2d6091b5
L.RING_EMPTY_DESC             = 'Aún no tienes ninguna habilidad en este menú radial.'; -- en:044cf09a
---------------------------------------------------------------
-- Long / curated block entries
---------------------------------------------------------------
L.ACTIONBAR_FORM_DESC = [[Activar esta forma cambiará automáticamente tu barra de acción principal para mostrar las habilidades asociadas con esta forma.

La forma comparte asignaciones con tu barra de acción principal, permitiéndote usar tus combos habituales para acceder a las habilidades en esta forma.

Cuando salgas de esta forma, tu barra de acción principal volverá a su estado anterior, mostrando tus habilidades habituales.]]; -- en:a751197a
L.ACTIONBAR_MAIN_DESC = [[La barra de acción principal es tu ubicación principal para habilidades de rotación y otras acciones de uso frecuente.

Esta barra es dinámica y puede cambiar automáticamente a diferentes páginas según tu situación actual.

Por ejemplo, la barra de acción principal cambiará a un conjunto especial de habilidades cuando entres en un vehículo, participes en una batalla de mascotas, te transformes en otra forma, entres en una postura de combate o tomes el control de otra unidad.

Esto te permite acceder a habilidades específicas del contexto sin tener que cambiar manualmente la configuración de la barra de acción.

Cuando vuelvas a tu estado normal, tus habilidades habituales reaparecerán en la barra.]]; -- en:8e47cecd
L.ACTIONBAR_PAGE_MISMATCH_DESC = [[El número de página real de una barra de acción no siempre coincide con el nombre mostrado, debido a cómo se diseñó originalmente el sistema de barras de acción.

Esta discrepancia puede ignorarse si no usas una solución de página de acción personalizada. Ambos se muestran como referencia.]]; -- en:9fd917fd
L.ADD_NEW_RING_TEXT = [[|cFFFFFF00Crear nuevo menú radial|r
Por favor, elige un nombre para tu nuevo menú radial:]]; -- en:00af872a
L.CLEAR_RING_TEXT = [[|cFFFFFF00Vaciar %s|r
¿Seguro que quieres vaciar el menú radial?]]; -- en:ebc807d8
L.CONTROLS_GAMEPAD_TESTER_ACTION = [[
	Las pruebas caducarán automáticamente tras unos segundos si no se detecta entrada.
]]; -- en:0f591dc7
L.CONTROLS_GAMEPAD_TESTER_DESC = [[
	Usa la herramienta de pruebas para verificar que tu mando funciona correctamente.

	La prueba te pedirá que pulses botones y muevas los ejes de tu mando,
	para asegurar que todos los botones y sensores funcionan como se espera.

	Solución de problemas:

	- Asegúrate de que tu mando esté conectado y reconocido por el sistema operativo.

	- Comprueba si hay software conflictivo que pueda interferir con tu dispositivo,
	como Steam ejecutándose en segundo plano en Windows.

	- Si usas un ordenador portátil, asegúrate de que el dispositivo esté en modo juego
	en el centro de control. El modo escritorio no funcionará correctamente.

	- Actualiza los controladores e instala cualquier software necesario para tu mando.
]]; -- en:fd1ed2f5
L.CONTROLS_GENERAL_INFO = [[
	Selecciona tu esquema de control preferido.
]]; -- en:3f779845
L.CONTROLS_MODIFIERS_CUSTOM = [[
	Usa ajustes de modificador personalizados.

	Se recomienda asignar los modificadores a los gatillos o botones superiores, ya que son los botones más accesibles del mando.
]]; -- en:964cdf45
L.CONTROLS_MODIFIERS_DESC = [[
	Los modificadores alternan entre conjuntos de asignaciones y también emulan las teclas de control del teclado (Mayús, Ctrl, Alt).

	Mantener pulsado un modificador alternará temporalmente tus asignaciones a un conjunto alternativo, ampliando tus acciones disponibles.

	Los modificadores pueden pulsarse — presionados y soltados rápidamente — para ejecutar asignaciones normales.

	También pueden combinarse entre sí; usar dos modificadores te da un total de cuatro conjuntos de asignaciones,
	y tres modificadores te dan ocho conjuntos.

	Dos modificadores son suficientes para que la mayoría de jugadores tengan un conjunto cómodo de asignaciones,
	sin añadir demasiada complejidad.
]]; -- en:b083ec08
L.CONTROLS_MODIFIERS_LEFT = [[
	Usa modificadores zurdos para mantener el movimiento y el cambio de conjunto de asignaciones en el lado izquierdo del mando.

	Tener roles separados para las manos izquierda y derecha puede ayudar con la ergonomía y la coordinación.
]]; -- en:507e5d94
L.CONTROLS_MODIFIERS_TRIGGERS = [[
	Usa ambos gatillos como modificadores para dividir tus asignaciones entre el lado izquierdo y el derecho.

	Esto puede ser beneficioso si vienes de FFXIV o prefieres el modelo mental de crossbar.
]]; -- en:70401fbd
L.CONTROLS_MOUSE_BUTTONS_DESC = [[
	Los botones del ratón pueden emularse para ofrecer funcionalidad similar a un ratón.

	Estas asignaciones son vitales en algunos casos, como confirmar la colocación de hechizos en el suelo,
	apuntar con precisión entre multitudes y acciones de interfaz específicas.

	Pueden combinarse con modificadores para replicar aún más la funcionalidad de un ratón.

	Estos botones también se usan para alternar el cursor, que puede tener tres estados:

	- Libre; puedes usar tu mando para mover el cursor por la pantalla.

	- Centrado; el cursor está fijo en el centro de la pantalla, para apuntar a objetos y personajes
	y colocar hechizos en el suelo.

	- Oculto; el cursor sigue centrado, pero no es visible en la pantalla. Su posición se indica con una mira.
]]; -- en:e088d19f
L.CONTROLS_MOUSE_CUSTOM = [[
	Usa ajustes personalizados de botones de ratón.

	World of Warcraft trata los botones del ratón de dos maneras separadas, en su mayoría ocultas.

	- Cuando haces clic en la interfaz del juego (como botones o menús), la interfaz solo reacciona
	a clics de ratón, que pueden emularse con un mando.

	- Cuando haces clic en cosas del mundo del juego (como apuntar o interactuar), se usan asignaciones normales.

	Se recomienda encarecidamente mantener estas acciones juntas para cumplir el mismo papel que un ratón.
]]; -- en:3e862670
L.CONTROLS_MOUSE_INVERTED = [[
	Usa asignaciones de botones de ratón invertidas.

	Usa el stick izquierdo para alternar entre los modos de cursor centrado y oculto, y para clic derecho.

	Usa el stick derecho para alternar el modo de cursor libre y para clic izquierdo.
]]; -- en:16d3d6d2
L.CONTROLS_MOUSE_REGULAR = [[
	Usa asignaciones de botones de ratón normales.

	Usa el stick izquierdo para alternar el modo de cursor libre y para clic izquierdo.

	Usa el stick derecho para alternar entre los modos de cursor centrado y oculto, y para clic derecho.
]]; -- en:75e9f21b
L.CONTROLS_MOVEMENT_BALANCED_DESC = [[
	El movimiento equilibrado es un compromiso entre el movimiento tanque y el de seguimiento.

	Tanto en combate como en viaje, esta configuración hará lateral hasta 115 grados en cada dirección,
	lo que significa que sigues mirando al frente mientras te mueves lateralmente.

	Si mueves el stick aún más hacia abajo, tu personaje pasará a seguir la dirección de movimiento.
	Mira la cabeza de tu personaje para ver hacia dónde está mirando.

	115 grados es el punto óptimo para ofrecer máxima cobertura sin perder velocidad de movimiento.
]]; -- en:3355743a
L.CONTROLS_MOVEMENT_DESC = [[
	Los controles de movimiento pueden personalizarse para adaptarse a tu estilo de juego.

	Los mandos usan movimiento analógico, lo que significa que puedes correr en cualquier dirección,
	y caminar variando la presión aplicada al stick.

	El juego depende en gran medida del movimiento lateral como mecánica,
	donde te mueves de lado mientras miras en una dirección distinta.

	Puedes personalizar cuándo tu personaje pasa entre
	el movimiento lateral y girarse para mirar en la dirección de movimiento.

	Resalta una de las configuraciones y mueve tu stick izquierdo
	para probarla.
]]; -- en:9d22c4f0
L.CONTROLS_MOVEMENT_FOLLOW_DESC = [[
	El movimiento de seguimiento se centra en seguir la dirección hacia la que te mueves.

	Tanto en combate como en viaje, esta configuración nunca hará lateral
	ni caminará hacia atrás.

	Esto puede ser útil para jugadores que a menudo o siempre juegan con una configuración de un solo stick.
]]; -- en:45773d56
L.CONTROLS_MOVEMENT_TANK_DESC = [[
	El movimiento tanque se centra en mantener una posición orientada hacia delante mientras se está en combate.

	En combate, esta configuración siempre hará lateral y caminará hacia atrás para mantenerse mirando al frente.

	En viaje, esta configuración siempre seguirá la dirección de movimiento.
]]; -- en:9fcbcaaf
L.DEFAULTS_BINDINGS_EMPTY_DESC = [[
	Empieza desde cero.

	Esta acción borrará todas tus asignaciones de mando actuales, incluyendo los valores predeterminados de Blizzard,
	para permitirte configurar tus asignaciones desde cero.

	Esta acción no sobrescribe ni interfiere con las asignaciones de teclado existentes,
	pero ten en cuenta que las barras de acción se comparten entre ambos.

	Si planeas alternar entre teclado y mando, se recomienda cambiar tus
	asignaciones de mando en lugar de mover habilidades por las barras de acción al ajustar la configuración.
]]; -- en:51053386
L.DEFAULTS_BINDINGS_PRESET_DESC = [[
	Aplica las asignaciones recomendadas.

	Estas asignaciones están basadas en tus elecciones anteriores y deberían ofrecerte un buen punto de partida
	para configurar tu mando. Siempre puedes cambiarlas más adelante.

	Esta acción no sobrescribe ni interfiere con las asignaciones de teclado existentes,
	pero ten en cuenta que las barras de acción se comparten entre ambos.

	Si planeas alternar entre teclado y mando, se recomienda cambiar tus
	asignaciones de mando en lugar de mover habilidades por las barras de acción al ajustar la configuración.
]]; -- en:6ac789b1
L.DEFAULTS_GENERAL_INFO = [[
	Finaliza la configuración aplicando los ajustes y asignaciones recomendados para tu mando.
]]; -- en:c436023e
L.DEFAULTS_SETTINGS_APPLIED = [[
	Se han aplicado los ajustes recomendados para tu tipo de mando (%s).
]]; -- en:16be45b5
L.DEFAULTS_SETTINGS_DESC = [[
	Aplica los ajustes recomendados para tu tipo de mando (%s):
]]; -- en:15a4050f
L.DEFAULTS_SETTINGS_NOTWEAK = [[
	Tu tipo de mando (%s) no tiene ningún ajuste recomendado que aplicar.
]]; -- en:067a8a20
L.DESC_EASY_MOTION = [[
	Genera teclas rápidas de unidad para los marcos de unidad de tu pantalla,
	permitiéndote cambiar rápidamente entre objetivos amistosos.

	Para usar, mantén pulsada la asignación, luego pulsa las teclas
	indicadas sobre tu objetivo elegido y suelta
	la asignación para cambiar de objetivo.

	Esta asignación está muy recomendada para sanadores en contenido de
	5 jugadores, ya que proporciona un método extremadamente rápido para
	dirigirse a objetivos en grupos pequeños.

	En bandas, la complejidad de la entrada necesaria
	para aislar tu objetivo preferido puede ser intimidante.
	Ver «Alternar cursor de banda» para una alternativa.
]]; -- en:0f9384b6
L.DESC_EXTRAACTIONBUTTON1 = [[
	El botón de acción adicional alberga una habilidad temporal usada en
	diversas misiones, escenarios y encuentros con jefes.

	Cuando esta asignación no está configurada, el botón de acción adicional siempre
	está disponible en el menú radial de utilidad.

	Este botón aparece en tu barra de acción de mando como un botón de acción normal,
	pero no puedes cambiar su contenido.
]]; -- en:6dd42998
L.DESC_INTERACTTARGET = [[
	Te permite interactuar con PNJ y objetos del mundo del juego.

	Tiene la misma capacidad que el cursor centrado, pero no requiere que apuntes
	con el cursor o la mira directamente al objetivo.

	Los objetos interactivos se resaltan cuando están dentro del rango.
]]; -- en:b1478add
L.DESC_JUMP = [[
	También se puede usar para nadar hacia arriba bajo el agua, ascender con
	monturas voladoras y despegar o batir las alas mientras vas a lomos de dragón.

	Saltar es útil para cubrir huecos en el movimiento mientras realizas una
	acción a mano izquierda que requiere tu pulgar.

	En una configuración normal, el stick izquierdo controla tu movimiento.
	Si necesitas pulsar una combo de cruceta en movimiento,
	saltar puede servir para mantener tu impulso hacia adelante, mientras retiras
	brevemente el pulgar del stick.
]]; -- en:4c032315
L.DESC_KEY_BUTTON1 = [[
	Se usa para alternar el cursor libre, permitiéndote usar tu stick de cámara como puntero de ratón.
]]; -- en:fd3d111a
L.DESC_KEY_BUTTON2 = [[
	Se usa para alternar el cursor centrado, permitiéndote interactuar con objetos y personajes
	del mundo del juego en una posición fija central del ratón.
]]; -- en:2f5c87e4
L.DESC_QUICK_MENU = [[
	Un menú de acceso rápido que reúne las acciones más comunes durante el juego,
	como tirar el dado para el botín de grupo, cancelar mejoras
	o usar un objeto de las bolsas.
]]; -- en:0365846b
L.DESC_RAID_CURSOR = [[
	Alterna un cursor que se ajusta a tus
	marcos de unidad en pantalla, permitiéndote curar a jugadores amistosos
	mientras mantienes otro objetivo.

	El cursor de banda también puede configurarse para apuntar directamente,
	donde mover el cursor cambiará tu objetivo actual.

	Durante su uso, el cursor de banda ocupa un conjunto de
	combinaciones de cruceta para controlar la posición del cursor.

	En modo de redirección, el cursor no redirige macros ni
	hechizos ambiguos, como el Castigo de un sacerdote.

	Ver «Marcos de unidad de objetivo» para otra opción.
]]; -- en:cacdf9c0
L.DESC_RING_CUSTOM = [[
	Un menú radial donde puedes añadir tus objetos, hechizos, macros y
	monturas para los que no quieres sacrificar espacio de barra de acción.

	Para usarlo, mantén pulsada la asignación, inclina el stick en la dirección
	del objeto que quieres seleccionar y suelta la asignación.

	Para quitar objetos, sigue la indicación de la información de objeto cuando lo tengas enfocado.
]]; -- en:159abd06
L.DESC_RING_MENU = [[
	Un menú radial que reúne paneles habituales y acciones frecuentes
	en un solo lugar para un acceso rápido.

	El menú también es accesible desde el menú del juego sin necesidad de
	una asignación separada, cambiando de página.
]]; -- en:7ee244a1
L.DESC_RING_PET = [[
	Un menú radial que te permite controlar a tu mascota actual.
]]; -- en:b1c4b5d3
L.DESC_RING_UTILITY = [[
	Un menú radial donde puedes añadir tus objetos, hechizos, macros y
	monturas para los que no quieres sacrificar espacio de barra de acción.

	Para usarlo, mantén pulsada la asignación, inclina el stick en la dirección
	del objeto que quieres seleccionar y suelta la asignación.

	Para añadir objetos al menú, sigue la indicación del cursor de interfaz,
	o coge algo con el cursor del ratón y pulsa la asignación para soltarlo en el menú.

	Para quitar objetos, sigue la indicación de la información de objeto cuando lo tengas enfocado.

	El menú radial de utilidad añade automáticamente objetos de misión y habilidades
	temporales que no hayas colocado en la barra de acción.
]]; -- en:de107e96
L.DESC_TARGETNEARESTENEMY = [[
	Alterna entre los objetivos enemigos más cercanos delante de ti.
	Sin un objetivo actual, se seleccionará el enemigo más central.
	De lo contrario, se irá pasando entre los objetivos más cercanos.

	Mantén pulsado para resaltar objetivos antes de decidir
	cambiar de objetivo.

	Recomendado para uso como asignación secundaria de selección de objetivos,
	o como asignación principal en juego casual o si
	el escaneo de objetivos requiere demasiada precisión para ser cómodo.

	No recomendado para mazmorras u otros escenarios de alta precisión.
]]; -- en:981bc29c
L.DESC_TARGETSCANENEMY = [[
	Escanea enemigos en un cono estrecho delante de ti.
	Mantén pulsado para resaltar objetivos antes de decidir
	cambiar de objetivo.

	Especialmente útil para cambiar rápidamente de objetivos
	en combate con alta precisión.

	La prioridad de objetivo está sesgada hacia el apuntado, es decir, el
	objetivo más cercano al centro del cono se selecciona
	primero. Esto puede priorizar un
	objetivo distante sobre uno más cercano, si el objetivo distante
	está más cerca del centro del cono.

	Recomendado como asignación principal de selección de objetivos para la mayoría de jugadores.
]]; -- en:2de05bb9
L.DESC_TOGGLEAUTORUN = [[
	La carrera automática hará que tu personaje siga moviéndose
	en la dirección a la que mira sin ninguna entrada por tu parte.

	La carrera automática es útil para aliviar la fatiga del pulgar durante
	largas fases de movimiento, o para liberar tu pulgar para hacer otras cosas mientras te mueves.
]]; -- en:9e97af4b
L.DESC_TOGGLEGAMEMENU = [[
	La asignación de menú gestiona todas las funcionalidades que ocurren al pulsar
	la tecla Escape en un teclado. Gestiona diferentes acciones según
	el estado actual del juego.

	Si hay acciones en curso relacionadas con hechizos o selección de objetivos,
	se cancelarán. Pulsar la asignación con un objetivo activo
	lo eliminará. Pulsar la asignación mientras lanzas un hechizo
	interrumpirá el lanzamiento.

	La asignación también gestiona otros casos según lo que esté
	mostrado actualmente en la pantalla. Por ejemplo, si hay un panel
	abierto, como el libro de hechizos, la asignación realizará la
	acción necesaria para cerrarlo u ocultarlo.

	Si no se aplica ninguno de los casos anteriores, el menú del juego se abrirá o
	se cerrará al pulsarse.
]]; -- en:adfccfe4
L.DEVICE_DESC_PLAYSTATION4 = [[
	El mando PlayStation 4, también conocido como DualShock 4, es el mando de la generación anterior de Sony.

	Es un mando con muchas funciones, con panel táctil, controles de movimiento y soporte para todos sus botones en el juego.

	Para aprovechar todas las funciones, puede que necesites instalar PlayStation Accessories (Windows).
]]; -- en:7bea4ad9
L.DEVICE_DESC_PLAYSTATION5 = [[
	El mando PlayStation 5, también conocido como DualSense, es actualmente el mejor mando para World of Warcraft.

	Es el mando más completo disponible, con controles de movimiento, panel táctil y, en el caso de la variante Edge, paletas traseras nativas.
	Todos los botones del mando pueden usarse en el juego.

	Para aprovechar todas las funciones, puede que necesites instalar PlayStation Accessories (Windows).
]]; -- en:c5f15091
L.DEVICE_DESC_STEAMDECK = [[
	Las Steam Decks suelen ejecutar World of Warcraft mediante Proton a través del cliente Steam.

	Al jugar mediante Steam, el dispositivo debería usar un perfil de juego que cubra al menos un diseño Xbox estándar.

	Mando con Trackpad de Ratón ofrece una base sólida.

	Las Steam Decks no pueden usar sus paletas de forma nativa en World of Warcraft.
	Las paletas pueden asignarse mediante emulación o con teclas de teclado en los ajustes de Steam Input.

	El preajuste de Steam Deck del juego también puede ser adecuado para otros ordenadores portátiles, debido al diseño de control similar.
]]; -- en:2a5e4173
L.DEVICE_DESC_SWITCHPRO = [[
	El mando Nintendo Switch Pro tiene un diseño similar al mando Xbox, pero con etiquetas de botones invertidas.

	El mando Pro tiene cuatro botones centrales, dándole una ligera ventaja sobre un mando Xbox estándar.

	El mando Nintendo Switch 2 Pro no puede usar sus paletas ni el botón C de forma nativa en el juego.
	Con software externo, como Steam o reWASD, pueden asignarse a teclas de teclado para permitir su uso en el juego.
]]; -- en:79260874
L.DEVICE_DESC_XBOX = [[
	Las variantes Xbox son los mandos más comunes y están bien soportadas por World of Warcraft.

	El mando Xbox Elite no puede usar sus paletas de forma nativa en el juego, pero pueden usarse para simular otros botones del mando,
	usando la aplicación Xbox Accessories (Windows).

	Con software externo, como Steam o reWASD, las paletas pueden asignarse a teclas de teclado para permitir su uso en el juego.

	El botón central está reservado para la Guía Xbox y no puede usarse en el juego.

	También recomendado para Steam Input, consistente con el mando Xbox 360 que emula.
]]; -- en:654501d3
L.DISC_KEY_BUTTON1 = [[
	Mientras uno de tus botones esté configurado para emular el clic izquierdo, esta asignación no puede cambiarse.
]]; -- en:e811ebc6
L.DISC_KEY_BUTTON2 = [[
	Mientras uno de tus botones esté configurado para emular el clic derecho, esta asignación no puede cambiarse.
]]; -- en:b85c78b2
L.EXPORT_DATA_TEXT = [[

|cFFFFFF00Exportar|r

Selecciona qué datos quieres exportar. Se generará una cadena debajo, que puedes pegar en otro cliente o compartir con otros.

Usa %s para copiar la cadena.
]]; -- en:1741e6a6
L.GFX_GENERAL_INFO = [[
	Selecciona los gráficos de mando que más se parecen al aspecto de tu mando.

	Elegir los gráficos no cambia el funcionamiento de tu mando, solo cambia la apariencia de la interfaz.

	Los gráficos se usan para mostrarte qué botones están asignados actualmente a qué acciones, y para proporcionar una referencia visual del diseño de tu mando.

	Se ofrecen algunas recomendaciones de ajustes opcionales según tu elección.
]]; -- en:54457360
L.IMPORT_DATA_TEXT = [[

|cFFFFFF00Importar|r

Pega abajo una cadena exportada, luego carga y selecciona los datos que quieres importar. Los datos importados sobrescribirán tus datos actuales cuando aplique.

Usa %s para copiar la cadena desde el origen y %s para pegarla abajo.
]]; -- en:145f78fb
L.IMPORT_FAILED_TEXT = [[

|cFFFFFF00Importar|r

La importación ha fallado:
]]; -- en:a7555666
L.LINK_COPY = [[
	Enlace a %s.

	Ctrl+A para seleccionar y Ctrl+C para copiar.

	Pega (Ctrl+V) el enlace en tu navegador web.
]]; -- en:3f396345
L.LINK_DISCORD_TEXT = [[
	La comunidad donde puedes encontrar soporte, hablar sobre el juego, compartir ideas y encontrar jugadores afines.

	Haz clic aquí para unirte al servidor.
]]; -- en:e2f9740c
L.LINK_PATREON_TEXT = [[
	El desarrollo y mantenimiento de este addon requiere mucho tiempo y esfuerzo,
	pero ConsolePort siempre será totalmente gratuito.

	Conviértete en mecenas en Patreon para desbloquear tu insignia de Discord y, a cambio, apoyar el futuro del proyecto.

	Haz clic aquí para hacerte mecenas.
]]; -- en:3cc9532e
L.LINK_PAYPAL_TEXT = [[
	Las donaciones se reinvierten directamente en el desarrollo y mantenimiento del addon.

	Cualquier contribución, grande o pequeña, es muy apreciada.

	Haz clic aquí para donar mediante PayPal.
]]; -- en:28c6265a
L.REMOVE_RING_TEXT = [[|cFFFFFF00Eliminar %s|r
¿Seguro que quieres eliminar el menú radial?]]; -- en:1a461a1a
L.RING_MENU_DESC = [[Crea tus propios menús radiales donde puedes añadir tus objetos, hechizos, macros y monturas para los que no quieres sacrificar espacio de barra de acción.

Para usarlo, mantén pulsada la asignación seleccionada, inclina el stick en la dirección del objeto que quieres seleccionar y suelta la asignación.

El menú radial por defecto, el |CFF00FF00Menú radial de utilidad|r, tiene propiedades especiales para facilitar las misiones y la interacción con el mundo, y no es estático. Añadirá y eliminará objetos automáticamente según sea necesario.

Si quieres crear un menú radial para usar en tu rotación y no solo para utilidad, se recomienda usar un menú radial personalizado para este propósito.]]; -- en:39d4577b
L.SELECTED_RING_TEXT = [[Este es tu menú radial seleccionado actualmente.
Cuando pulses y mantengas la asignación, todas tus habilidades seleccionadas aparecerán en un menú radial en pantalla.

Inclina tu stick radial en la dirección de la habilidad u objeto que quieras usar, luego suelta la asignación para confirmar.]]; -- en:2cdfa5d3
L.SET_RING_BINDING_TEXT = [[
|cFFFFFF00Establecer asignación|r

Pulsa una combinación de botones para seleccionar una nueva asignación para este menú radial.

]]; -- en:1c0e03f4
L.SLOT_NO_BINDING = [[
|cFFFFFF00Establecer asignación|r

%s en %s no tiene una asignación asignada.

Pulsa una combinación de botones para seleccionar una nueva asignación para esta ranura.

]]; -- en:74326275
L.SLOT_SET_BINDING = [[
|cFFFFFF00Establecer asignación|r

Pulsa una combinación de botones para seleccionar una nueva asignación para %s.

]]; -- en:d1933130
---------------------------------------------------------------
-- Literals
---------------------------------------------------------------
L['2D deadzone for camera that takes into account pitch and yaw movement together.'] = 'Zona muerta 2D para la cámara que tiene en cuenta el movimiento de cabeceo y guiñada conjuntamente.';
L['2D deadzone for movement that takes into account X and Y movement together.'] = 'Zona muerta 2D para movimiento que tiene en cuenta el movimiento X e Y conjuntamente.';
L['A button cluster for all modifiers of a single button.'] = 'Un clúster de botones para todos los modificadores de un solo botón.';
L['A cluster bar with a toolbar below it, laid out horizontally.'] = 'Una barra clúster con una barra de herramientas debajo, dispuesta horizontalmente.';
L['A cluster bar with a toolbar below it.'] = 'Una barra clúster con una barra de herramientas debajo.';
L['A divider to separate elements.'] = 'Un separador para separar elementos.';
L['A friendly soft target can be acquired while having an enemy hard target.'] = 'Un objetivo flexible amistoso puede adquirirse mientras se tiene un objetivo fijo enemigo.';
L['A regular action bar.'] = 'Una barra de acción normal.';
L['A ring of buttons for pet commands.'] = 'Un menú radial de botones para órdenes de mascota.';
L['A toolbar with XP indicators, shortcuts, class specific bars, and miscellaneous information.'] = 'Una barra de herramientas con indicadores de XP, accesos directos, barras específicas de clase e información variada.';
L['About'] = 'Acerca de';
L['Acceleration of cursor per second as it continues to move.'] = 'Aceleración del cursor por segundo mientras sigue moviéndose.';
L['Accent Color'] = 'Color de acento';
L['Accept Button'] = 'Botón Aceptar';
L['Action Bar Configuration'] = 'Configuración de barra de acción';
L['Action bar is scaled separately.'] = 'La barra de acción se escala por separado.';
L['Action Bar Loadout'] = 'Loadout de barra de acción';
L['Action Bar Loadout (Deprecated)'] = 'Loadout de barra de acción (obsoleto)';
L['Action Bar Presets'] = 'Preajustes de barra de acción';
L['Action Bar Setup'] = 'Configuración de barra de acción';
L['Action Button'] = 'Botón de acción';
L['Action Button Group'] = 'Grupo de botones de acción';
L['Action Page'] = 'Página de acción';
L['Action Page Condition'] = 'Condición de página de acción';
L['Action Page Response'] = 'Respuesta de página de acción';
L['Activate targeting components only while their bindings are in use.'] = 'Activa los componentes de selección de objetivo solo mientras sus asignaciones están en uso.';
L['Active Color'] = 'Color activo';
L['Active Device'] = 'Dispositivo activo';
L['Add a new element to your loadout.'] = 'Añade un nuevo elemento a tu loadout.';
L['Add to %s'] = 'Añadir a %s';
L['Add, remove or reset a frame from cursor stack.'] = 'Añade, elimina o restablece un marco de la pila del cursor.';
L['Affects both mouse and gamepad.'] = 'Afecta tanto al ratón como al mando.';
L['Alignment'] = 'Alineación';
L['Alignment of the counter text on buttons.'] = 'Alineación del texto del contador en los botones.';
L['Alignment of the hotkey text on buttons.'] = 'Alineación del texto de tecla rápida en los botones.';
L['Alignment of the macro text on buttons.'] = 'Alineación del texto de macro en los botones.';
L['All combines all connected devices into one.'] = '«Todos» combina todos los dispositivos conectados en uno.';
L['Allow binding discrete radial stick inputs.'] = 'Permitir vincular entradas radiales discretas del stick.';
L['Allow binding multiple combos to the same binding.'] = 'Permitir vincular múltiples combos a la misma asignación.';
L['Allow Binding Overlap'] = 'Permitir solapamiento de asignaciones';
L['Allow cursor to interact with and show preference for group loot frames.'] = 'Permitir que el cursor interactúe con marcos de botín de grupo y muestre preferencia por ellos.';
L['Allow cursor to interact with and show preference for popups and static dialogs.'] = 'Permitir que el cursor interactúe con popups y diálogos estáticos y muestre preferencia por ellos.';
L['Allow cursor to interact with the entire interface, not only panels.'] = 'Permitir que el cursor interactúe con toda la interfaz, no solo con paneles.';
L['Allow Radial Bindings'] = 'Permitir asignaciones radiales';
L['Allows the use of the touchpad to control cursor movement.'] = 'Permite el uso del panel táctil para controlar el movimiento del cursor.';
L['Alphabet to use for dictionary suggestions and word processing.'] = 'Alfabeto a usar para sugerencias de diccionario y procesamiento de palabras.';
L['Always keep cursor centered and visible when controlling camera.'] = 'Mantener siempre el cursor centrado y visible al controlar la cámara.';
L['Always Show All Buttons'] = 'Mostrar siempre todos los botones';
L['Always Show Mouse Cursor'] = 'Mostrar siempre el cursor del ratón';
L['Always show nameplate for soft enemy target.'] = 'Mostrar siempre la placa de nombre para objetivo flexible enemigo.';
L['Always show nameplate for soft friendly target.'] = 'Mostrar siempre la placa de nombre para objetivo flexible amistoso.';
L['Always show tooltip for an automatically acquired target, as long as it exists.'] = 'Mostrar siempre la información para un objetivo adquirido automáticamente, mientras exista.';
L['An action button in a group.'] = 'Un botón de acción en un grupo.';
L['Analog Movement'] = 'Movimiento analógico';
L['Anchor'] = 'Anclaje';
L['Anchor point of parent to pair with.'] = 'Punto de anclaje del padre con el que emparejar.';
L['Anchor point of the counter text on buttons.'] = 'Punto de anclaje del texto del contador en los botones.';
L['Anchor point of the hotkey icon on group buttons.'] = 'Punto de anclaje del icono de tecla rápida en botones de grupo.';
L['Anchor point of the hotkey text on buttons.'] = 'Punto de anclaje del texto de tecla rápida en los botones.';
L['Anchor point of the macro text on buttons.'] = 'Punto de anclaje del texto de macro en los botones.';
L['Anchor point to attach.'] = 'Punto de anclaje al que adjuntar.';
L['Apply default settings to the current category or all settings.'] = 'Aplicar ajustes predeterminados a la categoría actual o a todos los ajustes.';
L['Arc Allowance'] = 'Tolerancia de arco';
L['Are you sure you want to delete %s from %s?'] = '¿Seguro que quieres eliminar %s de %s?';
L['Are you sure you want to overwrite %s with %s?'] = '¿Seguro que quieres sobrescribir %s con %s?';
L['Are you sure you want to regenerate the keyboard dictionary? You will lose all custom phrases.'] = '¿Seguro que quieres regenerar el diccionario del teclado? Perderás todas las frases personalizadas.';
L['Are you sure you want to reset all device profiles?'] = '¿Seguro que quieres restablecer todos los perfiles de dispositivo?';
L['Are you sure you want to reset the keyboard layout?'] = '¿Seguro que quieres restablecer el diseño del teclado?';
L['Are you sure you want to reset your device profile?'] = '¿Seguro que quieres restablecer tu perfil de dispositivo?';
L['Are you sure you want to wipe the keyboard dictionary? It currently contains %d words.'] = '¿Seguro que quieres borrar el diccionario del teclado? Actualmente contiene %d palabras.';
L['Area where the interact key can find a suitable target.'] = 'Área donde la tecla de interacción puede encontrar un objetivo adecuado.';
L['Artwork flavor.'] = 'Variante de artwork.';
L['Artwork for the interface.'] = 'Artwork para la interfaz.';
L['Artwork style.'] = 'Estilo de artwork.';
L['Assign or clear bindings for this set.'] = 'Asignar o borrar asignaciones para este conjunto.';
L['Auto-adjusts your camera, allowing you to control movement with a single stick.'] = 'Ajusta automáticamente tu cámara, permitiéndote controlar el movimiento con un solo stick.';
L['Auto-Sell Gear Level Limit'] = 'Límite de nivel de equipo para autoventa';
L['Auto-Sell Junk'] = 'Vender basura automáticamente';
L['Auto-set target to match soft target.'] = 'Establecer automáticamente el objetivo para coincidir con el objetivo flexible.';
L['Automatic Binding Backups'] = 'Copias de seguridad automáticas de asignaciones';
L['Automatic Cursor Timeout'] = 'Tiempo de espera automático del cursor';
L['Automatic Tooltip Duration'] = 'Duración automática de información';
L['Automatically add tracked quest items and extra spells to main utility ring.'] = 'Añadir automáticamente objetos de misión rastreados y hechizos extra al menú radial principal de utilidad.';
L['Automatically backup your bindings when you change them, for import and export.'] = 'Hacer copia de seguridad automática de tus asignaciones al cambiarlas, para importar y exportar.';
L['Automatically Bind Extra Items'] = 'Asignar automáticamente objetos extra';
L['Automatically Control Cursor Pickups'] = 'Controlar automáticamente cogidas del cursor';
L['Automatically control cursor when picking up items.'] = 'Controlar automáticamente el cursor al coger objetos.';
L['Automatically disabled if an inactive component is clicked from a macro.'] = 'Se desactiva automáticamente si se hace clic en un componente inactivo desde una macro.';
L['Automatically sell junk when interacting with a merchant.'] = 'Vender basura automáticamente al interactuar con un comerciante.';
L['Axis Interpretation'] = 'Interpretación de eje';
L['Battery Level'] = 'Nivel de batería';
L['Binding Catch Timeframe'] = 'Plazo de captura de asignación';
L['Blend Mode'] = 'Modo de mezcla';
L['Blend mode of the artwork.'] = 'Modo de mezcla del artwork.';
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
L['Border Vertex Color'] = 'Color de vértice del borde';
L['Breadth'] = 'Anchura';
L['Breadth of the divider.'] = 'Anchura del separador.';
L['Button %d'] = 'Botón %d';
L['Button Set'] = 'Conjunto de botones';
L['Button that emulates '] = 'Botón que emula ';
L['Button that emulates the '] = 'Botón que emula la ';
L['Button to cancel or exit the quick menu.'] = 'Botón para cancelar o salir del menú rápido.';
L['Button to handle cancel actions, such as exiting menus.'] = 'Botón para gestionar acciones de cancelación, como salir de menús.';
L['Button to handle contextual actions, such as adding items to the utility ring or passing on loot.'] = 'Botón para gestionar acciones contextuales, como añadir objetos al menú radial de utilidad o pasar en el botín.';
L['Button to handle contextual actions, such as adding items to the utility ring.'] = 'Botón para gestionar acciones contextuales, como añadir objetos al menú radial de utilidad.';
L['Button to insert suggested word.'] = 'Botón para insertar palabra sugerida.';
L['Button to move the cursor down.'] = 'Botón para mover el cursor hacia abajo.';
L['Button to move the cursor left.'] = 'Botón para mover el cursor a la izquierda.';
L['Button to move the cursor right.'] = 'Botón para mover el cursor a la derecha.';
L['Button to move the cursor up.'] = 'Botón para mover el cursor hacia arriba.';
L['Button to replicate left click. This is the primary interface action.'] = 'Botón para replicar el clic izquierdo. Esta es la acción principal de interfaz.';
L['Button to replicate right click. This is the secondary interface action.'] = 'Botón para replicar el clic derecho. Esta es la acción secundaria de interfaz.';
L['Button to select next suggested word.'] = 'Botón para seleccionar la siguiente palabra sugerida.';
L['Button to select previous suggested word.'] = 'Botón para seleccionar la palabra sugerida anterior.';
L['Button to use for combo hotkey 1.'] = 'Botón a usar para combo 1.';
L['Button to use for combo hotkey 2.'] = 'Botón a usar para combo 2.';
L['Button to use for combo hotkey 3.'] = 'Botón a usar para combo 3.';
L['Button to use for combo hotkey 4.'] = 'Botón a usar para combo 4.';
L['Button to use for combo hotkey 5.'] = 'Botón a usar para combo 5.';
L['Button to use for combo hotkey 6.'] = 'Botón a usar para combo 6.';
L['Button to use for combo hotkey 7.'] = 'Botón a usar para combo 7.';
L['Button to use for combo hotkey 8.'] = 'Botón a usar para combo 8.';
L['Button to use to erase characters.'] = 'Botón a usar para borrar caracteres.';
L['Button to use to move the cursor leftwards.'] = 'Botón a usar para mover el cursor a la izquierda.';
L['Button to use to move the cursor rightwards.'] = 'Botón a usar para mover el cursor a la derecha.';
L['Button to use to trigger the enter command.'] = 'Botón a usar para activar la orden Enter.';
L['Button to use to trigger the escape command.'] = 'Botón a usar para activar la orden Escape.';
L['Button to use to trigger the space command.'] = 'Botón a usar para activar la orden Espacio.';
L['Button used to confirm a selected item from a ring.'] = 'Botón usado para confirmar un objeto seleccionado de un menú radial.';
L['Button used to remove a selected item from an editable ring.'] = 'Botón usado para eliminar un objeto seleccionado de un menú radial editable.';
L['Button |cFF00FFFF%s|r'] = 'Botón |cFF00FFFF%s|r';
L['Buttons'] = 'Botones';
L['Buttons emulating modifiers will instead trigger bindings when pressed and released within the time span.'] = 'Los botones que emulan modificadores activarán asignaciones cuando se pulsen y suelten dentro del plazo.';
L['Buttons in the cluster bar.'] = 'Botones de la barra clúster.';
L['Buttons in the group.'] = 'Botones del grupo.';
L['By default, shows modifiers on mouseover and on cooldown.'] = 'Por defecto, muestra modificadores al pasar el ratón y en tiempo de reutilización.';
L['Camera 2D Deadzone'] = 'Zona muerta 2D de cámara';
L['Camera Look'] = 'Mirada de cámara';
L['Camera Look is a temporary turn of the camera based on the current analog input.'] = 'La mirada de cámara es un giro temporal de la cámara basado en la entrada analógica actual.';
L['Camera Pitch Axis'] = 'Eje de cabeceo de cámara';
L['Camera Pitch Speed'] = 'Velocidad de cabeceo de cámara';
L['Camera Pitch-Only Deadzone'] = 'Zona muerta de solo cabeceo de cámara';
L['Camera speed for pitch - moving up/down.'] = 'Velocidad de cámara para cabeceo — mover arriba/abajo.';
L['Camera speed for yaw - turning left/right.'] = 'Velocidad de cámara para guiñada — girar izquierda/derecha.';
L['Camera Yaw Axis'] = 'Eje de guiñada de cámara';
L['Camera Yaw Speed'] = 'Velocidad de guiñada de cámara';
L['Camera Yaw-Only Deadzone'] = 'Zona muerta de solo guiñada de cámara';
L['Cancel and clear cursor'] = 'Cancelar y borrar cursor';
L['Cancel Button'] = 'Botón Cancelar';
L['Cannot open configuration menu in combat.'] = 'No se puede abrir el menú de configuración en combate.';
L['Casting Bar'] = 'Barra de lanzamiento';
L['Center Gap'] = 'Hueco central';
L['Center gap, as fraction of overall crosshair size.'] = 'Hueco central, como fracción del tamaño global de la mira.';
L['Change before touchpad moves the cursor.'] = 'Umbral antes de que el panel táctil mueva el cursor.';
L['Change bluetooth state for active device.'] = 'Cambiar estado Bluetooth para el dispositivo activo.';
L['Change or print a value from the active device configuration.'] = 'Cambiar o imprimir un valor de la configuración del dispositivo activo.';
L['Character Specific'] = 'Específico del personaje';
L['Choose a negative value to invert the axis.'] = 'Elige un valor negativo para invertir el eje.';
L['Class Bar'] = 'Barra de clase';
L['Class Colored Health'] = 'Salud con color de clase';
L['Clear all items from this set.'] = 'Vaciar todos los objetos de este conjunto.';
L['Clear Binding'] = 'Borrar asignación';
L['Clear configured gamepad bindings and reload interface.'] = 'Borrar asignaciones de mando configuradas y recargar la interfaz.';
L['Clear Focus Deadzone'] = 'Zona muerta para borrar foco';
L['Clear Focus Mode'] = 'Modo de borrado de foco';
L['Clear Focus Time'] = 'Tiempo de borrado de foco';
L['Clear Slot'] = 'Vaciar ranura';
L['Clear slot or binding'] = 'Vaciar ranura o asignación';
L['Click here to reset your device profile.'] = 'Haz clic aquí para restablecer tu perfil de dispositivo.';
L['Click on Down'] = 'Clic al pulsar';
L['Click Override Button'] = 'Botón de sustitución de clic';
L['Click Override Condition'] = 'Condición de sustitución de clic';
L['Cluster Action Bar'] = 'Barra de acción clúster';
L['Cluster Handle'] = 'Asa del clúster';
L['Cluster Modifier Toggle'] = 'Alternar modificador de clúster';
L['Clusters'] = 'Clústeres';
L['Color accent of radial menu items.'] = 'Acento de color de los elementos del menú radial.';
L['Color of a partially selected slice.'] = 'Color de un trozo parcialmente seleccionado.';
L['Color of the active slice.'] = 'Color del trozo activo.';
L['Color of the cooldown swipe effect on buttons.'] = 'Color del efecto de barrido de tiempo de reutilización en los botones.';
L['Color of the counter text on buttons.'] = 'Color del texto del contador en los botones.';
L['Color of the crosshair.'] = 'Color de la mira.';
L['Color of the divider.'] = 'Color del separador.';
L['Color of the hotkey text on buttons.'] = 'Color del texto de tecla rápida en los botones.';
L['Color of the macro text on buttons.'] = 'Color del texto de macro en los botones.';
L['Color of the main XP bar.'] = 'Color de la barra principal de XP.';
L['Color of the mana indicator on buttons.'] = 'Color del indicador de maná en los botones.';
L['Color of the range indicator on buttons.'] = 'Color del indicador de alcance en los botones.';
L['Color of the sticky selection slice.'] = 'Color del trozo de selección pegajosa.';
L['Color of the vertices on the border of buttons.'] = 'Color de los vértices en el borde de los botones.';
L['Color the health bars in the target ring by class.'] = 'Colorea las barras de salud del menú radial de objetivo según la clase.';
L['Color tint for combo hotkey 1.'] = 'Tinte de color para combo 1.';
L['Color tint for combo hotkey 2.'] = 'Tinte de color para combo 2.';
L['Color tint for combo hotkey 3.'] = 'Tinte de color para combo 3.';
L['Color tint for combo hotkey 4.'] = 'Tinte de color para combo 4.';
L['Color tint for combo hotkey 5.'] = 'Tinte de color para combo 5.';
L['Color tint for combo hotkey 6.'] = 'Tinte de color para combo 6.';
L['Color tint for combo hotkey 7.'] = 'Tinte de color para combo 7.';
L['Color tint for combo hotkey 8.'] = 'Tinte de color para combo 8.';
L['Combine with '] = 'Combinar con ';
L['Combine with use on demand for full cursor control.'] = 'Combina con uso bajo demanda para control completo del cursor.';
L['Combined Input Overlap Time'] = 'Tiempo de solapamiento de entrada combinada';
L['Combo Button 1'] = 'Botón combo 1';
L['Combo Button 2'] = 'Botón combo 2';
L['Combo Button 3'] = 'Botón combo 3';
L['Combo Button 4'] = 'Botón combo 4';
L['Combo Button 5'] = 'Botón combo 5';
L['Combo Button 6'] = 'Botón combo 6';
L['Combo Button 7'] = 'Botón combo 7';
L['Combo Button 8'] = 'Botón combo 8';
L['Combo Color 1'] = 'Color combo 1';
L['Combo Color 2'] = 'Color combo 2';
L['Combo Color 3'] = 'Color combo 3';
L['Combo Color 4'] = 'Color combo 4';
L['Combo Color 5'] = 'Color combo 5';
L['Combo Color 6'] = 'Color combo 6';
L['Combo Color 7'] = 'Color combo 7';
L['Combo Color 8'] = 'Color combo 8';
L['Command Modifier'] = 'Modificador de orden';
L['Configure the casting bar.'] = 'Configurar la barra de lanzamiento.';
L['Configure the class related bar.'] = 'Configurar la barra relacionada con la clase.';
L['Connect your controller.'] = 'Conecta tu mando.';
L['Connected device(s):'] = 'Dispositivo(s) conectado(s):';
L['ConsolePort'] = 'ConsolePort';
L['Context Button'] = 'Botón de contexto';
L['Controls the cutoff range where an interactable target or object can be found.'] = 'Controla el rango de corte donde se puede encontrar un objetivo u objeto interactivo.';
L['Controls when your character starts running. Expressed as a fraction of your total movement stick radius.'] = 'Controla cuándo tu personaje empieza a correr. Expresado como fracción del radio total de tu stick de movimiento.';
L['Copy %s from %s:'] = 'Copiar %s de %s:';
L['Copy this element to a new name.'] = 'Copiar este elemento con un nombre nuevo.';
L['Correlation between stick position and pie selection.'] = 'Correlación entre posición del stick y selección en la rueda.';
L['Create Binding Preset'] = 'Crear preajuste de asignaciones';
L['Critical, Low, Medium, High, Wired/Charging, or Unknown/Disconnected.'] = 'Crítico, Bajo, Medio, Alto, Cargando con cable o Desconocido/Desconectado.';
L['Crossbar: Minimal'] = 'Crossbar: Mínima';
L['Crossbar: Triggers'] = 'Crossbar: Gatillos';
L['Crossbar: Triple'] = 'Crossbar: Triple';
L['Crosshair'] = 'Mira';
L['Cursor Acceleration'] = 'Aceleración del cursor';
L['Cursor acceleration for touchpad control.'] = 'Aceleración del cursor para control con panel táctil.';
L['Cursor appears on demand, instead of in response to a panel showing up.'] = 'El cursor aparece bajo demanda, en lugar de responder a la aparición de un panel.';
L['Cursor Center Position'] = 'Posición central del cursor';
L['Cursor hides when you start moving, if free of obstacles.'] = 'El cursor se oculta cuando empiezas a moverte, si no hay obstáculos.';
L['Cursor Max Speed'] = 'Velocidad máxima del cursor';
L['Cursor Move Threshold'] = 'Umbral de movimiento del cursor';
L['Cursor Reticle Targeting'] = 'Selección de objetivo por mira del cursor';
L['Cursor Speed'] = 'Velocidad del cursor';
L['Cursor speed for touchpad control.'] = 'Velocidad del cursor para control con panel táctil.';
L['Cursor Start Speed'] = 'Velocidad inicial del cursor';
L['Custom color to use for the touchpad LED.'] = 'Color personalizado para el LED del panel táctil.';
L['Cyan'] = 'Cian';
L['Deadzone for simple point-to-select rings.'] = 'Zona muerta para menús radiales simples de apuntar y seleccionar.';
L['Deadzone to clear focus after intercepting stick input.'] = 'Zona muerta para borrar el foco tras interceptar la entrada del stick.';
L['Decrease'] = 'Disminuir';
L['Decrease lightness'] = 'Disminuir luminosidad';
L['Decrease opacity'] = 'Disminuir opacidad';
L['Default to '] = 'Por defecto a ';
L['Delay before reactivating interface cursor after leaving combat, in seconds.'] = 'Retardo antes de reactivar el cursor de interfaz tras salir de combate, en segundos.';
L['Delay before starting to adjust angle when camera control is idle, in seconds.'] = 'Retardo antes de empezar a ajustar el ángulo cuando el control de cámara está inactivo, en segundos.';
L['Delay is doubled if you are dead.'] = 'El retardo se duplica si estás muerto.';
L['Delay until a movement is repeated, when holding down a direction, in seconds.'] = 'Retardo hasta que un movimiento se repite, al mantener pulsada una dirección, en segundos.';
L['Delay until the first movement is repeated, when holding down a direction, in seconds.'] = 'Retardo hasta que se repite el primer movimiento, al mantener pulsada una dirección, en segundos.';
L['Delete this element.'] = 'Eliminar este elemento.';
L['Depth'] = 'Profundidad';
L['Depth of the divider.'] = 'Profundidad del separador.';
L['Detected %d out of 8 possible sensors.'] = 'Detectados %d de 8 sensores posibles.';
L['Detected %d valid button(s).'] = 'Detectado(s) %d botón(es) válido(s).';
L['Device Information'] = 'Información del dispositivo';
L['Device Mappings'] = 'Asignaciones del dispositivo';
L['Device Profiles'] = 'Perfiles de dispositivo';
L['Device Selection'] = 'Selección de dispositivo';
L['Device Settings'] = 'Ajustes del dispositivo';
L['Diamond Grid'] = 'Rejilla en rombo';
L['Dictionary Match Alphabet'] = 'Alfabeto de coincidencia de diccionario';
L['Dictionary Match Pattern'] = 'Patrón de coincidencia de diccionario';
L['Direction for flyout buttons, such as portals, poisons, and pet utilities.'] = 'Dirección para botones desplegables, como portales, venenos y utilidades de mascota.';
L['Direction of the button cluster.'] = 'Dirección del clúster de botones.';
L['Disable Drag and Drop'] = 'Desactivar arrastrar y soltar';
L['Disable dragging and dropping abilities on action bars.'] = 'Desactivar arrastrar y soltar habilidades en las barras de acción.';
L['Disable free-roaming mouse cursor when you jump.'] = 'Desactivar el cursor de ratón libre cuando saltas.';
L['Disable free-roaming mouse cursor when you use your sticks.'] = 'Desactivar el cursor de ratón libre cuando usas tus sticks.';
L['Disable Hotkey Rendering'] = 'Desactivar renderizado de teclas rápidas';
L['Disable if your mouse cursor is invisible.'] = 'Desactiva si tu cursor de ratón es invisible.';
L['Disable repeated cursor movements - each click will only move the cursor once.'] = 'Desactivar movimientos repetidos del cursor — cada clic moverá el cursor solo una vez.';
L['Disable Repeated Movement'] = 'Desactivar movimiento repetido';
L['Disable to use discrete legacy movement controls.'] = 'Desactiva para usar controles de movimiento heredados discretos.';
L['Disable Wrapping'] = 'Desactivar envoltura';
L['Disables customization to hotkeys on regular action bars.'] = 'Desactiva la personalización de teclas rápidas en barras de acción normales.';
L['Disabling this may cause worse performance with many panels open.'] = 'Desactivar esto puede causar peor rendimiento con muchos paneles abiertos.';
L['Disconnected'] = 'Desconectado';
L['Discord'] = 'Discord';
L['Display icon next to the power level for the current active gamepad.'] = 'Mostrar icono junto al nivel de batería del mando activo actual.';
L['Display power level for the current active gamepad.'] = 'Mostrar nivel de batería del mando activo actual.';
L['Display power level status text for the current active gamepad.'] = 'Mostrar texto de estado del nivel de batería del mando activo actual.';
L['Display the action bar grid when picking up a spell on the cursor.'] = 'Mostrar la cuadrícula de la barra de acción al coger un hechizo en el cursor.';
L['Displays a briefing for newly acquired abilities.'] = 'Muestra un resumen para habilidades recién adquiridas.';
L['Divider'] = 'Separador';
L['Do you want to load settings for %s?'] = '¿Quieres cargar los ajustes para %s?';
L['Does not affect actual ability to interact with the target, which may have a different range.'] = 'No afecta a la capacidad real de interactuar con el objetivo, que puede tener un rango diferente.';
L['Donate via PayPal'] = 'Donar mediante PayPal';
L['Double Tap Modifier'] = 'Modificador de doble pulsación';
L['Double Tap Timeframe'] = 'Plazo de doble pulsación';
L['Duration after using gamepad and mouse at the same time before switching to just one or the other, in milliseconds.'] = 'Duración tras usar mando y ratón al mismo tiempo antes de cambiar a solo uno u otro, en milisegundos.';
L['Duration under which a tooltip is displayed for an acquired target or interactable, in milliseconds.'] = 'Duración durante la cual se muestra información para un objetivo u objeto interactivo adquirido, en milisegundos.';
L['Dynamic Pitch'] = 'Cabeceo dinámico';
L['Dynamic will use the button set that does not conflict with your '] = '«Dinámico» usará el conjunto de botones que no entre en conflicto con tu ';
L['E.g. '] = 'P. ej. ';
L['Edit Binding'] = 'Editar asignación';
L['Edit Slot'] = 'Editar ranura';
L['Emulate P1 '] = 'Emular P1 ';
L['Emulate P2 '] = 'Emular P2 ';
L['Emulate P3 '] = 'Emular P3 ';
L['Emulate P4 '] = 'Emular P4 ';
L['Emulate Pad 5'] = 'Emular Pad 5';
L['Emulate Pad 6'] = 'Emular Pad 6';
L['Emulate Pad Back'] = 'Emular Atrás';
L['Emulate Pad Forward'] = 'Emular Adelante';
L['Emulate Pad Social'] = 'Emular Social';
L['Emulate Pad System'] = 'Emular Sistema';
L['Enable all modifier states for the cluster, including unmapped modifiers.'] = 'Activar todos los estados de modificador para el clúster, incluyendo modificadores no mapeados.';
L['Enable Animation'] = 'Activar animación';
L['Enable casting bar ownership.'] = 'Activar propiedad de la barra de lanzamiento.';
L['Enable class bar ownership.'] = 'Activar propiedad de la barra de clase.';
L['Enable Cooldown Numbers'] = 'Activar números de tiempo de reutilización';
L['Enable Group Loot'] = 'Activar botín de grupo';
L['Enable interact key to interact with objects and creatures in the game world.'] = 'Activar tecla de interacción para interactuar con objetos y criaturas del mundo del juego.';
L['Enable interface cursor. Disable to use mouse-based interface interaction.'] = 'Activar cursor de interfaz. Desactivar para usar interacción de interfaz basada en ratón.';
L['Enable Lazy Loading'] = 'Activar carga diferida';
L['Enable Mouse Handling'] = 'Activar gestión del ratón';
L['Enable Player Interact'] = 'Activar interactuar con jugador';
L['Enable Popups'] = 'Activar popups';
L['Enable separate strafe angle threshold for when your character is in the air.'] = 'Activar umbral de ángulo de movimiento lateral separado para cuando tu personaje está en el aire.';
L['Enable Strafe Angle (Jump)'] = 'Activar ángulo de movimiento lateral (salto)';
L['Enable Tint'] = 'Activar tinte';
L['Enable touch tap to press touchpad buttons.'] = 'Activar pulsación táctil para pulsar los botones del panel táctil.';
L['Enable Touchpad Cursor'] = 'Activar cursor del panel táctil';
L['Enable Vehicle'] = 'Activar vehículo';
L['Enable Watch Bars'] = 'Activar barras de seguimiento';
L['Enables a crosshair to reveal your hidden center cursor position at all times.'] = 'Activa una mira para revelar la posición de tu cursor centrado oculto en todo momento.';
L['Enables a radial on-screen keyboard that can be used to type messages.'] = 'Activa un teclado radial en pantalla que puede usarse para escribir mensajes.';
L['Enemy Soft Targeting'] = 'Selección flexible de enemigos';
L['Equippable items of poor quality will not be sold while your character is below this level.'] = 'Los objetos equipables de mala calidad no se venderán mientras tu personaje esté por debajo de este nivel.';
L['Erase'] = 'Borrar';
L['Exit the vehicle you are currently controlling.'] = 'Salir del vehículo que estás controlando actualmente.';
L['Export'] = 'Exportar';
L['Export %s to a string:'] = 'Exportar %s a una cadena:';
L['Export action page logic'] = 'Exportar lógica de página de acción';
L['Export All'] = 'Exportar todo';
L['Export all your custom presets to a string that can be shared with others.'] = 'Exportar todos tus preajustes personalizados a una cadena que puede compartirse con otros.';
L['Export current options'] = 'Exportar opciones actuales';
L['Export serialized settings for sharing or backup.'] = 'Exportar ajustes serializados para compartir o respaldar.';
L['Export this preset to a string that can be shared with others.'] = 'Exportar este preajuste a una cadena que puede compartirse con otros.';
L['Expressed in milliseconds. Pressing any combination of modifier and button will cancel the effect.'] = 'Expresado en milisegundos. Pulsar cualquier combinación de modificador y botón cancelará el efecto.';
L['Fade Buttons'] = 'Atenuar botones';
L['Fade out the pet ring when not moused over.'] = 'Atenuar el menú radial de mascota cuando no se pasa el ratón por encima.';
L['Fade out the watch bars when not mousing over the toolbar.'] = 'Atenuar las barras de seguimiento cuando no se pasa el ratón sobre la barra de herramientas.';
L['Fade Watch Bars'] = 'Atenuar barras de seguimiento';
L['Filter Condition'] = 'Condición de filtro';
L['Filter condition to find raid cursor frames, as a boolean expression in Lua.'] = 'Condición de filtro para encontrar marcos del cursor de banda, como expresión booleana en Lua.';
L['Flavor'] = 'Variante';
L['Flyout Direction'] = 'Dirección desplegable';
L['FOAS Adjust Delay'] = 'Retardo de ajuste FOAS';
L['FOAS Adjust Ease In'] = 'Inicio gradual FOAS';
L['Follow On A Stick (FOAS)'] = 'Seguir con un stick (FOAS)';
L['Font Flags'] = 'Atributos de fuente';
L['Font flags of the counter text on buttons.'] = 'Atributos de fuente del texto del contador en los botones.';
L['Font flags of the hotkey text on buttons.'] = 'Atributos de fuente del texto de tecla rápida en los botones.';
L['Font flags of the macro text on buttons.'] = 'Atributos de fuente del texto de macro en los botones.';
L['Font size of the counter text on buttons.'] = 'Tamaño de fuente del texto del contador en los botones.';
L['Font size of the hotkey text on buttons.'] = 'Tamaño de fuente del texto de tecla rápida en los botones.';
L['Font size of the macro text on buttons.'] = 'Tamaño de fuente del texto de macro en los botones.';
L['Font size of the ring slice buttons.'] = 'Tamaño de fuente de los botones de trozo del menú radial.';
L['Force Hard Target'] = 'Forzar objetivo fijo';
L['Frame level of the element.'] = 'Nivel de marco del elemento.';
L['Frame Level Offset'] = 'Desplazamiento de nivel de marco';
L['Frame level offset of the hotkey prompt, relative to the unit frame.'] = 'Desplazamiento del nivel de marco del aviso de tecla rápida, relativo al marco de unidad.';
L['Frame strata of the element.'] = 'Estrato del marco del elemento.';
L['Free Cursor Timein'] = 'Aparición de cursor libre';
L['Frees your mouse cursor when used, if the cursor is currently center-fixed or hidden.'] = 'Libera tu cursor de ratón al usarlo, si el cursor está actualmente fijo en el centro u oculto.';
L['Friend Soft Targeting'] = 'Selección flexible de amigos';
L['Full State Modifier'] = 'Modificador de estado completo';
L['Global color of the tint effect on the toolbar and dividers.'] = 'Color global del efecto de tinte en la barra de herramientas y los separadores.';
L['Global Scale'] = 'Escala global';
L['Global Visibility'] = 'Visibilidad global';
L['Green'] = 'Verde';
L['Grid'] = 'Rejilla';
L['Group buttons by modifier in a diamond layout.'] = 'Agrupar botones por modificador en un diseño en rombo.';
L['Group buttons by modifier in a grid layout.'] = 'Agrupar botones por modificador en un diseño en rejilla.';
L['Group buttons for left and right triggers, with modifier swapping.'] = 'Agrupar botones para los gatillos izquierdo y derecho, con intercambio de modificador.';
L['Group buttons in a single crossbar layout, with modifier swapping.'] = 'Agrupar botones en un único diseño crossbar, con intercambio de modificador.';
L['Group buttons in three layouts, with modifier swapping.'] = 'Agrupar botones en tres diseños, con intercambio de modificador.';
L['Height of the artwork.'] = 'Altura del artwork.';
L['Height of the cluster bar.'] = 'Altura de la barra clúster.';
L['Height of the crosshair, in scaled pixel units.'] = 'Altura de la mira, en unidades de píxel escaladas.';
L['Height of the group.'] = 'Altura del grupo.';
L['Hide Cursor on Jump'] = 'Ocultar cursor al saltar';
L['Hide Cursor On Movement'] = 'Ocultar cursor al moverse';
L['Hide Cursor on Stick Input'] = 'Ocultar cursor con entrada del stick';
L['Hide Flyout Buttons'] = 'Ocultar botones desplegables';
L['Hide Macro Text'] = 'Ocultar texto de macro';
L['Hide the class bar.'] = 'Ocultar la barra de clase.';
L['Hide the macro text on buttons.'] = 'Ocultar el texto de macro en los botones.';
L['Higher is slower.'] = 'Más alto es más lento.';
L['Higher values appear on top of lower values. Valid range 0-10000.'] = 'Valores más altos aparecen sobre valores más bajos. Rango válido 0-10000.';
L['Highlight Color'] = 'Color de resaltado';
L['Horizontal Offset'] = 'Desplazamiento horizontal';
L['Horizontal offset from anchor point.'] = 'Desplazamiento horizontal desde el punto de anclaje.';
L['Horizontal offset of the counter text on buttons.'] = 'Desplazamiento horizontal del texto del contador en los botones.';
L['Horizontal offset of the hotkey icon on group buttons.'] = 'Desplazamiento horizontal del icono de tecla rápida en botones de grupo.';
L['Horizontal offset of the hotkey prompt position, in pixels.'] = 'Desplazamiento horizontal de la posición del aviso de tecla rápida, en píxeles.';
L['Horizontal offset of the hotkey text on buttons.'] = 'Desplazamiento horizontal del texto de tecla rápida en los botones.';
L['Horizontal offset of the macro text on buttons.'] = 'Desplazamiento horizontal del texto de macro en los botones.';
L['Horizontal Padding'] = 'Relleno horizontal';
L['Hotkey Anchor'] = 'Anclaje de tecla rápida';
L['Hotkey Offset X'] = 'Desplazamiento X de tecla rápida';
L['Hotkey Offset Y'] = 'Desplazamiento Y de tecla rápida';
L['Hotkey prompts appear on applicable name plates.'] = 'Los avisos de tecla rápida aparecen en las placas de nombre aplicables.';
L['Hotkey prompts linger on unit frames after targeting.'] = 'Los avisos de tecla rápida permanecen en los marcos de unidad tras seleccionar objetivo.';
L['Hotkey Relative Anchor'] = 'Anclaje relativo de tecla rápida';
L['Hotkey Size'] = 'Tamaño de tecla rápida';
L['Hotkeys activate their target immediately.'] = 'Las teclas rápidas activan su objetivo inmediatamente.';
L['Hotkeys always target the same unit.'] = 'Las teclas rápidas siempre apuntan a la misma unidad.';
L['Hotkeys control your focus target instead of your current target.'] = 'Las teclas rápidas controlan tu objetivo de foco en lugar de tu objetivo actual.';
L['Hotkeys use '] = 'Las teclas rápidas usan ';
L['How long the cursor should take to transition from one node to another.'] = 'Cuánto debería tardar el cursor en pasar de un nodo a otro.';
L['How to clear focus after intercepting stick input.'] = 'Cómo borrar el foco tras interceptar la entrada del stick.';
L['Import serialized preset(s) from an external source.'] = 'Importar preajuste(s) serializado(s) de una fuente externa.';
L['Import serialized preset(s):'] = 'Importar preajuste(s) serializado(s):';
L['Import serialized settings from an external source.'] = 'Importar ajustes serializados de una fuente externa.';
L['Inactive Opacity'] = 'Opacidad inactiva';
L['Include the current action page logic in the preset data.'] = 'Incluir la lógica de página de acción actual en los datos del preajuste.';
L['Include the current options from the %s tab in the preset data.'] = 'Incluir las opciones actuales de la pestaña %s en los datos del preajuste.';
L['Increase'] = 'Aumentar';
L['Increase lightness'] = 'Aumentar luminosidad';
L['Increase opacity'] = 'Aumentar opacidad';
L['Insert Suggestion'] = 'Insertar sugerencia';
L['Intensity'] = 'Intensidad';
L['Intensity of the gradient.'] = 'Intensidad del degradado.';
L['Interface Cursor'] = 'Cursor de interfaz';
L['Interference'] = 'Interferencia';
L['Inverted'] = 'Invertido';
L['Join Discord'] = 'Unirse a Discord';
L['Keeps your character centered to reduce motion sickness.'] = 'Mantiene a tu personaje centrado para reducir el mareo por movimiento.';
L['Key %d'] = 'Tecla %d';
L['Keyboard button to emulate the back button.'] = 'Tecla de teclado para emular el botón atrás.';
L['Keyboard button to emulate the forward button.'] = 'Tecla de teclado para emular el botón adelante.';
L['Keyboard button to emulate the pad 5 button.'] = 'Tecla de teclado para emular el botón pad 5.';
L['Keyboard button to emulate the pad 6 button.'] = 'Tecla de teclado para emular el botón pad 6.';
L['Keyboard button to emulate the social button.'] = 'Tecla de teclado para emular el botón social.';
L['Keyboard button to emulate the system button.'] = 'Tecla de teclado para emular el botón de sistema.';
L['Keyboard'] = 'Teclado';
L['Keyboard button to emulate the paddle 1 button.'] = 'Tecla de teclado para emular el botón paleta 1.';
L['Keyboard button to emulate the paddle 2 button.'] = 'Tecla de teclado para emular el botón paleta 2.';
L['Keyboard button to emulate the paddle 3 button.'] = 'Tecla de teclado para emular el botón paleta 3.';
L['Keyboard button to emulate the paddle 4 button.'] = 'Tecla de teclado para emular el botón paleta 4.';
L['Keyboard Layout Editor'] = 'Editor de disposición de teclado';
L['Larger value for easier taps.'] = 'Valor mayor para pulsaciones más fáciles.';
L['Layout'] = 'Disposición';
L['Lazy loading has been disabled to activate the raid cursor.'] = 'La carga diferida se ha desactivado para activar el cursor de banda.';
L['Lazy loading has been disabled to activate the target ring.'] = 'La carga diferida se ha desactivado para activar el menú radial de objetivo.';
L['Lazy loading has been disabled to activate unit hotkeys.'] = 'La carga diferida se ha desactivado para activar las teclas rápidas de unidad.';
L['LED Color Type'] = 'Tipo de color LED';
L['LED Custom Color'] = 'Color LED personalizado';
L['Load'] = 'Cargar';
L['Loaded binding preset %s.'] = 'Preajuste de asignaciones %s cargado.';
L['Loadout'] = 'Loadout';
L['Lock Automatic Tooltip'] = 'Bloquear información automática';
L['Looks like a regular action bar, but shows the button combination rather than the action slot.'] = 'Parece una barra de acción normal, pero muestra la combinación de botones en lugar de la ranura de acción.';
L['Lua pattern to match words for dictionary lookups.'] = 'Patrón Lua para coincidir con palabras para búsquedas de diccionario.';
L['Macro condition to automatically load a binding preset by name when the condition applies.'] = 'Condición de macro para cargar automáticamente un preajuste de asignaciones por nombre cuando la condición se cumple.';
L['Macro condition to evaluate action bar page.'] = 'Condición de macro para evaluar la página de barra de acción.';
L['Macro condition to override the strafe angle threshold for combat.'] = 'Condición de macro para sustituir el umbral de ángulo de movimiento lateral en combate.';
L['Macro condition to override the strafe angle threshold for travel.'] = 'Condición de macro para sustituir el umbral de ángulo de movimiento lateral en viaje.';
L['Macro Text'] = 'Texto de macro';
L['Main Button Border Style'] = 'Estilo de borde del botón principal';
L['Maintain offset relative to scale.'] = 'Mantener el desplazamiento relativo a la escala.';
L['Make sure your choice does not conflict with your bindings.'] = 'Asegúrate de que tu elección no entre en conflicto con tus asignaciones.';
L['Make this preset the default layout for all new characters.'] = 'Convertir este preajuste en el diseño por defecto para todos los personajes nuevos.';
L['Match appropriate soft target to locked target.'] = 'Hacer coincidir el objetivo flexible apropiado con el objetivo fijo.';
L['Max Pitch'] = 'Cabeceo máx.';
L['Max time for a touch to register a tap/click, in milliseconds.'] = 'Tiempo máximo para que un toque registre una pulsación/clic, en milisegundos.';
L['Max Yaw'] = 'Guiñada máx.';
L['Maximum Pitch adjust for the camera "look" feature.'] = 'Ajuste máximo de cabeceo para la función «mirada» de la cámara.';
L['Maximum Yaw adjust for the camera "look" feature.'] = 'Ajuste máximo de guiñada para la función «mirada» de la cámara.';
L['Menu buttons to display on the toolbar.'] = 'Botones de menú a mostrar en la barra de herramientas.';
L['Micro Menu'] = 'Micromenú';
L['Minimal Interact Nameplate Tooltip'] = 'Información mínima de interactuar en placa de nombre';
L['Modifications'] = 'Modificaciones';
L['Modifier'] = 'Modificador';
L['Modifier 1: Shift'] = 'Modificador 1: Mayús';
L['Modifier 2: Ctrl'] = 'Modificador 2: Ctrl';
L['Modifier 3: Alt'] = 'Modificador 3: Alt';
L['Modifier Tap Window'] = 'Ventana de pulsación de modificador';
L['Modifiers'] = 'Modificadores';
L['Move Left'] = 'Mover a la izquierda';
L['Move one of the sticks.'] = 'Mueve uno de los sticks.';
L['Move Right'] = 'Mover a la derecha';
L['Movement Deadzone'] = 'Zona muerta de movimiento';
L['Movement is analog, translated from your movement stick angle.'] = 'El movimiento es analógico, traducido del ángulo de tu stick de movimiento.';
L['Movement X Axis'] = 'Eje X de movimiento';
L['Movement Y Axis'] = 'Eje Y de movimiento';
L['Needs to be long enough to press and release the button.'] = 'Necesita ser lo bastante largo para pulsar y soltar el botón.';
L['Nested Rings'] = 'Menús radiales anidados';
L['Next Word'] = 'Palabra siguiente';
L['No axis input detected yet.'] = 'Aún no se ha detectado entrada de eje.';
L['No binding preset named %s exists.'] = 'No existe ningún preajuste de asignaciones llamado %s.';
L['No button input detected yet.'] = 'Aún no se ha detectado entrada de botón.';
L['No buttons were detected during the test.'] = 'No se detectaron botones durante la prueba.';
L['No sensors were detected.'] = 'No se detectaron sensores.';
L['Normal background color of pie slices.'] = 'Color de fondo normal de los trozos de tarta.';
L['Normal Color'] = 'Color normal';
L['Nudge Modifier'] = 'Modificador de empuje';
L['Number of buttons in the page.'] = 'Número de botones en la página.';
L['Number of buttons per row or column.'] = 'Número de botones por fila o columna.';
L['Offset'] = 'Desplazamiento';
L['Offset of pointer arrow, from the selected node center, in pixels.'] = 'Desplazamiento de la flecha del puntero, desde el centro del nodo seleccionado, en píxeles.';
L['Offset X'] = 'Desplazamiento X';
L['Offset Y'] = 'Desplazamiento Y';
L['Offsets the camera horizontally from your character, for a more cinematic view.'] = 'Desplaza la cámara horizontalmente respecto a tu personaje, para una vista más cinematográfica.';
L['Only recommended for super users.'] = 'Solo recomendado para superusuarios.';
L['Only use taps for cursor clicks, do not use tap presses.'] = 'Usar solo pulsaciones para clics del cursor, no usar presiones de pulsación.';
L['Opacity of inactive hotkey prompts on unit frames after targeting.'] = 'Opacidad de avisos de tecla rápida inactivos en marcos de unidad tras seleccionar objetivo.';
L['Open Designer'] = 'Abrir Diseñador';
L['Open Main Config'] = 'Abrir Configuración principal';
L['Open the configuration menu for the action bar.'] = 'Abrir el menú de configuración de la barra de acción.';
L['Open the main configuration window.'] = 'Abrir la ventana principal de configuración.';
L['Open the main edit mode window.'] = 'Abrir la ventana principal de modo edición.';
L['Open the unit menu for the target unit.'] = 'Abrir el menú de unidad para la unidad objetivo.';
L['Open unit menu when interacting with other players.'] = 'Abrir el menú de unidad al interactuar con otros jugadores.';
L['Optimize Algorithm'] = 'Optimizar algoritmo';
L['or'] = 'o';
L['Orientation of the page.'] = 'Orientación de la página.';
L['Orthodox'] = 'Ortodoxo';
L['Out of Mana Color'] = 'Color de falta de maná';
L['Out of Range Color'] = 'Color de fuera de alcance';
L['Outcome'] = 'Resultado';
L['Over Shoulder'] = 'Sobre el hombro';
L['Override'] = 'Sustituir';
L['Override Class File'] = 'Archivo de clase de sustitución';
L['Override class theme for interface styling.'] = 'Sustituir el tema de clase para el estilo de interfaz.';
L['Padding between buttons horizontally.'] = 'Relleno entre botones horizontalmente.';
L['Padding between buttons vertically.'] = 'Relleno entre botones verticalmente.';
L['Page'] = 'Página';
L['Page Condition'] = 'Condición de página';
L['Page Hotkeys'] = 'Teclas rápidas de página';
L['Page Response'] = 'Respuesta de página';
L['Page |cFF00FFFF%s|r'] = 'Página |cFF00FFFF%s|r';
L['Patreon'] = 'Patreon';
L['PayPal'] = 'PayPal';
L['Performs an action and closes the menu.'] = 'Realiza una acción y cierra el menú.';
L['Performs an action without closing the menu.'] = 'Realiza una acción sin cerrar el menú.';
L['Pet Ring'] = 'Menú radial de mascota';
L['Pet Ring Stick'] = 'Stick del menú radial de mascota';
L['Pick up'] = 'Coger';
L['Pickup'] = 'Recoger';
L['Pitch Axis'] = 'Eje de cabeceo';
L['Pitch-only deadzone for camera, applied before the 2D deadzone.'] = 'Zona muerta de solo cabeceo para la cámara, aplicada antes de la zona muerta 2D.';
L['Pitches the camera upwards as you zoom out.'] = 'Inclina la cámara hacia arriba al alejar el zoom.';
L['Place in slot'] = 'Colocar en ranura';
L['Place on action bar'] = 'Colocar en barra de acción';
L['Play a sound when the pointer arrow reaches its destination.'] = 'Reproducir un sonido cuando la flecha del puntero alcance su destino.';
L['Please provide a unique name for a new %s in %s:'] = 'Por favor, proporciona un nombre único para un nuevo %s en %s:';
L['Plural Button'] = 'Botón plural';
L['Pointer arrow rotates in the direction of travel, and portraits scale up and down on movement.'] = 'La flecha del puntero rota en la dirección del movimiento, y los retratos se escalan hacia arriba y abajo al moverse.';
L['Pointer arrow rotates in the direction of travel.'] = 'La flecha del puntero rota en la dirección del movimiento.';
L['Pointer Offset'] = 'Desplazamiento del puntero';
L['Pointer Size'] = 'Tamaño del puntero';
L['Position'] = 'Posición';
L['Position of the artwork.'] = 'Posición del artwork.';
L['Position of the button cluster.'] = 'Posición del clúster de botones.';
L['Position of the button.'] = 'Posición del botón.';
L['Position of the class bar.'] = 'Posición de la barra de clase.';
L['Position of the cluster bar.'] = 'Posición de la barra clúster.';
L['Position of the divider.'] = 'Posición del separador.';
L['Position of the element.'] = 'Posición del elemento.';
L['Position of the group.'] = 'Posición del grupo.';
L['Position of the page.'] = 'Posición de la página.';
L['Position of the pet ring.'] = 'Posición del menú radial de mascota.';
L['Position of the toolbar.'] = 'Posición de la barra de herramientas.';
L['Power Level'] = 'Nivel de batería';
L['Preferred size of radial menus, in pixels.'] = 'Tamaño preferido de los menús radiales, en píxeles.';
L['Preset Load Condition'] = 'Condición de carga de preajuste';
L['Presets'] = 'Preajustes';
L['Press and Hold'] = 'Pulsar y mantener';
L['Press your gamepad buttons to test them.'] = 'Pulsa los botones de tu mando para probarlos.';
L['Prevent the cursor from wrapping when navigating.'] = 'Evitar que el cursor se envuelva al navegar.';
L['Previous Word'] = 'Palabra anterior';
L['Primary accept button, to use or confirm a quick menu action.'] = 'Botón principal de aceptar, para usar o confirmar una acción del menú rápido.';
L['Primary Button'] = 'Botón principal';
L['Primary Stick'] = 'Stick principal';
L['Prioritize raid cursor bindings over other override bindings.'] = 'Priorizar asignaciones del cursor de banda sobre otras asignaciones de sustitución.';
L['Priority Override'] = 'Prioridad de sustitución';
L['Purple'] = 'Morado';
L['Quick Menu'] = 'Menú rápido';
L['Radial Menus'] = 'Menús radiales';
L['Raid Cursor'] = 'Cursor de banda';
L['Re-apply config for the active device.'] = 'Volver a aplicar la configuración del dispositivo activo.';
L['Reactivation Delay'] = 'Retardo de reactivación';
L['Realm'] = 'Reino';
L['Recharge'] = 'Recarga';
L['Recommended as first choice modifier.'] = 'Recomendado como primera elección de modificador.';
L['Recommended as second choice modifier.'] = 'Recomendado como segunda elección de modificador.';
L['Reduces unexpected camera movement to reduce motion sickness.'] = 'Reduce el movimiento de cámara inesperado para reducir el mareo por movimiento.';
L['Regenerate Dictionary'] = 'Regenerar diccionario';
L['Regular'] = 'Normal';
L['Relative Anchor'] = 'Anclaje relativo';
L['Relative anchor point of the counter text on buttons.'] = 'Punto de anclaje relativo del texto del contador en los botones.';
L['Relative anchor point of the hotkey icon on group buttons.'] = 'Punto de anclaje relativo del icono de tecla rápida en botones de grupo.';
L['Relative anchor point of the hotkey text on buttons.'] = 'Punto de anclaje relativo del texto de tecla rápida en los botones.';
L['Relative anchor point of the macro text on buttons.'] = 'Punto de anclaje relativo del texto de macro en los botones.';
L['Relative Rescale'] = 'Reescalado relativo';
L['Reload'] = 'Recargar';
L['Remove all saved settings and bindings, disable addon, and reload interface.'] = 'Eliminar todos los ajustes y asignaciones guardados, desactivar addon y recargar la interfaz.';
L['Remove all saved settings and reload interface.'] = 'Eliminar todos los ajustes guardados y recargar la interfaz.';
L['Remove Button'] = 'Botón Eliminar';
L['Remove from %s'] = 'Quitar de %s';
L['Remove this set. This action cannot be undone.'] = 'Eliminar este conjunto. Esta acción no se puede deshacer.';
L['Removes the tooltip background for a minimalistic look.'] = 'Elimina el fondo de la información para un aspecto minimalista.';
L['Repeated Movement Delay'] = 'Retardo de movimiento repetido';
L['Repeated Movement First Delay'] = 'Primer retardo de movimiento repetido';
L['Replaces the default loot frame with a custom version optimized for controller navigation.'] = 'Reemplaza el marco de botín por defecto con una versión personalizada optimizada para navegación con mando.';
L['Request early landing from the taxi you are currently riding.'] = 'Solicitar aterrizaje temprano desde el taxi que estás montando actualmente.';
L['Requires /reload to fully unhook when disabled.'] = 'Requiere /reload para desengancharse completamente al desactivarse.';
L['Requires a touchpad with LED support.'] = 'Requiere un panel táctil con soporte LED.';
L['Requires reload.'] = 'Requiere recarga.';
L['Requires Settings > Hide Cursor on Stick Input set to None.'] = 'Requiere Ajustes > Ocultar cursor con entrada del stick configurado a Ninguno.';
L['Requires Toggle Interface Cursor binding to use the cursor.'] = 'Requiere la asignación Alternar cursor de interfaz para usar el cursor.';
L['Reset all mapping configurations and reload. (will not affect bindings)'] = 'Restablecer todas las configuraciones de asignación y recargar. (no afectará a las asignaciones)';
L['Response to condition for custom processing.'] = 'Respuesta a condición para procesamiento personalizado.';
L['Reticle targeting means anything you place on the ground.'] = 'La selección por mira significa todo lo que coloques en el suelo.';
L['Reticle targeting uses free cursor instead of staying center-fixed.'] = 'La selección por mira usa cursor libre en lugar de mantenerse fijo en el centro.';
L['Return Button'] = 'Botón Volver';
L['Returns to the previous menu.'] = 'Vuelve al menú anterior.';
L['Reverse Mouse Handling'] = 'Invertir gestión del ratón';
L['Reverse Order'] = 'Invertir orden';
L['Reverse the order of the buttons.'] = 'Invertir el orden de los botones.';
L['Ring Manager'] = 'Gestor de menús radiales';
L['Ring Scale'] = 'Escala del menú radial';
L['Ring Size'] = 'Tamaño del menú radial';
L['Rings'] = 'Menús radiales';
L['Rings (Account)'] = 'Menús radiales (cuenta)';
L['Rings (Character)'] = 'Menús radiales (personaje)';
L['Rotation'] = 'Rotación';
L['Rotation of the divider.'] = 'Rotación del separador.';
L['Run / Walk Threshold'] = 'Umbral de correr/andar';
L['Run Tests'] = 'Ejecutar pruebas';
L['Save as default'] = 'Guardar como predeterminado';
L['Save preset from %s:'] = 'Guardar preajuste de %s:';
L['Save your current loadout to the preset list.'] = 'Guardar tu loadout actual en la lista de preajustes.';
L['Scale of all radial menus, relative to UI scale.'] = 'Escala de todos los menús radiales, relativa a la escala de la interfaz.';
L['Scale of most ConsolePort frames, relative to UI scale.'] = 'Escala de la mayoría de marcos de ConsolePort, relativa a la escala de la interfaz.';
L['Scale of the cursor.'] = 'Escala del cursor.';
L['Scale of the game menu and radial companion.'] = 'Escala del menú del juego y compañero radial.';
L['Scale of the keyboard.'] = 'Escala del teclado.';
L['Scale of the pet ring.'] = 'Escala del menú radial de mascota.';
L['Secondary accept button, to use or confirm a quick menu action.'] = 'Botón secundario de aceptar, para usar o confirmar una acción del menú rápido.';
L['Select a device from the list to continue.'] = 'Selecciona un dispositivo de la lista para continuar.';
L['Select a slot to bind %s and place this spell.'] = 'Selecciona una ranura para asignar %s y colocar este hechizo.';
L['Select a slot to place this spell.'] = 'Selecciona una ranura para colocar este hechizo.';
L['Select the device you want to configure.'] = 'Selecciona el dispositivo que quieres configurar.';
L['Select the device you want to use.'] = 'Selecciona el dispositivo que quieres usar.';
L['Selecting an item on a ring will stick until another item is chosen.'] = 'Seleccionar un objeto en un menú radial se quedará pegado hasta que se elija otro objeto.';
L['Sensors'] = 'Sensores';
L['Set %d |cFF757575(%s)|r'] = 'Conjunto %d |cFF757575(%s)|r';
L['Set binding'] = 'Establecer asignación';
L['Sets if range should be a hard cutoff, even for something you can interact with.'] = 'Establece si el alcance debe ser un corte fijo, incluso para algo con lo que puedes interactuar.';
L['Shift-click to Edit Binding'] = 'Mayús+clic para editar asignación';
L['Shift-right-click to Clear Binding'] = 'Mayús+clic derecho para borrar asignación';
L['Show a color tint on the toolbar.'] = 'Mostrar un tinte de color en la barra de herramientas.';
L['Show Ability Briefings'] = 'Mostrar resúmenes de habilidades';
L['Show Action Bar Grid on Spell Pickup'] = 'Mostrar cuadrícula de barra de acción al coger hechizo';
L['Show active buffs in the quick menu.'] = 'Mostrar mejoras activas en el menú rápido.';
L['Show active debuffs in the quick menu.'] = 'Mostrar empeoramientos activos en el menú rápido.';
L['Show All Action Bars'] = 'Mostrar todas las barras de acción';
L['Show all enabled combinations in the cluster at all times.'] = 'Mostrar todas las combinaciones activadas en el clúster en todo momento.';
L['Show bonus bar configuration for characters without stances.'] = 'Mostrar configuración de barra de bonificación para personajes sin posturas.';
L['Show Centered Cursor Tooltip'] = 'Mostrar información del cursor centrado';
L['Show connected devices.'] = 'Mostrar dispositivos conectados.';
L['Show Default Button'] = 'Mostrar botón por defecto';
L['Show Enemy Nameplate'] = 'Mostrar placa de nombre enemiga';
L['Show Enemy Target Icon'] = 'Mostrar icono de objetivo enemigo';
L['Show Enemy Tooltip'] = 'Mostrar información enemiga';
L['Show Flyout Buttons'] = 'Mostrar botones desplegables';
L['Show Flyouts'] = 'Mostrar desplegables';
L['Show Friendly Nameplate'] = 'Mostrar placa de nombre amistosa';
L['Show Friendly Target Icon'] = 'Mostrar icono de objetivo amistoso';
L['Show Friendly Tooltip'] = 'Mostrar información amistosa';
L['Show Gauge'] = 'Mostrar medidor';
L['Show help for command(s).'] = 'Mostrar ayuda para orden(es).';
L['Show Hotkeys'] = 'Mostrar teclas rápidas';
L['Show icon above the current enemy soft target.'] = 'Mostrar icono sobre el objetivo flexible enemigo actual.';
L['Show icon above the current friendly soft target.'] = 'Mostrar icono sobre el objetivo flexible amistoso actual.';
L['Show icon above the current interactable object.'] = 'Mostrar icono sobre el objeto interactivo actual.';
L['Show icon above the current interactable target.'] = 'Mostrar icono sobre el objetivo interactivo actual.';
L['Show interact binding hint on interactables.'] = 'Mostrar pista de asignación de interacción en objetos interactivos.';
L['Show Interact Hint'] = 'Mostrar pista de interacción';
L['Show interact tooltip on nameplates, when applicable.'] = 'Mostrar información de interacción en placas de nombre, cuando aplique.';
L['Show item type in the quick menu.'] = 'Mostrar tipo de objeto en el menú rápido.';
L['Show Main Icons'] = 'Mostrar iconos principales';
L['Show Modifier Icons'] = 'Mostrar iconos de modificador';
L['Show numerical cooldown text on buttons.'] = 'Mostrar texto numérico de tiempo de reutilización en los botones.';
L['Show Object Icon'] = 'Mostrar icono de objeto';
L['Show on Name Plates'] = 'Mostrar en placas de nombre';
L['Show pet action bar in the quick menu.'] = 'Mostrar barra de acción de mascota en el menú rápido.';
L['Show ping commands in the quick menu.'] = 'Mostrar órdenes de ping en el menú rápido.';
L['Show Portrait'] = 'Mostrar retrato';
L['Show portrait for the current unit, with health percentage and applicable spell casts.'] = 'Mostrar retrato para la unidad actual, con porcentaje de salud e incantaciones aplicables.';
L['Show Status Text'] = 'Mostrar texto de estado';
L['Show Target Icon'] = 'Mostrar icono de objetivo';
L['Show the default mouse action button.'] = 'Mostrar el botón de acción de ratón por defecto.';
L['Show the empty buttons in the page.'] = 'Mostrar los botones vacíos en la página.';
L['Show the flyout of small buttons for the button cluster.'] = 'Mostrar el desplegable de botones pequeños para el clúster de botones.';
L['Show the hotkeys on the buttons.'] = 'Mostrar las teclas rápidas en los botones.';
L['Show the icons for main buttons.'] = 'Mostrar los iconos para botones principales.';
L['Show the icons for modifier buttons.'] = 'Mostrar los iconos para botones de modificador.';
L['Show the pet power and health status.'] = 'Mostrar el estado de poder y salud de la mascota.';
L['Show the pet ring when in a vehicle.'] = 'Mostrar el menú radial de mascota cuando estés en un vehículo.';
L['Show the watch bars at the bottom of the toolbar.'] = 'Mostrar las barras de seguimiento en la parte inferior de la barra de herramientas.';
L['Show Tooltip'] = 'Mostrar información';
L['Show tooltip for enemy target.'] = 'Mostrar información para objetivo enemigo.';
L['Show tooltip for friendly target.'] = 'Mostrar información para objetivo amistoso.';
L['Show tooltip for interactables.'] = 'Mostrar información para objetos interactivos.';
L['Show tooltip for mouseover targets when cursor is centered.'] = 'Mostrar información para objetivos al pasar el ratón cuando el cursor está centrado.';
L['Show tooltips on buttons when moused over.'] = 'Mostrar información en los botones al pasar el ratón.';
L['Show Type Icon'] = 'Mostrar icono de tipo';
L['Size of pointer arrow, in pixels.'] = 'Tamaño de la flecha del puntero, en píxeles.';
L['Size of the button cluster.'] = 'Tamaño del clúster de botones.';
L['Size of the hotkey icon on group buttons.'] = 'Tamaño del icono de tecla rápida en botones de grupo.';
L['Size of unit hotkeys, in pixels.'] = 'Tamaño de las teclas rápidas de unidad, en píxeles.';
L['Space'] = 'Espacio';
L['Speed of cursor when it starts moving.'] = 'Velocidad del cursor cuando empieza a moverse.';
L['Split stack'] = 'Dividir pila';
L['Start moving the configuration window.'] = 'Empezar a mover la ventana de configuración.';
L['Starting point of the page.'] = 'Punto de inicio de la página.';
L['Status Bar'] = 'Barra de estado';
L['Stick to use for main radial actions.'] = 'Stick a usar para las acciones radiales principales.';
L['Stick to use for the pet ring. Default follows the radial menu primary stick.'] = 'Stick a usar para el menú radial de mascota. Por defecto sigue el stick principal de los menús radiales.';
L['Stick to use for this ring. Default follows the radial menu primary stick.'] = 'Stick a usar para este menú radial. Por defecto sigue el stick principal de los menús radiales.';
L['Sticky Color'] = 'Color pegajoso';
L['Sticky Selection'] = 'Selección pegajosa';
L['Strafe Angle (Combat)'] = 'Ángulo de movimiento lateral (combate)';
L['Strafe Angle (Jump)'] = 'Ángulo de movimiento lateral (salto)';
L['Strafe Angle (Travel)'] = 'Ángulo de movimiento lateral (viaje)';
L['Strafe Angle Macro Condition (Combat)'] = 'Condición macro de ángulo de movimiento lateral (combate)';
L['Strafe Angle Macro Condition (Travel)'] = 'Condición macro de ángulo de movimiento lateral (viaje)';
L['Strata'] = 'Estrato';
L['Stride'] = 'Zancada';
L['Style of the border around main buttons.'] = 'Estilo del borde alrededor de los botones principales.';
L['Support on Patreon'] = 'Apoyar en Patreon';
L['Swap to a specified action bar layout.'] = 'Cambiar a un diseño de barra de acción especificado.';
L['Swipe Color'] = 'Color de barrido';
L['Switch Button'] = 'Botón cambiar';
L['Switches between the main menu and the radial companion.'] = 'Alterna entre el menú principal y el compañero radial.';
L['Synchronize Bindings'] = 'Sincronizar asignaciones';
L['Synchronize Config'] = 'Sincronizar configuración';
L['Take ownership of, and move the micro menu buttons to the toolbar.'] = 'Tomar la propiedad y mover los botones del micromenú a la barra de herramientas.';
L['Takes the format of...\n|cFF3FC7EB[condition] Preset Name; nil|r\n\nAuto-saved presets are named "Character (Specialization) Realm", using class instead of specialization on Classic.\n\nThe preset loads outside of combat when the condition applies. Character presets take precedence over device presets.'] = [[Toma el formato de…
|cFF3FC7EB[condición] Nombre del preajuste; nil|r

Los preajustes guardados automáticamente se llaman "Personaje (Especialización) Reino", con la clase en lugar de la especialización en Classic.

El preajuste se carga fuera de combate cuando la condición se cumple. Los preajustes de personaje tienen prioridad sobre los preajustes de dispositivo.]];
L['Taps for cursor clicks are right clicks instead of left.'] = 'Las pulsaciones para clics del cursor son clics derechos en lugar de izquierdos.';
L['Target enemies automatically by looking at them.'] = 'Seleccionar enemigos automáticamente mirándolos.';
L['Target friends automatically by looking at them.'] = 'Seleccionar amigos automáticamente mirándolos.';
L['Target Match Lock'] = 'Bloqueo de coincidencia de objetivo';
L['Target Range'] = 'Alcance de objetivo';
L['Target Range Hard Cutoff'] = 'Corte fijo de alcance de objetivo';
L['Target Ring'] = 'Menú radial de objetivo';
L['Targeting Mode'] = 'Modo de selección de objetivo';
L['Test Device'] = 'Probar dispositivo';
L['The analog input for forward/back movement.'] = 'La entrada analógica para el movimiento adelante/atrás.';
L['The analog input for left/right Camera Yaw "look" feature.'] = 'La entrada analógica para la función «mirada» de guiñada de cámara izquierda/derecha.';
L['The analog input for left/right Camera Yaw.'] = 'La entrada analógica para guiñada de cámara izquierda/derecha.';
L['The analog input for left/right movement.'] = 'La entrada analógica para el movimiento izquierda/derecha.';
L['The analog input for up/down Camera Pitch "look" feature.'] = 'La entrada analógica para la función «mirada» de cabeceo de cámara arriba/abajo.';
L['The analog input for up/down Camera Pitch.'] = 'La entrada analógica para cabeceo de cámara arriba/abajo.';
L['The configuration is accessible by the chat command %s or from the game menu.'] = 'La configuración es accesible mediante la orden de chat %s o desde el menú del juego.';
L['The modifier can be used to nudge the cursor position with the directional pad.'] = 'El modificador puede usarse para empujar la posición del cursor con la cruceta.';
L['The modifier can be used to scroll together with the directional pad.'] = 'El modificador puede usarse para desplazarse junto con la cruceta.';
L['The quick menu binding can be used to close the menu as well.'] = 'La asignación del menú rápido también puede usarse para cerrar el menú.';
L['The time it takes to transition from idle camera control to auto-adjustment (FOAS).'] = 'El tiempo que tarda en pasar del control de cámara inactivo al ajuste automático (FOAS).';
L['Thickness'] = 'Grosor';
L['Thickness in scaled pixel units.'] = 'Grosor en unidades de píxel escaladas.';
L['Thickness of the divider.'] = 'Grosor del separador.';
L['This button is necessary to use or sell an item directly from your bags.'] = 'Este botón es necesario para usar o vender un objeto directamente desde tus bolsas.';
L['This feature is only available in Classic.'] = 'Esta función solo está disponible en Classic.';
L['This only affects gamepad bindings.'] = 'Esto solo afecta a las asignaciones de mando.';
L['This will not affect your bindings, interface settings or system-wide settings.'] = 'Esto no afectará a tus asignaciones, ajustes de interfaz ni ajustes del sistema.';
L['This will not work with Xbox controllers connected via bluetooth. The Xbox Adapter is required.'] = 'Esto no funcionará con mandos Xbox conectados por Bluetooth. Se requiere el adaptador Xbox.';
L['Time in milliseconds for the opacity to change from one state to another.'] = 'Tiempo en milisegundos para que la opacidad cambie de un estado a otro.';
L['Time in seconds to automatically hide centered cursor.'] = 'Tiempo en segundos para ocultar automáticamente el cursor centrado.';
L['Time in seconds to enable free cursor.'] = 'Tiempo en segundos para activar el cursor libre.';
L['Time to clear focus after intercepting stick input, in seconds.'] = 'Tiempo para borrar el foco tras interceptar la entrada del stick, en segundos.';
L['Timeframe to catch a binding in the configuration, in seconds.'] = 'Plazo para capturar una asignación en la configuración, en segundos.';
L['Timeframe to toggle the mouse cursor when double-tapping a selected modifier.'] = 'Plazo para alternar el cursor de ratón al doble pulsar un modificador seleccionado.';
L['Tint Color'] = 'Color de tinte';
L['Toggle visibility of all modifier flyouts for cluster action bars.'] = 'Alternar la visibilidad de todos los desplegables de modificador para barras de acción clúster.';
L['Toggle visibility of all modifier flyouts.'] = 'Alternar la visibilidad de todos los desplegables de modificador.';
L['Toolbar'] = 'Barra de herramientas';
L['Tooltip'] = 'Información';
L['Top speed of cursor movement.'] = 'Velocidad máxima de movimiento del cursor.';
L['Touch Tap Buttons'] = 'Botones de pulsación táctil';
L['Touch Tap Exclusive Click'] = 'Clic exclusivo de pulsación táctil';
L['Touch Tap Max Time'] = 'Tiempo máximo de pulsación táctil';
L['Touch Tap Right Click'] = 'Clic derecho de pulsación táctil';
L['Touchpad'] = 'Panel táctil';
L['Transition'] = 'Transición';
L['Transition time for opacity changes.'] = 'Tiempo de transición para cambios de opacidad.';
L['Travel Time'] = 'Tiempo de viaje';
L['Trigger button actions on press instead of release.'] = 'Activar acciones de botón al pulsar en lugar de al soltar.';
L['Triggers'] = 'Gatillos';
L['Turn Character With Camera'] = 'Girar personaje con la cámara';
L['Turn your character facing when you turn your camera angle.'] = 'Gira la dirección hacia donde mira tu personaje cuando giras el ángulo de la cámara.';
L['Type of LED color to use for the touchpad.'] = 'Tipo de color LED a usar para el panel táctil.';
L['Types are PlayStation, Xbox, or Generic.'] = 'Los tipos son PlayStation, Xbox o Genérico.';
L['Unit Hotkeys'] = 'Teclas rápidas de unidad';
L['Unit Pool'] = 'Grupo de unidades';
L['Units to watch, as lists of unit tokens selected by macro conditions. Use [] for the unconditional fallback.'] = 'Unidades a vigilar, como listas de tokens seleccionadas por condiciones de macro. Usa [] como alternativa incondicional.';
L['Unknown device selected.'] = 'Dispositivo desconocido seleccionado.';
L['Unlimited Navigation'] = 'Navegación ilimitada';
L['Unmapped keyboard key(s) detected:'] = 'Tecla(s) de teclado sin asignar detectada(s):';
L['Use a targeting binding to turn a soft target into a hard target.'] = 'Usar una asignación de selección para convertir un objetivo flexible en un objetivo fijo.';
L['Use character specific addon settings for this character.'] = 'Usar ajustes de addon específicos del personaje para este personaje.';
L['Use Custom Button Set'] = 'Usar conjunto de botones personalizado';
L['Use Custom Loot Frame'] = 'Usar marco de botín personalizado';
L['Use Default Hotkey Icons'] = 'Usar iconos de tecla rápida por defecto';
L['Use Focus Mode'] = 'Usar modo foco';
L['Use Global Loot Tooltip'] = 'Usar información de botín global';
L['Use Hardware Mouse Cursor'] = 'Usar cursor de ratón por hardware';
L['Use Instant Mode'] = 'Usar modo instantáneo';
L['Use Interact Nameplate Tooltip'] = 'Usar información de interactuar en placa de nombre';
L['Use On Demand'] = 'Usar bajo demanda';
L['Use optimized pathfinding algorithm for cursor movement.'] = 'Usar un algoritmo optimizado de búsqueda de rutas para el movimiento del cursor.';
L['Use press and hold to navigate and use rings. Press, point, release.'] = 'Usa pulsar y mantener para navegar y usar los menús radiales. Pulsa, apunta, suelta.';
L['Use Static Mode'] = 'Usar modo estático';
L['Use the hardware cursor provided by the operating system.'] = 'Usar el cursor por hardware proporcionado por el sistema operativo.';
L['Use together with [@cursor] macros to place reticle spells in a single click.'] = 'Usar junto con macros [@cursor] para colocar hechizos con mira en un solo clic.';
L['Used for interacting with the world, at a center-fixed position.'] = 'Usado para interactuar con el mundo, en una posición fija central.';
L['Uses global tint color when transparent.'] = 'Usa el color de tinte global cuando es transparente.';
L['Uses the default hotkey icons instead of the custom icons provided by ConsolePort.'] = 'Usa los iconos de tecla rápida por defecto en lugar de los iconos personalizados proporcionados por ConsolePort.';
L['Valid Action Deadzone'] = 'Zona muerta de acción válida';
L['Value below two may appear interlaced or not at all.'] = 'Un valor por debajo de dos puede aparecer entrelazado o no aparecer en absoluto.';
L['Vertical Offset'] = 'Desplazamiento vertical';
L['Vertical offset from anchor point.'] = 'Desplazamiento vertical desde el punto de anclaje.';
L['Vertical offset of the counter text on buttons.'] = 'Desplazamiento vertical del texto del contador en los botones.';
L['Vertical offset of the hotkey icon on group buttons.'] = 'Desplazamiento vertical del icono de tecla rápida en botones de grupo.';
L['Vertical offset of the hotkey prompt position, in pixels.'] = 'Desplazamiento vertical de la posición del aviso de tecla rápida, en píxeles.';
L['Vertical offset of the hotkey text on buttons.'] = 'Desplazamiento vertical del texto de tecla rápida en los botones.';
L['Vertical offset of the macro text on buttons.'] = 'Desplazamiento vertical del texto de macro en los botones.';
L['Vertical Padding'] = 'Relleno vertical';
L['Vertical position of centered cursor & targeting, as fraction of screen height.'] = 'Posición vertical del cursor centrado y selección de objetivo, como fracción de la altura de la pantalla.';
L['Visibility Condition'] = 'Condición de visibilidad';
L['Watch bars include XP, reputation, honor, artifact power, and azerite.'] = 'Las barras de seguimiento incluyen XP, reputación, honor, poder de artefacto y azerita.';
L['When disabled, a button press will also act as a cursor click.'] = 'Cuando está desactivado, una pulsación de botón también actuará como un clic del cursor.';
L['When disabled, you will need to press the accept button to confirm a selection.'] = 'Cuando está desactivado, necesitarás pulsar el botón de aceptar para confirmar una selección.';
L['When enabled, a tap will act as a button press.'] = 'Cuando está activado, una pulsación actuará como una pulsación de botón.';
L['When set to both sticks, cursor only disables when both sticks are used together.'] = 'Cuando se configura en ambos sticks, el cursor solo se desactiva cuando se usan ambos sticks juntos.';
L['Whether client keybindings should be saved to the server.'] = 'Si las asignaciones de teclado del cliente deben guardarse en el servidor.';
L['Whether the keyboard should always be shown or only when a gamepad is active.'] = 'Si el teclado debe mostrarse siempre o solo cuando un mando está activo.';
L['Whether to save character- and account-scoped variables to the server.'] = 'Si guardar las variables a nivel de personaje y cuenta en el servidor.';
L['Which button set to use for unit hotkeys.'] = 'Qué conjunto de botones usar para teclas rápidas de unidad.';
L['Which modifier to use for modified commands.'] = 'Qué modificador usar para órdenes modificadas.';
L['Which modifier to use for nudging the cursor.'] = 'Qué modificador usar para empujar el cursor.';
L['Which modifier to use to toggle the mouse cursor when double-tapped.'] = 'Qué modificador usar para alternar el cursor de ratón al doble pulsarlo.';
L['Which modifier to use with the movement buttons to move the cursor.'] = 'Qué modificador usar con los botones de movimiento para mover el cursor.';
L['While held down, can simulate dragging by clicking on the directional pad.'] = 'Mientras se mantenga pulsado, puede simular arrastrar haciendo clic en la cruceta.';
L['Width of the artwork.'] = 'Anchura del artwork.';
L['Width of the cluster bar.'] = 'Anchura de la barra clúster.';
L['Width of the crosshair, in scaled pixel units.'] = 'Anchura de la mira, en unidades de píxel escaladas.';
L['Width of the group.'] = 'Anchura del grupo.';
L['Width of the toolbar.'] = 'Anchura de la barra de herramientas.';
L['Wipe Dictionary'] = 'Borrar diccionario';
L['Wired'] = 'Con cable';
L['Works like a regular action bar, which displays the action slots of a specified action page.'] = 'Funciona como una barra de acción normal, que muestra las ranuras de acción de una página de acción especificada.';
L['X Offset'] = 'Desplazamiento X';
L['XP Bar Color'] = 'Color de barra de XP';
L['Y Offset'] = 'Desplazamiento Y';
L['Yaw Axis'] = 'Eje de guiñada';
L['Yaw-only deadzone for camera, applied before the 2D deadzone.'] = 'Zona muerta de solo guiñada para la cámara, aplicada antes de la zona muerta 2D.';
L['your current loadout'] = 'tu loadout actual';
---------------------------------------------------------------
-- Literal block entries
---------------------------------------------------------------
L['%s is already bound to\n%s\n\nDo you want to change it to\n%s?'] = [[%s ya está asignado a
%s

¿Quieres cambiarlo a
%s?]];
L['+ Normal\n- Inverted'] = [[+ Normal
- Invertido]];
L['Basic redirect cannot route macros or ambiguous spells. Use target mode or focus mode with [@focus] macros to control behavior.'] = [[La redirección básica no puede enrutar macros ni hechizos ambiguos. Usa el modo objetivo o el modo foco con macros [@focus] para controlar el comportamiento.]];
L['Button or combination used to click when a given condition applies, but act as a normal binding otherwise.'] = [[Botón o combinación usado para hacer clic cuando se aplica una condición dada, pero actúa como asignación normal en otro caso.]];
L['Change how the raid cursor acquires a target. Redirect and focus modes will reroute appropriate spells without changing your target.'] = [[Cambia cómo el cursor de banda adquiere un objetivo. Los modos de redirección y foco redirigirán hechizos apropiados sin cambiar tu objetivo.]];
L['Controls when your character transitions from strafing to facing your movement stick direction while in combat. Expressed in degrees, from looking straight forward.'] = [[Controla cuándo tu personaje pasa del movimiento lateral a mirar en la dirección de tu stick de movimiento mientras está en combate. Expresado en grados, desde mirar al frente.]];
L['Controls when your character transitions from strafing to facing your movement stick direction while in the air. Expressed in degrees, from looking straight forward.'] = [[Controla cuándo tu personaje pasa del movimiento lateral a mirar en la dirección de tu stick de movimiento mientras está en el aire. Expresado en grados, desde mirar al frente.]];
L['Controls when your character transitions from strafing to facing your movement stick direction. Expressed in degrees, from looking straight forward.'] = [[Controla cuándo tu personaje pasa del movimiento lateral a mirar en la dirección de tu stick de movimiento. Expresado en grados, desde mirar al frente.]];
L['Enable custom mouse handling, automating cursor toggling and timeout while using left and right mouse button emulation.'] = [[Activar gestión personalizada del ratón, automatizando el alternado del cursor y el tiempo de espera mientras se usa la emulación de botones izquierdo y derecho del ratón.]];
L['Explicit only matches hard locked targets through using a targeting binding, while implicit matches targets you attack.'] = [[Explícito solo coincide con objetivos fijos a través de usar una asignación de selección, mientras que implícito coincide con objetivos que atacas.]];
L['Groups button combinations in circular clusters which switch between different actions when modifiers are used.'] = [[Agrupa combinaciones de botones en clústeres circulares que alternan entre diferentes acciones cuando se usan modificadores.]];
L['Left mouse button emulation toggles center-fixed mode instead of free-roaming mode. Right mouse button emulation toggles free-roaming mode instead of center-fixed mode.'] = [[La emulación del botón izquierdo del ratón alterna el modo fijo centrado en lugar del modo libre. La emulación del botón derecho del ratón alterna el modo libre en lugar del modo fijo centrado.]];
L['Macro condition to enable the click override button. The default condition clicks right mouse button when there is no enemy target.'] = [[Condición de macro para activar el botón de sustitución de clic. La condición por defecto hace clic derecho cuando no hay objetivo enemigo.]];
L['Modifiers should be in descending order. M2M1, for example, is the Ctrl and Shift modifiers held at the same time.'] = [[Los modificadores deben ir en orden descendente. M2M1, por ejemplo, son los modificadores Ctrl y Mayús mantenidos a la vez.]];
L['Opacity is expressed in percentage, where 100 is fully visible and 0 is fully transparent. Values outside of the 0-100 range will be clamped.'] = [[La opacidad se expresa en porcentaje, donde 100 es totalmente visible y 0 totalmente transparente. Los valores fuera del rango 0-100 se ajustarán.]];
L['Show group loot rolls in the quick menu, allowing you to roll on items using gamepad buttons while in combat.'] = [[Mostrar tiradas de botín de grupo en el menú rápido, permitiéndote tirar el dado para objetos usando botones del mando en combate.]];
L['Takes the format of...\n'] = [[Toma el formato de…
]];
L['The bindings underlying the button combinations will be unavailable while the cursor is in use.\n\nModifier can also be configured on a per button basis.'] = [[Las asignaciones subyacentes a las combinaciones de botones no estarán disponibles mientras se usa el cursor.

El modificador también puede configurarse por botón.]];
L['Timeout clears focus after a set time, deadzone clears focus when stick input is neutral.'] = [[El tiempo de espera borra el foco tras un tiempo definido, la zona muerta borra el foco cuando la entrada del stick es neutral.]];
L['Use a custom set of buttons for the game menu, otherwise the button set will be dynamically determined.'] = [[Usar un conjunto personalizado de botones para el menú del juego, de lo contrario el conjunto se determinará dinámicamente.]];
L['Use a shoulder button combined with crosshair for smooth and precise interactions. The click is performed at crosshair or cursor location.'] = [[Usa un botón superior combinado con la mira para interacciones suaves y precisas. El clic se realiza en la posición de la mira o del cursor.]];
L['Use global game tooltip for loot information, allowing other addons to add information to lootable items.'] = [[Usar la información de juego global para información de botín, permitiendo a otros addons añadir información a objetos saqueables.]];
L['When set to zero, always face your movement stick direction.\nWhen set to max, never face your movement stick direction.'] = [[Cuando se configura a cero, siempre mira en la dirección de tu stick de movimiento.
Cuando se configura al máximo, nunca mira en la dirección de tu stick de movimiento.]];
L['While disabled, cursor timeout, and toggling between free-roaming and center-fixed cursor are also disabled.'] = [[Mientras esté desactivado, el tiempo de espera del cursor y la alternancia entre cursor libre y fijo central también están desactivados.]];
L['Your %s device has separate handling for Bluetooth and wired connection.\nWhich one are you using?'] = [[Tu dispositivo %s tiene gestión separada para conexión Bluetooth y por cable.
¿Cuál estás usando?]];
