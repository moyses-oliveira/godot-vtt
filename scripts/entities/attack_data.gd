class_name AttackData
extends RefCounted

## Modelo de dominio puro (sem Node) representando um ataque disponivel
## para um personagem (jogador ou inimigo), ja convertido dos campos crus
## do JSON ("attacks" dentro de "character") para tipos GDScript.

var name: String
var aim: int
var target_range: int
var damage_min: int
var damage_max: int
var targets: int

static func from_dict(data: Dictionary) -> AttackData:
	var attack := AttackData.new()
	attack.name = data.get("name", "")
	attack.aim = data.get("aim", 0)
	attack.target_range = data.get("targetRange", 0)

	var damage_range: Dictionary = data.get("damageRange", {})
	attack.damage_min = damage_range.get("min", 0)
	attack.damage_max = damage_range.get("max", 0)

	attack.targets = data.get("targets", 1)

	return attack
