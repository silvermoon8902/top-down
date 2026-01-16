extends Node2D
class_name InimigoBase
## InimigoBase - Classe base para todos os inimigos
## Define comportamentos comuns de IA, movimento e ataque

# Sinais
signal movimento_completado(posicao_nova: Vector2i)
signal ataque_executado(direcao: int)
signal dano_recebido(quantidade: int)
signal morreu()

# Exportações para configurar no editor
@export var vida_maxima: int = 2
@export var dano_ataque: int = 1
@export var alcance_visao: int = 8
@export var alcance_ataque: int = 1

# Tipos de ataque disponíveis
enum TipoAtaque {
	CORPO_A_CORPO,
	AVANCAR_ATACAR,
	DISTANCIA,
	VENENO
}
@export var tipo_ataque: TipoAtaque = TipoAtaque.CORPO_A_CORPO
@export var distancia_avanco: int = 2  # Para ataque de avanço

# Referências aos nós filhos
@onready var sprite: Sprite2D = $Sprite

# Referências externas
var grid_system: GridSystem = null
var turn_manager: TurnManager = null
var cavaleiro_ref: Node2D = null

# Estado
var posicao_grade: Vector2i = Vector2i.ZERO
var vida_atual: int = 0
var esta_vivo: bool = true
var envenenado: bool = false

# Dados da ação calculada
var _acao_calculada: Dictionary = {}


func _ready() -> void:
	## Inicializa o inimigo
	add_to_group("inimigos")
	vida_atual = vida_maxima


func configurar(grid: GridSystem, turn: TurnManager, posicao_inicial: Vector2i) -> void:
	## Configura o inimigo com as referências e posição inicial
	grid_system = grid
	turn_manager = turn
	posicao_grade = posicao_inicial
	cavaleiro_ref = GameManager.cavaleiro_ref

	# Registra na grade
	grid_system.registrar_entidade(self, posicao_grade)

	# Posiciona no mundo
	position = grid_system.posicao_grade_para_mundo(posicao_grade)

	# Registra no turn manager
	turn_manager.registrar_inimigo(self)


func calcular_acao() -> Dictionary:
	## Calcula a próxima ação do inimigo
	## Retorna um dicionário com o tipo de ação e parâmetros
	_acao_calculada = {"tipo": "nenhuma"}

	if not esta_vivo or not cavaleiro_ref:
		return _acao_calculada

	var pos_jogador = grid_system.obter_posicao_jogador()
	var distancia = grid_system.calcular_distancia_manhattan(posicao_grade, pos_jogador)

	# Verifica se pode atacar
	if _pode_atacar(pos_jogador, distancia):
		_acao_calculada = _calcular_ataque(pos_jogador)
	# Senão, tenta se mover em direção ao jogador
	elif distancia <= alcance_visao:
		_acao_calculada = _calcular_movimento(pos_jogador)

	return _acao_calculada


func executar_acao(acao: Dictionary) -> void:
	## Executa a ação calculada
	if not esta_vivo:
		return

	match acao.get("tipo", "nenhuma"):
		"mover":
			_executar_movimento(acao.get("destino", posicao_grade))
		"atacar":
			_executar_ataque(acao.get("direcao", 0), acao.get("posicao_alvo", Vector2i.ZERO))
		"avancar_atacar":
			_executar_avanco_ataque(acao.get("direcao", 0), acao.get("distancia", 1))
		"atirar":
			_executar_tiro(acao.get("direcao", 0))
		"envenenar":
			_executar_veneno(acao.get("direcao", 0))


func _pode_atacar(pos_jogador: Vector2i, distancia: int) -> bool:
	## Verifica se pode atacar o jogador
	match tipo_ataque:
		TipoAtaque.CORPO_A_CORPO:
			return distancia == 1
		TipoAtaque.AVANCAR_ATACAR:
			return distancia <= distancia_avanco and _esta_em_linha_reta(pos_jogador)
		TipoAtaque.DISTANCIA:
			return _esta_em_linha_reta(pos_jogador) and distancia <= alcance_visao
		TipoAtaque.VENENO:
			return distancia == 1
	return false


func _esta_em_linha_reta(pos_alvo: Vector2i) -> bool:
	## Verifica se o alvo está em linha reta (horizontal ou vertical)
	return posicao_grade.x == pos_alvo.x or posicao_grade.y == pos_alvo.y


func _calcular_ataque(pos_jogador: Vector2i) -> Dictionary:
	## Calcula os parâmetros do ataque
	var direcao = grid_system.obter_direcao_entre_posicoes(posicao_grade, pos_jogador)

	match tipo_ataque:
		TipoAtaque.CORPO_A_CORPO:
			return {
				"tipo": "atacar",
				"direcao": direcao,
				"posicao_alvo": pos_jogador
			}
		TipoAtaque.AVANCAR_ATACAR:
			var distancia = grid_system.calcular_distancia_manhattan(posicao_grade, pos_jogador)
			return {
				"tipo": "avancar_atacar",
				"direcao": _obter_direcao_para_posicao(pos_jogador),
				"distancia": distancia - 1  # Para parar adjacente ao jogador
			}
		TipoAtaque.DISTANCIA:
			return {
				"tipo": "atirar",
				"direcao": _obter_direcao_para_posicao(pos_jogador)
			}
		TipoAtaque.VENENO:
			return {
				"tipo": "envenenar",
				"direcao": direcao
			}

	return {"tipo": "nenhuma"}


