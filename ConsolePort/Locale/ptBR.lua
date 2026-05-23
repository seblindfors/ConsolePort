local L = select(2, ...).Locale:GetLocale('ptBR'); if not L then return end;
---------------------------------------------------------------
-- ptBR Português Brazilian Portuguese
---------------------------------------------------------------
---------------------------------------------------------------
-- Short / curated keys
---------------------------------------------------------------
L.ACTIONBAR_FORM_ACTIVE_DESC  = 'Esta forma está atualmente ativa, e sua barra de ação principal está exibindo as habilidades associadas a ela.'; -- en:b400a632
L.DESC_CAMERAZOOMIN           = 'Aproxima a câmera. Segure para zoom contínuo.'; -- en:55f9b91f
L.DESC_CAMERAZOOMOUT          = 'Afasta a câmera. Segure para zoom contínuo.'; -- en:a6b9d796
L.DESC_OPENALLBAGS            = 'Abre e fecha todas as mochilas.'; -- en:4a74797f
L.DESC_TOGGLEWORLDMAP_CLASSIC = 'Alterna o mapa do mundo.'; -- en:00548e70
L.DESC_TOGGLEWORLDMAP_RETAIL  = 'Alterna o mapa do mundo e diário de missões combinados.'; -- en:621a94e8
L.FORMAT_HOLD_BINDING         = '%s (segurar)'; -- en:c3ecd1b3
L.FORMAT_RING_NUMERICAL       = 'Menu radial |cFF00FFFF%s|r'; -- en:68d18518
L.NAME_EASY_MOTION            = 'Mirar quadros de unidade (segurar)'; -- en:e6f0c131
L.NAME_QUICK_MENU             = 'Menu rápido'; -- en:ed9a0668
L.NAME_RAID_CURSOR_FOCUS      = 'Cursor de raide (Foco)'; -- en:d350d370
L.NAME_RAID_CURSOR_TARGET     = 'Cursor de raide (Alvo)'; -- en:8182d5d5
L.NAME_RAID_CURSOR_TOGGLE     = 'Alternar cursor de raide'; -- en:79fb9d46
L.NAME_RING_MENU              = 'Menu radial'; -- en:8d7e5939
L.NAME_RING_PET               = 'Menu radial de mascote'; -- en:8dab5a0e
L.NAME_RING_UTILITY           = 'Menu radial utilitário'; -- en:96bc880d
L.NAME_UI_CURSOR_TOGGLE       = 'Alternar cursor de interface'; -- en:2d6091b5
L.RING_EMPTY_DESC             = 'Você ainda não tem nenhuma habilidade neste menu radial.'; -- en:044cf09a
---------------------------------------------------------------
-- Long / curated block entries
---------------------------------------------------------------
L.ACTIONBAR_FORM_DESC = [[Ativar esta forma mudará automaticamente sua barra de ação principal para exibir as habilidades associadas a esta forma.

A forma compartilha ligações com sua barra de ação principal, permitindo usar seus combos habituais para acessar as habilidades nesta forma.

Quando sair desta forma, sua barra de ação principal voltará ao estado anterior, exibindo suas habilidades habituais.]]; -- en:a751197a
L.ACTIONBAR_MAIN_DESC = [[A barra de ação principal é seu local principal para habilidades de rotação e outras ações usadas com frequência.

Esta barra é dinâmica e pode mudar automaticamente para diferentes páginas dependendo da sua situação atual.

Por exemplo, a barra de ação principal mudará para um conjunto especial de habilidades quando você entrar em um veículo, participar de uma batalha de mascotes, se transformar em uma forma diferente, entrar em uma postura de combate ou assumir o controle de outra unidade.

Isso permite acessar habilidades específicas do contexto sem precisar mudar manualmente a configuração da sua barra de ação.

Quando voltar ao seu estado normal, suas habilidades regulares reaparecerão na barra.]]; -- en:8e47cecd
L.ACTIONBAR_PAGE_MISMATCH_DESC = [[O número de página real de uma barra de ação nem sempre corresponde ao nome exibido, devido a como o sistema de barra de ação foi originalmente projetado.

Esta discrepância pode ser ignorada se você não está usando uma solução personalizada de página de ação. Ambos são mostrados como referência.]]; -- en:9fd917fd
L.ADD_NEW_RING_TEXT = [[|cFFFFFF00Criar novo menu radial|r
Por favor, escolha um nome para seu novo menu radial:]]; -- en:00af872a
L.CLEAR_RING_TEXT = [[|cFFFFFF00Limpar %s|r
Tem certeza que quer limpar o menu radial?]]; -- en:ebc807d8
L.CONTROLS_GAMEPAD_TESTER_ACTION = [[
	Os testes expirarão automaticamente após alguns segundos se nenhuma entrada for detectada.
]]; -- en:0f591dc7
L.CONTROLS_GAMEPAD_TESTER_DESC = [[
	Use a ferramenta de teste para verificar se seu controle está funcionando corretamente.

	O teste pedirá para pressionar botões e mover os eixos do seu controle,
	para garantir que todos os botões e sensores estão funcionando como esperado.

	Solução de problemas:

	- Garanta que seu controle está conectado e reconhecido pelo sistema operacional.

	- Verifique se há software conflitante que possa interferir com seu dispositivo,
	como o Steam rodando em segundo plano no Windows.

	- Se está usando um computador portátil, garanta que o dispositivo está em modo de jogo
	no centro de controle. O modo desktop não funcionará corretamente.

	- Atualize drivers e instale qualquer software necessário para seu controle.
]]; -- en:fd1ed2f5
L.CONTROLS_GENERAL_INFO = [[
	Selecione seu esquema de controle preferido.
]]; -- en:3f779845
L.CONTROLS_MODIFIERS_CUSTOM = [[
	Use configurações de modificador personalizadas.

	Recomenda-se definir os modificadores nos botões superiores ou gatilhos, pois são os botões mais acessíveis do controle.
]]; -- en:964cdf45
L.CONTROLS_MODIFIERS_DESC = [[
	Os modificadores alternam entre conjuntos de ligações e também emulam as teclas de controle do teclado (Shift, Ctrl, Alt).

	Segurar um modificador alternará temporariamente suas ligações para um conjunto alternativo, expandindo suas ações disponíveis.

	Os modificadores podem ser tocados — pressionados e soltos rapidamente — para executar ligações regulares.

	Também podem ser combinados entre si; usar dois modificadores dá um total de quatro conjuntos de ligações,
	e três modificadores dão oito conjuntos de ligações.

	Dois modificadores são suficientes para a maioria dos jogadores terem um conjunto confortável de ligações,
	sem adicionar muita complexidade.
]]; -- en:b083ec08
L.CONTROLS_MODIFIERS_LEFT = [[
	Use modificadores canhotos para manter o movimento e a troca de conjunto de ligações no lado esquerdo do controle.

	Ter papéis separados para as mãos esquerda e direita pode ajudar com ergonomia e coordenação.
]]; -- en:507e5d94
L.CONTROLS_MODIFIERS_TRIGGERS = [[
	Use ambos os gatilhos como modificadores para dividir suas ligações entre o lado esquerdo e o direito.

	Isso pode ser benéfico se está vindo de FFXIV, ou se prefere o modelo mental de crossbar.
]]; -- en:70401fbd
L.CONTROLS_MOUSE_BUTTONS_DESC = [[
	Os botões do mouse podem ser emulados para fornecer funcionalidade semelhante à de um mouse.

	Essas ligações são vitais em alguns casos, como confirmar a colocação de magias no chão,
	mirar com precisão em uma multidão e ações específicas de interface.

	Elas podem ser combinadas com modificadores para replicar ainda mais a funcionalidade de um mouse.

	Esses botões também são usados para alternar o cursor, que pode ter três estados:

	- Livre; você pode usar seu controle para mover o cursor pela tela.

	- Centralizado; o cursor está fixo no centro da tela, para mirar em objetos e personagens
	e para colocar magias no chão.

	- Oculto; o cursor continua centralizado, mas não é visível na tela. Sua posição é indicada por uma mira.
]]; -- en:e088d19f
L.CONTROLS_MOUSE_CUSTOM = [[
	Use configurações personalizadas de botões de mouse.

	World of Warcraft trata os botões do mouse de duas maneiras separadas, geralmente ocultas.

	- Quando clica na interface do jogo (como botões ou menus), a interface apenas reage
	a cliques do mouse, que podem ser emulados por um controle.

	- Quando clica em coisas no mundo do jogo (como mirar ou interagir), usa ligações regulares.

	Recomenda-se manter essas ações juntas para preencher o mesmo papel de um mouse.
]]; -- en:3e862670
L.CONTROLS_MOUSE_INVERTED = [[
	Use ligações de botões de mouse invertidas.

	Use o stick esquerdo para alternar entre os modos cursor centralizado e oculto, e para clicar com o botão direito.

	Use o stick direito para alternar o modo cursor livre, e para clicar com o botão esquerdo.
]]; -- en:16d3d6d2
L.CONTROLS_MOUSE_REGULAR = [[
	Use ligações regulares de botões de mouse.

	Use o stick esquerdo para alternar o modo cursor livre, e para clicar com o botão esquerdo.

	Use o stick direito para alternar entre os modos cursor centralizado e oculto, e para clicar com o botão direito.
]]; -- en:75e9f21b
L.CONTROLS_MOVEMENT_BALANCED_DESC = [[
	O movimento equilibrado é um compromisso entre o movimento tanque e o de seguir.

	Em combate e em viagem, esta configuração fará movimento lateral até 115 graus em cada direção,
	ou seja, você ainda olhará para frente enquanto se move lateralmente.

	Se mover o stick mais para baixo, seu personagem passará a seguir a direção do movimento.
	Olhe a cabeça do seu personagem para ver em que direção está olhando.

	115 graus é o ponto ideal para fornecer cobertura máxima sem perder velocidade de movimento.
]]; -- en:3355743a
L.CONTROLS_MOVEMENT_DESC = [[
	Os controles de movimento podem ser personalizados para se adequar ao seu estilo de jogo.

	Os controles usam movimento analógico, ou seja, você pode correr em qualquer direção,
	e andar variando a pressão aplicada ao stick.

	O jogo depende muito do movimento lateral como mecânica,
	onde você se move lateralmente enquanto olha em uma direção diferente.

	Você pode personalizar quando seu personagem passa entre
	o movimento lateral e virar-se na direção de movimento.

	Destaque uma das configurações e mova seu stick esquerdo
	para testá-la.
]]; -- en:9d22c4f0
L.CONTROLS_MOVEMENT_FOLLOW_DESC = [[
	O movimento «seguir» se concentra em seguir a direção em que você está se movendo.

	Em combate e em viagem, esta configuração nunca fará movimento lateral
	e nunca andará para trás.

	Isso pode ser útil para jogadores que jogam frequentemente ou sempre com uma configuração de um único stick.
]]; -- en:45773d56
L.CONTROLS_MOVEMENT_TANK_DESC = [[
	O movimento tanque se concentra em manter uma posição voltada para frente enquanto se move em combate.

	Em combate, esta configuração sempre fará movimento lateral, e andará para trás para manter-se voltado para frente.

	Durante a viagem, esta configuração sempre seguirá a direção do movimento.
]]; -- en:9fcbcaaf
L.DEFAULTS_BINDINGS_EMPTY_DESC = [[
	Comece do zero.

	Esta ação limpará todas as suas ligações de controle atuais, incluindo as padrões da Blizzard,
	para permitir que você configure suas ligações do zero.

	Esta ação não sobrescreve nem interfere nas ligações de teclado existentes,
	mas lembre-se de que as barras de ação são compartilhadas entre as duas.

	Se pretende alternar entre teclado e controle, recomenda-se mudar suas
	ligações de controle em vez de mover habilidades pelas barras de ação.
]]; -- en:51053386
L.DEFAULTS_BINDINGS_PRESET_DESC = [[
	Aplica as ligações recomendadas.

	Essas ligações são baseadas nas suas escolhas anteriores e devem dar um bom ponto de partida
	para a configuração do seu controle. Você sempre pode mudá-las depois.

	Esta ação não sobrescreve nem interfere nas ligações de teclado existentes,
	mas lembre-se de que as barras de ação são compartilhadas entre as duas.

	Se pretende alternar entre teclado e controle, recomenda-se mudar suas
	ligações de controle em vez de mover habilidades pelas barras de ação.
]]; -- en:6ac789b1
L.DEFAULTS_GENERAL_INFO = [[
	Finalize a configuração aplicando configurações e ligações recomendadas para seu controle.
]]; -- en:c436023e
L.DEFAULTS_SETTINGS_APPLIED = [[
	As configurações recomendadas para seu tipo de controle (%s) foram aplicadas.
]]; -- en:16be45b5
L.DEFAULTS_SETTINGS_DESC = [[
	Aplique as configurações recomendadas para seu tipo de controle (%s):
]]; -- en:15a4050f
L.DEFAULTS_SETTINGS_NOTWEAK = [[
	Seu tipo de controle (%s) não tem nenhuma configuração recomendada para aplicar.
]]; -- en:067a8a20
L.DESC_EASY_MOTION = [[
	Gera teclas rápidas de unidade para os quadros de unidade na tela,
	permitindo alternar rapidamente entre alvos amigáveis.

	Para usar, segure a ligação, depois toque nas
	teclas indicadas no seu alvo escolhido, então solte
	a ligação para mudar de alvo.

	Esta ligação é altamente recomendada para curadores em conteúdo
	de 5 jogadores, pois fornece um método extremamente rápido de
	mirar em grupos menores.

	Em raides, a complexidade da entrada necessária
	para isolar seu alvo preferido pode ser intimidante.
	Ver «Alternar cursor de raide» para uma alternativa.
]]; -- en:0f9384b6
L.DESC_EXTRAACTIONBUTTON1 = [[
	O botão de ação extra abriga uma habilidade temporária usada em
	diversas missões, cenários e encontros de chefe.

	Quando esta ligação não está definida, o botão de ação extra está sempre
	disponível no menu radial utilitário.

	Este botão aparece na sua barra de ação de controle como um botão de ação normal,
	mas você não pode mudar seu conteúdo.
]]; -- en:6dd42998
L.DESC_INTERACTTARGET = [[
	Permite que você interaja com NPCs e objetos no mundo do jogo.

	Tem a mesma capacidade do cursor central, mas não exige que você
	aponte o cursor ou a mira diretamente para o alvo.

	Objetos interativos são destacados quando estão no alcance.
]]; -- en:b1478add
L.DESC_JUMP = [[
	Também pode ser usado para nadar para cima embaixo d'água, subir com
	montarias voadoras e decolar ou bater asas para cima em montaria de dragão.

	Saltar é útil para cobrir lacunas no movimento enquanto faz uma
	ação à mão esquerda que exige seu polegar.

	Em uma configuração normal, o stick esquerdo controla seu movimento.
	Se precisa pressionar uma combinação do direcional em movimento,
	saltar pode servir para manter o impulso para frente, enquanto retira
	brevemente o polegar do stick.
]]; -- en:4c032315
L.DESC_KEY_BUTTON1 = [[
	Usado para alternar o cursor livre, permitindo usar seu stick de câmera como um ponteiro de mouse.
]]; -- en:fd3d111a
L.DESC_KEY_BUTTON2 = [[
	Usado para alternar o cursor centralizado, permitindo interagir com objetos e personagens
	no mundo do jogo, em uma posição central fixa do mouse.
]]; -- en:2f5c87e4
L.DESC_QUICK_MENU = [[
	Um menu de acesso rápido que reúne ações comuns realizadas
	durante o jogo, como rolar dados para saque em grupo, cancelar
	buffs ou usar um item das mochilas.
]]; -- en:0365846b
L.DESC_RAID_CURSOR = [[
	Alterna um cursor que se prende aos seus
	quadros de unidade na tela, permitindo curar jogadores amigáveis
	mantendo outro alvo.

	O cursor de raide também pode ser configurado para mirar diretamente,
	onde mover o cursor mudará seu alvo atual.

	Durante o uso, o cursor de raide ocupa um conjunto de
	combinações de direcional para controlar a posição do cursor.

	No modo de redirecionamento, o cursor não redireciona macros ou
	magias ambíguas, como a Penitência de um sacerdote.

	Ver «Mirar em quadros de unidade» para uma alternativa.
]]; -- en:cacdf9c0
L.DESC_RING_CUSTOM = [[
	Um menu radial onde você pode adicionar seus itens, magias, macros e
	montarias para os quais não quer sacrificar espaço da barra de ação.

	Para usar, segure a ligação, incline o stick na direção
	do item que quer selecionar e solte a ligação.

	Para remover itens, siga o aviso da dica de ferramenta quando estiver
	com o item em foco.
]]; -- en:159abd06
L.DESC_RING_MENU = [[
	Um menu radial que reúne painéis comuns e ações frequentes
	em um único lugar para acesso rápido.

	O menu também pode ser acessado pelo menu do jogo sem uma
	ligação separada, trocando de página.
]]; -- en:7ee244a1
L.DESC_RING_PET = [[
	Um menu radial que permite controlar seu mascote atual.
]]; -- en:b1c4b5d3
L.DESC_RING_UTILITY = [[
	Um menu radial onde você pode adicionar seus itens, magias, macros e
	montarias para os quais não quer sacrificar espaço da barra de ação.

	Para usar, segure a ligação, incline o stick na direção
	do item que quer selecionar e solte a ligação.

	Para adicionar itens ao menu, siga o aviso do cursor de interface,
	ou pegue algo com o cursor do mouse e pressione a ligação
	para soltá-lo no menu.

	Para remover itens, siga o aviso da dica de ferramenta quando estiver
	com o item em foco.

	O menu radial utilitário adiciona automaticamente itens de missão e habilidades
	temporárias que você não tenha colocado em sua barra de ação.
]]; -- en:de107e96
L.DESC_TARGETNEARESTENEMY = [[
	Alterna entre os alvos inimigos mais próximos à sua frente.
	Sem um alvo atual, o inimigo mais central será selecionado.
	Caso contrário, percorrerá os alvos mais próximos.

	Segure para destacar alvos antes de decidir
	trocar de alvo.

	Recomendado para uso como ligação secundária de seleção de alvo,
	ou como ligação principal em jogabilidade casual ou se
	o escaneamento de alvos exige precisão demais para ser confortável.

	Não recomendado para masmorras ou outros cenários de alta precisão.
]]; -- en:981bc29c
L.DESC_TARGETSCANENEMY = [[
	Escaneia inimigos em um cone estreito à sua frente.
	Segure para destacar alvos antes de decidir
	trocar de alvo.

	Especialmente útil para trocar rapidamente de alvos
	em combate com alta precisão.

	A prioridade de alvo é enviesada pela mira, ou seja, o
	alvo mais próximo do centro do cone será
	selecionado primeiro. Isso pode priorizar um
	alvo distante sobre um mais próximo, se o alvo distante
	estiver mais próximo do centro do cone.

	Recomendado como ligação principal de seleção de alvo para a maioria dos jogadores.
]]; -- en:2de05bb9
L.DESC_TOGGLEAUTORUN = [[
	A corrida automática fará seu personagem continuar se movendo
	na direção em que está olhando sem nenhuma entrada de sua parte.

	A corrida automática é útil para aliviar a fadiga do polegar durante
	longos períodos de movimento, ou para liberar o polegar para fazer outras coisas enquanto se move.
]]; -- en:9e97af4b
L.DESC_TOGGLEGAMEMENU = [[
	A ligação de menu gerencia todas as funcionalidades que ocorrem ao pressionar
	a tecla Esc em um teclado. Ela trata de diferentes ações com base no
	estado atual do jogo.

	Se houver ações em andamento relacionadas a magias ou seleção de alvos,
	elas serão canceladas. Pressionar a ligação com um alvo ativo
	o limpará. Pressionar a ligação durante a conjuração de uma magia
	interromperá a conjuração.

	A ligação também trata de vários outros casos dependendo do que está
	atualmente exibido na tela. Por exemplo, se um painel
	está aberto, como o grimório, a ligação realizará a
	ação necessária para fechá-lo ou ocultá-lo.

	Se nenhum dos casos acima se aplicar, o menu do jogo abrirá ou
	fechará quando pressionado.
]]; -- en:adfccfe4
L.DEVICE_DESC_PLAYSTATION4 = [[
	O controle PlayStation 4, também conhecido como DualShock 4, é o controle da geração anterior da Sony.

	É um controle rico em recursos com touchpad, controles de movimento e suporte para todos os seus botões no jogo.

	Para aproveitar todos os recursos, talvez precise instalar o PlayStation Accessories (Windows).
]]; -- en:7bea4ad9
L.DEVICE_DESC_PLAYSTATION5 = [[
	O controle PlayStation 5, também conhecido como DualSense, é atualmente o melhor controle para World of Warcraft.

	É o controle mais completo disponível, com controles de movimento, touchpad e, no caso da variante Edge, paletas traseiras nativas.
	Todos os botões do controle podem ser usados no jogo.

	Para aproveitar todos os recursos, talvez precise instalar o PlayStation Accessories (Windows).
]]; -- en:c5f15091
L.DEVICE_DESC_STEAMDECK = [[
	Os Steam Decks normalmente executam World of Warcraft via Proton através do cliente Steam.

	Ao jogar via Steam, o dispositivo deve usar um perfil de jogo que cubra pelo menos um layout Xbox padrão.

	Controle com trackpad de mouse fornece uma base sólida.

	Os Steam Decks não podem usar suas paletas nativamente em World of Warcraft.
	As paletas podem ser mapeadas via emulação, ou com teclas de teclado nas configurações do Steam Input.

	A predefinição Steam Deck no jogo também pode ser adequada para outros computadores portáteis, devido ao layout de controle semelhante.
]]; -- en:2a5e4173
L.DEVICE_DESC_SWITCHPRO = [[
	O controle Nintendo Switch Pro tem um layout semelhante ao controle Xbox, mas com rótulos de botão invertidos.

	O controle Pro tem quatro botões centrais, dando uma leve vantagem sobre um controle Xbox padrão.

	O controle Nintendo Switch 2 Pro não pode usar suas paletas ou botão C nativamente no jogo.
	Com software externo, como Steam ou reWASD, eles podem ser mapeados para teclas de teclado, permitindo o uso no jogo.
]]; -- en:79260874
L.DEVICE_DESC_XBOX = [[
	As variantes Xbox são os controles mais comuns e são bem suportadas por World of Warcraft.

	O controle Xbox Elite não pode usar suas paletas nativamente no jogo, mas elas podem ser usadas para simular outros botões do controle,
	usando o aplicativo Xbox Accessories (Windows).

	Com software externo, como Steam ou reWASD, as paletas podem ser mapeadas para teclas de teclado, permitindo o uso no jogo.

	O botão central é reservado para o Xbox Guide e não pode ser usado no jogo.

	Também recomendado para Steam Input, consistente com o controle Xbox 360 que ele emula.
]]; -- en:654501d3
L.DISC_KEY_BUTTON1 = [[
	Enquanto um dos seus botões emula clique esquerdo, esta ligação não pode ser alterada.
]]; -- en:e811ebc6
L.DISC_KEY_BUTTON2 = [[
	Enquanto um dos seus botões emula clique direito, esta ligação não pode ser alterada.
]]; -- en:b85c78b2
L.EXPORT_DATA_TEXT = [[

|cFFFFFF00Exportar|r

Selecione quais dados quer exportar. Uma string será gerada abaixo, que você pode colar em outro cliente, ou compartilhar com outras pessoas.

Use %s para copiar a string.
]]; -- en:1741e6a6
L.GFX_GENERAL_INFO = [[
	Selecione os gráficos de controle que mais se parecem com a aparência do seu controle.

	Escolher os gráficos não muda como seu controle funciona, apenas muda a aparência da interface.

	Os gráficos são usados para mostrar quais botões estão atualmente vinculados a quais ações, e para fornecer uma referência visual do layout do seu controle.

	Algumas recomendações de configurações opcionais são fornecidas com base na sua escolha.
]]; -- en:54457360
L.IMPORT_DATA_TEXT = [[

|cFFFFFF00Importar|r

Cole uma string exportada abaixo, então carregue e selecione os dados que quer importar. Os dados importados sobrescreverão seus dados atuais quando aplicável.

Use %s para copiar a string da fonte, e %s para colar a string abaixo.
]]; -- en:145f78fb
L.IMPORT_FAILED_TEXT = [[

|cFFFFFF00Importar|r

Falha na importação:
]]; -- en:a7555666
L.LINK_COPY = [[
	Link para %s.

	Ctrl+A para selecionar e Ctrl+C para copiar.

	Cole (Ctrl+V) o link no seu navegador.
]]; -- en:3f396345
L.LINK_DISCORD_TEXT = [[
	A comunidade onde você pode encontrar suporte, discutir jogabilidade, compartilhar ideias e encontrar jogadores afins.

	Clique aqui para entrar no servidor.
]]; -- en:e2f9740c
L.LINK_PATREON_TEXT = [[
	O desenvolvimento e manutenção deste addon exige muito tempo e esforço,
	mas o ConsolePort sempre será totalmente gratuito.

	Torne-se um apoiador no Patreon para desbloquear sua insígnia do Discord e, em troca, apoiar o futuro do projeto.

	Clique aqui para se tornar um patrono.
]]; -- en:3cc9532e
L.LINK_PAYPAL_TEXT = [[
	As doações são reinvestidas diretamente no desenvolvimento e manutenção do addon.

	Qualquer contribuição, grande ou pequena, é muito apreciada.

	Clique aqui para doar via PayPal.
]]; -- en:28c6265a
L.REMOVE_RING_TEXT = [[|cFFFFFF00Remover %s|r
Tem certeza que quer remover o menu radial?]]; -- en:1a461a1a
L.RING_MENU_DESC = [[Crie seus próprios menus radiais onde pode adicionar seus itens, magias, macros e montarias para os quais não quer sacrificar espaço da barra de ação.

Para usar, segure a ligação selecionada, incline o stick na direção do item que quer selecionar e solte a ligação.

O menu radial padrão, o |CFF00FF00Menu radial utilitário|r, tem propriedades especiais para facilitar missões e interação com o mundo, e não é estático. Adicionará e removerá itens automaticamente conforme necessário.

Se quer criar um menu radial para usar em sua rotação e não apenas para utilidade, é altamente recomendado usar um menu radial personalizado para este propósito.]]; -- en:39d4577b
L.SELECTED_RING_TEXT = [[Este é o seu menu radial atualmente selecionado.
Quando você pressiona e segura a ligação, todas as suas habilidades selecionadas aparecerão em um menu radial na tela.

Incline seu stick radial na direção da habilidade ou item que quer usar, então solte a ligação para confirmar.]]; -- en:2cdfa5d3
L.SET_RING_BINDING_TEXT = [[
|cFFFFFF00Definir ligação|r

Pressione uma combinação de botões para selecionar uma nova ligação para este menu radial.

]]; -- en:1c0e03f4
L.SLOT_NO_BINDING = [[
|cFFFFFF00Definir ligação|r

%s em %s não tem uma ligação atribuída.

Pressione uma combinação de botões para selecionar uma nova ligação para este slot.

]]; -- en:74326275
L.SLOT_SET_BINDING = [[
|cFFFFFF00Definir ligação|r

Pressione uma combinação de botões para selecionar uma nova ligação para %s.

]]; -- en:d1933130
---------------------------------------------------------------
-- Literals
---------------------------------------------------------------
L['2D deadzone for camera that takes into account pitch and yaw movement together.'] = 'Zona morta 2D para câmera que considera o movimento de inclinação e guinada juntos.';
L['2D deadzone for movement that takes into account X and Y movement together.'] = 'Zona morta 2D para movimento que considera o movimento X e Y juntos.';
L['A button cluster for all modifiers of a single button.'] = 'Um cluster de botões para todos os modificadores de um único botão.';
L['A cluster bar with a toolbar below it, laid out horizontally.'] = 'Uma barra cluster com uma barra de ferramentas abaixo dela, disposta horizontalmente.';
L['A cluster bar with a toolbar below it.'] = 'Uma barra cluster com uma barra de ferramentas abaixo dela.';
L['A divider to separate elements.'] = 'Um divisor para separar elementos.';
L['A friendly soft target can be acquired while having an enemy hard target.'] = 'Um alvo flexível amigável pode ser adquirido enquanto se tem um alvo fixo inimigo.';
L['A regular action bar.'] = 'Uma barra de ação normal.';
L['A ring of buttons for pet commands.'] = 'Um menu radial de botões para comandos de mascote.';
L['A toolbar with XP indicators, shortcuts, class specific bars, and miscellaneous information.'] = 'Uma barra de ferramentas com indicadores de XP, atalhos, barras específicas de classe e informações diversas.';
L['About'] = 'Sobre';
L['Acceleration of cursor per second as it continues to move.'] = 'Aceleração do cursor por segundo enquanto continua a se mover.';
L['Accent Color'] = 'Cor de destaque';
L['Accept Button'] = 'Botão Aceitar';
L['Action Bar Configuration'] = 'Configuração da barra de ação';
L['Action bar is scaled separately.'] = 'A barra de ação é escalonada separadamente.';
L['Action Bar Loadout'] = 'Loadout da barra de ação';
L['Action Bar Loadout (Deprecated)'] = 'Loadout da barra de ação (obsoleto)';
L['Action Bar Presets'] = 'Predefinições da barra de ação';
L['Action Bar Setup'] = 'Configuração da barra de ação';
L['Action Button'] = 'Botão de ação';
L['Action Button Group'] = 'Grupo de botões de ação';
L['Action Page'] = 'Página de ação';
L['Action Page Condition'] = 'Condição da página de ação';
L['Action Page Response'] = 'Resposta da página de ação';
L['Active Color'] = 'Cor ativa';
L['Active Device'] = 'Dispositivo ativo';
L['Add a new element to your loadout.'] = 'Adicione um novo elemento ao seu loadout.';
L['Add to %s'] = 'Adicionar a %s';
L['Add, remove or reset a frame from cursor stack.'] = 'Adicione, remova ou redefina um quadro da pilha do cursor.';
L['Affects both mouse and gamepad.'] = 'Afeta tanto o mouse quanto o controle.';
L['Alignment'] = 'Alinhamento';
L['Alignment of the counter text on buttons.'] = 'Alinhamento do texto do contador nos botões.';
L['Alignment of the hotkey text on buttons.'] = 'Alinhamento do texto da tecla rápida nos botões.';
L['Alignment of the macro text on buttons.'] = 'Alinhamento do texto da macro nos botões.';
L['All combines all connected devices into one.'] = '«Todos» combina todos os dispositivos conectados em um só.';
L['Allow binding discrete radial stick inputs.'] = 'Permitir vincular entradas radiais discretas do stick.';
L['Allow binding multiple combos to the same binding.'] = 'Permitir vincular múltiplos combos à mesma ligação.';
L['Allow Binding Overlap'] = 'Permitir sobreposição de ligações';
L['Allow cursor to interact with and show preference for group loot frames.'] = 'Permitir que o cursor interaja e dê preferência aos quadros de saque em grupo.';
L['Allow cursor to interact with and show preference for popups and static dialogs.'] = 'Permitir que o cursor interaja e dê preferência a popups e diálogos estáticos.';
L['Allow cursor to interact with the entire interface, not only panels.'] = 'Permitir que o cursor interaja com toda a interface, não apenas com painéis.';
L['Allow Radial Bindings'] = 'Permitir ligações radiais';
L['Allows the use of the touchpad to control cursor movement.'] = 'Permite o uso do touchpad para controlar o movimento do cursor.';
L['Alphabet to use for dictionary suggestions and word processing.'] = 'Alfabeto para sugestões de dicionário e processamento de palavras.';
L['Always keep cursor centered and visible when controlling camera.'] = 'Manter sempre o cursor centralizado e visível ao controlar a câmera.';
L['Always Show All Buttons'] = 'Mostrar sempre todos os botões';
L['Always Show Mouse Cursor'] = 'Mostrar sempre o cursor do mouse';
L['Always show nameplate for soft enemy target.'] = 'Mostrar sempre a placa de nome para alvo flexível inimigo.';
L['Always show nameplate for soft friendly target.'] = 'Mostrar sempre a placa de nome para alvo flexível amigável.';
L['Always show tooltip for an automatically acquired target, as long as it exists.'] = 'Mostrar sempre a dica de ferramenta para um alvo adquirido automaticamente, enquanto ele existir.';
L['An action button in a group.'] = 'Um botão de ação em um grupo.';
L['Analog Movement'] = 'Movimento analógico';
L['Anchor'] = 'Âncora';
L['Anchor point of parent to pair with.'] = 'Ponto de âncora do pai com o qual emparelhar.';
L['Anchor point of the counter text on buttons.'] = 'Ponto de âncora do texto do contador nos botões.';
L['Anchor point of the hotkey icon on group buttons.'] = 'Ponto de âncora do ícone de tecla rápida nos botões de grupo.';
L['Anchor point of the hotkey text on buttons.'] = 'Ponto de âncora do texto da tecla rápida nos botões.';
L['Anchor point of the macro text on buttons.'] = 'Ponto de âncora do texto da macro nos botões.';
L['Anchor point to attach.'] = 'Ponto de âncora para anexar.';
L['Apply default settings to the current category or all settings.'] = 'Aplicar configurações padrão à categoria atual ou a todas as configurações.';
L['Arc Allowance'] = 'Tolerância de arco';
L['Are you sure you want to delete %s from %s?'] = 'Tem certeza que quer excluir %s de %s?';
L['Are you sure you want to overwrite %s with %s?'] = 'Tem certeza que quer sobrescrever %s com %s?';
L['Are you sure you want to regenerate the keyboard dictionary? You will lose all custom phrases.'] = 'Tem certeza que quer regenerar o dicionário do teclado? Você perderá todas as frases personalizadas.';
L['Are you sure you want to reset all device profiles?'] = 'Tem certeza que quer redefinir todos os perfis de dispositivo?';
L['Are you sure you want to reset the keyboard layout?'] = 'Tem certeza que quer redefinir o layout do teclado?';
L['Are you sure you want to reset your device profile?'] = 'Tem certeza que quer redefinir seu perfil de dispositivo?';
L['Are you sure you want to wipe the keyboard dictionary? It currently contains %d words.'] = 'Tem certeza que quer limpar o dicionário do teclado? Atualmente contém %d palavras.';
L['Area where the interact key can find a suitable target.'] = 'Área onde a tecla de interação pode encontrar um alvo adequado.';
L['Artwork flavor.'] = 'Variante de artwork.';
L['Artwork for the interface.'] = 'Artwork para a interface.';
L['Artwork style.'] = 'Estilo de artwork.';
L['Assign or clear bindings for this set.'] = 'Atribuir ou limpar ligações para este conjunto.';
L['Auto-adjusts your camera, allowing you to control movement with a single stick.'] = 'Ajusta automaticamente sua câmera, permitindo controlar o movimento com um único stick.';
L['Auto-Sell Gear Level Limit'] = 'Limite de nível de equipamento para autovenda';
L['Auto-Sell Junk'] = 'Vender lixo automaticamente';
L['Auto-set target to match soft target.'] = 'Definir o alvo automaticamente para corresponder ao alvo flexível.';
L['Automatic Binding Backups'] = 'Backups automáticos de ligações';
L['Automatic Cursor Timeout'] = 'Tempo limite automático do cursor';
L['Automatic Tooltip Duration'] = 'Duração automática da dica de ferramenta';
L['Automatically add tracked quest items and extra spells to main utility ring.'] = 'Adicionar automaticamente itens de missão rastreados e magias extras ao menu radial utilitário principal.';
L['Automatically backup your bindings when you change them, for import and export.'] = 'Fazer backup automático de suas ligações quando as alterar, para importar e exportar.';
L['Automatically Bind Extra Items'] = 'Vincular itens extras automaticamente';
L['Automatically Control Cursor Pickups'] = 'Controlar coletas do cursor automaticamente';
L['Automatically control cursor when picking up items.'] = 'Controlar automaticamente o cursor ao pegar itens.';
L['Automatically sell junk when interacting with a merchant.'] = 'Vender lixo automaticamente ao interagir com um comerciante.';
L['Axis Interpretation'] = 'Interpretação de eixo';
L['Battery Level'] = 'Nível da bateria';
L['Binding Catch Timeframe'] = 'Janela de captura de ligação';
L['Blend Mode'] = 'Modo de mistura';
L['Blend mode of the artwork.'] = 'Modo de mistura do artwork.';
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
L['Border Vertex Color'] = 'Cor de vértice da borda';
L['Breadth'] = 'Largura';
L['Breadth of the divider.'] = 'Largura do divisor.';
L['Button %d'] = 'Botão %d';
L['Button or combination used to click when a given condition applies, but act as a normal binding otherwise.'] = 'Botão ou combinação usado para clicar quando uma condição se aplica, mas agir como uma ligação normal caso contrário.';
L['Button Set'] = 'Conjunto de botões';
L['Button that emulates '] = 'Botão que emula ';
L['Button that emulates the '] = 'Botão que emula a ';
L['Button to cancel or exit the quick menu.'] = 'Botão para cancelar ou sair do menu rápido.';
L['Button to handle cancel actions, such as exiting menus.'] = 'Botão para lidar com ações de cancelamento, como sair de menus.';
L['Button to handle contextual actions, such as adding items to the utility ring or passing on loot.'] = 'Botão para lidar com ações contextuais, como adicionar itens ao menu radial utilitário ou passar no saque.';
L['Button to handle contextual actions, such as adding items to the utility ring.'] = 'Botão para lidar com ações contextuais, como adicionar itens ao menu radial utilitário.';
L['Button to insert suggested word.'] = 'Botão para inserir palavra sugerida.';
L['Button to move the cursor down.'] = 'Botão para mover o cursor para baixo.';
L['Button to move the cursor left.'] = 'Botão para mover o cursor para a esquerda.';
L['Button to move the cursor right.'] = 'Botão para mover o cursor para a direita.';
L['Button to move the cursor up.'] = 'Botão para mover o cursor para cima.';
L['Button to replicate left click. This is the primary interface action.'] = 'Botão para replicar o clique esquerdo. Esta é a ação principal de interface.';
L['Button to replicate right click. This is the secondary interface action.'] = 'Botão para replicar o clique direito. Esta é a ação secundária de interface.';
L['Button to select next suggested word.'] = 'Botão para selecionar a próxima palavra sugerida.';
L['Button to select previous suggested word.'] = 'Botão para selecionar a palavra sugerida anterior.';
L['Button to use for combo hotkey 1.'] = 'Botão para usar com combo 1.';
L['Button to use for combo hotkey 2.'] = 'Botão para usar com combo 2.';
L['Button to use for combo hotkey 3.'] = 'Botão para usar com combo 3.';
L['Button to use for combo hotkey 4.'] = 'Botão para usar com combo 4.';
L['Button to use for combo hotkey 5.'] = 'Botão para usar com combo 5.';
L['Button to use for combo hotkey 6.'] = 'Botão para usar com combo 6.';
L['Button to use for combo hotkey 7.'] = 'Botão para usar com combo 7.';
L['Button to use for combo hotkey 8.'] = 'Botão para usar com combo 8.';
L['Button to use to erase characters.'] = 'Botão para usar para apagar caracteres.';
L['Button to use to move the cursor leftwards.'] = 'Botão para usar para mover o cursor para a esquerda.';
L['Button to use to move the cursor rightwards.'] = 'Botão para usar para mover o cursor para a direita.';
L['Button to use to trigger the enter command.'] = 'Botão para usar para acionar o comando Enter.';
L['Button to use to trigger the escape command.'] = 'Botão para usar para acionar o comando Esc.';
L['Button to use to trigger the space command.'] = 'Botão para usar para acionar o comando Espaço.';
L['Button used to confirm a selected item from a ring.'] = 'Botão usado para confirmar um item selecionado de um menu radial.';
L['Button used to remove a selected item from an editable ring.'] = 'Botão usado para remover um item selecionado de um menu radial editável.';
L['Button |cFF00FFFF%s|r'] = 'Botão |cFF00FFFF%s|r';
L['Buttons'] = 'Botões';
L['Buttons in the cluster bar.'] = 'Botões na barra cluster.';
L['Buttons in the group.'] = 'Botões no grupo.';
L['By default, shows modifiers on mouseover and on cooldown.'] = 'Por padrão, mostra modificadores ao passar o mouse e durante o tempo de recarga.';
L['Camera 2D Deadzone'] = 'Zona morta 2D da câmera';
L['Camera Look'] = 'Olhar da câmera';
L['Camera Look is a temporary turn of the camera based on the current analog input.'] = 'O olhar da câmera é uma rotação temporária da câmera com base na entrada analógica atual.';
L['Camera Pitch Axis'] = 'Eixo de inclinação da câmera';
L['Camera Pitch Speed'] = 'Velocidade de inclinação da câmera';
L['Camera Pitch-Only Deadzone'] = 'Zona morta apenas de inclinação da câmera';
L['Camera speed for pitch - moving up/down.'] = 'Velocidade da câmera para inclinação — mover para cima/baixo.';
L['Camera speed for yaw - turning left/right.'] = 'Velocidade da câmera para guinada — virar esquerda/direita.';
L['Camera Yaw Axis'] = 'Eixo de guinada da câmera';
L['Camera Yaw Speed'] = 'Velocidade de guinada da câmera';
L['Camera Yaw-Only Deadzone'] = 'Zona morta apenas de guinada da câmera';
L['Cancel and clear cursor'] = 'Cancelar e limpar cursor';
L['Cancel Button'] = 'Botão Cancelar';
L['Cannot open configuration menu in combat.'] = 'Não é possível abrir o menu de configuração em combate.';
L['Casting Bar'] = 'Barra de conjuração';
L['Center Gap'] = 'Espaço central';
L['Center gap, as fraction of overall crosshair size.'] = 'Espaço central, como fração do tamanho total da mira.';
L['Change before touchpad moves the cursor.'] = 'Limite antes do touchpad mover o cursor.';
L['Change bluetooth state for active device.'] = 'Alterar estado Bluetooth para o dispositivo ativo.';
L['Change or print a value from the active device configuration.'] = 'Alterar ou imprimir um valor da configuração do dispositivo ativo.';
L['Character Specific'] = 'Específico do personagem';
L['Choose a negative value to invert the axis.'] = 'Escolha um valor negativo para inverter o eixo.';
L['Class Bar'] = 'Barra de classe';
L['Clear all items from this set.'] = 'Limpar todos os itens deste conjunto.';
L['Clear Binding'] = 'Limpar ligação';
L['Clear configured gamepad bindings and reload interface.'] = 'Limpar ligações de controle configuradas e recarregar interface.';
L['Clear Focus Deadzone'] = 'Zona morta para limpar foco';
L['Clear Focus Mode'] = 'Modo de limpeza de foco';
L['Clear Focus Time'] = 'Tempo de limpeza de foco';
L['Clear Slot'] = 'Limpar slot';
L['Clear slot or binding'] = 'Limpar slot ou ligação';
L['Click here to reset your device profile.'] = 'Clique aqui para redefinir seu perfil de dispositivo.';
L['Click on Down'] = 'Clicar ao pressionar';
L['Click Override Button'] = 'Botão de substituição de clique';
L['Click Override Condition'] = 'Condição de substituição de clique';
L['Cluster Action Bar'] = 'Barra de ação cluster';
L['Cluster Handle'] = 'Manípulo cluster';
L['Cluster Modifier Toggle'] = 'Alternador de modificador cluster';
L['Clusters'] = 'Clusters';
L['Color accent of radial menu items.'] = 'Acento de cor dos itens do menu radial.';
L['Color of a partially selected slice.'] = 'Cor de uma fatia parcialmente selecionada.';
L['Color of the active slice.'] = 'Cor da fatia ativa.';
L['Color of the cooldown swipe effect on buttons.'] = 'Cor do efeito de varredura do tempo de recarga nos botões.';
L['Color of the counter text on buttons.'] = 'Cor do texto do contador nos botões.';
L['Color of the crosshair.'] = 'Cor da mira.';
L['Color of the divider.'] = 'Cor do divisor.';
L['Color of the hotkey text on buttons.'] = 'Cor do texto da tecla rápida nos botões.';
L['Color of the macro text on buttons.'] = 'Cor do texto da macro nos botões.';
L['Color of the main XP bar.'] = 'Cor da barra de XP principal.';
L['Color of the mana indicator on buttons.'] = 'Cor do indicador de mana nos botões.';
L['Color of the range indicator on buttons.'] = 'Cor do indicador de alcance nos botões.';
L['Color of the sticky selection slice.'] = 'Cor da fatia de seleção fixa.';
L['Color of the vertices on the border of buttons.'] = 'Cor dos vértices na borda dos botões.';
L['Color tint for combo hotkey 1.'] = 'Matiz de cor para combo 1.';
L['Color tint for combo hotkey 2.'] = 'Matiz de cor para combo 2.';
L['Color tint for combo hotkey 3.'] = 'Matiz de cor para combo 3.';
L['Color tint for combo hotkey 4.'] = 'Matiz de cor para combo 4.';
L['Color tint for combo hotkey 5.'] = 'Matiz de cor para combo 5.';
L['Color tint for combo hotkey 6.'] = 'Matiz de cor para combo 6.';
L['Color tint for combo hotkey 7.'] = 'Matiz de cor para combo 7.';
L['Color tint for combo hotkey 8.'] = 'Matiz de cor para combo 8.';
L['Combine with '] = 'Combinar com ';
L['Combine with use on demand for full cursor control.'] = 'Combine com uso sob demanda para controle total do cursor.';
L['Combined Input Overlap Time'] = 'Tempo de sobreposição de entrada combinada';
L['Combo Button 1'] = 'Botão combo 1';
L['Combo Button 2'] = 'Botão combo 2';
L['Combo Button 3'] = 'Botão combo 3';
L['Combo Button 4'] = 'Botão combo 4';
L['Combo Button 5'] = 'Botão combo 5';
L['Combo Button 6'] = 'Botão combo 6';
L['Combo Button 7'] = 'Botão combo 7';
L['Combo Button 8'] = 'Botão combo 8';
L['Combo Color 1'] = 'Cor combo 1';
L['Combo Color 2'] = 'Cor combo 2';
L['Combo Color 3'] = 'Cor combo 3';
L['Combo Color 4'] = 'Cor combo 4';
L['Combo Color 5'] = 'Cor combo 5';
L['Combo Color 6'] = 'Cor combo 6';
L['Combo Color 7'] = 'Cor combo 7';
L['Combo Color 8'] = 'Cor combo 8';
L['Command Modifier'] = 'Modificador de comando';
L['Configure the casting bar.'] = 'Configurar a barra de conjuração.';
L['Configure the class related bar.'] = 'Configurar a barra relacionada à classe.';
L['Connect your controller.'] = 'Conecte seu controle.';
L['Connected device(s):'] = 'Dispositivo(s) conectado(s):';
L['ConsolePort'] = 'ConsolePort';
L['Context Button'] = 'Botão de contexto';
L['Controls the cutoff range where an interactable target or object can be found.'] = 'Controla o alcance de corte onde um alvo ou objeto interativo pode ser encontrado.';
L['Controls when your character starts running. Expressed as a fraction of your total movement stick radius.'] = 'Controla quando seu personagem começa a correr. Expresso como fração do raio total do seu stick de movimento.';
L['Copy %s from %s:'] = 'Copiar %s de %s:';
L['Copy this element to a new name.'] = 'Copiar este elemento com um novo nome.';
L['Correlation between stick position and pie selection.'] = 'Correlação entre posição do stick e seleção em pizza.';
L['Create Binding Preset'] = 'Criar predefinição de ligação';
L['Critical, Low, Medium, High, Wired/Charging, or Unknown/Disconnected.'] = 'Crítico, Baixo, Médio, Alto, Com fio/Carregando, ou Desconhecido/Desconectado.';
L['Crossbar: Minimal'] = 'Crossbar: Minimalista';
L['Crossbar: Triggers'] = 'Crossbar: Gatilhos';
L['Crossbar: Triple'] = 'Crossbar: Triplo';
L['Crosshair'] = 'Mira';
L['Cursor Acceleration'] = 'Aceleração do cursor';
L['Cursor acceleration for touchpad control.'] = 'Aceleração do cursor para controle por touchpad.';
L['Cursor appears on demand, instead of in response to a panel showing up.'] = 'O cursor aparece sob demanda, em vez de em resposta a um painel aparecer.';
L['Cursor Center Position'] = 'Posição central do cursor';
L['Cursor hides when you start moving, if free of obstacles.'] = 'O cursor se esconde quando você começa a se mover, se estiver livre de obstáculos.';
L['Cursor Max Speed'] = 'Velocidade máxima do cursor';
L['Cursor Move Threshold'] = 'Limite de movimento do cursor';
L['Cursor Reticle Targeting'] = 'Mira do cursor';
L['Cursor Speed'] = 'Velocidade do cursor';
L['Cursor speed for touchpad control.'] = 'Velocidade do cursor para controle por touchpad.';
L['Cursor Start Speed'] = 'Velocidade inicial do cursor';
L['Custom color to use for the touchpad LED.'] = 'Cor personalizada para o LED do touchpad.';
L['Cyan'] = 'Ciano';
L['Deadzone for simple point-to-select rings.'] = 'Zona morta para menus radiais simples de apontar e selecionar.';
L['Deadzone to clear focus after intercepting stick input.'] = 'Zona morta para limpar foco após interceptar entrada do stick.';
L['Decrease'] = 'Diminuir';
L['Decrease lightness'] = 'Diminuir luminosidade';
L['Decrease opacity'] = 'Diminuir opacidade';
L['Default to '] = 'Padrão para ';
L['Delay before reactivating interface cursor after leaving combat, in seconds.'] = 'Atraso antes de reativar o cursor de interface após sair de combate, em segundos.';
L['Delay before starting to adjust angle when camera control is idle, in seconds.'] = 'Atraso antes de começar a ajustar o ângulo quando o controle de câmera está ocioso, em segundos.';
L['Delay is doubled if you are dead.'] = 'O atraso é dobrado se estiver morto.';
L['Delay until a movement is repeated, when holding down a direction, in seconds.'] = 'Atraso até um movimento ser repetido, ao segurar uma direção, em segundos.';
L['Delay until the first movement is repeated, when holding down a direction, in seconds.'] = 'Atraso até o primeiro movimento ser repetido, ao segurar uma direção, em segundos.';
L['Delete this element.'] = 'Excluir este elemento.';
L['Depth'] = 'Profundidade';
L['Depth of the divider.'] = 'Profundidade do divisor.';
L['Detected %d out of 8 possible sensors.'] = 'Detectado %d de 8 sensores possíveis.';
L['Detected %d valid button(s).'] = 'Detectado %d botão(ões) válido(s).';
L['Device Information'] = 'Informações do dispositivo';
L['Device Mappings'] = 'Mapeamentos do dispositivo';
L['Device Profiles'] = 'Perfis do dispositivo';
L['Device Selection'] = 'Seleção de dispositivo';
L['Device Settings'] = 'Configurações do dispositivo';
L['Diamond Grid'] = 'Grade em diamante';
L['Dictionary Match Alphabet'] = 'Alfabeto de correspondência do dicionário';
L['Dictionary Match Pattern'] = 'Padrão de correspondência do dicionário';
L['Direction for flyout buttons, such as portals, poisons, and pet utilities.'] = 'Direção para botões pop-out, como portais, venenos e utilitários de mascote.';
L['Direction of the button cluster.'] = 'Direção do cluster de botões.';
L['Disable Drag and Drop'] = 'Desativar arrastar e soltar';
L['Disable dragging and dropping abilities on action bars.'] = 'Desativar arrastar e soltar habilidades nas barras de ação.';
L['Disable free-roaming mouse cursor when you jump.'] = 'Desativar cursor livre do mouse ao saltar.';
L['Disable free-roaming mouse cursor when you use your sticks.'] = 'Desativar cursor livre do mouse ao usar os sticks.';
L['Disable Hotkey Rendering'] = 'Desativar renderização de teclas rápidas';
L['Disable if your mouse cursor is invisible.'] = 'Desative se o cursor do mouse estiver invisível.';
L['Disable repeated cursor movements - each click will only move the cursor once.'] = 'Desativar movimentos repetidos do cursor — cada clique moverá o cursor apenas uma vez.';
L['Disable Repeated Movement'] = 'Desativar movimento repetido';
L['Disable to use discrete legacy movement controls.'] = 'Desative para usar controles de movimento legados discretos.';
L['Disable Wrapping'] = 'Desativar empacotamento';
L['Disables customization to hotkeys on regular action bars.'] = 'Desativa a personalização de teclas rápidas em barras de ação normais.';
L['Disabling this may cause worse performance with many panels open.'] = 'Desativar isso pode causar pior desempenho com muitos painéis abertos.';
L['Disconnected'] = 'Desconectado';
L['Discord'] = 'Discord';
L['Display icon next to the power level for the current active gamepad.'] = 'Exibir ícone ao lado do nível de bateria para o controle ativo atual.';
L['Display power level for the current active gamepad.'] = 'Exibir nível de bateria para o controle ativo atual.';
L['Display power level status text for the current active gamepad.'] = 'Exibir texto de status do nível de bateria para o controle ativo atual.';
L['Display the action bar grid when picking up a spell on the cursor.'] = 'Exibir a grade da barra de ação ao pegar uma magia no cursor.';
L['Displays a briefing for newly acquired abilities.'] = 'Exibe um briefing para habilidades recém-adquiridas.';
L['Divider'] = 'Divisor';
L['Do you want to load settings for %s?'] = 'Quer carregar as configurações para %s?';
L['Does not affect actual ability to interact with the target, which may have a different range.'] = 'Não afeta a capacidade real de interagir com o alvo, que pode ter um alcance diferente.';
L['Donate via PayPal'] = 'Doar via PayPal';
L['Double Tap Modifier'] = 'Modificador de toque duplo';
L['Double Tap Timeframe'] = 'Janela de tempo do toque duplo';
L['Duration after using gamepad and mouse at the same time before switching to just one or the other, in milliseconds.'] = 'Duração após usar controle e mouse ao mesmo tempo antes de mudar para apenas um deles, em milissegundos.';
L['Duration under which a tooltip is displayed for an acquired target or interactable, in milliseconds.'] = 'Duração em que uma dica de ferramenta é exibida para um alvo adquirido ou objeto interativo, em milissegundos.';
L['Dynamic Pitch'] = 'Inclinação dinâmica';
L['Dynamic will use the button set that does not conflict with your '] = '«Dinâmico» usará o conjunto de botões que não entra em conflito com sua ';
L['E.g. '] = 'P. ex. ';
L['Edit Binding'] = 'Editar ligação';
L['Edit Slot'] = 'Editar slot';
L['Emulate P1 '] = 'Emular P1 ';
L['Emulate P2 '] = 'Emular P2 ';
L['Emulate P3 '] = 'Emular P3 ';
L['Emulate P4 '] = 'Emular P4 ';
L['Enable all modifier states for the cluster, including unmapped modifiers.'] = 'Ativar todos os estados de modificador para o cluster, incluindo modificadores não mapeados.';
L['Enable Animation'] = 'Ativar animação';
L['Enable casting bar ownership.'] = 'Ativar propriedade da barra de conjuração.';
L['Enable class bar ownership.'] = 'Ativar propriedade da barra de classe.';
L['Enable Cooldown Numbers'] = 'Ativar números de tempo de recarga';
L['Enable Group Loot'] = 'Ativar saque em grupo';
L['Enable interact key to interact with objects and creatures in the game world.'] = 'Ativar tecla de interação para interagir com objetos e criaturas no mundo do jogo.';
L['Enable interface cursor. Disable to use mouse-based interface interaction.'] = 'Ativar cursor de interface. Desative para usar interação de interface baseada em mouse.';
L['Enable Mouse Handling'] = 'Ativar gerenciamento do mouse';
L['Enable Player Interact'] = 'Ativar interagir com jogador';
L['Enable Popups'] = 'Ativar popups';
L['Enable separate strafe angle threshold for when your character is in the air.'] = 'Ativar limite de ângulo de movimento lateral separado para quando seu personagem está no ar.';
L['Enable Strafe Angle (Jump)'] = 'Ativar ângulo de movimento lateral (salto)';
L['Enable Tint'] = 'Ativar matiz';
L['Enable touch tap to press touchpad buttons.'] = 'Ativar toque tátil para pressionar os botões do touchpad.';
L['Enable Touchpad Cursor'] = 'Ativar cursor do touchpad';
L['Enable Vehicle'] = 'Ativar veículo';
L['Enable Watch Bars'] = 'Ativar barras de observação';
L['Enables a crosshair to reveal your hidden center cursor position at all times.'] = 'Ativa uma mira para revelar a posição do seu cursor central oculto a todo momento.';
L['Enables a radial on-screen keyboard that can be used to type messages.'] = 'Ativa um teclado radial na tela que pode ser usado para digitar mensagens.';
L['Enemy Soft Targeting'] = 'Alvo flexível inimigo';
L['Equippable items of poor quality will not be sold while your character is below this level.'] = 'Itens equipáveis de qualidade ruim não serão vendidos enquanto seu personagem estiver abaixo deste nível.';
L['Erase'] = 'Apagar';
L['Exit the vehicle you are currently controlling.'] = 'Sair do veículo que está controlando atualmente.';
L['Export'] = 'Exportar';
L['Export %s to a string:'] = 'Exportar %s para uma string:';
L['Export action page logic'] = 'Exportar lógica da página de ação';
L['Export All'] = 'Exportar tudo';
L['Export all your custom presets to a string that can be shared with others.'] = 'Exportar todas as suas predefinições personalizadas para uma string que pode ser compartilhada com outros.';
L['Export current options'] = 'Exportar opções atuais';
L['Export serialized settings for sharing or backup.'] = 'Exportar configurações serializadas para compartilhar ou fazer backup.';
L['Export this preset to a string that can be shared with others.'] = 'Exportar esta predefinição para uma string que pode ser compartilhada com outros.';
L['Expressed in milliseconds. Pressing any combination of modifier and button will cancel the effect.'] = 'Expresso em milissegundos. Pressionar qualquer combinação de modificador e botão cancelará o efeito.';
L['Fade Buttons'] = 'Esmaecer botões';
L['Fade out the pet ring when not moused over.'] = 'Esmaecer o menu radial do mascote quando o mouse não está sobre ele.';
L['Fade out the watch bars when not mousing over the toolbar.'] = 'Esmaecer as barras de observação quando o mouse não está sobre a barra de ferramentas.';
L['Fade Watch Bars'] = 'Esmaecer barras de observação';
L['Filter Condition'] = 'Condição de filtro';
L['Filter condition to find raid cursor frames, as a boolean expression in Lua.'] = 'Condição de filtro para encontrar quadros do cursor de raide, como expressão booleana em Lua.';
L['Flavor'] = 'Variante';
L['Flyout Direction'] = 'Direção pop-out';
L['FOAS Adjust Delay'] = 'Atraso de ajuste FOAS';
L['FOAS Adjust Ease In'] = 'Início suave FOAS';
L['Follow On A Stick (FOAS)'] = 'Follow On A Stick (FOAS)';
L['Font Flags'] = 'Flags de fonte';
L['Font flags of the counter text on buttons.'] = 'Flags de fonte do texto do contador nos botões.';
L['Font flags of the hotkey text on buttons.'] = 'Flags de fonte do texto da tecla rápida nos botões.';
L['Font flags of the macro text on buttons.'] = 'Flags de fonte do texto da macro nos botões.';
L['Font size of the counter text on buttons.'] = 'Tamanho de fonte do texto do contador nos botões.';
L['Font size of the hotkey text on buttons.'] = 'Tamanho de fonte do texto da tecla rápida nos botões.';
L['Font size of the macro text on buttons.'] = 'Tamanho de fonte do texto da macro nos botões.';
L['Font size of the ring slice buttons.'] = 'Tamanho de fonte dos botões de fatia do menu radial.';
L['Force Hard Target'] = 'Forçar alvo fixo';
L['Frame level of the element.'] = 'Nível de quadro do elemento.';
L['Frame Level Offset'] = 'Deslocamento de nível de quadro';
L['Frame level offset of the hotkey prompt, relative to the unit frame.'] = 'Deslocamento de nível de quadro do aviso de tecla rápida, relativo ao quadro de unidade.';
L['Frame strata of the element.'] = 'Estrato de quadro do elemento.';
L['Free Cursor Timein'] = 'Tempo de aparição do cursor livre';
L['Frees your mouse cursor when used, if the cursor is currently center-fixed or hidden.'] = 'Libera seu cursor do mouse quando usado, se o cursor estiver atualmente fixo no centro ou oculto.';
L['Friend Soft Targeting'] = 'Alvo flexível amigável';
L['Full State Modifier'] = 'Modificador de estado completo';
L['Global color of the tint effect on the toolbar and dividers.'] = 'Cor global do efeito de matiz na barra de ferramentas e divisores.';
L['Global Scale'] = 'Escala global';
L['Global Visibility'] = 'Visibilidade global';
L['Green'] = 'Verde';
L['Grid'] = 'Grade';
L['Group buttons by modifier in a diamond layout.'] = 'Agrupar botões por modificador em um layout em diamante.';
L['Group buttons by modifier in a grid layout.'] = 'Agrupar botões por modificador em um layout em grade.';
L['Group buttons for left and right triggers, with modifier swapping.'] = 'Agrupar botões para gatilhos esquerdo e direito, com troca de modificador.';
L['Group buttons in a single crossbar layout, with modifier swapping.'] = 'Agrupar botões em um único layout crossbar, com troca de modificador.';
L['Group buttons in three layouts, with modifier swapping.'] = 'Agrupar botões em três layouts, com troca de modificador.';
L['Groups button combinations in circular clusters which switch between different actions when modifiers are used.'] = 'Agrupa combinações de botões em clusters circulares que alternam entre diferentes ações quando modificadores são usados.';
L['Height of the artwork.'] = 'Altura do artwork.';
L['Height of the cluster bar.'] = 'Altura da barra cluster.';
L['Height of the crosshair, in scaled pixel units.'] = 'Altura da mira, em unidades de pixel escalonadas.';
L['Height of the group.'] = 'Altura do grupo.';
L['Hide Cursor on Jump'] = 'Ocultar cursor ao saltar';
L['Hide Cursor On Movement'] = 'Ocultar cursor em movimento';
L['Hide Cursor on Stick Input'] = 'Ocultar cursor em entrada do stick';
L['Hide Flyout Buttons'] = 'Ocultar botões pop-out';
L['Hide Macro Text'] = 'Ocultar texto da macro';
L['Hide the class bar.'] = 'Ocultar a barra de classe.';
L['Hide the macro text on buttons.'] = 'Ocultar o texto da macro nos botões.';
L['Higher is slower.'] = 'Mais alto é mais lento.';
L['Higher values appear on top of lower values. Valid range 0-10000.'] = 'Valores mais altos aparecem acima dos mais baixos. Intervalo válido 0-10000.';
L['Highlight Color'] = 'Cor de destaque';
L['Horizontal Offset'] = 'Deslocamento horizontal';
L['Horizontal offset from anchor point.'] = 'Deslocamento horizontal do ponto de âncora.';
L['Horizontal offset of the counter text on buttons.'] = 'Deslocamento horizontal do texto do contador nos botões.';
L['Horizontal offset of the hotkey icon on group buttons.'] = 'Deslocamento horizontal do ícone de tecla rápida nos botões de grupo.';
L['Horizontal offset of the hotkey prompt position, in pixels.'] = 'Deslocamento horizontal da posição do aviso de tecla rápida, em pixels.';
L['Horizontal offset of the hotkey text on buttons.'] = 'Deslocamento horizontal do texto da tecla rápida nos botões.';
L['Horizontal offset of the macro text on buttons.'] = 'Deslocamento horizontal do texto da macro nos botões.';
L['Horizontal Padding'] = 'Preenchimento horizontal';
L['Hotkey Anchor'] = 'Âncora de tecla rápida';
L['Hotkey Offset X'] = 'Deslocamento X de tecla rápida';
L['Hotkey Offset Y'] = 'Deslocamento Y de tecla rápida';
L['Hotkey prompts appear on applicable name plates.'] = 'Avisos de tecla rápida aparecem nas placas de nome aplicáveis.';
L['Hotkey prompts linger on unit frames after targeting.'] = 'Avisos de tecla rápida permanecem nos quadros de unidade após a seleção do alvo.';
L['Hotkey Relative Anchor'] = 'Âncora relativa de tecla rápida';
L['Hotkey Size'] = 'Tamanho de tecla rápida';
L['Hotkeys activate their target immediately.'] = 'As teclas rápidas ativam seu alvo imediatamente.';
L['Hotkeys always target the same unit.'] = 'As teclas rápidas sempre miram na mesma unidade.';
L['Hotkeys control your focus target instead of your current target.'] = 'As teclas rápidas controlam seu alvo focal em vez de seu alvo atual.';
L['Hotkeys use '] = 'As teclas rápidas usam ';
L['How long the cursor should take to transition from one node to another.'] = 'Quanto tempo o cursor deve levar para passar de um nó para outro.';
L['How to clear focus after intercepting stick input.'] = 'Como limpar o foco após interceptar entrada do stick.';
L['Import serialized preset(s) from an external source.'] = 'Importar predefinição(ões) serializada(s) de uma fonte externa.';
L['Import serialized preset(s):'] = 'Importar predefinição(ões) serializada(s):';
L['Import serialized settings from an external source.'] = 'Importar configurações serializadas de uma fonte externa.';
L['Inactive Opacity'] = 'Opacidade inativa';
L['Include the current action page logic in the preset data.'] = 'Incluir a lógica de página de ação atual nos dados da predefinição.';
L['Include the current options from the %s tab in the preset data.'] = 'Incluir as opções atuais da aba %s nos dados da predefinição.';
L['Increase'] = 'Aumentar';
L['Increase lightness'] = 'Aumentar luminosidade';
L['Increase opacity'] = 'Aumentar opacidade';
L['Insert Suggestion'] = 'Inserir sugestão';
L['Intensity'] = 'Intensidade';
L['Intensity of the gradient.'] = 'Intensidade do gradiente.';
L['Interface Cursor'] = 'Cursor de interface';
L['Interference'] = 'Interferência';
L['Inverted'] = 'Invertido';
L['Join Discord'] = 'Entrar no Discord';
L['Keeps your character centered to reduce motion sickness.'] = 'Mantém seu personagem centralizado para reduzir o enjoo de movimento.';
L['Key %d'] = 'Tecla %d';
L['Keyboard'] = 'Teclado';
L['Keyboard button to emulate the paddle 1 button.'] = 'Tecla de teclado para emular o botão da paleta 1.';
L['Keyboard button to emulate the paddle 2 button.'] = 'Tecla de teclado para emular o botão da paleta 2.';
L['Keyboard button to emulate the paddle 3 button.'] = 'Tecla de teclado para emular o botão da paleta 3.';
L['Keyboard button to emulate the paddle 4 button.'] = 'Tecla de teclado para emular o botão da paleta 4.';
L['Keyboard Layout Editor'] = 'Editor de layout de teclado';
L['Larger value for easier taps.'] = 'Valor maior para toques mais fáceis.';
L['Layout'] = 'Layout';
L['LED Color Type'] = 'Tipo de cor LED';
L['LED Custom Color'] = 'Cor LED personalizada';
L['Load'] = 'Carregar';
L['Loadout'] = 'Loadout';
L['Lock Automatic Tooltip'] = 'Bloquear dica de ferramenta automática';
L['Looks like a regular action bar, but shows the button combination rather than the action slot.'] = 'Parece uma barra de ação normal, mas mostra a combinação de botões em vez do slot de ação.';
L['Lua pattern to match words for dictionary lookups.'] = 'Padrão Lua para corresponder palavras para pesquisas de dicionário.';
L['Macro condition to evaluate action bar page.'] = 'Condição de macro para avaliar a página da barra de ação.';
L['Macro condition to override the strafe angle threshold for combat.'] = 'Condição de macro para substituir o limite de ângulo de movimento lateral para combate.';
L['Macro condition to override the strafe angle threshold for travel.'] = 'Condição de macro para substituir o limite de ângulo de movimento lateral para viagem.';
L['Macro Text'] = 'Texto da macro';
L['Main Button Border Style'] = 'Estilo da borda do botão principal';
L['Maintain offset relative to scale.'] = 'Manter deslocamento relativo à escala.';
L['Make sure your choice does not conflict with your bindings.'] = 'Certifique-se de que sua escolha não entra em conflito com suas ligações.';
L['Make this preset the default layout for all new characters.'] = 'Tornar esta predefinição o layout padrão para todos os novos personagens.';
L['Match appropriate soft target to locked target.'] = 'Combinar alvo flexível apropriado ao alvo fixo.';
L['Match criteria for unit pool, each type separated by semicolon.'] = 'Critérios de correspondência para pool de unidades, cada tipo separado por ponto e vírgula.';
L['Max Pitch'] = 'Inclinação máx.';
L['Max time for a touch to register a tap/click, in milliseconds.'] = 'Tempo máximo para um toque registrar um toque/clique, em milissegundos.';
L['Max Yaw'] = 'Guinada máx.';
L['Maximum Pitch adjust for the camera "look" feature.'] = 'Ajuste máximo de inclinação para a função «olhar» da câmera.';
L['Maximum Yaw adjust for the camera "look" feature.'] = 'Ajuste máximo de guinada para a função «olhar» da câmera.';
L['Menu buttons to display on the toolbar.'] = 'Botões de menu para exibir na barra de ferramentas.';
L['Micro Menu'] = 'Micromenu';
L['Minimal Interact Nameplate Tooltip'] = 'Dica de ferramenta de interação mínima em placa de nome';
L['Modifications'] = 'Modificações';
L['Modifier'] = 'Modificador';
L['Modifier 1: Shift'] = 'Modificador 1: Shift';
L['Modifier 2: Ctrl'] = 'Modificador 2: Ctrl';
L['Modifier 3: Alt'] = 'Modificador 3: Alt';
L['Modifier Tap Window'] = 'Janela de toque do modificador';
L['Modifiers'] = 'Modificadores';
L['Move Left'] = 'Mover para a esquerda';
L['Move one of the sticks.'] = 'Mova um dos sticks.';
L['Move Right'] = 'Mover para a direita';
L['Movement Deadzone'] = 'Zona morta de movimento';
L['Movement is analog, translated from your movement stick angle.'] = 'O movimento é analógico, traduzido do ângulo do seu stick de movimento.';
L['Movement X Axis'] = 'Eixo X de movimento';
L['Movement Y Axis'] = 'Eixo Y de movimento';
L['Needs to be long enough to press and release the button.'] = 'Precisa ser longo o suficiente para pressionar e soltar o botão.';
L['Nested Rings'] = 'Menus radiais aninhados';
L['Next Word'] = 'Próxima palavra';
L['No axis input detected yet.'] = 'Nenhuma entrada de eixo detectada ainda.';
L['No button input detected yet.'] = 'Nenhuma entrada de botão detectada ainda.';
L['No buttons were detected during the test.'] = 'Nenhum botão foi detectado durante o teste.';
L['No sensors were detected.'] = 'Nenhum sensor foi detectado.';
L['Normal background color of pie slices.'] = 'Cor de fundo normal das fatias da pizza.';
L['Normal Color'] = 'Cor normal';
L['Nudge Modifier'] = 'Modificador de empurrão';
L['Number of buttons in the page.'] = 'Número de botões na página.';
L['Number of buttons per row or column.'] = 'Número de botões por linha ou coluna.';
L['Offset'] = 'Deslocamento';
L['Offset of pointer arrow, from the selected node center, in pixels.'] = 'Deslocamento da seta do ponteiro, a partir do centro do nó selecionado, em pixels.';
L['Offset X'] = 'Deslocamento X';
L['Offset Y'] = 'Deslocamento Y';
L['Offsets the camera horizontally from your character, for a more cinematic view.'] = 'Desloca a câmera horizontalmente do seu personagem, para uma visão mais cinematográfica.';
L['Only recommended for super users.'] = 'Recomendado apenas para super usuários.';
L['Only use taps for cursor clicks, do not use tap presses.'] = 'Usar apenas toques para cliques do cursor, não usar pressões de toque.';
L['Opacity of inactive hotkey prompts on unit frames after targeting.'] = 'Opacidade dos avisos inativos de tecla rápida nos quadros de unidade após a seleção do alvo.';
L['Open Designer'] = 'Abrir Designer';
L['Open Main Config'] = 'Abrir Configuração principal';
L['Open the configuration menu for the action bar.'] = 'Abrir o menu de configuração da barra de ação.';
L['Open the main configuration window.'] = 'Abrir a janela de configuração principal.';
L['Open the main edit mode window.'] = 'Abrir a janela principal do modo de edição.';
L['Open the unit menu for the target unit.'] = 'Abrir o menu de unidade para a unidade alvo.';
L['Open unit menu when interacting with other players.'] = 'Abrir o menu de unidade ao interagir com outros jogadores.';
L['Optimize Algorithm'] = 'Otimizar algoritmo';
L['or'] = 'ou';
L['Orientation of the page.'] = 'Orientação da página.';
L['Orthodox'] = 'Ortodoxo';
L['Out of Mana Color'] = 'Cor de falta de mana';
L['Out of Range Color'] = 'Cor fora de alcance';
L['Outcome'] = 'Resultado';
L['Over Shoulder'] = 'Sobre o ombro';
L['Override'] = 'Substituir';
L['Override Class File'] = 'Arquivo de classe de substituição';
L['Override class theme for interface styling.'] = 'Substituir tema de classe para estilização de interface.';
L['Padding between buttons horizontally.'] = 'Preenchimento entre botões horizontalmente.';
L['Padding between buttons vertically.'] = 'Preenchimento entre botões verticalmente.';
L['Page'] = 'Página';
L['Page Condition'] = 'Condição de página';
L['Page Hotkeys'] = 'Teclas rápidas de página';
L['Page Response'] = 'Resposta de página';
L['Page |cFF00FFFF%s|r'] = 'Página |cFF00FFFF%s|r';
L['Patreon'] = 'Patreon';
L['PayPal'] = 'PayPal';
L['Performs an action and closes the menu.'] = 'Executa uma ação e fecha o menu.';
L['Performs an action without closing the menu.'] = 'Executa uma ação sem fechar o menu.';
L['Pet Ring'] = 'Menu radial de mascote';
L['Pick up'] = 'Pegar';
L['Pickup'] = 'Coleta';
L['Pitch Axis'] = 'Eixo de inclinação';
L['Pitch-only deadzone for camera, applied before the 2D deadzone.'] = 'Zona morta apenas de inclinação para a câmera, aplicada antes da zona morta 2D.';
L['Pitches the camera upwards as you zoom out.'] = 'Inclina a câmera para cima conforme você dá zoom out.';
L['Place in slot'] = 'Colocar no slot';
L['Place on action bar'] = 'Colocar na barra de ação';
L['Play a sound when the pointer arrow reaches its destination.'] = 'Tocar um som quando a seta do ponteiro alcançar seu destino.';
L['Please provide a unique name for a new %s in %s:'] = 'Por favor, forneça um nome único para um novo %s em %s:';
L['Plural Button'] = 'Botão plural';
L['Pointer arrow rotates in the direction of travel, and portraits scale up and down on movement.'] = 'A seta do ponteiro gira na direção do movimento, e os retratos aumentam e diminuem com o movimento.';
L['Pointer arrow rotates in the direction of travel.'] = 'A seta do ponteiro gira na direção do movimento.';
L['Pointer Offset'] = 'Deslocamento do ponteiro';
L['Pointer Size'] = 'Tamanho do ponteiro';
L['Position'] = 'Posição';
L['Position of the artwork.'] = 'Posição do artwork.';
L['Position of the button cluster.'] = 'Posição do cluster de botões.';
L['Position of the button.'] = 'Posição do botão.';
L['Position of the class bar.'] = 'Posição da barra de classe.';
L['Position of the cluster bar.'] = 'Posição da barra cluster.';
L['Position of the divider.'] = 'Posição do divisor.';
L['Position of the element.'] = 'Posição do elemento.';
L['Position of the group.'] = 'Posição do grupo.';
L['Position of the page.'] = 'Posição da página.';
L['Position of the pet ring.'] = 'Posição do menu radial de mascote.';
L['Position of the toolbar.'] = 'Posição da barra de ferramentas.';
L['Power Level'] = 'Nível da bateria';
L['Preferred size of radial menus, in pixels.'] = 'Tamanho preferido dos menus radiais, em pixels.';
L['Presets'] = 'Predefinições';
L['Press and Hold'] = 'Pressionar e segurar';
L['Press your gamepad buttons to test them.'] = 'Pressione os botões do seu controle para testá-los.';
L['Prevent the cursor from wrapping when navigating.'] = 'Impedir que o cursor faça loop ao navegar.';
L['Previous Word'] = 'Palavra anterior';
L['Primary accept button, to use or confirm a quick menu action.'] = 'Botão de aceitação principal, para usar ou confirmar uma ação do menu rápido.';
L['Primary Button'] = 'Botão principal';
L['Primary Stick'] = 'Stick principal';
L['Prioritize raid cursor bindings over other override bindings.'] = 'Priorizar ligações do cursor de raide sobre outras ligações de substituição.';
L['Priority Override'] = 'Substituição de prioridade';
L['Purple'] = 'Roxo';
L['Quick Menu'] = 'Menu rápido';
L['Radial Menus'] = 'Menus radiais';
L['Raid Cursor'] = 'Cursor de raide';
L['Re-apply config for the active device.'] = 'Reaplicar configuração para o dispositivo ativo.';
L['Reactivation Delay'] = 'Atraso de reativação';
L['Recharge'] = 'Recarga';
L['Recommended as first choice modifier.'] = 'Recomendado como primeira escolha de modificador.';
L['Recommended as second choice modifier.'] = 'Recomendado como segunda escolha de modificador.';
L['Reduces unexpected camera movement to reduce motion sickness.'] = 'Reduz movimento inesperado da câmera para reduzir o enjoo de movimento.';
L['Regenerate Dictionary'] = 'Regenerar dicionário';
L['Regular'] = 'Normal';
L['Relative Anchor'] = 'Âncora relativa';
L['Relative anchor point of the counter text on buttons.'] = 'Ponto de âncora relativo do texto do contador nos botões.';
L['Relative anchor point of the hotkey icon on group buttons.'] = 'Ponto de âncora relativo do ícone de tecla rápida nos botões de grupo.';
L['Relative anchor point of the hotkey text on buttons.'] = 'Ponto de âncora relativo do texto da tecla rápida nos botões.';
L['Relative anchor point of the macro text on buttons.'] = 'Ponto de âncora relativo do texto da macro nos botões.';
L['Relative Rescale'] = 'Redimensionamento relativo';
L['Reload'] = 'Recarregar';
L['Remove all saved settings and bindings, disable addon, and reload interface.'] = 'Remover todas as configurações e ligações salvas, desativar addon e recarregar interface.';
L['Remove all saved settings and reload interface.'] = 'Remover todas as configurações salvas e recarregar interface.';
L['Remove Button'] = 'Botão Remover';
L['Remove from %s'] = 'Remover de %s';
L['Remove this set. This action cannot be undone.'] = 'Remover este conjunto. Esta ação não pode ser desfeita.';
L['Removes the tooltip background for a minimalistic look.'] = 'Remove o fundo da dica de ferramenta para um visual minimalista.';
L['Repeated Movement Delay'] = 'Atraso de movimento repetido';
L['Repeated Movement First Delay'] = 'Primeiro atraso de movimento repetido';
L['Replaces the default loot frame with a custom version optimized for controller navigation.'] = 'Substitui o quadro de saque padrão por uma versão personalizada otimizada para navegação com controle.';
L['Request early landing from the taxi you are currently riding.'] = 'Solicitar pouso antecipado do táxi que você está cavalgando atualmente.';
L['Requires /reload to fully unhook when disabled.'] = 'Requer /reload para desconectar completamente quando desativado.';
L['Requires a touchpad with LED support.'] = 'Requer um touchpad com suporte a LED.';
L['Requires reload.'] = 'Requer recarregamento.';
L['Requires Settings > Hide Cursor on Stick Input set to None.'] = 'Requer Configurações > Ocultar cursor em entrada do stick configurado para Nenhum.';
L['Requires Toggle Interface Cursor binding to use the cursor.'] = 'Requer a ligação Alternar cursor de interface para usar o cursor.';
L['Reset all mapping configurations and reload. (will not affect bindings)'] = 'Redefinir todas as configurações de mapeamento e recarregar. (não afetará ligações)';
L['Response to condition for custom processing.'] = 'Resposta à condição para processamento personalizado.';
L['Reticle targeting means anything you place on the ground.'] = 'Mira de mira significa qualquer coisa que você coloca no chão.';
L['Reticle targeting uses free cursor instead of staying center-fixed.'] = 'Mira de mira usa cursor livre em vez de manter-se fixo no centro.';
L['Return Button'] = 'Botão Voltar';
L['Returns to the previous menu.'] = 'Retorna ao menu anterior.';
L['Reverse Mouse Handling'] = 'Inverter gerenciamento do mouse';
L['Reverse Order'] = 'Inverter ordem';
L['Reverse the order of the buttons.'] = 'Inverter a ordem dos botões.';
L['Ring Manager'] = 'Gerenciador de menus radiais';
L['Ring Scale'] = 'Escala do menu radial';
L['Ring Size'] = 'Tamanho do menu radial';
L['Rings'] = 'Menus radiais';
L['Rings (Account)'] = 'Menus radiais (conta)';
L['Rings (Character)'] = 'Menus radiais (personagem)';
L['Rotation'] = 'Rotação';
L['Rotation of the divider.'] = 'Rotação do divisor.';
L['Run / Walk Threshold'] = 'Limite de correr/caminhar';
L['Run Tests'] = 'Executar testes';
L['Save as default'] = 'Salvar como padrão';
L['Save preset from %s:'] = 'Salvar predefinição de %s:';
L['Save your current loadout to the preset list.'] = 'Salvar seu loadout atual na lista de predefinições.';
L['Scale of all radial menus, relative to UI scale.'] = 'Escala de todos os menus radiais, relativa à escala da interface.';
L['Scale of most ConsolePort frames, relative to UI scale.'] = 'Escala da maioria dos quadros ConsolePort, relativa à escala da interface.';
L['Scale of the cursor.'] = 'Escala do cursor.';
L['Scale of the game menu and radial companion.'] = 'Escala do menu do jogo e companheiro radial.';
L['Scale of the keyboard.'] = 'Escala do teclado.';
L['Scale of the pet ring.'] = 'Escala do menu radial de mascote.';
L['Secondary accept button, to use or confirm a quick menu action.'] = 'Botão de aceitação secundário, para usar ou confirmar uma ação do menu rápido.';
L['Select a device from the list to continue.'] = 'Selecione um dispositivo da lista para continuar.';
L['Select a slot to bind %s and place this spell.'] = 'Selecione um slot para vincular %s e colocar esta magia.';
L['Select a slot to place this spell.'] = 'Selecione um slot para colocar esta magia.';
L['Select the device you want to configure.'] = 'Selecione o dispositivo que quer configurar.';
L['Select the device you want to use.'] = 'Selecione o dispositivo que quer usar.';
L['Selecting an item on a ring will stick until another item is chosen.'] = 'Selecionar um item em um menu radial fica fixo até que outro item seja escolhido.';
L['Sensors'] = 'Sensores';
L['Set %d |cFF757575(%s)|r'] = 'Conjunto %d |cFF757575(%s)|r';
L['Set binding'] = 'Definir ligação';
L['Sets if range should be a hard cutoff, even for something you can interact with.'] = 'Define se o alcance deve ser um corte fixo, mesmo para algo com o qual você pode interagir.';
L['Shift-click to Edit Binding'] = 'Shift+clique para editar ligação';
L['Shift-right-click to Clear Binding'] = 'Shift+clique direito para limpar ligação';
L['Show a color tint on the toolbar.'] = 'Mostrar uma matiz colorida na barra de ferramentas.';
L['Show Ability Briefings'] = 'Mostrar briefings de habilidade';
L['Show Action Bar Grid on Spell Pickup'] = 'Mostrar grade da barra de ação ao pegar magia';
L['Show active buffs in the quick menu.'] = 'Mostrar buffs ativos no menu rápido.';
L['Show active debuffs in the quick menu.'] = 'Mostrar debuffs ativos no menu rápido.';
L['Show All Action Bars'] = 'Mostrar todas as barras de ação';
L['Show all enabled combinations in the cluster at all times.'] = 'Mostrar todas as combinações ativadas no cluster o tempo todo.';
L['Show bonus bar configuration for characters without stances.'] = 'Mostrar configuração da barra bônus para personagens sem poses.';
L['Show Centered Cursor Tooltip'] = 'Mostrar dica de ferramenta do cursor centralizado';
L['Show connected devices.'] = 'Mostrar dispositivos conectados.';
L['Show Default Button'] = 'Mostrar botão padrão';
L['Show Enemy Nameplate'] = 'Mostrar placa de nome inimiga';
L['Show Enemy Target Icon'] = 'Mostrar ícone de alvo inimigo';
L['Show Enemy Tooltip'] = 'Mostrar dica de ferramenta inimiga';
L['Show Flyout Buttons'] = 'Mostrar botões pop-out';
L['Show Flyouts'] = 'Mostrar pop-outs';
L['Show Friendly Nameplate'] = 'Mostrar placa de nome amigável';
L['Show Friendly Target Icon'] = 'Mostrar ícone de alvo amigável';
L['Show Friendly Tooltip'] = 'Mostrar dica de ferramenta amigável';
L['Show Gauge'] = 'Mostrar medidor';
L['Show group loot rolls in the quick menu, allowing you to roll on items using gamepad buttons while in combat.'] = 'Mostrar rolagens de saque em grupo no menu rápido, permitindo rolar dados em itens usando botões de controle em combate.';
L['Show help for command(s).'] = 'Mostrar ajuda para comando(s).';
L['Show Hotkeys'] = 'Mostrar teclas rápidas';
L['Show icon above the current enemy soft target.'] = 'Mostrar ícone acima do alvo flexível inimigo atual.';
L['Show icon above the current friendly soft target.'] = 'Mostrar ícone acima do alvo flexível amigável atual.';
L['Show icon above the current interactable object.'] = 'Mostrar ícone acima do objeto interativo atual.';
L['Show icon above the current interactable target.'] = 'Mostrar ícone acima do alvo interativo atual.';
L['Show interact binding hint on interactables.'] = 'Mostrar dica de ligação de interação em objetos interativos.';
L['Show Interact Hint'] = 'Mostrar dica de interação';
L['Show interact tooltip on nameplates, when applicable.'] = 'Mostrar dica de interação em placas de nome, quando aplicável.';
L['Show item type in the quick menu.'] = 'Mostrar tipo de item no menu rápido.';
L['Show Main Icons'] = 'Mostrar ícones principais';
L['Show Modifier Icons'] = 'Mostrar ícones de modificador';
L['Show numerical cooldown text on buttons.'] = 'Mostrar texto numérico de tempo de recarga nos botões.';
L['Show Object Icon'] = 'Mostrar ícone de objeto';
L['Show on Name Plates'] = 'Mostrar em placas de nome';
L['Show pet action bar in the quick menu.'] = 'Mostrar barra de ação do mascote no menu rápido.';
L['Show ping commands in the quick menu.'] = 'Mostrar comandos de ping no menu rápido.';
L['Show Portrait'] = 'Mostrar retrato';
L['Show portrait for the current unit, with health percentage and applicable spell casts.'] = 'Mostrar retrato para a unidade atual, com porcentagem de vida e conjurações aplicáveis.';
L['Show Status Text'] = 'Mostrar texto de status';
L['Show Target Icon'] = 'Mostrar ícone de alvo';
L['Show the default mouse action button.'] = 'Mostrar o botão de ação de mouse padrão.';
L['Show the empty buttons in the page.'] = 'Mostrar os botões vazios na página.';
L['Show the flyout of small buttons for the button cluster.'] = 'Mostrar o pop-out de pequenos botões para o cluster de botões.';
L['Show the hotkeys on the buttons.'] = 'Mostrar as teclas rápidas nos botões.';
L['Show the icons for main buttons.'] = 'Mostrar os ícones para botões principais.';
L['Show the icons for modifier buttons.'] = 'Mostrar os ícones para botões modificadores.';
L['Show the pet power and health status.'] = 'Mostrar o status de poder e vida do mascote.';
L['Show the pet ring when in a vehicle.'] = 'Mostrar o menu radial do mascote quando em um veículo.';
L['Show the watch bars at the bottom of the toolbar.'] = 'Mostrar as barras de observação na parte inferior da barra de ferramentas.';
L['Show Tooltip'] = 'Mostrar dica de ferramenta';
L['Show tooltip for enemy target.'] = 'Mostrar dica de ferramenta para alvo inimigo.';
L['Show tooltip for friendly target.'] = 'Mostrar dica de ferramenta para alvo amigável.';
L['Show tooltip for interactables.'] = 'Mostrar dica de ferramenta para objetos interativos.';
L['Show tooltip for mouseover targets when cursor is centered.'] = 'Mostrar dica de ferramenta para alvos sob o mouse quando o cursor está centralizado.';
L['Show tooltips on buttons when moused over.'] = 'Mostrar dicas de ferramenta nos botões quando o mouse passa sobre eles.';
L['Show Type Icon'] = 'Mostrar ícone de tipo';
L['Size of pointer arrow, in pixels.'] = 'Tamanho da seta do ponteiro, em pixels.';
L['Size of the button cluster.'] = 'Tamanho do cluster de botões.';
L['Size of the hotkey icon on group buttons.'] = 'Tamanho do ícone de tecla rápida nos botões de grupo.';
L['Size of unit hotkeys, in pixels.'] = 'Tamanho das teclas rápidas de unidade, em pixels.';
L['Space'] = 'Espaço';
L['Speed of cursor when it starts moving.'] = 'Velocidade do cursor quando começa a se mover.';
L['Split stack'] = 'Dividir pilha';
L['Start moving the configuration window.'] = 'Começar a mover a janela de configuração.';
L['Starting point of the page.'] = 'Ponto de partida da página.';
L['Status Bar'] = 'Barra de status';
L['Stick to use for main radial actions.'] = 'Stick para usar nas ações radiais principais.';
L['Sticky Color'] = 'Cor fixa';
L['Sticky Selection'] = 'Seleção fixa';
L['Strafe Angle (Combat)'] = 'Ângulo de movimento lateral (combate)';
L['Strafe Angle (Jump)'] = 'Ângulo de movimento lateral (salto)';
L['Strafe Angle (Travel)'] = 'Ângulo de movimento lateral (viagem)';
L['Strafe Angle Macro Condition (Combat)'] = 'Condição de macro de ângulo de movimento lateral (combate)';
L['Strafe Angle Macro Condition (Travel)'] = 'Condição de macro de ângulo de movimento lateral (viagem)';
L['Strata'] = 'Estrato';
L['Stride'] = 'Passo';
L['Style of the border around main buttons.'] = 'Estilo da borda em torno dos botões principais.';
L['Support on Patreon'] = 'Apoiar no Patreon';
L['Swap to a specified action bar layout.'] = 'Trocar para um layout especificado de barra de ação.';
L['Swipe Color'] = 'Cor de varredura';
L['Switch Button'] = 'Botão Trocar';
L['Switches between the main menu and the radial companion.'] = 'Alterna entre o menu principal e o companheiro radial.';
L['Synchronize Bindings'] = 'Sincronizar ligações';
L['Synchronize Config'] = 'Sincronizar configuração';
L['Take ownership of, and move the micro menu buttons to the toolbar.'] = 'Assumir a propriedade e mover os botões do micromenu para a barra de ferramentas.';
L['Taps for cursor clicks are right clicks instead of left.'] = 'Os toques para cliques do cursor são cliques direitos em vez de esquerdos.';
L['Target enemies automatically by looking at them.'] = 'Mirar inimigos automaticamente olhando para eles.';
L['Target friends automatically by looking at them.'] = 'Mirar amigos automaticamente olhando para eles.';
L['Target Match Lock'] = 'Bloqueio de correspondência de alvo';
L['Target Range'] = 'Alcance do alvo';
L['Target Range Hard Cutoff'] = 'Corte fixo do alcance do alvo';
L['Targeting Mode'] = 'Modo de mira';
L['Test Device'] = 'Testar dispositivo';
L['The analog input for forward/back movement.'] = 'A entrada analógica para movimento para frente/trás.';
L['The analog input for left/right Camera Yaw "look" feature.'] = 'A entrada analógica para a função «olhar» de guinada da câmera esquerda/direita.';
L['The analog input for left/right Camera Yaw.'] = 'A entrada analógica para guinada da câmera esquerda/direita.';
L['The analog input for left/right movement.'] = 'A entrada analógica para movimento esquerda/direita.';
L['The analog input for up/down Camera Pitch "look" feature.'] = 'A entrada analógica para a função «olhar» de inclinação da câmera cima/baixo.';
L['The analog input for up/down Camera Pitch.'] = 'A entrada analógica para inclinação da câmera cima/baixo.';
L['The configuration is accessible by the chat command %s or from the game menu.'] = 'A configuração é acessível pelo comando de chat %s ou pelo menu do jogo.';
L['The modifier can be used to nudge the cursor position with the directional pad.'] = 'O modificador pode ser usado para empurrar a posição do cursor com o direcional.';
L['The modifier can be used to scroll together with the directional pad.'] = 'O modificador pode ser usado para rolar junto com o direcional.';
L['The quick menu binding can be used to close the menu as well.'] = 'A ligação do menu rápido também pode ser usada para fechar o menu.';
L['The time it takes to transition from idle camera control to auto-adjustment (FOAS).'] = 'O tempo que leva para passar do controle de câmera ocioso para o ajuste automático (FOAS).';
L['Thickness'] = 'Espessura';
L['Thickness in scaled pixel units.'] = 'Espessura em unidades de pixel escalonadas.';
L['Thickness of the divider.'] = 'Espessura do divisor.';
L['This button is necessary to use or sell an item directly from your bags.'] = 'Este botão é necessário para usar ou vender um item diretamente das suas mochilas.';
L['This feature is only available in Classic.'] = 'Este recurso está disponível apenas no Classic.';
L['This only affects gamepad bindings.'] = 'Isto afeta apenas as ligações de controle.';
L['This will not affect your bindings, interface settings or system-wide settings.'] = 'Isto não afetará suas ligações, configurações de interface ou configurações do sistema.';
L['This will not work with Xbox controllers connected via bluetooth. The Xbox Adapter is required.'] = 'Isto não funcionará com controles Xbox conectados via bluetooth. O adaptador Xbox é necessário.';
L['Time in milliseconds for the opacity to change from one state to another.'] = 'Tempo em milissegundos para a opacidade mudar de um estado para outro.';
L['Time in seconds to automatically hide centered cursor.'] = 'Tempo em segundos para ocultar automaticamente o cursor centralizado.';
L['Time in seconds to enable free cursor.'] = 'Tempo em segundos para ativar o cursor livre.';
L['Time to clear focus after intercepting stick input, in seconds.'] = 'Tempo para limpar foco após interceptar entrada do stick, em segundos.';
L['Timeframe to catch a binding in the configuration, in seconds.'] = 'Janela de tempo para capturar uma ligação na configuração, em segundos.';
L['Timeframe to toggle the mouse cursor when double-tapping a selected modifier.'] = 'Janela de tempo para alternar o cursor do mouse ao tocar duplo em um modificador selecionado.';
L['Timeout clears focus after a set time, deadzone clears focus when stick input is neutral.'] = 'O tempo limite limpa o foco após um tempo definido, a zona morta limpa o foco quando a entrada do stick é neutra.';
L['Tint Color'] = 'Cor de matiz';
L['Toggle visibility of all modifier flyouts for cluster action bars.'] = 'Alternar visibilidade de todos os pop-outs de modificador para barras de ação cluster.';
L['Toggle visibility of all modifier flyouts.'] = 'Alternar visibilidade de todos os pop-outs de modificador.';
L['Toolbar'] = 'Barra de ferramentas';
L['Tooltip'] = 'Dica de ferramenta';
L['Top speed of cursor movement.'] = 'Velocidade máxima do movimento do cursor.';
L['Touch Tap Buttons'] = 'Botões de toque tátil';
L['Touch Tap Exclusive Click'] = 'Clique exclusivo de toque tátil';
L['Touch Tap Max Time'] = 'Tempo máximo de toque tátil';
L['Touch Tap Right Click'] = 'Clique direito de toque tátil';
L['Touchpad'] = 'Touchpad';
L['Transition'] = 'Transição';
L['Transition time for opacity changes.'] = 'Tempo de transição para mudanças de opacidade.';
L['Travel Time'] = 'Tempo de viagem';
L['Trigger button actions on press instead of release.'] = 'Acionar ações de botão ao pressionar em vez de soltar.';
L['Triggers'] = 'Gatilhos';
L['Turn Character With Camera'] = 'Virar personagem com a câmera';
L['Turn your character facing when you turn your camera angle.'] = 'Vira a direção em que seu personagem está olhando quando você vira o ângulo da câmera.';
L['Type of LED color to use for the touchpad.'] = 'Tipo de cor LED para usar no touchpad.';
L['Types are PlayStation, Xbox, or Generic.'] = 'Os tipos são PlayStation, Xbox ou Genérico.';
L['Unit Hotkeys'] = 'Teclas rápidas de unidade';
L['Unit Pool'] = 'Pool de unidades';
L['Unknown device selected.'] = 'Dispositivo desconhecido selecionado.';
L['Unlimited Navigation'] = 'Navegação ilimitada';
L['Unmapped keyboard key(s) detected:'] = 'Tecla(s) de teclado não mapeada(s) detectada(s):';
L['Use a targeting binding to turn a soft target into a hard target.'] = 'Usar uma ligação de seleção de alvo para transformar um alvo flexível em alvo fixo.';
L['Use character specific addon settings for this character.'] = 'Usar configurações de addon específicas do personagem para este personagem.';
L['Use Custom Button Set'] = 'Usar conjunto de botões personalizado';
L['Use Custom Loot Frame'] = 'Usar quadro de saque personalizado';
L['Use Default Hotkey Icons'] = 'Usar ícones de tecla rápida padrão';
L['Use Focus Mode'] = 'Usar modo foco';
L['Use Global Loot Tooltip'] = 'Usar dica de ferramenta de saque global';
L['Use Hardware Mouse Cursor'] = 'Usar cursor de mouse de hardware';
L['Use Instant Mode'] = 'Usar modo instantâneo';
L['Use Interact Nameplate Tooltip'] = 'Usar dica de ferramenta de interação em placa de nome';
L['Use On Demand'] = 'Usar sob demanda';
L['Use optimized pathfinding algorithm for cursor movement.'] = 'Usar algoritmo otimizado de busca de caminho para o movimento do cursor.';
L['Use press and hold to navigate and use rings. Press, point, release.'] = 'Use pressionar e segurar para navegar e usar menus radiais. Pressione, aponte, solte.';
L['Use Static Mode'] = 'Usar modo estático';
L['Use the hardware cursor provided by the operating system.'] = 'Usar o cursor de hardware fornecido pelo sistema operacional.';
L['Use together with [@cursor] macros to place reticle spells in a single click.'] = 'Use junto com macros [@cursor] para colocar magias com mira em um único clique.';
L['Used for interacting with the world, at a center-fixed position.'] = 'Usado para interagir com o mundo, em uma posição fixa central.';
L['Uses global tint color when transparent.'] = 'Usa a cor de matiz global quando transparente.';
L['Uses the default hotkey icons instead of the custom icons provided by ConsolePort.'] = 'Usa os ícones de tecla rápida padrão em vez dos ícones personalizados fornecidos pelo ConsolePort.';
L['Valid Action Deadzone'] = 'Zona morta de ação válida';
L['Value below two may appear interlaced or not at all.'] = 'Um valor abaixo de dois pode aparecer entrelaçado ou não aparecer.';
L['Vertical Offset'] = 'Deslocamento vertical';
L['Vertical offset from anchor point.'] = 'Deslocamento vertical do ponto de âncora.';
L['Vertical offset of the counter text on buttons.'] = 'Deslocamento vertical do texto do contador nos botões.';
L['Vertical offset of the hotkey icon on group buttons.'] = 'Deslocamento vertical do ícone de tecla rápida nos botões de grupo.';
L['Vertical offset of the hotkey prompt position, in pixels.'] = 'Deslocamento vertical da posição do aviso de tecla rápida, em pixels.';
L['Vertical offset of the hotkey text on buttons.'] = 'Deslocamento vertical do texto da tecla rápida nos botões.';
L['Vertical offset of the macro text on buttons.'] = 'Deslocamento vertical do texto da macro nos botões.';
L['Vertical Padding'] = 'Preenchimento vertical';
L['Vertical position of centered cursor & targeting, as fraction of screen height.'] = 'Posição vertical do cursor centralizado e mira, como fração da altura da tela.';
L['Visibility Condition'] = 'Condição de visibilidade';
L['Watch bars include XP, reputation, honor, artifact power, and azerite.'] = 'As barras de observação incluem XP, reputação, honra, poder de artefato e azerita.';
L['When disabled, a button press will also act as a cursor click.'] = 'Quando desativado, uma pressão de botão também agirá como um clique do cursor.';
L['When disabled, you will need to press the accept button to confirm a selection.'] = 'Quando desativado, você precisará pressionar o botão aceitar para confirmar uma seleção.';
L['When enabled, a tap will act as a button press.'] = 'Quando ativado, um toque agirá como uma pressão de botão.';
L['When set to both sticks, cursor only disables when both sticks are used together.'] = 'Quando definido para ambos os sticks, o cursor só desativa quando ambos os sticks são usados juntos.';
L['Whether client keybindings should be saved to the server.'] = 'Se as ligações de teclas do cliente devem ser salvas no servidor.';
L['Whether the keyboard should always be shown or only when a gamepad is active.'] = 'Se o teclado deve sempre ser mostrado ou apenas quando um controle está ativo.';
L['Whether to save character- and account-scoped variables to the server.'] = 'Se deve salvar variáveis no escopo de personagem e conta no servidor.';
L['Which button set to use for unit hotkeys.'] = 'Qual conjunto de botões usar para teclas rápidas de unidade.';
L['Which modifier to use for modified commands.'] = 'Qual modificador usar para comandos modificados.';
L['Which modifier to use for nudging the cursor.'] = 'Qual modificador usar para empurrar o cursor.';
L['Which modifier to use to toggle the mouse cursor when double-tapped.'] = 'Qual modificador usar para alternar o cursor do mouse ao tocar duplo.';
L['Which modifier to use with the movement buttons to move the cursor.'] = 'Qual modificador usar com os botões de movimento para mover o cursor.';
L['While held down, can simulate dragging by clicking on the directional pad.'] = 'Enquanto pressionado, pode simular arrastar clicando no direcional.';
L['Width of the artwork.'] = 'Largura do artwork.';
L['Width of the cluster bar.'] = 'Largura da barra cluster.';
L['Width of the crosshair, in scaled pixel units.'] = 'Largura da mira, em unidades de pixel escalonadas.';
L['Width of the group.'] = 'Largura do grupo.';
L['Width of the toolbar.'] = 'Largura da barra de ferramentas.';
L['Wipe Dictionary'] = 'Limpar dicionário';
L['Wired'] = 'Com fio';
L['Works like a regular action bar, which displays the action slots of a specified action page.'] = 'Funciona como uma barra de ação normal, que exibe os slots de ação de uma página de ação especificada.';
L['X Offset'] = 'Deslocamento X';
L['XP Bar Color'] = 'Cor da barra de XP';
L['Y Offset'] = 'Deslocamento Y';
L['Yaw Axis'] = 'Eixo de guinada';
L['Yaw-only deadzone for camera, applied before the 2D deadzone.'] = 'Zona morta apenas de guinada para a câmera, aplicada antes da zona morta 2D.';
L['your current loadout'] = 'seu loadout atual';
---------------------------------------------------------------
-- Literal block entries
---------------------------------------------------------------
L['%s is already bound to\n%s\n\nDo you want to change it to\n%s?'] = [[%s já está ligado a
%s

Quer mudar para
%s?]];
L['+ Normal\n- Inverted'] = [[+ Normal
- Invertido]];
L['Basic redirect cannot route macros or ambiguous spells. Use target mode or focus mode with [@focus] macros to control behavior.'] = [[O redirecionamento básico não pode rotear macros ou magias ambíguas. Use o modo alvo ou modo foco com macros [@focus] para controlar o comportamento.]];
L['Buttons emulating modifiers will instead trigger bindings when pressed and released within the time span.'] = [[Os botões emulando modificadores irão, em vez disso, acionar ligações quando pressionados e soltos dentro do intervalo de tempo.]];
L['Change how the raid cursor acquires a target. Redirect and focus modes will reroute appropriate spells without changing your target.'] = [[Altera como o cursor de raide adquire um alvo. Os modos de redirecionamento e foco redirecionarão magias apropriadas sem mudar seu alvo.]];
L['Controls when your character transitions from strafing to facing your movement stick direction while in combat. Expressed in degrees, from looking straight forward.'] = [[Controla quando seu personagem passa do movimento lateral para virar na direção do seu stick de movimento em combate. Expresso em graus, a partir de olhar diretamente para frente.]];
L['Controls when your character transitions from strafing to facing your movement stick direction while in the air. Expressed in degrees, from looking straight forward.'] = [[Controla quando seu personagem passa do movimento lateral para virar na direção do seu stick de movimento no ar. Expresso em graus, a partir de olhar diretamente para frente.]];
L['Controls when your character transitions from strafing to facing your movement stick direction. Expressed in degrees, from looking straight forward.'] = [[Controla quando seu personagem passa do movimento lateral para virar na direção do seu stick de movimento. Expresso em graus, a partir de olhar diretamente para frente.]];
L['Enable custom mouse handling, automating cursor toggling and timeout while using left and right mouse button emulation.'] = [[Ativar gerenciamento personalizado do mouse, automatizando a alternância e o tempo limite do cursor enquanto usa emulação dos botões esquerdo e direito do mouse.]];
L['Explicit only matches hard locked targets through using a targeting binding, while implicit matches targets you attack.'] = [[Explícito só corresponde a alvos fixos por meio do uso de uma ligação de seleção de alvo, enquanto implícito corresponde a alvos que você ataca.]];
L['Left mouse button emulation toggles center-fixed mode instead of free-roaming mode. Right mouse button emulation toggles free-roaming mode instead of center-fixed mode.'] = [[A emulação do botão esquerdo do mouse alterna o modo fixo no centro em vez do modo livre. A emulação do botão direito do mouse alterna o modo livre em vez do modo fixo no centro.]];
L['Macro condition to enable the click override button. The default condition clicks right mouse button when there is no enemy target.'] = [[Condição de macro para ativar o botão de substituição de clique. A condição padrão clica com o botão direito quando não há alvo inimigo.]];
L['Modifiers should be in descending order. M2M1, for example, is the Ctrl and Shift modifiers held at the same time.'] = [[Modificadores devem estar em ordem decrescente. M2M1, por exemplo, são os modificadores Ctrl e Shift segurados ao mesmo tempo.]];
L['Opacity is expressed in percentage, where 100 is fully visible and 0 is fully transparent. Values outside of the 0-100 range will be clamped.'] = [[A opacidade é expressa em porcentagem, onde 100 é totalmente visível e 0 é totalmente transparente. Valores fora da faixa 0-100 serão limitados.]];
L['Takes the format of...\n'] = [[Toma o formato de…
]];
L['The bindings underlying the button combinations will be unavailable while the cursor is in use.\n\nModifier can also be configured on a per button basis.'] = [[As ligações subjacentes às combinações de botões ficarão indisponíveis enquanto o cursor estiver em uso.

O modificador também pode ser configurado por botão.]];
L['Use a custom set of buttons for the game menu, otherwise the button set will be dynamically determined.'] = [[Usar um conjunto personalizado de botões para o menu do jogo, caso contrário o conjunto de botões será determinado dinamicamente.]];
L['Use a shoulder button combined with crosshair for smooth and precise interactions. The click is performed at crosshair or cursor location.'] = [[Use um botão de ombro combinado com a mira para interações suaves e precisas. O clique é executado na localização da mira ou do cursor.]];
L['Use global game tooltip for loot information, allowing other addons to add information to lootable items.'] = [[Usar dica de ferramenta global do jogo para informações de saque, permitindo que outros addons adicionem informações a itens saqueáveis.]];
L['When set to zero, always face your movement stick direction.\nWhen set to max, never face your movement stick direction.'] = [[Quando definido para zero, sempre vire na direção do seu stick de movimento.
Quando definido para máximo, nunca vire na direção do seu stick de movimento.]];
L['While disabled, cursor timeout, and toggling between free-roaming and center-fixed cursor are also disabled.'] = [[Enquanto desativado, o tempo limite do cursor e a alternância entre cursor livre e fixo central também estão desativados.]];
L['Your %s device has separate handling for Bluetooth and wired connection.\nWhich one are you using?'] = [[Seu dispositivo %s tem gerenciamento separado para conexão Bluetooth e com fio.
Qual você está usando?]];
