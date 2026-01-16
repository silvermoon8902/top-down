extends Node
class_name PlaceholderSprites
## PlaceholderSprites - Gera sprites em estilo 1-bit (preto e branco)
## Inspirado no visual do jogo "1 Bit Survivor"

const TAMANHO_CELULA: int = 16

# Paleta 1-bit - apenas duas cores
const PRETO: Color = Color(0, 0, 0)
const BRANCO: Color = Color(1, 1, 1)


static func criar_textura_cavaleiro() -> ImageTexture:
	## Cria sprite do cavaleiro - silhueta branca com detalhes
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Corpo principal (branco)
	for x in range(5, 11):
		for y in range(5, 13):
			img.set_pixel(x, y, BRANCO)

	# Cabeça/Elmo
	for x in range(5, 11):
		for y in range(2, 5):
			img.set_pixel(x, y, BRANCO)

	# Crista do elmo
	for x in range(7, 9):
		img.set_pixel(x, 1, BRANCO)

	# Viseira (olhos) - linha preta
	for x in range(6, 10):
		img.set_pixel(x, 3, PRETO)

	# Detalhes do corpo - linhas pretas para definir armadura
	for x in range(5, 11):
		img.set_pixel(x, 7, PRETO)  # Cinto

	# Braços
	img.set_pixel(4, 6, BRANCO)
	img.set_pixel(4, 7, BRANCO)
	img.set_pixel(4, 8, BRANCO)
	img.set_pixel(11, 6, BRANCO)
	img.set_pixel(11, 7, BRANCO)
	img.set_pixel(11, 8, BRANCO)

	# Espada no lado direito
	img.set_pixel(12, 5, BRANCO)
	img.set_pixel(12, 6, BRANCO)
	img.set_pixel(12, 7, BRANCO)
	img.set_pixel(12, 8, BRANCO)
	img.set_pixel(12, 9, BRANCO)

	# Pernas
	for y in range(13, 16):
		img.set_pixel(6, y, BRANCO)
		img.set_pixel(7, y, BRANCO)
		img.set_pixel(8, y, BRANCO)
		img.set_pixel(9, y, BRANCO)

	# Separação das pernas
	img.set_pixel(7, 14, PRETO)
	img.set_pixel(8, 14, PRETO)

	return ImageTexture.create_from_image(img)


static func criar_textura_escudo() -> ImageTexture:
	## Cria sprite do indicador de escudo - triângulo branco com borda preta
	var img = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Triângulo preenchido branco
	for y in range(1, 7):
		var largura = 7 - y
		var inicio = y / 2
		for x in range(inicio, inicio + largura):
			if x >= 0 and x < 8:
				img.set_pixel(x, y, BRANCO)

	# Borda preta
	# Lado esquerdo
	for y in range(1, 7):
		var inicio = y / 2
		if inicio >= 0 and inicio < 8:
			img.set_pixel(inicio, y, PRETO)

	# Lado direito
	for y in range(1, 7):
		var fim = 6 - y / 2
		if fim >= 0 and fim < 8:
			img.set_pixel(fim, y, PRETO)

	# Topo
	for x in range(1, 6):
		img.set_pixel(x, 1, PRETO)

	return ImageTexture.create_from_image(img)


static func criar_textura_inimigo() -> ImageTexture:
	## Cria sprite de inimigo genérico - forma básica preta
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Corpo principal (preto)
	for x in range(4, 12):
		for y in range(4, 14):
			img.set_pixel(x, y, PRETO)

	# Cabeça
	for x in range(5, 11):
		for y in range(1, 5):
			img.set_pixel(x, y, PRETO)

	# Olhos brancos (para contraste)
	img.set_pixel(6, 2, BRANCO)
	img.set_pixel(7, 2, BRANCO)
	img.set_pixel(8, 2, BRANCO)
	img.set_pixel(9, 2, BRANCO)

	# Garras/braços
	img.set_pixel(3, 6, PRETO)
	img.set_pixel(3, 7, PRETO)
	img.set_pixel(3, 8, PRETO)
	img.set_pixel(12, 6, PRETO)
	img.set_pixel(12, 7, PRETO)
	img.set_pixel(12, 8, PRETO)

	return ImageTexture.create_from_image(img)