func _obter_direcao_para_posicao(pos_alvo: Vector2i) -> int:
	## Retorna a direção geral para uma posição
	var diff = pos_alvo - posicao_grade

	if abs(diff.x) > abs(diff.y):
		return 1 if diff.x > 0 else 3  # Direita ou Esquerda
	else:
		return 2 if diff.y > 0 else 0  # Baixo ou Cima


func _calcular_movimento(pos_jogador: Vector2i) -> Dictionary:
	## Calcula o movimento em direção ao jogador
	var proximo_passo = grid_system.obter_proximo_passo_em_direcao(posicao_grade, pos_jogador)

	if proximo_passo != posicao_grade and grid_system.esta_celula_livre(proximo_passo):
		return {
			"tipo": "mover",
			"destino": proximo_passo
		}

	return {"tipo": "nenhuma"}


func _executar_movimento(destino: Vector2i) -> void:
	## Executa o movimento para uma posição
	if not grid_system.esta_celula_livre(destino):
		return

	var posicao_antiga = posicao_grade
	grid_system.mover_entidade(self, posicao_grade, destino)
	posicao_grade = destino
	position = grid_system.posicao_grade_para_mundo(posicao_grade)

	movimento_completado.emit(destino)
	print("[Inimigo] Moveu de %s para %s" % [posicao_antiga, destino])


func _executar_ataque(direcao: int, posicao_alvo: Vector2i) -> void:
	## Executa ataque corpo a corpo
	AudioManager.tocar_sfx(AudioManager.SFX.ATACAR)

	var alvo = grid_system.obter_entidade_em(posicao_alvo)
	if alvo and alvo.is_in_group("jogador") and alvo.has_method("receber_dano"):
		# Calcula direção oposta (de onde vem o ataque do ponto de vista do jogador)
		var direcao_oposta = GameManager.obter_direcao_oposta(direcao)
		alvo.receber_dano(dano_ataque, direcao_oposta)

	ataque_executado.emit(direcao)
	print("[Inimigo] Atacou na direção %d" % direcao)


func _executar_avanco_ataque(direcao: int, distancia: int) -> void:
	## Executa avanço e ataque
	var vetor_direcao = GameManager.obter_vetor_direcao(direcao)

	# Move N células
	for i in range(distancia):
		var nova_pos = posicao_grade + vetor_direcao
		if grid_system.esta_celula_livre(nova_pos):
			grid_system.mover_entidade(self, posicao_grade, nova_pos)
			posicao_grade = nova_pos
		else:
			break

	position = grid_system.posicao_grade_para_mundo(posicao_grade)

	# Ataca adjacente
	var pos_ataque = posicao_grade + vetor_direcao
	_executar_ataque(direcao, pos_ataque)

	print("[Inimigo] Avançou e atacou na direção %d" % direcao)


func _executar_tiro(direcao: int) -> void:
	## Executa ataque à distância
	AudioManager.tocar_sfx(AudioManager.SFX.ATACAR)

	var vetor_direcao = GameManager.obter_vetor_direcao(direcao)
	var pos_atual = posicao_grade + vetor_direcao

	# Projétil viaja em linha reta até atingir algo ou sair da grade
	while grid_system.esta_dentro_da_grade(pos_atual):
		var entidade = grid_system.obter_entidade_em(pos_atual)

		if entidade:
			if entidade.is_in_group("jogador") and entidade.has_method("receber_dano"):
				var direcao_oposta = GameManager.obter_direcao_oposta(direcao)
				entidade.receber_dano(dano_ataque, direcao_oposta)
			break

		if grid_system.e_obstaculo(pos_atual):
			break

		pos_atual += vetor_direcao

	ataque_executado.emit(direcao)
	print("[Inimigo] Atirou na direção %d" % direcao)


func _executar_veneno(direcao: int) -> void:
	## Executa ataque de veneno
	var vetor_direcao = GameManager.obter_vetor_direcao(direcao)
	var pos_alvo = posicao_grade + vetor_direcao

	var alvo = grid_system.obter_entidade_em(pos_alvo)
	if alvo and alvo.is_in_group("jogador") and alvo.has_method("receber_veneno"):
		alvo.receber_veneno()

	ataque_executado.emit(direcao)
	print("[Inimigo] Envenenou na direção %d" % direcao)


func receber_dano(quantidade: int) -> void:
	## Recebe dano
	vida_atual -= quantidade
	dano_recebido.emit(quantidade)

	print("[Inimigo] Recebeu %d de dano (Vida: %d/%d)" % [quantidade, vida_atual, vida_maxima])

	if vida_atual <= 0:
		_morrer()


func _morrer() -> void:
	## Processa a morte do inimigo
	esta_vivo = false
	AudioManager.tocar_sfx(AudioManager.SFX.MORTE)

	# Remove da grade
	grid_system.remover_entidade(posicao_grade)

	# Remove do turn manager
	turn_manager.remover_inimigo(self)

	morreu.emit()
	print("[Inimigo] Morreu!")

	# Remove da cena
	queue_free()


func processar_status() -> void:
	## Processa efeitos de status (chamado no fim do turno)
	if envenenado:
		receber_dano(1)


func obter_posicao_grade() -> Vector2i:
	## Retorna a posição atual na grade
	return posicao_grade
