local L = select(2, ...).Locale;
---------------------------------------------------------------
-- zhCN 简体中文 simplified Chinese
---------------------------------------------------------------
---------------------------------------------------------------
-- Short / curated keys
---------------------------------------------------------------
L.ACTIONBAR_FORM_ACTIVE_DESC  = '此形态当前处于激活状态，你的主动作条正在显示与之相关的技能。'; -- en:b400a632
L.DESC_CAMERAZOOMIN           = '将摄像机拉近。按住进行连续缩放。'; -- en:55f9b91f
L.DESC_CAMERAZOOMOUT          = '将摄像机拉远。按住进行连续缩放。'; -- en:a6b9d796
L.DESC_OPENALLBAGS            = '打开/关闭所有背包。'; -- en:4a74797f
L.DESC_RING_TARGET            = '以环形显示你的单位池，让你可以使用径向摇杆选择目标单位。'; -- en:294b636e
L.DESC_TOGGLEWORLDMAP_CLASSIC = '显示/关闭世界地图。'; -- en:00548e70
L.DESC_TOGGLEWORLDMAP_RETAIL  = '显示/关闭世界地图和任务日志。'; -- en:621a94e8
L.FORMAT_HOLD_BINDING         = '%s（按住）'; -- en:c3ecd1b3
L.FORMAT_RING_NUMERICAL       = '|cFF00FFFF%s|r 环'; -- en:68d18518
L.NAME_EASY_MOTION            = '目标单位框架（按住）'; -- en:e6f0c131
L.NAME_QUICK_MENU             = '快捷菜单'; -- en:ed9a0668
L.NAME_RAID_CURSOR_FOCUS      = '团队光标(焦点)'; -- en:d350d370
L.NAME_RAID_CURSOR_TARGET     = '团队光标(目标)'; -- en:8182d5d5
L.NAME_RAID_CURSOR_TOGGLE     = '切换团队光标'; -- en:79fb9d46
L.NAME_RING_MENU              = '菜单环'; -- en:8d7e5939
L.NAME_RING_PET               = '宠物环'; -- en:8dab5a0e
L.NAME_RING_TARGET            = '目标环（按住）'; -- en:59e8a9cb
L.NAME_RING_UTILITY           = '工具环'; -- en:96bc880d
L.NAME_UI_CURSOR_TOGGLE       = '切换界面光标'; -- en:2d6091b5
L.RING_EMPTY_DESC             = '你在此环中尚未放置任何能力。'; -- en:044cf09a
---------------------------------------------------------------
-- Long / curated block entries
---------------------------------------------------------------
L.ACTIONBAR_FORM_DESC = [[激活此形态将自动切换你的主动作条以显示与此形态相关的技能。

该形态与你的主动作条共享快捷键，允许你使用常规组合键访问此形态中的技能。

当你退出此形态时，你的主动作条将恢复到之前的状态，显示你的常规技能。]]; -- en:a751197a
L.ACTIONBAR_MAIN_DESC = [[主动作条是你放置循环技能和其他常用动作的主要位置。

该动作条是动态的，可以根据你当前的状况自动切换到不同的页面。

例如，当你进入载具、参与宠物对战、变身为不同形态、进入战斗姿态或控制其他单位时，主动作条会切换到特殊的技能组。

这允许你访问特定情境下的技能，无需手动更改你的动作条设置。

当你回到正常状态时，你的常规技能将重新出现在动作条上。]]; -- en:8e47cecd
L.ACTIONBAR_PAGE_MISMATCH_DESC = [[由于动作条系统最初的设计方式，动作条的实际页码并不总是与显示的名称匹配。

如果你没有使用自定义动作页面解决方案，可以忽略此差异。两者都显示以供参考。]]; -- en:9fd917fd
L.ADD_NEW_RING_TEXT = [[|cFFFFFF00创建新环|r
请为新环选择一个名称：]]; -- en:00af872a
L.CLEAR_RING_TEXT = [[|cFFFFFF00清空 %s|r
你确定要清空此环吗？]]; -- en:ebc807d8
L.CONTROLS_GAMEPAD_TESTER_ACTION = [[
	如果没有检测到输入，测试将在几秒后自动过期。
]]; -- en:0f591dc7
L.CONTROLS_GAMEPAD_TESTER_DESC = [[
	使用测试工具来验证你的手柄是否正常工作。

	测试将要求你按下手柄上的按钮并移动轴，
	以确保所有按钮和传感器按预期工作。

	故障排除：

	- 确保你的手柄已连接并被操作系统识别。

	- 检查是否有冲突的软件可能干扰你的设备，
	例如 Windows 上后台运行的 Steam。

	- 如果使用掌上电脑，请确保设备在控制中心中设置为游戏模式。
	桌面模式将无法正常工作。

	- 更新驱动程序并安装手柄所需的任何软件。
]]; -- en:fd1ed2f5
L.CONTROLS_GENERAL_INFO = [[
	选择你偏好的控制方案。
]]; -- en:3f779845
L.CONTROLS_MODIFIERS_CUSTOM = [[
	使用自定义修饰键设置。

	建议将修饰键设置在肩键或扳机上，因为它们是手柄上最容易访问的按钮。
]]; -- en:964cdf45
L.CONTROLS_MODIFIERS_DESC = [[
	修饰键在快捷键集之间切换，并模拟键盘控制键（Shift、Ctrl、Alt）。

	按住修饰键将临时切换你的快捷键到另一个集合，扩展你的可用操作。

	修饰键可以被点击 — 快速按下并释放 — 以执行常规快捷键。

	它们也可以相互组合；使用两个修饰键总共可以访问四个快捷键集，
	三个修饰键可以提供八个快捷键集。

	对于大多数玩家来说，两个修饰键就足以拥有一个舒适的快捷键集，
	而不会增加太多复杂性。
]]; -- en:b083ec08
L.CONTROLS_MODIFIERS_LEFT = [[
	使用左手修饰键，将移动和快捷键集切换保持在手柄的左侧。

	为左右手分配单独的角色可能有助于人体工程学和协调性。
]]; -- en:507e5d94
L.CONTROLS_MODIFIERS_TRIGGERS = [[
	使用两个扳机作为修饰键，将你的快捷键在左右两侧之间分开。

	如果你正在从 FFXIV 过渡过来，或者你偏好十字栏的心智模型，这可能会有所帮助。
]]; -- en:70401fbd
L.CONTROLS_MOUSE_BUTTONS_DESC = [[
	鼠标按键可以被模拟，以提供类似鼠标的功能。

	在某些情况下这些快捷键是至关重要的，例如确认地面上的法术放置、
	在人群中精确选择目标，以及一些小众的界面操作。

	它们可以与修饰键组合，以进一步复制鼠标的功能。

	这些按钮还用于切换光标，光标可以有三种不同的状态：

	- 自由：你可以使用手柄在屏幕上移动光标。

	- 居中：光标固定在屏幕中央，用于瞄准对象和角色
	以及在地面上放置法术。

	- 隐藏：光标仍居中，但在屏幕上不可见。其位置由一个准星指示。
]]; -- en:e088d19f
L.CONTROLS_MOUSE_CUSTOM = [[
	使用自定义鼠标按键设置。

	《魔兽世界》以两种独立、大多隐藏的方式处理鼠标按键。

	- 当你点击游戏界面（如按钮或菜单）时，界面只对
	鼠标点击作出反应，这可以由手柄模拟。

	- 当你点击游戏世界中的东西（如选择目标或交互）时，它使用常规的快捷键。

	强烈建议将这些操作放在一起，以承担与鼠标相同的角色。
]]; -- en:3e862670
L.CONTROLS_MOUSE_INVERTED = [[
	使用反转的鼠标按键快捷键。

	使用左摇杆在居中和隐藏光标模式之间切换，以及进行右键单击。

	使用右摇杆切换自由光标模式，以及进行左键单击。
]]; -- en:16d3d6d2
L.CONTROLS_MOUSE_REGULAR = [[
	使用常规的鼠标按键快捷键。

	使用左摇杆切换自由光标模式，以及进行左键单击。

	使用右摇杆在居中和隐藏光标模式之间切换，以及进行右键单击。
]]; -- en:75e9f21b
L.CONTROLS_MOVEMENT_BALANCED_DESC = [[
	平衡移动是坦克和跟随移动之间的折衷。

	在战斗和旅行中，此配置将在每个方向横移最多 115 度，
	这意味着你在侧向移动时仍然面向前方。

	如果你将摇杆进一步向下移动，你的角色将过渡到跟随你的移动方向。
	查看角色的头部以了解他们面对的方向。

	115 度是在不损失任何移动速度的情况下提供最大覆盖范围的最佳点。
]]; -- en:3355743a
L.CONTROLS_MOVEMENT_DESC = [[
	可以根据你的游戏风格自定义移动控制。

	手柄使用模拟移动，这意味着你可以朝任何方向奔跑，
	并通过改变施加在摇杆上的压力来步行。

	游戏在很大程度上依赖横移作为机制，
	你在面对不同方向的同时侧向移动。

	你可以自定义你的角色何时在横移和
	转向面对你的移动方向之间过渡。

	高亮其中一种配置并移动你的左摇杆
	以测试它。
]]; -- en:9d22c4f0
L.CONTROLS_MOVEMENT_FOLLOW_DESC = [[
	「跟随」移动专注于跟随你正在移动的方向。

	在战斗和旅行中，此配置将永远不会横移，
	也永远不会向后行走。

	这对于经常或总是使用单摇杆配置的玩家可能很有用。
]]; -- en:45773d56
L.CONTROLS_MOVEMENT_TANK_DESC = [[
	坦克移动专注于在战斗中保持面向前方的位置。

	在战斗中，此配置将始终横移，并向后行走以保持面向前方。

	在旅行期间，此配置将始终跟随移动方向。
]]; -- en:9fcbcaaf
L.DEFAULTS_BINDINGS_EMPTY_DESC = [[
	从空白开始。

	此操作将清除你所有当前的手柄快捷键，包括暴雪的默认设置，
	以便你可以从头开始设置快捷键。

	此操作不会覆盖或干扰现有的键盘快捷键，
	但请记住，动作条在两者之间是共享的。

	如果你计划在键盘和手柄之间切换，建议更改你的
	手柄快捷键，而不是在动作条上移动技能。
]]; -- en:51053386
L.DEFAULTS_BINDINGS_PRESET_DESC = [[
	应用推荐的快捷键。

	这些快捷键基于你之前的选择，应该可以为你的手柄设置提供一个良好的起点。你随时可以更改它们。

	此操作不会覆盖或干扰现有的键盘快捷键，
	但请记住，动作条在两者之间是共享的。

	如果你计划在键盘和手柄之间切换，建议更改你的
	手柄快捷键，而不是在动作条上移动技能。
]]; -- en:6ac789b1
L.DEFAULTS_GENERAL_INFO = [[
	通过应用手柄的推荐设置和快捷键来完成设置。
]]; -- en:c436023e
L.DEFAULTS_SETTINGS_APPLIED = [[
	你的手柄类型 (%s) 的推荐设置已应用。
]]; -- en:16be45b5
L.DEFAULTS_SETTINGS_DESC = [[
	为你的手柄类型 (%s) 应用推荐设置：
]]; -- en:15a4050f
L.DEFAULTS_SETTINGS_NOTWEAK = [[
	你的手柄类型 (%s) 没有任何推荐设置可应用。
]]; -- en:067a8a20
L.DESC_EASY_MOTION = [[
	为你的单位框架中的每一个单位生成一个快捷键，
	按下对应快捷键即可切换目标。

	按住快捷键，然后点击你要选择的目标上
	看到的提示键，然后释放快捷键即可更改目标。

	强烈推荐5人本中的治疗职业使用，
	因为它提供了在较小组中非常快速的目标选择方法。

	在团队中，该功能在选取目标时操作可能过于复杂,会较为难用。
	该功能是切换友方目标的方案之一, 请参阅"团队光标"查看另一个方案。
]]; -- en:0f9384b6
L.DESC_EXTRAACTIONBUTTON1 = [[
	额外动作按钮容纳一种临时能力，用于
	各种任务、场景和首领战斗。

	当此快捷键未设置时，额外动作按钮始终
	可在工具环上使用。

	此按钮作为常规动作按钮出现在你的手柄动作条上，
	但你无法更改其内容。
]]; -- en:6dd42998
L.DESC_INTERACTTARGET = [[
	允许你与游戏世界中的 NPC 和对象互动。

	具有与居中光标相同的能力，但不需要你将光标或准星直接对准目标。

	可交互对象在范围内时会被高亮显示。
]]; -- en:b1478add
L.DESC_JUMP = [[
	还可以用于在水下向上游泳、与飞行坐骑一起上升，
	以及在驭龙术中起飞或向上扑翼。

	跳跃对于在执行需要拇指的左手动作时
	弥补移动中的空隙很有用。

	在常规设置中，左摇杆控制你的移动。
	如果你需要在移动中按下方向键组合，
	可以使用跳跃来维持你的前进动量，同时
	短暂地将拇指从摇杆上移开。
]]; -- en:4c032315
L.DESC_KEY_BUTTON1 = [[
	用于开启/关闭自由光标模式，在该模式下你可以使用摄像机杆(一般为右摇杆)移动鼠标指针
]]; -- en:fd3d111a
L.DESC_KEY_BUTTON2 = [[
	用于切换居中光标模式，允许你在游戏世界的中心固定鼠标位置与对象和角色互动。
]]; -- en:2f5c87e4
L.DESC_QUICK_MENU = [[
	一个快捷菜单，集中游戏中常用的操作，
	例如对组队战利品进行掷骰、取消增益效果
	或使用背包中的物品。
]]; -- en:0365846b
L.DESC_RAID_CURSOR = [[
	切换一个夹紧到你屏幕上单位框架的光标，
	允许你在保持另一个目标的同时治疗友方玩家。

	团队光标也可以设置为直接目标选择，
	移动光标会切换你当前的目标。

	使用时，团队光标占用一组
	方向键组合来控制光标位置。

	在路由模式下，光标不会重新路由宏或
	模糊的法术，例如牧师的「忏悔」。

	请参阅「单位框架瞄准」以获取其他选择。
]]; -- en:cacdf9c0
L.DESC_RING_CUSTOM = [[
	一个环形菜单，你可以在其中添加你不想为之牺牲动作条空间的
	物品、法术、宏和坐骑。

	要使用，按住快捷键，朝你想选择的物品方向倾斜你的摇杆，
	然后释放快捷键。

	要从环中删除物品，将该物品聚焦后按提示框提示操作。
]]; -- en:159abd06
L.DESC_RING_MENU = [[
	一个环形菜单，将常用面板和频繁操作
	集中在一个地方以便快速访问。

	该环还可以通过切换页面从游戏菜单中访问，
	无需单独绑定。
]]; -- en:7ee244a1
L.DESC_RING_PET = [[
	一个环形菜单，允许你控制当前的宠物。
]]; -- en:b1c4b5d3
L.DESC_RING_UTILITY = [[
	一个环形菜单，你可以在其中添加你不想为之牺牲动作条空间的
	物品、法术、宏和坐骑。

	要使用，按住快捷键，朝你想选择的物品方向倾斜你的摇杆，
	然后释放快捷键。

	要向环中添加物品，按界面光标的提示操作，
	或者，用你的鼠标光标拾取物品，然后按快捷键将其放入环中。

	要从环中删除物品，将该物品聚焦后按提示框提示操作。

	工具环会自动添加未放在你动作条上的任务物品和临时能力。
]]; -- en:de107e96
L.DESC_TARGETNEARESTENEMY = [[
	在你面前最近的敌方目标之间切换。
	没有当前目标时，将选择最居中的敌人。
	否则，它将在最近的目标之间循环。

	按住可在决定切换目标之前
	高亮显示目标。

	建议用作辅助目标选择快捷键，
	或在休闲游戏中用作主要目标选择快捷键，
	或者当目标扫描需要太多精度而不舒适时使用。

	不建议用于地下城或其他高精度场景。
]]; -- en:981bc29c
L.DESC_TARGETSCANENEMY = [[
	在你面前的狭窄圆锥中扫描敌人。
	按住可持续切换, 直至松开。

	特别适用于在战斗中快速切换目标
	精确度高。

	最靠近圆锥中心的目标将被优先选择。
	如果目标更接近圆锥中心,	即使他离你距离更远, 也会被优先选择。

	推荐大多数玩家将其设置为主要的切换目标快捷键。 
]]; -- en:2de05bb9
L.DESC_TOGGLEAUTORUN = [[
	自动奔跑将使你的角色继续朝你面对的方向移动，
	而无需你的任何输入。

	自动奔跑对于减轻长时间移动的拇指疲劳很有用，
	或者在你移动时解放你的拇指做其他事情。
]]; -- en:9e97af4b
L.DESC_TOGGLEGAMEMENU = [[
	菜单快捷键处理键盘上按下 Esc 键时发生的所有功能。
	它根据当前游戏状态处理不同的操作。

	如果有与法术或目标选择相关的正在进行的动作，
	它们将被取消。在有活动目标的情况下按下快捷键
	将清除它。在施法时按下快捷键将
	中断施法。

	快捷键还根据屏幕上当前显示的内容处理
	各种其他情况。例如，如果有面板
	打开，例如法术书，快捷键将执行
	必要的操作来关闭或隐藏它。

	如果以上情况都不适用，按下时游戏菜单将
	打开或关闭。
]]; -- en:adfccfe4
L.DEVICE_DESC_PLAYSTATION4 = [[
	PlayStation 4 控制器（也称为 DualShock 4）是 Sony 的上一代手柄。

	它是一款功能丰富的手柄，具有触摸板、动作控制以及在游戏中支持其所有按钮。

	要充分利用所有功能，你可能需要安装 PlayStation Accessories (Windows)。
]]; -- en:7bea4ad9
L.DEVICE_DESC_PLAYSTATION5 = [[
	PlayStation 5 控制器（也称为 DualSense）目前是《魔兽世界》最好的手柄。

	它是目前最完整的手柄，具有动作控制、触摸板，以及在 Edge 变体的情况下，原生背部拨片。
	手柄上的所有按钮都可以在游戏中使用。

	要充分利用所有功能，你可能需要安装 PlayStation Accessories (Windows)。
]]; -- en:c5f15091
L.DEVICE_DESC_STEAMDECK = [[
	Steam Deck 通常通过 Steam 客户端的 Proton 运行《魔兽世界》。

	通过 Steam 玩游戏时，设备应使用至少覆盖标准 Xbox 布局的游戏配置文件。

	手柄+鼠标触控板提供了坚实的基础。

	Steam Deck 不能在《魔兽世界》中原生使用其拨片。
	可以使用模拟或在 Steam Input 设置中使用键盘键来映射拨片。

	游戏内 Steam Deck 预设也可能适合其他掌上电脑，因为控制布局相似。
]]; -- en:2a5e4173
L.DEVICE_DESC_SWITCHPRO = [[
	Nintendo Switch Pro 控制器的布局与 Xbox 控制器类似，但按钮标签反转。

	Pro 控制器有四个中央按钮，使其相对于标准 Xbox 控制器略有优势。

	Nintendo Switch 2 Pro 控制器不能在游戏中原生使用其拨片或 C 按钮。
	使用外部软件，例如 Steam 或 reWASD，可以将它们映射到键盘键，允许在游戏中使用。
]]; -- en:79260874
L.DEVICE_DESC_XBOX = [[
	Xbox 变体是最常见的手柄，并被《魔兽世界》良好支持。

	Xbox Elite 控制器不能在游戏中原生使用其拨片，但可以使用它们来模拟其他手柄按钮，
	使用 Xbox Accessories 应用 (Windows)。

	使用外部软件，例如 Steam 或 reWASD，可以将拨片映射到键盘键，允许在游戏中使用。

	中央按钮保留给 Xbox Guide，无法在游戏中使用。

	也推荐用于 Steam Input，与其模拟的 Xbox 360 控制器一致。
]]; -- en:654501d3
L.DISC_KEY_BUTTON1 = [[
	当你的一个按钮设置为模拟左键点击时，此快捷键无法更改。
]]; -- en:e811ebc6
L.DISC_KEY_BUTTON2 = [[
	当你的一个按钮设置为模拟右键点击时，此快捷键无法更改。
]]; -- en:b85c78b2
L.EXPORT_DATA_TEXT = [[

|cFFFFFF00导出|r

选择你要导出的数据。将生成一个字符串，你可以将其粘贴到另一个客户端，或与他人分享。

使用 %s 复制字符串。
]]; -- en:1741e6a6
L.GFX_GENERAL_INFO = [[
	选择与你的手柄外观最接近的手柄图形。

	选择图形不会改变手柄的工作方式，它只会改变界面的外观。

	图形用于显示当前哪些按钮绑定了哪些操作，并为你的手柄布局提供视觉参考。

	根据你的选择，会提供一些可选的设置建议。
]]; -- en:54457360
L.IMPORT_DATA_TEXT = [[

|cFFFFFF00导入|r

在下面粘贴导出的字符串，然后加载并选择要导入的数据。导入的数据将在适用时覆盖你当前的数据。

使用 %s 从源复制字符串，使用 %s 在下面粘贴字符串。
]]; -- en:145f78fb
L.IMPORT_FAILED_TEXT = [[

|cFFFFFF00导入|r

导入失败：
]]; -- en:a7555666
L.LINK_COPY = [[
	链接到 %s。

	按 Ctrl+A 选择，Ctrl+C 复制。

	在浏览器中粘贴 (Ctrl+V) 链接。
]]; -- en:3f396345
L.LINK_DISCORD_TEXT = [[
	你可以在这个社区中获得支持、讨论玩法、分享想法，并结识志同道合的玩家。

	点击此处加入服务器。
]]; -- en:e2f9740c
L.LINK_PATREON_TEXT = [[
	这个插件的开发和维护需要大量的时间和精力，
	但 ConsolePort 将始终完全免费。

	成为 Patreon 支持者以解锁你的 Discord 徽章，并支持项目的未来。

	点击此处成为赞助者。
]]; -- en:3cc9532e
L.LINK_PAYPAL_TEXT = [[
	捐款将直接重新投入插件的开发和维护。

	任何贡献，无论大小，都将受到高度赞赏。

	点击此处通过 PayPal 捐款。
]]; -- en:28c6265a
L.REMOVE_RING_TEXT = [[|cFFFFFF00移除 %s|r
你确定要移除此环吗？]]; -- en:1a461a1a
L.RING_MENU_DESC = [[创建你自己的环形菜单，你可以在其中添加不想牺牲动作栏空间的物品、法术、宏和坐骑。

要使用，请按住选定的快捷键，向你要选择的物品方向倾斜摇杆，然后释放快捷键。

默认环或 |CFF00FF00工具环|r 具有特殊属性，可以帮你使用任务物品或其他交互物品，并且不是静态的。它将根据需要自动添加和移除物品。

如果你想创建一个在输出循环中用到的环，强烈建议使用自定义环而不是工具环。]]; -- en:39d4577b
L.SELECTED_RING_TEXT = [[这是你当前选择的环。
当你按住快捷键时，所有你选择的能力将以环的形式显示在屏幕上。

将你控制镜头用的摇杆(一般为右摇杆)向你要使用的能力或物品的方向倾斜，然后施放快捷键以确认。]]; -- en:2cdfa5d3
L.SET_RING_BINDING_TEXT = [[
|cFFFFFF00设置快捷键|r

按下按钮组合以为此环选择一个新的快捷键。

]]; -- en:1c0e03f4
L.SLOT_NO_BINDING = [[
|cFFFFFF00设置快捷键|r

%s 在 %s 中尚未分配快捷键。

按下按钮组合以为此插槽选择一个新的快捷键。

]]; -- en:74326275
L.SLOT_SET_BINDING = [[
|cFFFFFF00设置快捷键|r

按下按钮组合以为 %s 选择一个新的快捷键。

]]; -- en:d1933130
---------------------------------------------------------------
-- Literals
---------------------------------------------------------------
L['2D deadzone for camera that takes into account pitch and yaw movement together.'] = '用于摄像机的 2D 死区，同时考虑俯仰和偏航运动。';
L['2D deadzone for movement that takes into account X and Y movement together.'] = '用于移动的 2D 死区，同时考虑 X 和 Y 移动。';
L['A button cluster for all modifiers of a single button.'] = '单个按钮所有修饰键的按钮集群。';
L['A cluster bar with a toolbar below it, laid out horizontally.'] = '集群条下方有水平放置的工具栏。';
L['A cluster bar with a toolbar below it.'] = '集群条下方有工具栏。';
L['A divider to separate elements.'] = '用于分隔元素的分隔符。';
L['A friendly soft target can be acquired while having an enemy hard target.'] = '在拥有敌对硬目标的同时，可以获取友善软目标。';
L['A regular action bar.'] = '常规动作条。';
L['A ring of buttons for pet commands.'] = '用于宠物指令的按钮环。';
L['A toolbar with XP indicators, shortcuts, class specific bars, and miscellaneous information.'] = '带有经验值指示器、快捷方式、职业相关条和杂项信息的工具栏。';
L['About'] = '关于';
L['Acceleration of cursor per second as it continues to move.'] = '光标在继续移动时每秒的加速度。';
L['Accent Color'] = '强调色';
L['Accept Button'] = '接受按钮';
L['Action Bar Configuration'] = '动作条配置';
L['Action bar is scaled separately.'] = '动作条单独缩放。';
L['Action Bar Loadout'] = '动作条配置';
L['Action Bar Loadout (Deprecated)'] = '动作条配置（已弃用）';
L['Action Bar Presets'] = '动作条预设';
L['Action Bar Setup'] = '动作条设置';
L['Action Button'] = '动作按钮';
L['Action Button Group'] = '动作按钮组';
L['Action Page'] = '动作页面';
L['Action Page Condition'] = '动作页面条件';
L['Action Page Response'] = '动作页面响应';
L['Activate targeting components only while their bindings are in use.'] = '仅在相应快捷键被使用时激活目标选择组件。';
L['Active Color'] = '活动颜色';
L['Active Device'] = '活动设备';
L['Add a new element to your loadout.'] = '向你的配置添加新元素。';
L['Add to %s'] = '添加到 %s';
L['Add, remove or reset a frame from cursor stack.'] = '从光标堆栈添加、删除或重置框架。';
L['Affects both mouse and gamepad.'] = '影响鼠标和手柄。';
L['Alignment'] = '对齐';
L['Alignment of the counter text on buttons.'] = '按钮上计数器文本的对齐方式。';
L['Alignment of the hotkey text on buttons.'] = '按钮上快捷键文本的对齐方式。';
L['Alignment of the macro text on buttons.'] = '按钮上宏文本的对齐方式。';
L['All combines all connected devices into one.'] = '「全部」将所有连接的设备合并为一个。';
L['Allow binding discrete radial stick inputs.'] = '允许绑定离散的径向摇杆输入。';
L['Allow binding multiple combos to the same binding.'] = '允许将多个组合绑定到同一快捷键。';
L['Allow Binding Overlap'] = '允许快捷键重叠';
L['Allow cursor to interact with and show preference for group loot frames.'] = '允许光标与组队拾取框架交互并优先显示。';
L['Allow cursor to interact with and show preference for popups and static dialogs.'] = '允许光标与弹出窗口和静态对话框交互并优先显示。';
L['Allow cursor to interact with the entire interface, not only panels.'] = '允许光标与整个界面交互，而不仅仅是面板。';
L['Allow Radial Bindings'] = '允许径向快捷键';
L['Allows the use of the touchpad to control cursor movement.'] = '允许使用触摸板控制光标移动。';
L['Alphabet to use for dictionary suggestions and word processing.'] = '用于字典建议和文字处理的字母表。';
L['Always keep cursor centered and visible when controlling camera.'] = '控制摄像机时始终保持光标居中并可见。';
L['Always Show All Buttons'] = '始终显示所有按钮';
L['Always Show Mouse Cursor'] = '始终显示鼠标光标';
L['Always show nameplate for soft enemy target.'] = '始终为软敌方目标显示姓名板。';
L['Always show nameplate for soft friendly target.'] = '始终为软友方目标显示姓名板。';
L['Always show tooltip for an automatically acquired target, as long as it exists.'] = '只要目标存在，始终为自动获取的目标显示提示框。';
L['An action button in a group.'] = '组中的动作按钮。';
L['Analog Movement'] = '模拟移动';
L['Anchor'] = '锚点';
L['Anchor point of parent to pair with.'] = '父级用于配对的锚点。';
L['Anchor point of the counter text on buttons.'] = '按钮上计数器文本的锚点。';
L['Anchor point of the hotkey icon on group buttons.'] = '组按钮上快捷键图标的锚点。';
L['Anchor point of the hotkey text on buttons.'] = '按钮上快捷键文本的锚点。';
L['Anchor point of the macro text on buttons.'] = '按钮上宏文本的锚点。';
L['Anchor point to attach.'] = '用于附加的锚点。';
L['Apply default settings to the current category or all settings.'] = '将默认设置应用于当前类别或所有设置。';
L['Arc Allowance'] = '弧度允许';
L['Are you sure you want to delete %s from %s?'] = '你确定要从 %s 删除 %s 吗？';
L['Are you sure you want to overwrite %s with %s?'] = '你确定要用 %s 覆盖 %s 吗？';
L['Are you sure you want to regenerate the keyboard dictionary? You will lose all custom phrases.'] = '你确定要重新生成键盘字典吗？你将丢失所有自定义短语。';
L['Are you sure you want to reset all device profiles?'] = '你确定要重置所有设备配置文件吗？';
L['Are you sure you want to reset the keyboard layout?'] = '你确定要重置键盘布局吗？';
L['Are you sure you want to reset your device profile?'] = '你确定要重置你的设备配置文件吗？';
L['Are you sure you want to wipe the keyboard dictionary? It currently contains %d words.'] = '你确定要清除键盘字典吗？它当前包含 %d 个单词。';
L['Area where the interact key can find a suitable target.'] = '互动键可以找到合适目标的区域。';
L['Artwork flavor.'] = '美术风格变体。';
L['Artwork for the interface.'] = '界面美术。';
L['Artwork style.'] = '美术样式。';
L['Assign or clear bindings for this set.'] = '为此集合分配或清除快捷键。';
L['Auto-adjusts your camera, allowing you to control movement with a single stick.'] = '自动调整你的摄像机，允许你使用单个摇杆控制移动。';
L['Auto-Sell Gear Level Limit'] = '自动出售装备等级限制';
L['Auto-Sell Junk'] = '自动出售杂物';
L['Auto-set target to match soft target.'] = '自动设置目标以匹配软目标。';
L['Automatic Binding Backups'] = '自动快捷键备份';
L['Automatic Cursor Timeout'] = '自动光标超时';
L['Automatic Tooltip Duration'] = '自动提示框持续时间';
L['Automatically add tracked quest items and extra spells to main utility ring.'] = '自动将追踪的任务物品和额外法术添加到主工具环。';
L['Automatically backup your bindings when you change them, for import and export.'] = '当你更改快捷键时自动备份它们，用于导入和导出。';
L['Automatically Bind Extra Items'] = '自动绑定额外物品';
L['Automatically Control Cursor Pickups'] = '自动控制光标拾取';
L['Automatically control cursor when picking up items.'] = '拾取物品时自动控制光标。';
L['Automatically disabled if an inactive component is clicked from a macro.'] = '如果通过宏点击了未激活的组件，将自动禁用。';
L['Automatically sell junk when interacting with a merchant.'] = '与商人互动时自动出售杂物。';
L['Axis Interpretation'] = '轴解释';
L['Basic redirect cannot route macros or ambiguous spells. Use target mode or focus mode with [@focus] macros to control behavior.'] = '基本重定向无法路由宏或模糊的法术。使用目标模式或焦点模式以及 [@focus] 宏来控制行为。';
L['Battery Level'] = '电池电量';
L['Binding Catch Timeframe'] = '快捷键捕获时间';
L['Blend Mode'] = '混合模式';
L['Blend mode of the artwork.'] = '美术的混合模式。';
L['Blizzard_Collections'] = 'Blizzard_Collections';
L['Blizzard_DelvesCompanionConfiguration'] = 'Blizzard_DelvesCompanionConfiguration';
L['Blizzard_HelpPlate'] = 'Blizzard_HelpPlate';
L['Blizzard_HouseEditor'] = 'Blizzard_HouseEditor';
L['Blizzard_HousingTemplates'] = 'Blizzard_HousingTemplates';
L['Blizzard_MapCanvas'] = 'Blizzard_MapCanvas';
L['Blizzard_PlayerSpells'] = 'Blizzard_PlayerSpells';
L['Blizzard_PVPMatch'] = 'Blizzard_PVPMatch';
L['Blizzard_SharedMapDataProviders'] = 'Blizzard_SharedMapDataProviders';
L['Bluetooth'] = '蓝牙';
L['Border Vertex Color'] = '边框顶点颜色';
L['Breadth'] = '宽度';
L['Breadth of the divider.'] = '分隔符的宽度。';
L['Button %d'] = '按钮 %d';
L['Button or combination used to click when a given condition applies, but act as a normal binding otherwise.'] = '当给定条件适用时用于单击的按钮或组合，否则作为常规快捷键操作。';
L['Button Set'] = '按钮集';
L['Button that emulates '] = '模拟以下按键的按钮：';
L['Button that emulates the '] = '模拟以下按键的按钮：';
L['Button to cancel or exit the quick menu.'] = '取消或退出快捷菜单的按钮。';
L['Button to handle cancel actions, such as exiting menus.'] = '处理取消操作（如退出菜单）的按钮。';
L['Button to handle contextual actions, such as adding items to the utility ring or passing on loot.'] = '处理上下文操作（如向工具环添加物品或对战利品弃权）的按钮。';
L['Button to handle contextual actions, such as adding items to the utility ring.'] = '处理上下文操作（如向工具环添加物品）的按钮。';
L['Button to insert suggested word.'] = '用于插入建议单词的按钮。';
L['Button to move the cursor down.'] = '向下移动光标的按钮。';
L['Button to move the cursor left.'] = '向左移动光标的按钮。';
L['Button to move the cursor right.'] = '向右移动光标的按钮。';
L['Button to move the cursor up.'] = '向上移动光标的按钮。';
L['Button to replicate left click. This is the primary interface action.'] = '复制左键单击的按钮。这是主要的界面操作。';
L['Button to replicate right click. This is the secondary interface action.'] = '复制右键单击的按钮。这是次要的界面操作。';
L['Button to select next suggested word.'] = '选择下一个建议单词的按钮。';
L['Button to select previous suggested word.'] = '选择上一个建议单词的按钮。';
L['Button to use for combo hotkey 1.'] = '用于组合快捷键 1 的按钮。';
L['Button to use for combo hotkey 2.'] = '用于组合快捷键 2 的按钮。';
L['Button to use for combo hotkey 3.'] = '用于组合快捷键 3 的按钮。';
L['Button to use for combo hotkey 4.'] = '用于组合快捷键 4 的按钮。';
L['Button to use for combo hotkey 5.'] = '用于组合快捷键 5 的按钮。';
L['Button to use for combo hotkey 6.'] = '用于组合快捷键 6 的按钮。';
L['Button to use for combo hotkey 7.'] = '用于组合快捷键 7 的按钮。';
L['Button to use for combo hotkey 8.'] = '用于组合快捷键 8 的按钮。';
L['Button to use to erase characters.'] = '用于擦除字符的按钮。';
L['Button to use to move the cursor leftwards.'] = '用于向左移动光标的按钮。';
L['Button to use to move the cursor rightwards.'] = '用于向右移动光标的按钮。';
L['Button to use to trigger the enter command.'] = '用于触发回车命令的按钮。';
L['Button to use to trigger the escape command.'] = '用于触发 Esc 命令的按钮。';
L['Button to use to trigger the space command.'] = '用于触发空格命令的按钮。';
L['Button used to confirm a selected item from a ring.'] = '用于确认从环中选择的物品的按钮。';
L['Button used to remove a selected item from an editable ring.'] = '用于从可编辑环中删除选定物品的按钮。';
L['Button |cFF00FFFF%s|r'] = '按钮 |cFF00FFFF%s|r';
L['Buttons'] = '按钮';
L['Buttons emulating modifiers will instead trigger bindings when pressed and released within the time span.'] = '模拟修饰键的按钮在时间范围内按下并释放时，将触发快捷键。';
L['Buttons in the cluster bar.'] = '集群条中的按钮。';
L['Buttons in the group.'] = '组中的按钮。';
L['By default, shows modifiers on mouseover and on cooldown.'] = '默认情况下，在鼠标悬停和冷却时显示修饰键。';
L['Camera 2D Deadzone'] = '摄像机 2D 死区';
L['Camera Look'] = '摄像机查看';
L['Camera Look is a temporary turn of the camera based on the current analog input.'] = '摄像机查看是基于当前模拟输入的临时摄像机转动。';
L['Camera Pitch Axis'] = '摄像机俯仰轴';
L['Camera Pitch Speed'] = '摄像机俯仰速度';
L['Camera Pitch-Only Deadzone'] = '摄像机仅俯仰死区';
L['Camera speed for pitch - moving up/down.'] = '用于俯仰的摄像机速度 — 上/下移动。';
L['Camera speed for yaw - turning left/right.'] = '用于偏航的摄像机速度 — 左/右转动。';
L['Camera Yaw Axis'] = '摄像机偏航轴';
L['Camera Yaw Speed'] = '摄像机偏航速度';
L['Camera Yaw-Only Deadzone'] = '摄像机仅偏航死区';
L['Cancel and clear cursor'] = '取消并清除光标';
L['Cancel Button'] = '取消按钮';
L['Cannot open configuration menu in combat.'] = '战斗中无法打开配置菜单。';
L['Casting Bar'] = '施法栏';
L['Center Gap'] = '中心间隙';
L['Center gap, as fraction of overall crosshair size.'] = '中心间隙，占整个准星大小的比例。';
L['Change before touchpad moves the cursor.'] = '触摸板移动光标前的阈值。';
L['Change bluetooth state for active device.'] = '更改活动设备的蓝牙状态。';
L['Change how the raid cursor acquires a target. Redirect and focus modes will reroute appropriate spells without changing your target.'] = '更改团队光标获取目标的方式。重定向和焦点模式将重新路由适当的法术而不改变你的目标。';
L['Change or print a value from the active device configuration.'] = '从活动设备配置中更改或打印值。';
L['Character Specific'] = '角色特定';
L['Choose a negative value to invert the axis.'] = '选择负值以反转轴。';
L['Class Bar'] = '职业栏';
L['Class Colored Health'] = '职业颜色生命值';
L['Clear all items from this set.'] = '清除此集合中的所有物品。';
L['Clear Binding'] = '清除快捷键';
L['Clear configured gamepad bindings and reload interface.'] = '清除配置的手柄快捷键并重新加载界面。';
L['Clear Focus Deadzone'] = '清除焦点死区';
L['Clear Focus Mode'] = '清除焦点模式';
L['Clear Focus Time'] = '清除焦点时间';
L['Clear Slot'] = '清除插槽';
L['Clear slot or binding'] = '清除插槽或快捷键';
L['Click here to reset your device profile.'] = '点击此处重置你的设备配置文件。';
L['Click on Down'] = '按下时点击';
L['Click Override Button'] = '点击覆盖按钮';
L['Click Override Condition'] = '点击覆盖条件';
L['Cluster Action Bar'] = '集群动作条';
L['Cluster Handle'] = '集群手柄';
L['Cluster Modifier Toggle'] = '集群修饰键切换';
L['Clusters'] = '集群';
L['Color accent of radial menu items.'] = '径向菜单项的颜色强调。';
L['Color of a partially selected slice.'] = '部分选中的扇区的颜色。';
L['Color of the active slice.'] = '活动扇区的颜色。';
L['Color of the cooldown swipe effect on buttons.'] = '按钮上冷却扫掠效果的颜色。';
L['Color of the counter text on buttons.'] = '按钮上计数器文本的颜色。';
L['Color of the crosshair.'] = '准星的颜色。';
L['Color of the divider.'] = '分隔符的颜色。';
L['Color of the hotkey text on buttons.'] = '按钮上快捷键文本的颜色。';
L['Color of the macro text on buttons.'] = '按钮上宏文本的颜色。';
L['Color of the main XP bar.'] = '主经验条的颜色。';
L['Color of the mana indicator on buttons.'] = '按钮上法力指示器的颜色。';
L['Color of the range indicator on buttons.'] = '按钮上距离指示器的颜色。';
L['Color of the sticky selection slice.'] = '粘性选择扇区的颜色。';
L['Color of the vertices on the border of buttons.'] = '按钮边框顶点的颜色。';
L['Color the health bars in the target ring by class.'] = '按职业为目标环中的生命条着色。';
L['Color tint for combo hotkey 1.'] = '组合快捷键 1 的颜色色调。';
L['Color tint for combo hotkey 2.'] = '组合快捷键 2 的颜色色调。';
L['Color tint for combo hotkey 3.'] = '组合快捷键 3 的颜色色调。';
L['Color tint for combo hotkey 4.'] = '组合快捷键 4 的颜色色调。';
L['Color tint for combo hotkey 5.'] = '组合快捷键 5 的颜色色调。';
L['Color tint for combo hotkey 6.'] = '组合快捷键 6 的颜色色调。';
L['Color tint for combo hotkey 7.'] = '组合快捷键 7 的颜色色调。';
L['Color tint for combo hotkey 8.'] = '组合快捷键 8 的颜色色调。';
L['Combine with '] = '结合 ';
L['Combine with use on demand for full cursor control.'] = '结合「按需使用」以获得完整的光标控制。';
L['Combined Input Overlap Time'] = '组合输入重叠时间';
L['Combo Button 1'] = '组合按钮 1';
L['Combo Button 2'] = '组合按钮 2';
L['Combo Button 3'] = '组合按钮 3';
L['Combo Button 4'] = '组合按钮 4';
L['Combo Button 5'] = '组合按钮 5';
L['Combo Button 6'] = '组合按钮 6';
L['Combo Button 7'] = '组合按钮 7';
L['Combo Button 8'] = '组合按钮 8';
L['Combo Color 1'] = '组合颜色 1';
L['Combo Color 2'] = '组合颜色 2';
L['Combo Color 3'] = '组合颜色 3';
L['Combo Color 4'] = '组合颜色 4';
L['Combo Color 5'] = '组合颜色 5';
L['Combo Color 6'] = '组合颜色 6';
L['Combo Color 7'] = '组合颜色 7';
L['Combo Color 8'] = '组合颜色 8';
L['Command Modifier'] = '命令修饰键';
L['Configure the casting bar.'] = '配置施法栏。';
L['Configure the class related bar.'] = '配置职业相关条。';
L['Connect your controller.'] = '连接你的控制器。';
L['Connected device(s):'] = '已连接的设备：';
L['ConsolePort'] = 'ConsolePort';
L['Context Button'] = '上下文按钮';
L['Controls the cutoff range where an interactable target or object can be found.'] = '控制可以找到可交互目标或对象的截止范围。';
L['Controls when your character starts running. Expressed as a fraction of your total movement stick radius.'] = '控制你的角色何时开始奔跑。表示为你总移动摇杆半径的一部分。';
L['Controls when your character transitions from strafing to facing your movement stick direction while in combat. Expressed in degrees, from looking straight forward.'] = '控制你的角色在战斗中何时从横移过渡到面向你的移动摇杆方向。以度数表示，从直视前方开始。';
L['Controls when your character transitions from strafing to facing your movement stick direction while in the air. Expressed in degrees, from looking straight forward.'] = '控制你的角色在空中时何时从横移过渡到面向你的移动摇杆方向。以度数表示，从直视前方开始。';
L['Controls when your character transitions from strafing to facing your movement stick direction. Expressed in degrees, from looking straight forward.'] = '控制你的角色何时从横移过渡到面向你的移动摇杆方向。以度数表示，从直视前方开始。';
L['Copy %s from %s:'] = '从 %s 复制 %s：';
L['Copy this element to a new name.'] = '将此元素复制为新名称。';
L['Correlation between stick position and pie selection.'] = '摇杆位置与饼形选择之间的相关性。';
L['Create Binding Preset'] = '创建快捷键预设';
L['Critical, Low, Medium, High, Wired/Charging, or Unknown/Disconnected.'] = '紧急、低、中、高、有线/充电中或未知/已断开连接。';
L['Crossbar: Minimal'] = '十字栏：精简';
L['Crossbar: Triggers'] = '十字栏：扳机';
L['Crossbar: Triple'] = '十字栏：三重';
L['Crosshair'] = '准星';
L['Cursor Acceleration'] = '光标加速度';
L['Cursor acceleration for touchpad control.'] = '触摸板控制的光标加速度。';
L['Cursor appears on demand, instead of in response to a panel showing up.'] = '光标按需出现，而不是响应面板出现。';
L['Cursor Center Position'] = '光标中心位置';
L['Cursor hides when you start moving, if free of obstacles.'] = '当你开始移动时，如果没有障碍物，光标会隐藏。';
L['Cursor Max Speed'] = '光标最大速度';
L['Cursor Move Threshold'] = '光标移动阈值';
L['Cursor Reticle Targeting'] = '光标准星目标选择';
L['Cursor Speed'] = '光标速度';
L['Cursor speed for touchpad control.'] = '触摸板控制的光标速度。';
L['Cursor Start Speed'] = '光标起始速度';
L['Custom color to use for the touchpad LED.'] = '用于触摸板 LED 的自定义颜色。';
L['Cyan'] = '青色';
L['Deadzone for simple point-to-select rings.'] = '用于简单点选环的死区。';
L['Deadzone to clear focus after intercepting stick input.'] = '在截获摇杆输入后清除焦点的死区。';
L['Decrease'] = '减少';
L['Decrease lightness'] = '减少亮度';
L['Decrease opacity'] = '减少不透明度';
L['Default to '] = '默认为 ';
L['Delay before reactivating interface cursor after leaving combat, in seconds.'] = '脱离战斗后重新激活界面光标的延迟，以秒为单位。';
L['Delay before starting to adjust angle when camera control is idle, in seconds.'] = '摄像机控制空闲时开始调整角度的延迟，以秒为单位。';
L['Delay is doubled if you are dead.'] = '如果你死亡，延迟会加倍。';
L['Delay until a movement is repeated, when holding down a direction, in seconds.'] = '按住方向时移动重复之前的延迟，以秒为单位。';
L['Delay until the first movement is repeated, when holding down a direction, in seconds.'] = '按住方向时第一次移动重复之前的延迟，以秒为单位。';
L['Delete this element.'] = '删除此元素。';
L['Depth'] = '深度';
L['Depth of the divider.'] = '分隔符的深度。';
L['Detected %d out of 8 possible sensors.'] = '在 8 个可能的传感器中检测到 %d 个。';
L['Detected %d valid button(s).'] = '检测到 %d 个有效按钮。';
L['Device Information'] = '设备信息';
L['Device Mappings'] = '设备映射';
L['Device Profiles'] = '设备配置文件';
L['Device Selection'] = '设备选择';
L['Device Settings'] = '设备设置';
L['Diamond Grid'] = '钻石网格';
L['Dictionary Match Alphabet'] = '字典匹配字母表';
L['Dictionary Match Pattern'] = '字典匹配模式';
L['Direction for flyout buttons, such as portals, poisons, and pet utilities.'] = '弹出按钮的方向，例如门户、毒药和宠物工具。';
L['Direction of the button cluster.'] = '按钮集群的方向。';
L['Disable Drag and Drop'] = '禁用拖放';
L['Disable dragging and dropping abilities on action bars.'] = '禁用在动作条上拖放能力。';
L['Disable free-roaming mouse cursor when you jump.'] = '跳跃时禁用自由漫游鼠标光标。';
L['Disable free-roaming mouse cursor when you use your sticks.'] = '使用摇杆时禁用自由漫游鼠标光标。';
L['Disable Hotkey Rendering'] = '禁用快捷键渲染';
L['Disable if your mouse cursor is invisible.'] = '如果鼠标光标不可见，请禁用。';
L['Disable repeated cursor movements - each click will only move the cursor once.'] = '禁用重复光标移动 — 每次点击只会移动光标一次。';
L['Disable Repeated Movement'] = '禁用重复移动';
L['Disable to use discrete legacy movement controls.'] = '禁用以使用离散的旧版移动控制。';
L['Disable Wrapping'] = '禁用环绕';
L['Disables customization to hotkeys on regular action bars.'] = '禁用常规动作条上的快捷键自定义。';
L['Disabling this may cause worse performance with many panels open.'] = '禁用此功能可能导致打开许多面板时性能下降。';
L['Disconnected'] = '已断开连接';
L['Discord'] = 'Discord';
L['Display icon next to the power level for the current active gamepad.'] = '为当前活动手柄的电量旁边显示图标。';
L['Display power level for the current active gamepad.'] = '显示当前活动手柄的电量。';
L['Display power level status text for the current active gamepad.'] = '显示当前活动手柄的电量状态文本。';
L['Display the action bar grid when picking up a spell on the cursor.'] = '在光标上拾取法术时显示动作条网格。';
L['Displays a briefing for newly acquired abilities.'] = '显示新获得能力的简介。';
L['Divider'] = '分隔符';
L['Do you want to load settings for %s?'] = '你要为 %s 加载设置吗？';
L['Does not affect actual ability to interact with the target, which may have a different range.'] = '不影响实际与目标互动的能力，该能力可能具有不同的范围。';
L['Donate via PayPal'] = '通过 PayPal 捐款';
L['Double Tap Modifier'] = '双击修饰键';
L['Double Tap Timeframe'] = '双击时间范围';
L['Duration after using gamepad and mouse at the same time before switching to just one or the other, in milliseconds.'] = '同时使用手柄和鼠标后切换到其中一个或另一个之前的持续时间，以毫秒为单位。';
L['Duration under which a tooltip is displayed for an acquired target or interactable, in milliseconds.'] = '已获取的目标或可交互物显示提示框的持续时间，以毫秒为单位。';
L['Dynamic Pitch'] = '动态俯仰';
L['Dynamic will use the button set that does not conflict with your '] = '「动态」将使用不与你的 ';
L['E.g. '] = '例如 ';
L['Edit Binding'] = '编辑快捷键';
L['Edit Slot'] = '编辑插槽';
L['Emulate P1 '] = '模拟 P1 ';
L['Emulate P2 '] = '模拟 P2 ';
L['Emulate P3 '] = '模拟 P3 ';
L['Emulate P4 '] = '模拟 P4 ';
L['Emulate Pad 5'] = '模拟 Pad 5';
L['Emulate Pad 6'] = '模拟 Pad 6';
L['Emulate Pad Back'] = '模拟返回键';
L['Emulate Pad Forward'] = '模拟前进键';
L['Emulate Pad Social'] = '模拟社交键';
L['Emulate Pad System'] = '模拟系统键';
L['Enable all modifier states for the cluster, including unmapped modifiers.'] = '为集群启用所有修饰键状态，包括未映射的修饰键。';
L['Enable Animation'] = '启用动画';
L['Enable casting bar ownership.'] = '启用施法栏所有权。';
L['Enable class bar ownership.'] = '启用职业栏所有权。';
L['Enable Cooldown Numbers'] = '启用冷却数字';
L['Enable custom mouse handling, automating cursor toggling and timeout while using left and right mouse button emulation.'] = '启用自定义鼠标处理，在使用左右鼠标按钮模拟时自动化光标切换和超时。';
L['Enable Group Loot'] = '启用组队拾取';
L['Enable interact key to interact with objects and creatures in the game world.'] = '启用互动键以与游戏世界中的对象和生物互动。';
L['Enable interface cursor. Disable to use mouse-based interface interaction.'] = '启用界面光标。禁用以使用基于鼠标的界面互动。';
L['Enable Lazy Loading'] = '启用延迟加载';
L['Enable Mouse Handling'] = '启用鼠标处理';
L['Enable Player Interact'] = '启用玩家互动';
L['Enable Popups'] = '启用弹出窗口';
L['Enable separate strafe angle threshold for when your character is in the air.'] = '为你的角色在空中时启用单独的横移角度阈值。';
L['Enable Strafe Angle (Jump)'] = '启用横移角度 (跳跃)';
L['Enable Tint'] = '启用色调';
L['Enable touch tap to press touchpad buttons.'] = '启用触摸点击以按下触摸板按钮。';
L['Enable Touchpad Cursor'] = '启用触摸板光标';
L['Enable Vehicle'] = '启用载具';
L['Enable Watch Bars'] = '启用监视条';
L['Enables a crosshair to reveal your hidden center cursor position at all times.'] = '启用准星以始终显示你隐藏的中央光标位置。';
L['Enables a radial on-screen keyboard that can be used to type messages.'] = '启用一个可用于输入消息的径向屏幕键盘。';
L['Enemy Soft Targeting'] = '敌方软目标选择';
L['Equippable items of poor quality will not be sold while your character is below this level.'] = '当你的角色低于此等级时，质量差的可装备物品将不会被出售。';
L['Erase'] = '擦除';
L['Exit the vehicle you are currently controlling.'] = '退出你当前控制的载具。';
L['Explicit only matches hard locked targets through using a targeting binding, while implicit matches targets you attack.'] = '显式仅通过使用目标选择快捷键匹配硬锁定的目标，而隐式匹配你攻击的目标。';
L['Export'] = '导出';
L['Export %s to a string:'] = '将 %s 导出为字符串：';
L['Export action page logic'] = '导出动作页面逻辑';
L['Export All'] = '全部导出';
L['Export all your custom presets to a string that can be shared with others.'] = '将你所有的自定义预设导出为可与他人共享的字符串。';
L['Export current options'] = '导出当前选项';
L['Export serialized settings for sharing or backup.'] = '导出序列化设置以共享或备份。';
L['Export this preset to a string that can be shared with others.'] = '将此预设导出为可与他人共享的字符串。';
L['Expressed in milliseconds. Pressing any combination of modifier and button will cancel the effect.'] = '以毫秒表示。按下任何修饰键和按钮的组合将取消效果。';
L['Fade Buttons'] = '淡出按钮';
L['Fade out the pet ring when not moused over.'] = '未鼠标悬停时淡出宠物环。';
L['Fade out the watch bars when not mousing over the toolbar.'] = '未鼠标悬停工具栏时淡出监视条。';
L['Fade Watch Bars'] = '淡出监视条';
L['Filter Condition'] = '过滤条件';
L['Filter condition to find raid cursor frames, as a boolean expression in Lua.'] = '用于查找团队光标框架的过滤条件，作为 Lua 中的布尔表达式。';
L['Flavor'] = '风格';
L['Flyout Direction'] = '弹出方向';
L['FOAS Adjust Delay'] = 'FOAS 调整延迟';
L['FOAS Adjust Ease In'] = 'FOAS 调整淡入';
L['Follow On A Stick (FOAS)'] = 'Follow On A Stick (FOAS)';
L['Font Flags'] = '字体标志';
L['Font flags of the counter text on buttons.'] = '按钮上计数器文本的字体标志。';
L['Font flags of the hotkey text on buttons.'] = '按钮上快捷键文本的字体标志。';
L['Font flags of the macro text on buttons.'] = '按钮上宏文本的字体标志。';
L['Font size of the counter text on buttons.'] = '按钮上计数器文本的字体大小。';
L['Font size of the hotkey text on buttons.'] = '按钮上快捷键文本的字体大小。';
L['Font size of the macro text on buttons.'] = '按钮上宏文本的字体大小。';
L['Font size of the ring slice buttons.'] = '环切片按钮的字体大小。';
L['Force Hard Target'] = '强制硬目标';
L['Frame level of the element.'] = '元素的框架级别。';
L['Frame Level Offset'] = '框架级别偏移';
L['Frame level offset of the hotkey prompt, relative to the unit frame.'] = '快捷键提示相对于单位框架的框架级别偏移。';
L['Frame strata of the element.'] = '元素的框架层级。';
L['Free Cursor Timein'] = '自由光标进入时间';
L['Frees your mouse cursor when used, if the cursor is currently center-fixed or hidden.'] = '使用时释放你的鼠标光标，如果光标当前居中固定或隐藏。';
L['Friend Soft Targeting'] = '友方软目标选择';
L['Full State Modifier'] = '全状态修饰键';
L['Global color of the tint effect on the toolbar and dividers.'] = '工具栏和分隔符上色调效果的全局颜色。';
L['Global Scale'] = '全局缩放';
L['Global Visibility'] = '全局可见性';
L['Green'] = '绿色';
L['Grid'] = '网格';
L['Group buttons by modifier in a diamond layout.'] = '按修饰键以钻石布局对按钮分组。';
L['Group buttons by modifier in a grid layout.'] = '按修饰键以网格布局对按钮分组。';
L['Group buttons for left and right triggers, with modifier swapping.'] = '为左右扳机分组按钮，带修饰键切换。';
L['Group buttons in a single crossbar layout, with modifier swapping.'] = '在单个十字栏布局中分组按钮，带修饰键切换。';
L['Group buttons in three layouts, with modifier swapping.'] = '在三个布局中分组按钮，带修饰键切换。';
L['Groups button combinations in circular clusters which switch between different actions when modifiers are used.'] = '将按钮组合分组到圆形集群中，当使用修饰键时，集群在不同动作之间切换。';
L['Height of the artwork.'] = '美术的高度。';
L['Height of the cluster bar.'] = '集群条的高度。';
L['Height of the crosshair, in scaled pixel units.'] = '准星的高度，以缩放像素单位表示。';
L['Height of the group.'] = '组的高度。';
L['Hide Cursor on Jump'] = '跳跃时隐藏光标';
L['Hide Cursor On Movement'] = '移动时隐藏光标';
L['Hide Cursor on Stick Input'] = '摇杆输入时隐藏光标';
L['Hide Flyout Buttons'] = '隐藏弹出按钮';
L['Hide Macro Text'] = '隐藏宏文本';
L['Hide the class bar.'] = '隐藏职业栏。';
L['Hide the macro text on buttons.'] = '隐藏按钮上的宏文本。';
L['Higher is slower.'] = '值越高越慢。';
L['Higher values appear on top of lower values. Valid range 0-10000.'] = '较高的值显示在较低值之上。有效范围 0-10000。';
L['Highlight Color'] = '高亮颜色';
L['Horizontal Offset'] = '水平偏移';
L['Horizontal offset from anchor point.'] = '锚点的水平偏移。';
L['Horizontal offset of the counter text on buttons.'] = '按钮上计数器文本的水平偏移。';
L['Horizontal offset of the hotkey icon on group buttons.'] = '组按钮上快捷键图标的水平偏移。';
L['Horizontal offset of the hotkey prompt position, in pixels.'] = '快捷键提示位置的水平偏移，以像素为单位。';
L['Horizontal offset of the hotkey text on buttons.'] = '按钮上快捷键文本的水平偏移。';
L['Horizontal offset of the macro text on buttons.'] = '按钮上宏文本的水平偏移。';
L['Horizontal Padding'] = '水平内边距';
L['Hotkey Anchor'] = '快捷键锚点';
L['Hotkey Offset X'] = '快捷键 X 偏移';
L['Hotkey Offset Y'] = '快捷键 Y 偏移';
L['Hotkey prompts appear on applicable name plates.'] = '快捷键提示出现在适用的姓名板上。';
L['Hotkey prompts linger on unit frames after targeting.'] = '目标选择后快捷键提示停留在单位框架上。';
L['Hotkey Relative Anchor'] = '快捷键相对锚点';
L['Hotkey Size'] = '快捷键大小';
L['Hotkeys activate their target immediately.'] = '快捷键立即激活其目标。';
L['Hotkeys always target the same unit.'] = '快捷键始终瞄准同一单位。';
L['Hotkeys control your focus target instead of your current target.'] = '快捷键控制你的焦点目标而不是当前目标。';
L['Hotkeys use '] = '快捷键使用 ';
L['How long the cursor should take to transition from one node to another.'] = '光标从一个节点过渡到另一个节点所需的时间。';
L['How to clear focus after intercepting stick input.'] = '如何在截获摇杆输入后清除焦点。';
L['Import serialized preset(s) from an external source.'] = '从外部源导入序列化预设。';
L['Import serialized preset(s):'] = '导入序列化预设：';
L['Import serialized settings from an external source.'] = '从外部源导入序列化设置。';
L['Inactive Opacity'] = '非活动不透明度';
L['Include the current action page logic in the preset data.'] = '在预设数据中包含当前动作页面逻辑。';
L['Include the current options from the %s tab in the preset data.'] = '在预设数据中包含 %s 选项卡的当前选项。';
L['Increase'] = '增加';
L['Increase lightness'] = '增加亮度';
L['Increase opacity'] = '增加不透明度';
L['Insert Suggestion'] = '插入建议';
L['Intensity'] = '强度';
L['Intensity of the gradient.'] = '渐变的强度。';
L['Interface Cursor'] = '界面光标';
L['Interference'] = '干扰';
L['Inverted'] = '反转';
L['Join Discord'] = '加入 Discord';
L['Keeps your character centered to reduce motion sickness.'] = '保持你的角色居中以减少晕动症。';
L['Key %d'] = '键 %d';
L['Keyboard button to emulate the back button.'] = '用于模拟返回按钮的键盘按键。';
L['Keyboard button to emulate the forward button.'] = '用于模拟前进按钮的键盘按键。';
L['Keyboard button to emulate the pad 5 button.'] = '用于模拟 Pad 5 按钮的键盘按键。';
L['Keyboard button to emulate the pad 6 button.'] = '用于模拟 Pad 6 按钮的键盘按键。';
L['Keyboard button to emulate the social button.'] = '用于模拟社交按钮的键盘按键。';
L['Keyboard button to emulate the system button.'] = '用于模拟系统按钮的键盘按键。';
L['Keyboard'] = '键盘';
L['Keyboard button to emulate the paddle 1 button.'] = '用于模拟拨片 1 按钮的键盘按键。';
L['Keyboard button to emulate the paddle 2 button.'] = '用于模拟拨片 2 按钮的键盘按键。';
L['Keyboard button to emulate the paddle 3 button.'] = '用于模拟拨片 3 按钮的键盘按键。';
L['Keyboard button to emulate the paddle 4 button.'] = '用于模拟拨片 4 按钮的键盘按键。';
L['Keyboard Layout Editor'] = '键盘布局编辑器';
L['Larger value for easier taps.'] = '较大的值便于点击。';
L['Layout'] = '布局';
L['Lazy loading has been disabled to activate the raid cursor.'] = '延迟加载已禁用，以激活团队光标。';
L['Lazy loading has been disabled to activate the target ring.'] = '延迟加载已禁用，以激活目标环。';
L['Lazy loading has been disabled to activate unit hotkeys.'] = '延迟加载已禁用，以激活单位快捷键。';
L['LED Color Type'] = 'LED 颜色类型';
L['LED Custom Color'] = 'LED 自定义颜色';
L['Left mouse button emulation toggles center-fixed mode instead of free-roaming mode. Right mouse button emulation toggles free-roaming mode instead of center-fixed mode.'] = '左鼠标按钮模拟切换居中固定模式而不是自由漫游模式。右鼠标按钮模拟切换自由漫游模式而不是居中固定模式。';
L['Load'] = '加载';
L['Loaded binding preset %s.'] = '已加载快捷键预设 %s。';
L['Loadout'] = '配置';
L['Lock Automatic Tooltip'] = '锁定自动提示框';
L['Looks like a regular action bar, but shows the button combination rather than the action slot.'] = '看起来像常规动作条，但显示按钮组合而不是动作槽。';
L['Lua pattern to match words for dictionary lookups.'] = '用于字典查询匹配单词的 Lua 模式。';
L['Macro condition to automatically load a binding preset by name when the condition applies.'] = '当条件满足时，按名称自动加载快捷键预设的宏条件。';
L['Macro condition to enable the click override button. The default condition clicks right mouse button when there is no enemy target.'] = '启用点击覆盖按钮的宏条件。默认条件是在没有敌方目标时点击右鼠标按钮。';
L['Macro condition to evaluate action bar page.'] = '用于评估动作条页面的宏条件。';
L['Macro condition to override the strafe angle threshold for combat.'] = '用于覆盖战斗横移角度阈值的宏条件。';
L['Macro condition to override the strafe angle threshold for travel.'] = '用于覆盖旅行横移角度阈值的宏条件。';
L['Macro Text'] = '宏文本';
L['Main Button Border Style'] = '主按钮边框样式';
L['Maintain offset relative to scale.'] = '保持相对于缩放的偏移。';
L['Make sure your choice does not conflict with your bindings.'] = '确保你的选择不与你的快捷键冲突。';
L['Make this preset the default layout for all new characters.'] = '将此预设设为所有新角色的默认布局。';
L['Match appropriate soft target to locked target.'] = '将适当的软目标与锁定目标匹配。';
L['Max Pitch'] = '最大俯仰';
L['Max time for a touch to register a tap/click, in milliseconds.'] = '触摸注册为点击/单击的最长时间，以毫秒为单位。';
L['Max Yaw'] = '最大偏航';
L['Maximum Pitch adjust for the camera "look" feature.'] = '摄像机「查看」功能的最大俯仰调整。';
L['Maximum Yaw adjust for the camera "look" feature.'] = '摄像机「查看」功能的最大偏航调整。';
L['Menu buttons to display on the toolbar.'] = '要在工具栏上显示的菜单按钮。';
L['Micro Menu'] = '微型菜单';
L['Minimal Interact Nameplate Tooltip'] = '最小化互动姓名板提示框';
L['Modifications'] = '修改';
L['Modifier'] = '修饰键';
L['Modifier 1: Shift'] = '修饰键 1：Shift';
L['Modifier 2: Ctrl'] = '修饰键 2：Ctrl';
L['Modifier 3: Alt'] = '修饰键 3：Alt';
L['Modifier Tap Window'] = '修饰键点击窗口';
L['Modifiers'] = '修饰键';
L['Modifiers should be in descending order. M2M1, for example, is the Ctrl and Shift modifiers held at the same time.'] = '修饰键应按降序排列。例如，M2M1 是同时按下的 Ctrl 和 Shift 修饰键。';
L['Move Left'] = '向左移动';
L['Move one of the sticks.'] = '移动其中一个摇杆。';
L['Move Right'] = '向右移动';
L['Move the frame with the sticks or the mouse. Confirm to save, cancel to restore.'] = '使用摇杆或鼠标移动框体。确认以保存，取消以恢复。';
L['Movement Deadzone'] = '移动死区';
L['Movement is analog, translated from your movement stick angle.'] = '移动是模拟的，从你的移动摇杆角度转换。';
L['Movement X Axis'] = '移动 X 轴';
L['Movement Y Axis'] = '移动 Y 轴';
L['Needs to be long enough to press and release the button.'] = '需要足够长以按下并释放按钮。';
L['Nested Rings'] = '嵌套环';
L['Next Word'] = '下一个单词';
L['No axis input detected yet.'] = '尚未检测到轴输入。';
L['No binding preset named %s exists.'] = '不存在名为 %s 的快捷键预设。';
L['No button input detected yet.'] = '尚未检测到按钮输入。';
L['No buttons were detected during the test.'] = '测试期间未检测到按钮。';
L['No sensors were detected.'] = '未检测到传感器。';
L['Normal background color of pie slices.'] = '饼图扇区的正常背景颜色。';
L['Normal Color'] = '正常颜色';
L['Nudge Modifier'] = '推动修饰键';
L['Number of buttons in the page.'] = '页面中的按钮数。';
L['Number of buttons per row or column.'] = '每行或每列的按钮数。';
L['Offset'] = '偏移';
L['Offset of pointer arrow, from the selected node center, in pixels.'] = '指针箭头相对于所选节点中心的偏移，以像素为单位。';
L['Offset X'] = 'X 偏移';
L['Offset Y'] = 'Y 偏移';
L['Offsets the camera horizontally from your character, for a more cinematic view.'] = '将摄像机水平偏移于你的角色，以获得更具电影感的视角。';
L['Only recommended for super users.'] = '仅建议超级用户使用。';
L['Only use taps for cursor clicks, do not use tap presses.'] = '仅将点击用于光标点击，不要使用点击按下。';
L['Opacity is expressed in percentage, where 100 is fully visible and 0 is fully transparent. Values outside of the 0-100 range will be clamped.'] = '不透明度以百分比表示，其中 100 完全可见，0 完全透明。0-100 范围外的值将被钳制。';
L['Opacity of inactive hotkey prompts on unit frames after targeting.'] = '目标选择后单位框架上非活动快捷键提示的不透明度。';
L['Open Designer'] = '打开设计器';
L['Open Main Config'] = '打开主配置';
L['Open the configuration menu for the action bar.'] = '打开动作条的配置菜单。';
L['Open the main configuration window.'] = '打开主配置窗口。';
L['Open the main edit mode window.'] = '打开主编辑模式窗口。';
L['Open the unit menu for the target unit.'] = '打开目标单位的单位菜单。';
L['Open unit menu when interacting with other players.'] = '与其他玩家互动时打开单位菜单。';
L['Optimize Algorithm'] = '优化算法';
L['or'] = '或';
L['Orientation of the page.'] = '页面方向。';
L['Orthodox'] = '正统';
L['Out of Mana Color'] = '法力耗尽颜色';
L['Out of Range Color'] = '超出范围颜色';
L['Outcome'] = '结果';
L['Over Shoulder'] = '肩部上方';
L['Override'] = '覆盖';
L['Override Class File'] = '覆盖职业文件';
L['Override class theme for interface styling.'] = '覆盖职业主题以进行界面样式设置。';
L['Padding between buttons horizontally.'] = '按钮之间的水平内边距。';
L['Padding between buttons vertically.'] = '按钮之间的垂直内边距。';
L['Page'] = '页面';
L['Page Condition'] = '页面条件';
L['Page Hotkeys'] = '页面快捷键';
L['Page Response'] = '页面响应';
L['Page |cFF00FFFF%s|r'] = '页面 |cFF00FFFF%s|r';
L['Patreon'] = 'Patreon';
L['PayPal'] = 'PayPal';
L['Performs an action and closes the menu.'] = '执行操作并关闭菜单。';
L['Performs an action without closing the menu.'] = '执行操作而不关闭菜单。';
L['Pet Ring'] = '宠物环';
L['Pet Ring Position'] = '宠物环位置';
L['Pet Ring Stick'] = '宠物环摇杆';
L['Pick up'] = '拾取';
L['Pickup'] = '拾取';
L['Pitch Axis'] = '俯仰轴';
L['Pitch-only deadzone for camera, applied before the 2D deadzone.'] = '摄像机的仅俯仰死区，在 2D 死区之前应用。';
L['Pitches the camera upwards as you zoom out.'] = '缩小时向上倾斜摄像机。';
L['Place in slot'] = '放入插槽';
L['Place on action bar'] = '放置在动作条上';
L['Play a sound when the pointer arrow reaches its destination.'] = '当指针箭头到达目的地时播放声音。';
L['Please provide a unique name for a new %s in %s:'] = '请为 %s 中的新 %s 提供一个唯一的名称：';
L['Plural Button'] = '复数按钮';
L['Pointer arrow rotates in the direction of travel, and portraits scale up and down on movement.'] = '指针箭头朝行进方向旋转，肖像在移动时放大和缩小。';
L['Pointer arrow rotates in the direction of travel.'] = '指针箭头朝行进方向旋转。';
L['Pointer Offset'] = '指针偏移';
L['Pointer Size'] = '指针大小';
L['Position'] = '位置';
L['Position of the artwork.'] = '美术的位置。';
L['Position of the button cluster.'] = '按钮集群的位置。';
L['Position of the button.'] = '按钮的位置。';
L['Position of the class bar.'] = '职业栏的位置。';
L['Position of the cluster bar.'] = '集群条的位置。';
L['Position of the divider.'] = '分隔符的位置。';
L['Position of the element.'] = '元素的位置。';
L['Position of the group.'] = '组的位置。';
L['Position of the page.'] = '页面的位置。';
L['Position of the pet ring.'] = '宠物环的位置。';
L['Position of the toolbar.'] = '工具栏的位置。';
L['Power Level'] = '电池电量';
L['Preferred size of radial menus, in pixels.'] = '径向菜单的首选大小，以像素为单位。';
L['Preset Load Condition'] = '预设加载条件';
L['Presets'] = '预设';
L['Press and Hold'] = '按住';
L['Press your gamepad buttons to test them.'] = '按下你的手柄按钮以测试它们。';
L['Prevent the cursor from wrapping when navigating.'] = '防止光标在导航时环绕。';
L['Previous Word'] = '上一个单词';
L['Primary accept button, to use or confirm a quick menu action.'] = '主接受按钮，用于使用或确认快捷菜单操作。';
L['Primary Button'] = '主按钮';
L['Primary Stick'] = '主摇杆';
L['Prioritize raid cursor bindings over other override bindings.'] = '优先考虑团队光标快捷键而非其他覆盖快捷键。';
L['Priority Override'] = '优先级覆盖';
L['Purple'] = '紫色';
L['Quick Menu'] = '快捷菜单';
L['Radial Menus'] = '径向菜单';
L['Raid Cursor'] = '团队光标';
L['Re-apply config for the active device.'] = '为活动设备重新应用配置。';
L['Reactivation Delay'] = '重新激活延迟';
L['Realm'] = '服务器';
L['Recharge'] = '充能';
L['Recommended as first choice modifier.'] = '推荐作为第一选择修饰键。';
L['Recommended as second choice modifier.'] = '推荐作为第二选择修饰键。';
L['Reduces unexpected camera movement to reduce motion sickness.'] = '减少意外的摄像机移动以减少晕动症。';
L['Regenerate Dictionary'] = '重新生成字典';
L['Regular'] = '常规';
L['Relative Anchor'] = '相对锚点';
L['Relative anchor point of the counter text on buttons.'] = '按钮上计数器文本的相对锚点。';
L['Relative anchor point of the hotkey icon on group buttons.'] = '组按钮上快捷键图标的相对锚点。';
L['Relative anchor point of the hotkey text on buttons.'] = '按钮上快捷键文本的相对锚点。';
L['Relative anchor point of the macro text on buttons.'] = '按钮上宏文本的相对锚点。';
L['Relative Rescale'] = '相对重新缩放';
L['Reload'] = '重新加载';
L['Remove all saved settings and bindings, disable addon, and reload interface.'] = '移除所有已保存的设置和快捷键，禁用插件并重新加载界面。';
L['Remove all saved settings and reload interface.'] = '移除所有已保存的设置并重新加载界面。';
L['Remove Button'] = '移除按钮';
L['Remove from %s'] = '从 %s 移除';
L['Remove this set. This action cannot be undone.'] = '移除此集合。此操作无法撤消。';
L['Removes the tooltip background for a minimalistic look.'] = '移除提示框背景以获得简约外观。';
L['Repeated Movement Delay'] = '重复移动延迟';
L['Repeated Movement First Delay'] = '重复移动首次延迟';
L['Replaces the default loot frame with a custom version optimized for controller navigation.'] = '用针对控制器导航优化的自定义版本替换默认拾取框架。';
L['Request early landing from the taxi you are currently riding.'] = '请求从你当前乘坐的出租车提前降落。';
L['Requires /reload to fully unhook when disabled.'] = '禁用时需要 /reload 才能完全解除。';
L['Requires a touchpad with LED support.'] = '需要支持 LED 的触摸板。';
L['Requires reload.'] = '需要重新加载。';
L['Requires Settings > Hide Cursor on Stick Input set to None.'] = '需要将设置 > 「摇杆输入时隐藏光标」设为「无」。';
L['Requires Toggle Interface Cursor binding to use the cursor.'] = '需要「切换界面光标」快捷键才能使用光标。';
L['Reset all mapping configurations and reload. (will not affect bindings)'] = '重置所有映射配置并重新加载。(不会影响快捷键)';
L['Response to condition for custom processing.'] = '条件响应，用于自定义处理。';
L['Reticle targeting means anything you place on the ground.'] = '准星目标选择意味着你放在地上的任何东西。';
L['Reticle targeting uses free cursor instead of staying center-fixed.'] = '准星目标选择使用自由光标而不是保持中心固定。';
L['Return Button'] = '返回按钮';
L['Returns to the previous menu.'] = '返回上一菜单。';
L['Reverse Mouse Handling'] = '反转鼠标处理';
L['Reverse Order'] = '反转顺序';
L['Reverse the order of the buttons.'] = '反转按钮的顺序。';
L['Ring Manager'] = '环管理器';
L['Ring Scale'] = '环缩放';
L['Ring Size'] = '环大小';
L['Rings'] = '环';
L['Rings (Account)'] = '环（账户）';
L['Rings (Character)'] = '环（角色）';
L['Rotation'] = '旋转';
L['Rotation of the divider.'] = '分隔符的旋转。';
L['Run / Walk Threshold'] = '奔跑/行走阈值';
L['Run Tests'] = '运行测试';
L['Save as default'] = '保存为默认';
L['Save preset from %s:'] = '从 %s 保存预设：';
L['Save your current loadout to the preset list.'] = '将你当前的配置保存到预设列表。';
L['Scale of all radial menus, relative to UI scale.'] = '所有径向菜单的缩放，相对于 UI 缩放。';
L['Scale of most ConsolePort frames, relative to UI scale.'] = '大多数 ConsolePort 框架的缩放，相对于 UI 缩放。';
L['Scale of the cursor.'] = '光标的缩放。';
L['Scale of the game menu and radial companion.'] = '游戏菜单和径向伴侣的缩放。';
L['Scale of the keyboard.'] = '键盘的缩放。';
L['Scale of the pet ring.'] = '宠物环的缩放。';
L['Screen position of the ring.'] = '环形菜单在屏幕上的位置。';
L['Secondary accept button, to use or confirm a quick menu action.'] = '次要接受按钮，用于使用或确认快捷菜单操作。';
L['Select a device from the list to continue.'] = '从列表中选择一个设备以继续。';
L['Select a slot to bind %s and place this spell.'] = '选择一个插槽以绑定 %s 并放置此法术。';
L['Select a slot to place this spell.'] = '选择一个插槽以放置此法术。';
L['Select the device you want to configure.'] = '选择你要配置的设备。';
L['Select the device you want to use.'] = '选择你要使用的设备。';
L['Selecting an item on a ring will stick until another item is chosen.'] = '在环上选择项目将保持粘性，直到选择另一个项目。';
L['Sensors'] = '传感器';
L['Set %d |cFF757575(%s)|r'] = '集合 %d |cFF757575(%s)|r';
L['Set binding'] = '设置快捷键';
L['Sets if range should be a hard cutoff, even for something you can interact with.'] = '设置范围是否应为硬截止，即使对于你可以与之交互的东西。';
L['Shift-click to Edit Binding'] = '按住 Shift 并点击以编辑快捷键';
L['Shift-right-click to Clear Binding'] = '按住 Shift 并右键点击以清除快捷键';
L['Show a color tint on the toolbar.'] = '在工具栏上显示色调。';
L['Show Ability Briefings'] = '显示能力简介';
L['Show Action Bar Grid on Spell Pickup'] = '拾取法术时显示动作条网格';
L['Show active buffs in the quick menu.'] = '在快捷菜单中显示活动增益。';
L['Show active debuffs in the quick menu.'] = '在快捷菜单中显示活动减益。';
L['Show All Action Bars'] = '显示所有动作条';
L['Show all enabled combinations in the cluster at all times.'] = '始终在集群中显示所有启用的组合。';
L['Show bonus bar configuration for characters without stances.'] = '为没有姿态的角色显示奖励条配置。';
L['Show Centered Cursor Tooltip'] = '显示居中光标提示框';
L['Show connected devices.'] = '显示已连接的设备。';
L['Show Default Button'] = '显示默认按钮';
L['Show Enemy Nameplate'] = '显示敌方姓名板';
L['Show Enemy Target Icon'] = '显示敌方目标图标';
L['Show Enemy Tooltip'] = '显示敌方提示框';
L['Show Flyout Buttons'] = '显示弹出按钮';
L['Show Flyouts'] = '显示弹出菜单';
L['Show Friendly Nameplate'] = '显示友方姓名板';
L['Show Friendly Target Icon'] = '显示友方目标图标';
L['Show Friendly Tooltip'] = '显示友方提示框';
L['Show Gauge'] = '显示仪表';
L['Show group loot rolls in the quick menu, allowing you to roll on items using gamepad buttons while in combat.'] = '在快捷菜单中显示组队拾取掷骰，允许你在战斗中使用手柄按钮对物品掷骰。';
L['Show help for command(s).'] = '显示命令的帮助。';
L['Show Hotkeys'] = '显示快捷键';
L['Show icon above the current enemy soft target.'] = '在当前敌方软目标上方显示图标。';
L['Show icon above the current friendly soft target.'] = '在当前友方软目标上方显示图标。';
L['Show icon above the current interactable object.'] = '在当前可交互对象上方显示图标。';
L['Show icon above the current interactable target.'] = '在当前可交互目标上方显示图标。';
L['Show interact binding hint on interactables.'] = '在可交互物上显示互动快捷键提示。';
L['Show Interact Hint'] = '显示互动提示';
L['Show interact tooltip on nameplates, when applicable.'] = '在适用时在姓名板上显示互动提示框。';
L['Show item type in the quick menu.'] = '在快捷菜单中显示物品类型。';
L['Show Main Icons'] = '显示主图标';
L['Show Modifier Icons'] = '显示修饰键图标';
L['Show numerical cooldown text on buttons.'] = '在按钮上显示数字冷却时间文本。';
L['Show Object Icon'] = '显示对象图标';
L['Show on Name Plates'] = '显示在姓名板上';
L['Show pet action bar in the quick menu.'] = '在快捷菜单中显示宠物动作条。';
L['Show ping commands in the quick menu.'] = '在快捷菜单中显示 ping 命令。';
L['Show Portrait'] = '显示肖像';
L['Show portrait for the current unit, with health percentage and applicable spell casts.'] = '为当前单位显示肖像，附带生命值百分比和适用的法术施放。';
L['Show Status Text'] = '显示状态文本';
L['Show Target Icon'] = '显示目标图标';
L['Show the default mouse action button.'] = '显示默认鼠标动作按钮。';
L['Show the empty buttons in the page.'] = '在页面中显示空按钮。';
L['Show the flyout of small buttons for the button cluster.'] = '为按钮集群显示小按钮弹出菜单。';
L['Show the hotkeys on the buttons.'] = '在按钮上显示快捷键。';
L['Show the icons for main buttons.'] = '显示主按钮的图标。';
L['Show the icons for modifier buttons.'] = '显示修饰键按钮的图标。';
L['Show the pet power and health status.'] = '显示宠物的力量和生命值状态。';
L['Show the pet ring when in a vehicle.'] = '在载具中时显示宠物环。';
L['Show the watch bars at the bottom of the toolbar.'] = '在工具栏底部显示监视条。';
L['Show Tooltip'] = '显示提示框';
L['Show tooltip for enemy target.'] = '显示敌方目标的提示框。';
L['Show tooltip for friendly target.'] = '显示友方目标的提示框。';
L['Show tooltip for interactables.'] = '显示可交互物的提示框。';
L['Show tooltip for mouseover targets when cursor is centered.'] = '光标居中时显示鼠标悬停目标的提示框。';
L['Show tooltips on buttons when moused over.'] = '鼠标悬停时在按钮上显示提示框。';
L['Show Type Icon'] = '显示类型图标';
L['Size of pointer arrow, in pixels.'] = '指针箭头的大小，以像素为单位。';
L['Size of the button cluster.'] = '按钮集群的大小。';
L['Size of the hotkey icon on group buttons.'] = '组按钮上快捷键图标的大小。';
L['Size of unit hotkeys, in pixels.'] = '单位快捷键的大小，以像素为单位。';
L['Space'] = '空格';
L['Speed of cursor when it starts moving.'] = '光标开始移动时的速度。';
L['Split stack'] = '拆分堆叠';
L['Start moving the configuration window.'] = '开始移动配置窗口。';
L['Starting point of the page.'] = '页面的起始点。';
L['Status Bar'] = '状态栏';
L['Stick to use for main radial actions.'] = '用于主要径向操作的摇杆。';
L['Stick to use for the pet ring. Default follows the radial menu primary stick.'] = '宠物环使用的摇杆。默认跟随径向菜单的主摇杆。';
L['Stick to use for this ring. Default follows the radial menu primary stick.'] = '此环形菜单使用的摇杆。默认跟随径向菜单的主摇杆。';
L['Sticky Color'] = '粘性颜色';
L['Sticky Selection'] = '粘性选择';
L['Strafe Angle (Combat)'] = '横移角度 (战斗)';
L['Strafe Angle (Jump)'] = '横移角度 (跳跃)';
L['Strafe Angle (Travel)'] = '横移角度 (旅行)';
L['Strafe Angle Macro Condition (Combat)'] = '横移角度宏条件 (战斗)';
L['Strafe Angle Macro Condition (Travel)'] = '横移角度宏条件 (旅行)';
L['Strata'] = '层级';
L['Stride'] = '步幅';
L['Style of the border around main buttons.'] = '主按钮周围的边框样式。';
L['Support on Patreon'] = '在 Patreon 上支持';
L['Swap to a specified action bar layout.'] = '切换到指定的动作条布局。';
L['Swipe Color'] = '扫掠颜色';
L['Switch Button'] = '切换按钮';
L['Switches between the main menu and the radial companion.'] = '在主菜单和径向伴侣之间切换。';
L['Synchronize Bindings'] = '同步快捷键';
L['Synchronize Config'] = '同步配置';
L['Take ownership of, and move the micro menu buttons to the toolbar.'] = '接管并将微型菜单按钮移动到工具栏。';
L['Takes the format of...\n|cFF3FC7EB[condition] Preset Name; nil|r\n\nAuto-saved presets are named "Character (Specialization) Realm", using class instead of specialization on Classic.\n\nThe preset loads outside of combat when the condition applies. Character presets take precedence over device presets.'] = [[格式为...
|cFF3FC7EB[条件] 预设名称; nil|r

自动保存的预设名为"角色 (专精) 服务器"，怀旧服使用职业代替专精。

条件满足时会在脱离战斗后加载预设。角色预设优先于设备预设。]];
L['Taps for cursor clicks are right clicks instead of left.'] = '光标点击的点击是右键点击而不是左键。';
L['Target enemies automatically by looking at them.'] = '通过查看自动选择敌人。';
L['Target friends automatically by looking at them.'] = '通过查看自动选择朋友。';
L['Target Match Lock'] = '目标匹配锁定';
L['Target Range'] = '目标范围';
L['Target Range Hard Cutoff'] = '目标范围硬截止';
L['Target Ring'] = '目标环';
L['Targeting Mode'] = '目标选择模式';
L['Test Device'] = '测试设备';
L['The analog input for forward/back movement.'] = '前进/后退移动的模拟输入。';
L['The analog input for left/right Camera Yaw "look" feature.'] = '左/右摄像机偏航「查看」功能的模拟输入。';
L['The analog input for left/right Camera Yaw.'] = '左/右摄像机偏航的模拟输入。';
L['The analog input for left/right movement.'] = '左/右移动的模拟输入。';
L['The analog input for up/down Camera Pitch "look" feature.'] = '上/下摄像机俯仰「查看」功能的模拟输入。';
L['The analog input for up/down Camera Pitch.'] = '上/下摄像机俯仰的模拟输入。';
L['The configuration is accessible by the chat command %s or from the game menu.'] = '可以通过聊天命令 %s 或从游戏菜单访问配置。';
L['The modifier can be used to nudge the cursor position with the directional pad.'] = '修饰键可用于通过方向键推动光标位置。';
L['The modifier can be used to scroll together with the directional pad.'] = '修饰键可与方向键一起用于滚动。';
L['The quick menu binding can be used to close the menu as well.'] = '快捷菜单快捷键也可用于关闭菜单。';
L['The time it takes to transition from idle camera control to auto-adjustment (FOAS).'] = '从空闲摄像机控制过渡到自动调整 (FOAS) 所需的时间。';
L['Thickness'] = '厚度';
L['Thickness in scaled pixel units.'] = '厚度，以缩放像素单位表示。';
L['Thickness of the divider.'] = '分隔符的厚度。';
L['This button is necessary to use or sell an item directly from your bags.'] = '此按钮是直接从你的背包使用或出售物品所必需的。';
L['This feature is only available in Classic.'] = '此功能仅在 Classic 中可用。';
L['This only affects gamepad bindings.'] = '这只影响手柄快捷键。';
L['This will not affect your bindings, interface settings or system-wide settings.'] = '这不会影响你的快捷键、界面设置或系统范围的设置。';
L['This will not work with Xbox controllers connected via bluetooth. The Xbox Adapter is required.'] = '这不适用于通过蓝牙连接的 Xbox 控制器。需要 Xbox 适配器。';
L['Time in milliseconds for the opacity to change from one state to another.'] = '不透明度从一种状态变为另一种状态的时间，以毫秒为单位。';
L['Time in seconds to automatically hide centered cursor.'] = '自动隐藏居中光标的时间，以秒为单位。';
L['Time in seconds to enable free cursor.'] = '启用自由光标的时间，以秒为单位。';
L['Time to clear focus after intercepting stick input, in seconds.'] = '截获摇杆输入后清除焦点的时间，以秒为单位。';
L['Timeframe to catch a binding in the configuration, in seconds.'] = '在配置中捕获快捷键的时间范围，以秒为单位。';
L['Timeframe to toggle the mouse cursor when double-tapping a selected modifier.'] = '双击选定修饰键时切换鼠标光标的时间范围。';
L['Timeout clears focus after a set time, deadzone clears focus when stick input is neutral.'] = '超时在设定的时间后清除焦点，死区在摇杆输入为中性时清除焦点。';
L['Tint Color'] = '色调颜色';
L['Toggle visibility of all modifier flyouts for cluster action bars.'] = '切换集群动作条所有修饰键弹出菜单的可见性。';
L['Toggle visibility of all modifier flyouts.'] = '切换所有修饰键弹出菜单的可见性。';
L['Toolbar'] = '工具栏';
L['Tooltip'] = '提示框';
L['Top speed of cursor movement.'] = '光标移动的最高速度。';
L['Touch Tap Buttons'] = '触摸点击按钮';
L['Touch Tap Exclusive Click'] = '触摸点击独占点击';
L['Touch Tap Max Time'] = '触摸点击最大时间';
L['Touch Tap Right Click'] = '触摸点击右键';
L['Touchpad'] = '触摸板';
L['Transition'] = '过渡';
L['Transition time for opacity changes.'] = '不透明度变化的过渡时间。';
L['Travel Time'] = '行进时间';
L['Trigger button actions on press instead of release.'] = '在按下而不是释放时触发按钮操作。';
L['Triggers'] = '扳机';
L['Turn Character With Camera'] = '用摄像机转动角色';
L['Turn your character facing when you turn your camera angle.'] = '当你转动摄像机角度时，转动你的角色面向方向。';
L['Type of LED color to use for the touchpad.'] = '用于触摸板的 LED 颜色类型。';
L['Types are PlayStation, Xbox, or Generic.'] = '类型为 PlayStation、Xbox 或通用。';
L['Unit Hotkeys'] = '单位快捷键';
L['Unit Pool'] = '单位池';
L['Units to watch, as lists of unit tokens selected by macro conditions. Use [] for the unconditional fallback.'] = '要监视的单位，以宏条件选择的单位标记列表形式。使用 [] 作为无条件回退。';
L['Unknown device selected.'] = '选择了未知设备。';
L['Unlimited Navigation'] = '无限导航';
L['Unmapped keyboard key(s) detected:'] = '检测到未映射的键盘按键：';
L['Use a custom set of buttons for the game menu, otherwise the button set will be dynamically determined.'] = '为游戏菜单使用自定义按钮集，否则按钮集将动态确定。';
L['Use a shoulder button combined with crosshair for smooth and precise interactions. The click is performed at crosshair or cursor location.'] = '使用肩部按钮结合准星实现平滑精确的互动。点击在准星或光标位置执行。';
L['Use a targeting binding to turn a soft target into a hard target.'] = '使用目标选择快捷键将软目标转换为硬目标。';
L['Use character specific addon settings for this character.'] = '为此角色使用角色特定的插件设置。';
L['Use Custom Button Set'] = '使用自定义按钮集';
L['Use Custom Loot Frame'] = '使用自定义拾取框架';
L['Use Default Hotkey Icons'] = '使用默认快捷键图标';
L['Use Focus Mode'] = '使用焦点模式';
L['Use global game tooltip for loot information, allowing other addons to add information to lootable items.'] = '为拾取信息使用全局游戏提示框，允许其他插件向可拾取物品添加信息。';
L['Use Global Loot Tooltip'] = '使用全局拾取提示框';
L['Use Hardware Mouse Cursor'] = '使用硬件鼠标光标';
L['Use Instant Mode'] = '使用即时模式';
L['Use Interact Nameplate Tooltip'] = '使用互动姓名板提示框';
L['Use On Demand'] = '按需使用';
L['Use optimized pathfinding algorithm for cursor movement.'] = '为光标移动使用优化的寻路算法。';
L['Use press and hold to navigate and use rings. Press, point, release.'] = '使用按住进行导航和使用环。按住、指向、释放。';
L['Use Static Mode'] = '使用静态模式';
L['Use the hardware cursor provided by the operating system.'] = '使用操作系统提供的硬件光标。';
L['Use together with [@cursor] macros to place reticle spells in a single click.'] = '与 [@cursor] 宏一起使用，单击放置准星法术。';
L['Used for interacting with the world, at a center-fixed position.'] = '用于在中心固定位置与世界互动。';
L['Uses global tint color when transparent.'] = '透明时使用全局色调颜色。';
L['Uses the default hotkey icons instead of the custom icons provided by ConsolePort.'] = '使用默认快捷键图标而不是 ConsolePort 提供的自定义图标。';
L['Valid Action Deadzone'] = '有效动作死区';
L['Value below two may appear interlaced or not at all.'] = '低于二的值可能显示为隔行扫描或完全不显示。';
L['Vertical Offset'] = '垂直偏移';
L['Vertical offset from anchor point.'] = '锚点的垂直偏移。';
L['Vertical offset of the counter text on buttons.'] = '按钮上计数器文本的垂直偏移。';
L['Vertical offset of the hotkey icon on group buttons.'] = '组按钮上快捷键图标的垂直偏移。';
L['Vertical offset of the hotkey prompt position, in pixels.'] = '快捷键提示位置的垂直偏移，以像素为单位。';
L['Vertical offset of the hotkey text on buttons.'] = '按钮上快捷键文本的垂直偏移。';
L['Vertical offset of the macro text on buttons.'] = '按钮上宏文本的垂直偏移。';
L['Vertical Padding'] = '垂直内边距';
L['Vertical position of centered cursor & targeting, as fraction of screen height.'] = '居中光标和目标选择的垂直位置，作为屏幕高度的比例。';
L['Visibility Condition'] = '可见性条件';
L['Watch bars include XP, reputation, honor, artifact power, and azerite.'] = '监视条包括经验值、声望、荣誉、神器之力和艾泽里特。';
L['When disabled, a button press will also act as a cursor click.'] = '禁用时，按下按钮也会作为光标点击。';
L['When disabled, you will need to press the accept button to confirm a selection.'] = '禁用时，你需要按下接受按钮以确认选择。';
L['When enabled, a tap will act as a button press.'] = '启用时，点击将作为按下按钮。';
L['When set to both sticks, cursor only disables when both sticks are used together.'] = '设置为两个摇杆时，只有同时使用两个摇杆时光标才会禁用。';
L['Whether client keybindings should be saved to the server.'] = '客户端按键绑定是否应保存到服务器。';
L['Whether the keyboard should always be shown or only when a gamepad is active.'] = '键盘是否应始终显示，或仅在手柄处于活动状态时显示。';
L['Whether to save character- and account-scoped variables to the server.'] = '是否将角色和账户范围的变量保存到服务器。';
L['Which button set to use for unit hotkeys.'] = '用于单位快捷键的按钮集。';
L['Which modifier to use for modified commands.'] = '用于修改命令的修饰键。';
L['Which modifier to use for nudging the cursor.'] = '用于推动光标的修饰键。';
L['Which modifier to use to toggle the mouse cursor when double-tapped.'] = '双击时用于切换鼠标光标的修饰键。';
L['Which modifier to use with the movement buttons to move the cursor.'] = '用于与移动按钮一起移动光标的修饰键。';
L['While disabled, cursor timeout, and toggling between free-roaming and center-fixed cursor are also disabled.'] = '禁用时，光标超时以及自由漫游和居中固定光标之间的切换也被禁用。';
L['While held down, can simulate dragging by clicking on the directional pad.'] = '按住时，可以通过点击方向键模拟拖拽。';
L['Width of the artwork.'] = '美术的宽度。';
L['Width of the cluster bar.'] = '集群条的宽度。';
L['Width of the crosshair, in scaled pixel units.'] = '准星的宽度，以缩放像素单位表示。';
L['Width of the group.'] = '组的宽度。';
L['Width of the toolbar.'] = '工具栏的宽度。';
L['Wipe Dictionary'] = '清除字典';
L['Wired'] = '有线';
L['Works like a regular action bar, which displays the action slots of a specified action page.'] = '像常规动作条一样工作，显示指定动作页面的动作槽。';
L['X Offset'] = 'X 偏移';
L['XP Bar Color'] = '经验条颜色';
L['Y Offset'] = 'Y 偏移';
L['Yaw Axis'] = '偏航轴';
L['Yaw-only deadzone for camera, applied before the 2D deadzone.'] = '摄像机的仅偏航死区，在 2D 死区之前应用。';
L['your current loadout'] = '你当前的配置';
---------------------------------------------------------------
-- Literal block entries
---------------------------------------------------------------
L['%s is already bound to\n%s\n\nDo you want to change it to\n%s?'] = [[%s 已绑定到
%s

你要将其更改为
%s 吗？]];
L['+ Normal\n- Inverted'] = [[+ 正常
- 反转]];
L['Takes the format of...\n'] = [[格式为...
]];
L['The bindings underlying the button combinations will be unavailable while the cursor is in use.\n\nModifier can also be configured on a per button basis.'] = [[光标使用时，按钮组合的底层快捷键将不可用。

修饰键也可以按按钮配置。]];
L['When set to zero, always face your movement stick direction.\nWhen set to max, never face your movement stick direction.'] = [[设置为零时，始终面向你的移动摇杆方向。
设置为最大时，永远不要面向你的移动摇杆方向。]];
L['Your %s device has separate handling for Bluetooth and wired connection.\nWhich one are you using?'] = [[你的 %s 设备对蓝牙和有线连接有单独的处理方式。
你正在使用哪一种？]];