static func criar_textura_arvore() -> ImageTexture:
	## Cria sprite de árvore - copa com padrão e tronco
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Copa da árvore (círculo preto com padrão)
	var centro_x = 8
	var centro_y = 5
	var raio = 5

	for x in range(TAMANHO_CELULA):
		for y in range(11):
			var dist = sqrt(pow(x - centro_x, 2) + pow(y - centro_y, 2))
			if dist <= raio:
				# Padrão de dithering para textura de folhas
				if (x + y) % 2 == 0:
					img.set_pixel(x, y, PRETO)
				else:
					img.set_pixel(x, y, BRANCO)

	# Borda sólida da copa
	for x in range(TAMANHO_CELULA):
		for y in range(11):
			var dist = sqrt(pow(x - centro_x, 2) + pow(y - centro_y, 2))
			if dist > raio - 1 and dist <= raio:
				img.set_pixel(x, y, PRETO)

	# Tronco (branco com borda preta)
	for x in range(6, 10):
		for y in range(9, 16):
			img.set_pixel(x, y, BRANCO)

	# Borda do tronco
	for y in range(9, 16):
		img.set_pixel(6, y, PRETO)
		img.set_pixel(9, y, PRETO)

	return ImageTexture.create_from_image(img)


static func criar_textura_rio() -> ImageTexture:
	## Cria sprite de água/rio - padrão de ondas 1-bit
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(PRETO)

	# Padrão de ondas horizontais
	for y in range(TAMANHO_CELULA):
		for x in range(TAMANHO_CELULA):
			# Cria ondas com offset baseado na linha
			var offset = (y / 4) * 2
			if (x + offset) % 4 < 2:
				img.set_pixel(x, y, BRANCO)

	return ImageTexture.create_from_image(img)


static func criar_textura_chao() -> ImageTexture:
	## Cria sprite de chão/grama - padrão sutil
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(BRANCO)

	# Pontos esparsos representando grama/textura
	var pontos = [
		Vector2i(2, 3), Vector2i(7, 1), Vector2i(12, 4),
		Vector2i(4, 8), Vector2i(9, 6), Vector2i(14, 9),
		Vector2i(1, 12), Vector2i(6, 14), Vector2i(11, 11),
		Vector2i(3, 5), Vector2i(10, 13), Vector2i(13, 2)
	]

	for ponto in pontos:
		img.set_pixel(ponto.x, ponto.y, PRETO)

	return ImageTexture.create_from_image(img)


static func criar_textura_obstaculo() -> ImageTexture:
	## Cria sprite de obstáculo/pedra - padrão de tijolos 1-bit
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(BRANCO)

	# Padrão de tijolos/pedras
	for x in range(TAMANHO_CELULA):
		for y in range(TAMANHO_CELULA):
			# Linhas horizontais
			if y % 4 == 0:
				img.set_pixel(x, y, PRETO)
			# Linhas verticais alternadas
			elif y % 8 < 4:
				if x % 8 == 0:
					img.set_pixel(x, y, PRETO)
			else:
				if (x + 4) % 8 == 0:
					img.set_pixel(x, y, PRETO)

	# Borda externa
	for x in range(TAMANHO_CELULA):
		img.set_pixel(x, 0, PRETO)
		img.set_pixel(x, 15, PRETO)
	for y in range(TAMANHO_CELULA):
		img.set_pixel(0, y, PRETO)
		img.set_pixel(15, y, PRETO)

	return ImageTexture.create_from_image(img)


static func criar_textura_bau() -> ImageTexture:
	## Cria sprite de baú - forma retangular com detalhes
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Corpo do baú (branco)
	for x in range(2, 14):
		for y in range(5, 14):
			img.set_pixel(x, y, BRANCO)

	# Tampa do baú
	for x in range(2, 14):
		for y in range(3, 6):
			img.set_pixel(x, y, BRANCO)

	# Borda preta do baú
	for x in range(2, 14):
		img.set_pixel(x, 3, PRETO)
		img.set_pixel(x, 13, PRETO)
	for y in range(3, 14):
		img.set_pixel(2, y, PRETO)
		img.set_pixel(13, y, PRETO)

	# Linha divisória tampa/corpo
	for x in range(2, 14):
		img.set_pixel(x, 5, PRETO)

	# Fechadura (quadrado preto no centro)
	for x in range(6, 10):
		for y in range(7, 11):
			img.set_pixel(x, y, PRETO)

	# Buraco da fechadura (branco)
	img.set_pixel(7, 8, BRANCO)
	img.set_pixel(8, 8, BRANCO)
	img.set_pixel(7, 9, BRANCO)
	img.set_pixel(8, 9, BRANCO)

	return ImageTexture.create_from_image(img)


