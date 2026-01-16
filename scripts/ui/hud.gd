extends CanvasLayer
class_name HUD
## HUD - Interface do usuário durante o jogo
## Mostra vida, armadura, inventário e indicador de escudo
## Estilo 1-bit (preto e branco)

# Referências aos nós de UI
@onready var container_vida: HBoxContainer = $MarginContainer/VBoxContainer/ContainerVida
@onready var container_armadura: HBoxContainer = $MarginContainer/VBoxContainer/ContainerArmadura
@onready var container_inventario: HBoxContainer = $MarginContainer/VBoxContainer/ContainerInventario
@onready var label_turno: Label = $MarginContainer/VBoxContainer/LabelTurno
@onready var label_escudo: Label = $MarginContainer/VBoxContainer/LabelEscudo
@onready var label_status: Label = $MarginContainer/VBoxContainer/LabelStatus

# Ícones de vida e armadura (serão criados dinamicamente)
var icones_vida: Array[TextureRect] = []
var icones_armadura: Array[TextureRect] = []
var slots_cura: Array[TextureRect] = []
var slots_antidoto: Array[TextureRect] = []

# Cores 1-bit
const PRETO = Color(0, 0, 0)
const BRANCO = Color(1, 1, 1)

# Mapeamento de direções para texto
var _texto_direcao: Dictionary = {
	0: "CIMA",
	1: "DIREITA",
	2: "BAIXO",
	3: "ESQUERDA"
}


func _ready() -> void:
	## Inicializa o HUD
	_criar_icones_vida()
	_criar_icones_armadura()
	_criar_slots_inventario()

	# Conecta aos sinais do GameManager
	GameManager.cavaleiro_stats_atualizados.connect(_atualizar_tudo)

	# Atualiza inicialmente
	_atualizar_tudo()


func _criar_icones_vida() -> void:
	## Cria os ícones de vida estilo 1-bit (corações)
	if not container_vida:
		return

	# Limpa existentes
	for child in container_vida.get_children():
		child.queue_free()

	icones_vida.clear()

	# Cria novos ícones de coração
	for i in range(GameManager.VIDA_MAXIMA):
		var icone = TextureRect.new()
		icone.custom_minimum_size = Vector2(16, 16)
		icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icone.texture = _criar_textura_coracao(true)
		container_vida.add_child(icone)
		icones_vida.append(icone)


func _criar_icones_armadura() -> void:
	## Cria os ícones de armadura estilo 1-bit (escudos)
	if not container_armadura:
		return

	# Limpa existentes
	for child in container_armadura.get_children():
		child.queue_free()

	icones_armadura.clear()

	# Cria novos ícones de escudo
	for i in range(GameManager.ARMADURA_MAXIMA):
		var icone = TextureRect.new()
		icone.custom_minimum_size = Vector2(16, 16)
		icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icone.texture = _criar_textura_escudo_hud(true)
		container_armadura.add_child(icone)
		icones_armadura.append(icone)


func _criar_slots_inventario() -> void:
	## Cria os slots de inventário estilo 1-bit
	if not container_inventario:
		return

	# Limpa existentes
	for child in container_inventario.get_children():
		child.queue_free()

	slots_cura.clear()
	slots_antidoto.clear()

	# Label de cura
	var label_cura = Label.new()
	label_cura.text = "Cura:"
	label_cura.add_theme_font_size_override("font_size", 10)
	label_cura.add_theme_color_override("font_color", BRANCO)
	container_inventario.add_child(label_cura)

	# Slots de cura (coxa de frango simplificada)
	for i in range(GameManager.SLOTS_CURA):
		var slot = TextureRect.new()
		slot.custom_minimum_size = Vector2(12, 12)
		slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot.texture = _criar_textura_slot_cura(false)
		container_inventario.add_child(slot)
		slots_cura.append(slot)

	# Espaçador
	var espacador = Control.new()
	espacador.custom_minimum_size = Vector2(10, 0)
	container_inventario.add_child(espacador)

	# Label de antídoto
	var label_antidoto = Label.new()
	label_antidoto.text = "Antídoto:"
	label_antidoto.add_theme_font_size_override("font_size", 10)
	label_antidoto.add_theme_color_override("font_color", BRANCO)
	container_inventario.add_child(label_antidoto)

	# Slots de antídoto (poção simplificada)
	for i in range(GameManager.SLOTS_ANTIDOTO):
		var slot = TextureRect.new()
		slot.custom_minimum_size = Vector2(12, 12)
		slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot.texture = _criar_textura_slot_antidoto(false)
		container_inventario.add_child(slot)
		slots_antidoto.append(slot)


