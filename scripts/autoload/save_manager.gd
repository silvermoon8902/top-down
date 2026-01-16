extends Node
## SaveManager - Gerenciador de salvamento do jogo
## Responsável por salvar e carregar o progresso do jogador

# Caminho do arquivo de save
const SAVE_PATH: String = "user://save_game.json"

# Estrutura de dados do save
var dados_save: Dictionary = {
	"fase_atual": 1,
	"fase_mais_alta": 1,
	"itens_cura": 0,
	"itens_antidoto": 0,
	"tempo_total_jogo": 0.0,
	"data_ultimo_save": ""
}


func _ready() -> void:
	## Inicializa o SaveManager
	pass


func salvar_jogo() -> bool:
	## Salva o estado atual do jogo
	## Retorna true se salvou com sucesso

	# Atualiza os dados do save com o estado atual do GameManager
	dados_save["fase_atual"] = GameManager.fase_atual
	dados_save["fase_mais_alta"] = GameManager.fase_mais_alta_desbloqueada
	dados_save["itens_cura"] = GameManager.itens_cura
	dados_save["itens_antidoto"] = GameManager.itens_antidoto
	dados_save["data_ultimo_save"] = Time.get_datetime_string_from_system()

	# Converte para JSON e salva
	var json_string = JSON.stringify(dados_save, "\t")
	var arquivo = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if arquivo:
		arquivo.store_string(json_string)
		arquivo.close()
		print("[SaveManager] Jogo salvo com sucesso!")
		return true
	else:
		push_error("[SaveManager] Erro ao salvar o jogo!")
		return false


func carregar_jogo() -> Dictionary:
	## Carrega o jogo salvo
	## Retorna os dados carregados ou um dicionário vazio se não houver save

	if not FileAccess.file_exists(SAVE_PATH):
		print("[SaveManager] Nenhum save encontrado.")
		return {}

	var arquivo = FileAccess.open(SAVE_PATH, FileAccess.READ)

	if arquivo:
		var json_string = arquivo.get_as_text()
		arquivo.close()

		var json = JSON.new()
		var erro = json.parse(json_string)

		if erro == OK:
			dados_save = json.get_data()
			print("[SaveManager] Jogo carregado com sucesso!")
			return dados_save
		else:
			push_error("[SaveManager] Erro ao parsear o save: " + json.get_error_message())
			return {}
	else:
		push_error("[SaveManager] Erro ao abrir arquivo de save!")
		return {}


func existe_save() -> bool:
	## Verifica se existe um arquivo de save
	return FileAccess.file_exists(SAVE_PATH)


func deletar_save() -> bool:
	## Deleta o arquivo de save
	## Retorna true se deletou com sucesso

	if FileAccess.file_exists(SAVE_PATH):
		var erro = DirAccess.remove_absolute(SAVE_PATH)
		if erro == OK:
			print("[SaveManager] Save deletado com sucesso!")
			_resetar_dados()
			return true
		else:
			push_error("[SaveManager] Erro ao deletar save!")
			return false
	return true


func _resetar_dados() -> void:
	## Reseta os dados do save para os valores padrão
	dados_save = {
		"fase_atual": 1,
		"fase_mais_alta": 1,
		"itens_cura": 0,
		"itens_antidoto": 0,
		"tempo_total_jogo": 0.0,
		"data_ultimo_save": ""
	}


func obter_fase_mais_alta() -> int:
	## Retorna a fase mais alta desbloqueada
	if existe_save():
		var dados = carregar_jogo()
		return dados.get("fase_mais_alta", 1)
	return 1
