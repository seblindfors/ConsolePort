if not (GetLocale() == "ptBR") then return end
local _, db = ...

db.TOOLTIP = {
	CLICK = {
		COMPARE 			=	"Comparar",
		QUEST_TRACKER 		=	"Definir missão atual",
		USE_NOCOMBAT 		=	"Usar (fora de combate)",
		BUY 				= 	"Comprar",
		USE 				= 	"Usar",
		EQUIP				= 	"Equipar",
		SELL 				= 	"Vender",
		QUEST_DETAILS 		= 	"Ver detalhes de missão",
		PICKUP 				= 	"Pegar",
		CANCEL 				= 	"Cancelar",
		STACK_BUY 			= 	"Comprar uma quantidade diferente",
		ADD_TO_EXTRA		= 	"Atribuir",
	}
}
db.HEADERS = {
	CP_LEFT 				= 	"Botões direcionais",
	CP_RIGHT				= 	"Botões de ação",
	CP_CENTER				= 	"Botões centrais",
	CP_TRIG					=	"Gatilhos",
}