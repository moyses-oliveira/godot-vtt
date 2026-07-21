extends Node2D

signal tile_clicked(cell)

const WIDTH = 20
const HEIGHT = 12
const CELL_SIZE = 64

const DIRECTIONS: Array[Vector2i] = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]

const RANGE_COLOR = Color(0.4, 1.0, 0.4, 0.35)
const HOVER_COLOR = Color(0.4, 0.8, 1.0, 0.5)
const OBSTACLE_COLOR = Color(0.15, 0.15, 0.15, 0.9)
const TRAP_COLOR = Color(1.0, 0.55, 0.0, 0.35)
const TRAP_ON_PATH_COLOR = Color(1.0, 0.15, 0.15, 0.6)
const GUIDE_LINE_COLOR = Color(0.95, 0.95, 1.0, 0.9)

@export var obstacles: Array[Vector2i] = [
	Vector2i(3, 0), Vector2i(3, 1), Vector2i(3, 2), Vector2i(3, 3)
]
@export var traps: Array[Vector2i] = [
	Vector2i(2, 3)
]

var highlighted_cells: Array[Vector2i] = []
var hover_cell := Vector2i(-1, -1)
var hover_path: Array[Vector2i] = []

var _origin_cell := Vector2i(-1, -1)
var _came_from: Dictionary = {}

func _draw():

	# linhas verticais
	for x in range(WIDTH + 1):
		draw_line(
			Vector2(x * CELL_SIZE, 0),
			Vector2(x * CELL_SIZE, HEIGHT * CELL_SIZE),
			Color.GRAY
		)

	# linhas horizontais
	for y in range(HEIGHT + 1):
		draw_line(
			Vector2(0, y * CELL_SIZE),
			Vector2(WIDTH * CELL_SIZE, y * CELL_SIZE),
			Color.GRAY
		)

	# obstaculos (bloqueiam movimento)
	for cell in obstacles:
		draw_rect(Rect2(cell.x * CELL_SIZE, cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE), OBSTACLE_COLOR)

	# quadrados de alcance de movimento
	for cell in highlighted_cells:
		var color = HOVER_COLOR if cell == hover_cell else RANGE_COLOR
		draw_rect(Rect2(cell.x * CELL_SIZE, cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE), color)

	# armadilhas: sempre visiveis, destacadas quando o caminho em hover passa por elas
	for cell in traps:
		var color = TRAP_ON_PATH_COLOR if cell in hover_path else TRAP_COLOR
		draw_rect(Rect2(cell.x * CELL_SIZE, cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE), color)

	# linha guia mostrando por onde o personagem vai passar
	if hover_path.size() > 0:
		var points := PackedVector2Array()
		points.append(cell_center(_origin_cell))
		for cell in hover_path:
			points.append(cell_center(cell))
		draw_polyline(points, GUIDE_LINE_COLOR, 3.0)
		for cell in hover_path:
			draw_circle(cell_center(cell), 5.0, GUIDE_LINE_COLOR)

func _ready():
	queue_redraw()

func _unhandled_input(event):
	if highlighted_cells.is_empty():
		return

	if event is InputEventMouseMotion:
		var cell = get_cell_from_local_pos(get_local_mouse_position())
		if cell in highlighted_cells:
			if cell != hover_cell:
				hover_cell = cell
				hover_path = build_path_to(cell)
				queue_redraw()
		elif hover_cell != Vector2i(-1, -1):
			hover_cell = Vector2i(-1, -1)
			hover_path = []
			queue_redraw()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var cell = get_cell_from_local_pos(get_local_mouse_position())
			if cell in highlighted_cells:
				tile_clicked.emit(cell)

func get_cell_from_local_pos(pos: Vector2) -> Vector2i:
	return Vector2i(floori(pos.x / CELL_SIZE), floori(pos.y / CELL_SIZE))

func cell_center(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * CELL_SIZE + CELL_SIZE / 2, cell.y * CELL_SIZE + CELL_SIZE / 2)

func is_within_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < WIDTH and cell.y >= 0 and cell.y < HEIGHT

func is_obstacle(cell: Vector2i) -> bool:
	return cell in obstacles

func is_trap(cell: Vector2i) -> bool:
	return cell in traps

# BFS ortogonal (cima/baixo/esquerda/direita) respeitando obstaculos,
# limitado ao alcance de movimento do personagem.
func show_movement_range(origin: Vector2i, move_range: int) -> void:
	_origin_cell = origin
	_came_from.clear()
	hover_cell = Vector2i(-1, -1)
	hover_path = []

	var distance = {origin: 0}
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
			_came_from[neighbor] = current
			queue.append(neighbor)

	highlighted_cells.clear()
	for cell in distance:
		if cell != origin:
			highlighted_cells.append(cell)

	queue_redraw()

func build_path_to(cell: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var current = cell
	while _came_from.has(current):
		path.push_front(current)
		current = _came_from[current]
	return path

func clear_highlight() -> void:
	highlighted_cells.clear()
	hover_cell = Vector2i(-1, -1)
	hover_path = []
	_came_from.clear()
	_origin_cell = Vector2i(-1, -1)
	queue_redraw()
