local L = select(2, ...).Locale;
---------------------------------------------------------------
-- koKR 한국어 Korean
---------------------------------------------------------------
---------------------------------------------------------------
-- Short / curated keys
---------------------------------------------------------------
L.ACTIONBAR_FORM_ACTIVE_DESC  = '이 변신은 현재 활성 상태이며, 주 행동 단축바가 관련 능력을 표시하고 있습니다.'; -- en:b400a632
L.DESC_CAMERAZOOMIN           = '카메라를 확대합니다. 연속 확대하려면 길게 누르십시오.'; -- en:55f9b91f
L.DESC_CAMERAZOOMOUT          = '카메라를 축소합니다. 연속 축소하려면 길게 누르십시오.'; -- en:a6b9d796
L.DESC_OPENALLBAGS            = '모든 가방을 열고 닫습니다.'; -- en:4a74797f
L.DESC_RING_TARGET            = '유닛 풀을 원형 메뉴로 표시하여 방사형 스틱으로 유닛을 대상으로 지정할 수 있습니다.'; -- en:294b636e
L.DESC_TOGGLEWORLDMAP_CLASSIC = '세계 지도를 전환합니다.'; -- en:00548e70
L.DESC_TOGGLEWORLDMAP_RETAIL  = '통합 세계 지도와 퀘스트 기록을 전환합니다.'; -- en:621a94e8
L.FORMAT_HOLD_BINDING         = '%s (누름)'; -- en:c3ecd1b3
L.FORMAT_RING_NUMERICAL       = '원형 메뉴 |cFF00FFFF%s|r'; -- en:68d18518
L.NAME_EASY_MOTION            = '유닛 프레임 대상 지정 (누름)'; -- en:e6f0c131
L.NAME_QUICK_MENU             = '빠른 메뉴'; -- en:ed9a0668
L.NAME_RAID_CURSOR_FOCUS      = '공격대 커서 (주시 대상)'; -- en:d350d370
L.NAME_RAID_CURSOR_TARGET     = '공격대 커서 (대상)'; -- en:8182d5d5
L.NAME_RAID_CURSOR_TOGGLE     = '공격대 커서 전환'; -- en:79fb9d46
L.NAME_RING_MENU              = '원형 메뉴'; -- en:8d7e5939
L.NAME_RING_PET               = '소환수 원형 메뉴'; -- en:8dab5a0e
L.NAME_RING_TARGET            = '대상 원형 메뉴 (누름)'; -- en:59e8a9cb
L.NAME_RING_UTILITY           = '도구 원형 메뉴'; -- en:96bc880d
L.NAME_UI_CURSOR_TOGGLE       = '인터페이스 커서 전환'; -- en:2d6091b5
L.RING_EMPTY_DESC             = '이 원형 메뉴에 아직 능력이 없습니다.'; -- en:044cf09a
---------------------------------------------------------------
-- Long / curated block entries
---------------------------------------------------------------
L.ACTIONBAR_FORM_DESC = [[이 변신을 활성화하면 주 행동 단축바가 자동으로 이 변신과 관련된 능력을 표시하도록 전환됩니다.

이 변신은 주 행동 단축바와 단축키를 공유하므로, 일반적인 조합으로 이 변신의 능력에 접근할 수 있습니다.

이 변신에서 빠져나오면 주 행동 단축바는 이전 상태로 돌아가 일반 능력을 표시합니다.]]; -- en:a751197a
L.ACTIONBAR_MAIN_DESC = [[주 행동 단축바는 순환 능력과 기타 자주 사용되는 동작을 위한 주요 위치입니다.

이 바는 동적이며 현재 상황에 따라 다른 페이지로 자동 전환될 수 있습니다.

예를 들어 탈것에 타거나, 애완동물 대결에 참여하거나, 다른 형태로 변신하거나, 전투 자세에 들어가거나, 다른 유닛을 제어할 때 주 행동 단축바가 특수 능력 세트로 전환됩니다.

이를 통해 행동 단축바 설정을 수동으로 변경하지 않고도 상황별 능력에 접근할 수 있습니다.

일반 상태로 돌아오면 일반 능력이 다시 바에 표시됩니다.]]; -- en:8e47cecd
L.ACTIONBAR_PAGE_MISMATCH_DESC = [[행동 단축바의 실제 페이지 번호는 행동 단축바 시스템이 원래 설계된 방식 때문에 표시된 이름과 항상 일치하지는 않습니다.

사용자 정의 동작 페이지 솔루션을 사용하지 않는다면 이 불일치는 무시할 수 있습니다. 참조용으로 둘 다 표시됩니다.]]; -- en:9fd917fd
L.ADD_NEW_RING_TEXT = [[|cFFFFFF00새 원형 메뉴 만들기|r
새 원형 메뉴의 이름을 선택하십시오:]]; -- en:00af872a
L.CLEAR_RING_TEXT = [[|cFFFFFF00%s 비우기|r
이 원형 메뉴를 비우시겠습니까?]]; -- en:ebc807d8
L.CONTROLS_GAMEPAD_TESTER_ACTION = [[
	입력이 감지되지 않으면 테스트는 몇 초 후에 자동으로 만료됩니다.
]]; -- en:0f591dc7
L.CONTROLS_GAMEPAD_TESTER_DESC = [[
	게임패드가 올바르게 작동하는지 확인하려면 테스트 도구를 사용하십시오.

	테스트는 게임패드의 버튼을 누르고 축을 움직이도록 요청하여
	모든 버튼과 센서가 예상대로 작동하는지 확인합니다.

	문제 해결:

	- 게임패드가 운영 체제에 연결되어 인식되는지 확인하십시오.

	- Windows에서 백그라운드에서 실행되는 Steam 같이
	장치를 방해할 수 있는 충돌 소프트웨어를 확인하십시오.

	- 휴대용 컴퓨터를 사용하는 경우 제어 센터에서 장치가 게임 모드로 설정되어 있는지 확인하십시오.
	데스크톱 모드는 올바르게 작동하지 않습니다.

	- 드라이버를 업데이트하고 게임패드에 필요한 소프트웨어를 설치하십시오.
]]; -- en:fd1ed2f5
L.CONTROLS_GENERAL_INFO = [[
	선호하는 제어 구성을 선택하십시오.
]]; -- en:3f779845
L.CONTROLS_MODIFIERS_CUSTOM = [[
	사용자 정의 조합키 설정을 사용합니다.

	조합키는 게임패드에서 가장 접근하기 쉬운 버튼인 어깨 버튼이나 트리거에 설정하는 것을 권장합니다.
]]; -- en:964cdf45
L.CONTROLS_MODIFIERS_DESC = [[
	조합키는 단축키 세트 사이를 전환하며, 키보드 컨트롤 키(Shift, Ctrl, Alt)를 에뮬레이트합니다.

	조합키를 누르면 단축키가 임시로 다른 세트로 전환되어 사용 가능한 동작이 확장됩니다.

	조합키는 짧게 누르고 떼는 것으로 일반 단축키를 실행할 수 있습니다.

	서로 조합할 수도 있습니다. 두 개의 조합키를 사용하면 총 네 개의 단축키 세트에 접근할 수 있고,
	세 개의 조합키는 여덟 개의 세트를 제공합니다.

	대부분의 플레이어에게는 너무 복잡하지 않으면서도 편안한 단축키 세트를 가지기에
	두 개의 조합키로 충분합니다.
]]; -- en:b083ec08
L.CONTROLS_MODIFIERS_LEFT = [[
	왼손잡이 조합키를 사용하여 이동과 단축키 세트 전환을 게임패드 왼쪽에 유지합니다.

	왼손과 오른손에 별도의 역할을 두는 것은 인체공학과 협응에 도움이 될 수 있습니다.
]]; -- en:507e5d94
L.CONTROLS_MODIFIERS_TRIGGERS = [[
	양쪽 트리거를 조합키로 사용하여 단축키를 왼쪽과 오른쪽으로 분할합니다.

	FFXIV에서 전환하는 경우나 크로스바 멘탈 모델을 선호하는 경우에 유용할 수 있습니다.
]]; -- en:70401fbd
L.CONTROLS_MOUSE_BUTTONS_DESC = [[
	마우스 버튼을 에뮬레이트하여 마우스와 비슷한 기능을 제공할 수 있습니다.

	이러한 단축키는 지면 주문 설치 확인, 군중 속에서의 정밀 조준,
	특수 인터페이스 동작 등에 매우 중요합니다.

	조합키와 결합하여 마우스 기능을 더욱 가깝게 복제할 수 있습니다.

	이 버튼은 커서를 전환하는 데에도 사용되며, 커서는 세 가지 상태를 가질 수 있습니다:

	- 자유; 게임패드로 화면 위의 커서를 움직일 수 있습니다.

	- 중앙; 커서가 화면 중앙에 고정되어 오브젝트와 캐릭터를 조준하고
	지면에 주문을 설치할 수 있습니다.

	- 숨김; 커서가 여전히 중앙에 있지만 화면에 보이지 않습니다. 십자선으로 위치가 표시됩니다.
]]; -- en:e088d19f
L.CONTROLS_MOUSE_CUSTOM = [[
	사용자 정의 마우스 버튼 설정을 사용합니다.

	World of Warcraft는 마우스 버튼을 두 가지 별개의 방식으로 처리하며, 대부분 숨겨져 있습니다.

	- 게임 인터페이스(버튼이나 메뉴 등)를 클릭할 때, 인터페이스는
	게임패드로 에뮬레이트할 수 있는 마우스 클릭에만 반응합니다.

	- 게임 세계(대상 지정이나 상호작용 등)에서 클릭할 때는 일반 단축키가 사용됩니다.

	마우스와 동일한 역할을 수행하기 위해 이러한 동작을 함께 유지하는 것을 강력히 권장합니다.
]]; -- en:3e862670
L.CONTROLS_MOUSE_INVERTED = [[
	반전된 마우스 버튼 단축키를 사용합니다.

	왼쪽 스틱으로 중앙 및 숨김 커서 모드 전환과 마우스 우클릭에 사용하십시오.

	오른쪽 스틱으로 자유 커서 모드 전환과 마우스 좌클릭에 사용하십시오.
]]; -- en:16d3d6d2
L.CONTROLS_MOUSE_REGULAR = [[
	일반 마우스 버튼 단축키를 사용합니다.

	왼쪽 스틱으로 자유 커서 모드 전환과 마우스 좌클릭에 사용하십시오.

	오른쪽 스틱으로 중앙 및 숨김 커서 모드 전환과 마우스 우클릭에 사용하십시오.
]]; -- en:75e9f21b
L.CONTROLS_MOVEMENT_BALANCED_DESC = [[
	균형 이동은 탱커 이동과 추적 이동 사이의 절충안입니다.

	전투와 이동 모두에서 이 구성은 각 방향으로 최대 115도까지 측면 이동하므로,
	측면으로 이동하면서도 여전히 앞을 바라봅니다.

	스틱을 더 아래로 움직이면 캐릭터는 이동 방향을 따라가도록 전환됩니다.
	캐릭터의 머리를 보고 어느 방향을 바라보는지 확인하십시오.

	115도는 이동 속도를 잃지 않으면서 최대 커버리지를 제공하는 최적의 지점입니다.
]]; -- en:3355743a
L.CONTROLS_MOVEMENT_DESC = [[
	이동 제어는 플레이 스타일에 맞게 사용자 정의할 수 있습니다.

	게임패드는 아날로그 이동을 사용하므로 어떤 방향으로든 달릴 수 있으며,
	스틱에 가하는 압력을 조절하여 걸을 수 있습니다.

	이 게임은 측면 이동을 주요 메커니즘으로 사용하며,
	다른 방향을 바라보는 동안 측면으로 이동합니다.

	캐릭터가 측면 이동과 이동 방향으로 회전 사이를
	언제 전환할지 사용자 정의할 수 있습니다.

	구성 중 하나를 강조하고 왼쪽 스틱을 움직여
	테스트해 보십시오.
]]; -- en:9d22c4f0
L.CONTROLS_MOVEMENT_FOLLOW_DESC = [[
	추적 이동은 이동 방향을 따라가는 데 중점을 둡니다.

	전투와 이동 모두에서 이 구성은 측면 이동을 하지 않으며
	뒤로 걷지도 않습니다.

	단일 스틱 구성으로 자주 또는 항상 플레이하는 플레이어에게 유용합니다.
]]; -- en:45773d56
L.CONTROLS_MOVEMENT_TANK_DESC = [[
	탱커 이동은 전투 중 이동하면서 전방을 향한 자세를 유지하는 데 중점을 둡니다.

	전투에서 이 구성은 항상 측면 이동을 하며, 전방을 유지하기 위해 뒤로 걷습니다.

	이동 중에는 항상 이동 방향을 따라갑니다.
]]; -- en:9fcbcaaf
L.DEFAULTS_BINDINGS_EMPTY_DESC = [[
	처음부터 시작합니다.

	이 작업은 Blizzard 기본값을 포함한 모든 현재 게임패드 단축키를 지우고,
	처음부터 단축키를 설정할 수 있게 합니다.

	이 작업은 기존 키보드 단축키를 덮어쓰거나 간섭하지 않지만,
	행동 단축바는 둘 사이에서 공유된다는 점을 유의하십시오.

	키보드와 게임패드를 전환할 계획이라면, 행동 단축바에서 능력을 이리저리 옮기지 말고
	게임패드 단축키를 변경하는 것을 권장합니다.
]]; -- en:51053386
L.DEFAULTS_BINDINGS_PRESET_DESC = [[
	권장 단축키를 적용합니다.

	이 단축키는 이전 선택을 바탕으로 게임패드 설정의 좋은 시작점을 제공합니다.
	나중에 언제든지 변경할 수 있습니다.

	이 작업은 기존 키보드 단축키를 덮어쓰거나 간섭하지 않지만,
	행동 단축바는 둘 사이에서 공유된다는 점을 유의하십시오.

	키보드와 게임패드를 전환할 계획이라면, 행동 단축바에서 능력을 이리저리 옮기지 말고
	게임패드 단축키를 변경하는 것을 권장합니다.
]]; -- en:6ac789b1
L.DEFAULTS_GENERAL_INFO = [[
	게임패드에 권장되는 설정과 단축키를 적용하여 설정을 완료하십시오.
]]; -- en:c436023e
L.DEFAULTS_SETTINGS_APPLIED = [[
	게임패드 종류(%s)에 대한 권장 설정이 적용되었습니다.
]]; -- en:16be45b5
L.DEFAULTS_SETTINGS_DESC = [[
	게임패드 종류(%s)에 대한 권장 설정을 적용합니다:
]]; -- en:15a4050f
L.DEFAULTS_SETTINGS_NOTWEAK = [[
	게임패드 종류(%s)에 적용할 권장 설정이 없습니다.
]]; -- en:067a8a20
L.DESC_EASY_MOTION = [[
	화면의 유닛 프레임에 대한 단축키를 생성하여
	우호적인 대상 사이를 빠르게 전환할 수 있습니다.

	사용하려면 단축키를 누른 채로 선택한 대상에 표시된
	키를 누른 뒤, 단축키를 놓아 대상을 변경하십시오.

	이 단축키는 5인 콘텐츠의 치유사에게 강력히 권장됩니다.
	작은 그룹에서 매우 빠른 대상 지정 방법을 제공합니다.

	공격대에서는 선호하는 대상을 고르기 위한
	입력의 복잡성이 부담스러울 수 있습니다.
	다른 선택은 「공격대 커서 전환」을 참조하십시오.
]]; -- en:0f9384b6
L.DESC_EXTRAACTIONBUTTON1 = [[
	추가 동작 버튼은 다양한 퀘스트, 시나리오, 우두머리 전투에서
	사용되는 임시 능력을 담고 있습니다.

	이 단축키가 설정되지 않은 경우, 추가 동작 버튼은 항상
	도구 원형 메뉴에서 사용할 수 있습니다.

	이 버튼은 일반 동작 버튼처럼 게임패드 행동 단축바에 표시되지만,
	내용을 변경할 수 없습니다.
]]; -- en:6dd42998
L.DESC_INTERACTTARGET = [[
	게임 세계의 NPC 및 오브젝트와 상호작용할 수 있습니다.

	중앙 커서와 동일한 기능을 제공하지만, 커서나 십자선을
	대상에 직접 조준할 필요가 없습니다.

	상호작용 가능한 오브젝트는 사거리 내에 있을 때 강조 표시됩니다.
]]; -- en:b1478add
L.DESC_JUMP = [[
	수중에서 위로 헤엄치거나 비행 탈것으로 상승하거나,
	용 등 위에서 위로 날갯짓하는 데에도 사용할 수 있습니다.

	점프는 엄지손가락이 필요한 왼손 동작을 수행하는 동안
	이동의 공백을 메우는 데 유용합니다.

	일반 설정에서 왼쪽 스틱은 이동을 제어합니다.
	이동 중에 방향키 조합을 눌러야 할 때,
	점프를 사용하면 잠시 엄지손가락을 스틱에서 떼는 동안
	전진 추진력을 유지할 수 있습니다.
]]; -- en:4c032315
L.DESC_KEY_BUTTON1 = [[
	자유 커서를 전환하는 데 사용되며, 카메라 스틱을 마우스 포인터로 사용할 수 있습니다.
]]; -- en:fd3d111a
L.DESC_KEY_BUTTON2 = [[
	중앙 커서를 전환하는 데 사용되며, 마우스 중앙 고정 위치에서
	게임 세계의 오브젝트 및 캐릭터와 상호작용할 수 있습니다.
]]; -- en:2f5c87e4
L.DESC_QUICK_MENU = [[
	파티 전리품 굴림, 강화 효과 취소, 가방 아이템 사용 등
	플레이 중 자주 수행하는 동작을 한곳에 모아 빠르게 접근할 수 있는 메뉴입니다.
]]; -- en:0365846b
L.DESC_RAID_CURSOR = [[
	화면의 유닛 프레임에 고정되는 커서를 전환하여,
	다른 대상을 유지하면서 우호적인 플레이어를 치유할 수 있습니다.

	공격대 커서를 직접 대상 지정으로 설정할 수도 있으며,
	커서를 움직이면 현재 대상이 전환됩니다.

	사용 중에 공격대 커서는 커서 위치를 제어하기 위해
	방향키 조합 한 세트를 차지합니다.

	라우팅 모드에서는 사제의 「참회」 같은 매크로나 모호한 주문을
	커서가 다시 라우팅하지 않습니다.

	다른 선택은 「유닛 프레임 대상 지정」을 참조하십시오.
]]; -- en:cacdf9c0
L.DESC_RING_CUSTOM = [[
	행동 단축바 공간을 차지하고 싶지 않은 아이템, 주문, 매크로, 탈것을
	추가할 수 있는 원형 메뉴입니다.

	사용하려면 단축키를 누른 채로 스틱을 선택하고 싶은 항목 방향으로 기울인 뒤
	단축키를 놓으십시오.

	항목을 제거하려면 해당 항목에 초점을 두고 툴팁 안내를 따르십시오.
]]; -- en:159abd06
L.DESC_RING_MENU = [[
	자주 사용하는 패널과 동작을 한곳에 모아 빠르게 접근할 수 있는 원형 메뉴입니다.

	별도의 단축키 없이도 게임 메뉴에서 페이지를 전환하여 접근할 수 있습니다.
]]; -- en:7ee244a1
L.DESC_RING_PET = [[
	현재 소환수를 조종할 수 있는 원형 메뉴입니다.
]]; -- en:b1c4b5d3
L.DESC_RING_UTILITY = [[
	행동 단축바 공간을 차지하고 싶지 않은 아이템, 주문, 매크로, 탈것을
	추가할 수 있는 원형 메뉴입니다.

	사용하려면 단축키를 누른 채로 스틱을 선택하고 싶은 항목 방향으로 기울인 뒤
	단축키를 놓으십시오.

	항목을 추가하려면 인터페이스 커서의 안내를 따르거나, 마우스 커서로 무언가를 집은 뒤
	단축키를 눌러 메뉴에 놓으십시오.

	항목을 제거하려면 해당 항목에 초점을 두고 툴팁 안내를 따르십시오.

	도구 원형 메뉴는 행동 단축바에 배치하지 않은 퀘스트 아이템과 임시 능력을
	자동으로 추가합니다.
]]; -- en:de107e96
L.DESC_TARGETNEARESTENEMY = [[
	정면에서 가장 가까운 적 대상 사이를 전환합니다.
	현재 대상이 없으면 가장 중앙의 적이 선택됩니다.
	그렇지 않으면 가장 가까운 대상을 순환합니다.

	대상 변경을 결정하기 전에 누르고 있으면 대상이 강조 표시됩니다.

	보조 대상 지정 단축키로 사용하거나,
	캐주얼 플레이에서 주요 대상 지정 단축키로 사용하거나,
	대상 스캔이 너무 정밀해서 편하지 않을 때 사용하길 권장합니다.

	던전이나 기타 고정밀 시나리오에는 권장되지 않습니다.
]]; -- en:981bc29c
L.DESC_TARGETSCANENEMY = [[
	정면의 좁은 원뿔 영역에서 적을 스캔합니다.
	대상 변경을 결정하기 전에 누르고 있으면 대상이 강조 표시됩니다.

	높은 정밀도로 전투 중에 대상을 빠르게 전환할 때
	특히 유용합니다.

	대상 우선순위는 조준에 편향되어 있어
	원뿔의 중심에 가장 가까운 대상이 먼저 선택됩니다.
	먼 대상이 원뿔 중심에 더 가까운 경우 가까운 대상보다
	먼 대상이 우선시될 수 있습니다.

	대부분의 플레이어에게 주요 대상 지정 단축키로 권장됩니다.
]]; -- en:2de05bb9
L.DESC_TOGGLEAUTORUN = [[
	자동 달리기를 활성화하면 입력 없이도 캐릭터가 바라보는 방향으로
	계속 이동합니다.

	자동 달리기는 오랜 이동 중 엄지손가락 피로를 줄이거나,
	이동 중에 다른 작업을 할 수 있도록 엄지손가락을 자유롭게 해줍니다.
]]; -- en:9e97af4b
L.DESC_TOGGLEGAMEMENU = [[
	메뉴 단축키는 키보드의 Esc 키를 누를 때 발생하는 모든 기능을 처리합니다.
	현재 게임 상태에 따라 다른 동작을 처리합니다.

	주문이나 대상 지정과 관련된 진행 중인 동작이 있으면
	취소됩니다. 활성 대상이 있는 상태에서 단축키를 누르면
	대상이 지워집니다. 주문을 시전 중에 단축키를 누르면
	시전이 중단됩니다.

	이 단축키는 현재 화면에 표시된 것에 따라 다양한 다른 경우도 처리합니다.
	예를 들어 주문서 같은 패널이 열려 있으면
	이를 닫거나 숨기는 데 필요한 동작을 수행합니다.

	위의 어느 경우에도 해당하지 않으면, 단축키를 누를 때 게임 메뉴가
	열리거나 닫힙니다.
]]; -- en:adfccfe4
L.DEVICE_DESC_PLAYSTATION4 = [[
	PlayStation 4 컨트롤러는 DualShock 4로도 알려져 있으며, Sony의 이전 세대 게임패드입니다.

	터치패드, 모션 컨트롤, 그리고 모든 버튼을 게임에서 지원하는 기능이 풍부한 게임패드입니다.

	모든 기능을 활용하려면 PlayStation Accessories(Windows)를 설치해야 할 수 있습니다.
]]; -- en:7bea4ad9
L.DEVICE_DESC_PLAYSTATION5 = [[
	PlayStation 5 컨트롤러는 DualSense로도 알려져 있으며, 현재 World of Warcraft에 가장 적합한 게임패드입니다.

	모션 컨트롤, 터치패드, 그리고 Edge 변형의 경우 네이티브 후면 패들까지 갖춘 가장 기능이 풍부한 게임패드입니다.
	게임패드의 모든 버튼을 게임에서 사용할 수 있습니다.

	모든 기능을 활용하려면 PlayStation Accessories(Windows)를 설치해야 할 수 있습니다.
]]; -- en:c5f15091
L.DEVICE_DESC_STEAMDECK = [[
	Steam Deck은 일반적으로 Steam 클라이언트를 통해 Proton으로 World of Warcraft를 실행합니다.

	Steam을 통해 플레이할 때 장치는 최소한 표준 Xbox 레이아웃을 다루는 게임 프로필을 사용해야 합니다.

	마우스 트랙패드가 있는 게임패드가 견고한 기반을 제공합니다.

	Steam Deck은 World of Warcraft에서 패들을 기본적으로 사용할 수 없습니다.
	패들은 에뮬레이션을 통해 매핑하거나 Steam Input 설정에서 키보드 키로 매핑할 수 있습니다.

	게임 내 Steam Deck 프리셋은 비슷한 제어 레이아웃 덕분에 다른 휴대용 컴퓨터에도 적합할 수 있습니다.
]]; -- en:2a5e4173
L.DEVICE_DESC_SWITCHPRO = [[
	Nintendo Switch Pro 컨트롤러는 Xbox 컨트롤러와 비슷한 레이아웃을 가지지만, 버튼 라벨이 반전되어 있습니다.

	Pro 컨트롤러에는 중앙 버튼이 네 개 있어 표준 Xbox 컨트롤러보다 약간의 이점을 제공합니다.

	Nintendo Switch 2 Pro 컨트롤러는 게임에서 패들이나 C 버튼을 기본적으로 사용할 수 없습니다.
	Steam이나 reWASD 같은 외부 소프트웨어로 키보드 키에 매핑하여 게임에서 사용할 수 있습니다.
]]; -- en:79260874
L.DEVICE_DESC_XBOX = [[
	Xbox 변형은 가장 일반적인 게임패드이며 World of Warcraft에서 잘 지원됩니다.

	Xbox Elite 컨트롤러는 게임에서 패들을 기본적으로 사용할 수 없지만,
	Xbox Accessories 앱(Windows)을 사용하여 다른 게임패드 버튼을 시뮬레이션하는 데 사용할 수 있습니다.

	Steam이나 reWASD 같은 외부 소프트웨어로 패들을 키보드 키에 매핑하여 게임에서 사용할 수 있습니다.

	중앙 버튼은 Xbox 가이드용으로 예약되어 있어 게임에서 사용할 수 없습니다.

	Steam Input에도 권장되며, 에뮬레이트하는 Xbox 360 컨트롤러와 일관성이 있습니다.
]]; -- en:654501d3
L.DISC_KEY_BUTTON1 = [[
	버튼 중 하나가 마우스 좌클릭을 에뮬레이트하도록 설정되어 있는 동안에는 이 단축키를 변경할 수 없습니다.
]]; -- en:e811ebc6
L.DISC_KEY_BUTTON2 = [[
	버튼 중 하나가 마우스 우클릭을 에뮬레이트하도록 설정되어 있는 동안에는 이 단축키를 변경할 수 없습니다.
]]; -- en:b85c78b2
L.EXPORT_DATA_TEXT = [[

|cFFFFFF00내보내기|r

내보내려는 데이터를 선택하십시오. 아래에 문자열이 생성되며, 다른 클라이언트에 붙여넣거나 다른 사람과 공유할 수 있습니다.

%s를 사용하여 문자열을 복사하십시오.
]]; -- en:1741e6a6
L.GFX_GENERAL_INFO = [[
	게임패드 외관과 가장 가까운 게임패드 그래픽을 선택하십시오.

	그래픽 선택은 게임패드 작동 방식을 바꾸지 않으며, 단지 인터페이스 외관만 바꿉니다.

	그래픽은 현재 어떤 버튼이 어떤 동작에 할당되어 있는지 표시하고, 게임패드 레이아웃에 대한 시각적 참조를 제공하는 데 사용됩니다.

	선택에 따라 선택적인 설정 권장 사항이 제공됩니다.
]]; -- en:54457360
L.IMPORT_DATA_TEXT = [[

|cFFFFFF00가져오기|r

내보낸 문자열을 아래에 붙여넣은 다음, 가져올 데이터를 불러와 선택하십시오. 가져온 데이터는 해당되는 경우 현재 데이터를 덮어씁니다.

%s를 사용하여 원본에서 문자열을 복사하고, %s를 사용하여 아래에 붙여넣으십시오.
]]; -- en:145f78fb
L.IMPORT_FAILED_TEXT = [[

|cFFFFFF00가져오기|r

가져오기 실패:
]]; -- en:a7555666
L.LINK_COPY = [[
	%s 링크입니다.

	Ctrl+A로 선택하고 Ctrl+C로 복사하십시오.

	웹 브라우저에 (Ctrl+V로) 링크를 붙여넣으십시오.
]]; -- en:3f396345
L.LINK_DISCORD_TEXT = [[
	지원을 찾고, 게임플레이를 토론하고, 아이디어를 공유하고, 같은 생각을 가진 플레이어를 만날 수 있는 커뮤니티입니다.

	서버에 참여하려면 여기를 클릭하십시오.
]]; -- en:e2f9740c
L.LINK_PATREON_TEXT = [[
	이 애드온의 개발과 유지보수에는 많은 시간과 노력이 들지만,
	ConsolePort는 언제나 완전히 무료로 사용할 수 있습니다.

	Patreon 후원자가 되어 Discord 배지를 잠금 해제하고, 프로젝트의 미래를 지원해 주십시오.

	후원자가 되려면 여기를 클릭하십시오.
]]; -- en:3cc9532e
L.LINK_PAYPAL_TEXT = [[
	기부금은 애드온의 개발과 유지보수에 직접 재투자됩니다.

	크든 작든 모든 기여에 깊이 감사드립니다.

	PayPal로 기부하려면 여기를 클릭하십시오.
]]; -- en:28c6265a
L.REMOVE_RING_TEXT = [[|cFFFFFF00%s 제거|r
원형 메뉴를 제거하시겠습니까?]]; -- en:1a461a1a
L.RING_MENU_DESC = [[행동 단축바 공간을 차지하고 싶지 않은 아이템, 주문, 매크로, 탈것을 추가할 수 있는 사용자 정의 원형 메뉴를 만드십시오.

사용하려면 선택한 단축키를 누른 채로 스틱을 선택하고 싶은 항목 방향으로 기울인 뒤 단축키를 놓으십시오.

기본 원형 메뉴인 |CFF00FF00도구 원형 메뉴|r는 퀘스트 진행과 세계 상호작용을 쉽게 하는 특수 속성을 가지며 정적이지 않습니다. 필요에 따라 자동으로 항목을 추가하고 제거합니다.

순환에서 사용할 원형 메뉴를 만들려면 단순한 도구 용도가 아닌 경우, 이 용도로 사용자 정의 원형 메뉴를 만드는 것을 강력히 권장합니다.]]; -- en:39d4577b
L.SELECTED_RING_TEXT = [[현재 선택된 원형 메뉴입니다.
단축키를 누르고 유지하면 선택한 모든 능력이 화면에 원형 메뉴로 나타납니다.

사용하려는 능력이나 아이템 방향으로 방사형 스틱을 기울인 다음, 단축키를 놓아 확인하십시오.]]; -- en:2cdfa5d3
L.SET_RING_BINDING_TEXT = [[
|cFFFFFF00단축키 설정|r

이 원형 메뉴에 새 단축키를 선택하려면 버튼 조합을 누르십시오.

]]; -- en:1c0e03f4
L.SLOT_NO_BINDING = [[
|cFFFFFF00단축키 설정|r

%s의 %s에 단축키가 할당되어 있지 않습니다.

이 슬롯에 새 단축키를 선택하려면 버튼 조합을 누르십시오.

]]; -- en:74326275
L.SLOT_SET_BINDING = [[
|cFFFFFF00단축키 설정|r

%s에 새 단축키를 선택하려면 버튼 조합을 누르십시오.

]]; -- en:d1933130
---------------------------------------------------------------
-- Literals
---------------------------------------------------------------
L['2D deadzone for camera that takes into account pitch and yaw movement together.'] = '피치 및 요 움직임을 함께 고려하는 카메라용 2D 사용 안 함 구역.';
L['2D deadzone for movement that takes into account X and Y movement together.'] = 'X 및 Y 움직임을 함께 고려하는 이동용 2D 사용 안 함 구역.';
L['A button cluster for all modifiers of a single button.'] = '단일 버튼의 모든 조합키에 대한 버튼 클러스터.';
L['A cluster bar with a toolbar below it, laid out horizontally.'] = '도구 모음이 아래에 가로로 배치된 클러스터 바.';
L['A cluster bar with a toolbar below it.'] = '도구 모음이 아래에 있는 클러스터 바.';
L['A divider to separate elements.'] = '요소를 구분하는 구분 기호.';
L['A friendly soft target can be acquired while having an enemy hard target.'] = '적대적인 단단한 대상이 있는 동안에도 우호적인 부드러운 대상을 획득할 수 있습니다.';
L['A regular action bar.'] = '일반 행동 단축바.';
L['A ring of buttons for pet commands.'] = '소환수 명령을 위한 버튼 원형 메뉴.';
L['A toolbar with XP indicators, shortcuts, class specific bars, and miscellaneous information.'] = '경험치 표시기, 단축키, 직업별 바, 기타 정보가 있는 도구 모음.';
L['About'] = '정보';
L['Acceleration of cursor per second as it continues to move.'] = '계속 움직이는 동안의 초당 커서 가속.';
L['Accent Color'] = '강조 색상';
L['Accept Button'] = '수락 버튼';
L['Action Bar Configuration'] = '행동 단축바 구성';
L['Action bar is scaled separately.'] = '행동 단축바는 별도로 크기 조정됩니다.';
L['Action Bar Loadout'] = '행동 단축바 로드아웃';
L['Action Bar Loadout (Deprecated)'] = '행동 단축바 로드아웃 (사용 중단)';
L['Action Bar Presets'] = '행동 단축바 프리셋';
L['Action Bar Setup'] = '행동 단축바 설정';
L['Action Button'] = '동작 버튼';
L['Action Button Group'] = '동작 버튼 그룹';
L['Action Page'] = '동작 페이지';
L['Action Page Condition'] = '동작 페이지 조건';
L['Action Page Response'] = '동작 페이지 응답';
L['Activate targeting components only while their bindings are in use.'] = '대상 지정 구성 요소를 해당 단축키가 사용 중일 때만 활성화합니다.';
L['Active Color'] = '활성 색상';
L['Active Device'] = '활성 장치';
L['Add a new element to your loadout.'] = '로드아웃에 새 요소를 추가합니다.';
L['Add to %s'] = '%s에 추가';
L['Add, remove or reset a frame from cursor stack.'] = '커서 스택에서 프레임 추가, 제거 또는 재설정.';
L['Affects both mouse and gamepad.'] = '마우스와 게임패드 모두에 영향을 줍니다.';
L['Alignment'] = '정렬';
L['Alignment of the counter text on buttons.'] = '버튼의 카운터 텍스트 정렬.';
L['Alignment of the hotkey text on buttons.'] = '버튼의 단축키 텍스트 정렬.';
L['Alignment of the macro text on buttons.'] = '버튼의 매크로 텍스트 정렬.';
L['All combines all connected devices into one.'] = '「모두」는 연결된 모든 장치를 하나로 결합합니다.';
L['Allow binding discrete radial stick inputs.'] = '이산 방사형 스틱 입력 단축키 허용.';
L['Allow binding multiple combos to the same binding.'] = '여러 조합을 같은 단축키에 할당하도록 허용.';
L['Allow Binding Overlap'] = '단축키 겹침 허용';
L['Allow casting on mouseover targets, when enabled in the game options.'] = '게임 옵션에서 활성화된 경우 마우스오버 대상에게 주문을 시전할 수 있습니다.';
L['Allow cursor to interact with and show preference for group loot frames.'] = '커서가 파티 전리품 프레임과 상호작용하고 우선시하도록 허용합니다.';
L['Allow cursor to interact with and show preference for popups and static dialogs.'] = '커서가 팝업 및 정적 대화상자와 상호작용하고 우선시하도록 허용합니다.';
L['Allow cursor to interact with the entire interface, not only panels.'] = '커서가 패널뿐 아니라 전체 인터페이스와 상호작용하도록 허용합니다.';
L['Allow Radial Bindings'] = '방사형 단축키 허용';
L['Allows the use of the touchpad to control cursor movement.'] = '터치패드를 사용하여 커서 움직임을 제어할 수 있도록 허용합니다.';
L['Alphabet to use for dictionary suggestions and word processing.'] = '사전 제안 및 단어 처리에 사용할 알파벳.';
L['Always keep cursor centered and visible when controlling camera.'] = '카메라를 제어할 때 항상 커서를 중앙에 두고 보이게 합니다.';
L['Always Show All Buttons'] = '항상 모든 버튼 표시';
L['Always Show Mouse Cursor'] = '항상 마우스 커서 표시';
L['Always show nameplate for soft enemy target.'] = '부드러운 적 대상에 대해 항상 이름표 표시.';
L['Always show nameplate for soft friendly target.'] = '부드러운 우호 대상에 대해 항상 이름표 표시.';
L['Always show tooltip for an automatically acquired target, as long as it exists.'] = '자동으로 획득한 대상이 존재하는 한 항상 툴팁 표시.';
L['An action button in a group.'] = '그룹의 동작 버튼.';
L['Analog Movement'] = '아날로그 이동';
L['Anchor'] = '고정점';
L['Anchor point of parent to pair with.'] = '쌍을 이룰 상위 항목의 고정점.';
L['Anchor point of the counter text on buttons.'] = '버튼의 카운터 텍스트 고정점.';
L['Anchor point of the hotkey icon on group buttons.'] = '그룹 버튼의 단축키 아이콘 고정점.';
L['Anchor point of the hotkey text on buttons.'] = '버튼의 단축키 텍스트 고정점.';
L['Anchor point of the macro text on buttons.'] = '버튼의 매크로 텍스트 고정점.';
L['Anchor point to attach.'] = '부착할 고정점.';
L['Apply default settings to the current category or all settings.'] = '현재 범주 또는 모든 설정에 기본 설정 적용.';
L['Arc Allowance'] = '호 허용 범위';
L['Are you sure you want to delete %s from %s?'] = '%s에서 %s을(를) 삭제하시겠습니까?';
L['Are you sure you want to overwrite %s with %s?'] = '%s을(를) %s으로 덮어쓰시겠습니까?';
L['Are you sure you want to regenerate the keyboard dictionary? You will lose all custom phrases.'] = '키보드 사전을 재생성하시겠습니까? 모든 사용자 정의 구문을 잃게 됩니다.';
L['Are you sure you want to reset all device profiles?'] = '모든 장치 프로필을 재설정하시겠습니까?';
L['Are you sure you want to reset the keyboard layout?'] = '키보드 레이아웃을 재설정하시겠습니까?';
L['Are you sure you want to reset your device profile?'] = '장치 프로필을 재설정하시겠습니까?';
L['Are you sure you want to wipe the keyboard dictionary? It currently contains %d words.'] = '키보드 사전을 지우시겠습니까? 현재 %d개의 단어가 포함되어 있습니다.';
L['Area where the interact key can find a suitable target.'] = '상호작용 키가 적합한 대상을 찾을 수 있는 영역.';
L['Artwork flavor.'] = '아트워크 변형.';
L['Artwork for the interface.'] = '인터페이스의 아트워크.';
L['Artwork style.'] = '아트워크 스타일.';
L['Assign or clear bindings for this set.'] = '이 세트에 대한 단축키 할당 또는 지우기.';
L['Assist Mode'] = '지원 모드';
L['Auto-adjusts your camera, allowing you to control movement with a single stick.'] = '카메라를 자동으로 조정하여 단일 스틱으로 움직임을 제어할 수 있습니다.';
L['Auto-Sell Gear Level Limit'] = '자동 판매 장비 레벨 제한';
L['Auto-Sell Junk'] = '잡동사니 자동 판매';
L['Auto-set target to match soft target.'] = '부드러운 대상에 맞게 자동으로 대상 설정.';
L['Automatic Binding Backups'] = '자동 단축키 백업';
L['Automatic Cursor Timeout'] = '자동 커서 시간 초과';
L['Automatic Tooltip Duration'] = '자동 툴팁 지속 시간';
L['Automatically add tracked quest items and extra spells to main utility ring.'] = '추적되는 퀘스트 아이템과 추가 주문을 메인 도구 원형 메뉴에 자동으로 추가합니다.';
L['Automatically backup your bindings when you change them, for import and export.'] = '단축키 변경 시 가져오기 및 내보내기를 위해 자동으로 백업합니다.';
L['Automatically Bind Extra Items'] = '추가 아이템 자동 할당';
L['Automatically Control Cursor Pickups'] = '커서 줍기 자동 제어';
L['Automatically control cursor when picking up items.'] = '아이템을 줍을 때 커서를 자동으로 제어합니다.';
L['Automatically disabled if an inactive component is clicked from a macro.'] = '비활성 구성 요소가 매크로에서 클릭되면 자동으로 비활성화됩니다.';
L['Automatically sell junk when interacting with a merchant.'] = '상인과 상호작용할 때 잡동사니를 자동으로 판매합니다.';
L['Axis Interpretation'] = '축 해석';
L['Basic redirect cannot route macros or ambiguous spells. Use target mode or focus mode with [@focus] macros to control behavior.'] = '기본 리디렉션은 매크로나 모호한 주문을 라우팅할 수 없습니다. 동작을 제어하려면 [@focus] 매크로와 함께 대상 모드나 초점 모드를 사용하십시오.';
L['Battery Level'] = '배터리 레벨';
L['Binding Catch Timeframe'] = '단축키 캡처 시간';
L['Blend Mode'] = '혼합 모드';
L['Blend mode of the artwork.'] = '아트워크의 혼합 모드.';
L['Blizzard_Collections'] = 'Blizzard_Collections';
L['Blizzard_DelvesCompanionConfiguration'] = 'Blizzard_DelvesCompanionConfiguration';
L['Blizzard_HelpPlate'] = 'Blizzard_HelpPlate';
L['Blizzard_HouseEditor'] = 'Blizzard_HouseEditor';
L['Blizzard_HousingTemplates'] = 'Blizzard_HousingTemplates';
L['Blizzard_MapCanvas'] = 'Blizzard_MapCanvas';
L['Blizzard_PlayerSpells'] = 'Blizzard_PlayerSpells';
L['Blizzard_PVPMatch'] = 'Blizzard_PVPMatch';
L['Blizzard_SharedMapDataProviders'] = 'Blizzard_SharedMapDataProviders';
L['Bluetooth'] = '블루투스';
L['Border Vertex Color'] = '테두리 정점 색상';
L['Breadth'] = '너비';
L['Breadth of the divider.'] = '구분 기호의 너비.';
L['Button %d'] = '버튼 %d';
L['Button or combination used to click when a given condition applies, but act as a normal binding otherwise.'] = '주어진 조건이 적용될 때 클릭에 사용되는 버튼 또는 조합, 그렇지 않으면 일반 단축키처럼 동작합니다.';
L['Button Set'] = '버튼 세트';
L['Button that emulates '] = '다음을 에뮬레이트하는 버튼: ';
L['Button that emulates the '] = '다음을 에뮬레이트하는 버튼: ';
L['Button to cancel or exit the quick menu.'] = '빠른 메뉴를 취소하거나 종료하는 버튼.';
L['Button to handle cancel actions, such as exiting menus.'] = '메뉴 종료 같은 취소 동작을 처리하는 버튼.';
L['Button to handle contextual actions, such as adding items to the utility ring or passing on loot.'] = '도구 원형 메뉴에 아이템 추가, 전리품 통과 등 상황별 동작을 처리하는 버튼.';
L['Button to handle contextual actions, such as adding items to the utility ring.'] = '도구 원형 메뉴에 아이템 추가 같은 상황별 동작을 처리하는 버튼.';
L['Button to insert suggested word.'] = '제안된 단어를 삽입하는 버튼.';
L['Button to move the cursor down.'] = '커서를 아래로 이동하는 버튼.';
L['Button to move the cursor left.'] = '커서를 왼쪽으로 이동하는 버튼.';
L['Button to move the cursor right.'] = '커서를 오른쪽으로 이동하는 버튼.';
L['Button to move the cursor up.'] = '커서를 위로 이동하는 버튼.';
L['Button to replicate left click. This is the primary interface action.'] = '좌클릭을 복제하는 버튼. 이것이 주 인터페이스 동작입니다.';
L['Button to replicate right click. This is the secondary interface action.'] = '우클릭을 복제하는 버튼. 이것이 보조 인터페이스 동작입니다.';
L['Button to select next suggested word.'] = '다음 제안 단어를 선택하는 버튼.';
L['Button to select previous suggested word.'] = '이전 제안 단어를 선택하는 버튼.';
L['Button to use for combo hotkey 1.'] = '조합 단축키 1에 사용할 버튼.';
L['Button to use for combo hotkey 2.'] = '조합 단축키 2에 사용할 버튼.';
L['Button to use for combo hotkey 3.'] = '조합 단축키 3에 사용할 버튼.';
L['Button to use for combo hotkey 4.'] = '조합 단축키 4에 사용할 버튼.';
L['Button to use for combo hotkey 5.'] = '조합 단축키 5에 사용할 버튼.';
L['Button to use for combo hotkey 6.'] = '조합 단축키 6에 사용할 버튼.';
L['Button to use for combo hotkey 7.'] = '조합 단축키 7에 사용할 버튼.';
L['Button to use for combo hotkey 8.'] = '조합 단축키 8에 사용할 버튼.';
L['Button to use to erase characters.'] = '문자를 지우는 데 사용할 버튼.';
L['Button to use to move the cursor leftwards.'] = '커서를 왼쪽으로 이동하는 데 사용할 버튼.';
L['Button to use to move the cursor rightwards.'] = '커서를 오른쪽으로 이동하는 데 사용할 버튼.';
L['Button to use to trigger the enter command.'] = 'Enter 명령을 실행하는 데 사용할 버튼.';
L['Button to use to trigger the escape command.'] = 'Esc 명령을 실행하는 데 사용할 버튼.';
L['Button to use to trigger the space command.'] = 'Space 명령을 실행하는 데 사용할 버튼.';
L['Button used to confirm a selected item from a ring.'] = '원형 메뉴에서 선택한 항목을 확인하는 데 사용되는 버튼.';
L['Button used to remove a selected item from an editable ring.'] = '편집 가능한 원형 메뉴에서 선택한 항목을 제거하는 데 사용되는 버튼.';
L['Button |cFF00FFFF%s|r'] = '버튼 |cFF00FFFF%s|r';
L['Buttons'] = '버튼';
L['Buttons emulating modifiers will instead trigger bindings when pressed and released within the time span.'] = '조합키를 에뮬레이트하는 버튼은 지정된 시간 내에 누르고 떼면 대신 단축키를 실행합니다.';
L['Buttons in the cluster bar.'] = '클러스터 바의 버튼.';
L['Buttons in the group.'] = '그룹의 버튼.';
L['By default, shows modifiers on mouseover and on cooldown.'] = '기본적으로 마우스 위로 가져갈 때와 재사용 대기시간 동안 조합키를 표시합니다.';
L['Camera 2D Deadzone'] = '카메라 2D 사용 안 함 구역';
L['Camera Look'] = '카메라 보기';
L['Camera Look is a temporary turn of the camera based on the current analog input.'] = '카메라 보기는 현재 아날로그 입력에 기반한 카메라의 임시 회전입니다.';
L['Camera Pitch Axis'] = '카메라 피치 축';
L['Camera Pitch Speed'] = '카메라 피치 속도';
L['Camera Pitch-Only Deadzone'] = '카메라 피치 전용 사용 안 함 구역';
L['Camera speed for pitch - moving up/down.'] = '피치에 대한 카메라 속도 — 위/아래로 이동.';
L['Camera speed for yaw - turning left/right.'] = '요에 대한 카메라 속도 — 왼쪽/오른쪽으로 회전.';
L['Camera Yaw Axis'] = '카메라 요 축';
L['Camera Yaw Speed'] = '카메라 요 속도';
L['Camera Yaw-Only Deadzone'] = '카메라 요 전용 사용 안 함 구역';
L['Cancel and clear cursor'] = '취소하고 커서 지우기';
L['Cancel Button'] = '취소 버튼';
L['Cannot open configuration menu in combat.'] = '전투 중에는 구성 메뉴를 열 수 없습니다.';
L['Casting Bar'] = '시전 막대';
L['Casting this spell without an assistable target opens the ring to pick the target.'] = '지원 가능한 대상 없이 이 주문을 시전하면 원형 메뉴가 열려 대상을 선택할 수 있습니다.';
L['Center Gap'] = '중앙 간격';
L['Center gap, as fraction of overall crosshair size.'] = '전체 십자선 크기에 대한 비율로서의 중앙 간격.';
L['Change before touchpad moves the cursor.'] = '터치패드가 커서를 움직이기 전의 임계값.';
L['Change bluetooth state for active device.'] = '활성 장치의 블루투스 상태 변경.';
L['Change how the raid cursor acquires a target. Redirect and focus modes will reroute appropriate spells without changing your target.'] = '공격대 커서가 대상을 획득하는 방법을 변경합니다. 리디렉션 및 초점 모드는 대상을 변경하지 않고 적절한 주문을 다시 라우팅합니다.';
L['Change or print a value from the active device configuration.'] = '활성 장치 구성에서 값 변경 또는 출력.';
L['Character Specific'] = '캐릭터별';
L['Choose a negative value to invert the axis.'] = '축을 반전하려면 음수 값을 선택하십시오.';
L['Class Bar'] = '직업 바';
L['Class Colored Health'] = '직업 색상 생명력';
L['Clear all items from this set.'] = '이 세트의 모든 항목 지우기.';
L['Clear Binding'] = '단축키 지우기';
L['Clear configured gamepad bindings and reload interface.'] = '구성된 게임패드 단축키를 지우고 인터페이스를 다시 불러옵니다.';
L['Clear Focus Deadzone'] = '초점 지우기 사용 안 함 구역';
L['Clear Focus Mode'] = '초점 지우기 모드';
L['Clear Focus Time'] = '초점 지우기 시간';
L['Clear Slot'] = '슬롯 비우기';
L['Clear slot or binding'] = '슬롯 또는 단축키 비우기';
L['Click here to reset your device profile.'] = '장치 프로필을 재설정하려면 여기를 클릭하십시오.';
L['Click on Down'] = '누를 때 클릭';
L['Click Override Button'] = '클릭 재정의 버튼';
L['Click Override Condition'] = '클릭 재정의 조건';
L['Cluster Action Bar'] = '클러스터 행동 단축바';
L['Cluster Handle'] = '클러스터 핸들';
L['Cluster Modifier Toggle'] = '클러스터 조합키 전환';
L['Clusters'] = '클러스터';
L['Color accent of radial menu items.'] = '원형 메뉴 항목의 색상 강조.';
L['Color of a partially selected slice.'] = '부분적으로 선택된 조각의 색상.';
L['Color of the active slice.'] = '활성 조각의 색상.';
L['Color of the cooldown swipe effect on buttons.'] = '버튼의 재사용 대기시간 스와이프 효과 색상.';
L['Color of the counter text on buttons.'] = '버튼의 카운터 텍스트 색상.';
L['Color of the crosshair.'] = '십자선의 색상.';
L['Color of the divider.'] = '구분 기호의 색상.';
L['Color of the hotkey text on buttons.'] = '버튼의 단축키 텍스트 색상.';
L['Color of the macro text on buttons.'] = '버튼의 매크로 텍스트 색상.';
L['Color of the main XP bar.'] = '주 경험치 막대의 색상.';
L['Color of the mana indicator on buttons.'] = '버튼의 마나 표시기 색상.';
L['Color of the range indicator on buttons.'] = '버튼의 사거리 표시기 색상.';
L['Color of the sticky selection slice.'] = '고정 선택 조각의 색상.';
L['Color of the vertices on the border of buttons.'] = '버튼 테두리 정점의 색상.';
L['Color the health bars in the target ring by class.'] = '대상 원형 메뉴의 생명력 바를 직업 색상으로 표시합니다.';
L['Color tint for combo hotkey 1.'] = '조합 단축키 1의 색조.';
L['Color tint for combo hotkey 2.'] = '조합 단축키 2의 색조.';
L['Color tint for combo hotkey 3.'] = '조합 단축키 3의 색조.';
L['Color tint for combo hotkey 4.'] = '조합 단축키 4의 색조.';
L['Color tint for combo hotkey 5.'] = '조합 단축키 5의 색조.';
L['Color tint for combo hotkey 6.'] = '조합 단축키 6의 색조.';
L['Color tint for combo hotkey 7.'] = '조합 단축키 7의 색조.';
L['Color tint for combo hotkey 8.'] = '조합 단축키 8의 색조.';
L['Combine with '] = '다음과 결합: ';
L['Combine with use on demand for full cursor control.'] = '완전한 커서 제어를 위해 「요청 시 사용」과 결합하십시오.';
L['Combined Input Overlap Time'] = '결합 입력 겹침 시간';
L['Combo Button 1'] = '조합 버튼 1';
L['Combo Button 2'] = '조합 버튼 2';
L['Combo Button 3'] = '조합 버튼 3';
L['Combo Button 4'] = '조합 버튼 4';
L['Combo Button 5'] = '조합 버튼 5';
L['Combo Button 6'] = '조합 버튼 6';
L['Combo Button 7'] = '조합 버튼 7';
L['Combo Button 8'] = '조합 버튼 8';
L['Combo Color 1'] = '조합 색상 1';
L['Combo Color 2'] = '조합 색상 2';
L['Combo Color 3'] = '조합 색상 3';
L['Combo Color 4'] = '조합 색상 4';
L['Combo Color 5'] = '조합 색상 5';
L['Combo Color 6'] = '조합 색상 6';
L['Combo Color 7'] = '조합 색상 7';
L['Combo Color 8'] = '조합 색상 8';
L['Command Modifier'] = '명령 조합키';
L['Configure the casting bar.'] = '시전 막대 구성.';
L['Configure the class related bar.'] = '직업 관련 바 구성.';
L['Connect your controller.'] = '컨트롤러를 연결하십시오.';
L['Connected device(s):'] = '연결된 장치:';
L['ConsolePort'] = 'ConsolePort';
L['Context Button'] = '상황별 버튼';
L['Controls the cutoff range where an interactable target or object can be found.'] = '상호작용 가능한 대상이나 오브젝트를 찾을 수 있는 차단 범위를 제어합니다.';
L['Controls when your character starts running. Expressed as a fraction of your total movement stick radius.'] = '캐릭터가 달리기를 시작하는 시점을 제어합니다. 전체 이동 스틱 반경의 비율로 표현됩니다.';
L['Controls when your character transitions from strafing to facing your movement stick direction while in combat. Expressed in degrees, from looking straight forward.'] = '전투 중 캐릭터가 측면 이동에서 이동 스틱 방향으로 회전하는 시점을 제어합니다. 정면 직진에서의 각도로 표현됩니다.';
L['Controls when your character transitions from strafing to facing your movement stick direction while in the air. Expressed in degrees, from looking straight forward.'] = '공중에서 캐릭터가 측면 이동에서 이동 스틱 방향으로 회전하는 시점을 제어합니다. 정면 직진에서의 각도로 표현됩니다.';
L['Controls when your character transitions from strafing to facing your movement stick direction. Expressed in degrees, from looking straight forward.'] = '캐릭터가 측면 이동에서 이동 스틱 방향으로 회전하는 시점을 제어합니다. 정면 직진에서의 각도로 표현됩니다.';
L['Copy %s from %s:'] = '%s에서 %s 복사:';
L['Copy this element to a new name.'] = '이 요소를 새 이름으로 복사.';
L['Correlation between stick position and pie selection.'] = '스틱 위치와 파이 선택 간의 상관관계.';
L['Create Binding Preset'] = '단축키 프리셋 만들기';
L['Critical, Low, Medium, High, Wired/Charging, or Unknown/Disconnected.'] = '위급, 낮음, 중간, 높음, 유선/충전 중 또는 알 수 없음/연결 끊김.';
L['Crossbar: Minimal'] = '크로스바: 최소';
L['Crossbar: Triggers'] = '크로스바: 트리거';
L['Crossbar: Triple'] = '크로스바: 삼중';
L['Crosshair'] = '십자선';
L['Cursor Acceleration'] = '커서 가속';
L['Cursor acceleration for touchpad control.'] = '터치패드 제어용 커서 가속.';
L['Cursor appears on demand, instead of in response to a panel showing up.'] = '커서가 패널이 나타날 때 반응하는 대신 요청 시 나타납니다.';
L['Cursor Center Position'] = '커서 중앙 위치';
L['Cursor hides when you start moving, if free of obstacles.'] = '장애물이 없으면 움직이기 시작할 때 커서가 숨겨집니다.';
L['Cursor Max Speed'] = '커서 최대 속도';
L['Cursor Move Threshold'] = '커서 이동 임계값';
L['Cursor Reticle Targeting'] = '커서 십자선 대상 지정';
L['Cursor Speed'] = '커서 속도';
L['Cursor speed for touchpad control.'] = '터치패드 제어용 커서 속도.';
L['Cursor Start Speed'] = '커서 시작 속도';
L['Custom color to use for the touchpad LED.'] = '터치패드 LED에 사용할 사용자 정의 색상.';
L['Cyan'] = '청록';
L['Deadzone for simple point-to-select rings.'] = '단순한 가리켜 선택 원형 메뉴용 사용 안 함 구역.';
L['Deadzone to clear focus after intercepting stick input.'] = '스틱 입력 차단 후 초점을 지우기 위한 사용 안 함 구역.';
L['Decrease'] = '감소';
L['Decrease lightness'] = '밝기 감소';
L['Decrease opacity'] = '투명도 감소';
L['Default to '] = '기본값: ';
L['Delay before reactivating interface cursor after leaving combat, in seconds.'] = '전투에서 벗어난 후 인터페이스 커서를 다시 활성화하기 전 지연(초).';
L['Delay before starting to adjust angle when camera control is idle, in seconds.'] = '카메라 제어가 유휴 상태일 때 각도 조정을 시작하기 전 지연(초).';
L['Delay is doubled if you are dead.'] = '죽었을 때 지연이 두 배가 됩니다.';
L['Delay until a movement is repeated, when holding down a direction, in seconds.'] = '방향을 누르고 있을 때 움직임이 반복되기까지의 지연(초).';
L['Delay until the first movement is repeated, when holding down a direction, in seconds.'] = '방향을 누르고 있을 때 첫 번째 움직임이 반복되기까지의 지연(초).';
L['Delete this element.'] = '이 요소 삭제.';
L['Depth'] = '깊이';
L['Depth of the divider.'] = '구분 기호의 깊이.';
L['Detected %d out of 8 possible sensors.'] = '가능한 8개 센서 중 %d개 감지됨.';
L['Detected %d valid button(s).'] = '유효한 버튼 %d개 감지됨.';
L['Device Information'] = '장치 정보';
L['Device Mappings'] = '장치 매핑';
L['Device Profiles'] = '장치 프로필';
L['Device Selection'] = '장치 선택';
L['Device Settings'] = '장치 설정';
L['Diamond Grid'] = '마름모 격자';
L['Dictionary Match Alphabet'] = '사전 일치 알파벳';
L['Dictionary Match Pattern'] = '사전 일치 패턴';
L['Direction for flyout buttons, such as portals, poisons, and pet utilities.'] = '포털, 독약, 소환수 도구 같은 펼침 버튼 방향.';
L['Direction of the button cluster.'] = '버튼 클러스터의 방향.';
L['Disable Drag and Drop'] = '드래그 앤 드롭 비활성화';
L['Disable dragging and dropping abilities on action bars.'] = '행동 단축바에서 능력의 드래그 앤 드롭 비활성화.';
L['Disable free-roaming mouse cursor when you jump.'] = '점프할 때 자유롭게 움직이는 마우스 커서 비활성화.';
L['Disable free-roaming mouse cursor when you use your sticks.'] = '스틱을 사용할 때 자유롭게 움직이는 마우스 커서 비활성화.';
L['Disable Hotkey Rendering'] = '단축키 렌더링 비활성화';
L['Disable if your mouse cursor is invisible.'] = '마우스 커서가 보이지 않으면 비활성화하십시오.';
L['Disable repeated cursor movements - each click will only move the cursor once.'] = '반복 커서 이동 비활성화 — 각 클릭은 커서를 한 번만 이동합니다.';
L['Disable Repeated Movement'] = '반복 이동 비활성화';
L['Disable to use discrete legacy movement controls.'] = '이산 레거시 이동 제어를 사용하려면 비활성화하십시오.';
L['Disable Wrapping'] = '감싸기 비활성화';
L['Disables customization to hotkeys on regular action bars.'] = '일반 행동 단축바의 단축키 사용자 정의를 비활성화합니다.';
L['Disabling this may cause worse performance with many panels open.'] = '이를 비활성화하면 패널이 많이 열렸을 때 성능이 저하될 수 있습니다.';
L['Disconnected'] = '연결 끊김';
L['Discord'] = 'Discord';
L['Display icon next to the power level for the current active gamepad.'] = '현재 활성 게임패드의 배터리 레벨 옆에 아이콘 표시.';
L['Display power level for the current active gamepad.'] = '현재 활성 게임패드의 배터리 레벨 표시.';
L['Display power level status text for the current active gamepad.'] = '현재 활성 게임패드의 배터리 레벨 상태 텍스트 표시.';
L['Display the action bar grid when picking up a spell on the cursor.'] = '커서에 주문을 들었을 때 행동 단축바 그리드 표시.';
L['Displays a briefing for newly acquired abilities.'] = '새로 획득한 능력에 대한 설명을 표시합니다.';
L['Divider'] = '구분 기호';
L['Do you want to load settings for %s?'] = '%s에 대한 설정을 불러오시겠습니까?';
L['Does not affect actual ability to interact with the target, which may have a different range.'] = '다른 사거리를 가질 수 있는 대상과 상호작용하는 실제 능력에는 영향을 주지 않습니다.';
L['Donate via PayPal'] = 'PayPal로 기부';
L['Double Tap Modifier'] = '더블 탭 조합키';
L['Double Tap Timeframe'] = '더블 탭 시간';
L['Duration after using gamepad and mouse at the same time before switching to just one or the other, in milliseconds.'] = '게임패드와 마우스를 동시에 사용한 후 한쪽으로만 전환하기 전의 지속 시간(밀리초).';
L['Duration under which a tooltip is displayed for an acquired target or interactable, in milliseconds.'] = '획득한 대상이나 상호작용 가능한 항목에 툴팁이 표시되는 지속 시간(밀리초).';
L['Dynamic Pitch'] = '동적 피치';
L['Dynamic will use the button set that does not conflict with your '] = '「동적」은 다음과 충돌하지 않는 버튼 세트를 사용합니다: ';
L['E.g. '] = '예: ';
L['Edit Binding'] = '단축키 편집';
L['Edit Slot'] = '슬롯 편집';
L['Emulate P1 '] = 'P1 에뮬레이트 ';
L['Emulate P2 '] = 'P2 에뮬레이트 ';
L['Emulate P3 '] = 'P3 에뮬레이트 ';
L['Emulate P4 '] = 'P4 에뮬레이트 ';
L['Emulate Pad 5'] = 'Pad 5 에뮬레이트';
L['Emulate Pad 6'] = 'Pad 6 에뮬레이트';
L['Emulate Pad Back'] = '뒤로 가기 에뮬레이트';
L['Emulate Pad Forward'] = '앞으로 가기 에뮬레이트';
L['Emulate Pad Social'] = '소셜 에뮬레이트';
L['Emulate Pad System'] = '시스템 에뮬레이트';
L['Enable all modifier states for the cluster, including unmapped modifiers.'] = '할당되지 않은 조합키를 포함하여 클러스터에 대한 모든 조합키 상태 활성화.';
L['Enable Animation'] = '애니메이션 활성화';
L['Enable casting bar ownership.'] = '시전 막대 소유권 활성화.';
L['Enable class bar ownership.'] = '직업 바 소유권 활성화.';
L['Enable Cooldown Numbers'] = '재사용 대기시간 숫자 활성화';
L['Enable custom mouse handling, automating cursor toggling and timeout while using left and right mouse button emulation.'] = '왼쪽 및 오른쪽 마우스 버튼 에뮬레이션을 사용하는 동안 커서 전환 및 시간 초과를 자동화하여 사용자 정의 마우스 처리 활성화.';
L['Enable Group Loot'] = '파티 전리품 활성화';
L['Enable interact key to interact with objects and creatures in the game world.'] = '게임 세계의 오브젝트 및 생물과 상호작용하도록 상호작용 키 활성화.';
L['Enable interface cursor. Disable to use mouse-based interface interaction.'] = '인터페이스 커서 활성화. 마우스 기반 인터페이스 상호작용을 사용하려면 비활성화하십시오.';
L['Enable Lazy Loading'] = '지연 로딩 사용';
L['Enable Mouse Handling'] = '마우스 처리 활성화';
L['Enable Player Interact'] = '플레이어 상호작용 활성화';
L['Enable Popups'] = '팝업 활성화';
L['Enable separate strafe angle threshold for when your character is in the air.'] = '캐릭터가 공중에 있을 때 별도의 측면 이동 각도 임계값 활성화.';
L['Enable Strafe Angle (Jump)'] = '측면 이동 각도 활성화 (점프)';
L['Enable Tint'] = '색조 활성화';
L['Enable touch tap to press touchpad buttons.'] = '터치패드 버튼을 누르도록 터치 탭 활성화.';
L['Enable Touchpad Cursor'] = '터치패드 커서 활성화';
L['Enable Vehicle'] = '탈것 활성화';
L['Enable Watch Bars'] = '감시 막대 활성화';
L['Enables a crosshair to reveal your hidden center cursor position at all times.'] = '숨겨진 중앙 커서 위치를 항상 표시하기 위한 십자선 활성화.';
L['Enables a radial on-screen keyboard that can be used to type messages.'] = '메시지를 입력하는 데 사용할 수 있는 방사형 화면 키보드 활성화.';
L['Enemy Soft Targeting'] = '적 부드러운 대상 지정';
L['Equippable items of poor quality will not be sold while your character is below this level.'] = '장착 가능한 저품질 아이템은 캐릭터가 이 레벨 미만일 때 판매되지 않습니다.';
L['Erase'] = '지우기';
L['Exit the vehicle you are currently controlling.'] = '현재 제어 중인 탈것에서 내립니다.';
L['Explicit only matches hard locked targets through using a targeting binding, while implicit matches targets you attack.'] = '명시적은 대상 지정 단축키를 통해 하드 고정된 대상만 일치시키는 반면, 묵시적은 공격하는 대상을 일치시킵니다.';
L['Export'] = '내보내기';
L['Export %s to a string:'] = '%s을(를) 문자열로 내보내기:';
L['Export action page logic'] = '동작 페이지 로직 내보내기';
L['Export All'] = '모두 내보내기';
L['Export all your custom presets to a string that can be shared with others.'] = '모든 사용자 정의 프리셋을 다른 사람과 공유할 수 있는 문자열로 내보냅니다.';
L['Export current options'] = '현재 옵션 내보내기';
L['Export serialized settings for sharing or backup.'] = '공유 또는 백업을 위해 직렬화된 설정 내보내기.';
L['Export this preset to a string that can be shared with others.'] = '이 프리셋을 다른 사람과 공유할 수 있는 문자열로 내보냅니다.';
L['Expressed in milliseconds. Pressing any combination of modifier and button will cancel the effect.'] = '밀리초로 표현됩니다. 조합키와 버튼의 모든 조합을 누르면 효과가 취소됩니다.';
L['Fade Buttons'] = '버튼 페이드';
L['Fade out the pet ring when not moused over.'] = '마우스를 올리지 않았을 때 소환수 원형 메뉴를 페이드 아웃합니다.';
L['Fade out the watch bars when not mousing over the toolbar.'] = '도구 모음에 마우스를 올리지 않았을 때 감시 막대를 페이드 아웃합니다.';
L['Fade Watch Bars'] = '감시 막대 페이드';
L['Filter Condition'] = '필터 조건';
L['Filter condition to find raid cursor frames, as a boolean expression in Lua.'] = 'Lua의 부울 표현식으로 공격대 커서 프레임을 찾기 위한 필터 조건.';
L['Flavor'] = '변형';
L['Flyout Direction'] = '펼침 방향';
L['FOAS Adjust Delay'] = 'FOAS 조정 지연';
L['FOAS Adjust Ease In'] = 'FOAS 이즈 인';
L['Follow On A Stick (FOAS)'] = 'Follow On A Stick (FOAS)';
L['Font Flags'] = '글꼴 플래그';
L['Font flags of the counter text on buttons.'] = '버튼의 카운터 텍스트 글꼴 플래그.';
L['Font flags of the hotkey text on buttons.'] = '버튼의 단축키 텍스트 글꼴 플래그.';
L['Font flags of the macro text on buttons.'] = '버튼의 매크로 텍스트 글꼴 플래그.';
L['Font size of the counter text on buttons.'] = '버튼의 카운터 텍스트 글꼴 크기.';
L['Font size of the hotkey text on buttons.'] = '버튼의 단축키 텍스트 글꼴 크기.';
L['Font size of the macro text on buttons.'] = '버튼의 매크로 텍스트 글꼴 크기.';
L['Font size of the ring slice buttons.'] = '원형 메뉴 조각 버튼의 글꼴 크기.';
L['Force Hard Target'] = '하드 대상 강제';
L['Frame level of the element.'] = '요소의 프레임 레벨.';
L['Frame Level Offset'] = '프레임 레벨 오프셋';
L['Frame level offset of the hotkey prompt, relative to the unit frame.'] = '유닛 프레임에 상대적인 단축키 안내의 프레임 레벨 오프셋.';
L['Frame strata of the element.'] = '요소의 프레임 계층.';
L['Free Cursor Timein'] = '자유 커서 진입 시간';
L['Frees your mouse cursor when used, if the cursor is currently center-fixed or hidden.'] = '커서가 현재 중앙 고정 또는 숨겨진 경우 사용 시 마우스 커서를 해제합니다.';
L['Friend Soft Targeting'] = '친구 부드러운 대상 지정';
L['Full State Modifier'] = '전체 상태 조합키';
L['Global color of the tint effect on the toolbar and dividers.'] = '도구 모음과 구분 기호의 색조 효과 전역 색상.';
L['Global Scale'] = '전역 크기';
L['Global Visibility'] = '전역 가시성';
L['Green'] = '녹색';
L['Grid'] = '격자';
L['Group buttons by modifier in a diamond layout.'] = '마름모 레이아웃의 조합키로 버튼 그룹화.';
L['Group buttons by modifier in a grid layout.'] = '격자 레이아웃의 조합키로 버튼 그룹화.';
L['Group buttons for left and right triggers, with modifier swapping.'] = '조합키 전환을 통해 왼쪽 및 오른쪽 트리거의 버튼 그룹화.';
L['Group buttons in a single crossbar layout, with modifier swapping.'] = '조합키 전환을 통해 단일 크로스바 레이아웃에서 버튼 그룹화.';
L['Group buttons in three layouts, with modifier swapping.'] = '조합키 전환을 통해 세 가지 레이아웃에서 버튼 그룹화.';
L['Groups button combinations in circular clusters which switch between different actions when modifiers are used.'] = '조합키가 사용될 때 다른 동작 사이를 전환하는 원형 클러스터로 버튼 조합을 그룹화합니다.';
L['Height of the artwork.'] = '아트워크의 높이.';
L['Height of the cluster bar.'] = '클러스터 바의 높이.';
L['Height of the crosshair, in scaled pixel units.'] = '조정된 픽셀 단위의 십자선 높이.';
L['Height of the group.'] = '그룹의 높이.';
L['Hide Cursor on Jump'] = '점프 시 커서 숨기기';
L['Hide Cursor On Movement'] = '이동 시 커서 숨기기';
L['Hide Cursor on Stick Input'] = '스틱 입력 시 커서 숨기기';
L['Hide Flyout Buttons'] = '펼침 버튼 숨기기';
L['Hide Macro Text'] = '매크로 텍스트 숨기기';
L['Hide the class bar.'] = '직업 바 숨기기.';
L['Hide the macro text on buttons.'] = '버튼의 매크로 텍스트 숨기기.';
L['Higher is slower.'] = '높을수록 느립니다.';
L['Higher values appear on top of lower values. Valid range 0-10000.'] = '높은 값이 낮은 값 위에 표시됩니다. 유효 범위 0-10000.';
L['Highlight Color'] = '강조 색상';
L['Horizontal Offset'] = '가로 오프셋';
L['Horizontal offset from anchor point.'] = '고정점으로부터의 가로 오프셋.';
L['Horizontal offset of the counter text on buttons.'] = '버튼의 카운터 텍스트 가로 오프셋.';
L['Horizontal offset of the hotkey icon on group buttons.'] = '그룹 버튼의 단축키 아이콘 가로 오프셋.';
L['Horizontal offset of the hotkey prompt position, in pixels.'] = '픽셀 단위의 단축키 안내 위치 가로 오프셋.';
L['Horizontal offset of the hotkey text on buttons.'] = '버튼의 단축키 텍스트 가로 오프셋.';
L['Horizontal offset of the macro text on buttons.'] = '버튼의 매크로 텍스트 가로 오프셋.';
L['Horizontal Padding'] = '가로 여백';
L['Hotkey Anchor'] = '단축키 고정점';
L['Hotkey Offset X'] = '단축키 오프셋 X';
L['Hotkey Offset Y'] = '단축키 오프셋 Y';
L['Hotkey prompts appear on applicable name plates.'] = '해당하는 이름판에 단축키 안내가 표시됩니다.';
L['Hotkey prompts linger on unit frames after targeting.'] = '대상 지정 후 유닛 프레임에 단축키 안내가 남아 있습니다.';
L['Hotkey Relative Anchor'] = '단축키 상대 고정점';
L['Hotkey Size'] = '단축키 크기';
L['Hotkeys activate their target immediately.'] = '단축키가 즉시 대상을 활성화합니다.';
L['Hotkeys always target the same unit.'] = '단축키가 항상 같은 유닛을 대상으로 합니다.';
L['Hotkeys control your focus target instead of your current target.'] = '단축키가 현재 대상 대신 주시 대상을 제어합니다.';
L['Hotkeys use '] = '단축키가 다음을 사용합니다: ';
L['How long the cursor should take to transition from one node to another.'] = '커서가 한 노드에서 다른 노드로 전환하는 데 걸리는 시간.';
L['How to clear focus after intercepting stick input.'] = '스틱 입력 차단 후 초점을 지우는 방법.';
L['Import serialized preset(s) from an external source.'] = '외부 소스에서 직렬화된 프리셋을 가져옵니다.';
L['Import serialized preset(s):'] = '직렬화된 프리셋 가져오기:';
L['Import serialized settings from an external source.'] = '외부 소스에서 직렬화된 설정을 가져옵니다.';
L['Inactive Opacity'] = '비활성 투명도';
L['Include the current action page logic in the preset data.'] = '현재 동작 페이지 로직을 프리셋 데이터에 포함합니다.';
L['Include the current options from the %s tab in the preset data.'] = '%s 탭의 현재 옵션을 프리셋 데이터에 포함합니다.';
L['Increase'] = '증가';
L['Increase lightness'] = '밝기 증가';
L['Increase opacity'] = '투명도 증가';
L['Insert Suggestion'] = '제안 삽입';
L['Intensity'] = '강도';
L['Intensity of the gradient.'] = '그라데이션의 강도.';
L['Interface Cursor'] = '인터페이스 커서';
L['Interference'] = '간섭';
L['Inverted'] = '반전됨';
L['Join Discord'] = 'Discord 참여';
L['Keeps your character centered to reduce motion sickness.'] = '멀미를 줄이기 위해 캐릭터를 중앙에 유지합니다.';
L['Key %d'] = '키 %d';
L['Keyboard button to emulate the back button.'] = '뒤로 가기 버튼을 에뮬레이트할 키보드 키.';
L['Keyboard button to emulate the forward button.'] = '앞으로 가기 버튼을 에뮬레이트할 키보드 키.';
L['Keyboard button to emulate the pad 5 button.'] = '패드 5 버튼을 에뮬레이트할 키보드 키.';
L['Keyboard button to emulate the pad 6 button.'] = '패드 6 버튼을 에뮬레이트할 키보드 키.';
L['Keyboard button to emulate the social button.'] = '소셜 버튼을 에뮬레이트할 키보드 키.';
L['Keyboard button to emulate the system button.'] = '시스템 버튼을 에뮬레이트할 키보드 키.';
L['Keyboard'] = '키보드';
L['Keyboard button to emulate the paddle 1 button.'] = '패들 1 버튼을 에뮬레이트할 키보드 키.';
L['Keyboard button to emulate the paddle 2 button.'] = '패들 2 버튼을 에뮬레이트할 키보드 키.';
L['Keyboard button to emulate the paddle 3 button.'] = '패들 3 버튼을 에뮬레이트할 키보드 키.';
L['Keyboard button to emulate the paddle 4 button.'] = '패들 4 버튼을 에뮬레이트할 키보드 키.';
L['Keyboard Layout Editor'] = '키보드 레이아웃 편집기';
L['Larger value for easier taps.'] = '쉬운 탭을 위해 더 큰 값.';
L['Layout'] = '레이아웃';
L['Lazy loading has been disabled to activate the raid cursor.'] = '공격대 커서를 활성화하기 위해 지연 로딩이 비활성화되었습니다.';
L['Lazy loading has been disabled to activate the target ring.'] = '대상 원형 메뉴를 활성화하기 위해 지연 로딩이 비활성화되었습니다.';
L['Lazy loading has been disabled to activate unit hotkeys.'] = '유닛 단축키를 활성화하기 위해 지연 로딩이 비활성화되었습니다.';
L['LED Color Type'] = 'LED 색상 유형';
L['LED Custom Color'] = 'LED 사용자 정의 색상';
L['Left mouse button emulation toggles center-fixed mode instead of free-roaming mode. Right mouse button emulation toggles free-roaming mode instead of center-fixed mode.'] = '왼쪽 마우스 버튼 에뮬레이션은 자유롭게 움직이는 모드 대신 중앙 고정 모드를 전환합니다. 오른쪽 마우스 버튼 에뮬레이션은 중앙 고정 모드 대신 자유롭게 움직이는 모드를 전환합니다.';
L['Load'] = '불러오기';
L['Loaded binding preset %s.'] = '단축키 프리셋 %s을(를) 불러왔습니다.';
L['Loadout'] = '로드아웃';
L['Lock Automatic Tooltip'] = '자동 툴팁 잠금';
L['Looks like a regular action bar, but shows the button combination rather than the action slot.'] = '일반 행동 단축바처럼 보이지만, 동작 슬롯 대신 버튼 조합을 표시합니다.';
L['Lua pattern to match words for dictionary lookups.'] = '사전 조회를 위한 단어와 일치시키는 Lua 패턴.';
L['Macro condition to automatically load a binding preset by name when the condition applies.'] = '조건이 충족되면 이름으로 단축키 프리셋을 자동으로 불러오는 매크로 조건입니다.';
L['Macro condition to enable the click override button. The default condition clicks right mouse button when there is no enemy target.'] = '클릭 재정의 버튼을 활성화하는 매크로 조건. 기본 조건은 적 대상이 없을 때 마우스 우클릭을 합니다.';
L['Macro condition to evaluate action bar page.'] = '행동 단축바 페이지를 평가하는 매크로 조건.';
L['Macro condition to override the strafe angle threshold for combat.'] = '전투용 측면 이동 각도 임계값을 재정의하는 매크로 조건.';
L['Macro condition to override the strafe angle threshold for travel.'] = '이동용 측면 이동 각도 임계값을 재정의하는 매크로 조건.';
L['Macro Text'] = '매크로 텍스트';
L['Main Button Border Style'] = '주 버튼 테두리 스타일';
L['Maintain offset relative to scale.'] = '크기에 상대적인 오프셋 유지.';
L['Make sure your choice does not conflict with your bindings.'] = '선택이 단축키와 충돌하지 않는지 확인하십시오.';
L['Make this preset the default layout for all new characters.'] = '이 프리셋을 모든 새 캐릭터의 기본 레이아웃으로 만듭니다.';
L['Match appropriate soft target to locked target.'] = '적절한 부드러운 대상을 잠긴 대상과 일치시킵니다.';
L['Max Pitch'] = '최대 피치';
L['Max time for a touch to register a tap/click, in milliseconds.'] = '터치가 탭/클릭으로 등록되는 최대 시간(밀리초).';
L['Max Yaw'] = '최대 요';
L['Maximum Pitch adjust for the camera "look" feature.'] = '카메라 「보기」 기능의 최대 피치 조정.';
L['Maximum Yaw adjust for the camera "look" feature.'] = '카메라 「보기」 기능의 최대 요 조정.';
L['Menu buttons to display on the toolbar.'] = '도구 모음에 표시할 메뉴 버튼.';
L['Micro Menu'] = '마이크로 메뉴';
L['Minimal Interact Nameplate Tooltip'] = '최소 상호작용 이름판 툴팁';
L['Modifications'] = '수정 사항';
L['Modifier'] = '조합키';
L['Modifier 1: Shift'] = '조합키 1: Shift';
L['Modifier 2: Ctrl'] = '조합키 2: Ctrl';
L['Modifier 3: Alt'] = '조합키 3: Alt';
L['Modifier Tap Window'] = '조합키 탭 창';
L['Modifiers'] = '조합키';
L['Modifiers should be in descending order. M2M1, for example, is the Ctrl and Shift modifiers held at the same time.'] = '조합키는 내림차순이어야 합니다. 예를 들어 M2M1은 Ctrl과 Shift 조합키를 동시에 누르는 것입니다.';
L['Mouseover Cast'] = '마우스오버 시전';
L['Move Left'] = '왼쪽으로 이동';
L['Move one of the sticks.'] = '스틱 중 하나를 움직이십시오.';
L['Move Right'] = '오른쪽으로 이동';
L['Move the frame with the sticks or the mouse. Confirm to save, cancel to restore.'] = '스틱이나 마우스로 프레임을 이동합니다. 확인하면 저장되고 취소하면 복원됩니다.';
L['Movement Deadzone'] = '이동 사용 안 함 구역';
L['Movement is analog, translated from your movement stick angle.'] = '이동은 아날로그이며, 이동 스틱 각도에서 변환됩니다.';
L['Movement X Axis'] = '이동 X 축';
L['Movement Y Axis'] = '이동 Y 축';
L['Needs to be long enough to press and release the button.'] = '버튼을 누르고 떼기에 충분히 길어야 합니다.';
L['Nested Rings'] = '중첩된 원형 메뉴';
L['Next Word'] = '다음 단어';
L['No axis input detected yet.'] = '축 입력이 아직 감지되지 않았습니다.';
L['No binding preset named %s exists.'] = '%s(이)라는 단축키 프리셋이 없습니다.';
L['No button input detected yet.'] = '버튼 입력이 아직 감지되지 않았습니다.';
L['No buttons were detected during the test.'] = '테스트 중에 버튼이 감지되지 않았습니다.';
L['No sensors were detected.'] = '센서가 감지되지 않았습니다.';
L['Normal background color of pie slices.'] = '파이 조각의 일반 배경 색상.';
L['Normal Color'] = '일반 색상';
L['Nudge Modifier'] = '넛지 조합키';
L['Number of buttons in the page.'] = '페이지의 버튼 수.';
L['Number of buttons per row or column.'] = '행 또는 열당 버튼 수.';
L['Offset'] = '오프셋';
L['Offset of pointer arrow, from the selected node center, in pixels.'] = '픽셀 단위로, 선택된 노드 중심에서 포인터 화살표의 오프셋.';
L['Offset X'] = '오프셋 X';
L['Offset Y'] = '오프셋 Y';
L['Offsets the camera horizontally from your character, for a more cinematic view.'] = '더 영화 같은 시점을 위해 캐릭터에서 카메라를 수평으로 이동합니다.';
L['Only recommended for super users.'] = '고급 사용자에게만 권장됩니다.';
L['Only use taps for cursor clicks, do not use tap presses.'] = '커서 클릭에 탭만 사용하고 탭 누름은 사용하지 마십시오.';
L['Opacity is expressed in percentage, where 100 is fully visible and 0 is fully transparent. Values outside of the 0-100 range will be clamped.'] = '투명도는 백분율로 표현되며, 100은 완전히 보이고 0은 완전히 투명합니다. 0-100 범위를 벗어난 값은 제한됩니다.';
L['Opacity of inactive hotkey prompts on unit frames after targeting.'] = '대상 지정 후 유닛 프레임의 비활성 단축키 안내 투명도.';
L['Open Designer'] = '디자이너 열기';
L['Open Main Config'] = '메인 구성 열기';
L['Open the configuration menu for the action bar.'] = '행동 단축바의 구성 메뉴를 엽니다.';
L['Open the main configuration window.'] = '메인 구성 창을 엽니다.';
L['Open the main edit mode window.'] = '메인 편집 모드 창을 엽니다.';
L['Open the unit menu for the target unit.'] = '대상 유닛의 유닛 메뉴를 엽니다.';
L['Open unit menu when interacting with other players.'] = '다른 플레이어와 상호작용할 때 유닛 메뉴를 엽니다.';
L['Optimize Algorithm'] = '알고리즘 최적화';
L['or'] = '또는';
L['Orientation of the page.'] = '페이지의 방향.';
L['Orthodox'] = '정통';
L['Out of Mana Color'] = '마나 부족 색상';
L['Out of Range Color'] = '사거리 초과 색상';
L['Outcome'] = '결과';
L['Over Shoulder'] = '어깨 너머';
L['Override'] = '재정의';
L['Override Class File'] = '재정의 직업 파일';
L['Override class theme for interface styling.'] = '인터페이스 스타일링용 직업 테마 재정의.';
L['Padding between buttons horizontally.'] = '버튼 사이의 가로 여백.';
L['Padding between buttons vertically.'] = '버튼 사이의 세로 여백.';
L['Page'] = '페이지';
L['Page Condition'] = '페이지 조건';
L['Page Hotkeys'] = '페이지 단축키';
L['Page Response'] = '페이지 응답';
L['Page |cFF00FFFF%s|r'] = '페이지 |cFF00FFFF%s|r';
L['Patreon'] = 'Patreon';
L['PayPal'] = 'PayPal';
L['Performs an action and closes the menu.'] = '동작을 수행하고 메뉴를 닫습니다.';
L['Performs an action without closing the menu.'] = '메뉴를 닫지 않고 동작을 수행합니다.';
L['Pet Ring'] = '소환수 원형 메뉴';
L['Pet Ring Position'] = '소환수 원형 메뉴 위치';
L['Pet Ring Stick'] = '소환수 원형 메뉴 스틱';
L['Pick up'] = '줍기';
L['Pickup'] = '픽업';
L['Pitch Axis'] = '피치 축';
L['Pitch-only deadzone for camera, applied before the 2D deadzone.'] = '2D 사용 안 함 구역 이전에 적용되는 카메라용 피치 전용 사용 안 함 구역.';
L['Pitches the camera upwards as you zoom out.'] = '줌 아웃하면 카메라가 위쪽으로 기울어집니다.';
L['Place in slot'] = '슬롯에 배치';
L['Place on action bar'] = '행동 단축바에 배치';
L['Play a sound when the pointer arrow reaches its destination.'] = '포인터 화살표가 목적지에 도달하면 소리를 재생합니다.';
L['Please provide a unique name for a new %s in %s:'] = '%s의 새 %s에 대한 고유한 이름을 제공하십시오:';
L['Plural Button'] = '복수 버튼';
L['Pointer arrow rotates in the direction of travel, and portraits scale up and down on movement.'] = '포인터 화살표가 이동 방향으로 회전하고, 초상화가 움직임에 따라 확대/축소됩니다.';
L['Pointer arrow rotates in the direction of travel.'] = '포인터 화살표가 이동 방향으로 회전합니다.';
L['Pointer Offset'] = '포인터 오프셋';
L['Pointer Size'] = '포인터 크기';
L['Position'] = '위치';
L['Position of the artwork.'] = '아트워크의 위치.';
L['Position of the button cluster.'] = '버튼 클러스터의 위치.';
L['Position of the button.'] = '버튼의 위치.';
L['Position of the class bar.'] = '직업 바의 위치.';
L['Position of the cluster bar.'] = '클러스터 바의 위치.';
L['Position of the divider.'] = '구분 기호의 위치.';
L['Position of the element.'] = '요소의 위치.';
L['Position of the group.'] = '그룹의 위치.';
L['Position of the page.'] = '페이지의 위치.';
L['Position of the pet ring.'] = '소환수 원형 메뉴의 위치.';
L['Position of the toolbar.'] = '도구 모음의 위치.';
L['Power Level'] = '배터리 레벨';
L['Preferred size of radial menus, in pixels.'] = '픽셀 단위의 원형 메뉴 선호 크기.';
L['Preset Load Condition'] = '프리셋 불러오기 조건';
L['Presets'] = '프리셋';
L['Press and Hold'] = '누르고 유지';
L['Press your gamepad buttons to test them.'] = '게임패드 버튼을 눌러 테스트하십시오.';
L['Prevent the cursor from wrapping when navigating.'] = '탐색 시 커서가 감싸지지 않도록 합니다.';
L['Previous Word'] = '이전 단어';
L['Primary accept button, to use or confirm a quick menu action.'] = '빠른 메뉴 동작을 사용하거나 확인하기 위한 주 수락 버튼.';
L['Primary Button'] = '주 버튼';
L['Primary Stick'] = '주 스틱';
L['Prioritize raid cursor bindings over other override bindings.'] = '공격대 커서 단축키를 다른 재정의 단축키보다 우선시.';
L['Priority Override'] = '우선순위 재정의';
L['Purple'] = '보라';
L['Quick Menu'] = '빠른 메뉴';
L['Radial Menus'] = '원형 메뉴';
L['Raid Cursor'] = '공격대 커서';
L['Re-apply config for the active device.'] = '활성 장치의 구성을 다시 적용합니다.';
L['Reactivation Delay'] = '재활성화 지연';
L['Realm'] = '서버';
L['Recharge'] = '재충전';
L['Recommended as first choice modifier.'] = '첫 번째 조합키로 권장됨.';
L['Recommended as second choice modifier.'] = '두 번째 조합키로 권장됨.';
L['Reduces unexpected camera movement to reduce motion sickness.'] = '멀미를 줄이기 위해 예기치 않은 카메라 움직임을 줄입니다.';
L['Regenerate Dictionary'] = '사전 재생성';
L['Regular'] = '일반';
L['Relative Anchor'] = '상대 고정점';
L['Relative anchor point of the counter text on buttons.'] = '버튼의 카운터 텍스트 상대 고정점.';
L['Relative anchor point of the hotkey icon on group buttons.'] = '그룹 버튼의 단축키 아이콘 상대 고정점.';
L['Relative anchor point of the hotkey text on buttons.'] = '버튼의 단축키 텍스트 상대 고정점.';
L['Relative anchor point of the macro text on buttons.'] = '버튼의 매크로 텍스트 상대 고정점.';
L['Relative Rescale'] = '상대 크기 재조정';
L['Reload'] = '다시 불러오기';
L['Remove all saved settings and bindings, disable addon, and reload interface.'] = '저장된 모든 설정과 단축키 제거, 애드온 비활성화 및 인터페이스 다시 불러오기.';
L['Remove all saved settings and reload interface.'] = '저장된 모든 설정 제거 및 인터페이스 다시 불러오기.';
L['Remove Button'] = '제거 버튼';
L['Remove from %s'] = '%s에서 제거';
L['Remove this set. This action cannot be undone.'] = '이 세트를 제거합니다. 이 작업은 취소할 수 없습니다.';
L['Removes the tooltip background for a minimalistic look.'] = '미니멀한 모양을 위해 툴팁 배경을 제거합니다.';
L['Repeated Movement Delay'] = '반복 이동 지연';
L['Repeated Movement First Delay'] = '반복 이동 첫 번째 지연';
L['Replaces the default loot frame with a custom version optimized for controller navigation.'] = '컨트롤러 탐색에 최적화된 사용자 정의 버전으로 기본 전리품 프레임을 대체합니다.';
L['Request early landing from the taxi you are currently riding.'] = '현재 타고 있는 비행기에서 조기 착륙을 요청합니다.';
L['Requires /reload to fully unhook when disabled.'] = '비활성화 시 완전히 분리하려면 /reload가 필요합니다.';
L['Requires a touchpad with LED support.'] = 'LED를 지원하는 터치패드가 필요합니다.';
L['Requires reload.'] = '다시 불러오기가 필요합니다.';
L['Requires Settings > Hide Cursor on Stick Input set to None.'] = '설정 > 스틱 입력 시 커서 숨기기가 「없음」으로 설정되어야 합니다.';
L['Requires the mouseover cast option in the game combat settings.'] = '게임 전투 설정의 마우스오버 시전 옵션이 필요합니다.';
L['Requires Toggle Interface Cursor binding to use the cursor.'] = '커서를 사용하려면 「인터페이스 커서 전환」 단축키가 필요합니다.';
L['Reset all mapping configurations and reload. (will not affect bindings)'] = '모든 매핑 구성 재설정 및 다시 불러오기. (단축키에는 영향을 주지 않음)';
L['Response to condition for custom processing.'] = '사용자 정의 처리를 위한 조건에 대한 응답.';
L['Reticle targeting means anything you place on the ground.'] = '십자선 대상 지정은 지면에 배치하는 모든 것을 의미합니다.';
L['Reticle targeting uses free cursor instead of staying center-fixed.'] = '십자선 대상 지정은 중앙 고정 상태로 있는 대신 자유 커서를 사용합니다.';
L['Return Button'] = '돌아가기 버튼';
L['Returns to the previous menu.'] = '이전 메뉴로 돌아갑니다.';
L['Reverse Mouse Handling'] = '마우스 처리 반전';
L['Reverse Order'] = '순서 반전';
L['Reverse the order of the buttons.'] = '버튼 순서를 반전합니다.';
L['Ring Manager'] = '원형 메뉴 관리자';
L['Ring Scale'] = '원형 메뉴 크기';
L['Ring Size'] = '원형 메뉴 크기';
L['Rings'] = '원형 메뉴';
L['Rings (Account)'] = '원형 메뉴 (계정)';
L['Rings (Character)'] = '원형 메뉴 (캐릭터)';
L['Rotation'] = '회전';
L['Rotation of the divider.'] = '구분 기호의 회전.';
L['Run / Walk Threshold'] = '달리기/걷기 임계값';
L['Run Tests'] = '테스트 실행';
L['Save as default'] = '기본값으로 저장';
L['Save preset from %s:'] = '%s에서 프리셋 저장:';
L['Save your current loadout to the preset list.'] = '현재 로드아웃을 프리셋 목록에 저장합니다.';
L['Scale of all radial menus, relative to UI scale.'] = 'UI 크기에 상대적인 모든 원형 메뉴의 크기.';
L['Scale of most ConsolePort frames, relative to UI scale.'] = 'UI 크기에 상대적인 대부분의 ConsolePort 프레임 크기.';
L['Scale of the cursor.'] = '커서의 크기.';
L['Scale of the game menu and radial companion.'] = '게임 메뉴와 방사형 동반자의 크기.';
L['Scale of the keyboard.'] = '키보드의 크기.';
L['Scale of the pet ring.'] = '소환수 원형 메뉴의 크기.';
L['Screen position of the ring.'] = '원형 메뉴의 화면 위치입니다.';
L['Secondary accept button, to use or confirm a quick menu action.'] = '빠른 메뉴 동작을 사용하거나 확인하기 위한 보조 수락 버튼.';
L['Select a device from the list to continue.'] = '계속하려면 목록에서 장치를 선택하십시오.';
L['Select a slot to bind %s and place this spell.'] = '%s을(를) 할당하고 이 주문을 배치할 슬롯을 선택하십시오.';
L['Select a slot to place this spell.'] = '이 주문을 배치할 슬롯을 선택하십시오.';
L['Select the device you want to configure.'] = '구성하려는 장치를 선택하십시오.';
L['Select the device you want to use.'] = '사용하려는 장치를 선택하십시오.';
L['Selecting an item on a ring will stick until another item is chosen.'] = '원형 메뉴에서 항목을 선택하면 다른 항목이 선택될 때까지 유지됩니다.';
L['Sensors'] = '센서';
L['Set %d |cFF757575(%s)|r'] = '세트 %d |cFF757575(%s)|r';
L['Set binding'] = '단축키 설정';
L['Sets if range should be a hard cutoff, even for something you can interact with.'] = '상호작용할 수 있는 것에 대해서도 사거리가 하드 컷오프여야 하는지 설정합니다.';
L['Shift-click to Edit Binding'] = '단축키 편집은 Shift+클릭';
L['Shift-right-click to Clear Binding'] = '단축키 지우기는 Shift+우클릭';
L['Show a color tint on the toolbar.'] = '도구 모음에 색조 표시.';
L['Show Ability Briefings'] = '능력 설명 표시';
L['Show Action Bar Grid on Spell Pickup'] = '주문 줍기 시 행동 단축바 그리드 표시';
L['Show active buffs in the quick menu.'] = '빠른 메뉴에 활성 버프 표시.';
L['Show active debuffs in the quick menu.'] = '빠른 메뉴에 활성 디버프 표시.';
L['Show All Action Bars'] = '모든 행동 단축바 표시';
L['Show all enabled combinations in the cluster at all times.'] = '클러스터에서 활성화된 모든 조합을 항상 표시.';
L['Show bonus bar configuration for characters without stances.'] = '자세가 없는 캐릭터의 보너스 바 구성 표시.';
L['Show Centered Cursor Tooltip'] = '중앙 커서 툴팁 표시';
L['Show connected devices.'] = '연결된 장치 표시.';
L['Show Default Button'] = '기본 버튼 표시';
L['Show Enemy Nameplate'] = '적 이름판 표시';
L['Show Enemy Target Icon'] = '적 대상 아이콘 표시';
L['Show Enemy Tooltip'] = '적 툴팁 표시';
L['Show Flyout Buttons'] = '펼침 버튼 표시';
L['Show Flyouts'] = '펼침 표시';
L['Show Friendly Nameplate'] = '우호 이름판 표시';
L['Show Friendly Target Icon'] = '우호 대상 아이콘 표시';
L['Show Friendly Tooltip'] = '우호 툴팁 표시';
L['Show Gauge'] = '게이지 표시';
L['Show group loot rolls in the quick menu, allowing you to roll on items using gamepad buttons while in combat.'] = '빠른 메뉴에 파티 전리품 굴림 표시. 전투 중에 게임패드 버튼으로 아이템 굴림 가능.';
L['Show help for command(s).'] = '명령에 대한 도움말 표시.';
L['Show Hotkeys'] = '단축키 표시';
L['Show icon above the current enemy soft target.'] = '현재 부드러운 적 대상 위에 아이콘 표시.';
L['Show icon above the current friendly soft target.'] = '현재 부드러운 우호 대상 위에 아이콘 표시.';
L['Show icon above the current interactable object.'] = '현재 상호작용 가능한 오브젝트 위에 아이콘 표시.';
L['Show icon above the current interactable target.'] = '현재 상호작용 가능한 대상 위에 아이콘 표시.';
L['Show interact binding hint on interactables.'] = '상호작용 가능한 항목에 상호작용 단축키 힌트 표시.';
L['Show Interact Hint'] = '상호작용 힌트 표시';
L['Show interact tooltip on nameplates, when applicable.'] = '해당하는 경우 이름판에 상호작용 툴팁 표시.';
L['Show item type in the quick menu.'] = '빠른 메뉴에 아이템 유형 표시.';
L['Show Main Icons'] = '주 아이콘 표시';
L['Show Modifier Icons'] = '조합키 아이콘 표시';
L['Show numerical cooldown text on buttons.'] = '버튼에 숫자 재사용 대기시간 텍스트 표시.';
L['Show Object Icon'] = '오브젝트 아이콘 표시';
L['Show on Name Plates'] = '이름판에 표시';
L['Show pet action bar in the quick menu.'] = '빠른 메뉴에 소환수 행동 단축바 표시.';
L['Show ping commands in the quick menu.'] = '빠른 메뉴에 핑 명령 표시.';
L['Show Portrait'] = '초상화 표시';
L['Show portrait for the current unit, with health percentage and applicable spell casts.'] = '현재 유닛의 초상화와 생명력 백분율, 해당 주문 시전을 표시.';
L['Show Status Text'] = '상태 텍스트 표시';
L['Show Target Icon'] = '대상 아이콘 표시';
L['Show the default mouse action button.'] = '기본 마우스 동작 버튼 표시.';
L['Show the empty buttons in the page.'] = '페이지의 빈 버튼 표시.';
L['Show the flyout of small buttons for the button cluster.'] = '버튼 클러스터의 작은 버튼 펼침 표시.';
L['Show the hotkeys on the buttons.'] = '버튼에 단축키 표시.';
L['Show the icons for main buttons.'] = '주 버튼의 아이콘 표시.';
L['Show the icons for modifier buttons.'] = '조합키 버튼의 아이콘 표시.';
L['Show the pet power and health status.'] = '소환수의 힘과 생명력 상태 표시.';
L['Show the pet ring when in a vehicle.'] = '탈것을 탔을 때 소환수 원형 메뉴 표시.';
L['Show the watch bars at the bottom of the toolbar.'] = '도구 모음 하단에 감시 막대 표시.';
L['Show Tooltip'] = '툴팁 표시';
L['Show tooltip for enemy target.'] = '적 대상의 툴팁 표시.';
L['Show tooltip for friendly target.'] = '우호 대상의 툴팁 표시.';
L['Show tooltip for interactables.'] = '상호작용 가능한 항목의 툴팁 표시.';
L['Show tooltip for mouseover targets when cursor is centered.'] = '커서가 중앙에 있을 때 마우스 오버 대상의 툴팁 표시.';
L['Show tooltips on buttons when moused over.'] = '마우스를 올렸을 때 버튼에 툴팁 표시.';
L['Show Type Icon'] = '유형 아이콘 표시';
L['Size of pointer arrow, in pixels.'] = '픽셀 단위의 포인터 화살표 크기.';
L['Size of the button cluster.'] = '버튼 클러스터의 크기.';
L['Size of the hotkey icon on group buttons.'] = '그룹 버튼의 단축키 아이콘 크기.';
L['Size of unit hotkeys, in pixels.'] = '픽셀 단위의 유닛 단축키 크기.';
L['Space'] = '스페이스';
L['Speed of cursor when it starts moving.'] = '움직이기 시작할 때의 커서 속도.';
L['Split stack'] = '묶음 분할';
L['Start moving the configuration window.'] = '구성 창 이동 시작.';
L['Starting point of the page.'] = '페이지의 시작점.';
L['Status Bar'] = '상태 막대';
L['Stick to use for main radial actions.'] = '주 방사형 동작에 사용할 스틱.';
L['Stick to use for the pet ring. Default follows the radial menu primary stick.'] = '소환수 원형 메뉴에 사용할 스틱입니다. 기본값은 원형 메뉴의 기본 스틱을 따릅니다.';
L['Stick to use for this ring. Default follows the radial menu primary stick.'] = '이 원형 메뉴에 사용할 스틱입니다. 기본값은 원형 메뉴의 기본 스틱을 따릅니다.';
L['Sticky Color'] = '고정 색상';
L['Sticky Selection'] = '고정 선택';
L['Strafe Angle (Combat)'] = '측면 이동 각도 (전투)';
L['Strafe Angle (Jump)'] = '측면 이동 각도 (점프)';
L['Strafe Angle (Travel)'] = '측면 이동 각도 (이동)';
L['Strafe Angle Macro Condition (Combat)'] = '측면 이동 각도 매크로 조건 (전투)';
L['Strafe Angle Macro Condition (Travel)'] = '측면 이동 각도 매크로 조건 (이동)';
L['Strata'] = '계층';
L['Stride'] = '보폭';
L['Style of the border around main buttons.'] = '주 버튼 주위 테두리 스타일.';
L['Support on Patreon'] = 'Patreon에서 후원';
L['Swap to a specified action bar layout.'] = '지정된 행동 단축바 레이아웃으로 전환.';
L['Swipe Color'] = '스와이프 색상';
L['Switch Button'] = '전환 버튼';
L['Switches between the main menu and the radial companion.'] = '메인 메뉴와 방사형 동반자 사이를 전환합니다.';
L['Synchronize Bindings'] = '단축키 동기화';
L['Synchronize Config'] = '구성 동기화';
L['Take ownership of, and move the micro menu buttons to the toolbar.'] = '마이크로 메뉴 버튼의 소유권을 가져와 도구 모음으로 이동.';
L['Takes the format of...\n|cFF3FC7EB[condition] Preset Name; nil|r\n\nAuto-saved presets are named "Character (Specialization) Realm", using class instead of specialization on Classic.\n\nThe preset loads outside of combat when the condition applies. Character presets take precedence over device presets.'] = [[형식:
|cFF3FC7EB[조건] 프리셋 이름; nil|r

자동 저장된 프리셋의 이름은 "캐릭터 (전문화) 서버"이며, 클래식에서는 전문화 대신 직업이 사용됩니다.

조건이 충족되면 전투 중이 아닐 때 프리셋을 불러옵니다. 캐릭터 프리셋이 장치 프리셋보다 우선합니다.]];
L['Taps for cursor clicks are right clicks instead of left.'] = '커서 클릭의 탭은 좌클릭 대신 우클릭입니다.';
L['Target enemies automatically by looking at them.'] = '바라봄으로써 자동으로 적을 대상으로 지정합니다.';
L['Target friends automatically by looking at them.'] = '바라봄으로써 자동으로 친구를 대상으로 지정합니다.';
L['Target Match Lock'] = '대상 일치 잠금';
L['Target Range'] = '대상 사거리';
L['Target Range Hard Cutoff'] = '대상 사거리 하드 컷오프';
L['Target Ring'] = '대상 원형 메뉴';
L['Targeting Mode'] = '대상 지정 모드';
L['Test Device'] = '장치 테스트';
L['The analog input for forward/back movement.'] = '앞/뒤 이동을 위한 아날로그 입력.';
L['The analog input for left/right Camera Yaw "look" feature.'] = '왼쪽/오른쪽 카메라 요 「보기」 기능을 위한 아날로그 입력.';
L['The analog input for left/right Camera Yaw.'] = '왼쪽/오른쪽 카메라 요를 위한 아날로그 입력.';
L['The analog input for left/right movement.'] = '왼쪽/오른쪽 이동을 위한 아날로그 입력.';
L['The analog input for up/down Camera Pitch "look" feature.'] = '위/아래 카메라 피치 「보기」 기능을 위한 아날로그 입력.';
L['The analog input for up/down Camera Pitch.'] = '위/아래 카메라 피치를 위한 아날로그 입력.';
L['The configuration is accessible by the chat command %s or from the game menu.'] = '구성은 채팅 명령 %s 또는 게임 메뉴에서 접근할 수 있습니다.';
L['The modifier can be used to nudge the cursor position with the directional pad.'] = '조합키를 사용하여 방향 패드로 커서 위치를 미세 조정할 수 있습니다.';
L['The modifier can be used to scroll together with the directional pad.'] = '조합키를 사용하여 방향 패드와 함께 스크롤할 수 있습니다.';
L['The quick menu binding can be used to close the menu as well.'] = '빠른 메뉴 단축키를 사용하여 메뉴를 닫을 수도 있습니다.';
L['The time it takes to transition from idle camera control to auto-adjustment (FOAS).'] = '카메라 유휴 제어에서 자동 조정(FOAS)으로 전환하는 데 걸리는 시간.';
L['Thickness'] = '두께';
L['Thickness in scaled pixel units.'] = '조정된 픽셀 단위의 두께.';
L['Thickness of the divider.'] = '구분 기호의 두께.';
L['This button is necessary to use or sell an item directly from your bags.'] = '이 버튼은 가방에서 직접 아이템을 사용하거나 판매하는 데 필요합니다.';
L['This feature is only available in Classic.'] = '이 기능은 Classic에서만 사용할 수 있습니다.';
L['This only affects gamepad bindings.'] = '이는 게임패드 단축키에만 영향을 줍니다.';
L['This will not affect your bindings, interface settings or system-wide settings.'] = '이는 단축키, 인터페이스 설정 또는 시스템 전역 설정에 영향을 주지 않습니다.';
L['This will not work with Xbox controllers connected via bluetooth. The Xbox Adapter is required.'] = '블루투스로 연결된 Xbox 컨트롤러에서는 작동하지 않습니다. Xbox 어댑터가 필요합니다.';
L['Time in milliseconds for the opacity to change from one state to another.'] = '투명도가 한 상태에서 다른 상태로 변경되는 시간(밀리초).';
L['Time in seconds to automatically hide centered cursor.'] = '중앙 커서를 자동으로 숨기는 시간(초).';
L['Time in seconds to enable free cursor.'] = '자유 커서를 활성화하는 시간(초).';
L['Time to clear focus after intercepting stick input, in seconds.'] = '스틱 입력 차단 후 초점을 지우는 시간(초).';
L['Timeframe to catch a binding in the configuration, in seconds.'] = '구성에서 단축키를 캡처하는 시간(초).';
L['Timeframe to toggle the mouse cursor when double-tapping a selected modifier.'] = '선택한 조합키를 두 번 두드릴 때 마우스 커서를 전환하는 시간.';
L['Timeout clears focus after a set time, deadzone clears focus when stick input is neutral.'] = '시간 초과는 설정된 시간 후 초점을 지우고, 사용 안 함 구역은 스틱 입력이 중립일 때 초점을 지웁니다.';
L['Tint Color'] = '색조 색상';
L['Toggle visibility of all modifier flyouts for cluster action bars.'] = '클러스터 행동 단축바의 모든 조합키 펼침 표시 전환.';
L['Toggle visibility of all modifier flyouts.'] = '모든 조합키 펼침 표시 전환.';
L['Toolbar'] = '도구 모음';
L['Tooltip'] = '툴팁';
L['Top speed of cursor movement.'] = '커서 이동의 최고 속도.';
L['Touch Tap Buttons'] = '터치 탭 버튼';
L['Touch Tap Exclusive Click'] = '터치 탭 전용 클릭';
L['Touch Tap Max Time'] = '터치 탭 최대 시간';
L['Touch Tap Right Click'] = '터치 탭 우클릭';
L['Touchpad'] = '터치패드';
L['Transition'] = '전환';
L['Transition time for opacity changes.'] = '투명도 변경의 전환 시간.';
L['Travel Time'] = '이동 시간';
L['Trigger button actions on press instead of release.'] = '버튼 동작을 떼는 대신 누를 때 실행.';
L['Triggers'] = '트리거';
L['Turn Character With Camera'] = '카메라로 캐릭터 회전';
L['Turn your character facing when you turn your camera angle.'] = '카메라 각도를 돌릴 때 캐릭터의 시선 방향을 회전합니다.';
L['Type of LED color to use for the touchpad.'] = '터치패드에 사용할 LED 색상 유형.';
L['Types are PlayStation, Xbox, or Generic.'] = '유형은 PlayStation, Xbox 또는 일반입니다.';
L['Unit Hotkeys'] = '유닛 단축키';
L['Unit Pool'] = '유닛 풀';
L['Units to watch, as lists of unit tokens selected by macro conditions. Use [] for the unconditional fallback.'] = '매크로 조건으로 선택되는 유닛 토큰 목록으로 감시할 유닛을 지정합니다. 무조건 대체값에는 []를 사용하세요.';
L['Unknown device selected.'] = '알 수 없는 장치가 선택되었습니다.';
L['Unlimited Navigation'] = '무제한 탐색';
L['Unmapped keyboard key(s) detected:'] = '매핑되지 않은 키보드 키가 감지됨:';
L['Use a custom set of buttons for the game menu, otherwise the button set will be dynamically determined.'] = '게임 메뉴에 사용자 정의 버튼 세트 사용. 그렇지 않으면 버튼 세트가 동적으로 결정됩니다.';
L['Use a shoulder button combined with crosshair for smooth and precise interactions. The click is performed at crosshair or cursor location.'] = '부드럽고 정확한 상호작용을 위해 십자선과 함께 어깨 버튼을 사용하십시오. 클릭은 십자선 또는 커서 위치에서 수행됩니다.';
L['Use a targeting binding to turn a soft target into a hard target.'] = '부드러운 대상을 하드 대상으로 바꾸려면 대상 지정 단축키를 사용하십시오.';
L['Use character specific addon settings for this character.'] = '이 캐릭터에 캐릭터별 애드온 설정 사용.';
L['Use Custom Button Set'] = '사용자 정의 버튼 세트 사용';
L['Use Custom Loot Frame'] = '사용자 정의 전리품 프레임 사용';
L['Use Default Hotkey Icons'] = '기본 단축키 아이콘 사용';
L['Use Focus Mode'] = '초점 모드 사용';
L['Use global game tooltip for loot information, allowing other addons to add information to lootable items.'] = '전리품 정보에 전역 게임 툴팁을 사용하여, 다른 애드온이 약탈 가능한 아이템에 정보를 추가할 수 있도록 허용.';
L['Use Global Loot Tooltip'] = '전역 전리품 툴팁 사용';
L['Use Hardware Mouse Cursor'] = '하드웨어 마우스 커서 사용';
L['Use Instant Mode'] = '즉시 모드 사용';
L['Use Interact Nameplate Tooltip'] = '상호작용 이름판 툴팁 사용';
L['Use On Demand'] = '요청 시 사용';
L['Use optimized pathfinding algorithm for cursor movement.'] = '커서 이동에 최적화된 경로 탐색 알고리즘 사용.';
L['Use press and hold to navigate and use rings. Press, point, release.'] = '원형 메뉴를 탐색하고 사용하려면 「누르고 유지」를 사용하십시오. 누르고, 가리키고, 떼십시오.';
L['Use Static Mode'] = '정적 모드 사용';
L['Use the hardware cursor provided by the operating system.'] = '운영 체제에서 제공하는 하드웨어 커서 사용.';
L['Use together with [@cursor] macros to place reticle spells in a single click.'] = '[@cursor] 매크로와 함께 사용하여 십자선 주문을 한 번의 클릭으로 배치.';
L['Used for interacting with the world, at a center-fixed position.'] = '중앙 고정 위치에서 세계와 상호작용하는 데 사용.';
L['Uses global tint color when transparent.'] = '투명할 때 전역 색조 색상 사용.';
L['Uses the default hotkey icons instead of the custom icons provided by ConsolePort.'] = 'ConsolePort가 제공하는 사용자 정의 아이콘 대신 기본 단축키 아이콘 사용.';
L['Valid Action Deadzone'] = '유효한 동작 사용 안 함 구역';
L['Value below two may appear interlaced or not at all.'] = '2보다 작은 값은 인터레이스되어 보이거나 전혀 보이지 않을 수 있습니다.';
L['Vertical Offset'] = '세로 오프셋';
L['Vertical offset from anchor point.'] = '고정점으로부터의 세로 오프셋.';
L['Vertical offset of the counter text on buttons.'] = '버튼의 카운터 텍스트 세로 오프셋.';
L['Vertical offset of the hotkey icon on group buttons.'] = '그룹 버튼의 단축키 아이콘 세로 오프셋.';
L['Vertical offset of the hotkey prompt position, in pixels.'] = '픽셀 단위의 단축키 안내 위치 세로 오프셋.';
L['Vertical offset of the hotkey text on buttons.'] = '버튼의 단축키 텍스트 세로 오프셋.';
L['Vertical offset of the macro text on buttons.'] = '버튼의 매크로 텍스트 세로 오프셋.';
L['Vertical Padding'] = '세로 여백';
L['Vertical position of centered cursor & targeting, as fraction of screen height.'] = '화면 높이의 비율로서, 중앙 커서 및 대상 지정의 세로 위치.';
L['Visibility Condition'] = '가시성 조건';
L['Watch bars include XP, reputation, honor, artifact power, and azerite.'] = '감시 막대에는 경험치, 평판, 명예, 유물 힘 및 정수가 포함됩니다.';
L['When disabled, a button press will also act as a cursor click.'] = '비활성화되면 버튼 누름도 커서 클릭으로 작동합니다.';
L['When disabled, you will need to press the accept button to confirm a selection.'] = '비활성화되면 선택을 확인하려면 수락 버튼을 눌러야 합니다.';
L['When enabled, a tap will act as a button press.'] = '활성화되면 탭이 버튼 누름으로 작동합니다.';
L['When set to both sticks, cursor only disables when both sticks are used together.'] = '두 스틱으로 설정하면 두 스틱을 함께 사용할 때만 커서가 비활성화됩니다.';
L['Whether client keybindings should be saved to the server.'] = '클라이언트 키 단축키를 서버에 저장할지 여부.';
L['Whether the keyboard should always be shown or only when a gamepad is active.'] = '키보드를 항상 표시할지, 게임패드가 활성일 때만 표시할지 여부.';
L['Whether to save character- and account-scoped variables to the server.'] = '캐릭터 및 계정 범위 변수를 서버에 저장할지 여부.';
L['Which button set to use for unit hotkeys.'] = '유닛 단축키에 사용할 버튼 세트.';
L['Which modifier to use for modified commands.'] = '수정된 명령에 사용할 조합키.';
L['Which modifier to use for nudging the cursor.'] = '커서를 미세 조정하는 데 사용할 조합키.';
L['Which modifier to use to toggle the mouse cursor when double-tapped.'] = '두 번 두드릴 때 마우스 커서를 전환하는 데 사용할 조합키.';
L['Which modifier to use with the movement buttons to move the cursor.'] = '커서를 이동하기 위해 이동 버튼과 함께 사용할 조합키.';
L['While disabled, cursor timeout, and toggling between free-roaming and center-fixed cursor are also disabled.'] = '비활성화된 동안 커서 시간 초과와 자유롭게 움직이는 커서와 중앙 고정 커서 사이의 전환도 비활성화됩니다.';
L['While held down, can simulate dragging by clicking on the directional pad.'] = '누르고 있는 동안 방향 패드를 클릭하여 드래그를 시뮬레이션할 수 있습니다.';
L['Width of the artwork.'] = '아트워크의 너비.';
L['Width of the cluster bar.'] = '클러스터 바의 너비.';
L['Width of the crosshair, in scaled pixel units.'] = '조정된 픽셀 단위의 십자선 너비.';
L['Width of the group.'] = '그룹의 너비.';
L['Width of the toolbar.'] = '도구 모음의 너비.';
L['Wipe Dictionary'] = '사전 지우기';
L['Wired'] = '유선';
L['Works like a regular action bar, which displays the action slots of a specified action page.'] = '지정된 동작 페이지의 동작 슬롯을 표시하는 일반 행동 단축바처럼 작동합니다.';
L['X Offset'] = 'X 오프셋';
L['XP Bar Color'] = '경험치 막대 색상';
L['Y Offset'] = 'Y 오프셋';
L['Yaw Axis'] = '요 축';
L['Yaw-only deadzone for camera, applied before the 2D deadzone.'] = '2D 사용 안 함 구역 이전에 적용되는 카메라용 요 전용 사용 안 함 구역.';
L['your current loadout'] = '현재 로드아웃';
---------------------------------------------------------------
-- Literal block entries
---------------------------------------------------------------
L['%s is already bound to\n%s\n\nDo you want to change it to\n%s?'] = [[%s은(는) 이미 다음에 할당되어 있습니다:
%s

다음으로 변경하시겠습니까?
%s]];
L['+ Normal\n- Inverted'] = [[+ 정상
- 반전]];
L['Takes the format of...\n'] = [[형식:
]];
L['The bindings underlying the button combinations will be unavailable while the cursor is in use.\n\nModifier can also be configured on a per button basis.'] = [[버튼 조합의 기본 단축키는 커서가 사용 중일 때 사용할 수 없습니다.

조합키는 버튼별로도 구성할 수 있습니다.]];
L['When set to zero, always face your movement stick direction.\nWhen set to max, never face your movement stick direction.'] = [[0으로 설정하면 항상 이동 스틱 방향을 바라봅니다.
최대로 설정하면 이동 스틱 방향을 절대 바라보지 않습니다.]];
L['Your %s device has separate handling for Bluetooth and wired connection.\nWhich one are you using?'] = [[%s 장치는 블루투스와 유선 연결을 별도로 처리합니다.
어느 것을 사용 중이십니까?]];
