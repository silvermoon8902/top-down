extends Control
## Tela de Game Over
## Permite tentar novamente ou voltar ao menu

@onready var botao_tentar: Button = $VBoxContainer/BotaoTentarNovamente
@onready var botao_menu: Button = $VBoxContainer/BotaoMenu


func _ready() -> void:
	## Inicializa a tela de game over
	AudioManager.tocar_musica(AudioManager.Musica.GAME_OVER)

	if botao_tentar:
		botao_tentar.pressed.connect(_on_tentar_novamente)
	if botao_menu:
		botao_menu.pressed.connect(_on_menu)


func _on_tentar_novamente() -> void:
	## Reinicia a fase atual
	AudioManager.tocar_sfx(AudioManager.SFX.MENU_CONFIRMAR)

	# Reinicia a fase atual (não reseta o progresso)
	GameManager.iniciar_fase(GameManager.fase_atual)
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_menu() -> void:
	## Volta ao menu principal
	AudioManager.tocar_sfx(AudioManager.SFX.MENU_CONFIRMAR)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
