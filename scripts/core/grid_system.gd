extends Node
class_name GridSystem
## GridSystem - Sistema de grade do jogo
## Gerencia posições, movimento e colisões na grade

# Sinais
signal entidade_moveu(entidade: Node2D, pos_antiga: Vector2i, pos_nova: Vector2i)
signal celula_ocupada(posicao: Vector2i, entidade: Node2D)
signal celula_liberada(posicao: Vector2i)

# Configurações da grade
var tamanho_grade: Vector2i = Vector2i(17, 17)
var tamanho_celula: int = 16

# Mapa de ocupação - armazena referências às entidades em cada célula
var _mapa_ocupacao: Dictionary = {}

# Mapa de obstáculos - células que não podem ser atravessadas
var _mapa_obstaculos: Dictionary = {}

# Referência ao TileMap (será definido pela fase)
var tilemap: TileMap = null


func _ready() -> void:
	## Inicializa o sistema de grade
	limpar_grade()


func limpar_grade() -> void:
	## Limpa todos os dados da grade
	_mapa_ocupacao.clear()
	_mapa_obstaculos.clear()


func configurar_grade(novo_tamanho: Vector2i, novo_tilemap: TileMap = null) -> void:
	## Configura a grade para uma nova fase
	tamanho_grade = novo_tamanho
	tilemap = novo_tilemap
	limpar_grade()


func posicao_mundo_para_grade(posicao_mundo: Vector2) -> Vector2i:
	## Converte posição do mundo para coordenadas da grade
	return Vector2i(
		int(posicao_mundo.x / tamanho_celula),
		int(posicao_mundo.y / tamanho_celula)
	)


func posicao_grade_para_mundo(posicao_grade: Vector2i) -> Vector2:
	## Converte coordenadas da grade para posição do mundo (centro da célula)
	return Vector2(
		posicao_grade.x * tamanho_celula + tamanho_celula / 2.0,
		posicao_grade.y * tamanho_celula + tamanho_celula / 2.0
	)


func esta_dentro_da_grade(posicao: Vector2i) -> bool:
	## Verifica se uma posição está dentro dos limites da grade
	return (posicao.x >= 0 and posicao.x < tamanho_grade.x and
			posicao.y >= 0 and posicao.y < tamanho_grade.y)


func esta_celula_livre(posicao: Vector2i) -> bool:
	## Verifica se uma célula está livre para movimento
	if not esta_dentro_da_grade(posicao):
		return false

	if _mapa_obstaculos.has(posicao):
		return false

	if _mapa_ocupacao.has(posicao):
		return false

	return true


func esta_celula_ocupada_por_inimigo(posicao: Vector2i) -> bool:
	## Verifica se uma célula está ocupada por um inimigo
	if not _mapa_ocupacao.has(posicao):
		return false

	var entidade = _mapa_ocupacao[posicao]
	return entidade.is_in_group("inimigos")


func esta_celula_ocupada_por_jogador(posicao: Vector2i) -> bool:
	## Verifica se uma célula está ocupada pelo jogador
	if not _mapa_ocupacao.has(posicao):
		return false

	var entidade = _mapa_ocupacao[posicao]
	return entidade.is_in_group("jogador")


func obter_entidade_em(posicao: Vector2i) -> Node2D:
	## Retorna a entidade em uma posição, ou null se vazia
	return _mapa_ocupacao.get(posicao, null)


func registrar_entidade(entidade: Node2D, posicao: Vector2i) -> bool:
	## Registra uma entidade em uma posição da grade
	## Retorna false se a posição já estiver ocupada
	if _mapa_ocupacao.has(posicao):
		return false

	_mapa_ocupacao[posicao] = entidade
	celula_ocupada.emit(posicao, entidade)
	return true


func remover_entidade(posicao: Vector2i) -> void:
	## Remove uma entidade de uma posição da grade
	if _mapa_ocupacao.has(posicao):
		_mapa_ocupacao.erase(posicao)
		celula_liberada.emit(posicao)


func mover_entidade(entidade: Node2D, pos_antiga: Vector2i, pos_nova: Vector2i) -> bool:
	## Move uma entidade de uma posição para outra
	## Retorna false se o movimento não for possível
	if not esta_celula_livre(pos_nova):
		return false

	remover_entidade(pos_antiga)
	registrar_entidade(entidade, pos_nova)
	entidade_moveu.emit(entidade, pos_antiga, pos_nova)
	return true


func adicionar_obstaculo(posicao: Vector2i) -> void:
	## Marca uma célula como obstáculo
	_mapa_obstaculos[posicao] = true


func remover_obstaculo(posicao: Vector2i) -> void:
	## Remove um obstáculo de uma célula
	if _mapa_obstaculos.has(posicao):
		_mapa_obstaculos.erase(posicao)


