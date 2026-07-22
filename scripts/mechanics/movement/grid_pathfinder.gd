class_name GridPathfinder
extends RefCounted

## Logica pura de grid: limites, obstaculos, armadilhas e busca de caminho
## ortogonal (BFS). Nao depende de nenhum node, script visual ou contexto
## de jogo especifico - qualquer sistema (jogador, inimigo, IA) pode criar
## sua propria instancia para calcular alcance e caminhos.

const DIRECTIONS: Array[Vector2i] = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]

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
## "origin" dentro de "move_range" passos ortogonais, contornando obstaculos.
func compute_reachable(origin: Vector2i, move_range: int) -> MovementRange:
	var distance = {origin: 0}
	var came_from: Dictionary = {}
	var queue: Array[Vector2i] = [origin]
	var head := 0

	while head < queue.size():
		var current = queue[head]
		head += 1
		var current_dist = distance[current]
		if current_dist >= move_range:
			continue

		for dir in DIRECTIONS:
			var neighbor = current + dir
			if not is_within_bounds(neighbor) or is_obstacle(neighbor) or distance.has(neighbor):
				continue

			distance[neighbor] = current_dist + 1
			came_from[neighbor] = current
			queue.append(neighbor)

	var cells: Array[Vector2i] = []
	for cell in distance:
		if cell != origin:
			cells.append(cell)

	return MovementRange.new(origin, cells, came_from)
