extends Node2D
class_name LevelManager
## LevelManager - Gerenciador de níveis/fases
## Carrega e configura fases, gerencia transições

# Sinais
signal fase_carregada(numero_fase: int)
signal fase_iniciada(numero_fase: int)
signal fase_completada(numero_fase: int)

# Constantes
const TAMANHO_CELULA: int = 16

# Referências aos sistemas
var grid_system: GridSystem = null
var turn_manager: TurnManager = null
var level_loader: LevelLoader = null

# Referências aos nós
@onready var container_tiles: Node2D = $Tiles
@onready var container_entidades: Node2D = $Entidades
@onready var hud: HUD = $HUD
@onready var camera: Camera2D = $Camera2D

# Cenas pré-carregadas
var cena_cavaleiro: PackedScene = preload("res://scenes/entities/knight.tscn")
var cena_bau: PackedScene = preload("res://scenes/entities/chest.tscn")

# Fábrica de inimigos
var enemy_factory: EnemyFactory = null

# Dados da fase atual
var numero_fase_atual: int = 1
var tamanho_fase: Vector2i = Vector2i(17, 17)
var cavaleiro: Cavaleiro = null
var inimigos: Array = []
var baus: Array = []


func _ready() -> void:
	## Inicializa o gerenciador de níveis
	_inicializar_sistemas()

	# Conecta sinais do GameManager
	GameManager.fase_completada.connect(_on_fase_completada)
	GameManager.cavaleiro_morreu.connect(_on_cavaleiro_morreu)

	# Carrega e inicia a fase atual
	carregar_fase(GameManager.fase_atual)
	iniciar_fase()


func _inicializar_sistemas() -> void:
	## Inicializa os sistemas de grade e turno
	grid_system = GridSystem.new()
	grid_system.name = "GridSystem"
	add_child(grid_system)

	turn_manager = TurnManager.new()
	turn_manager.name = "TurnManager"
	add_child(turn_manager)

	level_loader = LevelLoader.new()
	level_loader.name = "LevelLoader"
	add_child(level_loader)

	enemy_factory = EnemyFactory.new()
	enemy_factory.name = "EnemyFactory"
	add_child(enemy_factory)

	# Cria container de tiles se não existir
	if not container_tiles:
		container_tiles = Node2D.new()
		container_tiles.name = "Tiles"
		add_child(container_tiles)

	# Cria container de entidades se não existir
	if not container_entidades:
		container_entidades = Node2D.new()
		container_entidades.name = "Entidades"
		add_child(container_entidades)


func carregar_fase(numero_fase: int) -> void:
	## Carrega uma fase específica
	numero_fase_atual = numero_fase

	# Limpa fase anterior
	_limpar_fase()

	# Carrega dados da fase
	var dados = level_loader.carregar_dados_fase(numero_fase)

	# Configura tamanho da grade
	tamanho_fase = level_loader.obter_tamanho_fase()
	grid_system.configurar_grade(tamanho_fase, null)

	# Centraliza a câmera
	_centralizar_camera()

	# Cria tiles visuais
	_criar_tiles_visuais()

	# Processa mapa e registra obstáculos
	level_loader.processar_mapa(grid_system)

	# Spawna o cavaleiro
	_spawnar_cavaleiro()

	# Spawna inimigos
	_spawnar_inimigos(numero_fase)

	# Spawna baús
	_spawnar_baus(numero_fase)

	# Configura o turn manager
	turn_manager.configurar(grid_system, cavaleiro)

	fase_carregada.emit(numero_fase)
	print("[LevelManager] Fase %d carregada" % numero_fase)


func iniciar_fase() -> void:
	## Inicia a fase após carregamento
	turn_manager.iniciar_jogo()

	# Toca música apropriada
	var musica = AudioManager.obter_musica_para_fase(numero_fase_atual)
	AudioManager.tocar_musica(musica)

	fase_iniciada.emit(numero_fase_atual)
	print("[LevelManager] Fase %d iniciada" % numero_fase_atual)