static func criar_textura_item_cura() -> ImageTexture:
	## Cria sprite de coxa de frango - silhueta reconhecível
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Parte da carne (preenchimento branco)
	for x in range(4, 12):
		for y in range(2, 9):
			var dist = sqrt(pow(x - 8, 2) + pow(y - 5, 2))
			if dist <= 4:
				img.set_pixel(x, y, BRANCO)

	# Borda preta da carne
	for x in range(4, 12):
		for y in range(2, 9):
			var dist = sqrt(pow(x - 8, 2) + pow(y - 5, 2))
			if dist > 3 and dist <= 4:
				img.set_pixel(x, y, PRETO)

	# Osso (branco com borda)
	for y in range(8, 15):
		img.set_pixel(7, y, BRANCO)
		img.set_pixel(8, y, BRANCO)

	# Borda do osso
	for y in range(8, 15):
		img.set_pixel(6, y, PRETO)
		img.set_pixel(9, y, PRETO)

	# Ponta do osso
	img.set_pixel(6, 14, BRANCO)
	img.set_pixel(9, 14, BRANCO)
	img.set_pixel(5, 14, PRETO)
	img.set_pixel(10, 14, PRETO)

	return ImageTexture.create_from_image(img)


static func criar_textura_item_pocao() -> ImageTexture:
	## Cria sprite de poção - garrafa com líquido
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Gargalo da garrafa
	for x in range(6, 10):
		for y in range(1, 4):
			img.set_pixel(x, y, BRANCO)

	# Corpo da garrafa
	for x in range(4, 12):
		for y in range(4, 14):
			img.set_pixel(x, y, BRANCO)

	# Borda preta
	for x in range(6, 10):
		img.set_pixel(x, 1, PRETO)
	for y in range(1, 4):
		img.set_pixel(6, y, PRETO)
		img.set_pixel(9, y, PRETO)
	for x in range(4, 12):
		img.set_pixel(x, 4, PRETO)
		img.set_pixel(x, 13, PRETO)
	for y in range(4, 14):
		img.set_pixel(4, y, PRETO)
		img.set_pixel(11, y, PRETO)

	# Líquido dentro (metade inferior preenchida com padrão)
	for x in range(5, 11):
		for y in range(8, 13):
			if (x + y) % 2 == 0:
				img.set_pixel(x, y, PRETO)

	# Rolha
	for x in range(6, 10):
		img.set_pixel(x, 1, PRETO)
		img.set_pixel(x, 2, PRETO)

	return ImageTexture.create_from_image(img)


static func criar_textura_item_elmo() -> ImageTexture:
	## Cria sprite de elmo - capacete com viseira
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Corpo do elmo (branco)
	for x in range(3, 13):
		for y in range(3, 14):
			img.set_pixel(x, y, BRANCO)

	# Topo arredondado
	for x in range(4, 12):
		img.set_pixel(x, 2, BRANCO)
	for x in range(5, 11):
		img.set_pixel(x, 1, BRANCO)

	# Crista no topo
	for y in range(0, 3):
		img.set_pixel(7, y, PRETO)
		img.set_pixel(8, y, PRETO)

	# Borda externa preta
	for x in range(5, 11):
		img.set_pixel(x, 1, PRETO)
	for x in range(4, 12):
		img.set_pixel(x, 2, PRETO)
	for x in range(3, 13):
		img.set_pixel(x, 3, PRETO)
		img.set_pixel(x, 13, PRETO)
	for y in range(3, 14):
		img.set_pixel(3, y, PRETO)
		img.set_pixel(12, y, PRETO)

	# Abertura para os olhos (viseira preta)
	for x in range(4, 12):
		for y in range(6, 9):
			img.set_pixel(x, y, PRETO)

	# Proteção do nariz
	for y in range(9, 12):
		img.set_pixel(7, y, PRETO)
		img.set_pixel(8, y, PRETO)

	return ImageTexture.create_from_image(img)


