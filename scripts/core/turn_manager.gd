extends Node
class_name TurnManager
## TurnManager - Gerenciador de turnos do jogo
## Controla a sequência de turnos entre jogador e inimigos

# Sinais
signal turno_iniciado(tipo_turno: TipoTurno)
signal turno_finalizado(tipo_turno: TipoTurno)
signal turno_jogador_iniciado()
signal turno_inimigos_iniciado()
signal fase_status_aplicada()
signal aguardando_input_jogador()
signal acao_jogador_executada()

# Tipos de turno
enum TipoTurno {
	JOGADOR,
	INIMIGOS,
	STATUS  # Fase de aplicação de efeitos (veneno, etc)
}

# Estado atual do turno
var turno_atual: TipoTurno = TipoTurno.JOGADOR
var numero_turno: int = 0
var aguardando_input: bool = false
var processando_turno: bool = false

# Referências
var grid_system: GridSystem = null
var cavaleiro: Node2D = null
var inimigos: Array = []

# Configuração
var tempo_entre_acoes_inimigos: float = 0.2  # Segundos entre ações de inimigos


func _ready() -> void:
	## Inicializa o gerenciador de turnos
	pass


func configurar(grid: GridSystem, jogador: Node2D) -> void:
	## Configura o gerenciador com as referências necessárias
	grid_system = grid
	cavaleiro = jogador
	numero_turno = 0
	turno_atual = TipoTurno.JOGADOR


func iniciar_jogo() -> void:
	## Inicia o primeiro turno do jogo
	numero_turno = 1
	_iniciar_turno_jogador()


func registrar_inimigo(inimigo: Node2D) -> void:
	## Registra um inimigo para participar dos turnos
	if not inimigo in inimigos:
		inimigos.append(inimigo)


func remover_inimigo(inimigo: Node2D) -> void:
	## Remove um inimigo do sistema de turnos
	inimigos.erase(inimigo)


func limpar_inimigos() -> void:
	## Remove todos os inimigos
	inimigos.clear()


func _iniciar_turno_jogador() -> void:
	## Inicia o turno do jogador
	turno_atual = TipoTurno.JOGADOR
	aguardando_input = true
	processando_turno = false

	turno_iniciado.emit(TipoTurno.JOGADOR)
	turno_jogador_iniciado.emit()
	aguardando_input_jogador.emit()

	print("[TurnManager] Turno %d - Vez do jogador" % numero_turno)


func jogador_executou_acao() -> void:
	## Chamado quando o jogador executa uma ação (mover, atacar, passar turno)
	if not aguardando_input:
		return

	aguardando_input = false
	acao_jogador_executada.emit()
	turno_finalizado.emit(TipoTurno.JOGADOR)

	# Verifica se o jogo ainda está ativo
	if GameManager.estado_atual != GameManager.EstadoJogo.JOGANDO:
		return

	# Próxima fase: turno dos inimigos
	_iniciar_turno_inimigos()


func passar_turno_jogador(nova_direcao_escudo: int = -1) -> void:
	## Jogador passa o turno (pode mudar direção do escudo)
	if nova_direcao_escudo >= 0:
		GameManager.mudar_direcao_escudo(nova_direcao_escudo)

	jogador_executou_acao()


func _iniciar_turno_inimigos() -> void:
	## Inicia o turno dos inimigos
	turno_atual = TipoTurno.INIMIGOS
	processando_turno = true

	turno_iniciado.emit(TipoTurno.INIMIGOS)
	turno_inimigos_iniciado.emit()

	print("[TurnManager] Turno %d - Vez dos inimigos (%d inimigos)" % [numero_turno, inimigos.size()])

	# Processa os inimigos
	await _processar_inimigos()

	turno_finalizado.emit(TipoTurno.INIMIGOS)

	# Próxima fase: aplicar status
	_iniciar_fase_status()


func _processar_inimigos() -> void:
	## Processa as ações de todos os inimigos
	# Primeiro, todos os inimigos calculam suas ações
	var acoes_inimigos: Array = []

	for inimigo in inimigos:
		if is_instance_valid(inimigo) and inimigo.has_method("calcular_acao"):
			var acao = inimigo.calcular_acao()
			acoes_inimigos.append({"inimigo": inimigo, "acao": acao})

	# Depois, executa todas as ações (simulando simultaneidade)
	for dados_acao in acoes_inimigos:
		var inimigo = dados_acao["inimigo"]

		if not is_instance_valid(inimigo):
			continue

		if inimigo.has_method("executar_acao"):
			inimigo.executar_acao(dados_acao["acao"])

		# Pequeno delay para feedback visual
		if tempo_entre_acoes_inimigos > 0:
			await get_tree().create_timer(tempo_entre_acoes_inimigos).timeout


func _iniciar_fase_status() -> void:
	## Aplica efeitos de status (veneno, etc)
	turno_atual = TipoTurno.STATUS

	print("[TurnManager] Aplicando efeitos de status")

	# Processa veneno do cavaleiro
	GameManager.processar_veneno()

	# Processa status dos inimigos (se houver)
	for inimigo in inimigos:
		if is_instance_valid(inimigo) and inimigo.has_method("processar_status"):
			inimigo.processar_status()

	fase_status_aplicada.emit()

	# Verifica condições de vitória/derrota
	if GameManager.estado_atual != GameManager.EstadoJogo.JOGANDO:
		return

	# Verifica se todos os inimigos foram derrotados (condição de vitória da fase)
	if _verificar_vitoria():
		GameManager.completar_fase()
		return

	# Próximo turno
	numero_turno += 1
	_iniciar_turno_jogador()


func _verificar_vitoria() -> bool:
	## Verifica se o jogador venceu a fase
	## Por padrão, vence quando todos os inimigos são derrotados
	# Remove inimigos inválidos da lista
	inimigos = inimigos.filter(func(i): return is_instance_valid(i))

	return inimigos.is_empty()


func pode_jogador_agir() -> bool:
	## Retorna true se o jogador pode executar uma ação
	return (turno_atual == TipoTurno.JOGADOR and
			aguardando_input and
			not processando_turno and
			GameManager.estado_atual == GameManager.EstadoJogo.JOGANDO)


func obter_numero_turno() -> int:
	## Retorna o número do turno atual
	return numero_turno


func obter_tipo_turno_atual() -> TipoTurno:
	## Retorna o tipo do turno atual
	return turno_atual


func resetar() -> void:
	## Reseta o estado do gerenciador de turnos
	numero_turno = 0
	turno_atual = TipoTurno.JOGADOR
	aguardando_input = false
	processando_turno = false
	inimigos.clear()
