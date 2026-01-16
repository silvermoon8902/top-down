extends Control
## Tela de Vitória
## Mostrada quando o jogador completa todas as 16 fases

@onready var botao_menu: Button = $VBoxContainer/BotaoMenu


func _ready() -> void:
	## Inicializa a tela de vitória
	AudioManager.tocar_musica(AudioManager.Musica.VITORIA)

	if botao_menu:
		botao_menu.pressed.connect(_on_menu)


func _on_menu() -> void:
	## Volta ao menu principal
	AudioManager.tocar_sfx(AudioManager.SFX.MENU_CONFIRMAR)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