static func criar_textura_saida() -> ImageTexture:
	## Cria sprite de saída/portal - arco com interior escuro
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(BRANCO)  # Fundo branco (chão)

	# Pilares do portal (branco com borda)
	for y in range(1, 15):
		# Pilar esquerdo
		img.set_pixel(2, y, PRETO)
		img.set_pixel(3, y, BRANCO)
		img.set_pixel(4, y, BRANCO)
		img.set_pixel(5, y, PRETO)

		# Pilar direito
		img.set_pixel(10, y, PRETO)
		img.set_pixel(11, y, BRANCO)
		img.set_pixel(12, y, BRANCO)
		img.set_pixel(13, y, PRETO)

	# Arco superior
	for x in range(2, 14):
		img.set_pixel(x, 1, PRETO)
		img.set_pixel(x, 2, PRETO)

	# Interior do portal (preto com padrão mágico)
	for x in range(6, 10):
		for y in range(3, 15):
			img.set_pixel(x, y, PRETO)

	# Brilhos mágicos no portal (brancos)
	img.set_pixel(7, 5, BRANCO)
	img.set_pixel(8, 8, BRANCO)
	img.set_pixel(7, 11, BRANCO)
	img.set_pixel(8, 13, BRANCO)

	return ImageTexture.create_from_image(img)


# === FUNÇÕES AUXILIARES PARA CRIAR SILHUETAS DE INIMIGOS ÚNICOS ===

static func criar_textura_goblin() -> ImageTexture:
	## Goblin - pequeno, orelhas pontudas
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Corpo
	for x in range(5, 11):
		for y in range(6, 14):
			img.set_pixel(x, y, PRETO)

	# Cabeça grande
	for x in range(4, 12):
		for y in range(2, 7):
			img.set_pixel(x, y, PRETO)

	# Orelhas pontudas
	img.set_pixel(3, 2, PRETO)
	img.set_pixel(3, 3, PRETO)
	img.set_pixel(12, 2, PRETO)
	img.set_pixel(12, 3, PRETO)

	# Olhos
	img.set_pixel(5, 4, BRANCO)
	img.set_pixel(6, 4, BRANCO)
	img.set_pixel(9, 4, BRANCO)
	img.set_pixel(10, 4, BRANCO)

	# Boca/dentes
	img.set_pixel(7, 5, BRANCO)
	img.set_pixel(8, 5, BRANCO)

	return ImageTexture.create_from_image(img)


static func criar_textura_esqueleto() -> ImageTexture:
	## Esqueleto - ossos brancos, crânio
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Crânio (branco)
	for x in range(5, 11):
		for y in range(1, 6):
			img.set_pixel(x, y, BRANCO)

	# Órbitas dos olhos (preto)
	img.set_pixel(6, 3, PRETO)
	img.set_pixel(7, 3, PRETO)
	img.set_pixel(8, 3, PRETO)
	img.set_pixel(9, 3, PRETO)

	# Nariz
	img.set_pixel(7, 4, PRETO)
	img.set_pixel(8, 4, PRETO)

	# Caixa torácica (linhas brancas)
	for y in range(6, 11):
		img.set_pixel(6, y, BRANCO)
		img.set_pixel(7, y, BRANCO)
		img.set_pixel(8, y, BRANCO)
		img.set_pixel(9, y, BRANCO)

	# Costelas (linhas pretas)
	for x in range(6, 10):
		img.set_pixel(x, 7, PRETO)
		img.set_pixel(x, 9, PRETO)

	# Pelve
	for x in range(5, 11):
		img.set_pixel(x, 11, BRANCO)

	# Pernas (ossos)
	for y in range(12, 16):
		img.set_pixel(6, y, BRANCO)
		img.set_pixel(9, y, BRANCO)

	# Braços
	for x in range(3, 6):
		img.set_pixel(x, 7, BRANCO)
	for x in range(10, 13):
		img.set_pixel(x, 7, BRANCO)

	return ImageTexture.create_from_image(img)


