extends Node
## AudioManager - Gerenciador de áudio do jogo
## Controla música de fundo e efeitos sonoros

# Nós de áudio
var _player_musica: AudioStreamPlayer
var _player_sfx: AudioStreamPlayer

# Configurações de volume (0.0 a 1.0)
var volume_musica: float = 0.8
var volume_sfx: float = 1.0
var musica_ativa: bool = true
var sfx_ativo: bool = true

# Cache de sons carregados
var _cache_sfx: Dictionary = {}
var _cache_musica: Dictionary = {}

# Caminhos dos arquivos de áudio
const CAMINHO_SFX: String = "res://assets/audio/sfx/"
const CAMINHO_MUSICA: String = "res://assets/audio/music/"

# Enumeração dos efeitos sonoros
enum SFX {
	MOVER,
	ATACAR,
	ACERTO,
	DANO,
	MORTE,
	PEGAR_ITEM,
	ABRIR_BAU,
	VENENO,
	CURAR,
	ESCUDO_BLOQUEIO,
	MENU_SELECIONAR,
	MENU_CONFIRMAR,
	FASE_COMPLETA
}

# Enumeração das músicas
enum Musica {
	MENU,
	FLORESTA,
	DUNGEON,
	CASTELO,
	BOSS,
	VITORIA,
	GAME_OVER
}

# Mapeamento de enum para arquivo
var _mapa_sfx: Dictionary = {
	SFX.MOVER: "mover.wav",
	SFX.ATACAR: "atacar.wav",
	SFX.ACERTO: "acerto.wav",
	SFX.DANO: "dano.wav",
	SFX.MORTE: "morte.wav",
	SFX.PEGAR_ITEM: "pegar_item.wav",
	SFX.ABRIR_BAU: "abrir_bau.wav",
	SFX.VENENO: "veneno.wav",
	SFX.CURAR: "curar.wav",
	SFX.ESCUDO_BLOQUEIO: "escudo_bloqueio.wav",
	SFX.MENU_SELECIONAR: "menu_selecionar.wav",
	SFX.MENU_CONFIRMAR: "menu_confirmar.wav",
	SFX.FASE_COMPLETA: "fase_completa.wav"
}

var _mapa_musica: Dictionary = {
	Musica.MENU: "menu.ogg",
	Musica.FLORESTA: "floresta.ogg",
	Musica.DUNGEON: "dungeon.ogg",
	Musica.CASTELO: "castelo.ogg",
	Musica.BOSS: "boss.ogg",
	Musica.VITORIA: "vitoria.ogg",
	Musica.GAME_OVER: "game_over.ogg"
}


func _ready() -> void:
	## Inicializa o AudioManager
	process_mode = Node.PROCESS_MODE_ALWAYS
	_criar_players()


func _criar_players() -> void:
	## Cria os AudioStreamPlayers necessários
	_player_musica = AudioStreamPlayer.new()
	_player_musica.name = "PlayerMusica"
	_player_musica.bus = "Music"
	add_child(_player_musica)

	_player_sfx = AudioStreamPlayer.new()
	_player_sfx.name = "PlayerSFX"
	_player_sfx.bus = "SFX"
	add_child(_player_sfx)

	# Conecta sinal para loop da música
	_player_musica.finished.connect(_on_musica_terminou)


func tocar_sfx(tipo_sfx: SFX) -> void:
	## Toca um efeito sonoro
	if not sfx_ativo:
		return

	var nome_arquivo = _mapa_sfx.get(tipo_sfx, "")
	if nome_arquivo.is_empty():
		push_warning("[AudioManager] SFX não mapeado: " + str(tipo_sfx))
		return

	var stream = _carregar_sfx(nome_arquivo)
	if stream:
		_player_sfx.stream = stream
		_player_sfx.volume_db = linear_to_db(volume_sfx)
		_player_sfx.play()


func tocar_musica(tipo_musica: Musica, loop: bool = true) -> void:
	## Toca uma música de fundo
	if not musica_ativa:
		return

	var nome_arquivo = _mapa_musica.get(tipo_musica, "")
	if nome_arquivo.is_empty():
		push_warning("[AudioManager] Música não mapeada: " + str(tipo_musica))
		return

	var stream = _carregar_musica(nome_arquivo)
	if stream:
		_player_musica.stream = stream
		_player_musica.volume_db = linear_to_db(volume_musica)
		_player_musica.play()


func parar_musica() -> void:
	## Para a música atual
	_player_musica.stop()


func pausar_musica(pausar: bool) -> void:
	## Pausa ou retoma a música
	_player_musica.stream_paused = pausar


func definir_volume_musica(volume: float) -> void:
	## Define o volume da música (0.0 a 1.0)
	volume_musica = clamp(volume, 0.0, 1.0)
	_player_musica.volume_db = linear_to_db(volume_musica)


func definir_volume_sfx(volume: float) -> void:
	## Define o volume dos efeitos sonoros (0.0 a 1.0)
	volume_sfx = clamp(volume, 0.0, 1.0)


func alternar_musica(ativa: bool) -> void:
	## Liga ou desliga a música
	musica_ativa = ativa
	if not ativa:
		parar_musica()


func alternar_sfx(ativo: bool) -> void:
	## Liga ou desliga os efeitos sonoros
	sfx_ativo = ativo


func _carregar_sfx(nome_arquivo: String) -> AudioStream:
	## Carrega um arquivo de SFX (com cache)
	if _cache_sfx.has(nome_arquivo):
		return _cache_sfx[nome_arquivo]

	var caminho_completo = CAMINHO_SFX + nome_arquivo
	if ResourceLoader.exists(caminho_completo):
		var stream = load(caminho_completo)
		_cache_sfx[nome_arquivo] = stream
		return stream
	else:
		# Não mostra erro pois os arquivos ainda não existem
		return null


func _carregar_musica(nome_arquivo: String) -> AudioStream:
	## Carrega um arquivo de música (com cache)
	if _cache_musica.has(nome_arquivo):
		return _cache_musica[nome_arquivo]

	var caminho_completo = CAMINHO_MUSICA + nome_arquivo
	if ResourceLoader.exists(caminho_completo):
		var stream = load(caminho_completo)
		_cache_musica[nome_arquivo] = stream
		return stream
	else:
		# Não mostra erro pois os arquivos ainda não existem
		return null


func _on_musica_terminou() -> void:
	## Chamado quando a música termina - faz loop
	if musica_ativa and _player_musica.stream:
		_player_musica.play()


func obter_musica_para_fase(numero_fase: int) -> Musica:
	## Retorna a música apropriada para uma fase
	## Fases de boss: 4, 8, 12, 16
	if numero_fase in [4, 8, 12, 16]:
		return Musica.BOSS
	elif numero_fase <= 4:
		return Musica.FLORESTA
	elif numero_fase <= 8:
		return Musica.DUNGEON
	elif numero_fase <= 12:
		return Musica.DUNGEON
	else:
		return Musica.CASTELO
