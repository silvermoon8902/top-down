extends Node2D
class_name Bau
## Bau - Baú que contém itens
## Pode ser aberto ao encostar ou atacar

# Sinais
signal aberto(item_tipo: String)

# Tipos de item que podem estar no baú
enum TipoItem {
	COXA_FRANGO,
	POCAO,
	ELMO
}

# Exportações
@export var item_dentro: TipoItem = TipoItem.COXA_FRANGO
@export var item_aleatorio: bool = false  # Se true, escolhe item aleatório

# Referências
@onready var sprite: Sprite2D = $Sprite

# Estado
var grid_system: GridSystem = null
var posicao_grade: Vector2i = Vector2i.ZERO
var esta_aberto: bool = false

# Mapeamento de tipos para strings
var _mapa_tipo_item: Dictionary = {
	TipoItem.COXA_FRANGO: "coxa_frango",
	TipoItem.POCAO: "pocao",
	TipoItem.ELMO: "elmo"
}

# Cenas de itens
var _cena_item: PackedScene = preload("res://scenes/entities/item.tscn")


func _ready() -> void:
	## Inicializa o baú
	add_to_group("baus")

	# Se item aleatório, escolhe um
	if item_aleatorio:
		item_dentro = _escolher_item_aleatorio()


func configurar(grid: GridSystem, posicao_inicial: Vector2i) -> void:
	## Configura o baú
	grid_system = grid
	posicao_grade = posicao_inicial

	# Registra na grade como obstáculo (não pode andar em cima)
	grid_system.registrar_entidade(self, posicao_grade)

	# Posiciona no mundo
	position = grid_system.posicao_grade_para_mundo(posicao_grade)


func abrir() -> void:
	## Abre o baú e libera o item
	if esta_aberto:
		return

	esta_aberto = true

	# Toca som
	AudioManager.tocar_sfx(AudioManager.SFX.ABRIR_BAU)

	# Obtém o tipo de item como string
	var tipo_string = _mapa_tipo_item.get(item_dentro, "coxa_frango")

	# Emite sinal
	aberto.emit(tipo_string)

	print("[Baú] Aberto! Item: %s" % tipo_string)

	# Cria o item no lugar do baú
	_criar_item(tipo_string)

	# Remove o baú
	_remover()


func _escolher_item_aleatorio() -> TipoItem:
	## Escolhe um item aleatório com probabilidades
	## Coxa: 50%, Poção: 35%, Elmo: 15%
	var chance = randf()

	if chance < 0.5:
		return TipoItem.COXA_FRANGO
	elif chance < 0.85:
		return TipoItem.POCAO
	else:
		return TipoItem.ELMO


func _criar_item(tipo: String) -> void:
	## Cria um item no lugar do baú
	if not _cena_item:
		push_warning("[Baú] Cena de item não encontrada")
		return

	var item = _cena_item.instantiate()
	item.tipo_item = tipo

	# Adiciona à cena
	get_parent().add_child(item)

	# Configura posição
	item.configurar(grid_system, posicao_grade)


func _remover() -> void:
	## Remove o baú da cena
	# Remove da grade
	grid_system.remover_entidade(posicao_grade)

	# Remove da cena
	queue_free()