static func criar_textura_slime() -> ImageTexture:
	## Slime - forma de gota/bolha
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Forma de gota (preenchida com padrão)
	var centro_x = 8
	var centro_y = 9

	for x in range(TAMANHO_CELULA):
		for y in range(4, 15):
			var dist = sqrt(pow(x - centro_x, 2) + pow((y - centro_y) * 0.8, 2))
			if dist <= 5:
				if (x + y) % 3 == 0:
					img.set_pixel(x, y, BRANCO)
				else:
					img.set_pixel(x, y, PRETO)

	# Olhos (brancos)
	img.set_pixel(6, 8, BRANCO)
	img.set_pixel(7, 8, BRANCO)
	img.set_pixel(9, 8, BRANCO)
	img.set_pixel(10, 8, BRANCO)

	return ImageTexture.create_from_image(img)


static func criar_textura_cobra() -> ImageTexture:
	## Cobra - forma ondulada
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Corpo ondulado
	var pontos_corpo = [
		Vector2i(3, 10), Vector2i(4, 9), Vector2i(5, 8), Vector2i(6, 8),
		Vector2i(7, 9), Vector2i(8, 10), Vector2i(9, 10), Vector2i(10, 9),
		Vector2i(11, 8), Vector2i(12, 7)
	]

	for ponto in pontos_corpo:
		img.set_pixel(ponto.x, ponto.y, PRETO)
		img.set_pixel(ponto.x, ponto.y + 1, PRETO)
		img.set_pixel(ponto.x, ponto.y + 2, PRETO)

	# Cabeça (maior)
	for x in range(11, 15):
		for y in range(5, 10):
			img.set_pixel(x, y, PRETO)

	# Olho
	img.set_pixel(13, 6, BRANCO)

	# Língua bifurcada
	img.set_pixel(15, 7, PRETO)
	img.set_pixel(15, 6, PRETO)
	img.set_pixel(15, 8, PRETO)

	return ImageTexture.create_from_image(img)


static func criar_textura_morcego() -> ImageTexture:
	## Morcego - asas abertas
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Corpo central
	for x in range(6, 10):
		for y in range(5, 12):
			img.set_pixel(x, y, PRETO)

	# Cabeça com orelhas
	for x in range(6, 10):
		for y in range(3, 6):
			img.set_pixel(x, y, PRETO)

	# Orelhas pontudas
	img.set_pixel(6, 2, PRETO)
	img.set_pixel(9, 2, PRETO)

	# Olhos
	img.set_pixel(7, 4, BRANCO)
	img.set_pixel(8, 4, BRANCO)

	# Asas (esquerda)
	for i in range(5):
		img.set_pixel(5 - i, 6 + i, PRETO)
		img.set_pixel(4 - i, 6 + i, PRETO)
		if i < 4:
			img.set_pixel(5 - i, 7 + i, PRETO)

	# Asas (direita)
	for i in range(5):
		img.set_pixel(10 + i, 6 + i, PRETO)
		img.set_pixel(11 + i, 6 + i, PRETO)
		if i < 4:
			img.set_pixel(10 + i, 7 + i, PRETO)

	return ImageTexture.create_from_image(img)


static func criar_textura_lobo() -> ImageTexture:
	## Lobo - quadrúpede com focinho
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Corpo (horizontal)
	for x in range(3, 13):
		for y in range(7, 11):
			img.set_pixel(x, y, PRETO)

	# Cabeça
	for x in range(10, 15):
		for y in range(4, 9):
			img.set_pixel(x, y, PRETO)

	# Focinho
	img.set_pixel(15, 6, PRETO)
	img.set_pixel(15, 7, PRETO)

	# Orelhas
	img.set_pixel(11, 3, PRETO)
	img.set_pixel(13, 3, PRETO)

	# Olho
	img.set_pixel(12, 5, BRANCO)

	# Pernas
	for y in range(11, 15):
		img.set_pixel(4, y, PRETO)
		img.set_pixel(5, y, PRETO)
		img.set_pixel(10, y, PRETO)
		img.set_pixel(11, y, PRETO)

	# Cauda
	img.set_pixel(2, 6, PRETO)
	img.set_pixel(1, 5, PRETO)
	img.set_pixel(2, 7, PRETO)

	return ImageTexture.create_from_image(img)


