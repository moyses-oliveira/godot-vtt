class_name PlayerData
extends RefCounted

## Modelo de dominio puro (sem Node) representando uma entrada de
## resources/fakers/players.json ja convertida dos campos crus do JSON para
## tipos GDScript. Nao sabe nada sobre Character, HTTP ou grid.

var user_token: String
var name: String
var pvs: int
var movement_points: int
var avatar_url: String

static func from_dict(data: Dictionary) -> PlayerData:
	var player := PlayerData.new()
	player.user_token = data.get("userToken", "")

	var character_info: Dictionary = data.get("character", {})
	player.name = character_info.get("name", "")
	player.pvs = character_info.get("pvs", 0)
	player.movement_points = character_info.get("movementPoints", 0)
	player.avatar_url = character_info.get("avatar", "")

	return player
