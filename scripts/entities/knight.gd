extends Node2D
class_name Cavaleiro
## Cavaleiro - Personagem principal controlado pelo jogador
## Gerencia movimento, ataque e interações do cavaleiro

# Sinais
signal movimento_completado(posicao_nova: Vector2i)
signal ataque_executado(direcao: int, posicao_alvo: Vector2i)
signal dano_recebido(quantidade: int)
signal morreu()
signal item_coletado(tipo_item: String)

# Referências aos nós filhos
@onready var sprite: Sprite2D = $Sprite
@onready var indicador_escudo: Sprite2D = $IndicadorEscudo
@onready var collision: Area2D = $Area2D

# Referências externas
var grid_system: GridSystem = null
var turn_manager: TurnManager = null

# Posição na grade
var posicao_grade: Vector2i = Vector2i.ZERO

# Estado
var pode_agir: bool = true


func _ready() -> void:
	## Inicializa o cavaleiro
	add_to_group("jogador")
	_atualizar_indicador_escudo()

	# Conecta ao sinal de atualização de stats
	GameManager.cavaleiro_stats_atualizados.connect(_on_stats_atualizados)


func configurar(grid: GridSystem, turn: TurnManager, posicao_inicial: Vector2i) -> void:
	## Configura o cavaleiro com as referências e posição inicial
	grid_system = grid
	turn_manager = turn
	posicao_grade = posicao_inicial

	# Registra na grade
	grid_system.registrar_entidade(self, posicao_grade)

	# Posiciona no mundo
	position = grid_system.posicao_grade_para_mundo(posicao_grade)

	# Armazena referência no GameManager
	GameManager.cavaleiro_ref = self


func _input(event: InputEvent) -> void:
	## Processa input do jogador
	if not turn_manager or not turn_manager.pode_jogador_agir():
		return

	if not pode_agir:
		return

	# Verifica se está atacando (K pressionado)
	var atacando = Input.is_action_pressed("atacar")

	# Movimento / Ataque direcional
	if event.is_action_pressed("mover_cima"):
		if atacando:
			_executar_ataque(0)  # Atacar para cima
		else:
			_tentar_mover(Vector2i(0, -1))

	elif event.is_action_pressed("mover_baixo"):
		if atacando:
			_executar_ataque(2)  # Atacar para baixo
		else:
			_tentar_mover(Vector2i(0, 1))

	elif event.is_action_pressed("mover_esquerda"):
		if atacando:
			_executar_ataque(3)  # Atacar para esquerda
		else:
			_tentar_mover(Vector2i(-1, 0))

	elif event.is_action_pressed("mover_direita"):
		if atacando:
			_executar_ataque(1)  # Atacar para direita
		else:
			_tentar_mover(Vector2i(1, 0))

	# Ataque sem direção (ataca na direção do escudo)
	elif event.is_action_pressed("atacar"):
		# Aguarda direção ou usa direção do escudo
		pass

	# Passar turno
	elif event.is_action_pressed("passar_turno"):
		_passar_turno()

	# Usar item de cura
	elif event.is_action_pressed("usar_item_cura"):
		_usar_item_cura()

	# Usar antídoto
	elif event.is_action_pressed("usar_antidoto"):
		_usar_antidoto()


func _tentar_mover(direcao: Vector2i) -> void:
	## Tenta mover o cavaleiro em uma direção
	var nova_posicao = posicao_grade + direcao

	# Verifica se pode mover
	if grid_system.esta_celula_livre(nova_posicao):
		_mover_para(nova_posicao)
		_finalizar_acao()

	# Verifica se há baú ou item para interagir
	elif _verificar_interacao(nova_posicao):
		_finalizar_acao()


func _mover_para(nova_posicao: Vector2i) -> void:
	## Move o cavaleiro para uma nova posição
	var posicao_antiga = posicao_grade

	# Atualiza na grade
	grid_system.mover_entidade(self, posicao_grade, nova_posicao)
	posicao_grade = nova_posicao

	# Atualiza posição visual
	position = grid_system.posicao_grade_para_mundo(posicao_grade)

	# Toca som de movimento
	AudioManager.tocar_sfx(AudioManager.SFX.MOVER)

	# Verifica se há item no chão para coletar
	_verificar_itens_no_chao()

	movimento_completado.emit(nova_posicao)
	print("[Cavaleiro] Moveu de %s para %s" % [posicao_antiga, nova_posicao])


func _verificar_itens_no_chao() -> void:
	## Verifica e coleta itens no chão da posição atual
	var itens = get_tree().get_nodes_in_group("itens")

	for item in itens:
		if item.has_method("verificar_coleta_manual"):
			item.verificar_coleta_manual(posicao_grade)


func _executar_ataque(direcao: int) -> void:
	## Executa um ataque na direção especificada
	## 0=cima, 1=direita, 2=baixo, 3=esquerda
	var vetor_direcao = GameManager.obter_vetor_direcao(direcao)
	var posicao_alvo = posicao_grade + vetor_direcao

	# Toca som de ataque
	AudioManager.tocar_sfx(AudioManager.SFX.ATACAR)

	# Verifica se há alvo na posição
	var alvo = grid_system.obter_entidade_em(posicao_alvo)

	if alvo:
		if alvo.is_in_group("inimigos") and alvo.has_method("receber_dano"):
			# Calcula dano (por enquanto, dano fixo de 1)
			var dano = 1
			alvo.receber_dano(dano)
			AudioManager.tocar_sfx(AudioManager.SFX.ACERTO)
			print("[Cavaleiro] Atacou inimigo em %s causando %d de dano" % [posicao_alvo, dano])

		elif alvo.is_in_group("baus") and alvo.has_method("abrir"):
			alvo.abrir()
			print("[Cavaleiro] Abriu baú em %s" % posicao_alvo)

	ataque_executado.emit(direcao, posicao_alvo)
	_finalizar_acao()