func _limpar_fase() -> void:
	## Limpa todos os objetos da fase atual
	# Remove cavaleiro
	if cavaleiro and is_instance_valid(cavaleiro):
		cavaleiro.queue_free()
		cavaleiro = null

	# Remove inimigos
	for inimigo in inimigos:
		if is_instance_valid(inimigo):
			inimigo.queue_free()
	inimigos.clear()

	# Remove baús
	for bau in baus:
		if is_instance_valid(bau):
			bau.queue_free()
	baus.clear()

	# Limpa tiles
	if container_tiles:
		for child in container_tiles.get_children():
			child.queue_free()

	# Limpa entidades restantes
	if container_entidades:
		for child in container_entidades.get_children():
			child.queue_free()

	# Limpa grade e turno
	if grid_system:
		grid_system.limpar_grade()
	if turn_manager:
		turn_manager.resetar()


func _centralizar_camera() -> void:
	## Centraliza a câmera no meio do mapa
	if camera:
		var centro_x = (tamanho_fase.x * TAMANHO_CELULA) / 2.0
		var centro_y = (tamanho_fase.y * TAMANHO_CELULA) / 2.0
		camera.position = Vector2(centro_x, centro_y)


func _criar_tiles_visuais() -> void:
	## Cria os sprites visuais para cada tile do mapa
	var mapa = level_loader.obter_mapa_texto()

	# Se não há mapa definido, cria chão básico
	if mapa.is_empty():
		_criar_chao_basico()
		return

	# Primeiro, preenche todo o chão
	for y in range(tamanho_fase.y):
		for x in range(tamanho_fase.x):
			var tile = Sprite2D.new()
			tile.texture = PlaceholderSprites.criar_textura_chao()
			tile.position = Vector2(
				x * TAMANHO_CELULA + TAMANHO_CELULA / 2.0,
				y * TAMANHO_CELULA + TAMANHO_CELULA / 2.0
			)
			container_tiles.add_child(tile)

	# Depois, adiciona os elementos sobre o chão
	for y in range(mapa.size()):
		var linha = mapa[y]
		for x in range(linha.length()):
			var char = linha[x]
			var pos_mundo = Vector2(
				x * TAMANHO_CELULA + TAMANHO_CELULA / 2.0,
				y * TAMANHO_CELULA + TAMANHO_CELULA / 2.0
			)

			var tile: Sprite2D = null

			match char:
				"T":  # Árvore
					tile = Sprite2D.new()
					tile.texture = PlaceholderSprites.criar_textura_arvore()
				"R":  # Rio
					tile = Sprite2D.new()
					tile.texture = PlaceholderSprites.criar_textura_rio()
				"#":  # Obstáculo
					tile = Sprite2D.new()
					tile.texture = PlaceholderSprites.criar_textura_obstaculo()

			if tile:
				tile.position = pos_mundo
				tile.z_index = 0
				container_tiles.add_child(tile)


func _criar_chao_basico() -> void:
	## Cria um chão básico quando não há mapa definido
	for y in range(tamanho_fase.y):
		for x in range(tamanho_fase.x):
			var tile = Sprite2D.new()
			tile.texture = PlaceholderSprites.criar_textura_chao()
			tile.position = Vector2(
				x * TAMANHO_CELULA + TAMANHO_CELULA / 2.0,
				y * TAMANHO_CELULA + TAMANHO_CELULA / 2.0
			)
			container_tiles.add_child(tile)


func _spawnar_cavaleiro() -> void:
	## Cria e posiciona o cavaleiro
	cavaleiro = cena_cavaleiro.instantiate()
	container_entidades.add_child(cavaleiro)

	# Posição inicial da fase
	var pos_inicial = level_loader.obter_posicao_jogador()
	cavaleiro.configurar(grid_system, turn_manager, pos_inicial)

	# Aplica sprite placeholder
	if cavaleiro.sprite:
		cavaleiro.sprite.texture = PlaceholderSprites.criar_textura_cavaleiro()

	if cavaleiro.indicador_escudo:
		cavaleiro.indicador_escudo.texture = PlaceholderSprites.criar_textura_escudo()


