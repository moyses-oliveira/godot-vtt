class_name MovementRange
extends RefCounted

## Resultado de um GridPathfinder.compute_reachable: quais celulas sao
## alcancaveis e como reconstruir o caminho ortogonal ate qualquer uma delas.

var origin: Vector2i
var cells: Array[Vector2i]
var _came_from: Dictionary

func _init(p_origin: Vector2i, p_cells: Array[Vector2i], p_came_from: Dictionary) -> void:
	origin = p_origin
	cells = p_cells
	_came_from = p_came_from

func contains(cell: Vector2i) -> bool:
	return cell in cells

func build_path_to(destination: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var current = destination
	while _came_from.has(current):
		path.push_front(current)
		current = _came_from[current]
	return path