static func criar_textura_aranha() -> ImageTexture:
	## Aranha - corpo com 8 patas
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Corpo (duas partes)
	# Abdômen
	for x in range(5, 11):
		for y in range(8, 13):
			img.set_pixel(x, y, PRETO)

	# Cefalotórax
	for x in range(6, 10):
		for y in range(5, 9):
			img.set_pixel(x, y, PRETO)

	# Olhos (múltiplos)
	img.set_pixel(7, 6, BRANCO)
	img.set_pixel(8, 6, BRANCO)

	# Patas (4 de cada lado)
	# Esquerda
	img.set_pixel(4, 6, PRETO)
	img.set_pixel(3, 5, PRETO)
	img.set_pixel(4, 8, PRETO)
	img.set_pixel(3, 9, PRETO)
	img.set_pixel(4, 10, PRETO)
	img.set_pixel(3, 11, PRETO)
	img.set_pixel(4, 12, PRETO)
	img.set_pixel(3, 13, PRETO)

	# Direita
	img.set_pixel(11, 6, PRETO)
	img.set_pixel(12, 5, PRETO)
	img.set_pixel(11, 8, PRETO)
	img.set_pixel(12, 9, PRETO)
	img.set_pixel(11, 10, PRETO)
	img.set_pixel(12, 11, PRETO)
	img.set_pixel(11, 12, PRETO)
	img.set_pixel(12, 13, PRETO)

	return ImageTexture.create_from_image(img)


static func criar_textura_mago() -> ImageTexture:
	## Mago - figura com capuz e cajado
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Robe (corpo largo)
	for x in range(4, 12):
		for y in range(5, 15):
			img.set_pixel(x, y, PRETO)

	# Capuz pontudo
	for x in range(5, 11):
		for y in range(2, 6):
			img.set_pixel(x, y, PRETO)

	# Ponta do capuz
	img.set_pixel(7, 1, PRETO)
	img.set_pixel(8, 1, PRETO)
	img.set_pixel(7, 0, PRETO)
	img.set_pixel(8, 0, PRETO)

	# Rosto (sombra com olhos)
	img.set_pixel(6, 4, BRANCO)
	img.set_pixel(9, 4, BRANCO)

	# Cajado
	for y in range(3, 15):
		img.set_pixel(13, y, BRANCO)

	# Orbe no topo do cajado
	img.set_pixel(12, 2, BRANCO)
	img.set_pixel(13, 2, BRANCO)
	img.set_pixel(14, 2, BRANCO)
	img.set_pixel(13, 1, BRANCO)
	img.set_pixel(13, 3, BRANCO)

	return ImageTexture.create_from_image(img)


static func criar_textura_cavaleiro_negro() -> ImageTexture:
	## Cavaleiro Negro - armadura pesada com espada
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Corpo/armadura
	for x in range(4, 12):
		for y in range(4, 14):
			img.set_pixel(x, y, PRETO)

	# Cabeça/elmo
	for x in range(5, 11):
		for y in range(1, 5):
			img.set_pixel(x, y, PRETO)

	# Chifres no elmo
	img.set_pixel(4, 1, PRETO)
	img.set_pixel(4, 0, PRETO)
	img.set_pixel(11, 1, PRETO)
	img.set_pixel(11, 0, PRETO)

	# Viseira (linha branca)
	for x in range(6, 10):
		img.set_pixel(x, 3, BRANCO)

	# Espada grande
	for y in range(2, 14):
		img.set_pixel(13, y, BRANCO)
		img.set_pixel(14, y, BRANCO)

	# Guarda da espada
	for x in range(12, 16):
		img.set_pixel(x, 6, BRANCO)

	return ImageTexture.create_from_image(img)


static func criar_textura_zumbi() -> ImageTexture:
	## Zumbi - figura deformada com braços estendidos
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Corpo torto
	for x in range(5, 11):
		for y in range(5, 14):
			img.set_pixel(x, y, PRETO)

	# Cabeça inclinada
	for x in range(6, 11):
		for y in range(1, 6):
			img.set_pixel(x, y, PRETO)

	# Olhos (um maior que outro)
	img.set_pixel(7, 3, BRANCO)
	img.set_pixel(8, 3, BRANCO)
	img.set_pixel(9, 3, BRANCO)

	# Boca aberta
	for x in range(7, 10):
		img.set_pixel(x, 4, BRANCO)

	# Braços estendidos para frente
	for x in range(11, 15):
		img.set_pixel(x, 7, PRETO)
		img.set_pixel(x, 8, PRETO)

	# Pernas arrastando
	for y in range(14, 16):
		img.set_pixel(6, y, PRETO)
		img.set_pixel(9, y, PRETO)
		img.set_pixel(10, y, PRETO)

	return ImageTexture.create_from_image(img)


