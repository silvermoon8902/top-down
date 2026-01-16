extends Node
class_name LevelLoader
## LevelLoader - Carrega dados de fases do JSON e cria o mapa

const TAMANHO_CELULA: int = 16

# Tipos de tile
enum TipoTile {
	CHAO,
	ARVORE,
	RIO,
	OBSTACULO,
	SAIDA
}

# Dados carregados
var dados_fase: Dictionary = {}


func carregar_dados_fase(numero_fase: int) -> Dictionary:
	## Carrega os dados de uma fase do arquivo JSON
	var caminho = "res://data/level_%02d_data.json" % numero_fase

	if not FileAccess.file_exists(caminho):
		# Tenta carregar do arquivo genérico
		caminho = "res://data/levels.json"
		var dados_geral = _carregar_json(caminho)
		if dados_geral and dados_geral.has("fases"):
			for fase in dados_geral["fases"]:
				if fase.get("numero") == numero_fase:
					return fase
		push_warning("[LevelLoader] Dados da fase %d não encontrados" % numero_fase)
		return {}

	dados_fase = _carregar_json(caminho)
	return dados_fase


func _carregar_json(caminho: String) -> Dictionary:
	## Carrega um arquivo JSON
	if not FileAccess.file_exists(caminho):
		return {}

	var arquivo = FileAccess.open(caminho, FileAccess.READ)
	if not arquivo:
		return {}

	var json_string = arquivo.get_as_text()
	arquivo.close()

	var json = JSON.new()
	var erro = json.parse(json_string)

	if erro != OK:
		push_error("[LevelLoader] Erro ao parsear JSON: " + json.get_error_message())
		return {}

	return json.get_data()


func obter_tamanho_fase() -> Vector2i:
	## Retorna o tamanho da fase carregada
	if dados_fase.has("tamanho"):
		var tam = dados_fase["tamanho"]
		return Vector2i(tam[0], tam[1])
	return Vector2i(17, 17)


func obter_posicao_jogador() -> Vector2i:
	## Retorna a posição inicial do jogador
	if dados_fase.has("posicao_jogador"):
		var pos = dados_fase["posicao_jogador"]
		return Vector2i(pos[0], pos[1])
	return Vector2i(8, 15)


func obter_arvores() -> Array:
	## Retorna lista de posições de árvores
	if dados_fase.has("arvores"):
		var resultado: Array = []
		for pos in dados_fase["arvores"]:
			resultado.append(Vector2i(pos[0], pos[1]))
		return resultado
	return []


func obter_rio() -> Array:
	## Retorna lista de posições do rio
	if dados_fase.has("rio"):
		var resultado: Array = []
		for pos in dados_fase["rio"]:
			resultado.append(Vector2i(pos[0], pos[1]))
		return resultado
	return []


func obter_obstaculos() -> Array:
	## Retorna lista de posições de obstáculos
	if dados_fase.has("obstaculos"):
		var resultado: Array = []
		for pos in dados_fase["obstaculos"]:
			resultado.append(Vector2i(pos[0], pos[1]))
		return resultado
	return []


func obter_inimigos() -> Array:
	## Retorna lista de spawns de inimigos
	if dados_fase.has("inimigos_spawn"):
		return dados_fase["inimigos_spawn"]
	return []


func obter_baus() -> Array:
	## Retorna lista de spawns de baús
	if dados_fase.has("baus_spawn"):
		return dados_fase["baus_spawn"]
	return []


func obter_mapa_texto() -> Array:
	## Retorna o mapa em formato de texto
	if dados_fase.has("mapa"):
		return dados_fase["mapa"]
	return []


func processar_mapa(grid_system: GridSystem) -> void:
	## Processa o mapa e registra obstáculos no grid
	var mapa = obter_mapa_texto()

	for y in range(mapa.size()):
		var linha = mapa[y]
		for x in range(linha.length()):
			var char = linha[x]
			var pos = Vector2i(x, y)

			match char:
				"T":  # Árvore
					grid_system.adicionar_obstaculo(pos)
				"R":  # Rio
					grid_system.adicionar_obstaculo(pos)
				"#":  # Obstáculo/estrutura
					grid_system.adicionar_obstaculo(pos)


func criar_tiles_visuais(parent: Node2D) -> void:
	## Cria os sprites visuais para cada tile do mapa
	var mapa = obter_mapa_texto()
	var tamanho = obter_tamanho_fase()

	# Cria container para tiles
	var container_tiles = Node2D.new()
	container_tiles.name = "Tiles"
	parent.add_child(container_tiles)

	# Primeiro, preenche todo o chão
	for y in range(tamanho.y):
		for x in range(tamanho.x):
			var tile = Sprite2D.new()
			tile.texture = PlaceholderSprites.criar_textura_chao()
			tile.position = Vector2(x * TAMANHO_CELULA + TAMANHO_CELULA / 2, y * TAMANHO_CELULA + TAMANHO_CELULA / 2)
			container_tiles.add_child(tile)

	# Depois, adiciona os elementos sobre o chão
	for y in range(mapa.size()):
		var linha = mapa[y]
		for x in range(linha.length()):
			var char = linha[x]
			var pos_mundo = Vector2(x * TAMANHO_CELULA + TAMANHO_CELULA / 2, y * TAMANHO_CELULA + TAMANHO_CELULA / 2)

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
				tile.z_index = -1  # Atrás das entidades
				container_tiles.add_child(tile)