func _passar_turno() -> void:
	## Passa o turno do jogador
	## Verifica se jogador quer mudar direção do escudo
	var nova_direcao = -1

	# Checa se alguma direção está pressionada
	if Input.is_action_pressed("mover_cima"):
		nova_direcao = 0
	elif Input.is_action_pressed("mover_direita"):
		nova_direcao = 1
	elif Input.is_action_pressed("mover_baixo"):
		nova_direcao = 2
	elif Input.is_action_pressed("mover_esquerda"):
		nova_direcao = 3

	if nova_direcao >= 0:
		GameManager.mudar_direcao_escudo(nova_direcao)
		_atualizar_indicador_escudo()

	turn_manager.passar_turno_jogador(nova_direcao)
	print("[Cavaleiro] Passou o turno (escudo: %d)" % GameManager.direcao_escudo)


func _usar_item_cura() -> void:
	## Usa um item de cura do inventário
	if GameManager.usar_item_cura():
		AudioManager.tocar_sfx(AudioManager.SFX.CURAR)
		print("[Cavaleiro] Usou item de cura")
		_finalizar_acao()


func _usar_antidoto() -> void:
	## Usa um antídoto do inventário
	if GameManager.usar_antidoto():
		AudioManager.tocar_sfx(AudioManager.SFX.CURAR)
		print("[Cavaleiro] Usou antídoto")
		_finalizar_acao()


func _verificar_interacao(posicao: Vector2i) -> bool:
	## Verifica e executa interação com objetos na posição
	var objeto = grid_system.obter_entidade_em(posicao)

	if objeto:
		# Interação com baú
		if objeto.is_in_group("baus") and objeto.has_method("abrir"):
			objeto.abrir()
			return true

	return false


func _finalizar_acao() -> void:
	## Finaliza a ação do jogador e passa o turno
	turn_manager.jogador_executou_acao()


func receber_dano(quantidade: int, direcao_ataque: int = -1, ignora_armadura: bool = false) -> void:
	## Recebe dano de um ataque
	## direcao_ataque: direção de onde vem o ataque (para verificar escudo)
	## ignora_armadura: se true (veneno), ignora escudo e armadura

	# Verifica bloqueio do escudo (se não for veneno)
	if not ignora_armadura and direcao_ataque >= 0:
		if GameManager.verificar_bloqueio_escudo(direcao_ataque):
			AudioManager.tocar_sfx(AudioManager.SFX.ESCUDO_BLOQUEIO)
			print("[Cavaleiro] Escudo bloqueou ataque da direção %d" % direcao_ataque)
			return

	# Aplica o dano
	GameManager.aplicar_dano_cavaleiro(quantidade, ignora_armadura)
	AudioManager.tocar_sfx(AudioManager.SFX.DANO)

	dano_recebido.emit(quantidade)
	print("[Cavaleiro] Recebeu %d de dano (Vida: %d, Armadura: %d)" %
		  [quantidade, GameManager.cavaleiro_vida, GameManager.cavaleiro_armadura])

	# Verifica morte
	if GameManager.cavaleiro_vida <= 0:
		_morrer()


func receber_veneno() -> void:
	## Recebe ataque de veneno
	GameManager.envenenar_cavaleiro()
	AudioManager.tocar_sfx(AudioManager.SFX.VENENO)
	print("[Cavaleiro] Foi envenenado!")


func _morrer() -> void:
	## Processa a morte do cavaleiro
	AudioManager.tocar_sfx(AudioManager.SFX.MORTE)
	morreu.emit()
	print("[Cavaleiro] Morreu!")


func coletar_item(tipo: String) -> bool:
	## Coleta um item
	## Retorna true se conseguiu coletar
	var coletou = false

	match tipo:
		"coxa_frango":
			coletou = GameManager.adicionar_item_cura()
		"pocao":
			coletou = GameManager.adicionar_item_antidoto()
		"elmo":
			# Elmo é usado instantaneamente
			GameManager.restaurar_armadura(3)
			coletou = true

	if coletou:
		AudioManager.tocar_sfx(AudioManager.SFX.PEGAR_ITEM)
		item_coletado.emit(tipo)
		print("[Cavaleiro] Coletou item: %s" % tipo)

	return coletou


func _atualizar_indicador_escudo() -> void:
	## Atualiza a posição/rotação do indicador de escudo
	if not indicador_escudo:
		return

	# Posiciona o indicador baseado na direção
	var offset = 8  # Pixels de distância do centro
	match GameManager.direcao_escudo:
		0:  # Cima
			indicador_escudo.position = Vector2(0, -offset)
			indicador_escudo.rotation_degrees = 0
		1:  # Direita
			indicador_escudo.position = Vector2(offset, 0)
			indicador_escudo.rotation_degrees = 90
		2:  # Baixo
			indicador_escudo.position = Vector2(0, offset)
			indicador_escudo.rotation_degrees = 180
		3:  # Esquerda
			indicador_escudo.position = Vector2(-offset, 0)
			indicador_escudo.rotation_degrees = 270


func _on_stats_atualizados() -> void:
	## Chamado quando os stats do cavaleiro são atualizados
	_atualizar_indicador_escudo()


func obter_posicao_grade() -> Vector2i:
	## Retorna a posição atual na grade
	return posicao_grade
