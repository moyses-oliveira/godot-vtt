class_name AttackTargeting
extends RefCounted

## Logica pura de selecao de alvos: dado de onde o ataque parte, seu
## alcance e a lista de personagens candidatos, devolve so os que estao
## dentro do alcance. Nao depende de Node, selecao ou estado de UI - por
## isso e uma classe estatica sem instancia, reutilizavel tanto pela UI do
## jogador quanto por uma futura IA de inimigos.
##
## Distancia e calculada em passos ortogonais (Manhattan), ignorando
## obstaculos - o mesmo criterio usado por GridPathfinder para grade, mas
## sem exigir caminho livre ate o alvo (ataques nao andam pela grade).

static func targets_in_range(origin: Vector2i, attack_range: int, candidates: Array[Character]) -> Array[Character]:
	var valid: Array[Character] = []
	for candidate in candidates:
		if _distance(origin, candidate.grid_position) <= attack_range:
			valid.append(candidate)
	return valid

static func _distance(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)