static func criar_textura_golem() -> ImageTexture:
	## Golem - figura grande e blocada
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Corpo grande (quadrado)
	for x in range(3, 13):
		for y in range(4, 14):
			img.set_pixel(x, y, PRETO)

	# Cabeça pequena
	for x in range(5, 11):
		for y in range(1, 5):
			img.set_pixel(x, y, PRETO)

	# Olhos (pequenos pontos)
	img.set_pixel(6, 2, BRANCO)
	img.set_pixel(9, 2, BRANCO)

	# Padrão de pedra (rachaduras brancas)
	img.set_pixel(5, 6, BRANCO)
	img.set_pixel(6, 7, BRANCO)
	img.set_pixel(4, 9, BRANCO)
	img.set_pixel(10, 8, BRANCO)
	img.set_pixel(11, 10, BRANCO)
	img.set_pixel(8, 11, BRANCO)

	# Braços grossos
	for y in range(5, 10):
		img.set_pixel(2, y, PRETO)
		img.set_pixel(1, y, PRETO)
		img.set_pixel(13, y, PRETO)
		img.set_pixel(14, y, PRETO)

	# Pernas curtas e grossas
	for x in range(4, 7):
		img.set_pixel(x, 14, PRETO)
		img.set_pixel(x, 15, PRETO)
	for x in range(9, 12):
		img.set_pixel(x, 14, PRETO)
		img.set_pixel(x, 15, PRETO)

	return ImageTexture.create_from_image(img)