func e_obstaculo(posicao: Vector2i) -> bool:
	## Verifica se uma célula é um obstáculo
	return _mapa_obstaculos.has(posicao)


func obter_celulas_adjacentes(posicao: Vector2i) -> Array[Vector2i]:
	## Retorna as células adjacentes (4 direções)
	var adjacentes: Array[Vector2i] = []
	var direcoes = [
		Vector2i(0, -1),  # Cima
		Vector2i(1, 0),   # Direita
		Vector2i(0, 1),   # Baixo
		Vector2i(-1, 0)   # Esquerda
	]

	for direcao in direcoes:
		var pos_adjacente = posicao + direcao
		if esta_dentro_da_grade(pos_adjacente):
			adjacentes.append(pos_adjacente)

	return adjacentes


func obter_celulas_livres_adjacentes(posicao: Vector2i) -> Array[Vector2i]:
	## Retorna as células adjacentes que estão livres
	var livres: Array[Vector2i] = []

	for pos_adjacente in obter_celulas_adjacentes(posicao):
		if esta_celula_livre(pos_adjacente):
			livres.append(pos_adjacente)

	return livres


func obter_direcao_entre_posicoes(de: Vector2i, para: Vector2i) -> int:
	## Retorna a direção (0-3) entre duas posições adjacentes
	## 0=cima, 1=direita, 2=baixo, 3=esquerda, -1=não adjacente
	var diferenca = para - de

	if diferenca == Vector2i(0, -1):
		return 0  # Cima
	elif diferenca == Vector2i(1, 0):
		return 1  # Direita
	elif diferenca == Vector2i(0, 1):
		return 2  # Baixo
	elif diferenca == Vector2i(-1, 0):
		return 3  # Esquerda
	else:
		return -1  # Não adjacente


func calcular_distancia_manhattan(de: Vector2i, para: Vector2i) -> int:
	## Calcula a distância Manhattan entre duas posições
	return abs(para.x - de.x) + abs(para.y - de.y)


func encontrar_caminho(de: Vector2i, para: Vector2i) -> Array[Vector2i]:
	## Encontra um caminho entre duas posições usando A*
	## Retorna array vazio se não houver caminho
	if not esta_dentro_da_grade(de) or not esta_dentro_da_grade(para):
		return []

	if de == para:
		return [de]

	# Implementação simplificada de A*
	var abertos: Array[Vector2i] = [de]
	var fechados: Dictionary = {}
	var veio_de: Dictionary = {}
	var g_score: Dictionary = {de: 0}
	var f_score: Dictionary = {de: calcular_distancia_manhattan(de, para)}

	while not abertos.is_empty():
		# Encontra o nó com menor f_score
		var atual = abertos[0]
		var menor_f = f_score.get(atual, INF)

		for pos in abertos:
			var f = f_score.get(pos, INF)
			if f < menor_f:
				menor_f = f
				atual = pos

		if atual == para:
			# Reconstrói o caminho
			var caminho: Array[Vector2i] = [atual]
			while veio_de.has(atual):
				atual = veio_de[atual]
				caminho.push_front(atual)
			return caminho

		abertos.erase(atual)
		fechados[atual] = true

		for vizinho in obter_celulas_adjacentes(atual):
			if fechados.has(vizinho):
				continue

			# Verifica se pode passar (livre ou é o destino)
			if not esta_celula_livre(vizinho) and vizinho != para:
				continue

			var tentativa_g = g_score.get(atual, INF) + 1

			if not vizinho in abertos:
				abertos.append(vizinho)
			elif tentativa_g >= g_score.get(vizinho, INF):
				continue

			veio_de[vizinho] = atual
			g_score[vizinho] = tentativa_g
			f_score[vizinho] = tentativa_g + calcular_distancia_manhattan(vizinho, para)

	return []  # Nenhum caminho encontrado


func obter_proximo_passo_em_direcao(de: Vector2i, para: Vector2i) -> Vector2i:
	## Retorna o próximo passo para ir de uma posição a outra
	## Útil para IA de inimigos
	var caminho = encontrar_caminho(de, para)

	if caminho.size() > 1:
		return caminho[1]  # Retorna o segundo elemento (primeiro é a posição atual)

	return de  # Não há para onde ir


func obter_todas_entidades() -> Array:
	## Retorna todas as entidades registradas na grade
	return _mapa_ocupacao.values()


func obter_inimigos() -> Array:
	## Retorna todos os inimigos na grade
	var inimigos: Array = []
	for entidade in _mapa_ocupacao.values():
		if entidade.is_in_group("inimigos"):
			inimigos.append(entidade)
	return inimigos


func obter_posicao_jogador() -> Vector2i:
	## Retorna a posição do jogador na grade
	for posicao in _mapa_ocupacao:
		var entidade = _mapa_ocupacao[posicao]
		if entidade.is_in_group("jogador"):
			return posicao
	return Vector2i(-1, -1)  # Jogador não encontrado