func _criar_textura_coracao(cheio: bool) -> ImageTexture:
	## Cria textura de coração 1-bit
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Forma de coração
	var pontos_coracao = [
		# Topo esquerdo
		Vector2i(3, 4), Vector2i(4, 3), Vector2i(5, 3), Vector2i(6, 4),
		# Topo direito
		Vector2i(9, 4), Vector2i(10, 3), Vector2i(11, 3), Vector2i(12, 4),
		# Centro
		Vector2i(7, 5), Vector2i(8, 5),
		# Laterais
		Vector2i(2, 5), Vector2i(2, 6), Vector2i(2, 7),
		Vector2i(13, 5), Vector2i(13, 6), Vector2i(13, 7),
		# Parte inferior
		Vector2i(3, 8), Vector2i(4, 9), Vector2i(5, 10), Vector2i(6, 11), Vector2i(7, 12),
		Vector2i(12, 8), Vector2i(11, 9), Vector2i(10, 10), Vector2i(9, 11), Vector2i(8, 12),
		# Ponta
		Vector2i(7, 13), Vector2i(8, 13)
	]

	# Desenha borda
	for ponto in pontos_coracao:
		img.set_pixel(ponto.x, ponto.y, BRANCO)

	# Preenche interior se cheio
	if cheio:
		for y in range(4, 14):
			for x in range(2, 14):
				if img.get_pixel(x, y) == Color.TRANSPARENT:
					# Verifica se está dentro do coração
					var dentro = false
					var contagem = 0
					for px in range(x):
						if img.get_pixel(px, y) == BRANCO:
							contagem += 1
					if contagem > 0:
						var contagem2 = 0
						for px in range(x + 1, 14):
							if img.get_pixel(px, y) == BRANCO:
								contagem2 += 1
						if contagem2 > 0:
							dentro = true
					if dentro:
						img.set_pixel(x, y, BRANCO)

	return ImageTexture.create_from_image(img)


func _criar_textura_escudo_hud(cheio: bool) -> ImageTexture:
	## Cria textura de escudo 1-bit para HUD
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Forma de escudo
	# Topo
	for x in range(3, 13):
		img.set_pixel(x, 2, BRANCO)

	# Laterais superiores
	for y in range(2, 9):
		img.set_pixel(3, y, BRANCO)
		img.set_pixel(12, y, BRANCO)

	# Laterais inferiores (convergindo)
	img.set_pixel(4, 9, BRANCO)
	img.set_pixel(11, 9, BRANCO)
	img.set_pixel(5, 10, BRANCO)
	img.set_pixel(10, 10, BRANCO)
	img.set_pixel(6, 11, BRANCO)
	img.set_pixel(9, 11, BRANCO)
	img.set_pixel(7, 12, BRANCO)
	img.set_pixel(8, 12, BRANCO)

	# Ponta
	img.set_pixel(7, 13, BRANCO)
	img.set_pixel(8, 13, BRANCO)

	# Preenche interior se cheio
	if cheio:
		for y in range(3, 13):
			for x in range(4, 12):
				if img.get_pixel(x, y) == Color.TRANSPARENT:
					# Verifica limites baseado na altura
					var limite_esq = 3
					var limite_dir = 12
					if y >= 9:
						limite_esq = 3 + (y - 8)
						limite_dir = 12 - (y - 8)
					if x > limite_esq and x < limite_dir:
						img.set_pixel(x, y, BRANCO)

	return ImageTexture.create_from_image(img)


