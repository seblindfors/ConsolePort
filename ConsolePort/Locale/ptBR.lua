if GetLocale() == "ptBR" then
	local _, db = ...
	db.TUTORIAL = {
		BIND  = {
			DEFAULT 			= "Clique em um botão para alterar seu comportamento.",
			COMBO 				= "Clique em uma combinação de %s para alterar.",
			STATIC 				= "Selecione uma ação da lista para alterar %s",
			DYNAMIC 			= "Selecione qualquer botão da interface com o cursor para alterar %s\n%s Aplicar %s Cancelar ",
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
	db.XBOX = {
		CP_L_UP					=	"Cima",
		CP_L_DOWN				=	"Baixo",
		CP_L_LEFT				=	"Esquerda",
		CP_L_RIGHT				=	"Direita",
		CP_TR1					=	"RB",
		CP_TR2					=	"RT",
		CP_R_UP					=	"Y",
		CP_R_DOWN				=	"A",
		CP_R_LEFT				=	"X",
		CP_R_RIGHT				=	"B",
		CP_L_OPTION				= 	"Back",
		CP_C_OPTION				=	"Guia",
		CP_R_OPTION				= 	"Start",
		HEADER_CP_LEFT 			= 	"Botões direcionais",
		HEADER_CP_RIGHT			= 	"Botões de ação",
		HEADER_CP_CENTER		= 	"Botões centrais",
		HEADER_CP_TRIG			=	"Gatilhos",
	}
	db.PS4 = {
		CP_L_UP					=	"Cima",
		CP_L_DOWN				=	"Baixo",
		CP_L_LEFT				=	"Esquerda",
		CP_L_RIGHT				=	"Direita",
		CP_TR1					=	"R1",
		CP_TR2					=	"R2",
		CP_R_UP					=	"Triângulo",
		CP_R_DOWN				=	"X",
		CP_R_LEFT				=	"Quadrado",
		CP_R_RIGHT				=	"Círculo",
		CP_L_OPTION				= 	"Share",
		CP_C_OPTION				=	"PS",
		CP_R_OPTION				= 	"Options",
		HEADER_CP_LEFT 			= 	"Botões direcionais",
		HEADER_CP_RIGHT			= 	"Botões de ação",
		HEADER_CP_CENTER		= 	"Botões centrais",
		HEADER_CP_TRIG			=	"Gatilhos",
	}
end
