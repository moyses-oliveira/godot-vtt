class_name MovementRange
extends RefCounted

## Resultado de um GridPathfinder.compute_reachable: quais celulas sao
## alcancaveis (a distancia octile do GridPathfinder, incluindo diagonais)
## e como reconstruir o caminho fisico ate qualquer uma delas.

var origin: Vector2i
var cells: Array[Vector2i]
var _came_from: Dictionary

func _init(p_origin: Vector2i, p_cells: Array[Vector2i], p_came_from: Dictionary) -> void:
	origin = p_origin
	cells = p_cells
	_came_from = p_came_from

func contains(cell: Vector2i) -> bool:
	return cell in cells

## O grafo de alcance permite diagonais, mas cada uma delas e decomposta
## aqui em dois passos ortogonais (x, depois y) - a animacao do personagem
## (GridMover) so sabe andar reto pelos eixos, entao o caminho devolvido
## nunca pode ter dois vizinhos diagonais em sequencia.
func build_path_to(destination: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var current = destination
	while _came_from.has(current):
		var previous: Vector2i = _came_from[current]
		if current.x != previous.x and current.y != previous.y:
			path.push_front(current)
			path.push_front(Vector2i(current.x, previous.y))
		else:
			path.push_front(current)
		current = previous
	return path
