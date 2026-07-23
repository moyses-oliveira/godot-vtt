extends Node2D

signal tile_clicked(cell)

const WIDTH = 20
const HEIGHT = 12
const CELL_SIZE = 64

const RANGE_COLOR = Color(0.4, 1.0, 0.4, 0.35)
const ATTACK_RANGE_COLOR = Color(1.0, 0.35, 0.35, 0.45)
const HOVER_COLOR = Color(0.4, 0.8, 1.0, 0.5)
const OBSTACLE_COLOR = Color(0.15, 0.15, 0.15, 0.9)
const TRAP_COLOR = Color(1.0, 0.329, 0.0, 0.149)
const TRAP_ON_PATH_COLOR = Color(1.0, 0.15, 0.15, 0.6)
const GUIDE_LINE_COLOR = Color(0.95, 0.95, 1.0, 0.9)
const SELECTED_GLOW_COLOR = Color(1.0, 0.85, 0.2)
const SELECTED_GLOW_MIN_ALPHA = 0.12
const SELECTED_GLOW_MAX_ALPHA = 0.4
const SELECTED_GLOW_SPEED = 3.0

@export var obstacles: Array[Vector2i] = [
	Vector2i(3, 0), Vector2i(3, 1), Vector2i(3, 2), Vector2i(3, 3)
]
@export var traps: Array[Vector2i] = [
	Vector2i(2, 3)
]

var pathfinder: GridPathfinder

var _range: MovementRange
var _attack_cells: Array[Vector2i] = []
var hover_cell := Vector2i(-1, -1)
var hover_path: Array[Vector2i] = []
var _pulse_time := 0.0

func _ready():
	pathfinder = GridPathfinder.new(WIDTH, HEIGHT, obstacles, traps)
	queue_redraw()

func _process(delta):
	if _range:
		_pulse_time += delta
		queue_redraw()

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
	if _range:
		for cell in _range.cells:
			var color = HOVER_COLOR if cell == hover_cell else RANGE_COLOR
			draw_rect(Rect2(cell.x * CELL_SIZE, cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE), color)

	# celulas dos inimigos alcancaveis pelo ataque selecionado
	for cell in _attack_cells:
		var color = HOVER_COLOR if cell == hover_cell else ATTACK_RANGE_COLOR
		draw_rect(Rect2(cell.x * CELL_SIZE, cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE), color)

	# brilho dourado pulsante no tile do personagem selecionado
	if _range:
		var pulse = (sin(_pulse_time * SELECTED_GLOW_SPEED) + 1.0) / 2.0
		var alpha = lerpf(SELECTED_GLOW_MIN_ALPHA, SELECTED_GLOW_MAX_ALPHA, pulse)
		var rect = Rect2(_range.origin.x * CELL_SIZE, _range.origin.y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
		draw_rect(rect, Color(SELECTED_GLOW_COLOR.r, SELECTED_GLOW_COLOR.g, SELECTED_GLOW_COLOR.b, alpha))
		draw_rect(rect, Color(SELECTED_GLOW_COLOR.r, SELECTED_GLOW_COLOR.g, SELECTED_GLOW_COLOR.b, alpha + 0.3), false, 2.0)

	# armadilhas: sempre visiveis, destacadas quando o caminho em hover passa por elas
	for cell in traps:
		var color = TRAP_ON_PATH_COLOR if cell in hover_path else TRAP_COLOR
		draw_rect(Rect2(cell.x * CELL_SIZE, cell.y * CELL_SIZE, CELL_SIZE, CELL_SIZE), color)

	# linha guia mostrando por onde o personagem vai passar
	if hover_path.size() > 0:
		var points := PackedVector2Array()
		points.append(cell_center(_range.origin))
		for cell in hover_path:
			points.append(cell_center(cell))
		draw_polyline(points, GUIDE_LINE_COLOR, 3.0)
		for cell in hover_path:
			draw_circle(cell_center(cell), 5.0, GUIDE_LINE_COLOR)

func _unhandled_input(event):
	if _range:
		_handle_movement_input(event)
	elif not _attack_cells.is_empty():
		_handle_attack_input(event)

func _handle_movement_input(event) -> void:
	if event is InputEventMouseMotion:
		var cell = get_cell_from_local_pos(get_local_mouse_position())
		if _range.contains(cell):
			if cell != hover_cell:
				hover_cell = cell
				hover_path = _range.build_path_to(cell)
				queue_redraw()
		elif hover_cell != Vector2i(-1, -1):
			hover_cell = Vector2i(-1, -1)
			hover_path = []
			queue_redraw()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var cell = get_cell_from_local_pos(get_local_mouse_position())
			if _range.contains(cell):
				tile_clicked.emit(cell)

# Modo de ataque nao tem caminho a percorrer, entao so precisa saber se a
# celula sob o mouse e um dos alvos validos - sem MovementRange envolvido.
func _handle_attack_input(event) -> void:
	if event is InputEventMouseMotion:
		var cell = get_cell_from_local_pos(get_local_mouse_position())
		var new_hover = cell if cell in _attack_cells else Vector2i(-1, -1)
		if new_hover != hover_cell:
			hover_cell = new_hover
			queue_redraw()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var cell = get_cell_from_local_pos(get_local_mouse_position())
			if cell in _attack_cells:
				tile_clicked.emit(cell)

func get_cell_from_local_pos(pos: Vector2) -> Vector2i:
	return Vector2i(floori(pos.x / CELL_SIZE), floori(pos.y / CELL_SIZE))

func cell_center(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * CELL_SIZE + CELL_SIZE / 2, cell.y * CELL_SIZE + CELL_SIZE / 2)

func show_movement_range(origin: Vector2i, move_range: int, occupied_cells: Array[Vector2i] = []) -> void:
	_range = pathfinder.compute_reachable(origin, move_range, occupied_cells)
	_attack_cells = []
	hover_cell = Vector2i(-1, -1)
	hover_path = []
	queue_redraw()

## Recebe as celulas ja filtradas por AttackTargeting (so os inimigos
## dentro do alcance do ataque escolhido) e as destaca como clicaveis.
func show_attack_targets(cells: Array[Vector2i]) -> void:
	_attack_cells = cells
	_range = null
	hover_cell = Vector2i(-1, -1)
	hover_path = []
	queue_redraw()

func build_path_to(cell: Vector2i) -> Array[Vector2i]:
	if not _range:
		return []
	return _range.build_path_to(cell)

func clear_highlight() -> void:
	_range = null
	_attack_cells = []
	hover_cell = Vector2i(-1, -1)
	hover_path = []
	queue_redraw()
