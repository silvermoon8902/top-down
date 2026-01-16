extends Node2D
class_name Item
## Item - Item coletável no chão
## Pode ser coletado pelo jogador ao encostar

# Sinais
signal coletado()

# Tipo do item
@export var tipo_item: String = "coxa_frango"  # coxa_frango, pocao, elmo

# Referências
@onready var sprite: Sprite2D = $Sprite
@onready var area: Area2D = $Area2D

# Estado
var grid_system: GridSystem = null
var posicao_grade: Vector2i = Vector2i.ZERO


func _ready() -> void:
	## Inicializa o item
	add_to_group("itens")

	# Conecta sinais de colisão
	if area:
		area.body_entered.connect(_on_body_entered)

	# Atualiza visual baseado no tipo
	_atualizar_visual()


func configurar(grid: GridSystem, posicao_inicial: Vector2i) -> void:
	## Configura o item
	grid_system = grid
	posicao_grade = posicao_inicial

	# Não registra como entidade na grade (jogador pode passar por cima)

	# Posiciona no mundo
	position = grid_system.posicao_grade_para_mundo(posicao_grade)

	print("[Item] Criado: %s em %s" % [tipo_item, posicao_grade])


func _atualizar_visual() -> void:
	## Atualiza o sprite baseado no tipo de item
	if not sprite:
		return

	# Por enquanto, muda a cor do sprite placeholder
	# Quando tiver sprites reais, carrega a textura correta
	match tipo_item:
		"coxa_frango":
			sprite.modulate = Color(0.8, 0.6, 0.2)  # Marrom
		"pocao":
			sprite.modulate = Color(0.2, 0.8, 0.2)  # Verde
		"elmo":
			sprite.modulate = Color(0.7, 0.7, 0.7)  # Cinza


func _on_body_entered(body: Node2D) -> void:
	## Chamado quando algo entra na área do item
	if body.is_in_group("jogador"):
		coletar(body)


func coletar(jogador: Node2D) -> void:
	## Coleta o item
	if jogador.has_method("coletar_item"):
		var coletou = jogador.coletar_item(tipo_item)

		if coletou:
			coletado.emit()
			queue_free()
		else:
			print("[Item] Jogador não pôde coletar: %s (inventário cheio?)" % tipo_item)


func verificar_coleta_manual(pos_jogador: Vector2i) -> bool:
	## Verifica se o jogador está na mesma posição e coleta
	if pos_jogador == posicao_grade:
		var cavaleiro = GameManager.cavaleiro_ref
		if cavaleiro:
			coletar(cavaleiro)
			return true
	return false
