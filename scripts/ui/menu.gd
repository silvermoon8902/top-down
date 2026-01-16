extends Control
## Menu Principal do Jogo
## Gerencia opções de novo jogo, continuar e configurações

@onready var botao_novo_jogo: Button = $VBoxContainer/BotaoNovoJogo
@onready var botao_continuar: Button = $VBoxContainer/BotaoContinuar
@onready var botao_sair: Button = $VBoxContainer/BotaoSair
@onready var label_titulo: Label = $VBoxContainer/LabelTitulo


func _ready() -> void:
	## Inicializa o menu
	_configurar_botoes()
	_verificar_save()

	# Toca música do menu
	AudioManager.tocar_musica(AudioManager.Musica.MENU)


func _configurar_botoes() -> void:
	## Conecta os sinais dos botões
	if botao_novo_jogo:
		botao_novo_jogo.pressed.connect(_on_novo_jogo_pressed)

	if botao_continuar:
		botao_continuar.pressed.connect(_on_continuar_pressed)

	if botao_sair:
		botao_sair.pressed.connect(_on_sair_pressed)


func _verificar_save() -> void:
	## Verifica se existe save e habilita/desabilita botão continuar
	if botao_continuar:
		botao_continuar.disabled = not SaveManager.existe_save()


func _on_novo_jogo_pressed() -> void:
	## Inicia um novo jogo
	AudioManager.tocar_sfx(AudioManager.SFX.MENU_CONFIRMAR)

	# Deleta save anterior se existir
	SaveManager.deletar_save()

	# Inicia nova partida
	GameManager.iniciar_nova_partida()

	# Carrega a cena do jogo
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_continuar_pressed() -> void:
	## Continua jogo salvo
	if not SaveManager.existe_save():
		return

	AudioManager.tocar_sfx(AudioManager.SFX.MENU_CONFIRMAR)

	# Carrega partida salva
	GameManager.carregar_partida_salva()

	# Carrega a cena do jogo
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_sair_pressed() -> void:
	## Sai do jogo
	AudioManager.tocar_sfx(AudioManager.SFX.MENU_CONFIRMAR)
	get_tree().quit()


func _input(event: InputEvent) -> void:
	## Processa input de navegação do menu
	# Navegação com teclado pode ser adicionada aqui
	pass
