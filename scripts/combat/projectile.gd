extends Node2D
class_name Projetil
## Projetil - Projétil para ataques à distância
## Viaja em linha reta até atingir algo ou sair da grade

# Sinais
signal atingiu_alvo(alvo: Node2D)
signal destruido()

# Configurações
@export var dano: int = 1
@export var velocidade_visual: float = 200.0  # Pixels por segundo
@export var e_veneno: bool = false

# Referências
@onready var sprite: Sprite2D = $Sprite

# Estado
var grid_system: GridSystem = null
var direcao: int = 0  # 0=cima, 1=direita, 2=baixo, 3=esquerda
var posicao_grade: Vector2i = Vector2i.ZERO
var posicao_alvo: Vector2i = Vector2i.ZERO
var grupo_origem: String = ""  # "jogador" ou "inimigos"
var esta_viajando: bool = false

const TAMANHO_CELULA: int = 16


func _ready() -> void:
	## Inicializa o projétil
	add_to_group("projeteis")

	# Cria sprite se não existir
	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = "Sprite"
		add_child(sprite)

	# Aplica textura placeholder
	sprite.texture = _criar_textura_projetil()


func configurar(grid: GridSystem, pos_inicial: Vector2i, dir: int, origem: String) -> void:
	## Configura o projétil
	grid_system = grid
	posicao_grade = pos_inicial
	direcao = dir
	grupo_origem = origem

	# Posição inicial no mundo
	position = grid_system.posicao_grade_para_mundo(posicao_grade)

	# Rotaciona sprite baseado na direção
	match direcao:
		0: rotation_degrees = 0    # Cima
		1: rotation_degrees = 90   # Direita
		2: rotation_degrees = 180  # Baixo
		3: rotation_degrees = 270  # Esquerda


func disparar() -> void:
	## Inicia o movimento do projétil
	esta_viajando = true
	_processar_movimento()


func _processar_movimento() -> void:
	## Processa o movimento do projétil célula por célula
	var vetor_direcao = GameManager.obter_vetor_direcao(direcao)

	while esta_viajando:
		var proxima_pos = posicao_grade + vetor_direcao

		# Verifica se saiu da grade
		if not grid_system.esta_dentro_da_grade(proxima_pos):
			_destruir()
			return

		# Verifica colisão com obstáculo
		if grid_system.e_obstaculo(proxima_pos):
			_destruir()
			return

		# Verifica colisão com entidade
		var entidade = grid_system.obter_entidade_em(proxima_pos)
		if entidade:
			# Não atinge aliados
			if entidade.is_in_group(grupo_origem):
				# Passa através de aliados
				pass
			else:
				# Atingiu alvo válido
				await _mover_para(proxima_pos)
				_atingir(entidade)
				return

		# Move para próxima célula
		await _mover_para(proxima_pos)
		posicao_grade = proxima_pos


func _mover_para(nova_pos: Vector2i) -> void:
	## Move visualmente para uma posição
	var pos_mundo = grid_system.posicao_grade_para_mundo(nova_pos)

	# Movimento instantâneo (pode adicionar tween depois)
	var tween = create_tween()
	tween.tween_property(self, "position", pos_mundo, TAMANHO_CELULA / velocidade_visual)
	await tween.finished

	posicao_grade = nova_pos


func _atingir(alvo: Node2D) -> void:
	## Processa quando o projétil atinge um alvo
	esta_viajando = false

	if alvo.has_method("receber_dano"):
		if e_veneno and alvo.has_method("receber_veneno"):
			alvo.receber_veneno()
		else:
			# Calcula direção do ataque (de onde vem o projétil)
			var direcao_oposta = GameManager.obter_direcao_oposta(direcao)

			if alvo.is_in_group("jogador"):
				alvo.receber_dano(dano, direcao_oposta, e_veneno)
			else:
				alvo.receber_dano(dano)

	atingiu_alvo.emit(alvo)
	_destruir()


func _destruir() -> void:
	## Destrói o projétil
	esta_viajando = false
	destruido.emit()
	queue_free()


func _criar_textura_projetil() -> ImageTexture:
	## Cria textura placeholder para o projétil
	var img = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	var cor = Color(0.9, 0.7, 0.2) if not e_veneno else Color(0.5, 0.2, 0.8)

	# Forma de seta/projétil
	for y in range(8):
		var largura = 8 - y
		var inicio = y / 2
		for x in range(inicio, inicio + largura):
			if x >= 0 and x < 8:
				img.set_pixel(x, y, cor)

	return ImageTexture.create_from_image(img)
