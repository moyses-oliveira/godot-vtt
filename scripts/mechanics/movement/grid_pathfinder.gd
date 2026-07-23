class_name GridPathfinder
extends RefCounted

## Logica pura de grid: limites, obstaculos, armadilhas e busca de
## alcance/caminho. Nao depende de nenhum node, script visual ou contexto
## de jogo especifico - qualquer sistema (jogador, inimigo, IA) pode criar
## sua propria instancia para calcular alcance e caminhos.
##
## O alcance tambem considera as 4 diagonais, com custo em distancia
## octile (GridDistance) em vez de contar so passos ortogonais - isso faz
## a area alcancavel se aproximar de um circulo em vez do losango que
## resultaria de uma busca puramente ortogonal. Por isso a busca usa
## Dijkstra (custos diferentes por direcao) em vez de um BFS simples. O
## custo acumulado e arredondado (GridDistance.round_cost) antes de
## comparar com "move_range" - assim um unico passo diagonal (~1,41) cabe
## num alcance 1, como o jogador espera visualmente, em vez de exigir 2.
## O caminho fisico devolvido por MovementRange.build_path_to, porem,
## decompoe toda diagonal em dois passos ortogonais - a animacao do
## personagem sempre anda reto pelos eixos, mesmo que o alcance tenha sido
## calculado permitindo diagonais.

const DIRECTIONS: Array[Vector2i] = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
const DIAGONAL_DIRECTIONS: Array[Vector2i] = [Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(1, 1)]

var width: int
var height: int
var obstacles: Array[Vector2i]
var traps: Array[Vector2i]

func _init(p_width: int, p_height: int, p_obstacles: Array[Vector2i] = [], p_traps: Array[Vector2i] = []) -> void:
	width = p_width
	height = p_height
	obstacles = p_obstacles
	traps = p_traps

func is_within_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < width and cell.y >= 0 and cell.y < height

func is_obstacle(cell: Vector2i) -> bool:
	return cell in obstacles

func is_trap(cell: Vector2i) -> bool:
	return cell in traps

## Retorna um MovementRange com todas as celulas alcancaveis a partir de
## "origin" dentro de "move_range" (medido em distancia octile, nao em
## numero de passos), contornando obstaculos fixos do cenario e
## "occupied_cells" - celulas ocupadas por outros personagens no momento
## da chamada, tratadas como bloqueio solido. E passado por fora (em vez
## de guardado em "obstacles") porque quem esta em pe muda a cada turno,
## diferente do cenario.
func compute_reachable(origin: Vector2i, move_range: int, occupied_cells: Array[Vector2i] = []) -> MovementRange:
	var distance: Dictionary = {origin: 0.0}
	var came_from: Dictionary = {}
	var frontier: Array[Vector2i] = [origin]

	while not frontier.is_empty():
		var current: Vector2i = _closest_in_frontier(frontier, distance)
		frontier.erase(current)
		var current_dist: float = distance[current]

		for dir in DIRECTIONS:
			_relax(current, current_dist, current + dir, GridDistance.ORTHOGONAL_COST, move_range, occupied_cells, distance, came_from, frontier)

		for dir in DIAGONAL_DIRECTIONS:
			if _diagonal_blocked(current, dir, occupied_cells):
				continue
			_relax(current, current_dist, current + dir, GridDistance.DIAGONAL_COST, move_range, occupied_cells, distance, came_from, frontier)

	var cells: Array[Vector2i] = []
	for cell in distance:
		if cell != origin:
			cells.append(cell)

	return MovementRange.new(origin, cells, came_from)

func _relax(current: Vector2i, current_dist: float, neighbor: Vector2i, cost: float, move_range: int, occupied_cells: Array[Vector2i], distance: Dictionary, came_from: Dictionary, frontier: Array[Vector2i]) -> void:
	if not is_within_bounds(neighbor) or is_obstacle(neighbor) or neighbor in occupied_cells:
		return

	var new_dist := current_dist + cost
	if GridDistance.round_cost(new_dist) > move_range:
		return
	if distance.has(neighbor) and distance[neighbor] <= new_dist:
		return

	distance[neighbor] = new_dist
	came_from[neighbor] = current
	if neighbor not in frontier:
		frontier.append(neighbor)

## Impede diagonais que cortariam a quina de dois obstaculos/personagens
## ortogonais ao mesmo tempo - sem essa checagem o personagem "atravessaria"
## a quina de uma parede ou de outro personagem para chegar na diagonal.
func _diagonal_blocked(current: Vector2i, dir: Vector2i, occupied_cells: Array[Vector2i]) -> bool:
	return _is_blocked(current + Vector2i(dir.x, 0), occupied_cells) or _is_blocked(current + Vector2i(0, dir.y), occupied_cells)

func _is_blocked(cell: Vector2i, occupied_cells: Array[Vector2i]) -> bool:
	return not is_within_bounds(cell) or is_obstacle(cell) or cell in occupied_cells

func _closest_in_frontier(frontier: Array[Vector2i], distance: Dictionary) -> Vector2i:
	var best: Vector2i = frontier[0]
	var best_dist: float = distance[best]
	for cell in frontier:
		if distance[cell] < best_dist:
			best = cell
			best_dist = distance[cell]
	return best