func _spawnar_inimigos(numero_fase: int) -> void:
	## Spawna os inimigos da fase
	var dados_inimigos = level_loader.obter_inimigos()

	if dados_inimigos.is_empty():
		# Spawna inimigos de teste se não há dados
		_spawnar_inimigos_teste(numero_fase)
		return

	for dados in dados_inimigos:
		var pos_arr = dados.get("posicao", [8, 8])
		var tipo = dados.get("tipo", "goblin")
		var pos = Vector2i(pos_arr[0], pos_arr[1])

		# Verifica se posição está livre
		if not grid_system.esta_celula_livre(pos):
			pos = _encontrar_posicao_livre_proxima(pos)

		# Usa factory para criar inimigo
		var inimigo = enemy_factory.criar_inimigo(tipo, grid_system, turn_manager, pos)
		container_entidades.add_child(inimigo)

		inimigos.append(inimigo)


func _spawnar_inimigos_teste(numero_fase: int) -> void:
	## Spawna inimigos de teste quando não há dados da fase
	var quantidade = min(2 + numero_fase, 6)
	var tipos_disponiveis = enemy_factory.obter_inimigos_para_fase(numero_fase)

	for i in range(quantidade):
		var pos = _encontrar_posicao_livre_aleatoria()
		var tipo = tipos_disponiveis[randi() % tipos_disponiveis.size()]

		# Usa factory para criar inimigo
		var inimigo = enemy_factory.criar_inimigo(tipo, grid_system, turn_manager, pos)
		container_entidades.add_child(inimigo)

		inimigos.append(inimigo)


func _spawnar_baus(numero_fase: int) -> void:
	## Spawna os baús da fase
	var dados_baus = level_loader.obter_baus()

	if dados_baus.is_empty():
		# Spawna baú de teste
		var pos = _encontrar_posicao_livre_aleatoria()
		_criar_bau(pos, true)
		return

	for dados in dados_baus:
		var pos_arr = dados.get("posicao", [8, 8])
		var aleatorio = dados.get("item_aleatorio", true)
		var pos = Vector2i(pos_arr[0], pos_arr[1])

		# Verifica se posição está livre
		if not grid_system.esta_celula_livre(pos):
			pos = _encontrar_posicao_livre_proxima(pos)

		_criar_bau(pos, aleatorio)


func _criar_bau(pos: Vector2i, item_aleatorio: bool) -> void:
	## Cria um baú na posição especificada
	var bau = cena_bau.instantiate()
	bau.item_aleatorio = item_aleatorio
	container_entidades.add_child(bau)
	bau.configurar(grid_system, pos)

	# Aplica sprite placeholder
	if bau.sprite:
		bau.sprite.texture = PlaceholderSprites.criar_textura_bau()

	baus.append(bau)


func _encontrar_posicao_livre_aleatoria() -> Vector2i:
	## Encontra uma posição livre aleatória na grade
	var tentativas = 100

	for i in range(tentativas):
		var pos = Vector2i(
			randi_range(2, tamanho_fase.x - 3),
			randi_range(2, tamanho_fase.y - 3)
		)

		if grid_system.esta_celula_livre(pos):
			return pos

	return _encontrar_posicao_livre_proxima(Vector2i(tamanho_fase.x / 2, tamanho_fase.y / 2))


func _encontrar_posicao_livre_proxima(pos_original: Vector2i) -> Vector2i:
	## Encontra a posição livre mais próxima da posição original
	var raio = 1

	while raio < max(tamanho_fase.x, tamanho_fase.y):
		for dx in range(-raio, raio + 1):
			for dy in range(-raio, raio + 1):
				var pos = pos_original + Vector2i(dx, dy)
				if grid_system.esta_celula_livre(pos):
					return pos
		raio += 1

	push_warning("[LevelManager] Não encontrou posição livre!")
	return Vector2i(1, 1)


func _on_fase_completada(numero_fase: int) -> void:
	## Chamado quando a fase é completada
	AudioManager.tocar_sfx(AudioManager.SFX.FASE_COMPLETA)
	fase_completada.emit(numero_fase)
	print("[LevelManager] Fase %d completada!" % numero_fase)

	# Carrega próxima fase ou mostra tela de vitória
	if numero_fase < GameManager.TOTAL_FASES:
		# Delay antes de carregar próxima fase
		await get_tree().create_timer(1.5).timeout
		carregar_fase(numero_fase + 1)
		iniciar_fase()
	else:
		# Jogo completado!
		get_tree().change_scene_to_file("res://scenes/victory.tscn")


func _on_cavaleiro_morreu() -> void:
	## Chamado quando o cavaleiro morre
	print("[LevelManager] Game Over!")

	# Delay antes de mostrar game over
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