func _criar_textura_slot_cura(cheio: bool) -> ImageTexture:
	## Cria textura de slot de cura 1-bit (coxa de frango simplificada)
	var img = Image.create(12, 12, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	if cheio:
		# Carne (círculo)
		for x in range(3, 9):
			for y in range(1, 6):
				var dist = sqrt(pow(x - 6, 2) + pow(y - 3, 2))
				if dist <= 3:
					img.set_pixel(x, y, BRANCO)

		# Osso
		for y in range(5, 11):
			img.set_pixel(5, y, BRANCO)
			img.set_pixel(6, y, BRANCO)

		# Ponta do osso
		img.set_pixel(4, 10, BRANCO)
		img.set_pixel(7, 10, BRANCO)
	else:
		# Slot vazio (apenas borda)
		for x in range(2, 10):
			img.set_pixel(x, 1, BRANCO)
			img.set_pixel(x, 10, BRANCO)
		for y in range(1, 11):
			img.set_pixel(2, y, BRANCO)
			img.set_pixel(9, y, BRANCO)

	return ImageTexture.create_from_image(img)


func _criar_textura_slot_antidoto(cheio: bool) -> ImageTexture:
	## Cria textura de slot de antídoto 1-bit (poção simplificada)
	var img = Image.create(12, 12, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	if cheio:
		# Gargalo
		for x in range(4, 8):
			img.set_pixel(x, 1, BRANCO)
			img.set_pixel(x, 2, BRANCO)

		# Corpo da garrafa
		for x in range(3, 9):
			for y in range(3, 10):
				img.set_pixel(x, y, BRANCO)

		# Interior (padrão hachurado para indicar líquido)
		for x in range(4, 8):
			for y in range(5, 9):
				if (x + y) % 2 == 0:
					img.set_pixel(x, y, PRETO)
	else:
		# Slot vazio (apenas borda)
		for x in range(2, 10):
			img.set_pixel(x, 1, BRANCO)
			img.set_pixel(x, 10, BRANCO)
		for y in range(1, 11):
			img.set_pixel(2, y, BRANCO)
			img.set_pixel(9, y, BRANCO)

	return ImageTexture.create_from_image(img)


func _atualizar_tudo() -> void:
	## Atualiza todos os elementos do HUD
	_atualizar_vida()
	_atualizar_armadura()
	_atualizar_inventario()
	_atualizar_escudo()
	_atualizar_status()


func _atualizar_vida() -> void:
	## Atualiza os ícones de vida
	for i in range(icones_vida.size()):
		if i < GameManager.cavaleiro_vida:
			icones_vida[i].texture = _criar_textura_coracao(true)
		else:
			icones_vida[i].texture = _criar_textura_coracao(false)


func _atualizar_armadura() -> void:
	## Atualiza os ícones de armadura
	for i in range(icones_armadura.size()):
		if i < GameManager.cavaleiro_armadura:
			icones_armadura[i].texture = _criar_textura_escudo_hud(true)
		else:
			icones_armadura[i].texture = _criar_textura_escudo_hud(false)


func _atualizar_inventario() -> void:
	## Atualiza os slots de inventário
	# Slots de cura
	for i in range(slots_cura.size()):
		if i < GameManager.itens_cura:
			slots_cura[i].texture = _criar_textura_slot_cura(true)
		else:
			slots_cura[i].texture = _criar_textura_slot_cura(false)

	# Slots de antídoto
	for i in range(slots_antidoto.size()):
		if i < GameManager.itens_antidoto:
			slots_antidoto[i].texture = _criar_textura_slot_antidoto(true)
		else:
			slots_antidoto[i].texture = _criar_textura_slot_antidoto(false)


func _atualizar_escudo() -> void:
	## Atualiza o indicador de escudo
	if label_escudo:
		var direcao = _texto_direcao.get(GameManager.direcao_escudo, "?")
		label_escudo.text = "Escudo: " + direcao
		label_escudo.add_theme_color_override("font_color", BRANCO)


func _atualizar_status() -> void:
	## Atualiza o label de status
	if label_status:
		var status = ""

		if GameManager.cavaleiro_envenenado:
			status = "ENVENENADO!"
			# Em 1-bit, usamos inversão ou padrão diferente
			label_status.add_theme_color_override("font_color", BRANCO)
		else:
			label_status.add_theme_color_override("font_color", BRANCO)

		label_status.text = status


func atualizar_turno(numero_turno: int) -> void:
	## Atualiza o número do turno
	if label_turno:
		label_turno.text = "Turno: %d" % numero_turno
		label_turno.add_theme_color_override("font_color", BRANCO)


func mostrar_mensagem(texto: String, duracao: float = 2.0) -> void:
	## Mostra uma mensagem temporária
	if label_status:
		label_status.text = texto
		label_status.add_theme_color_override("font_color", BRANCO)

		await get_tree().create_timer(duracao).timeout

		# Restaura o status normal
		_atualizar_status()
