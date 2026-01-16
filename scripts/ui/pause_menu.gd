extends CanvasLayer
class_name PauseMenu
## PauseMenu - Menu de pausa do jogo
## Permite continuar, reiniciar ou voltar ao menu

@onready var painel: Panel = $Panel
@onready var botao_continuar: Button = $Panel/VBoxContainer/BotaoContinuar
@onready var botao_reiniciar: Button = $Panel/VBoxContainer/BotaoReiniciar
@onready var botao_menu: Button = $Panel/VBoxContainer/BotaoMenu

var esta_pausado: bool = false


func _ready() -> void:
	## Inicializa o menu de pausa
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	# Conecta botões
	if botao_continuar:
		botao_continuar.pressed.connect(_on_continuar)
	if botao_reiniciar:
		botao_reiniciar.pressed.connect(_on_reiniciar)
	if botao_menu:
		botao_menu.pressed.connect(_on_menu)


func _input(event: InputEvent) -> void:
	## Processa input de pausa
	if event.is_action_pressed("pausar"):
		if esta_pausado:
			despausar()
		else:
			pausar()


func pausar() -> void:
	## Pausa o jogo e mostra o menu
	if GameManager.estado_atual != GameManager.EstadoJogo.JOGANDO:
		return

	esta_pausado = true
	visible = true
	get_tree().paused = true
	GameManager.pausar_jogo(true)

	# Foca no botão continuar
	if botao_continuar:
		botao_continuar.grab_focus()


func despausar() -> void:
	## Despausa o jogo e esconde o menu
	esta_pausado = false
	visible = false
	get_tree().paused = false
	GameManager.pausar_jogo(false)


func _on_continuar() -> void:
	## Continua o jogo
	AudioManager.tocar_sfx(AudioManager.SFX.MENU_CONFIRMAR)
	despausar()


func _on_reiniciar() -> void:
	## Reinicia a fase atual
	AudioManager.tocar_sfx(AudioManager.SFX.MENU_CONFIRMAR)
	despausar()

	# Reinicia a fase
	GameManager.iniciar_fase(GameManager.fase_atual)
	get_tree().reload_current_scene()


func _on_menu() -> void:
	## Volta ao menu principal
	AudioManager.tocar_sfx(AudioManager.SFX.MENU_CONFIRMAR)
	despausar()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
