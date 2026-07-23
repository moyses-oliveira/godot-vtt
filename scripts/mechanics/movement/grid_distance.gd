class_name GridDistance
extends RefCounted

## Distancia octile entre duas celulas: cada passo na diagonal custa
## aproximadamente raiz de 2 (em vez de contar como 2 passos ortogonais,
## como na distancia de Manhattan, ou como 1 passo, como na distancia de
## Chebyshev). E a metrica que faz uma area de alcance desenhada em grid
## se aproximar de um circulo, em vez de um losango ou um quadrado.

const ORTHOGONAL_COST := 1.0
const DIAGONAL_COST := 1.4142135

static func octile(a: Vector2i, b: Vector2i) -> float:
	var dx := absi(a.x - b.x)
	var dy := absi(a.y - b.y)
	var diagonal_steps := mini(dx, dy)
	var straight_steps := maxi(dx, dy) - diagonal_steps
	return diagonal_steps * DIAGONAL_COST + straight_steps * ORTHOGONAL_COST

## Arredonda um custo octile para o inteiro mais proximo antes de comparar
## com um alcance em numero inteiro de casas. Sem isso, um unico passo
## diagonal (custo ~1,41) nunca caberia num alcance 1 - visualmente o
## jogador espera que as 4 diagonais adjacentes contem como "1 casa", nao
## como "quase 2".
static func round_cost(cost: float) -> int:
	return roundi(cost)
