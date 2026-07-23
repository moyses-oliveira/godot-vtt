class_name PlayerData
extends RefCounted

## Modelo de dominio puro (sem Node) representando uma entrada de
## resources/fakers/players.json ou resources/fakers/enemies.json ja
## convertida dos campos crus do JSON para tipos GDScript. Nao sabe nada
## sobre Character, HTTP ou grid.
##
## Um inimigo e, estruturalmente, o mesmo modelo que um jogador (um
## personagem controlado remotamente, so que por gatilhos do backend em vez
## de um jogador humano) - por isso reaproveita PlayerData em vez de um
## EnemyData separado. TEAM e quem diferencia os dois na hora de decidir
## quem pode ser alvo de ataque de quem.

enum Team { ALLY, ENEMY }

var team: Team = Team.ALLY
var user_token: String
var name: String
var hp: int
var baseHp: int
var maxHp: int
var mp: int
var baseMp: int
var maxMp: int
var movement_points: int
var avatar_url: String
var attacks: Array[AttackData] = []

static func from_dict(data: Dictionary, team: Team = Team.ALLY) -> PlayerData:
	var player := PlayerData.new()
	player.team = team
	player.user_token = data.get("userToken", "")

	var character_info: Dictionary = data.get("character", {})
	player.name = character_info.get("name", "")
	player.hp = character_info.get("hp", 0)
	player.baseHp = character_info.get("baseHp", 0)
	player.maxHp = character_info.get("maxHp", 0)
	player.mp = character_info.get("mp", 0)
	player.baseMp = character_info.get("baseMp", 0)
	player.maxMp = character_info.get("maxMp", 0)
	player.movement_points = character_info.get("movementPoints", 0)
	player.avatar_url = character_info.get("avatar", "")

	var attacks_data: Array = character_info.get("attacks", [])
	for attack_entry in attacks_data:
		if typeof(attack_entry) == TYPE_DICTIONARY:
			player.attacks.append(AttackData.from_dict(attack_entry))

	return player
