class_name AttackTargeting
extends RefCounted

## Logica pura de alcance de ataque: nao depende de Node, Character ou
## estado de UI - so calcula quais celulas do grid estao dentro do
## target_range de um ataque, a partir da celula de origem de quem ataca.
## Reutilizavel tanto pela UI do jogador (para desenhar a sombra do
## alcance) quanto por uma futura IA de inimigos.
##
## Distancia e a mesma metrica octile (GridDistance) usada pelo alcance de
## movimento, ignorando obstaculos - ataques nao andam pela grade, entao
## nao ha corredores nem quinas a contornar, so a forma circular do
## alcance. Usar Manhattan aqui deixaria a sombra em losango, e Chebyshev
## deixaria em quadrado.

static func cells_in_range(origin: Vector2i, attack_range: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for dx in range(-attack_range, attack_range + 1):
		for dy in range(-attack_range, attack_range + 1):
			var offset := Vector2i(dx, dy)
			if offset == Vector2i.ZERO:
				continue
			if GridDistance.round_cost(GridDistance.octile(Vector2i.ZERO, offset)) <= attack_range:
				cells.append(origin + offset)
	return cells
