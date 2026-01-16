extends Node
## GameManager - Gerenciador global do estado do jogo
## Controla o estado atual do jogo, fase atual, e dados do cavaleiro

# Sinais para comunicação entre sistemas
signal fase_iniciada(numero_fase: int)
signal fase_completada(numero_fase: int)
signal jogo_pausado(pausado: bool)
signal cavaleiro_morreu()
signal cavaleiro_stats_atualizados()

# Enumeração dos estados do jogo
enum EstadoJogo {
	MENU,
	JOGANDO,
	PAUSADO,
	GAME_OVER,
	VITORIA
}

# Constantes do jogo
const VIDA_MAXIMA: int = 3
const ARMADURA_MAXIMA: int = 3
const SLOTS_CURA: int = 3
const SLOTS_ANTIDOTO: int = 3
const TOTAL_FASES: int = 16
const TAMANHO_CELULA: int = 16

# Estado atual do jogo
var estado_atual: EstadoJogo = EstadoJogo.MENU
var fase_atual: int = 1
var fase_mais_alta_desbloqueada: int = 1

# Stats do cavaleiro
var cavaleiro_vida: int = VIDA_MAXIMA
var cavaleiro_armadura: int = ARMADURA_MAXIMA
var cavaleiro_envenenado: bool = false
var turnos_envenenado: int = 0

# Inventário do cavaleiro
var itens_cura: int = 0
var itens_antidoto: int = 0

# Direção do escudo (0=cima, 1=direita, 2=baixo, 3=esquerda)
var direcao_escudo: int = 0

# Referências
var cavaleiro_ref: Node2D = null


func _ready() -> void:
	## Inicializa o GameManager
	process_mode = Node.PROCESS_MODE_ALWAYS
	_resetar_stats_cavaleiro()


func _resetar_stats_cavaleiro() -> void:
	## Reseta os stats do cavaleiro para o início de fase
	cavaleiro_vida = VIDA_MAXIMA
	cavaleiro_armadura = ARMADURA_MAXIMA
	cavaleiro_envenenado = false
	turnos_envenenado = 0
	direcao_escudo = 0
	cavaleiro_stats_atualizados.emit()


func iniciar_nova_partida() -> void:
	## Inicia uma nova partida do zero
	fase_atual = 1
	fase_mais_alta_desbloqueada = 1
	itens_cura = 0
	itens_antidoto = 0
	_resetar_stats_cavaleiro()
	estado_atual = EstadoJogo.JOGANDO


func carregar_partida_salva() -> void:
	## Carrega uma partida salva
	var dados = SaveManager.carregar_jogo()
	if dados:
		fase_atual = dados.get("fase_atual", 1)
		fase_mais_alta_desbloqueada = dados.get("fase_mais_alta", 1)
		itens_cura = dados.get("itens_cura", 0)
		itens_antidoto = dados.get("itens_antidoto", 0)
	_resetar_stats_cavaleiro()
	estado_atual = EstadoJogo.JOGANDO


func iniciar_fase(numero_fase: int) -> void:
	## Inicia uma fase específica
	fase_atual = numero_fase
	_resetar_stats_cavaleiro()
	estado_atual = EstadoJogo.JOGANDO
	fase_iniciada.emit(numero_fase)


func completar_fase() -> void:
	## Chamado quando o jogador completa a fase atual
	if fase_atual >= fase_mais_alta_desbloqueada:
		fase_mais_alta_desbloqueada = fase_atual + 1

	# Salva o progresso
	SaveManager.salvar_jogo()

	fase_completada.emit(fase_atual)

	# Verifica se completou o jogo
	if fase_atual >= TOTAL_FASES:
		estado_atual = EstadoJogo.VITORIA
	else:
		fase_atual += 1


func pausar_jogo(pausar: bool) -> void:
	## Pausa ou despausa o jogo
	if pausar:
		estado_atual = EstadoJogo.PAUSADO
	else:
		estado_atual = EstadoJogo.JOGANDO

	get_tree().paused = pausar
	jogo_pausado.emit(pausar)


