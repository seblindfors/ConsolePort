local L = select(2, ...).Locale;
---------------------------------------------------------------
-- zhTW 繁體中文 traditional Chinese
---------------------------------------------------------------
---------------------------------------------------------------
-- Short / curated keys
---------------------------------------------------------------
L.ACTIONBAR_FORM_ACTIVE_DESC  = '此形態當前處於激活狀態，你的主動作條正在顯示與之相關的技能。'; -- en:b400a632
L.DESC_CAMERAZOOMIN           = '將鏡頭拉近。按住進行連續縮放。'; -- en:55f9b91f
L.DESC_CAMERAZOOMOUT          = '將鏡頭拉遠。按住進行連續縮放。'; -- en:a6b9d796
L.DESC_OPENALLBAGS            = '打開/關閉所有背包。'; -- en:4a74797f
L.DESC_RING_TARGET            = '以環形顯示你的單位池，讓你可以使用徑向搖桿選擇目標單位。'; -- en:294b636e
L.DESC_TOGGLEWORLDMAP_CLASSIC = '顯示/關閉世界地圖。'; -- en:00548e70
L.DESC_TOGGLEWORLDMAP_RETAIL  = '顯示/關閉世界地圖和任務日誌。'; -- en:621a94e8
L.FORMAT_HOLD_BINDING         = '%s（按住）'; -- en:c3ecd1b3
L.FORMAT_RING_NUMERICAL       = '|cFF00FFFF%s|r 環'; -- en:68d18518
L.NAME_EASY_MOTION            = '目標單位框架（按住）'; -- en:e6f0c131
L.NAME_QUICK_MENU             = '快捷菜單'; -- en:ed9a0668
L.NAME_RAID_CURSOR_FOCUS      = '團隊光標(焦點)'; -- en:d350d370
L.NAME_RAID_CURSOR_TARGET     = '團隊光標（目標）'; -- en:8182d5d5
L.NAME_RAID_CURSOR_TOGGLE     = '切換團隊光標'; -- en:79fb9d46
L.NAME_RING_MENU              = '菜單環'; -- en:8d7e5939
L.NAME_RING_PET               = '寵物環'; -- en:8dab5a0e
L.NAME_RING_TARGET            = '目標環（按住）'; -- en:59e8a9cb
L.NAME_RING_UTILITY           = '工具環'; -- en:96bc880d
L.NAME_UI_CURSOR_TOGGLE       = '切換界面光標'; -- en:2d6091b5
L.RING_EMPTY_DESC             = '你在此環中尚未放置任何能力。'; -- en:044cf09a
---------------------------------------------------------------
-- Long / curated block entries
---------------------------------------------------------------
L.ACTIONBAR_FORM_DESC = [[激活此形態將自動切換你的主動作條以顯示與此形態相關的技能。

該形態與你的主動作條共享快捷鍵，允许你使用常規組合鍵访問此形態中的技能。

當你退出此形態時，你的主動作條將恢複到之前的狀態，顯示你的常規技能。]]; -- en:a751197a
L.ACTIONBAR_MAIN_DESC = [[主動作條是你放置循環技能和其他常用動作的主要位置。

該動作條是動態的，可以根據你當前的狀况自動切換到不同的页面。

例如，當你進入載具、參與宠物對戰、變身為不同形態、進入戰斗姿態或控製其他單位時，主動作條會切換到特殊的技能組。

這允许你访問特定情境下的技能，无需手動更改你的動作條設置。

當你回到正常狀態時，你的常規技能將重新出現在動作條上。]]; -- en:8e47cecd
L.ACTIONBAR_PAGE_MISMATCH_DESC = [[由於動作條系統最初的設計方式，動作條的實際页码并不總是與顯示的名称匹配。

如果你没有使用自定義動作页面解決方案，可以忽略此差异。两者都顯示以供參考。]]; -- en:9fd917fd
L.ADD_NEW_RING_TEXT = [[|cFFFFFF00創建新環|r
请為新環選擇一個名称：]]; -- en:00af872a
L.CLEAR_RING_TEXT = [[|cFFFFFF00清空 %s|r
你確定要清空此環吗？]]; -- en:ebc807d8
L.CONTROLS_GAMEPAD_TESTER_ACTION = [[
	如果没有检测到输入，测試將在幾秒後自動過期。
]]; -- en:0f591dc7
L.CONTROLS_GAMEPAD_TESTER_DESC = [[
	使用测試工具來驗證你的手柄是否正常工作。

	测試將要求你按下手柄上的按鈕并移動轴，
	以確保所有按鈕和传感器按预期工作。

	故障排除：

	- 確保你的手柄已连接并被操作系統識別。

	- 检查是否有冲突的软件可能干扰你的設備，
	例如 Windows 上後台运行的 Steam。

	- 如果使用掌上电腦，请確保設備在控製中心中設置為游戏模式。
	桌面模式將无法正常工作。

	- 更新驱動程序并安裝手柄所需的任何软件。
]]; -- en:fd1ed2f5
L.CONTROLS_GENERAL_INFO = [[
	選擇你偏好的控製方案。
]]; -- en:3f779845
L.CONTROLS_MODIFIERS_CUSTOM = [[
	使用自定義修飾鍵設置。

	建議將修飾鍵設置在肩鍵或扳機上，因為它們是手柄上最容易访問的按鈕。
]]; -- en:964cdf45
L.CONTROLS_MODIFIERS_DESC = [[
	修飾鍵在快捷鍵集之間切換，并模拟鍵盤控製鍵（Shift、Ctrl、Alt）。

	按住修飾鍵將临時切換你的快捷鍵到另一個集合，扩展你的可用操作。

	修飾鍵可以被點擊 — 快速按下并釋放 — 以執行常規快捷鍵。

	它們也可以相互組合；使用两個修飾鍵總共可以访問四個快捷鍵集，
	三個修飾鍵可以提供八個快捷鍵集。

	對於大多數玩家來說，两個修飾鍵就足以拥有一個舒适的快捷鍵集，
	而不會增加太多複杂性。
]]; -- en:b083ec08
L.CONTROLS_MODIFIERS_LEFT = [[
	使用左手修飾鍵，將移動和快捷鍵集切換保持在手柄的左侧。

	為左右手分配單独的角色可能有助於人體工程學和协調性。
]]; -- en:507e5d94
L.CONTROLS_MODIFIERS_TRIGGERS = [[
	使用两個扳機作為修飾鍵，將你的快捷鍵在左右两侧之間分開。

	如果你正在从 FFXIV 過渡過來，或者你偏好十字栏的心智模型，這可能會有所帮助。
]]; -- en:70401fbd
L.CONTROLS_MOUSE_BUTTONS_DESC = [[
	鼠標按鍵可以被模拟，以提供類似鼠標的功能。

	在某些情况下這些快捷鍵是至關重要的，例如確認地面上的法術放置、
	在人群中精確選擇目標，以及一些小眾的界面操作。

	它們可以與修飾鍵組合，以進一步複製鼠標的功能。

	這些按鈕還用於切換光標，光標可以有三種不同的狀態：

	- 自由：你可以使用手柄在屏幕上移動光標。

	- 居中：光標固定在屏幕中央，用於瞄准對象和角色
	以及在地面上放置法術。

	- 隐藏：光標仍居中，但在屏幕上不可見。其位置由一個准星指示。
]]; -- en:e088d19f
L.CONTROLS_MOUSE_CUSTOM = [[
	使用自定義鼠標按鍵設置。

	《魔兽世界》以两種独立、大多隐藏的方式處理鼠標按鍵。

	- 當你點擊游戏界面（如按鈕或菜單）時，界面只對
	鼠標點擊作出反應，這可以由手柄模拟。

	- 當你點擊游戏世界中的东西（如選擇目標或交互）時，它使用常規的快捷鍵。

	強烈建議將這些操作放在一起，以承担與鼠標相同的角色。
]]; -- en:3e862670
L.CONTROLS_MOUSE_INVERTED = [[
	使用反轉的鼠標按鍵快捷鍵。

	使用左摇杆在居中和隐藏光標模式之間切換，以及進行右鍵單擊。

	使用右摇杆切換自由光標模式，以及進行左鍵單擊。
]]; -- en:16d3d6d2
L.CONTROLS_MOUSE_REGULAR = [[
	使用常規的鼠標按鍵快捷鍵。

	使用左摇杆切換自由光標模式，以及進行左鍵單擊。

	使用右摇杆在居中和隐藏光標模式之間切換，以及進行右鍵單擊。
]]; -- en:75e9f21b
L.CONTROLS_MOVEMENT_BALANCED_DESC = [[
	平衡移動是坦克和跟随移動之間的折衷。

	在戰斗和旅行中，此配置將在每個方向橫移最多 115 度，
	這意味着你在侧向移動時仍然面向前方。

	如果你將摇杆進一步向下移動，你的角色將過渡到跟随你的移動方向。
	查看角色的頭部以了解他們面對的方向。

	115 度是在不损失任何移動速度的情况下提供最大覆盖範圍的最佳點。
]]; -- en:3355743a
L.CONTROLS_MOVEMENT_DESC = [[
	可以根據你的游戏风格自定義移動控製。

	手柄使用模拟移動，這意味着你可以朝任何方向奔跑，
	并通過改變施加在摇杆上的压力來步行。

	游戏在很大程度上依赖橫移作為機製，
	你在面對不同方向的同時侧向移動。

	你可以自定義你的角色何時在橫移和
	轉向面對你的移動方向之間過渡。

	高亮其中一種配置并移動你的左摇杆
	以测試它。
]]; -- en:9d22c4f0
L.CONTROLS_MOVEMENT_FOLLOW_DESC = [[
	「跟随」移動專注於跟随你正在移動的方向。

	在戰斗和旅行中，此配置將永遠不會橫移，
	也永遠不會向後行走。

	這對於經常或總是使用單摇杆配置的玩家可能很有用。
]]; -- en:45773d56
L.CONTROLS_MOVEMENT_TANK_DESC = [[
	坦克移動專注於在戰斗中保持面向前方的位置。

	在戰斗中，此配置將始終橫移，并向後行走以保持面向前方。

	在旅行期間，此配置將始終跟随移動方向。
]]; -- en:9fcbcaaf
L.DEFAULTS_BINDINGS_EMPTY_DESC = [[
	从空白開始。

	此操作將清除你所有當前的手柄快捷鍵，包括暴雪的默認設置，
	以便你可以从頭開始設置快捷鍵。

	此操作不會覆盖或干扰現有的鍵盤快捷鍵，
	但请記住，動作條在两者之間是共享的。

	如果你計劃在鍵盤和手柄之間切換，建議更改你的
	手柄快捷鍵，而不是在動作條上移動技能。
]]; -- en:51053386
L.DEFAULTS_BINDINGS_PRESET_DESC = [[
	應用推荐的快捷鍵。

	這些快捷鍵基於你之前的選擇，應該可以為你的手柄設置提供一個良好的起點。你随時可以更改它們。

	此操作不會覆盖或干扰現有的鍵盤快捷鍵，
	但请記住，動作條在两者之間是共享的。

	如果你計劃在鍵盤和手柄之間切換，建議更改你的
	手柄快捷鍵，而不是在動作條上移動技能。
]]; -- en:6ac789b1
L.DEFAULTS_GENERAL_INFO = [[
	通過應用手柄的推荐設置和快捷鍵來完成設置。
]]; -- en:c436023e
L.DEFAULTS_SETTINGS_APPLIED = [[
	你的手柄類型 (%s) 的推荐設置已應用。
]]; -- en:16be45b5
L.DEFAULTS_SETTINGS_DESC = [[
	為你的手柄類型 (%s) 應用推荐設置：
]]; -- en:15a4050f
L.DEFAULTS_SETTINGS_NOTWEAK = [[
	你的手柄類型 (%s) 没有任何推荐設置可應用。
]]; -- en:067a8a20
L.DESC_EASY_MOTION = [[
	為你的單位框架中的每一個單位生成一個快捷鍵，
	按下對應快捷鍵即可切換目標。

	按住快捷鍵，然後點擊你要選擇的目標上
	看到的提示鍵，然後釋放快捷鍵即可更改目標。

	強烈推薦5人本中的治療職業使用，
	因為它提供了在較小組中非常快速的目標選擇方法。

	在團隊中，該功能在選取目標時操作可能過於複雜，會較為難用。
	該功能是切換友方目標的方案之一，請參閱"團隊光標"查看另一個方案。
]]; -- en:0f9384b6
L.DESC_EXTRAACTIONBUTTON1 = [[
	額外動作按鈕容納一種临時能力，用於
	各種任務、場景和首领戰斗。

	當此快捷鍵未設置時，額外動作按鈕始終
	可在工具環上使用。

	此按鈕作為常規動作按鈕出現在你的手柄動作條上，
	但你无法更改其內容。
]]; -- en:6dd42998
L.DESC_INTERACTTARGET = [[
	允许你與游戏世界中的 NPC 和對象互動。

	具有與居中光標相同的能力，但不需要你將光標或准星直接對准目標。

	可交互對象在範圍內時會被高亮顯示。
]]; -- en:b1478add
L.DESC_JUMP = [[
	還可以用於在水下向上游泳、與飞行坐騎一起上升，
	以及在驭龍術中起飞或向上扑翼。

	跳跃對於在執行需要拇指的左手動作時
	弥补移動中的空隙很有用。

	在常規設置中，左摇杆控製你的移動。
	如果你需要在移動中按下方向鍵組合，
	可以使用跳跃來维持你的前進動量，同時
	短暫地將拇指从摇杆上移開。
]]; -- en:4c032315
L.DESC_KEY_BUTTON1 = [[
	用於開啟/關閉自由光標模式，在該模式下你可以使用鏡頭桿（一般為右搖桿）移動鼠標指針
]]; -- en:fd3d111a
L.DESC_KEY_BUTTON2 = [[
	用於切換居中光標模式，允许你在游戏世界的中心固定鼠標位置與對象和角色互動。
]]; -- en:2f5c87e4
L.DESC_QUICK_MENU = [[
	一個快捷菜單，集中游戏中常用的操作，
	例如對組隊戰利品進行掷骰、取消增益效果
	或使用背包中的物品。
]]; -- en:0365846b
L.DESC_RAID_CURSOR = [[
	切換一個夹緊到你屏幕上單位框架的光標，
	允许你在保持另一個目標的同時治疗友方玩家。

	團隊光標也可以設置為直接目標選擇，
	移動光標會切換你當前的目標。

	使用時，團隊光標占用一組
	方向鍵組合來控製光標位置。

	在路由模式下，光標不會重新路由宏或
	模糊的法術，例如牧師的「忏悔」。

	请參阅「單位框架瞄准」以获取其他選擇。
]]; -- en:cacdf9c0
L.DESC_RING_CUSTOM = [[
	一個環形菜單，你可以在其中添加你不想為之牺牲動作條空間的
	物品、法術、宏和坐騎。

	要使用，按住快捷鍵，朝你想選擇的物品方向倾斜你的摇杆，
	然後釋放快捷鍵。

	要从環中删除物品，將該物品聚焦後按提示框提示操作。
]]; -- en:159abd06
L.DESC_RING_MENU = [[
	一個環形菜單，將常用面板和頻繁操作
	集中在一個地方以便快速訪問。

	該環還可以通過切換頁面從遊戲菜單中訪問，
	無需單獨綁定。
]]; -- en:7ee244a1
L.DESC_RING_PET = [[
	一個環形菜單，允許你控制當前的寵物。
]]; -- en:b1c4b5d3
L.DESC_RING_UTILITY = [[
	一個環形菜單，你可以在其中添加你不想為之牺牲動作條空間的
	物品、法術、宏和坐騎。

	要使用，按住快捷鍵，朝你想選擇的物品方向倾斜你的摇杆，
	然後釋放快捷鍵。

	要向環中添加物品，按界面光標的提示操作，
	或者，用你的鼠標光標拾取物品，然後按快捷鍵將其放入環中。

	要从環中删除物品，將該物品聚焦後按提示框提示操作。

	工具環會自動添加未放在你動作條上的任務物品和临時能力。
]]; -- en:de107e96
L.DESC_TARGETNEARESTENEMY = [[
	在你面前最近的敌方目標之間切換。
	没有當前目標時，將選擇最居中的敌人。
	否則，它將在最近的目標之間循環。

	按住可在決定切換目標之前
	高亮顯示目標。

	建議用作辅助目標選擇快捷鍵，
	或在休闲游戏中用作主要目標選擇快捷鍵，
	或者當目標扫描需要太多精度而不舒适時使用。

	不建議用於地下城或其他高精度場景。
]]; -- en:981bc29c
L.DESC_TARGETSCANENEMY = [[
	在你面前的狹窄圓錐中掃描敵人。
	按住可持續切換，直至鬆開。

	特別適用於在戰鬥中快速切換目標
	精確度高。

	最靠近圓錐中心的目標將被優先選擇。
	如果目標更接近圓錐中心，即使他離你距離更遠，也會被優先選擇。

	推薦大多數玩家將其設置為主要的切換目標快捷鍵。 
]]; -- en:2de05bb9
L.DESC_TOGGLEAUTORUN = [[
	自動奔跑將使你的角色继续朝你面對的方向移動，
	而无需你的任何输入。

	自動奔跑對於减轻長時間移動的拇指疲劳很有用，
	或者在你移動時解放你的拇指做其他事情。
]]; -- en:9e97af4b
L.DESC_TOGGLEGAMEMENU = [[
	菜單快捷鍵處理鍵盤上按下 Esc 鍵時发生的所有功能。
	它根據當前游戏狀態處理不同的操作。

	如果有與法術或目標選擇相關的正在進行的動作，
	它們將被取消。在有活動目標的情况下按下快捷鍵
	將清除它。在施法時按下快捷鍵將
	中斷施法。

	快捷鍵還根據屏幕上當前顯示的內容處理
	各種其他情况。例如，如果有面板
	打開，例如法術書，快捷鍵將執行
	必要的操作來關閉或隐藏它。

	如果以上情况都不适用，按下時游戏菜單將
	打開或關閉。
]]; -- en:adfccfe4
L.DEVICE_DESC_PLAYSTATION4 = [[
	PlayStation 4 控製器（也称為 DualShock 4）是 Sony 的上一代手柄。

	它是一款功能丰富的手柄，具有觸摸板、動作控製以及在游戏中支持其所有按鈕。

	要充分利用所有功能，你可能需要安裝 PlayStation Accessories (Windows)。
]]; -- en:7bea4ad9
L.DEVICE_DESC_PLAYSTATION5 = [[
	PlayStation 5 控製器（也称為 DualSense）目前是《魔兽世界》最好的手柄。

	它是目前最完整的手柄，具有動作控製、觸摸板，以及在 Edge 變體的情况下，原生背部拨片。
	手柄上的所有按鈕都可以在游戏中使用。

	要充分利用所有功能，你可能需要安裝 PlayStation Accessories (Windows)。
]]; -- en:c5f15091
L.DEVICE_DESC_STEAMDECK = [[
	Steam Deck 通常通過 Steam 客戶端的 Proton 运行《魔兽世界》。

	通過 Steam 玩游戏時，設備應使用至少覆盖標准 Xbox 布局的游戏配置文件。

	手柄+鼠標觸控板提供了坚實的基础。

	Steam Deck 不能在《魔兽世界》中原生使用其拨片。
	可以使用模拟或在 Steam Input 設置中使用鍵盤鍵來映射拨片。

	游戏內 Steam Deck 预設也可能适合其他掌上电腦，因為控製布局相似。
]]; -- en:2a5e4173
L.DEVICE_DESC_SWITCHPRO = [[
	Nintendo Switch Pro 控製器的布局與 Xbox 控製器類似，但按鈕標簽反轉。

	Pro 控製器有四個中央按鈕，使其相對於標准 Xbox 控製器略有優势。

	Nintendo Switch 2 Pro 控製器不能在游戏中原生使用其拨片或 C 按鈕。
	使用外部软件，例如 Steam 或 reWASD，可以將它們映射到鍵盤鍵，允许在游戏中使用。
]]; -- en:79260874
L.DEVICE_DESC_XBOX = [[
	Xbox 變體是最常見的手柄，并被《魔兽世界》良好支持。

	Xbox Elite 控製器不能在游戏中原生使用其拨片，但可以使用它們來模拟其他手柄按鈕，
	使用 Xbox Accessories 應用 (Windows)。

	使用外部软件，例如 Steam 或 reWASD，可以將拨片映射到鍵盤鍵，允许在游戏中使用。

	中央按鈕保留給 Xbox Guide，无法在游戏中使用。

	也推荐用於 Steam Input，與其模拟的 Xbox 360 控製器一致。
]]; -- en:654501d3
L.DISC_KEY_BUTTON1 = [[
	當你的一個按鈕設置為模擬左鍵點擊時，此快捷鍵無法更改。
]]; -- en:e811ebc6
L.DISC_KEY_BUTTON2 = [[
	當你的一個按鈕設置為模拟右鍵點擊時，此快捷鍵无法更改。
]]; -- en:b85c78b2
L.EXPORT_DATA_TEXT = [[

|cFFFFFF00導出|r

選擇你要導出的數據。將生成一個字符串，你可以將其粘貼到另一個客戶端，或與他人分享。

使用 %s 複製字符串。
]]; -- en:1741e6a6
L.GFX_GENERAL_INFO = [[
	選擇與你的手柄外觀最接近的手柄圖形。

	選擇圖形不會改變手柄的工作方式，它只會改變界面的外觀。

	圖形用於顯示當前哪些按鈕绑定了哪些操作，并為你的手柄布局提供視覺參考。

	根據你的選擇，會提供一些可選的設置建議。
]]; -- en:54457360
L.IMPORT_DATA_TEXT = [[

|cFFFFFF00导入|r

在下面粘貼导出的字符串，然後加載并選擇要导入的數據。导入的數據將在适用時覆盖你當前的數據。

使用 %s 从源複製字符串，使用 %s 在下面粘貼字符串。
]]; -- en:145f78fb
L.IMPORT_FAILED_TEXT = [[

|cFFFFFF00导入|r

导入失敗：
]]; -- en:a7555666
L.LINK_COPY = [[
	鏈接到 %s。

	按 Ctrl+A 選擇，Ctrl+C 複製。

	在浏览器中粘貼 (Ctrl+V) 鏈接。
]]; -- en:3f396345
L.LINK_DISCORD_TEXT = [[
	你可以在這個社區中获得支持、讨論玩法、分享想法，并結識誌同道合的玩家。

	點擊此處加入服務器。
]]; -- en:e2f9740c
L.LINK_PATREON_TEXT = [[
	這個插件的開发和维护需要大量的時間和精力，
	但 ConsolePort 將始終完全免費。

	成為 Patreon 支持者以解鎖你的 Discord 徽章，并支持項目的未來。

	點擊此處成為讚助者。
]]; -- en:3cc9532e
L.LINK_PAYPAL_TEXT = [[
	捐款將直接重新投入插件的開发和维护。

	任何贡献，无論大小，都將受到高度讚赏。

	點擊此處通過 PayPal 捐款。
]]; -- en:28c6265a
L.REMOVE_RING_TEXT = [[|cFFFFFF00移除 %s|r
你確定要移除此環吗？]]; -- en:1a461a1a
L.RING_MENU_DESC = [[創建你自己的環形菜單，你可以在其中添加不想犧牲動作欄空間的物品、法術、宏和坐騎。

要使用，請按住選定的快捷鍵，向你要選擇的物品方向傾斜搖桿，然後釋放快捷鍵。

默認環或 |CFF00FF00工具環|r 具有特殊屬性，可以幫你使用任務物品或其他交互物品，並且不是靜態的。它將根據需要自動添加和移除物品。

如果你想創建一個在輸出循環中用到的環，強烈建議使用自定義環而不是工具環。]]; -- en:39d4577b
L.SELECTED_RING_TEXT = [[這是你當前選擇的環。
當你按住快捷鍵時，所有你選擇的能力將以環的形式顯示在屏幕上。

將你控制鏡頭用的搖桿（一般為右搖桿）向你要使用的能力或物品的方向傾斜，然後施放快捷鍵以確認。]]; -- en:2cdfa5d3
L.SET_RING_BINDING_TEXT = [[
|cFFFFFF00設置快捷鍵|r

按下按鈕組合以為此環選擇一個新的快捷鍵。

]]; -- en:1c0e03f4
L.SLOT_NO_BINDING = [[
|cFFFFFF00設置快捷鍵|r

%s 在 %s 中尚未分配快捷鍵。

按下按鈕組合以為此插槽選擇一個新的快捷鍵。

]]; -- en:74326275
L.SLOT_SET_BINDING = [[
|cFFFFFF00設置快捷鍵|r

按下按鈕組合以為 %s 選擇一個新的快捷鍵。

]]; -- en:d1933130
---------------------------------------------------------------
-- Literals
---------------------------------------------------------------
L['2D deadzone for camera that takes into account pitch and yaw movement together.'] = '用於摄像機的 2D 死區，同時考虑俯仰和偏航运動。';
L['2D deadzone for movement that takes into account X and Y movement together.'] = '用於移動的 2D 死區，同時考虑 X 和 Y 移動。';
L['A button cluster for all modifiers of a single button.'] = '單個按鈕所有修飾鍵的按鈕集群。';
L['A cluster bar with a toolbar below it, laid out horizontally.'] = '集群條下方有水平放置的工具栏。';
L['A cluster bar with a toolbar below it.'] = '集群條下方有工具栏。';
L['A divider to separate elements.'] = '用於分隔元素的分隔符。';
L['A friendly soft target can be acquired while having an enemy hard target.'] = '在拥有敌對硬目標的同時，可以获取友善软目標。';
L['A regular action bar.'] = '常規動作條。';
L['A ring of buttons for pet commands.'] = '用於宠物指令的按鈕環。';
L['A toolbar with XP indicators, shortcuts, class specific bars, and miscellaneous information.'] = '带有經驗值指示器、快捷方式、職業相關條和杂項信息的工具栏。';
L['About'] = '關於';
L['Acceleration of cursor per second as it continues to move.'] = '光標在继续移動時每秒的加速度。';
L['Accent Color'] = '強調色';
L['Accept Button'] = '接受按鈕';
L['Action Bar Configuration'] = '動作條配置';
L['Action bar is scaled separately.'] = '動作條單独缩放。';
L['Action Bar Loadout'] = '動作條配置';
L['Action Bar Loadout (Deprecated)'] = '動作條配置（已棄用）';
L['Action Bar Presets'] = '動作條预設';
L['Action Bar Setup'] = '動作條設置';
L['Action Button'] = '動作按鈕';
L['Action Button Group'] = '動作按鈕組';
L['Action Page'] = '動作页面';
L['Action Page Condition'] = '動作页面條件';
L['Action Page Response'] = '動作页面響應';
L['Activate targeting components only while their bindings are in use.'] = '僅在相應快捷鍵被使用時激活目標選擇組件。';
L['Active Color'] = '活動颜色';
L['Active Device'] = '活動設備';
L['Add a new element to your loadout.'] = '向你的配置添加新元素。';
L['Add to %s'] = '添加到 %s';
L['Add, remove or reset a frame from cursor stack.'] = '从光標堆栈添加、删除或重置框架。';
L['Affects both mouse and gamepad.'] = '影響鼠標和手柄。';
L['Alignment'] = '對齐';
L['Alignment of the counter text on buttons.'] = '按鈕上計數器文本的對齐方式。';
L['Alignment of the hotkey text on buttons.'] = '按鈕上快捷鍵文本的對齐方式。';
L['Alignment of the macro text on buttons.'] = '按鈕上宏文本的對齐方式。';
L['All combines all connected devices into one.'] = '「全部」將所有连接的設備合并為一個。';
L['Allow binding discrete radial stick inputs.'] = '允许绑定離散的徑向摇杆输入。';
L['Allow binding multiple combos to the same binding.'] = '允许將多個組合绑定到同一快捷鍵。';
L['Allow Binding Overlap'] = '允许快捷鍵重叠';
L['Allow cursor to interact with and show preference for group loot frames.'] = '允许光標與組隊拾取框架交互并優先顯示。';
L['Allow cursor to interact with and show preference for popups and static dialogs.'] = '允许光標與彈出窗口和静態對話框交互并優先顯示。';
L['Allow cursor to interact with the entire interface, not only panels.'] = '允许光標與整個界面交互，而不僅僅是面板。';
L['Allow Radial Bindings'] = '允许徑向快捷鍵';
L['Allows the use of the touchpad to control cursor movement.'] = '允许使用觸摸板控製光標移動。';
L['Alphabet to use for dictionary suggestions and word processing.'] = '用於字典建議和文字處理的字母表。';
L['Always keep cursor centered and visible when controlling camera.'] = '控製摄像機時始終保持光標居中并可見。';
L['Always Show All Buttons'] = '始終顯示所有按鈕';
L['Always Show Mouse Cursor'] = '始終顯示鼠標光標';
L['Always show nameplate for soft enemy target.'] = '始終為软敌方目標顯示姓名板。';
L['Always show nameplate for soft friendly target.'] = '始終為软友方目標顯示姓名板。';
L['Always show tooltip for an automatically acquired target, as long as it exists.'] = '只要目標存在，始終為自動获取的目標顯示提示框。';
L['An action button in a group.'] = '組中的動作按鈕。';
L['Analog Movement'] = '模拟移動';
L['Anchor'] = '锚點';
L['Anchor point of parent to pair with.'] = '父級用於配對的锚點。';
L['Anchor point of the counter text on buttons.'] = '按鈕上計數器文本的锚點。';
L['Anchor point of the hotkey icon on group buttons.'] = '組按鈕上快捷鍵圖標的锚點。';
L['Anchor point of the hotkey text on buttons.'] = '按鈕上快捷鍵文本的锚點。';
L['Anchor point of the macro text on buttons.'] = '按鈕上宏文本的锚點。';
L['Anchor point to attach.'] = '用於附加的锚點。';
L['Apply default settings to the current category or all settings.'] = '將默認設置應用於當前類別或所有設置。';
L['Arc Allowance'] = '弧度允许';
L['Are you sure you want to delete %s from %s?'] = '你確定要从 %s 删除 %s 吗？';
L['Are you sure you want to overwrite %s with %s?'] = '你確定要用 %s 覆盖 %s 吗？';
L['Are you sure you want to regenerate the keyboard dictionary? You will lose all custom phrases.'] = '你確定要重新生成鍵盤字典吗？你將丢失所有自定義短語。';
L['Are you sure you want to reset all device profiles?'] = '你確定要重置所有設備配置文件吗？';
L['Are you sure you want to reset the keyboard layout?'] = '你確定要重置鍵盤布局吗？';
L['Are you sure you want to reset your device profile?'] = '你確定要重置你的設備配置文件吗？';
L['Are you sure you want to wipe the keyboard dictionary? It currently contains %d words.'] = '你確定要清除鍵盤字典吗？它當前包含 %d 個單詞。';
L['Area where the interact key can find a suitable target.'] = '互動鍵可以找到合适目標的區域。';
L['Artwork flavor.'] = '美術风格變體。';
L['Artwork for the interface.'] = '界面美術。';
L['Artwork style.'] = '美術樣式。';
L['Assign or clear bindings for this set.'] = '為此集合分配或清除快捷鍵。';
L['Auto-adjusts your camera, allowing you to control movement with a single stick.'] = '自動調整你的摄像機，允许你使用單個摇杆控製移動。';
L['Auto-Sell Gear Level Limit'] = '自動出售裝備等級限製';
L['Auto-Sell Junk'] = '自動出售杂物';
L['Auto-set target to match soft target.'] = '自動設置目標以匹配软目標。';
L['Automatic Binding Backups'] = '自動快捷鍵備份';
L['Automatic Cursor Timeout'] = '自動光標超時';
L['Automatic Tooltip Duration'] = '自動提示框持续時間';
L['Automatically add tracked quest items and extra spells to main utility ring.'] = '自動將追踪的任務物品和額外法術添加到主工具環。';
L['Automatically backup your bindings when you change them, for import and export.'] = '當你更改快捷鍵時自動備份它們，用於导入和导出。';
L['Automatically Bind Extra Items'] = '自動绑定額外物品';
L['Automatically Control Cursor Pickups'] = '自動控製光標拾取';
L['Automatically control cursor when picking up items.'] = '拾取物品時自動控製光標。';
L['Automatically disabled if an inactive component is clicked from a macro.'] = '如果通過宏點擊了未激活的組件，將自動禁用。';
L['Automatically sell junk when interacting with a merchant.'] = '與商人互動時自動出售杂物。';
L['Axis Interpretation'] = '轴解釋';
L['Basic redirect cannot route macros or ambiguous spells. Use target mode or focus mode with [@focus] macros to control behavior.'] = '基本重定向无法路由宏或模糊的法術。使用目標模式或焦點模式以及 [@focus] 宏來控製行為。';
L['Battery Level'] = '电池电量';
L['Binding Catch Timeframe'] = '快捷鍵捕获時間';
L['Blend Mode'] = '混合模式';
L['Blend mode of the artwork.'] = '美術的混合模式。';
L['Blizzard_Collections'] = 'Blizzard_Collections';
L['Blizzard_DelvesCompanionConfiguration'] = 'Blizzard_DelvesCompanionConfiguration';
L['Blizzard_HelpPlate'] = 'Blizzard_HelpPlate';
L['Blizzard_HouseEditor'] = 'Blizzard_HouseEditor';
L['Blizzard_HousingTemplates'] = 'Blizzard_HousingTemplates';
L['Blizzard_MapCanvas'] = 'Blizzard_MapCanvas';
L['Blizzard_PlayerSpells'] = 'Blizzard_PlayerSpells';
L['Blizzard_PVPMatch'] = 'Blizzard_PVPMatch';
L['Blizzard_SharedMapDataProviders'] = 'Blizzard_SharedMapDataProviders';
L['Bluetooth'] = '藍牙';
L['Border Vertex Color'] = '邊框頂點颜色';
L['Breadth'] = '宽度';
L['Breadth of the divider.'] = '分隔符的宽度。';
L['Button %d'] = '按鈕 %d';
L['Button or combination used to click when a given condition applies, but act as a normal binding otherwise.'] = '當給定條件适用時用於單擊的按鈕或組合，否則作為常規快捷鍵操作。';
L['Button Set'] = '按鈕集';
L['Button that emulates '] = '模拟以下按鍵的按鈕：';
L['Button that emulates the '] = '模拟以下按鍵的按鈕：';
L['Button to cancel or exit the quick menu.'] = '取消或退出快捷菜單的按鈕。';
L['Button to handle cancel actions, such as exiting menus.'] = '處理取消操作（如退出菜單）的按鈕。';
L['Button to handle contextual actions, such as adding items to the utility ring or passing on loot.'] = '處理上下文操作（如向工具環添加物品或對戰利品棄權）的按鈕。';
L['Button to handle contextual actions, such as adding items to the utility ring.'] = '處理上下文操作（如向工具環添加物品）的按鈕。';
L['Button to insert suggested word.'] = '用於插入建議單詞的按鈕。';
L['Button to move the cursor down.'] = '向下移動光標的按鈕。';
L['Button to move the cursor left.'] = '向左移動光標的按鈕。';
L['Button to move the cursor right.'] = '向右移動光標的按鈕。';
L['Button to move the cursor up.'] = '向上移動光標的按鈕。';
L['Button to replicate left click. This is the primary interface action.'] = '複製左鍵單擊的按鈕。這是主要的界面操作。';
L['Button to replicate right click. This is the secondary interface action.'] = '複製右鍵單擊的按鈕。這是次要的界面操作。';
L['Button to select next suggested word.'] = '選擇下一個建議單詞的按鈕。';
L['Button to select previous suggested word.'] = '選擇上一個建議單詞的按鈕。';
L['Button to use for combo hotkey 1.'] = '用於組合快捷鍵 1 的按鈕。';
L['Button to use for combo hotkey 2.'] = '用於組合快捷鍵 2 的按鈕。';
L['Button to use for combo hotkey 3.'] = '用於組合快捷鍵 3 的按鈕。';
L['Button to use for combo hotkey 4.'] = '用於組合快捷鍵 4 的按鈕。';
L['Button to use for combo hotkey 5.'] = '用於組合快捷鍵 5 的按鈕。';
L['Button to use for combo hotkey 6.'] = '用於組合快捷鍵 6 的按鈕。';
L['Button to use for combo hotkey 7.'] = '用於組合快捷鍵 7 的按鈕。';
L['Button to use for combo hotkey 8.'] = '用於組合快捷鍵 8 的按鈕。';
L['Button to use to erase characters.'] = '用於擦除字符的按鈕。';
L['Button to use to move the cursor leftwards.'] = '用於向左移動光標的按鈕。';
L['Button to use to move the cursor rightwards.'] = '用於向右移動光標的按鈕。';
L['Button to use to trigger the enter command.'] = '用於觸发回車命令的按鈕。';
L['Button to use to trigger the escape command.'] = '用於觸发 Esc 命令的按鈕。';
L['Button to use to trigger the space command.'] = '用於觸发空格命令的按鈕。';
L['Button used to confirm a selected item from a ring.'] = '用於確認从環中選擇的物品的按鈕。';
L['Button used to remove a selected item from an editable ring.'] = '用於从可编辑環中删除選定物品的按鈕。';
L['Button |cFF00FFFF%s|r'] = '按鈕 |cFF00FFFF%s|r';
L['Buttons'] = '按鈕';
L['Buttons emulating modifiers will instead trigger bindings when pressed and released within the time span.'] = '模拟修飾鍵的按鈕在時間範圍內按下并釋放時，將觸发快捷鍵。';
L['Buttons in the cluster bar.'] = '集群條中的按鈕。';
L['Buttons in the group.'] = '組中的按鈕。';
L['By default, shows modifiers on mouseover and on cooldown.'] = '默認情况下，在鼠標悬停和冷却時顯示修飾鍵。';
L['Camera 2D Deadzone'] = '摄像機 2D 死區';
L['Camera Look'] = '摄像機查看';
L['Camera Look is a temporary turn of the camera based on the current analog input.'] = '摄像機查看是基於當前模拟输入的临時摄像機轉動。';
L['Camera Pitch Axis'] = '摄像機俯仰轴';
L['Camera Pitch Speed'] = '摄像機俯仰速度';
L['Camera Pitch-Only Deadzone'] = '摄像機僅俯仰死區';
L['Camera speed for pitch - moving up/down.'] = '用於俯仰的摄像機速度 — 上/下移動。';
L['Camera speed for yaw - turning left/right.'] = '用於偏航的摄像機速度 — 左/右轉動。';
L['Camera Yaw Axis'] = '摄像機偏航轴';
L['Camera Yaw Speed'] = '摄像機偏航速度';
L['Camera Yaw-Only Deadzone'] = '摄像機僅偏航死區';
L['Cancel and clear cursor'] = '取消并清除光標';
L['Cancel Button'] = '取消按鈕';
L['Cannot open configuration menu in combat.'] = '戰斗中无法打開配置菜單。';
L['Casting Bar'] = '施法栏';
L['Center Gap'] = '中心間隙';
L['Center gap, as fraction of overall crosshair size.'] = '中心間隙，占整個准星大小的比例。';
L['Change before touchpad moves the cursor.'] = '觸摸板移動光標前的阈值。';
L['Change bluetooth state for active device.'] = '更改活動設備的藍牙狀態。';
L['Change how the raid cursor acquires a target. Redirect and focus modes will reroute appropriate spells without changing your target.'] = '更改團隊光標获取目標的方式。重定向和焦點模式將重新路由适當的法術而不改變你的目標。';
L['Change or print a value from the active device configuration.'] = '从活動設備配置中更改或打印值。';
L['Character Specific'] = '角色特定';
L['Choose a negative value to invert the axis.'] = '選擇负值以反轉轴。';
L['Class Bar'] = '職業栏';
L['Class Colored Health'] = '職業顏色生命值';
L['Clear all items from this set.'] = '清除此集合中的所有物品。';
L['Clear Binding'] = '清除快捷鍵';
L['Clear configured gamepad bindings and reload interface.'] = '清除配置的手柄快捷鍵并重新加載界面。';
L['Clear Focus Deadzone'] = '清除焦點死區';
L['Clear Focus Mode'] = '清除焦點模式';
L['Clear Focus Time'] = '清除焦點時間';
L['Clear Slot'] = '清除插槽';
L['Clear slot or binding'] = '清除插槽或快捷鍵';
L['Click here to reset your device profile.'] = '點擊此處重置你的設備配置文件。';
L['Click on Down'] = '按下時點擊';
L['Click Override Button'] = '點擊覆盖按鈕';
L['Click Override Condition'] = '點擊覆盖條件';
L['Cluster Action Bar'] = '集群動作條';
L['Cluster Handle'] = '集群手柄';
L['Cluster Modifier Toggle'] = '集群修飾鍵切換';
L['Clusters'] = '集群';
L['Color accent of radial menu items.'] = '徑向菜單項的颜色強調。';
L['Color of a partially selected slice.'] = '部分選中的扇區的颜色。';
L['Color of the active slice.'] = '活動扇區的颜色。';
L['Color of the cooldown swipe effect on buttons.'] = '按鈕上冷却扫掠效果的颜色。';
L['Color of the counter text on buttons.'] = '按鈕上計數器文本的颜色。';
L['Color of the crosshair.'] = '准星的颜色。';
L['Color of the divider.'] = '分隔符的颜色。';
L['Color of the hotkey text on buttons.'] = '按鈕上快捷鍵文本的颜色。';
L['Color of the macro text on buttons.'] = '按鈕上宏文本的颜色。';
L['Color of the main XP bar.'] = '主經驗條的颜色。';
L['Color of the mana indicator on buttons.'] = '按鈕上法力指示器的颜色。';
L['Color of the range indicator on buttons.'] = '按鈕上距離指示器的颜色。';
L['Color of the sticky selection slice.'] = '粘性選擇扇區的颜色。';
L['Color of the vertices on the border of buttons.'] = '按鈕邊框頂點的颜色。';
L['Color the health bars in the target ring by class.'] = '按職業為目標環中的生命條著色。';
L['Color tint for combo hotkey 1.'] = '組合快捷鍵 1 的颜色色調。';
L['Color tint for combo hotkey 2.'] = '組合快捷鍵 2 的颜色色調。';
L['Color tint for combo hotkey 3.'] = '組合快捷鍵 3 的颜色色調。';
L['Color tint for combo hotkey 4.'] = '組合快捷鍵 4 的颜色色調。';
L['Color tint for combo hotkey 5.'] = '組合快捷鍵 5 的颜色色調。';
L['Color tint for combo hotkey 6.'] = '組合快捷鍵 6 的颜色色調。';
L['Color tint for combo hotkey 7.'] = '組合快捷鍵 7 的颜色色調。';
L['Color tint for combo hotkey 8.'] = '組合快捷鍵 8 的颜色色調。';
L['Combine with '] = '結合 ';
L['Combine with use on demand for full cursor control.'] = '結合「按需使用」以获得完整的光標控製。';
L['Combined Input Overlap Time'] = '組合输入重叠時間';
L['Combo Button 1'] = '組合按鈕 1';
L['Combo Button 2'] = '組合按鈕 2';
L['Combo Button 3'] = '組合按鈕 3';
L['Combo Button 4'] = '組合按鈕 4';
L['Combo Button 5'] = '組合按鈕 5';
L['Combo Button 6'] = '組合按鈕 6';
L['Combo Button 7'] = '組合按鈕 7';
L['Combo Button 8'] = '組合按鈕 8';
L['Combo Color 1'] = '組合颜色 1';
L['Combo Color 2'] = '組合颜色 2';
L['Combo Color 3'] = '組合颜色 3';
L['Combo Color 4'] = '組合颜色 4';
L['Combo Color 5'] = '組合颜色 5';
L['Combo Color 6'] = '組合颜色 6';
L['Combo Color 7'] = '組合颜色 7';
L['Combo Color 8'] = '組合颜色 8';
L['Command Modifier'] = '命令修飾鍵';
L['Configure the casting bar.'] = '配置施法栏。';
L['Configure the class related bar.'] = '配置職業相關條。';
L['Connect your controller.'] = '连接你的控製器。';
L['Connected device(s):'] = '已连接的設備：';
L['ConsolePort'] = 'ConsolePort';
L['Context Button'] = '上下文按鈕';
L['Controls the cutoff range where an interactable target or object can be found.'] = '控製可以找到可交互目標或對象的截止範圍。';
L['Controls when your character starts running. Expressed as a fraction of your total movement stick radius.'] = '控製你的角色何時開始奔跑。表示為你總移動摇杆半徑的一部分。';
L['Controls when your character transitions from strafing to facing your movement stick direction while in combat. Expressed in degrees, from looking straight forward.'] = '控製你的角色在戰斗中何時从橫移過渡到面向你的移動摇杆方向。以度數表示，从直視前方開始。';
L['Controls when your character transitions from strafing to facing your movement stick direction while in the air. Expressed in degrees, from looking straight forward.'] = '控製你的角色在空中時何時从橫移過渡到面向你的移動摇杆方向。以度數表示，从直視前方開始。';
L['Controls when your character transitions from strafing to facing your movement stick direction. Expressed in degrees, from looking straight forward.'] = '控製你的角色何時从橫移過渡到面向你的移動摇杆方向。以度數表示，从直視前方開始。';
L['Copy %s from %s:'] = '从 %s 複製 %s：';
L['Copy this element to a new name.'] = '將此元素複製為新名称。';
L['Correlation between stick position and pie selection.'] = '摇杆位置與饼形選擇之間的相關性。';
L['Create Binding Preset'] = '創建快捷鍵预設';
L['Critical, Low, Medium, High, Wired/Charging, or Unknown/Disconnected.'] = '緊急、低、中、高、有線/充电中或未知/已斷開连接。';
L['Crossbar: Minimal'] = '十字栏：精簡';
L['Crossbar: Triggers'] = '十字栏：扳機';
L['Crossbar: Triple'] = '十字栏：三重';
L['Crosshair'] = '准星';
L['Cursor Acceleration'] = '光標加速度';
L['Cursor acceleration for touchpad control.'] = '觸摸板控製的光標加速度。';
L['Cursor appears on demand, instead of in response to a panel showing up.'] = '光標按需出現，而不是響應面板出現。';
L['Cursor Center Position'] = '光標中心位置';
L['Cursor hides when you start moving, if free of obstacles.'] = '當你開始移動時，如果没有障礙物，光標會隐藏。';
L['Cursor Max Speed'] = '光標最大速度';
L['Cursor Move Threshold'] = '光標移動阈值';
L['Cursor Reticle Targeting'] = '光標准星目標選擇';
L['Cursor Speed'] = '光標速度';
L['Cursor speed for touchpad control.'] = '觸摸板控製的光標速度。';
L['Cursor Start Speed'] = '光標起始速度';
L['Custom color to use for the touchpad LED.'] = '用於觸摸板 LED 的自定義颜色。';
L['Cyan'] = '青色';
L['Deadzone for simple point-to-select rings.'] = '用於簡單點選環的死區。';
L['Deadzone to clear focus after intercepting stick input.'] = '在截获摇杆输入後清除焦點的死區。';
L['Decrease'] = '减少';
L['Decrease lightness'] = '减少亮度';
L['Decrease opacity'] = '减少不透明度';
L['Default to '] = '默認為 ';
L['Delay before reactivating interface cursor after leaving combat, in seconds.'] = '脱離戰斗後重新激活界面光標的延迟，以秒為單位。';
L['Delay before starting to adjust angle when camera control is idle, in seconds.'] = '摄像機控製空闲時開始調整角度的延迟，以秒為單位。';
L['Delay is doubled if you are dead.'] = '如果你死亡，延迟會加倍。';
L['Delay until a movement is repeated, when holding down a direction, in seconds.'] = '按住方向時移動重複之前的延迟，以秒為單位。';
L['Delay until the first movement is repeated, when holding down a direction, in seconds.'] = '按住方向時第一次移動重複之前的延迟，以秒為單位。';
L['Delete this element.'] = '删除此元素。';
L['Depth'] = '深度';
L['Depth of the divider.'] = '分隔符的深度。';
L['Detected %d out of 8 possible sensors.'] = '在 8 個可能的传感器中检测到 %d 個。';
L['Detected %d valid button(s).'] = '检测到 %d 個有效按鈕。';
L['Device Information'] = '設備信息';
L['Device Mappings'] = '設備映射';
L['Device Profiles'] = '設備配置文件';
L['Device Selection'] = '設備選擇';
L['Device Settings'] = '設備設置';
L['Diamond Grid'] = '钻石网格';
L['Dictionary Match Alphabet'] = '字典匹配字母表';
L['Dictionary Match Pattern'] = '字典匹配模式';
L['Direction for flyout buttons, such as portals, poisons, and pet utilities.'] = '彈出按鈕的方向，例如門戶、毒藥和宠物工具。';
L['Direction of the button cluster.'] = '按鈕集群的方向。';
L['Disable Drag and Drop'] = '禁用拖放';
L['Disable dragging and dropping abilities on action bars.'] = '禁用在動作條上拖放能力。';
L['Disable free-roaming mouse cursor when you jump.'] = '跳跃時禁用自由漫游鼠標光標。';
L['Disable free-roaming mouse cursor when you use your sticks.'] = '使用摇杆時禁用自由漫游鼠標光標。';
L['Disable Hotkey Rendering'] = '禁用快捷鍵渲染';
L['Disable if your mouse cursor is invisible.'] = '如果鼠標光標不可見，请禁用。';
L['Disable repeated cursor movements - each click will only move the cursor once.'] = '禁用重複光標移動 — 每次點擊只會移動光標一次。';
L['Disable Repeated Movement'] = '禁用重複移動';
L['Disable to use discrete legacy movement controls.'] = '禁用以使用離散的旧版移動控製。';
L['Disable Wrapping'] = '禁用環繞';
L['Disables customization to hotkeys on regular action bars.'] = '禁用常規動作條上的快捷鍵自定義。';
L['Disabling this may cause worse performance with many panels open.'] = '禁用此功能可能导致打開许多面板時性能下降。';
L['Disconnected'] = '已斷開连接';
L['Discord'] = 'Discord';
L['Display icon next to the power level for the current active gamepad.'] = '為當前活動手柄的电量旁邊顯示圖標。';
L['Display power level for the current active gamepad.'] = '顯示當前活動手柄的电量。';
L['Display power level status text for the current active gamepad.'] = '顯示當前活動手柄的电量狀態文本。';
L['Display the action bar grid when picking up a spell on the cursor.'] = '在光標上拾取法術時顯示動作條网格。';
L['Displays a briefing for newly acquired abilities.'] = '顯示新获得能力的簡介。';
L['Divider'] = '分隔符';
L['Do you want to load settings for %s?'] = '你要為 %s 加載設置吗？';
L['Does not affect actual ability to interact with the target, which may have a different range.'] = '不影響實際與目標互動的能力，該能力可能具有不同的範圍。';
L['Donate via PayPal'] = '通過 PayPal 捐款';
L['Double Tap Modifier'] = '雙擊修飾鍵';
L['Double Tap Timeframe'] = '雙擊時間範圍';
L['Duration after using gamepad and mouse at the same time before switching to just one or the other, in milliseconds.'] = '同時使用手柄和鼠標後切換到其中一個或另一個之前的持续時間，以毫秒為單位。';
L['Duration under which a tooltip is displayed for an acquired target or interactable, in milliseconds.'] = '已获取的目標或可交互物顯示提示框的持续時間，以毫秒為單位。';
L['Dynamic Pitch'] = '動態俯仰';
L['Dynamic will use the button set that does not conflict with your '] = '「動態」將使用不與你的 ';
L['E.g. '] = '例如 ';
L['Edit Binding'] = '编辑快捷鍵';
L['Edit Slot'] = '编辑插槽';
L['Emulate P1 '] = '模拟 P1 ';
L['Emulate P2 '] = '模拟 P2 ';
L['Emulate P3 '] = '模拟 P3 ';
L['Emulate P4 '] = '模拟 P4 ';
L['Emulate Pad 5'] = '模擬 Pad 5';
L['Emulate Pad 6'] = '模擬 Pad 6';
L['Emulate Pad Back'] = '模擬返回鍵';
L['Emulate Pad Forward'] = '模擬前進鍵';
L['Emulate Pad Social'] = '模擬社交鍵';
L['Emulate Pad System'] = '模擬系統鍵';
L['Enable all modifier states for the cluster, including unmapped modifiers.'] = '為集群啟用所有修飾鍵狀態，包括未映射的修飾鍵。';
L['Enable Animation'] = '啟用動畫';
L['Enable casting bar ownership.'] = '啟用施法栏所有權。';
L['Enable class bar ownership.'] = '啟用職業栏所有權。';
L['Enable Cooldown Numbers'] = '啟用冷却數字';
L['Enable custom mouse handling, automating cursor toggling and timeout while using left and right mouse button emulation.'] = '啟用自定義鼠標處理，在使用左右鼠標按鈕模拟時自動化光標切換和超時。';
L['Enable Group Loot'] = '啟用組隊拾取';
L['Enable interact key to interact with objects and creatures in the game world.'] = '啟用互動鍵以與游戏世界中的對象和生物互動。';
L['Enable interface cursor. Disable to use mouse-based interface interaction.'] = '啟用界面光標。禁用以使用基於鼠標的界面互動。';
L['Enable Lazy Loading'] = '啟用延遲加載';
L['Enable Mouse Handling'] = '啟用鼠標處理';
L['Enable Player Interact'] = '啟用玩家互動';
L['Enable Popups'] = '啟用彈出窗口';
L['Enable separate strafe angle threshold for when your character is in the air.'] = '為你的角色在空中時啟用單独的橫移角度阈值。';
L['Enable Strafe Angle (Jump)'] = '啟用橫移角度 (跳跃)';
L['Enable Tint'] = '啟用色調';
L['Enable touch tap to press touchpad buttons.'] = '啟用觸摸點擊以按下觸摸板按鈕。';
L['Enable Touchpad Cursor'] = '啟用觸摸板光標';
L['Enable Vehicle'] = '啟用載具';
L['Enable Watch Bars'] = '啟用监視條';
L['Enables a crosshair to reveal your hidden center cursor position at all times.'] = '啟用准星以始終顯示你隐藏的中央光標位置。';
L['Enables a radial on-screen keyboard that can be used to type messages.'] = '啟用一個可用於输入消息的徑向屏幕鍵盤。';
L['Enemy Soft Targeting'] = '敌方软目標選擇';
L['Equippable items of poor quality will not be sold while your character is below this level.'] = '當你的角色低於此等級時，質量差的可裝備物品將不會被出售。';
L['Erase'] = '擦除';
L['Exit the vehicle you are currently controlling.'] = '退出你當前控製的載具。';
L['Explicit only matches hard locked targets through using a targeting binding, while implicit matches targets you attack.'] = '顯式僅通過使用目標選擇快捷鍵匹配硬鎖定的目標，而隐式匹配你攻擊的目標。';
L['Export'] = '导出';
L['Export %s to a string:'] = '將 %s 导出為字符串：';
L['Export action page logic'] = '导出動作页面逻辑';
L['Export All'] = '全部导出';
L['Export all your custom presets to a string that can be shared with others.'] = '將你所有的自定義预設导出為可與他人共享的字符串。';
L['Export current options'] = '导出當前選項';
L['Export serialized settings for sharing or backup.'] = '导出序列化設置以共享或備份。';
L['Export this preset to a string that can be shared with others.'] = '將此预設导出為可與他人共享的字符串。';
L['Expressed in milliseconds. Pressing any combination of modifier and button will cancel the effect.'] = '以毫秒表示。按下任何修飾鍵和按鈕的組合將取消效果。';
L['Fade Buttons'] = '淡出按鈕';
L['Fade out the pet ring when not moused over.'] = '未鼠標悬停時淡出宠物環。';
L['Fade out the watch bars when not mousing over the toolbar.'] = '未鼠標悬停工具栏時淡出监視條。';
L['Fade Watch Bars'] = '淡出监視條';
L['Filter Condition'] = '過滤條件';
L['Filter condition to find raid cursor frames, as a boolean expression in Lua.'] = '用於查找團隊光標框架的過滤條件，作為 Lua 中的布尔表達式。';
L['Flavor'] = '风格';
L['Flyout Direction'] = '彈出方向';
L['FOAS Adjust Delay'] = 'FOAS 調整延迟';
L['FOAS Adjust Ease In'] = 'FOAS 調整淡入';
L['Follow On A Stick (FOAS)'] = 'Follow On A Stick (FOAS)';
L['Font Flags'] = '字體標誌';
L['Font flags of the counter text on buttons.'] = '按鈕上計數器文本的字體標誌。';
L['Font flags of the hotkey text on buttons.'] = '按鈕上快捷鍵文本的字體標誌。';
L['Font flags of the macro text on buttons.'] = '按鈕上宏文本的字體標誌。';
L['Font size of the counter text on buttons.'] = '按鈕上計數器文本的字體大小。';
L['Font size of the hotkey text on buttons.'] = '按鈕上快捷鍵文本的字體大小。';
L['Font size of the macro text on buttons.'] = '按鈕上宏文本的字體大小。';
L['Font size of the ring slice buttons.'] = '環切片按鈕的字體大小。';
L['Force Hard Target'] = '強製硬目標';
L['Frame level of the element.'] = '元素的框架級別。';
L['Frame Level Offset'] = '框架級別偏移';
L['Frame level offset of the hotkey prompt, relative to the unit frame.'] = '快捷鍵提示相對於單位框架的框架級別偏移。';
L['Frame strata of the element.'] = '元素的框架層級。';
L['Free Cursor Timein'] = '自由光標進入時間';
L['Frees your mouse cursor when used, if the cursor is currently center-fixed or hidden.'] = '使用時釋放你的鼠標光標，如果光標當前居中固定或隐藏。';
L['Friend Soft Targeting'] = '友方软目標選擇';
L['Full State Modifier'] = '全狀態修飾鍵';
L['Global color of the tint effect on the toolbar and dividers.'] = '工具栏和分隔符上色調效果的全局颜色。';
L['Global Scale'] = '全局缩放';
L['Global Visibility'] = '全局可見性';
L['Green'] = '綠色';
L['Grid'] = '网格';
L['Group buttons by modifier in a diamond layout.'] = '按修飾鍵以钻石布局對按鈕分組。';
L['Group buttons by modifier in a grid layout.'] = '按修飾鍵以网格布局對按鈕分組。';
L['Group buttons for left and right triggers, with modifier swapping.'] = '為左右扳機分組按鈕，带修飾鍵切換。';
L['Group buttons in a single crossbar layout, with modifier swapping.'] = '在單個十字栏布局中分組按鈕，带修飾鍵切換。';
L['Group buttons in three layouts, with modifier swapping.'] = '在三個布局中分組按鈕，带修飾鍵切換。';
L['Groups button combinations in circular clusters which switch between different actions when modifiers are used.'] = '將按鈕組合分組到圆形集群中，當使用修飾鍵時，集群在不同動作之間切換。';
L['Height of the artwork.'] = '美術的高度。';
L['Height of the cluster bar.'] = '集群條的高度。';
L['Height of the crosshair, in scaled pixel units.'] = '准星的高度，以缩放像素單位表示。';
L['Height of the group.'] = '組的高度。';
L['Hide Cursor on Jump'] = '跳跃時隐藏光標';
L['Hide Cursor On Movement'] = '移動時隐藏光標';
L['Hide Cursor on Stick Input'] = '摇杆输入時隐藏光標';
L['Hide Flyout Buttons'] = '隐藏彈出按鈕';
L['Hide Macro Text'] = '隐藏宏文本';
L['Hide the class bar.'] = '隐藏職業栏。';
L['Hide the macro text on buttons.'] = '隐藏按鈕上的宏文本。';
L['Higher is slower.'] = '值越高越慢。';
L['Higher values appear on top of lower values. Valid range 0-10000.'] = '较高的值顯示在较低值之上。有效範圍 0-10000。';
L['Highlight Color'] = '高亮颜色';
L['Horizontal Offset'] = '水平偏移';
L['Horizontal offset from anchor point.'] = '锚點的水平偏移。';
L['Horizontal offset of the counter text on buttons.'] = '按鈕上計數器文本的水平偏移。';
L['Horizontal offset of the hotkey icon on group buttons.'] = '組按鈕上快捷鍵圖標的水平偏移。';
L['Horizontal offset of the hotkey prompt position, in pixels.'] = '快捷鍵提示位置的水平偏移，以像素為單位。';
L['Horizontal offset of the hotkey text on buttons.'] = '按鈕上快捷鍵文本的水平偏移。';
L['Horizontal offset of the macro text on buttons.'] = '按鈕上宏文本的水平偏移。';
L['Horizontal Padding'] = '水平內邊距';
L['Hotkey Anchor'] = '快捷鍵锚點';
L['Hotkey Offset X'] = '快捷鍵 X 偏移';
L['Hotkey Offset Y'] = '快捷鍵 Y 偏移';
L['Hotkey prompts appear on applicable name plates.'] = '快捷鍵提示出現在适用的姓名板上。';
L['Hotkey prompts linger on unit frames after targeting.'] = '目標選擇後快捷鍵提示停留在單位框架上。';
L['Hotkey Relative Anchor'] = '快捷鍵相對锚點';
L['Hotkey Size'] = '快捷鍵大小';
L['Hotkeys activate their target immediately.'] = '快捷鍵立即激活其目標。';
L['Hotkeys always target the same unit.'] = '快捷鍵始終瞄准同一單位。';
L['Hotkeys control your focus target instead of your current target.'] = '快捷鍵控製你的焦點目標而不是當前目標。';
L['Hotkeys use '] = '快捷鍵使用 ';
L['How long the cursor should take to transition from one node to another.'] = '光標从一個節點過渡到另一個節點所需的時間。';
L['How to clear focus after intercepting stick input.'] = '如何在截获摇杆输入後清除焦點。';
L['Import serialized preset(s) from an external source.'] = '从外部源导入序列化预設。';
L['Import serialized preset(s):'] = '导入序列化预設：';
L['Import serialized settings from an external source.'] = '从外部源导入序列化設置。';
L['Inactive Opacity'] = '非活動不透明度';
L['Include the current action page logic in the preset data.'] = '在预設數據中包含當前動作页面逻辑。';
L['Include the current options from the %s tab in the preset data.'] = '在预設數據中包含 %s 選項卡的當前選項。';
L['Increase'] = '增加';
L['Increase lightness'] = '增加亮度';
L['Increase opacity'] = '增加不透明度';
L['Insert Suggestion'] = '插入建議';
L['Intensity'] = '強度';
L['Intensity of the gradient.'] = '漸變的強度。';
L['Interface Cursor'] = '界面光標';
L['Interference'] = '干扰';
L['Inverted'] = '反轉';
L['Join Discord'] = '加入 Discord';
L['Keeps your character centered to reduce motion sickness.'] = '保持你的角色居中以减少晕動症。';
L['Key %d'] = '鍵 %d';
L['Keyboard button to emulate the back button.'] = '用於模擬返回按鈕的鍵盤按鍵。';
L['Keyboard button to emulate the forward button.'] = '用於模擬前進按鈕的鍵盤按鍵。';
L['Keyboard button to emulate the pad 5 button.'] = '用於模擬 Pad 5 按鈕的鍵盤按鍵。';
L['Keyboard button to emulate the pad 6 button.'] = '用於模擬 Pad 6 按鈕的鍵盤按鍵。';
L['Keyboard button to emulate the social button.'] = '用於模擬社交按鈕的鍵盤按鍵。';
L['Keyboard button to emulate the system button.'] = '用於模擬系統按鈕的鍵盤按鍵。';
L['Keyboard'] = '鍵盤';
L['Keyboard button to emulate the paddle 1 button.'] = '用於模拟拨片 1 按鈕的鍵盤按鍵。';
L['Keyboard button to emulate the paddle 2 button.'] = '用於模拟拨片 2 按鈕的鍵盤按鍵。';
L['Keyboard button to emulate the paddle 3 button.'] = '用於模拟拨片 3 按鈕的鍵盤按鍵。';
L['Keyboard button to emulate the paddle 4 button.'] = '用於模拟拨片 4 按鈕的鍵盤按鍵。';
L['Keyboard Layout Editor'] = '鍵盤布局编辑器';
L['Larger value for easier taps.'] = '较大的值便於點擊。';
L['Layout'] = '布局';
L['Lazy loading has been disabled to activate the raid cursor.'] = '延遲加載已禁用，以激活團隊光標。';
L['Lazy loading has been disabled to activate the target ring.'] = '延遲加載已禁用，以激活目標環。';
L['Lazy loading has been disabled to activate unit hotkeys.'] = '延遲加載已禁用，以激活單位快捷鍵。';
L['LED Color Type'] = 'LED 颜色類型';
L['LED Custom Color'] = 'LED 自定義颜色';
L['Left mouse button emulation toggles center-fixed mode instead of free-roaming mode. Right mouse button emulation toggles free-roaming mode instead of center-fixed mode.'] = '左鼠標按鈕模拟切換居中固定模式而不是自由漫游模式。右鼠標按鈕模拟切換自由漫游模式而不是居中固定模式。';
L['Load'] = '加載';
L['Loaded binding preset %s.'] = '已加載快捷鍵預設 %s。';
L['Loadout'] = '配置';
L['Lock Automatic Tooltip'] = '鎖定自動提示框';
L['Looks like a regular action bar, but shows the button combination rather than the action slot.'] = '看起來像常規動作條，但顯示按鈕組合而不是動作槽。';
L['Lua pattern to match words for dictionary lookups.'] = '用於字典查詢匹配單詞的 Lua 模式。';
L['Macro condition to automatically load a binding preset by name when the condition applies.'] = '當條件滿足時，按名稱自動加載快捷鍵預設的宏條件。';
L['Macro condition to enable the click override button. The default condition clicks right mouse button when there is no enemy target.'] = '啟用點擊覆盖按鈕的宏條件。默認條件是在没有敌方目標時點擊右鼠標按鈕。';
L['Macro condition to evaluate action bar page.'] = '用於评估動作條页面的宏條件。';
L['Macro condition to override the strafe angle threshold for combat.'] = '用於覆盖戰斗橫移角度阈值的宏條件。';
L['Macro condition to override the strafe angle threshold for travel.'] = '用於覆盖旅行橫移角度阈值的宏條件。';
L['Macro Text'] = '宏文本';
L['Main Button Border Style'] = '主按鈕邊框樣式';
L['Maintain offset relative to scale.'] = '保持相對於缩放的偏移。';
L['Make sure your choice does not conflict with your bindings.'] = '確保你的選擇不與你的快捷鍵冲突。';
L['Make this preset the default layout for all new characters.'] = '將此预設設為所有新角色的默認布局。';
L['Match appropriate soft target to locked target.'] = '將适當的软目標與鎖定目標匹配。';
L['Max Pitch'] = '最大俯仰';
L['Max time for a touch to register a tap/click, in milliseconds.'] = '觸摸注册為點擊/單擊的最長時間，以毫秒為單位。';
L['Max Yaw'] = '最大偏航';
L['Maximum Pitch adjust for the camera "look" feature.'] = '摄像機「查看」功能的最大俯仰調整。';
L['Maximum Yaw adjust for the camera "look" feature.'] = '摄像機「查看」功能的最大偏航調整。';
L['Menu buttons to display on the toolbar.'] = '要在工具栏上顯示的菜單按鈕。';
L['Micro Menu'] = '微型菜單';
L['Minimal Interact Nameplate Tooltip'] = '最小化互動姓名板提示框';
L['Modifications'] = '修改';
L['Modifier'] = '修飾鍵';
L['Modifier 1: Shift'] = '修飾鍵 1：Shift';
L['Modifier 2: Ctrl'] = '修飾鍵 2：Ctrl';
L['Modifier 3: Alt'] = '修飾鍵 3：Alt';
L['Modifier Tap Window'] = '修飾鍵點擊窗口';
L['Modifiers'] = '修飾鍵';
L['Modifiers should be in descending order. M2M1, for example, is the Ctrl and Shift modifiers held at the same time.'] = '修飾鍵應按降序排列。例如，M2M1 是同時按下的 Ctrl 和 Shift 修飾鍵。';
L['Move Left'] = '向左移動';
L['Move one of the sticks.'] = '移動其中一個摇杆。';
L['Move Right'] = '向右移動';
L['Move the frame with the sticks or the mouse. Confirm to save, cancel to restore.'] = '使用搖桿或滑鼠移動框體。確認以儲存，取消以恢復。';
L['Movement Deadzone'] = '移動死區';
L['Movement is analog, translated from your movement stick angle.'] = '移動是模拟的，从你的移動摇杆角度轉換。';
L['Movement X Axis'] = '移動 X 轴';
L['Movement Y Axis'] = '移動 Y 轴';
L['Needs to be long enough to press and release the button.'] = '需要足够長以按下并釋放按鈕。';
L['Nested Rings'] = '嵌套環';
L['Next Word'] = '下一個單詞';
L['No axis input detected yet.'] = '尚未检测到轴输入。';
L['No binding preset named %s exists.'] = '不存在名為 %s 的快捷鍵預設。';
L['No button input detected yet.'] = '尚未检测到按鈕输入。';
L['No buttons were detected during the test.'] = '测試期間未检测到按鈕。';
L['No sensors were detected.'] = '未检测到传感器。';
L['Normal background color of pie slices.'] = '饼圖扇區的正常背景颜色。';
L['Normal Color'] = '正常颜色';
L['Nudge Modifier'] = '推動修飾鍵';
L['Number of buttons in the page.'] = '页面中的按鈕數。';
L['Number of buttons per row or column.'] = '每行或每列的按鈕數。';
L['Offset'] = '偏移';
L['Offset of pointer arrow, from the selected node center, in pixels.'] = '指针箭頭相對於所選節點中心的偏移，以像素為單位。';
L['Offset X'] = 'X 偏移';
L['Offset Y'] = 'Y 偏移';
L['Offsets the camera horizontally from your character, for a more cinematic view.'] = '將摄像機水平偏移於你的角色，以获得更具电影感的視角。';
L['Only recommended for super users.'] = '僅建議超級用戶使用。';
L['Only use taps for cursor clicks, do not use tap presses.'] = '僅將點擊用於光標點擊，不要使用點擊按下。';
L['Opacity is expressed in percentage, where 100 is fully visible and 0 is fully transparent. Values outside of the 0-100 range will be clamped.'] = '不透明度以百分比表示，其中 100 完全可見，0 完全透明。0-100 範圍外的值將被钳製。';
L['Opacity of inactive hotkey prompts on unit frames after targeting.'] = '目標選擇後單位框架上非活動快捷鍵提示的不透明度。';
L['Open Designer'] = '打開設計器';
L['Open Main Config'] = '打開主配置';
L['Open the configuration menu for the action bar.'] = '打開動作條的配置菜單。';
L['Open the main configuration window.'] = '打開主配置窗口。';
L['Open the main edit mode window.'] = '打開主编辑模式窗口。';
L['Open the unit menu for the target unit.'] = '打開目標單位的單位菜單。';
L['Open unit menu when interacting with other players.'] = '與其他玩家互動時打開單位菜單。';
L['Optimize Algorithm'] = '優化算法';
L['or'] = '或';
L['Orientation of the page.'] = '页面方向。';
L['Orthodox'] = '正統';
L['Out of Mana Color'] = '法力耗尽颜色';
L['Out of Range Color'] = '超出範圍颜色';
L['Outcome'] = '結果';
L['Over Shoulder'] = '肩部上方';
L['Override'] = '覆盖';
L['Override Class File'] = '覆盖職業文件';
L['Override class theme for interface styling.'] = '覆盖職業主題以進行界面樣式設置。';
L['Padding between buttons horizontally.'] = '按鈕之間的水平內邊距。';
L['Padding between buttons vertically.'] = '按鈕之間的垂直內邊距。';
L['Page'] = '页面';
L['Page Condition'] = '页面條件';
L['Page Hotkeys'] = '页面快捷鍵';
L['Page Response'] = '页面響應';
L['Page |cFF00FFFF%s|r'] = '页面 |cFF00FFFF%s|r';
L['Patreon'] = 'Patreon';
L['PayPal'] = 'PayPal';
L['Performs an action and closes the menu.'] = '執行操作并關閉菜單。';
L['Performs an action without closing the menu.'] = '執行操作而不關閉菜單。';
L['Pet Ring'] = '宠物環';
L['Pet Ring Position'] = '寵物環位置';
L['Pet Ring Stick'] = '寵物環搖桿';
L['Pick up'] = '拾取';
L['Pickup'] = '拾取';
L['Pitch Axis'] = '俯仰轴';
L['Pitch-only deadzone for camera, applied before the 2D deadzone.'] = '摄像機的僅俯仰死區，在 2D 死區之前應用。';
L['Pitches the camera upwards as you zoom out.'] = '缩小時向上倾斜摄像機。';
L['Place in slot'] = '放入插槽';
L['Place on action bar'] = '放置在動作條上';
L['Play a sound when the pointer arrow reaches its destination.'] = '當指针箭頭到達目的地時播放聲音。';
L['Please provide a unique name for a new %s in %s:'] = '请為 %s 中的新 %s 提供一個唯一的名称：';
L['Plural Button'] = '複數按鈕';
L['Pointer arrow rotates in the direction of travel, and portraits scale up and down on movement.'] = '指针箭頭朝行進方向旋轉，肖像在移動時放大和缩小。';
L['Pointer arrow rotates in the direction of travel.'] = '指针箭頭朝行進方向旋轉。';
L['Pointer Offset'] = '指针偏移';
L['Pointer Size'] = '指针大小';
L['Position'] = '位置';
L['Position of the artwork.'] = '美術的位置。';
L['Position of the button cluster.'] = '按鈕集群的位置。';
L['Position of the button.'] = '按鈕的位置。';
L['Position of the class bar.'] = '職業栏的位置。';
L['Position of the cluster bar.'] = '集群條的位置。';
L['Position of the divider.'] = '分隔符的位置。';
L['Position of the element.'] = '元素的位置。';
L['Position of the group.'] = '組的位置。';
L['Position of the page.'] = '页面的位置。';
L['Position of the pet ring.'] = '宠物環的位置。';
L['Position of the toolbar.'] = '工具栏的位置。';
L['Power Level'] = '电池电量';
L['Preferred size of radial menus, in pixels.'] = '徑向菜單的首選大小，以像素為單位。';
L['Preset Load Condition'] = '預設加載條件';
L['Presets'] = '预設';
L['Press and Hold'] = '按住';
L['Press your gamepad buttons to test them.'] = '按下你的手柄按鈕以测試它們。';
L['Prevent the cursor from wrapping when navigating.'] = '防止光標在导航時環繞。';
L['Previous Word'] = '上一個單詞';
L['Primary accept button, to use or confirm a quick menu action.'] = '主接受按鈕，用於使用或確認快捷菜單操作。';
L['Primary Button'] = '主按鈕';
L['Primary Stick'] = '主摇杆';
L['Prioritize raid cursor bindings over other override bindings.'] = '優先考虑團隊光標快捷鍵而非其他覆盖快捷鍵。';
L['Priority Override'] = '優先級覆盖';
L['Purple'] = '紫色';
L['Quick Menu'] = '快捷菜單';
L['Radial Menus'] = '徑向菜單';
L['Raid Cursor'] = '團隊光標';
L['Re-apply config for the active device.'] = '為活動設備重新應用配置。';
L['Reactivation Delay'] = '重新激活延迟';
L['Realm'] = '伺服器';
L['Recharge'] = '充能';
L['Recommended as first choice modifier.'] = '推荐作為第一選擇修飾鍵。';
L['Recommended as second choice modifier.'] = '推荐作為第二選擇修飾鍵。';
L['Reduces unexpected camera movement to reduce motion sickness.'] = '减少意外的摄像機移動以减少晕動症。';
L['Regenerate Dictionary'] = '重新生成字典';
L['Regular'] = '常規';
L['Relative Anchor'] = '相對锚點';
L['Relative anchor point of the counter text on buttons.'] = '按鈕上計數器文本的相對锚點。';
L['Relative anchor point of the hotkey icon on group buttons.'] = '組按鈕上快捷鍵圖標的相對锚點。';
L['Relative anchor point of the hotkey text on buttons.'] = '按鈕上快捷鍵文本的相對锚點。';
L['Relative anchor point of the macro text on buttons.'] = '按鈕上宏文本的相對锚點。';
L['Relative Rescale'] = '相對重新缩放';
L['Reload'] = '重新加載';
L['Remove all saved settings and bindings, disable addon, and reload interface.'] = '移除所有已保存的設置和快捷鍵，禁用插件并重新加載界面。';
L['Remove all saved settings and reload interface.'] = '移除所有已保存的設置并重新加載界面。';
L['Remove Button'] = '移除按鈕';
L['Remove from %s'] = '从 %s 移除';
L['Remove this set. This action cannot be undone.'] = '移除此集合。此操作无法撤消。';
L['Removes the tooltip background for a minimalistic look.'] = '移除提示框背景以获得簡約外觀。';
L['Repeated Movement Delay'] = '重複移動延迟';
L['Repeated Movement First Delay'] = '重複移動首次延迟';
L['Replaces the default loot frame with a custom version optimized for controller navigation.'] = '用针對控製器导航優化的自定義版本替換默認拾取框架。';
L['Request early landing from the taxi you are currently riding.'] = '请求从你當前乘坐的出租車提前降落。';
L['Requires /reload to fully unhook when disabled.'] = '禁用時需要 /reload 才能完全解除。';
L['Requires a touchpad with LED support.'] = '需要支持 LED 的觸摸板。';
L['Requires reload.'] = '需要重新加載。';
L['Requires Settings > Hide Cursor on Stick Input set to None.'] = '需要將設置 > 「摇杆输入時隐藏光標」設為「无」。';
L['Requires Toggle Interface Cursor binding to use the cursor.'] = '需要「切換界面光標」快捷鍵才能使用光標。';
L['Reset all mapping configurations and reload. (will not affect bindings)'] = '重置所有映射配置并重新加載。(不會影響快捷鍵)';
L['Response to condition for custom processing.'] = '條件響應，用於自定義處理。';
L['Reticle targeting means anything you place on the ground.'] = '准星目標選擇意味着你放在地上的任何东西。';
L['Reticle targeting uses free cursor instead of staying center-fixed.'] = '准星目標選擇使用自由光標而不是保持中心固定。';
L['Return Button'] = '返回按鈕';
L['Returns to the previous menu.'] = '返回上一菜單。';
L['Reverse Mouse Handling'] = '反轉鼠標處理';
L['Reverse Order'] = '反轉顺序';
L['Reverse the order of the buttons.'] = '反轉按鈕的顺序。';
L['Ring Manager'] = '環管理器';
L['Ring Scale'] = '環缩放';
L['Ring Size'] = '環大小';
L['Rings'] = '環';
L['Rings (Account)'] = '環（賬戶）';
L['Rings (Character)'] = '環（角色）';
L['Rotation'] = '旋轉';
L['Rotation of the divider.'] = '分隔符的旋轉。';
L['Run / Walk Threshold'] = '奔跑/行走阈值';
L['Run Tests'] = '运行测試';
L['Save as default'] = '保存為默認';
L['Save preset from %s:'] = '从 %s 保存预設：';
L['Save your current loadout to the preset list.'] = '將你當前的配置保存到预設列表。';
L['Scale of all radial menus, relative to UI scale.'] = '所有徑向菜單的缩放，相對於 UI 缩放。';
L['Scale of most ConsolePort frames, relative to UI scale.'] = '大多數 ConsolePort 框架的缩放，相對於 UI 缩放。';
L['Scale of the cursor.'] = '光標的缩放。';
L['Scale of the game menu and radial companion.'] = '游戏菜單和徑向伴侣的缩放。';
L['Scale of the keyboard.'] = '鍵盤的缩放。';
L['Scale of the pet ring.'] = '宠物環的缩放。';
L['Screen position of the ring.'] = '環形選單在螢幕上的位置。';
L['Secondary accept button, to use or confirm a quick menu action.'] = '次要接受按鈕，用於使用或確認快捷菜單操作。';
L['Select a device from the list to continue.'] = '从列表中選擇一個設備以继续。';
L['Select a slot to bind %s and place this spell.'] = '選擇一個插槽以绑定 %s 并放置此法術。';
L['Select a slot to place this spell.'] = '選擇一個插槽以放置此法術。';
L['Select the device you want to configure.'] = '選擇你要配置的設備。';
L['Select the device you want to use.'] = '選擇你要使用的設備。';
L['Selecting an item on a ring will stick until another item is chosen.'] = '在環上選擇項目將保持粘性，直到選擇另一個項目。';
L['Sensors'] = '传感器';
L['Set %d |cFF757575(%s)|r'] = '集合 %d |cFF757575(%s)|r';
L['Set binding'] = '設置快捷鍵';
L['Sets if range should be a hard cutoff, even for something you can interact with.'] = '設置範圍是否應為硬截止，即使對於你可以與之交互的东西。';
L['Shift-click to Edit Binding'] = '按住 Shift 并點擊以编辑快捷鍵';
L['Shift-right-click to Clear Binding'] = '按住 Shift 并右鍵點擊以清除快捷鍵';
L['Show a color tint on the toolbar.'] = '在工具栏上顯示色調。';
L['Show Ability Briefings'] = '顯示能力簡介';
L['Show Action Bar Grid on Spell Pickup'] = '拾取法術時顯示動作條网格';
L['Show active buffs in the quick menu.'] = '在快捷菜單中顯示活動增益。';
L['Show active debuffs in the quick menu.'] = '在快捷菜單中顯示活動减益。';
L['Show All Action Bars'] = '顯示所有動作條';
L['Show all enabled combinations in the cluster at all times.'] = '始終在集群中顯示所有啟用的組合。';
L['Show bonus bar configuration for characters without stances.'] = '為没有姿態的角色顯示奖励條配置。';
L['Show Centered Cursor Tooltip'] = '顯示居中光標提示框';
L['Show connected devices.'] = '顯示已连接的設備。';
L['Show Default Button'] = '顯示默認按鈕';
L['Show Enemy Nameplate'] = '顯示敌方姓名板';
L['Show Enemy Target Icon'] = '顯示敌方目標圖標';
L['Show Enemy Tooltip'] = '顯示敌方提示框';
L['Show Flyout Buttons'] = '顯示彈出按鈕';
L['Show Flyouts'] = '顯示彈出菜單';
L['Show Friendly Nameplate'] = '顯示友方姓名板';
L['Show Friendly Target Icon'] = '顯示友方目標圖標';
L['Show Friendly Tooltip'] = '顯示友方提示框';
L['Show Gauge'] = '顯示仪表';
L['Show group loot rolls in the quick menu, allowing you to roll on items using gamepad buttons while in combat.'] = '在快捷菜單中顯示組隊拾取掷骰，允许你在戰斗中使用手柄按鈕對物品掷骰。';
L['Show help for command(s).'] = '顯示命令的帮助。';
L['Show Hotkeys'] = '顯示快捷鍵';
L['Show icon above the current enemy soft target.'] = '在當前敌方软目標上方顯示圖標。';
L['Show icon above the current friendly soft target.'] = '在當前友方软目標上方顯示圖標。';
L['Show icon above the current interactable object.'] = '在當前可交互對象上方顯示圖標。';
L['Show icon above the current interactable target.'] = '在當前可交互目標上方顯示圖標。';
L['Show interact binding hint on interactables.'] = '在可交互物上顯示互動快捷鍵提示。';
L['Show Interact Hint'] = '顯示互動提示';
L['Show interact tooltip on nameplates, when applicable.'] = '在适用時在姓名板上顯示互動提示框。';
L['Show item type in the quick menu.'] = '在快捷菜單中顯示物品類型。';
L['Show Main Icons'] = '顯示主圖標';
L['Show Modifier Icons'] = '顯示修飾鍵圖標';
L['Show numerical cooldown text on buttons.'] = '在按鈕上顯示數字冷却時間文本。';
L['Show Object Icon'] = '顯示對象圖標';
L['Show on Name Plates'] = '顯示在姓名板上';
L['Show pet action bar in the quick menu.'] = '在快捷菜單中顯示宠物動作條。';
L['Show ping commands in the quick menu.'] = '在快捷菜單中顯示 ping 命令。';
L['Show Portrait'] = '顯示肖像';
L['Show portrait for the current unit, with health percentage and applicable spell casts.'] = '為當前單位顯示肖像，附带生命值百分比和适用的法術施放。';
L['Show Status Text'] = '顯示狀態文本';
L['Show Target Icon'] = '顯示目標圖標';
L['Show the default mouse action button.'] = '顯示默認鼠標動作按鈕。';
L['Show the empty buttons in the page.'] = '在页面中顯示空按鈕。';
L['Show the flyout of small buttons for the button cluster.'] = '為按鈕集群顯示小按鈕彈出菜單。';
L['Show the hotkeys on the buttons.'] = '在按鈕上顯示快捷鍵。';
L['Show the icons for main buttons.'] = '顯示主按鈕的圖標。';
L['Show the icons for modifier buttons.'] = '顯示修飾鍵按鈕的圖標。';
L['Show the pet power and health status.'] = '顯示宠物的力量和生命值狀態。';
L['Show the pet ring when in a vehicle.'] = '在載具中時顯示宠物環。';
L['Show the watch bars at the bottom of the toolbar.'] = '在工具栏底部顯示监視條。';
L['Show Tooltip'] = '顯示提示框';
L['Show tooltip for enemy target.'] = '顯示敌方目標的提示框。';
L['Show tooltip for friendly target.'] = '顯示友方目標的提示框。';
L['Show tooltip for interactables.'] = '顯示可交互物的提示框。';
L['Show tooltip for mouseover targets when cursor is centered.'] = '光標居中時顯示鼠標悬停目標的提示框。';
L['Show tooltips on buttons when moused over.'] = '鼠標悬停時在按鈕上顯示提示框。';
L['Show Type Icon'] = '顯示類型圖標';
L['Size of pointer arrow, in pixels.'] = '指针箭頭的大小，以像素為單位。';
L['Size of the button cluster.'] = '按鈕集群的大小。';
L['Size of the hotkey icon on group buttons.'] = '組按鈕上快捷鍵圖標的大小。';
L['Size of unit hotkeys, in pixels.'] = '單位快捷鍵的大小，以像素為單位。';
L['Space'] = '空格';
L['Speed of cursor when it starts moving.'] = '光標開始移動時的速度。';
L['Split stack'] = '拆分堆叠';
L['Start moving the configuration window.'] = '開始移動配置窗口。';
L['Starting point of the page.'] = '页面的起始點。';
L['Status Bar'] = '狀態栏';
L['Stick to use for main radial actions.'] = '用於主要徑向操作的摇杆。';
L['Stick to use for the pet ring. Default follows the radial menu primary stick.'] = '寵物環使用的搖桿。預設跟隨徑向選單的主搖桿。';
L['Stick to use for this ring. Default follows the radial menu primary stick.'] = '此環形選單使用的搖桿。預設跟隨徑向選單的主搖桿。';
L['Sticky Color'] = '粘性颜色';
L['Sticky Selection'] = '粘性選擇';
L['Strafe Angle (Combat)'] = '橫移角度 (戰斗)';
L['Strafe Angle (Jump)'] = '橫移角度 (跳跃)';
L['Strafe Angle (Travel)'] = '橫移角度 (旅行)';
L['Strafe Angle Macro Condition (Combat)'] = '橫移角度宏條件 (戰斗)';
L['Strafe Angle Macro Condition (Travel)'] = '橫移角度宏條件 (旅行)';
L['Strata'] = '層級';
L['Stride'] = '步幅';
L['Style of the border around main buttons.'] = '主按鈕周圍的邊框樣式。';
L['Support on Patreon'] = '在 Patreon 上支持';
L['Swap to a specified action bar layout.'] = '切換到指定的動作條布局。';
L['Swipe Color'] = '扫掠颜色';
L['Switch Button'] = '切換按鈕';
L['Switches between the main menu and the radial companion.'] = '在主菜單和徑向伴侣之間切換。';
L['Synchronize Bindings'] = '同步快捷鍵';
L['Synchronize Config'] = '同步配置';
L['Take ownership of, and move the micro menu buttons to the toolbar.'] = '接管并將微型菜單按鈕移動到工具栏。';
L['Takes the format of...\n|cFF3FC7EB[condition] Preset Name; nil|r\n\nAuto-saved presets are named "Character (Specialization) Realm", using class instead of specialization on Classic.\n\nThe preset loads outside of combat when the condition applies. Character presets take precedence over device presets.'] = [[格式為...
|cFF3FC7EB[條件] 預設名稱; nil|r

自動保存的預設名為"角色 (專精) 伺服器"，經典版使用職業代替專精。

條件滿足時會在脫離戰鬥後加載預設。角色預設優先於設備預設。]];
L['Taps for cursor clicks are right clicks instead of left.'] = '光標點擊的點擊是右鍵點擊而不是左鍵。';
L['Target enemies automatically by looking at them.'] = '通過查看自動選擇敌人。';
L['Target friends automatically by looking at them.'] = '通過查看自動選擇朋友。';
L['Target Match Lock'] = '目標匹配鎖定';
L['Target Range'] = '目標範圍';
L['Target Range Hard Cutoff'] = '目標範圍硬截止';
L['Target Ring'] = '目標環';
L['Targeting Mode'] = '目標選擇模式';
L['Test Device'] = '测試設備';
L['The analog input for forward/back movement.'] = '前進/後退移動的模拟输入。';
L['The analog input for left/right Camera Yaw "look" feature.'] = '左/右摄像機偏航「查看」功能的模拟输入。';
L['The analog input for left/right Camera Yaw.'] = '左/右摄像機偏航的模拟输入。';
L['The analog input for left/right movement.'] = '左/右移動的模拟输入。';
L['The analog input for up/down Camera Pitch "look" feature.'] = '上/下摄像機俯仰「查看」功能的模拟输入。';
L['The analog input for up/down Camera Pitch.'] = '上/下摄像機俯仰的模拟输入。';
L['The configuration is accessible by the chat command %s or from the game menu.'] = '可以通過聊天命令 %s 或从游戏菜單访問配置。';
L['The modifier can be used to nudge the cursor position with the directional pad.'] = '修飾鍵可用於通過方向鍵推動光標位置。';
L['The modifier can be used to scroll together with the directional pad.'] = '修飾鍵可與方向鍵一起用於滚動。';
L['The quick menu binding can be used to close the menu as well.'] = '快捷菜單快捷鍵也可用於關閉菜單。';
L['The time it takes to transition from idle camera control to auto-adjustment (FOAS).'] = '从空闲摄像機控製過渡到自動調整 (FOAS) 所需的時間。';
L['Thickness'] = '厚度';
L['Thickness in scaled pixel units.'] = '厚度，以缩放像素單位表示。';
L['Thickness of the divider.'] = '分隔符的厚度。';
L['This button is necessary to use or sell an item directly from your bags.'] = '此按鈕是直接从你的背包使用或出售物品所必需的。';
L['This feature is only available in Classic.'] = '此功能僅在 Classic 中可用。';
L['This only affects gamepad bindings.'] = '這只影響手柄快捷鍵。';
L['This will not affect your bindings, interface settings or system-wide settings.'] = '這不會影響你的快捷鍵、界面設置或系統範圍的設置。';
L['This will not work with Xbox controllers connected via bluetooth. The Xbox Adapter is required.'] = '這不适用於通過藍牙连接的 Xbox 控製器。需要 Xbox 适配器。';
L['Time in milliseconds for the opacity to change from one state to another.'] = '不透明度从一種狀態變為另一種狀態的時間，以毫秒為單位。';
L['Time in seconds to automatically hide centered cursor.'] = '自動隐藏居中光標的時間，以秒為單位。';
L['Time in seconds to enable free cursor.'] = '啟用自由光標的時間，以秒為單位。';
L['Time to clear focus after intercepting stick input, in seconds.'] = '截获摇杆输入後清除焦點的時間，以秒為單位。';
L['Timeframe to catch a binding in the configuration, in seconds.'] = '在配置中捕获快捷鍵的時間範圍，以秒為單位。';
L['Timeframe to toggle the mouse cursor when double-tapping a selected modifier.'] = '雙擊選定修飾鍵時切換鼠標光標的時間範圍。';
L['Timeout clears focus after a set time, deadzone clears focus when stick input is neutral.'] = '超時在設定的時間後清除焦點，死區在摇杆输入為中性時清除焦點。';
L['Tint Color'] = '色調颜色';
L['Toggle visibility of all modifier flyouts for cluster action bars.'] = '切換集群動作條所有修飾鍵彈出菜單的可見性。';
L['Toggle visibility of all modifier flyouts.'] = '切換所有修飾鍵彈出菜單的可見性。';
L['Toolbar'] = '工具栏';
L['Tooltip'] = '提示框';
L['Top speed of cursor movement.'] = '光標移動的最高速度。';
L['Touch Tap Buttons'] = '觸摸點擊按鈕';
L['Touch Tap Exclusive Click'] = '觸摸點擊独占點擊';
L['Touch Tap Max Time'] = '觸摸點擊最大時間';
L['Touch Tap Right Click'] = '觸摸點擊右鍵';
L['Touchpad'] = '觸摸板';
L['Transition'] = '過渡';
L['Transition time for opacity changes.'] = '不透明度變化的過渡時間。';
L['Travel Time'] = '行進時間';
L['Trigger button actions on press instead of release.'] = '在按下而不是釋放時觸发按鈕操作。';
L['Triggers'] = '扳機';
L['Turn Character With Camera'] = '用摄像機轉動角色';
L['Turn your character facing when you turn your camera angle.'] = '當你轉動摄像機角度時，轉動你的角色面向方向。';
L['Type of LED color to use for the touchpad.'] = '用於觸摸板的 LED 颜色類型。';
L['Types are PlayStation, Xbox, or Generic.'] = '類型為 PlayStation、Xbox 或通用。';
L['Unit Hotkeys'] = '單位快捷鍵';
L['Unit Pool'] = '單位池';
L['Units to watch, as lists of unit tokens selected by macro conditions. Use [] for the unconditional fallback.'] = '要監視的單位，以巨集條件選擇的單位標記列表形式。使用 [] 作為無條件回退。';
L['Unknown device selected.'] = '選擇了未知設備。';
L['Unlimited Navigation'] = '无限导航';
L['Unmapped keyboard key(s) detected:'] = '检测到未映射的鍵盤按鍵：';
L['Use a custom set of buttons for the game menu, otherwise the button set will be dynamically determined.'] = '為游戏菜單使用自定義按鈕集，否則按鈕集將動態確定。';
L['Use a shoulder button combined with crosshair for smooth and precise interactions. The click is performed at crosshair or cursor location.'] = '使用肩部按鈕結合准星實現平滑精確的互動。點擊在准星或光標位置執行。';
L['Use a targeting binding to turn a soft target into a hard target.'] = '使用目標選擇快捷鍵將软目標轉換為硬目標。';
L['Use character specific addon settings for this character.'] = '為此角色使用角色特定的插件設置。';
L['Use Custom Button Set'] = '使用自定義按鈕集';
L['Use Custom Loot Frame'] = '使用自定義拾取框架';
L['Use Default Hotkey Icons'] = '使用默認快捷鍵圖標';
L['Use Focus Mode'] = '使用焦點模式';
L['Use global game tooltip for loot information, allowing other addons to add information to lootable items.'] = '為拾取信息使用全局游戏提示框，允许其他插件向可拾取物品添加信息。';
L['Use Global Loot Tooltip'] = '使用全局拾取提示框';
L['Use Hardware Mouse Cursor'] = '使用硬件鼠標光標';
L['Use Instant Mode'] = '使用即時模式';
L['Use Interact Nameplate Tooltip'] = '使用互動姓名板提示框';
L['Use On Demand'] = '按需使用';
L['Use optimized pathfinding algorithm for cursor movement.'] = '為光標移動使用優化的寻路算法。';
L['Use press and hold to navigate and use rings. Press, point, release.'] = '使用按住進行导航和使用環。按住、指向、釋放。';
L['Use Static Mode'] = '使用静態模式';
L['Use the hardware cursor provided by the operating system.'] = '使用操作系統提供的硬件光標。';
L['Use together with [@cursor] macros to place reticle spells in a single click.'] = '與 [@cursor] 宏一起使用，單擊放置准星法術。';
L['Used for interacting with the world, at a center-fixed position.'] = '用於在中心固定位置與世界互動。';
L['Uses global tint color when transparent.'] = '透明時使用全局色調颜色。';
L['Uses the default hotkey icons instead of the custom icons provided by ConsolePort.'] = '使用默認快捷鍵圖標而不是 ConsolePort 提供的自定義圖標。';
L['Valid Action Deadzone'] = '有效動作死區';
L['Value below two may appear interlaced or not at all.'] = '低於二的值可能顯示為隔行扫描或完全不顯示。';
L['Vertical Offset'] = '垂直偏移';
L['Vertical offset from anchor point.'] = '锚點的垂直偏移。';
L['Vertical offset of the counter text on buttons.'] = '按鈕上計數器文本的垂直偏移。';
L['Vertical offset of the hotkey icon on group buttons.'] = '組按鈕上快捷鍵圖標的垂直偏移。';
L['Vertical offset of the hotkey prompt position, in pixels.'] = '快捷鍵提示位置的垂直偏移，以像素為單位。';
L['Vertical offset of the hotkey text on buttons.'] = '按鈕上快捷鍵文本的垂直偏移。';
L['Vertical offset of the macro text on buttons.'] = '按鈕上宏文本的垂直偏移。';
L['Vertical Padding'] = '垂直內邊距';
L['Vertical position of centered cursor & targeting, as fraction of screen height.'] = '居中光標和目標選擇的垂直位置，作為屏幕高度的比例。';
L['Visibility Condition'] = '可見性條件';
L['Watch bars include XP, reputation, honor, artifact power, and azerite.'] = '监視條包括經驗值、聲望、榮譽、神器之力和艾泽里特。';
L['When disabled, a button press will also act as a cursor click.'] = '禁用時，按下按鈕也會作為光標點擊。';
L['When disabled, you will need to press the accept button to confirm a selection.'] = '禁用時，你需要按下接受按鈕以確認選擇。';
L['When enabled, a tap will act as a button press.'] = '啟用時，點擊將作為按下按鈕。';
L['When set to both sticks, cursor only disables when both sticks are used together.'] = '設置為两個摇杆時，只有同時使用两個摇杆時光標才會禁用。';
L['Whether client keybindings should be saved to the server.'] = '客戶端按鍵绑定是否應保存到服務器。';
L['Whether the keyboard should always be shown or only when a gamepad is active.'] = '鍵盤是否應始終顯示，或僅在手柄處於活動狀態時顯示。';
L['Whether to save character- and account-scoped variables to the server.'] = '是否將角色和賬戶範圍的變量保存到服務器。';
L['Which button set to use for unit hotkeys.'] = '用於單位快捷鍵的按鈕集。';
L['Which modifier to use for modified commands.'] = '用於修改命令的修飾鍵。';
L['Which modifier to use for nudging the cursor.'] = '用於推動光標的修飾鍵。';
L['Which modifier to use to toggle the mouse cursor when double-tapped.'] = '雙擊時用於切換鼠標光標的修飾鍵。';
L['Which modifier to use with the movement buttons to move the cursor.'] = '用於與移動按鈕一起移動光標的修飾鍵。';
L['While disabled, cursor timeout, and toggling between free-roaming and center-fixed cursor are also disabled.'] = '禁用時，光標超時以及自由漫游和居中固定光標之間的切換也被禁用。';
L['While held down, can simulate dragging by clicking on the directional pad.'] = '按住時，可以通過點擊方向鍵模拟拖拽。';
L['Width of the artwork.'] = '美術的宽度。';
L['Width of the cluster bar.'] = '集群條的宽度。';
L['Width of the crosshair, in scaled pixel units.'] = '准星的宽度，以缩放像素單位表示。';
L['Width of the group.'] = '組的宽度。';
L['Width of the toolbar.'] = '工具栏的宽度。';
L['Wipe Dictionary'] = '清除字典';
L['Wired'] = '有線';
L['Works like a regular action bar, which displays the action slots of a specified action page.'] = '像常規動作條一樣工作，顯示指定動作页面的動作槽。';
L['X Offset'] = 'X 偏移';
L['XP Bar Color'] = '經驗條颜色';
L['Y Offset'] = 'Y 偏移';
L['Yaw Axis'] = '偏航轴';
L['Yaw-only deadzone for camera, applied before the 2D deadzone.'] = '摄像機的僅偏航死區，在 2D 死區之前應用。';
L['your current loadout'] = '你當前的配置';
---------------------------------------------------------------
-- Literal block entries
---------------------------------------------------------------
L['%s is already bound to\n%s\n\nDo you want to change it to\n%s?'] = [[%s 已绑定到
%s

你要將其更改為
%s 吗？]];
L['+ Normal\n- Inverted'] = [[+ 正常
- 反轉]];
L['Takes the format of...\n'] = [[格式為...
]];
L['The bindings underlying the button combinations will be unavailable while the cursor is in use.\n\nModifier can also be configured on a per button basis.'] = [[光標使用時，按鈕組合的底層快捷鍵將不可用。

修飾鍵也可以按按鈕配置。]];
L['When set to zero, always face your movement stick direction.\nWhen set to max, never face your movement stick direction.'] = [[設置為零時，始終面向你的移動摇杆方向。
設置為最大時，永遠不要面向你的移動摇杆方向。]];
L['Your %s device has separate handling for Bluetooth and wired connection.\nWhich one are you using?'] = [[你的 %s 設備對藍牙和有線连接有單独的處理方式。
你正在使用哪一種？]];