static func criar_textura_arqueiro() -> ImageTexture:
	## Arqueiro Goblin - goblin com arco
	var img = Image.create(TAMANHO_CELULA, TAMANHO_CELULA, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Corpo (igual ao goblin mas menor)
	for x in range(5, 10):
		for y in range(6, 13):
			img.set_pixel(x, y, PRETO)

	# Cabeça
	for x in range(4, 11):
		for y in range(2, 7):
			img.set_pixel(x, y, PRETO)

	# Orelhas pontudas
	img.set_pixel(3, 3, PRETO)
	img.set_pixel(11, 3, PRETO)

	# Olhos
	img.set_pixel(5, 4, BRANCO)
	img.set_pixel(9, 4, BRANCO)

	# Arco (curva branca)
	for y in range(4, 13):
		img.set_pixel(12, y, BRANCO)
	img.set_pixel(13, 6, BRANCO)
	img.set_pixel(13, 7, BRANCO)
	img.set_pixel(13, 8, BRANCO)
	img.set_pixel(13, 9, BRANCO)
	img.set_pixel(14, 7, BRANCO)
	img.set_pixel(14, 8, BRANCO)

	# Corda do arco
	for y in range(4, 13):
		img.set_pixel(11, y, BRANCO)

	return ImageTexture.create_from_image(img)


# === BOSS SPRITES (24x24) ===

static func criar_textura_boss_floresta() -> ImageTexture:
	## Boss Floresta - Guardião grande com galhos
	var img = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Corpo principal (forma de árvore humanóide)
	for x in range(6, 18):
		for y in range(8, 22):
			img.set_pixel(x, y, PRETO)

	# Cabeça/copa
	for x in range(4, 20):
		for y in range(2, 10):
			var dist = sqrt(pow(x - 12, 2) + pow(y - 6, 2))
			if dist <= 7:
				if (x + y) % 2 == 0:
					img.set_pixel(x, y, PRETO)
				else:
					img.set_pixel(x, y, BRANCO)

	# Olhos (brilhantes)
	for x in range(9, 11):
		for y in range(5, 7):
			img.set_pixel(x, y, BRANCO)
	for x in range(13, 15):
		for y in range(5, 7):
			img.set_pixel(x, y, BRANCO)

	# Braços/galhos
	for i in range(6):
		img.set_pixel(5 - i, 10 + i, PRETO)
		img.set_pixel(4 - i, 10 + i, PRETO)
		img.set_pixel(18 + i, 10 + i, PRETO)
		img.set_pixel(19 + i, 10 + i, PRETO)

	return ImageTexture.create_from_image(img)


static func criar_textura_boss_dungeon() -> ImageTexture:
	## Boss Dungeon - Senhor das Catacumbas (necromante)
	var img = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Robe grande
	for x in range(4, 20):
		for y in range(6, 23):
			img.set_pixel(x, y, PRETO)

	# Capuz
	for x in range(6, 18):
		for y in range(2, 8):
			img.set_pixel(x, y, PRETO)

	# Ponta do capuz
	for x in range(10, 14):
		img.set_pixel(x, 1, PRETO)
	img.set_pixel(11, 0, PRETO)
	img.set_pixel(12, 0, PRETO)

	# Olhos brilhantes (maiores)
	for x in range(8, 11):
		img.set_pixel(x, 5, BRANCO)
	for x in range(13, 16):
		img.set_pixel(x, 5, BRANCO)

	# Cajado com crânio
	for y in range(3, 22):
		img.set_pixel(20, y, BRANCO)
		img.set_pixel(21, y, BRANCO)

	# Crânio no cajado
	for x in range(19, 23):
		for y in range(1, 5):
			img.set_pixel(x, y, BRANCO)
	img.set_pixel(19, 2, PRETO)
	img.set_pixel(22, 2, PRETO)

	return ImageTexture.create_from_image(img)


static func criar_textura_boss_castelo() -> ImageTexture:
	## Boss Castelo - General das Sombras
	var img = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Armadura massiva
	for x in range(4, 20):
		for y in range(5, 22):
			img.set_pixel(x, y, PRETO)

	# Elmo com chifres grandes
	for x in range(6, 18):
		for y in range(2, 7):
			img.set_pixel(x, y, PRETO)

	# Chifres
	for i in range(4):
		img.set_pixel(5 - i, 2 - i, PRETO)
		img.set_pixel(4 - i, 2 - i, PRETO)
		img.set_pixel(18 + i, 2 - i, PRETO)
		img.set_pixel(19 + i, 2 - i, PRETO)

	# Viseira (V shape)
	for x in range(8, 16):
		img.set_pixel(x, 4, BRANCO)

	# Capa
	for y in range(8, 23):
		img.set_pixel(3, y, PRETO)
		img.set_pixel(2, y, PRETO)
		img.set_pixel(20, y, PRETO)
		img.set_pixel(21, y, PRETO)

	# Espada grande
	for y in range(0, 20):
		img.set_pixel(22, y, BRANCO)
		img.set_pixel(23, y, BRANCO)

	# Guarda da espada
	for x in range(20, 24):
		img.set_pixel(x, 8, BRANCO)

	return ImageTexture.create_from_image(img)


static func criar_textura_boss_final() -> ImageTexture:
	## Boss Final - Rei das Trevas
	var img = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Corpo massivo
	for x in range(3, 21):
		for y in range(6, 23):
			img.set_pixel(x, y, PRETO)

	# Cabeça
	for x in range(6, 18):
		for y in range(3, 8):
			img.set_pixel(x, y, PRETO)

	# Coroa (pontas brancas)
	for x in range(6, 18):
		img.set_pixel(x, 2, BRANCO)
	img.set_pixel(7, 1, BRANCO)
	img.set_pixel(9, 0, BRANCO)
	img.set_pixel(12, 1, BRANCO)
	img.set_pixel(14, 0, BRANCO)
	img.set_pixel(16, 1, BRANCO)

	# Olhos malignos (V shaped)
	img.set_pixel(8, 5, BRANCO)
	img.set_pixel(9, 4, BRANCO)
	img.set_pixel(10, 5, BRANCO)
	img.set_pixel(13, 5, BRANCO)
	img.set_pixel(14, 4, BRANCO)
	img.set_pixel(15, 5, BRANCO)

	# Cetro
	for y in range(4, 22):
		img.set_pixel(21, y, BRANCO)
		img.set_pixel(22, y, BRANCO)

	# Orbe do cetro
	for x in range(20, 24):
		for y in range(1, 5):
			img.set_pixel(x, y, BRANCO)
	img.set_pixel(21, 2, PRETO)
	img.set_pixel(22, 2, PRETO)
	img.set_pixel(21, 3, PRETO)
	img.set_pixel(22, 3, PRETO)

	# Capa
	for y in range(8, 24):
		img.set_pixel(2, y, PRETO)
		img.set_pixel(1, y, PRETO)

	return ImageTexture.create_from_image(img)
