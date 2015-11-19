if not (GetLocale() == "ptBR") then return end
local _, db = ...

db.TUTORIAL = {
	BIND  = {
		DEFAULT 			= "Clique em um botão para alterar seu comportamento.",
		COMBO 				= "Clique em uma combinação de %s para alterar.",
		APPLIED 			= "%s foi aplicado a %s.",
		INVALID 			= "Erro: Botão inválido. Nova atribuição foi descartada.",
		COMBAT 				= "Erro: Em combate! Saia de combate para alterar suas configurações.",
		IMPORT 				= "Configurações importadas de %s. Pressione OK para aplicar.",
		RESET 				= "Configurações padrões carregadas. Pressione OK para aplicar.",
	},
	SETUP = {
		HEADER 				= "Configurar: Definir botões do controle",
		HEADLINE 			= "Suas atribuições do controle estão incompletas.\nPressione o botão solicitado para mapeá-lo.",
		OVERRIDE 			= "%s já está atribuído a %s.\nPressione |T%s:20:20:0:0|t novamente para continuar assim mesmo.",
		INVALID 			= "Atribuição inválida.\nVocê pressionou o botão correto?",
		COMBAT 				= "Você está em combate!",
		EMPTY 				= "<Vazio>",
		SUCCESS 			= "|T%s:16:16:0:0|t foi atribuído com êxito a %s.",
		CONTINUE 			= "Pressione |T%s:20:20:0:0|t novamente para continuar.",
		CONFIRM 			= "Pressione |T%s:20:20:0:0|t novamente para confirmar.",
		CONTROLLER 			= "Selecione seu layout de botões preferido clicando em um controle.",
	},
	SLASH = {
		COMBAT 				= "Erro: Não é possível redefinir o addon em combate!",
		TYPE				= "Mudar tipo de controle",
		RESET 				= "Redefinir completamente o addon",
		BINDS 				= "Abrir menu de atribuições",
	}
}
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