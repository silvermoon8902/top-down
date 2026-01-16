extends Node
class_name EnemyFactory
## EnemyFactory - Fábrica de inimigos
## Cria inimigos com configurações específicas baseado no tipo
## Agora usando sprites 1-bit com silhuetas únicas para cada tipo

# Cena base de inimigo
var cena_inimigo: PackedScene = preload("res://scenes/entities/enemy.tscn")

# Dados dos tipos de inimigos
var tipos_inimigos: Dictionary = {
	# === INIMIGOS COMUNS ===
	"goblin": {
		"nome": "Goblin",
		"vida": 2,
		"dano": 1,
		"tipo_ataque": InimigoBase.TipoAtaque.CORPO_A_CORPO,
		"alcance_visao": 6,
		"sprite_func": "criar_textura_goblin"
	},
	"esqueleto": {
		"nome": "Esqueleto",
		"vida": 2,
		"dano": 1,
		"tipo_ataque": InimigoBase.TipoAtaque.CORPO_A_CORPO,
		"alcance_visao": 5,
		"sprite_func": "criar_textura_esqueleto"
	},
	"arqueiro_goblin": {
		"nome": "Arqueiro Goblin",
		"vida": 1,
		"dano": 1,
		"tipo_ataque": InimigoBase.TipoAtaque.DISTANCIA,
		"alcance_visao": 8,
		"sprite_func": "criar_textura_arqueiro"
	},
	"slime": {
		"nome": "Slime",
		"vida": 3,
		"dano": 1,
		"tipo_ataque": InimigoBase.TipoAtaque.CORPO_A_CORPO,
		"alcance_visao": 4,
		"sprite_func": "criar_textura_slime"
	},
	"cobra_venenosa": {
		"nome": "Cobra Venenosa",
		"vida": 1,
		"dano": 0,
		"tipo_ataque": InimigoBase.TipoAtaque.VENENO,
		"alcance_visao": 5,
		"sprite_func": "criar_textura_cobra"
	},
	"cavaleiro_negro": {
		"nome": "Cavaleiro Negro",
		"vida": 3,
		"dano": 2,
		"tipo_ataque": InimigoBase.TipoAtaque.AVANCAR_ATACAR,
		"distancia_avanco": 3,
		"alcance_visao": 6,
		"sprite_func": "criar_textura_cavaleiro_negro"
	},
	"mago_sombrio": {
		"nome": "Mago Sombrio",
		"vida": 2,
		"dano": 1,
		"tipo_ataque": InimigoBase.TipoAtaque.DISTANCIA,
		"alcance_visao": 7,
		"sprite_func": "criar_textura_mago"
	},
	"lobo": {
		"nome": "Lobo",
		"vida": 2,
		"dano": 1,
		"tipo_ataque": InimigoBase.TipoAtaque.AVANCAR_ATACAR,
		"distancia_avanco": 2,
		"alcance_visao": 7,
		"sprite_func": "criar_textura_lobo"
	},
	"morcego": {
		"nome": "Morcego",
		"vida": 1,
		"dano": 1,
		"tipo_ataque": InimigoBase.TipoAtaque.CORPO_A_CORPO,
		"alcance_visao": 6,
		"sprite_func": "criar_textura_morcego"
	},
	"zumbi": {
		"nome": "Zumbi",
		"vida": 4,
		"dano": 1,
		"tipo_ataque": InimigoBase.TipoAtaque.CORPO_A_CORPO,
		"alcance_visao": 4,
		"sprite_func": "criar_textura_zumbi"
	},
	"aranha": {
		"nome": "Aranha",
		"vida": 2,
		"dano": 1,
		"tipo_ataque": InimigoBase.TipoAtaque.VENENO,
		"alcance_visao": 5,
		"sprite_func": "criar_textura_aranha"
	},
	"golem": {
		"nome": "Golem",
		"vida": 5,
		"dano": 2,
		"tipo_ataque": InimigoBase.TipoAtaque.CORPO_A_CORPO,
		"alcance_visao": 4,
		"sprite_func": "criar_textura_golem"
	}
}

# Dados dos bosses
var tipos_bosses: Dictionary = {
	"boss_floresta": {
		"nome": "Guardião da Floresta",
		"vida": 10,
		"dano": 2,
		"tipo_ataque": InimigoBase.TipoAtaque.CORPO_A_CORPO,
		"alcance_visao": 10,
		"sprite_func": "criar_textura_boss_floresta",
		"e_boss": true
	},
	"boss_dungeon": {
		"nome": "Senhor das Catacumbas",
		"vida": 12,
		"dano": 2,
		"tipo_ataque": InimigoBase.TipoAtaque.DISTANCIA,
		"alcance_visao": 10,
		"sprite_func": "criar_textura_boss_dungeon",
		"e_boss": true
	},
	"boss_castelo": {
		"nome": "General das Sombras",
		"vida": 15,
		"dano": 3,
		"tipo_ataque": InimigoBase.TipoAtaque.AVANCAR_ATACAR,
		"distancia_avanco": 4,
		"alcance_visao": 10,
		"sprite_func": "criar_textura_boss_castelo",
		"e_boss": true
	},
	"boss_final": {
		"nome": "Rei das Trevas",
		"vida": 20,
		"dano": 3,
		"tipo_ataque": InimigoBase.TipoAtaque.CORPO_A_CORPO,
		"alcance_visao": 12,
		"sprite_func": "criar_textura_boss_final",
		"e_boss": true
	}
}