func aplicar_dano_cavaleiro(dano: int, ignora_armadura: bool = false) -> void:
	## Aplica dano ao cavaleiro
	## Se ignora_armadura for true (veneno), dano vai direto na vida
	if ignora_armadura:
		cavaleiro_vida -= dano
	else:
		# Primeiro reduz armadura, depois vida
		var dano_restante = dano
		if cavaleiro_armadura > 0:
			var dano_armadura = min(dano_restante, cavaleiro_armadura)
			cavaleiro_armadura -= dano_armadura
			dano_restante -= dano_armadura

		if dano_restante > 0:
			cavaleiro_vida -= dano_restante

	cavaleiro_stats_atualizados.emit()

	# Verifica morte
	if cavaleiro_vida <= 0:
		cavaleiro_vida = 0
		estado_atual = EstadoJogo.GAME_OVER
		cavaleiro_morreu.emit()


func curar_cavaleiro(quantidade: int) -> void:
	## Cura o cavaleiro
	cavaleiro_vida = min(cavaleiro_vida + quantidade, VIDA_MAXIMA)
	cavaleiro_stats_atualizados.emit()


func restaurar_armadura(quantidade: int) -> void:
	## Restaura a armadura do cavaleiro
	cavaleiro_armadura = min(cavaleiro_armadura + quantidade, ARMADURA_MAXIMA)
	cavaleiro_stats_atualizados.emit()


func envenenar_cavaleiro() -> void:
	## Aplica veneno ao cavaleiro
	cavaleiro_envenenado = true
	turnos_envenenado = 0
	cavaleiro_stats_atualizados.emit()


func curar_veneno() -> void:
	## Remove o veneno do cavaleiro
	cavaleiro_envenenado = false
	turnos_envenenado = 0
	cavaleiro_stats_atualizados.emit()


func processar_veneno() -> void:
	## Processa dano de veneno no fim do turno
	if cavaleiro_envenenado:
		turnos_envenenado += 1
		aplicar_dano_cavaleiro(1, true)  # Veneno ignora armadura


func adicionar_item_cura() -> bool:
	## Adiciona item de cura ao inventário
	## Retorna true se conseguiu adicionar
	if itens_cura < SLOTS_CURA:
		itens_cura += 1
		cavaleiro_stats_atualizados.emit()
		return true
	return false


func adicionar_item_antidoto() -> bool:
	## Adiciona antídoto ao inventário
	## Retorna true se conseguiu adicionar
	if itens_antidoto < SLOTS_ANTIDOTO:
		itens_antidoto += 1
		cavaleiro_stats_atualizados.emit()
		return true
	return false


func usar_item_cura() -> bool:
	## Usa um item de cura
	## Retorna true se usou com sucesso
	if itens_cura > 0 and cavaleiro_vida < VIDA_MAXIMA:
		itens_cura -= 1
		curar_cavaleiro(1)
		return true
	return false


func usar_antidoto() -> bool:
	## Usa um antídoto
	## Retorna true se usou com sucesso
	if itens_antidoto > 0 and cavaleiro_envenenado:
		itens_antidoto -= 1
		curar_veneno()
		return true
	return false


func mudar_direcao_escudo(nova_direcao: int) -> void:
	## Muda a direção do escudo
	## 0=cima, 1=direita, 2=baixo, 3=esquerda
	direcao_escudo = clamp(nova_direcao, 0, 3)
	cavaleiro_stats_atualizados.emit()


func verificar_bloqueio_escudo(direcao_ataque: int) -> bool:
	## Verifica se o escudo bloqueia um ataque vindo de determinada direção
	## O escudo bloqueia se estiver virado para a direção de onde vem o ataque
	## Se o ataque vem de cima (0), o escudo deve estar virado para cima (0)
	return direcao_escudo == direcao_ataque


func obter_direcao_oposta(direcao: int) -> int:
	## Retorna a direção oposta
	## 0 (cima) <-> 2 (baixo), 1 (direita) <-> 3 (esquerda)
	match direcao:
		0: return 2
		1: return 3
		2: return 0
		3: return 1
		_: return 0


func obter_vetor_direcao(direcao: int) -> Vector2i:
	## Converte direção numérica para vetor
	match direcao:
		0: return Vector2i(0, -1)  # Cima
		1: return Vector2i(1, 0)   # Direita
		2: return Vector2i(0, 1)   # Baixo
		3: return Vector2i(-1, 0)  # Esquerda
		_: return Vector2i.ZERO