func criar_inimigo(tipo: String, grid: GridSystem, turn: TurnManager, posicao: Vector2i) -> InimigoBase:
	## Cria um inimigo do tipo especificado
	var dados: Dictionary

	if tipos_inimigos.has(tipo):
		dados = tipos_inimigos[tipo]
	elif tipos_bosses.has(tipo):
		dados = tipos_bosses[tipo]
	else:
		push_warning("[EnemyFactory] Tipo de inimigo desconhecido: %s, usando goblin" % tipo)
		dados = tipos_inimigos["goblin"]

	var inimigo = cena_inimigo.instantiate()

	# Configura atributos
	inimigo.vida_maxima = dados.get("vida", 2)
	inimigo.dano_ataque = dados.get("dano", 1)
	inimigo.tipo_ataque = dados.get("tipo_ataque", InimigoBase.TipoAtaque.CORPO_A_CORPO)
	inimigo.alcance_visao = dados.get("alcance_visao", 6)

	if dados.has("distancia_avanco"):
		inimigo.distancia_avanco = dados["distancia_avanco"]

	# Configura na grade
	inimigo.configurar(grid, turn, posicao)

	# Aplica sprite 1-bit único baseado no tipo
	_aplicar_sprite_1bit(inimigo, dados)

	return inimigo


func _aplicar_sprite_1bit(inimigo: InimigoBase, dados: Dictionary) -> void:
	## Aplica sprite 1-bit único ao inimigo baseado no tipo
	if not inimigo.sprite:
		return

	var sprite_func: String = dados.get("sprite_func", "criar_textura_inimigo")

	# Chama a função correspondente em PlaceholderSprites usando match
	match sprite_func:
		"criar_textura_goblin":
			inimigo.sprite.texture = PlaceholderSprites.criar_textura_goblin()
		"criar_textura_esqueleto":
			inimigo.sprite.texture = PlaceholderSprites.criar_textura_esqueleto()
		"criar_textura_arqueiro":
			inimigo.sprite.texture = PlaceholderSprites.criar_textura_arqueiro()
		"criar_textura_slime":
			inimigo.sprite.texture = PlaceholderSprites.criar_textura_slime()
		"criar_textura_cobra":
			inimigo.sprite.texture = PlaceholderSprites.criar_textura_cobra()
		"criar_textura_cavaleiro_negro":
			inimigo.sprite.texture = PlaceholderSprites.criar_textura_cavaleiro_negro()
		"criar_textura_mago":
			inimigo.sprite.texture = PlaceholderSprites.criar_textura_mago()
		"criar_textura_lobo":
			inimigo.sprite.texture = PlaceholderSprites.criar_textura_lobo()
		"criar_textura_morcego":
			inimigo.sprite.texture = PlaceholderSprites.criar_textura_morcego()
		"criar_textura_zumbi":
			inimigo.sprite.texture = PlaceholderSprites.criar_textura_zumbi()
		"criar_textura_aranha":
			inimigo.sprite.texture = PlaceholderSprites.criar_textura_aranha()
		"criar_textura_golem":
			inimigo.sprite.texture = PlaceholderSprites.criar_textura_golem()
		"criar_textura_boss_floresta":
			inimigo.sprite.texture = PlaceholderSprites.criar_textura_boss_floresta()
		"criar_textura_boss_dungeon":
			inimigo.sprite.texture = PlaceholderSprites.criar_textura_boss_dungeon()
		"criar_textura_boss_castelo":
			inimigo.sprite.texture = PlaceholderSprites.criar_textura_boss_castelo()
		"criar_textura_boss_final":
			inimigo.sprite.texture = PlaceholderSprites.criar_textura_boss_final()
		_:
			inimigo.sprite.texture = PlaceholderSprites.criar_textura_inimigo()


func obter_inimigos_para_fase(numero_fase: int) -> Array[String]:
	## Retorna os tipos de inimigos disponíveis para uma fase
	match numero_fase:
		1, 2:
			return ["goblin", "slime"]
		3:
			return ["goblin", "slime", "lobo"]
		4:
			return ["goblin", "boss_floresta"]
		5, 6:
			return ["esqueleto", "morcego", "zumbi"]
		7:
			return ["esqueleto", "cobra_venenosa", "aranha"]
		8:
			return ["esqueleto", "mago_sombrio", "boss_dungeon"]
		9, 10:
			return ["cavaleiro_negro", "arqueiro_goblin"]
		11:
			return ["cavaleiro_negro", "mago_sombrio", "golem"]
		12:
			return ["cavaleiro_negro", "boss_castelo"]
		13, 14:
			return ["cavaleiro_negro", "mago_sombrio", "aranha"]
		15:
			return ["cavaleiro_negro", "mago_sombrio", "golem", "zumbi"]
		16:
			return ["cavaleiro_negro", "mago_sombrio", "boss_final"]
		_:
			return ["goblin"]
